#!/bin/bash

function install_docker() {
  # Check if Docker is installed
  if ! command -v docker &>/dev/null; then
    echo "Docker is not installed. Installing Docker..."

    # Install Docker using the appropriate package manager
    # For Ubuntu/Debian:
    nx_script.shsudo apt-get update
    sudo apt-get install -y docker.io

    # For other distributions, please consult Docker's installation guide.
  else
    echo "Docker is already installed."
  fi
}

function install_docker_compose_plugin() {
  echo "Checking if Docker Compose plugin is already installed..."

  DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
  COMPOSE_PLUGIN_PATH="$DOCKER_CONFIG/cli-plugins/docker-compose"
  DOCKER_COMPOSE_VERSION="v2.26.0"

  # Check if the Docker Compose plugin is already installed
  if [ -x "$COMPOSE_PLUGIN_PATH" ]; then
    echo "Docker Compose plugin is already installed."

    # Check the version of the installed plugin
    installed_version=$("$COMPOSE_PLUGIN_PATH" version --short)
    echo "Installed Docker Compose plugin version: $installed_version"

    # Compare the installed version with the desired version
    if [ "$installed_version" == "$DOCKER_COMPOSE_VERSION" ]; then
      echo "Docker Compose plugin is up-to-date."
      return
    else
      echo "Updating Docker Compose plugin to version $DOCKER_COMPOSE_VERSION..."
    fi
  else
    echo "Docker Compose plugin is not installed. Installing version ${DOCKER_COMPOSE_VERSION}..."
  fi

  # Create the necessary directory
  mkdir -p "$DOCKER_CONFIG/cli-plugins"

  # Download and install the Docker Compose plugin
  curl -SL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64" -o "$COMPOSE_PLUGIN_PATH"
  chmod +x "$COMPOSE_PLUGIN_PATH"

  # Verification code
  if [ -x "$COMPOSE_PLUGIN_PATH" ]; then
    echo "Docker Compose plugin installed successfully."
  else
    echo "Error: Docker Compose plugin installation failed."
  fi
}

function add_docker_as_sudoer() {
  # Check if the current user is in the docker group
  if ! groups | grep -q "\bdocker\b"; then
    echo "Adding current user to the docker group..."

    # Add the current user to the docker group
    sudo usermod -aG docker $USER

    echo "Please log out and log back in for the changes to take effect."
  else
    echo "Current user is already a member of the docker group."
  fi
}

function create_docker_network() {
  local NETWORK_NAME="main_network"
  # Create Docker network
  sudo docker network create $NETWORK_NAME
  if docker network ls | grep -q $NETWORK_NAME; then
    echo "Network '$NETWORK_NAME' created successfully."
  else
    echo "Failed to create network '$NETWORK_NAME'."
  fi
}

install_docker
install_docker_compose_plugin
create_docker_network
