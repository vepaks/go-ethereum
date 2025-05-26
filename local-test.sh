#!/bin/bash
# Root-level script for running local tests
# This script provides an easy entry point for running local tests

set -e  # Exit on error

# Print colored output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Display header
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   Go Ethereum Local Testing Tool${NC}"
echo -e "${BLUE}================================================${NC}"
echo

# Check if running from project root
if [ ! -d "ci/hardhat" ]; then
    echo -e "${RED}Error: This script must be run from the project root${NC}"
    echo "Current directory: $(pwd)"
    exit 1
fi

# Parse command line options
TEST_TYPE="all"
BRANCH="local"
TAG="latest"
SKIP_BUILD=false
VERBOSE=false

print_help() {
    echo -e "${YELLOW}Usage:${NC} $0 [options]"
    echo
    echo "Options:"
    echo "  --help          Show this help message"
    echo "  --type TYPE     Test type: all, devnet, unit, integration (default: all)"
    echo "  --branch NAME   Branch name for image tagging (default: local)"
    echo "  --tag TAG       Tag for image tagging (default: latest)"
    echo "  --skip-build    Skip Docker image building"
    echo "  --verbose       Show verbose output"
    echo
    echo "Examples:"
    echo "  $0 --type devnet"
    echo "  $0 --branch feature-xyz --tag dev --skip-build"
    echo
}

# Parse command line arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --help) print_help; exit 0;;
    --type) TEST_TYPE="$2"; shift 2;;
    --branch) BRANCH="$2"; shift 2;;
    --tag) TAG="$2"; shift 2;;
    --skip-build) SKIP_BUILD=true; shift 1;;
    --verbose) VERBOSE=true; shift 1;;
    *) echo -e "${RED}Unknown parameter: $1${NC}"; print_help; exit 1;;
  esac
done

# Check valid test type
if [[ ! "$TEST_TYPE" =~ ^(all|devnet|unit|integration)$ ]]; then
    echo -e "${RED}Error: Invalid test type '${TEST_TYPE}'${NC}"
    print_help
    exit 1
fi

# Run tests based on type
case "$TEST_TYPE" in
    all)
        echo -e "${YELLOW}Running all tests...${NC}"
        
        # Run unit tests
        echo -e "\n${BLUE}== Running unit tests ==${NC}"
        go test ./... -short
        
        # Run devnet tests
        echo -e "\n${BLUE}== Running devnet tests ==${NC}"
        cd ci/hardhat && ./local-test.sh --branch "$BRANCH" --tag "$TAG" $([ "$SKIP_BUILD" = true ] && echo "--skip-build") $([ "$VERBOSE" = true ] && echo "--verbose")
        cd ../..
        ;;
        
    devnet)
        echo -e "${YELLOW}Running devnet tests...${NC}"
        cd ci/hardhat && ./local-test.sh --branch "$BRANCH" --tag "$TAG" $([ "$SKIP_BUILD" = true ] && echo "--skip-build") $([ "$VERBOSE" = true ] && echo "--verbose")
        cd ../..
        ;;
        
    unit)
        echo -e "${YELLOW}Running unit tests...${NC}"
        go test ./... -short
        ;;
        
    integration)
        echo -e "${YELLOW}Running integration tests...${NC}"
        go test ./... -run Integration
        ;;
esac

echo
echo -e "${GREEN}All requested tests completed successfully!${NC}"