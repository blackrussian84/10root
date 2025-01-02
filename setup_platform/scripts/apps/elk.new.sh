#!/bin/bash
# Reference https://github.com/deviantony/elk/tree/main
###
# TODO: Why do we need to build ELK from the source code instead of using the official Docker image?
###
# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# shellcheck source=../libs/main.sh disable=SC1091
source "$(dirname "$(readlink -f "$0")")/../libs/main.sh"
# shellcheck source=../libs/install-helper.sh disable=SC1091
source "$(dirname "$(readlink -f "$0")")/../libs/install-helper.sh"

define_env
define_paths

# Ensure required functions are defined
function pre_install() {
  printf "Running pre-install steps for %s...\n" "$1"
  # Add any pre-install commands here
}

function replace_env() {
  local key="$1"
  local value="${!key}"
  if [ -n "$value" ]; then
    sed -i "s|^${key}=.*|${key}=${value}|" .env
  fi
}

# App specific variables
ELK_GIT_COMMIT=${ELK_GIT_COMMIT:-"629aea49616ae8a4184b5e68da904cb88e69831d"}

function clone_repository() {
  printf "Cloning the repository and checking out commit %s...\n" "$ELK_GIT_COMMIT"
  workdir=$(pwd)
  if [ -d "${workdir}/elk" ]; then
    print_red "The directory ${workdir}/elk already exists. Please remove it before running the script."
    print_red "You can run the following command to remove the directory:"
    print_yellow "./cleanup.sh --app elk"
    exit 1
  fi
  if ! git clone --branch main --single-branch --depth 1 https://github.com/deviantony/docker-elk.git "${workdir}/elk"; then
    print_red "Failed to clone the repository."
    exit 1
  fi
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
  if ! docker compose up setup; then
    print_red "Failed to start the setup service."
    exit 1
  fi

  printf "Starting the service...\n"
  if ! docker compose up -d; then
    print_red "Failed to start the service."
    exit 1
  fi
}

function import_dashboards() {
  printf "Waiting for Kibana to be ready...\n"
  local timeout=300
  local interval=5
  local elapsed=0

  while ! docker compose exec kibana curl -s -u "${KIBANA_SYSTEM_USER}:${KIBANA_SYSTEM_PASSWORD}" http://localhost:5601/api/status | grep -q '"overall":{"level":"available","summary":"All services and plugins are available"}'; do
    if [ "$elapsed" -ge "$timeout" ]; then
      print_red "Kibana did not become ready in time."
      exit 1
    fi
    printf "Sleeping %d; Still waiting for Kibana to be ready...\n" "$interval"
    sleep "$interval"
    elapsed=$((elapsed + interval))
  done

  docker compose exec kibana /bin/bash -c \
  "for file in /usr/share/kibana/dashboards/*.ndjson; do echo \"Importing \$file\"; curl -s -X POST -H 'kbn-xsrf: true' -u ${KIBANA_SYSTEM_USER}:${KIBANA_SYSTEM_PASSWORD} -H \"securitytenant: global\" http://localhost:5601/api/saved_objects/_import?overwrite=true --form file=@\"\$file\"; done"
}

function cleanup() {
  printf "Cleaning up...\n"
  # Add any cleanup commands here
}

trap cleanup EXIT

  # Main entry point for the script.
  #
  # This function is responsible for:
  # 1. Checking if KIBANA_SYSTEM_USER and KIBANA_SYSTEM_PASSWORD are set.
  # 2. Cloning the ELK repository and checking out the specified commit.
  # 3. Running the pre-install steps.
  # 4. Setting up the environment variables.
  # 5. Starting the services.
  # 6. Importing the dashboards.
  # 7. Printing the Kibana credentials.
  # 8. Printing a success message.
function main() {
  if [ -z "${KIBANA_SYSTEM_USER:-}" ] || [ -z "${KIBANA_SYSTEM_PASSWORD:-}" ]; then
  print_green_v2 "$service_name deployment completed." "Successfully"
    exit 1
  fi

  clone_repository
  pre_install "elk"
  setup_env_variables
  start_services
  import_dashboards

  printf "\n"
  print_with_border "Kibana credentials"
  printf "User: %s\n" "${KIBANA_SYSTEM_USER}"
  service_name="ELK"
  print_green_v2 "$service_name deployment started." "Successfully"
  print_green_v2 "$service_name deployment started." "Successfully"
}

main
