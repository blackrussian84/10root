#!/usr/bin/env bash
set -eo pipefail

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to print green message
print_green() {
  local message=$1
  printf "${GREEN}%s${NC}\n" "$message"
}

print_green_v2() {
  local message=$1
  local action=$2
  printf "${GREEN}✔${NC} %s ${GREEN}%s${NC}\n" "$message" "$action"
}

# Function to print red message
print_red() {
  local message=$1
  printf "${RED}%s${NC}\n" "$message"
}

# Function to print yellow message
print_yellow() {
  local message=$1
  printf "${YELLOW}%s${NC}\n" "$message"
}

# Ensure workdir, service_name, and resources_dir are defined
function define_paths() {
  home_path=${1:-"/home/$(whoami)/setup_platform"}
  workdir="${home_path}/workdir"
  resources_dir="${home_path}/resources"
  service_name="default_service"
}

# Function to Check if the first argument is provided
# Inputs:
# $1 - home_path
function check_home_path() {
  local home_path=${1:-"$home_path"}
  if [ -z "$home_path" ]; then
    print_red "Usage: %s <home_path>\n" "$0"
    exit 1
  fi
}

# Function to get env value from .env file
# Inputs:
# $1 - key to get the value
# $2[optional] - env file path
function get_env_value() {
  local key=$1
  local env_file=${2:-"${workdir}/${service_name}/.env"}
  local value
  value=$(sed -n "s/^${key}=//p" "$env_file")
  printf "%s\n" "$value"
}

# Replace the default values in the local .env file which uses by docker compose file
# Inputs:
# $1 - env file path to replace the values
# $2 - key to replace
function replace_env() {
  local key=$1
  local env_file=${2:-"${workdir}/${service_name}/.env"}

  if [[ -v $key ]]; then
    # Replace if the key exists, otherwise add it
    if grep -q "^${key}=" "$env_file"; then
      sed -i "s|${key}=.*|${key}=${!key}|" "$env_file"
    else
      echo "${key}=${!key}" >>"$env_file"
    fi
  else
    print_yellow "The env variable $key is not provided"
  fi
}

# Download external file
# Inputs:
# $1 - url to download
# $2 - file name to save
function download_external_file() {
  local url=$1
  local file_name=$2
  if [ ! -f "$file_name" ]; then
    curl --show-error --silent --location --output "$file_name" "$url"
    print_green_v2 "$file_name" "Downloaded"
  else
    print_red "$file_name already exists."
  fi
}

# PRE install steps for each app
# Inputs:
# $1 - service name
# $2 [option] - copy files from the source directory
function pre_install() {
  service_name=$1
  local copy_files=${2:-true}
  if [ -z "$service_name" ]; then
    printf "Service name is not provided\n"
    print_red "Usage: $0 <service_name>"
    exit 1
  fi

  src_dir="${resources_dir}/${service_name}"
  curr_dir=$(pwd)

  mkdir -p "${workdir}/${service_name}"

  # Step 1: Copy app related files
  if [ "$copy_files" = true ]; then
    if [ -d "$src_dir" ]; then
      printf "Copying app related files from %s...\n" "$src_dir"
      rsync -a "$src_dir/" "${workdir}/${service_name}/"
    else
      print_red "Source directory $src_dir does not exist. Exiting."
      exit 1
    fi
  else
    printf "Skipping copying app related files.\n"
  fi

  # Change to the directory where the docker-compose.yml file is located
  cd "${workdir}/${service_name}"

  # Change to the directory where the docker-compose.yml file is located
  cd "${workdir}/${service_name}"

  # Check if docker-compose.yml exists in the directory
  if [ ! -f "docker-compose.yml" ] && [ ! -f "docker-compose.yaml" ] && [ ! -f "compose.yml" ] && [ ! -f "compose.yaml" ]; then
    print_red "Can't find a suitable configuration file in ${workdir}/${service_name}. Exiting."
    exit 1
  fi

  cd "$curr_dir"
}