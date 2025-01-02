#!/bin/bash
# Reference: https://github.com/prowler-cloud/prowler/

# Exit immediately if a command exits with a non-zero status
set -e

if [ ! -f "./libs/main.sh" ]; then
  echo "Error: main.sh not found!"
  exit 1
fi
source "./libs/main.sh"
define_env
define_paths

if [ ! -f "./libs/install-helper.sh" ]; then
  echo "Error: install-helper.sh not found!"
  exit 1
fi
docker-compose up -d --force-recreate

# Step 1: Pre-installation
pre_install "prowler"
docker run --rm -it -e "TERM=xterm-256color" -v "${workdir}/${service_name}":/tmp ghcr.io/charmbracelet/glow:v2.0 glow /tmp/README.md
replace_env "PROWLER_COMMAND"

# Step 2: Start the service
printf "Starting the service...\n"
docker compose up -d --force-recreate

# Step 3: Post-installation output
# Add output from the prowler README.md
docker run --rm -it -e "TERM=xterm-256color" -v "${workdir}/${service_name}":/tmp ghcr.io/charmbracelet/glow:v2.0 /tmp/README.md
print_green_v2 "$service_name deployment started." "Successfully"
