#!/bin/bash

# Function to prompt for user input
prompt_for_port() {
  read -p "Enter the port number for the Laravel application (default: 80): " PORT
  PORT=${PORT:-80} # Default to 80 if no input is provided
}

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
