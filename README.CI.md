# Go Ethereum CI/CD Documentation

## Overview

This repository includes a comprehensive CI/CD pipeline for building, testing, and deploying Go Ethereum Docker images. The system is designed for simplicity, reliability, and developer productivity.

## Quick Start

### For Developers

1. **Local testing before pushing:**
   ```bash
   cd ci/hardhat
   ./local-test.sh
   ```

2. **Triggering CI builds:**
   - Add `CI:Build` label to your PR to trigger Docker image builds
   - Add `CI:Deploy` label to your PR to trigger DevNet deployment

### For DevOps

1. **Managing images:**
   - Images are published to `ghcr.io/vepaks/go-ethereum`
   - Standard tags: `<branch>-latest` and `<branch>-<sha>`

2. **Environment mapping:**
   - `master` branch → Production environment
   - All other branches → Staging environment

## Documentation

### Detailed Guides

- [CI/CD Process](docs/ci/README.md) - Complete details about the CI/CD process
- [Image Management](docs/ci/IMAGE-MANAGEMENT.md) - Docker image management documentation
- [CI/CD Visual Guide](docs/ci/CICD-PROCESS.md) - Flowcharts and diagrams of the CI process

### Workflow Files

- [Docker Build Workflow](.github/workflows/docker-build.yml) - Builds and pushes main images
- [DevNet Deployment Workflow](.github/workflows/deploy-devnet.yml) - Builds and tests DevNet

## Key Features

- **Simplified build workflow** with reduced metadata extraction
- **Streamlined environment determination** with a straightforward branch → environment mapping
- **Docker Compose for testing** instead of direct Docker commands
- **Health checks** for reliable service startup
- **Configuration file approach** instead of environment variables
- **Local testing scripts** that mirror the CI process

## Image Hierarchy

- `geth` - Main Ethereum client
- `geth_alltools` - All Ethereum tools and utilities
- `geth_devnet` - Development network with pre-deployed contracts

## Contributing

When contributing to CI/CD:
1. Test locally using `local-test.sh`
2. Ensure consistency with the tagging convention
3. Maintain backward compatibility in Docker images
4. Document changes to the CI/CD process

## Future Improvements

- Extended system tests
- Performance benchmarking in CI
- Automatic vulnerability scanning
- Cross-platform builds

## Support

For help with the CI/CD pipeline:
- Open an issue with the label `ci-cd`
- Contact the DevOps team at devops@example.com