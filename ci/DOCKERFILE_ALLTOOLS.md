# AllTools Dockerfile

## Overview

This document provides detailed information about the `Dockerfile.alltools` used to create the Go Etherium development tools container image. This image contains all CLI utilities from the Go Ethereum implementation, providing a comprehensive development environment.

## Features

- Multi-stage build process for optimal image organization
- Includes the full suite of Ethereum development tools
- Based on Alpine Linux for a minimal footprint
- Configurable through environment variables
- Designed to work alongside the node container

## Included Tools

As referenced in the main README.md under the "Executables" section, this image includes:

- **geth**: Main Ethereum CLI client
- **clef**: Stand-alone signing tool
- **devp2p**: Utilities for networking layer interaction
- **abigen**: Source code generator for Ethereum contract bindings
- **evm**: Developer utility for running EVM bytecode
- **rlpdump**: Developer utility for RLP data conversion
- Additional helper utilities and development tools

## Image Structure

### Build Arguments

| Argument | Description |
|----------|-------------|
| `COMMIT` | Git commit hash of the source code |
| `VERSION` | Version number of the build |
| `BUILDNUM` | Build number for CI/CD tracking |
| `BRANCH` | Git branch for environment determination |
| `ENVIRONMENT` | Deployment environment (prod, stage, dev) |

### Build Stages

#### Stage 1: Builder

The first stage uses the official Go image as a base and:
1. Installs necessary build dependencies
2. Copies Go module files for dependency caching
3. Copies the source code
4. Builds the `geth` client first for layer caching
5. Builds all tools using the same build infrastructure

#### Stage 2: Runtime

The second stage uses a minimal Alpine Linux image and:
1. Installs only runtime dependencies (CA certificates)
2. Copies all binaries from the builder stage
3. Exposes the standard Ethereum ports

## Ports

The image exposes the following ports:

| Port | Protocol | Description |
|------|----------|-------------|
| 8545 | TCP | HTTP JSON-RPC API endpoint |
| 8546 | TCP | WebSocket JSON-RPC API endpoint |
| 30303 | TCP | P2P communication |
| 30303 | UDP | P2P node discovery |

## Usage

### Running the Container

```bash
docker run -it --name ethereum-tools ghcr.io/your-org/go-ethereum_alltools:latest
```

### Executing Tools Within the Container

```bash
# Run a specific tool
docker exec -it ethereum-tools abigen --help

# Start an interactive shell
docker exec -it ethereum-tools sh
```

### Integration with Node Container

This container works best when connected to a running Ethereum node:

```bash
docker run -it --name ethereum-tools --link ethereum-node:node -e ETHEREUM_RPC=http://node:8545 ghcr.io/your-org/go-ethereum_alltools:latest
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ETHEREUM_RPC` | URL to connect to an Ethereum node | (none) |

## Related Documents

- [README.md](../README.md) - Main project documentation
- [docker-compose.yml](docker-compose.yml) - Docker Compose setup for local development
- [Dockerfile.md](Dockerfile.md) - Documentation for the node image 