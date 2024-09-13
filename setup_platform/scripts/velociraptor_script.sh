#!/bin/bash
#Reference https://github.com/Velocidex/velociraptor and https://github.com/weslambert/velocistack

# Exit immediately if a command exits with a non-zero status
set -e

source "./libs/main.sh"
source "./libs/install_script_helper.sh"
# Check if home_path is provided
check_home_path "$1"

home_path=$1
GLOBAL_ENV="${home_path}/scripts/.env"
source "$GLOBAL_ENV"
SCRIPTS_DIR=$(pwd)

SERVICE_NAME="velociraptor"
SRC_DIR="$home_path/resources/$SERVICE_NAME"
GIT_COMMIT=${GIT_COMMIT_VELOCIRAPTOR:-6da375b2ad9bb1f7ea2105967742a04bd485c9d8}

print_green "Preparing the $SERVICE_NAME:$GIT_COMMIT stack...\n"
git clone https://github.com/weslambert/velociraptor-docker "$SERVICE_NAME"
cd "$SERVICE_NAME"
git checkout "$GIT_COMMIT"
cp "${SRC_DIR}/docker-compose.yaml" .
cp "${SRC_DIR}/entrypoint" .
cp "${SRC_DIR}/Dockerfile" .
cp "${SRC_DIR}/.env" .

# Define here env variables to replace in the .env file
replace_env "VELOX_USER"
replace_env "VELOX_PASSWORD"
replace_env "VELOX_SERVER_URL"
replace_env "VELOX_FRONTEND_HOSTNAME"
replace_env "VELOX_USER_2"
replace_env "VELOX_PASSWORD_2"

sudo docker compose build
sudo docker compose up -d
print_yellow "Waiting for the $SERVICE_NAME service to start..."
sleep 5

sudo chmod 777 -R "${SCRIPTS_DIR}/${SERVICE_NAME}/velociraptor"
sudo chmod 777 -R "${SCRIPTS_DIR}/${SERVICE_NAME}/velociraptor/clients"
cd velociraptor

# TODO: Should we use the entrypoint only or this way to copy custom folder?
# https://github.com/10RootOrg/Risx-MSSP/blob/ca9659236cc93989bd00c4c499db9d278753a6e4/setup_platform/resources/velociraptor/entrypoint#L41
cp -R "${SRC_DIR}/custom/" .
print_yellow "Add custom resources and restarting the $SERVICE_NAME service..."
sudo docker restart "${SERVICE_NAME}"
print_green "Velociraptor deployment completed successfully."

# --- Show login credentials
_VELOX_USER=$(get_env_value 'VELOX_USER')
_VELOX_PASSWORD=$(get_env_value 'VELOX_PASSWORD')
echo "############################################"
print_green "$SERVICE_NAME credentials:"
echo "Username: $_VELOX_USER"
echo "Password: $_VELOX_PASSWORD"
echo "############################################"

# If the VELOX_USER is not defined in the global .env, then add creds to the .env file
if [[ -z $VELOX_USER ]]; then
  print_green "Velociraptor credentials added to the .env file"
  echo "### Generated by Velociraptor scripts ###" >>"$home_path/scripts/.env"
  echo "VELOCIRAPTOR_USERNAME=$_VELOX_USER" >>"$home_path/scripts/.env"
  echo "VELOCIRAPTOR_PASSWORD=$_VELOX_PASSWORD" >>"$home_path/scripts/.env"
fi
