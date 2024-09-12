set -e

# --- Function to Check if the first argument is provided
# Inputs:
# $1 - home_path
function check_home_path() {
  local home_path=$1
  if [ -z "$home_path" ]; then
    printf "Usage: %s <home_path>\n" "$0"
    exit 1
  fi
}

# --- Function get env value from .env file
# Inputs:
# $1 - key to get the value
# $2[optional] - env file path
function get_env_value() {
  local key=$1
  local env_file=${2:-"${SCRIPTS_DIR}/${SERVICE_NAME}/.env"}
  local value=$(grep "$key" "$env_file" | cut -d '=' -f2)
  echo "$value"
}

# --- Replace the default values in the .env file which uses by docker-compose file
# Inputs:
# $1 - env file path to replace the values
# $2 - key to replace
function replace_env() {
  local key=$1
  local env_file=${2:-"${SCRIPTS_DIR}/${SERVICE_NAME}/.env"}

  if [[ -v $key ]]; then
    sed -i "s|${key}=.*|${key}=\"${!key}\"|" "$env_file"
  else
    echo "The env variable $key is not provided"
  fi
}
