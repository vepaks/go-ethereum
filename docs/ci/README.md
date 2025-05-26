# Go Ethereum CI/CD Documentation

## Overview

This document provides comprehensive information about the CI/CD pipeline for the Go Ethereum project. The pipeline handles building, testing, and deployment of various Docker images for different environments.

## CI/CD Workflow Architecture

```
┌─────────────────┐      ┌───────────────┐      ┌─────────────────┐
│                 │      │               │      │                 │
│  Pull Request   ├─────►│  Build & Test ├─────►│  Image Publish  │
│                 │      │               │      │                 │
└─────────────────┘      └───────────────┘      └─────────────────┘
        │                                               │
        │                                               │
        │                                               ▼
        │                                       ┌─────────────────┐
        │                                       │                 │
        └───────────────────────────────────────►     Deploy      │
                                                │                 │
                                                └─────────────────┘
```

## Docker Image Types

### 1. Main Image (`geth`)

Contains only the main Ethereum client binary.

- **Base Image**: `golang:1.23.0-alpine` (build), `alpine:latest` (runtime)
- **Tags**: `<branch>-latest`, `<branch>-<sha>`
- **Workflow**: `.github/workflows/docker-build.yml`

### 2. AllTools Image (`geth_alltools`)

Contains all Go Ethereum tools and utilities.

- **Base Image**: `golang:1.23.0-alpine` (build), `alpine:latest` (runtime)
- **Tags**: `<branch>-latest`, `<branch>-<sha>`
- **Workflow**: `.github/workflows/docker-build.yml`

### 3. DevNet Image (`geth_devnet`)

Development network with pre-deployed contracts for testing.

- **Base Image**: `ghcr.io/vepaks/go-ethereum_alltools:<branch>-latest`
- **Tags**: `<branch>-latest`, `<branch>-<sha>`
- **Workflow**: `.github/workflows/deploy-devnet.yml`

## Workflow Triggers

1. **Docker Build Workflow**: Triggered when a PR with label `CI:Build` is merged to `master` or `develop`
2. **DevNet Deployment**: Triggered when a PR with label `CI:Deploy` is merged to `master` or `develop`

## Environment Determination

- **Master Branch**: Production (`prod`)
- **All other branches**: Staging (`stage`)

## Image Tagging Convention

We use a standardized tagging convention across all images:

- `<branch>-latest`: Latest build from the specific branch
- `<branch>-<sha>`: Specific commit build from the branch

Examples:
- `master-latest`: Latest production build
- `develop-latest`: Latest staging build
- `master-abc1234`: Specific production build with commit SHA abc1234

## Docker Image Inheritance

```
┌─────────────────┐
│                 │
│   Alpine Base   │
│                 │
└────────┬────────┘
         │
         ▼
┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │
│  geth (main)    │     │  geth_alltools  │
│                 │     │                 │
└─────────────────┘     └────────┬────────┘
                                 │
                                 ▼
                        ┌─────────────────┐
                        │                 │
                        │   geth_devnet   │
                        │                 │
                        └─────────────────┘
```

## GitHub Container Registry

All images are pushed to GitHub Container Registry (GHCR):

- `ghcr.io/vepaks/go-ethereum:<tag>`
- `ghcr.io/vepaks/go-ethereum_alltools:<tag>`
- `ghcr.io/vepaks/go-ethereum_devnet:<tag>`

## Extending Docker Images

To extend an existing image:

1. Use the appropriate base image in your Dockerfile:
   ```dockerfile
   FROM ghcr.io/vepaks/go-ethereum_alltools:master-latest
   ```

2. Add your customizations:
   ```dockerfile
   RUN apk add --no-cache your-dependencies
   COPY your-files /destination/
   ```

3. Use consistent tagging:
   ```bash
   docker build -t your-image:master-latest .
   ```

## Local Development

For local development, use the provided scripts:

1. Build and test locally:
   ```bash
   cd ci/hardhat
   ./local-test.sh
   ```

2. Use custom options:
   ```bash
   ./local-test.sh --branch feature-xyz --tag dev
   ```

## CI/CD Pipeline Steps

### Docker Build Pipeline

1. **Checkout code**: Clone repository
2. **Set environment**: Determine environment based on branch
3. **Setup Docker Buildx**: Configure multi-platform builds
4. **Login to GHCR**: Authenticate with GitHub Container Registry
5. **Build & push main image**: Build and push the geth image
6. **Build & push alltools image**: Build and push the alltools image

### DevNet Deployment Pipeline

1. **Checkout code**: Clone repository
2. **Set environment**: Determine environment based on branch
3. **Setup Docker Buildx**: Configure for builds
4. **Login to GHCR**: Authenticate with GitHub Container Registry
5. **Build & push devnet image**: Build and push the devnet image
6. **Test devnet**: Deploy and test using Docker Compose
7. **Verify deployment**: Ensure contracts are deployed correctly

## Configuration Management

Environment-specific configurations are managed using template files:

- `ci/hardhat/.env.template`: Default environment variables
- `hardhat/config/hardhat.dev.js`: Development environment
- `hardhat/config/hardhat.stage.js`: Staging environment
- `hardhat/config/hardhat.prod.js`: Production environment

## Troubleshooting

### Common Issues

1. **Image build fails**: Verify dependencies and build arguments
2. **Tests fail in CI**: Run locally with `./local-test.sh` first
3. **Authentication issues**: Check GitHub token permissions
4. **Missing labels**: Ensure PR has correct labels (`CI:Build` or `CI:Deploy`)

### Logs and Debugging

Access CI workflow logs in GitHub Actions:
1. Navigate to Actions tab in GitHub repository
2. Select the workflow run
3. View detailed logs for each step

## Best Practices

1. Always test locally before pushing to CI
2. Use proper labels on PRs to trigger workflows
3. Follow the standardized tagging convention
4. Maintain backward compatibility when extending images

## Contact

For issues or questions about the CI/CD pipeline, please contact:
- DevOps Team: devops@example.com
- GitHub Repository: https://github.com/vepaks/go-ethereum