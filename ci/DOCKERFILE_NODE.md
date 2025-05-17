# Node Dockerfile

## Overview

This document provides detailed information about the Dockerfile used to create the Go Etherium node container image. The image is a minimalistic, production-ready Ethereum node based on the Go Ethereum implementation (geth).

## Features

- Multi-stage build process for minimal image size
- Only includes the essential `geth` binary
- Based on Alpine Linux for a minimal footprint
- Configurable through environment variables and command-line arguments
- Exposed standard Ethereum ports for connectivity

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
2. Copies Go module files to leverage Docker layer caching
3. Copies the source code
4. Builds the static `geth` binary

#### Stage 2: Runtime

The second stage uses a minimal Alpine Linux image and:
1. Installs only runtime dependencies (CA certificates)
2. Copies the `geth` binary from the builder stage
3. Exposes the necessary ports
4. Sets the entrypoint to the `geth` command

## Ports

The image exposes the following ports:

| Port | Protocol | Description |
|------|----------|-------------|
| 8545 | TCP | HTTP JSON-RPC API endpoint |
| 8546 | TCP | WebSocket JSON-RPC API endpoint |
| 30303 | TCP | P2P communication |
| 30303 | UDP | P2P node discovery |

## Usage

### Basic Usage

```bash
docker run -d --name ethereum-node -p 8545:8545 -p 8546:8546 -p 30303:30303 -p 30303:30303/udp ghcr.io/your-org/go-ethereum:latest
```

### Custom Command-Line Options

You can append geth command-line options when running the container:

```bash
docker run -d --name ethereum-node ghcr.io/your-org/go-ethereum:latest --http --http.addr 0.0.0.0 --http.api eth,net,web3
```

### Environment Configuration

The image supports configuration through build arguments:

```bash
docker build \
  --build-arg COMMIT=abc123 \
  --build-arg VERSION=1.0.0 \
  --build-arg BUILDNUM=42 \
  --build-arg BRANCH=main \
  --build-arg ENVIRONMENT=prod \
  -t go-ethereum:custom \
  -f ci/Dockerfile .
```

## Related Documents

- [README.md](../README.md) - Main project documentation
- [docker-compose.yml](docker-compose.yml) - Docker Compose setup for local development
- [Dockerfile.alltools.md](Dockerfile.alltools.md) - Documentation for the development tools image 