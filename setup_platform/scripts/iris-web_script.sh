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
find $home_path/resources/iris-web -name 'env.*.secret' -type f | xargs cp

generate_passwords_if_required .

docker compose build
docker compose up -d
