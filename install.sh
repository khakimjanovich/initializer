#!/bin/bash

# Function to prompt for user input
prompt_for_port() {
  read -p "Enter the port number for the Laravel application (default: 80): " PORT
  PORT=${PORT:-80} # Default to 80 if no input is provided
}

# Function to check and start Docker based on the OS
check_and_start_docker() {
  if [ "$(uname)" == "Darwin" ]; then
    # macOS
    if ! (pgrep -f Docker); then
      echo "Docker is not running. Starting Docker..."
      open --background -a Docker
      while ! docker system info > /dev/null 2>&1; do
        echo "Waiting for Docker to start..."
        sleep 5
      done
    else
      echo "Docker is already running."
    fi
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # Linux
    if ! (systemctl is-active --quiet docker); then
      echo "Docker is not running. Starting Docker..."
      sudo systemctl start docker
    else
      echo "Docker is already running."
    fi
  elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ] || [ "$(expr substr $(uname -s) 1 10)" == "CYGWIN_NT" ]; then
    # Windows
    if ! (docker info > /dev/null 2>&1); then
      echo "Docker is not running. Please start Docker Desktop manually."
      exit 1
    else
      echo "Docker is already running."
    fi
  else
    echo "Unsupported OS. Please start Docker manually."
    exit 1
  fi
}

# Check for Docker
if ! [ -x "$(command -v docker)" ]; then
  echo "Docker is not installed. Installing Docker..."
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  rm get-docker.sh
else
  echo "Docker is already installed."
fi

# Check if Docker is running
check_and_start_docker

# Check for Docker Compose (required for Sail)
if ! [ -x "$(command -v docker-compose)" ]; then
  echo "Docker Compose is not installed. Installing Docker Compose..."
  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
else
  echo "Docker Compose is already installed."
fi

# Check for Composer
if ! [ -x "$(command -v composer)" ]; then
  echo "Composer is not installed. Installing Composer..."
  curl -sS https://getcomposer.org/installer | php
  sudo mv composer.phar /usr/local/bin/composer
else
  echo "Composer is already installed."
fi

# Prompt for port number
prompt_for_port

# Update the .env file with the provided port
if [ -f .env ]; then
  sed -i "s/APP_PORT=.*$/APP_PORT=${PORT}/" .env
else
  cp .env.example .env
  echo "APP_PORT=${PORT}" >> .env
fi

# Run Makefile to build the development environment
make build
