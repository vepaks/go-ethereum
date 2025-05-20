# Docker Build Workflow Documentation

## Overview

The Docker Build workflow (`docker-build.yml`) automatically builds and pushes Docker images to the GitHub Container Registry (GHCR) when pull requests with specific labels are merged into the master or develop branches.

## Workflow Triggers

This workflow triggers when:
- A pull request is closed (merged) into `master` or `develop` branches
- The pull request has the label `CI:Build`

## Environment Determination

The workflow automatically determines the environment based on the target branch:
- `master` → production environment (`prod`)
- `develop` → staging environment (`stage`)
- Any other branch → environment name matches the branch name

## Process Flow

1. **Setup**: 
   - Checkout the repository code
   - Set the environment variable based on the target branch
   - Set up Docker Buildx for multi-platform builds
   - Authenticate with GitHub Container Registry

2. **Image Metadata**:
   - For each image type (base and alltools), the workflow configures metadata
   - Sets up tags in format:
     - `<branch>_latest` - Latest version for the branch
     - `<branch>_<shortsha>` - Version tagged with short commit SHA 

3. **Docker Image Builds**:
   - Builds two Docker images for each branch/environment:
     - Base image (`ghcr.io/<repository>`)
     - Full toolset image (`ghcr.io/<repository>_alltools`)
   - Each image includes comprehensive metadata labels
   - Images are built with specific build arguments for traceability:
     - `COMMIT`: Git commit SHA
     - `VERSION`: Git commit SHA 
     - `BUILDNUM`: GitHub Actions run number

## Image Labels

Each image includes the following metadata labels:
- `org.opencontainers.image.title`: Image title with branch and environment
- `org.opencontainers.image.description`: Detailed description of the image
- `org.opencontainers.image.version`: Git commit SHA
- `org.opencontainers.image.revision`: Git commit SHA
- `org.opencontainers.image.source`: GitHub repository URL
- `org.opencontainers.image.url`: GitHub repository URL
- `org.opencontainers.image.documentation`: Link to README.md at the specific commit
- `org.opencontainers.image.authors`: GitHub actor who triggered the workflow

## Image Naming Convention

- Base image: `ghcr.io/<organization>/<repository>:<branch>_<tag>`
- All tools image: `ghcr.io/<organization>/<repository>_alltools:<branch>_<tag>`

Where `<tag>` is either:
- `latest` - For the most recent build
- Short Git SHA - For specific commit reference

## Deploy-Devnet Pipeline

The deploy-devnet pipeline is responsible for deploying the Go Ethereum node to a development network environment. This pipeline ensures proper testing and validation of the node in a controlled environment before production deployment.

### Pipeline Triggers

The deploy-devnet pipeline is triggered when:
- A pull request is merged into the `develop` branch
- The pull request has the label `CI:Deploy-Devnet`
- The Docker build workflow has successfully completed

### Deployment Process

1. **Environment Setup**:
   - Configures the development network environment
   - Sets up necessary environment variables
   - Authenticates with required services

2. **Node Deployment**:
   - Pulls the latest Docker image from GHCR
   - Deploys the Go Ethereum node to the development network
   - Configures node parameters and network settings
   - Sets up monitoring and logging

3. **Validation Steps**:
   - Verifies node connectivity
   - Checks synchronization status
   - Validates RPC endpoints
   - Tests basic node functionality

4. **Monitoring Setup**:
   - Configures Prometheus metrics
   - Sets up Grafana dashboards
   - Establishes alerting rules
   - Enables log aggregation

### Configuration Parameters

The deploy-devnet pipeline uses the following configuration parameters:
- `NETWORK_ID`: Development network identifier
- `NODE_NAME`: Unique identifier for the node
- `RPC_PORT`: Port for JSON-RPC API
- `WS_PORT`: Port for WebSocket API
- `P2P_PORT`: Port for peer-to-peer communication
- `SYNC_MODE`: Node synchronization mode
- `CACHE_SIZE`: Size of the node's cache
- `MAX_PEERS`: Maximum number of peer connections

### Health Checks

The pipeline implements several health checks:
1. **Node Status**:
   - Verifies node is running
   - Checks synchronization status
   - Validates peer connections

2. **API Endpoints**:
   - Tests JSON-RPC API
   - Validates WebSocket API
   - Checks admin API

3. **Performance Metrics**:
   - Monitors CPU usage
   - Tracks memory consumption
   - Measures network throughput

### Rollback Procedure

In case of deployment failure:
1. Automatically rolls back to the previous stable version
2. Notifies the development team
3. Logs the failure reason
4. Creates an incident report

### Monitoring and Alerts

The pipeline sets up:
1. **Performance Monitoring**:
   - Node synchronization status
   - Peer connection count
   - Transaction processing rate
   - Block propagation time

2. **Resource Monitoring**:
   - CPU utilization
   - Memory usage
   - Disk I/O
   - Network bandwidth

3. **Alert Conditions**:
   - Node synchronization issues
   - High resource utilization
   - Connection problems
   - Error rate thresholds

## Requirements

This workflow requires:
- GitHub Actions secrets:
  - `GITHUB_TOKEN` - Automatically provided by GitHub Actions
  - `DEVNET_SSH_KEY` - SSH key for development network access
  - `DEVNET_HOST` - Development network host address
  - `DEVNET_USER` - Development network username

## Example

When a PR with the label `CI:Build` is merged to `master`, the workflow produces:
- `ghcr.io/username/repo:master_latest`
- `ghcr.io/username/repo:master_a1b2c3d` (short SHA)
- `ghcr.io/username/repo_alltools:master_latest`
- `ghcr.io/username/repo_alltools:master_a1b2c3d` (short SHA)

When a PR with the label `CI:Deploy-Devnet` is merged to `develop`:
1. Docker image is built and pushed to GHCR
2. Deploy-devnet pipeline is triggered
3. Node is deployed to development network
4. Health checks are performed
5. Monitoring is set up
6. Deployment status is reported 