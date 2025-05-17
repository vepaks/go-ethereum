# CI Directory

This directory contains Docker configuration files used for Continuous Integration (CI) and container deployment of the Go Etherium client:

- `Dockerfile`: Defines a minimal Ethereum node image with just the `geth` client, using a multi-stage build process for optimal image size.
- `Dockerfile.alltools`: Creates a comprehensive Ethereum development image with all CLI tools provided by the Go Etherium implementation, including `geth`, `clef`, `devp2p`, `abigen`, `evm`, `rlpdump`, and other development tools.

These Docker configurations support the build and deployment processes for the Go Etherium project. 