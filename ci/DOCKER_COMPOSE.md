# go-ethereum Docker Compose Setup

## Overview

This document provides detailed information about the Docker Compose setup for creating a local go-ethereum development environment. The Docker Compose configuration streamlines the process of running a local Ethereum devnet with both node and development tools containers, including support for private registry authentication and local container versions.

## Prerequisites

Before starting the environment, you need to:

1. Copy the `.env.example` file to `.env`:
```bash
cp .env.example .env
```

2. Fill in the required environment variables in the `.env` file:
- `REGISTRY_URL`: Your container registry URL
- `REGISTRY_USERNAME`: Your registry username
- `REGISTRY_PASSWORD`: Your registry password
- `BRANCH_NAME`: The branch name to use for pulling images (defaults to 'master')

3. Run the registry login script to authenticate with your container registry:
```bash
./ci/scripts/registry-login.sh
```

## Features

- Complete local development environment with a single command
- Pre-configured Ethereum node in development mode
- Development tools container with all utilities
- Persistent data volumes for blockchain and development data
- Network configuration for container communication
- Ready-to-use configuration for immediate development
- Support for private container registry authentication
- Local container version management

## Services

### Node Service (`node`)

The main Ethereum node service runs a fully configured `geth` instance in development mode:

- **Image**: Built from the main Dockerfile (`ci/Dockerfile`) or pulled from registry
- **Container Name**: `go-ethereum-node`
- **Exposed Ports**:
  - 8545 (HTTP JSON-RPC)
  - 8546 (WebSocket JSON-RPC)
  - 30303 (P2P TCP and UDP)
- **Data Volume**: Persistent `node-data` volume for blockchain data
- **Configuration**: 
  - Dev mode with instant mining (only when transactions are pending)
  - Full API access for development
  - Secure connection settings
  - Network ID 1337 (standard for local development)

### Tools Service (`tools`)

A development environment with all Ethereum tools available:

- **Image**: Built from the alltools Dockerfile (`ci/Dockerfile.alltools`) or pulled from registry
- **Container Name**: `go-ethereum-tools`
- **Dependencies**: Waits for `node` service to start
- **Data Volume**: Persistent `tools-data` volume for development data
- **Environment Variables**:
  - `ETHEREUM_RPC=http://node:8545` (configured to communicate with the node service)
- **Usage**: Access via `docker exec` commands to run specific tools

## Networks

- **go-ethereum-net**: Bridge network for container communication

## Volumes

- **node-data**: Persistent storage for blockchain data
- **tools-data**: Persistent storage for development tools data

## Usage

### Starting the Environment

From the root directory of the project:

```bash
cd ci
docker-compose up -d
```

### Using Local Container Versions

The Docker Compose configuration supports running local versions of containers. To use local versions:

1. Build the local images:
```bash
# Build node image
docker build -t go-ethereum-node:local -f ci/Dockerfile .

# Build tools image
docker build -t go-ethereum-tools:local -f ci/Dockerfile.alltools .
```

2. Update the image references in docker-compose.yml:
```yaml
services:
  node:
    image: go-ethereum-node:local
    # ... other configuration ...

  tools:
    image: go-ethereum-tools:local
    # ... other configuration ...
```

### Accessing the JSON-RPC API

The HTTP JSON-RPC API is available at:
```
http://localhost:8545
```

The WebSocket JSON-RPC API is available at:
```
ws://localhost:8546
```

### Using the Tools Container

You can execute commands in the tools container:

```bash
# Run a specific command
docker exec -it go-ethereum-tools abigen --help

# Start an interactive shell
docker exec -it go-ethereum-tools sh
```

### Stopping the Environment

From the root directory of the project:

```bash
cd ci
docker-compose down
```

## Configuration Options

### Adding External Nodes

To connect the node to external nodes, modify the docker-compose.yml:

```yaml
command: >
  --datadir=/data
  # ... existing options ...
  --nodiscover
  # Replace with:
  # --bootnodes=enode://pubkey@ip:port
```

### Changing Network ID

To use a different network ID:

```yaml
command: >
  --datadir=/data
  # ... existing options ...
  --networkid=1337
  # Replace with your preferred network ID:
  # --networkid=<your-network-id>
```

## Environment Variables

The following environment variables can be configured in the `.env` file:

- `REGISTRY_URL`: Container registry URL
- `REGISTRY_USERNAME`: Registry username
- `REGISTRY_TOKEN`: Registry token
- `BRANCH_NAME`: The branch name to use for pulling images (defaults to 'master')

Note: The services automatically pull the latest version of the images from the registry for the specified branch in `BRANCH_NAME`. This ensures you always have the most recent code for your development branch.

## Related Documents

- [README.md](../README.md) - Main project documentation
- [Dockerfile.md](Dockerfile.md) - Documentation for the node image
- [Dockerfile.alltools.md](Dockerfile.alltools.md) - Documentation for the development tools image
- [registry-login.sh](scripts/registry-login.sh) - Registry authentication script 