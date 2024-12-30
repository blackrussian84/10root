#!/bin/bash
# Reference https://github.com/deviantony/elk/tree/main
###
# TODO: Why do we need to build ELK from the source code instead of using the official Docker image?
###
# Exit immediately if a command exits with a non-zero status
set -eu

source "./libs/main.sh"
source "./libs/install-helper.sh"

define_env
define_paths

# App specific variables
ELK_GIT_COMMIT=${ELK_GIT_COMMIT:-"629aea49616ae8a4184b5e68da904cb88e69831d"}

function clone_repository() {
  printf "Cloning the repository and checking out commit %s...\n" "$ELK_GIT_COMMIT"
  if [ -d "${workdir}/elk" ]; then
    print_red "The directory ${workdir}/elk already exists. Please remove it before running the script."
    print_red "You can run the following command to remove the directory:"
    print_yellow "./cleanup.sh --app elk"
    exit 1
  fi
  git clone --branch main --single-branch --depth 1 https://github.com/deviantony/docker-elk.git "${workdir}/elk"
  cd "${workdir}/elk"
  git fetch --depth 1 origin "$ELK_GIT_COMMIT"
  git checkout "$ELK_GIT_COMMIT"
}

function setup_env_variables() {
  grep -v '^#' .env | while read -r line; do
    key=$(echo "$line" | sed -E 's/(.*)=.*/\1/')
    replace_env "${key}"
  done
  replace_env "ELASTIC_VERSION"
}

function start_services() {
  printf "Starting up the setup service...\n"
  docker compose up setup

  printf "Starting the service...\n"
  docker compose up -d
}

function import_dashboards() {
  printf "Waiting for Kibana to be ready...\n"
  sleep 10
  while ! docker compose exec kibana curl -s -u "${KIBANA_SYSTEM_USER}:${KIBANA_SYSTEM_PASSWORD}" http://localhost:5601/api/status | grep -q '"overall":{"level":"available","summary":"All services and plugins are available"}'; do
    printf "Sleeping 5; Still waiting for Kibana to be ready...\n"
    sleep 5
  done

  docker compose exec kibana /bin/bash -c \
  "for file in /usr/share/kibana/dashboards/*.ndjson; do echo \"Importing \$file\"; curl -s -X POST -H 'kbn-xsrf: true' -u ${KIBANA_SYSTEM_USER}:${KIBANA_SYSTEM_PASSWORD} -H \"securitytenant: global\" http://localhost:5601/api/saved_objects/_import?overwrite=true --form file=@\"\$file\"; done"
}

function main() {
  clone_repository
  pre_install "elk"
  setup_env_variables
  start_services
  import_dashboards

  printf "\n"
  print_with_border "Kibana credentials"
  printf "User: %s\n" "${KIBANA_SYSTEM_USER}"
  printf "Password: %s\n" "${KIBANA_SYSTEM_PASSWORD}"
  print_green_v2 "$service_name deployment started." "Successfully"
}

main
