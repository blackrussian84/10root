#!/usr/bin/env bash
# --- The minimal set of functions which uses almost everywhere in the scripts

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

print_with_border() {
  local input_string="$1"
  local length=${#input_string}
  local border_len=$(( (80 - length) / 2 ))
  local extra_char=$(( (80 - length) % 2 ))
  printf "%${border_len}s %s %${border_len}s%s\n" "=" "$input_string" "=" "$extra_char"
  local border="===================== "
  # Calculate the length of the border
  local border_length=$(((80 - length - ${#border}) / 2))
  local extra_char=$(( (80 - length - ${#border}) % 2 ))
  # Print the top border
  printf "%s" "$border"
  for ((i = 0; i < border_length; i++)); do
    printf "="
  done
  printf " %s " "$input_string"
  for ((i = 0; i < border_length; i++)); do
    printf "="
  done
  printf "%s" "$border"
  if [ $extra_char -ne 0 ]; then
    printf "="
  fi
  printf "\n"
}

### Business functions ###
# Function to define env variables
define_env() {
  local env_file=${1:-"../workdir/.env"}

  if [ -f "$env_file" ]; then
    # shellcheck source=/dev/null
    source "$env_file"
    printf "%s is loaded\n" "$env_file"
  else
    print_red "Can't find the .env:\"$env_file\" file. Continue without an .env file."
  fi
}

# Function to define paths
define_paths() {
  if [ "$(whoami)" == "root" ]; then
    home_path="/root/setup_platform"
  else
    home_path="/home/$(whoami)/setup_platform"
  fi
  export resources_dir="$home_path/resources"
  export scripts_dir="$home_path/scripts"
  export workdir="$home_path/workdir"
  workdir="$home_path/workdir"
}