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

## Requirements

This workflow requires:
- GitHub Actions secrets:
  - `GITHUB_TOKEN` - Automatically provided by GitHub Actions

## Example

When a PR with the label `CI:Build` is merged to `master`, the workflow produces:
- `ghcr.io/username/repo:master_latest`
- `ghcr.io/username/repo:master_a1b2c3d` (short SHA)
- `ghcr.io/username/repo_alltools:master_latest`
- `ghcr.io/username/repo_alltools:master_a1b2c3d` (short SHA) 