#!/bin/bash
# Reference: https://github.com/dfir-iris/iris-web/tree/master

. ./_library.sh

home_path=$1
if [ -d "iris-web" -a -d "iris-web/.git" ]
then
  cd iris-web
  git pull
else
  git clone https://github.com/dfir-iris/iris-web.git
  cd iris-web
fi

git checkout v2.4.10

cp $home_path/resources/iris-web/docker-compose.yml .
cp $home_path/resources/iris-web/environment.sh .
cp $home_path/resources/iris-web/*start_with_secrets.sh .
chmod a+rx,go-w *start_with_secrets.sh

# Replaces direct `cp` for the situation of no secrets exists
find $home_path/resources/iris-web -name 'env.*.secret' -type f | xargs -I % cp % .

# Replace direct `cp` for the cases with no testcases defined
find $home_path/resources/iris-web -name '*_testcase.sh' -type f | xargs -I % cp % .

# Read, would you like to generate passwords?
# If yes, then define GENERATE_ALL_PASSWORDS=true
read -p "Would you like to generate passwords? [Y/n] (default:no)" ANSWER
if [[ $ANSWER =~ ^[Yy]$ ]]
then
  export GENERATE_ALL_PASSWORDS=true
fi

generate_passwords_if_required .
# Show login credentials
echo "############################################"
echo "Login credentials:"
echo "Username: administrator"
echo "Password: $(cat env.IRIS_ADM_PASSWORD.secret)"
echo "############################################"

docker compose build
docker compose up -d
