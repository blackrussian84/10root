home_path=$1
mkdir nginx
cd nginx
cp -r $home_path/resources/nginx/.  .
. .env
docker compose up -d
