#!/usr/bin/env bash
set -eo pipefail

# List of required packages
REQUIRED_PACKAGES=("curl" "git" "docker" "docker-compose")

# Function to check if a package is installed
check_package_installed() {
  type "$1" >/dev/null 2>&1
}

# Function to check a list of required packages
check_required_packages() {
  local missing_packages=()

  for package in "$@"; do
    if ! check_package_installed "$package"; then
      missing_packages+=("$package")
    fi
  done

  if [ ${#missing_packages[@]} -eq 0 ]; then
    printf "\e[32mAll required packages are installed.\e[0m\n"
  else
    printf "\e[31mThe following packages are missing: %s\e[0m\n" "${missing_packages[*]}"
    exit 1
  fi
}

# Check if the required packages are installed
check_required_packages "${REQUIRED_PACKAGES[@]}"
