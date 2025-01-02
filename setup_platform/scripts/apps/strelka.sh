#!/bin/bash
# Reference: https://github.com/target/strelka/
# This script installs and configures the Strelka service.

# Exit immediately if a command exits with a non-zero status
set -e
# Load main functions and variables
define_env
define_paths

# Load installation helper functions
source "./libs/install-helper.sh"
define_paths
source "./libs/install-helper.sh"

# Step 1: Pre-installation
docker compose up -d --force-recreate || { echo "Failed to start the service"; exit 1; }

# Step 2: Start the service
printf "Starting the service...\n"
docker compose up -d --force-recreate

# Step 3: Update the YARA rules
# App specific variables
# Replace the original configs/python/backend/yara/*
curl -o "${TMP_DIR}"/yara-forge-rules-full.zip -Ls "${GITHUB_URL_YARAHQ}" || { echo "Failed to download YARA rules"; exit 1; }
unzip -o "${TMP_DIR}"/yara-forge-rules-full.zip -d "${TMP_DIR}" || { echo "Failed to unzip YARA rules"; exit 1; }
TMP_DIR=$(mktemp -d)
docker compose stop || { echo "Failed to stop the service"; exit 1; }
curl -o "${TMP_DIR}"/yara-forge-rules-full.zip -Ls "${GITHUB_URL_YARAHQ}"
cp "${TMP_DIR}"/packages/full/yara-rules-full.yar configs/python/backend/yara/rules.yara || { echo "Failed to copy YARA rules"; exit 1; }
docker compose up -d || { echo "Failed to restart the service"; exit 1; }
docker compose stop
rm -rf "${TMP_DIR}" || { echo "Failed to remove temporary directory"; exit 1; }
cp "${TMP_DIR}"/packages/full/yara-rules-full.yar configs/python/backend/yara/rules.yara
docker compose up -d
print_green_v2 "Strelka deployment started." "Successfully"
rm -rf "${TMP_DIR}"
printf "YARA rules updated successfully.\n"

print_green_v2 "$service_name deployment started." "Successfully"
