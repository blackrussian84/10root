#!/bin/bash
# Reference: https://timesketch.org/developers/getting-started/

# Exit immediately if a command exits with a non-zero status
set -e

# Source necessary scripts and define environment and paths
source "./libs/main.sh"
define_env
define_paths
source "./libs/install-helper.sh"

# Pre-installation step
pre_install "timesketch"

# Run the deployment script with sudo
sudo ./deploy_timesketch.sh

# Print success message
print_green_v2 "$service_name deployment started." "Successfully"
