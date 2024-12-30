#!/usr/bin/env bash
# --- The minimal set of functions which uses almost everywhere in the scripts

set -eo pipefail

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to print colored message
print_message() {
  local color=$1
  local message=$2
  printf "${color}%s${NC}\n" "$message"
}

# Function to print green message with action
print_green_v2() {
  local message=$1
  local action=$2
  printf "${GREEN}✔${NC} %s ${GREEN}%s${NC}\n" "$message" "$action"
}

# Function to print with border
print_with_border() {
  local input_string="$1"
  local border="===================== "
  local border_length=$(( (80 - ${#input_string} - ${#border}) / 2 ))
  printf "%s%*s %s %*s%s\n" "$border" "$border_length" "" "$input_string" "$border_length" "" "$border"
}

### Business functions ###
# Function to define env variables
define_env() {
  local env_file=${1:-"../workdir/.env"}

  if [ -f "$env_file" ]; then
    source "$env_file"
    printf "%s is loaded\n" "$env_file"
  else
    print_message "$RED" "Can't find the .env:\"$env_file\" file. Continue without an .env file."
  fi
}

# Function to define paths
define_paths() {
  # username should be defined in the .env file
  # If the username is not defined, then ask user to enter the username
  if [ -z "$username" ]; then
    local current_user=$(whoami)
    read -p "Enter username for home directory setup (default: $current_user): " username
    username=${username:-$current_user}
  fi

  local home_path="/home/$username/setup_platform"
  local resources_dir="$home_path/resources"
  local scripts_dir="$home_path/scripts"
  local workdir="$home_path/workdir"
}
