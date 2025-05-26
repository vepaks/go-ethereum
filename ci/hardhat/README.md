# Go Ethereum DevNet Development Guide

This directory contains all configuration and scripts needed to build, test, and deploy the Go Ethereum development network with pre-deployed contracts.

## Overview

The DevNet provides a local development environment for testing Ethereum smart contracts and applications against a go-ethereum node. It includes:

- A custom Docker image based on go-ethereum
- Pre-deployed test contracts
- Simplified deployment workflow
- Docker Compose configuration for local development
- CI/CD integration

## Local Testing Before CI

Before pushing changes to CI, you can test them locally using the provided scripts. This ensures that your changes will work correctly in the CI pipeline.

### Prerequisites

- Docker
- Docker Compose

### Running Local Tests

From the `ci/hardhat` directory, run:

```bash
./local-test.sh
```

This script will:
1. Build a local DevNet image
2. Start the devnet container
3. Run the contract tests
4. Verify the deployment
5. Clean up resources

### Command Line Options

The `local-test.sh` script supports several command line arguments:

- `--skip-build`: Skip building the Docker image
- `--no-cleanup`: Don't remove containers after testing
- `--branch <branch>`: Specify branch name for image tagging (default: "local")
- `--tag <tag>`: Specify tag for image tagging (default: "latest")

Example:
```bash
./local-test.sh --branch feature-xyz --tag dev
```

## Configuration

### Environment Configuration

The DevNet uses configuration files instead of environment variables. Template files are provided:

- `.env.template`: Default configuration template
- Configuration files for specific environments are in `hardhat/config/`

### Docker Compose

The `docker-compose.yml` file defines:

- `devnet`: The main Ethereum node service with pre-deployed contracts
- `hardhat-tests`: Service for running tests against the devnet

## Project Structure

- `Dockerfile.devnet`: Docker image definition
- `docker-compose.yml`: Services configuration
- `init-devnet.sh`: Node initialization script
- `deploy-contracts.sh`: Contract deployment script
- `local-test.sh`: Local testing script

## Workflow Diagrams

### Local Development Workflow

```
1. Edit code/contracts → 2. Run local-test.sh → 3. Fix issues → 4. Push to GitHub
```

### CI/CD Workflow

```
1. PR to master/develop → 2. CI builds image → 3. Tests run → 4. Image published
```

## Health Checks

The DevNet container includes health checks to verify node status:

- RPC endpoint availability 
- Block production
- Contract deployment success

## Common Issues

1. **Connection refused**: Make sure no other service is using port 8545
2. **Failed to deploy contracts**: Check Hardhat configuration and contract code
3. **Container unhealthy**: Review logs with `docker-compose logs devnet`

## Version Compatibility

- Go Ethereum: 1.23.0
- Hardhat: 2.20.0+
- Solidity: 0.8.20