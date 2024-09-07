#!/bin/bash
# Reference: https://github.com/target/strelka/

# Exit immediately if a command exits with a non-zero status
set -e

# Check if home_path is provided
if [ -z "$1" ]; then
  printf "Usage: %s <home_path>\n" "$0"
  exit 1
fi

home_path=$1
SERVICE_NAME="strelka"
SRC_DIR="$home_path/resources/$SERVICE_NAME"
CURR_DIR=$(pwd)

mkdir -p "${CURR_DIR}/${SERVICE_NAME}"
cd "${CURR_DIR}/${SERVICE_NAME}"

printf "Copying the Strelka stack configs...\n"
if [ -d "configs" ]; then
  read -p "The $SERVICE_NAME configs already exists in the resources directory. Would you like to overwrite them? (y/n): " overwrite
  if [[ "$overwrite" == "y" ]]; then
    cp -Rf "$SRC_DIR/configs" .
  fi
else
  cp -Rf "$SRC_DIR/configs" .
fi

printf "Copying the docker compose file...\n"
cp "$SRC_DIR/docker-compose.yml" .

# NOTE: --force-recreate is used to ensure that the containers are recreated with the new configs
docker compose up -d --force-recreate
printf "Strelka deployment completed successfully.\n"
