#!/bin/bash
# Script to login to GitHub Container Registry for go-ethereum
# This script follows best practices for secure container registry authentication

# Source environment variables
if [ -f ../.env ]; then
  source ../.env
elif [ -f ../.env.example ]; then
  echo "Warning: .env file not found. Using .env.example for testing purposes."
  source ../.env.example
else
  echo "Error: Neither .env nor .env.example files found in ci directory."
  echo "Please create .env in the ci directory with the following variables:"
  echo "REGISTRY_URL=ghcr.io"
  echo "REGISTRY_USERNAME=your-github-username"
  echo "REGISTRY_TOKEN=your-github-token"
  exit 1
fi

# Validate required variables
if [ -z "$REGISTRY_URL" ] || [ -z "$REGISTRY_USERNAME" ] || [ -z "$REGISTRY_TOKEN" ]; then
  echo "Error: Missing registry credentials in .env"
  echo "Please ensure REGISTRY_URL, REGISTRY_USERNAME, and REGISTRY_TOKEN are set."
  exit 1
fi

# Login to GitHub Container Registry using stdin to avoid token in process list
echo "Logging in to GitHub Container Registry ($REGISTRY_URL)..."
echo "$REGISTRY_TOKEN" | docker login "$REGISTRY_URL" -u "$REGISTRY_USERNAME" --password-stdin

if [ $? -eq 0 ]; then
  echo "Successfully logged in to GitHub Container Registry."
  echo "Note: GitHub tokens may expire. If you encounter authentication issues, generate a new token."
  echo "Credentials stored in: ~/.docker/config.json"
else
  echo "Failed to login to GitHub Container Registry. Please check your credentials."
  echo "Make sure your token has at least 'read:packages' scope."
  exit 1
fi

echo "Login complete. You can now use docker-compose to build and run go-ethereum containers."
echo "To build all tools: docker-compose -f ../docker-compose.yml build"
echo "To run a specific service: docker-compose -f ../docker-compose.yml up <service-name>" 