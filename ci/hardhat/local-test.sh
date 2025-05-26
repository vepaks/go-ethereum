#!/bin/bash
# local-test.sh - Local testing script that mirrors the CI process
# This script helps developers verify their changes locally before pushing to CI

set -e  # Exit immediately if a command exits with a non-zero status

# Print colored output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Go Ethereum DevNet Local Testing ===${NC}"
echo "This script runs the same tests that will run in CI"
echo "Starting at $(date)"

# Check if Docker is installed and running
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed or not in PATH${NC}"
    exit 1
fi

if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker daemon is not running${NC}"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Error: Docker Compose is not installed or not in PATH${NC}"
    exit 1
fi

# Check we're in the correct directory
if [ ! -f "Dockerfile.devnet" ]; then
    echo -e "${RED}Error: This script must be run from the ci/hardhat directory${NC}"
    echo "Current directory: $(pwd)"
    echo "Please run: cd go-ethereum/ci/hardhat && ./local-test.sh"
    exit 1
fi

# Default values
BRANCH="local"
TAG="latest"
SKIP_BUILD=false
CLEANUP=true

# Parse command line arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --skip-build) SKIP_BUILD=true; shift 1;;
    --no-cleanup) CLEANUP=false; shift 1;;
    --branch) BRANCH="$2"; shift 2;;
    --tag) TAG="$2"; shift 2;;
    *) echo "Unknown parameter: $1"; exit 1;;
  esac
done

# Build local devnet image if not skipped
if [ "$SKIP_BUILD" = false ]; then
    echo -e "${YELLOW}Building local devnet image...${NC}"
    # Navigate to the project root for the Docker build
    cd ../..
    
    # Build the devnet image
    docker build \
        -t "go-ethereum_devnet:${BRANCH}-${TAG}" \
        -f ci/hardhat/Dockerfile.devnet \
        --build-arg COMMIT=$(git rev-parse HEAD) \
        --build-arg VERSION=$(git describe --tags --always) \
        .
    
    # Return to the hardhat directory
    cd ci/hardhat
    
    echo -e "${GREEN}✓ Image built successfully${NC}"
fi

# Set environment variable for Docker Compose
export DEVNET_IMAGE="go-ethereum_devnet:${BRANCH}-${TAG}"
export BRANCH="$BRANCH"

echo -e "${YELLOW}Starting devnet container...${NC}"
docker-compose down -v &> /dev/null || true
docker-compose up -d devnet

# Wait for devnet to be healthy
echo "Waiting for devnet to be ready..."
max_attempts=30
attempts=0

while [ $attempts -lt $max_attempts ]; do
    health=$(docker inspect --format='{{.State.Health.Status}}' $(docker-compose ps -q devnet) 2>/dev/null || echo "error")
    
    if [ "$health" == "healthy" ]; then
        echo -e "${GREEN}✓ Devnet is healthy and ready!${NC}"
        break
    fi
    
    echo "Waiting for devnet to be healthy (attempt $attempts/$max_attempts)..."
    attempts=$((attempts + 1))
    sleep 2
done

if [ $attempts -eq $max_attempts ]; then
    echo -e "${RED}✗ Devnet failed to become healthy within timeout${NC}"
    docker-compose logs devnet
    
    # Cleanup before exit if enabled
    if [ "$CLEANUP" = true ]; then
        echo "Cleaning up containers..."
        docker-compose down -v
    fi
    
    exit 1
fi

# Run tests
echo -e "${YELLOW}Running smart contract tests...${NC}"
if docker-compose up --exit-code-from hardhat-tests hardhat-tests; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    TEST_RESULT=0
else
    echo -e "${RED}✗ Tests failed!${NC}"
    TEST_RESULT=1
fi

# Show devnet logs for reference
echo -e "${YELLOW}Recent devnet logs:${NC}"
docker-compose logs --tail 20 devnet

# Verify the RPC endpoint manually
echo -e "${YELLOW}Verifying RPC endpoint...${NC}"
if curl -s -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
    http://localhost:8545 | grep -q "result"; then
    echo -e "${GREEN}✓ RPC endpoint is responding correctly${NC}"
else
    echo -e "${RED}✗ RPC endpoint verification failed${NC}"
    TEST_RESULT=1
fi

# Cleanup if enabled
if [ "$CLEANUP" = true ]; then
    echo "Cleaning up containers..."
    docker-compose down -v
fi

# Summary
echo 
echo -e "${YELLOW}=== Test Summary ===${NC}"
if [ $TEST_RESULT -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed successfully!${NC}"
    echo "Your code is ready for CI pipeline."
else
    echo -e "${RED}✗ Tests failed. Please fix the issues before pushing to CI.${NC}"
fi

exit $TEST_RESULT