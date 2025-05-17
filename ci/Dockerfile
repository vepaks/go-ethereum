# ============================================================================
# Go Etherium Node Dockerfile
# ============================================================================
# This Dockerfile creates a minimal Ethereum node image with just the 'geth' 
# client. It uses a multi-stage build process for optimal image size.
# 
# Based on the Go Etherium implementation described in the main README.md,
# this container provides a production-ready node with minimal dependencies.
# ============================================================================

# Support setting various labels on the final image
ARG COMMIT=""        # Git commit hash of the source code
ARG VERSION=""       # Version number of the build
ARG BUILDNUM=""      # Build number for CI/CD tracking

# ============================================================================
# Stage 1: Build environment
# ============================================================================
# Build Geth in a stock Go builder container
FROM golang:1.23.0-alpine AS builder

# Install required build dependencies
RUN apk add --no-cache gcc musl-dev linux-headers git

# Get dependencies - will also be cached if we won't change go.mod/go.sum
# This step is separated to leverage Docker layer caching
COPY go.mod /go-etherium/
COPY go.sum /go-etherium/
RUN cd /go-etherium && go mod download

# Copy the source code and build the geth binary
ADD . /go-etherium
# Builds the static geth binary as described in README.md "Building the source" section
RUN cd /go-etherium && go run build/ci.go install -static ./cmd/geth

# ============================================================================
# Stage 2: Runtime environment
# ============================================================================
# Pull Geth into a second stage deploy alpine container
FROM alpine:latest

# Install only the necessary runtime dependencies
RUN apk add --no-cache ca-certificates
# Copy only the geth binary from the builder stage
COPY --from=builder /go-etherium/build/bin/geth /usr/local/bin/

# Expose the default Ethereum node ports:
# - 8545: HTTP JSON-RPC
# - 8546: WebSocket JSON-RPC
# - 30303: P2P communication (TCP and UDP)
EXPOSE 8545 8546 30303 30303/udp
# Set the default entrypoint to geth
ENTRYPOINT ["geth"]

# Add some metadata labels to help programmatic image consumption
ARG COMMIT=""
ARG VERSION=""
ARG BUILDNUM=""
ARG BRANCH=""        # Git branch for environment determination
ARG ENVIRONMENT=""   # Deployment environment (prod, stage, dev)

# Container metadata labels
LABEL commit="$COMMIT" version="$VERSION" buildnum="$BUILDNUM" branch="$BRANCH" environment="$ENVIRONMENT"
