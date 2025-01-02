#!/bin/bash
set -eo pipefail

source libs/main.sh
rsync -a ../resources/default.env ../workdir/.env
define_env ../workdir/.env
define_paths

source libs/prerequisites-check.sh

# Define necessary variables
scripts_dir="$(dirname "$(readlink -f "$0")")"
home_path="$(cd ~ && pwd)"

# Ensure APPS_TO_INSTALL is defined and is an array
if [ -z "${APPS_TO_INSTALL+x}" ] || [ "${#APPS_TO_INSTALL[@]}" -eq 0 ]; then
  echo "APPS_TO_INSTALL is not defined or is empty. Exiting."
  exit 1
fi

# Function to deploy the services
deploy_service() {
  local service_name="$1"
  print_with_border "Deploying $service_name"
  if ! bash "${scripts_dir}/apps/${service_name}.sh" "$home_path"; then
    echo "Failed to deploy $service_name. Exiting."
    exit 1
  fi
}

# Deploy each service
for service in "${APPS_TO_INSTALL[@]}"; do
  deploy_service "$service"
done

# Deploy nginx as the last service
deploy_service "nginx"

# Ensure curl is installed
if ! command -v curl &> /dev/null; then
  echo "curl could not be found. Please install curl to proceed."
  exit 1
fi

# Set MYIP and PROTO if not already set
MYIP=${MYIP:-$(curl -s ifconfig.me)}
PROTO=${PROTO:-https}

# Define service endpoints
declare -a ENDPOINTS=(
  "cyberchef    : $PROTO://$MYIP/cyberchef/"
  "elk          : $PROTO://$MYIP/kibana/"
  "iris-web     : $PROTO://$MYIP:8443/"
  "nightingale  : $PROTO://$MYIP/nightingale/"
  "portainer    : $PROTO://$MYIP/portainer/"
  "prowler      : $PROTO://$MYIP:8844/"
  "strelka      : $PROTO://$MYIP:8843/"
  "timesketch   : $PROTO://$MYIP/"
  "velociraptor : $PROTO://$MYIP/velociraptor"
  "misp         : $PROTO://$MYIP/misp/"
  "opencti      : $PROTO://$MYIP/opencti/"
)

# Print success message and endpoints
print_green "All the docker services are deployed successfully."
print_with_border "Access the services using below links"
for service in "${APPS_TO_INSTALL[@]}"; do
  for endpoint in "${ENDPOINTS[@]}"; do
    if [[ $endpoint == "$service"* ]]; then
      echo "$endpoint"
    fi
  done
done