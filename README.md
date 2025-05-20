# Go Ethereum CI/CD Infrastructure

This repository implements CI/CD infrastructure for deploying a forked version of go-ethereum using GitHub Actions, Docker, Hardhat, and Terraform.

## Project Structure

```
.
├── .github/          # GitHub Actions workflows
├── ci/              # CI/CD and Docker configurations
│   ├── hardhat/     # Hardhat Docker configurations
│   └── scripts/     # CI/CD utility scripts
├── hardhat/         # Smart contract development
└── terraform/       # AWS EKS infrastructure
```

## Development Branches

- `feature/terraform-k8s-deployment`: AWS EKS cluster setup
- `feature/ci-workflows`: GitHub Actions workflows
- `dev/local-containerization`: Local development setup
- `feature/hardhat-setup`: Smart contract development

## Features

1. **Docker Image Management**
   - Automated builds on PR merge
   - GitHub Container Registry integration
   - Multi-stage builds

2. **Local Development**
   - Docker Compose setup
   - Development network
   - Environment management

3. **Smart Contracts**
   - Hardhat project
   - Contract deployment

4. **Cloud Infrastructure**
   - AWS EKS deployment
   - Kubernetes configuration
   - Terraform automation

## CI/CD Pipeline

- `CI:Build` label: Builds and pushes Docker images
- `CI:Deploy` label: Deploys to development network


## Documentation

- [CI/CD Documentation](ci/README.md)
- [Docker Setup](ci/DOCKER_COMPOSE.md)
- [GitHub Workflows](.github/DOCKER_WORKFLOW_DOCUMENTATION.md)
- [Hardhat Setup](hardhat/README.md)
- [Terraform Setup](terraform/README.md)

## Prerequisites

- Docker & Docker Compose
- Node.js & npm
- AWS CLI
- kubectl
- Terraform
- GitHub account

## Author

Created by [Aleksandar Kamburov](https://github.com/vepaks)
