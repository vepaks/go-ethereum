# Go Ethereum Docker Image Management

## Overview

This document outlines the standardized practices for managing Go Ethereum Docker images across development, staging, and production environments.

## Image Repository Structure

The Go Ethereum project maintains the following Docker images in GitHub Container Registry (GHCR):

| Image | Purpose | Base | Registry Path |
|-------|---------|------|--------------|
| `geth` | Main Ethereum client | `alpine:latest` | `ghcr.io/vepaks/go-ethereum` |
| `geth_alltools` | All Ethereum tools | `alpine:latest` | `ghcr.io/vepaks/go-ethereum_alltools` |
| `geth_devnet` | Development network | `geth_alltools` | `ghcr.io/vepaks/go-ethereum_devnet` |

## Standardized Tagging Convention

All images follow this tagging convention:

- `<branch>-latest`: Most recent build from a specific branch
- `<branch>-<sha>`: Build from a specific commit
- `<version>`: Release version (e.g., `v1.12.0`)

Examples:
```
ghcr.io/vepaks/go-ethereum:master-latest
ghcr.io/vepaks/go-ethereum:develop-abc1234
ghcr.io/vepaks/go-ethereum:v1.12.0
```

## Image Inheritance and Extension

### Base Images

The inheritance hierarchy is:
1. `alpine:latest` → `geth` and `geth_alltools`
2. `geth_alltools` → `geth_devnet`

When extending images, always reference the exact parent image version:

```dockerfile
# Good practice - reference specific version
FROM ghcr.io/vepaks/go-ethereum_alltools:master-abc1234

# Avoid - using floating tags
FROM ghcr.io/vepaks/go-ethereum_alltools:latest
```

### Extension Process

To properly extend an image:

1. Start with the appropriate base image
2. Add your customizations
3. Document build-time vs. runtime operations
4. Include proper labels for traceability
5. Add appropriate health checks

Example:
```dockerfile
FROM ghcr.io/vepaks/go-ethereum_alltools:master-latest

# Build-time operations
RUN apk add --no-cache your-dependencies

# Configuration
COPY ./config/defaults.json /app/config/

# Runtime configuration
ENV CONFIG_PATH=/app/config/defaults.json

# Health check
HEALTHCHECK --interval=30s --timeout=10s CMD curl -f http://localhost:8545 || exit 1
```

## Publishing Images

### Automated Publishing

Images are automatically built and published by GitHub Actions when:
1. A PR with the `CI:Build` label is merged to `master` or `develop`
2. A tag matching the pattern `v*` is created

### Manual Publishing

For manual publishing:

```bash
# Build the image
docker build -t ghcr.io/vepaks/go-ethereum:custom-tag .

# Log in to GHCR
echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USER --password-stdin

# Push the image
docker push ghcr.io/vepaks/go-ethereum:custom-tag
```

## Image Versioning Strategy

### Semantic Versioning

Released images follow semantic versioning:
- `MAJOR.MINOR.PATCH` (e.g., `v1.12.0`)

### Development Versions

Development images use:
- Branch name + commit SHA: `develop-abc1234`
- Branch name + latest: `develop-latest`

## Image Cleanup Policy

### Retention Policy

- Production images are retained indefinitely
- Development images are purged after 90 days
- PR-specific images are purged after 30 days

### Automated Cleanup

Cleanup is handled by GitHub Actions workflow:
```yaml
name: Image Cleanup
on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sundays

jobs:
  cleanup:
    runs-on: ubuntu-latest
    steps:
      - name: Delete old development images
        uses: actions/delete-package-versions@v3
        with:
          package-name: 'go-ethereum_devnet'
          min-versions-to-keep: 10
          ignore-versions: '^master-.*$'
```

## Best Practices

1. **Immutable Tags**: Never update an existing tag with new content
2. **Layer Optimization**: Combine related RUN commands to reduce layers
3. **Security Scanning**: Run security scans on all images
4. **Minimal Images**: Include only necessary components
5. **Proper Documentation**: Document image contents and usage

## Testing New Images

Before publishing, test images with:

```bash
# Test locally
cd ci/hardhat
./local-test.sh --branch your-branch --tag your-tag

# Verify image functionality
docker run --rm -it ghcr.io/vepaks/go-ethereum:your-tag version
```

## Image Promotion Workflow

For promoting images across environments:

1. Build and test in development
2. Tag and promote to staging
3. Approve for production
4. Tag and promote to production

```bash
# Example promotion script
#!/bin/bash
SOURCE_TAG="develop-abc1234"
TARGET_TAG="master-latest"

docker pull ghcr.io/vepaks/go-ethereum:$SOURCE_TAG
docker tag ghcr.io/vepaks/go-ethereum:$SOURCE_TAG ghcr.io/vepaks/go-ethereum:$TARGET_TAG
docker push ghcr.io/vepaks/go-ethereum:$TARGET_TAG
```

## Image Metadata

All images should include standardized labels:

```dockerfile
LABEL org.opencontainers.image.title="Go Ethereum"
LABEL org.opencontainers.image.description="Official Go implementation of the Ethereum protocol"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.source="https://github.com/vepaks/go-ethereum"
LABEL org.opencontainers.image.licenses="LGPL-3.0"
```