#!/bin/bash
# Reference https://github.com/MISP/

# Exit immediately if a command exits with a non-zero status
set -e

# Load helper functions and define environment variables
source "./libs/main.sh"
define_env
define_paths
source "./libs/install-helper.sh"

# Step 1: Pre-installation
pre_install "misp"

# Step 2: Start the service
printf "Starting the service...\n"
sudo docker-compose up -d --force-recreate

# Ensure the service name is defined
service_name="misp"
print_green_v2 "$service_name deployment started." "Successfully"
