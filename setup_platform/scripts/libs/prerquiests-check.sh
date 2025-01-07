#!/usr/bin/env bash
set -eo pipefail
# Verify if the required packages are installed

# List of required packages
REQUIRED_PACKAGES=("curl" "git" "docker" "docker-compose")

# Array to hold missing packages
MISSING_PACKAGES=()

# Function to check if a package is installed
check_package_installed() {
  local package=$1
  if command -v "$package" &> /dev/null; then
    echo "$package is installed."
  else
    echo "$package is not installed."
    MISSING_PACKAGES+=("$package")
  fi
}

# Function to check a list of required packages
check_required_packages() {
  local packages=("${@}")
  printf "Checking required packages...\n"
  for package in "${packages[@]}"; do
    check_package_installed "$package"
  done
  if [ ${#MISSING_PACKAGES[@]} -eq 0 ]; then
    echo -e "\e[32mAll required packages are installed.\e[0m"
  else
    echo -e "\e[31mThe following packages are missing: ${MISSING_PACKAGES[*]}\e[0m"
    exit 1
  fi
}

# Check if the required packages are installed
check_required_packages "${REQUIRED_PACKAGES[@]}"
