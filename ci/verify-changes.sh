#!/bin/bash
# verify-changes.sh - Script to verify CI/CD changes
# This script helps validate that the CI/CD improvements were successfully implemented

set -e  # Exit on error

# Print colored output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Display header
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}${BOLD}   Go Ethereum CI/CD Verification Tool${NC}"
echo -e "${BLUE}================================================${NC}"
echo

# Check if running from project root or ci directory
if [ -d "../.github" ]; then
  # We're in the ci directory
  cd ..
elif [ ! -d ".github" ]; then
  echo -e "${RED}Error: This script must be run from the project root or ci directory${NC}"
  echo "Current directory: $(pwd)"
  exit 1
fi

# Check for all required files
echo -e "${YELLOW}Checking for required files...${NC}"

# Array of files to check
FILES_TO_CHECK=(
  ".github/workflows/docker-build.yml"
  ".github/workflows/deploy-devnet.yml"
  "ci/hardhat/docker-compose.yml"
  "ci/hardhat/Dockerfile.devnet"
  "ci/hardhat/init-devnet.sh"
  "ci/hardhat/deploy-contracts.sh"
  "ci/hardhat/.env.template"
  "hardhat/config/hardhat.dev.js"
  "hardhat/config/hardhat.stage.js"
  "hardhat/config/hardhat.prod.js"
  "docs/ci/README.md"
  "docs/ci/IMAGE-MANAGEMENT.md"
  "docs/ci/CICD-PROCESS.md"
)

MISSING_FILES=0
for file in "${FILES_TO_CHECK[@]}"; do
  if [ -f "$file" ]; then
    echo -e "  ✓ ${GREEN}$file${NC}"
  else
    echo -e "  ✗ ${RED}$file${NC} - Missing"
    MISSING_FILES=$((MISSING_FILES + 1))
  fi
done

if [ $MISSING_FILES -gt 0 ]; then
  echo -e "\n${RED}Error: $MISSING_FILES required files are missing${NC}"
  exit 1
else
  echo -e "\n${GREEN}All required files are present!${NC}"
fi

# Check docker-build.yml for key improvements
echo -e "\n${YELLOW}Checking docker-build.yml for required improvements...${NC}"
DOCKER_BUILD_ISSUES=0

if grep -q "docker/metadata-action" .github/workflows/docker-build.yml; then
  echo -e "  ✗ ${RED}docker-build.yml${NC} - Still contains metadata-action (should be simplified)"
  DOCKER_BUILD_ISSUES=$((DOCKER_BUILD_ISSUES + 1))
else
  echo -e "  ✓ ${GREEN}Metadata extraction was simplified${NC}"
fi

if grep -q 'echo "ENVIRONMENT=${{ github.event.pull_request.base.ref }}"' .github/workflows/docker-build.yml; then
  echo -e "  ✗ ${RED}docker-build.yml${NC} - Complex environment determination logic not simplified"
  DOCKER_BUILD_ISSUES=$((DOCKER_BUILD_ISSUES + 1))
else
  echo -e "  ✓ ${GREEN}Environment determination logic simplified${NC}"
fi

if ! grep -q 'BRANCH\|BUILDNUM\|ENVIRONMENT' .github/workflows/docker-build.yml || grep -q 'COMMIT\|VERSION' .github/workflows/docker-build.yml; then
  echo -e "  ✓ ${GREEN}Build arguments were reduced to essentials${NC}"
else
  echo -e "  ✗ ${RED}docker-build.yml${NC} - Unnecessary build arguments not removed"
  DOCKER_BUILD_ISSUES=$((DOCKER_BUILD_ISSUES + 1))
fi

if grep -q "branch-latest\|branch-sha" .github/workflows/docker-build.yml; then
  echo -e "  ✓ ${GREEN}Tagging convention was simplified${NC}"
else
  echo -e "  ✗ ${RED}docker-build.yml${NC} - Tagging convention not simplified"
  DOCKER_BUILD_ISSUES=$((DOCKER_BUILD_ISSUES + 1))
fi

if [ $DOCKER_BUILD_ISSUES -gt 0 ]; then
  echo -e "\n${RED}Error: docker-build.yml still has $DOCKER_BUILD_ISSUES issues${NC}"
else
  echo -e "\n${GREEN}docker-build.yml successfully improved!${NC}"
fi

# Check deploy-devnet.yml for key improvements
echo -e "\n${YELLOW}Checking deploy-devnet.yml for required improvements...${NC}"
DEPLOY_DEVNET_ISSUES=0

if grep -q "ls -l" .github/workflows/deploy-devnet.yml; then
  echo -e "  ✗ ${RED}deploy-devnet.yml${NC} - Still contains redundant file system checks"
  DEPLOY_DEVNET_ISSUES=$((DEPLOY_DEVNET_ISSUES + 1))
else
  echo -e "  ✓ ${GREEN}Removed redundant file system checks${NC}"
fi

if grep -q "docker-compose" .github/workflows/deploy-devnet.yml; then
  echo -e "  ✓ ${GREEN}Using Docker Compose for deployment${NC}"
else
  echo -e "  ✗ ${RED}deploy-devnet.yml${NC} - Not using Docker Compose for deployment"
  DEPLOY_DEVNET_ISSUES=$((DEPLOY_DEVNET_ISSUES + 1))
fi

if [ -f "ci/hardhat/.env.template" ]; then
  echo -e "  ✓ ${GREEN}Using template file instead of dynamic .env creation${NC}"
else
  echo -e "  ✗ ${RED}Missing template .env file${NC}"
  DEPLOY_DEVNET_ISSUES=$((DEPLOY_DEVNET_ISSUES + 1))
fi

if [ $DEPLOY_DEVNET_ISSUES -gt 0 ]; then
  echo -e "\n${RED}Error: deploy-devnet.yml still has $DEPLOY_DEVNET_ISSUES issues${NC}"
else
  echo -e "\n${GREEN}deploy-devnet.yml successfully improved!${NC}"
fi

# Check Dockerfile.devnet for improvements
echo -e "\n${YELLOW}Checking Dockerfile.devnet for required improvements...${NC}"
DOCKERFILE_ISSUES=0

if grep -q "HEALTHCHECK" ci/hardhat/Dockerfile.devnet; then
  echo -e "  ✓ ${GREEN}Added proper Docker health checks${NC}"
else
  echo -e "  ✗ ${RED}Dockerfile.devnet${NC} - Missing proper health checks"
  DOCKERFILE_ISSUES=$((DOCKERFILE_ISSUES + 1))
fi

if grep -q "BUILD-TIME\|RUNTIME\|Stage 2: Build-time\|Stage 3: Runtime" ci/hardhat/Dockerfile.devnet; then
  echo -e "  ✓ ${GREEN}Clearly documented build-time vs. runtime operations${NC}"
else
  echo -e "  ✗ ${RED}Dockerfile.devnet${NC} - Missing clear documentation"
  DOCKERFILE_ISSUES=$((DOCKERFILE_ISSUES + 1))
fi

if [ $DOCKERFILE_ISSUES -gt 0 ]; then
  echo -e "\n${RED}Error: Dockerfile.devnet still has $DOCKERFILE_ISSUES issues${NC}"
else
  echo -e "\n${GREEN}Dockerfile.devnet successfully improved!${NC}"
fi

# Check hardhat configuration
echo -e "\n${YELLOW}Checking Hardhat configuration improvements...${NC}"
HARDHAT_ISSUES=0

if [ -f "hardhat/config/hardhat.dev.js" ] && [ -f "hardhat/config/hardhat.stage.js" ] && [ -f "hardhat/config/hardhat.prod.js" ]; then
  echo -e "  ✓ ${GREEN}Created separate environment configs${NC}"
else
  echo -e "  ✗ ${RED}Missing environment-specific configs${NC}"
  HARDHAT_ISSUES=$((HARDHAT_ISSUES + 1))
fi

if grep -q "switch (environment)" hardhat/hardhat.config.js; then
  echo -e "  ✓ ${GREEN}Simplified hardhat.config.js${NC}"
else
  echo -e "  ✗ ${RED}hardhat.config.js${NC} - Not using simplified config"
  HARDHAT_ISSUES=$((HARDHAT_ISSUES + 1))
fi

if [ $HARDHAT_ISSUES -gt 0 ]; then
  echo -e "\n${RED}Error: Hardhat configuration still has $HARDHAT_ISSUES issues${NC}"
else
  echo -e "\n${GREEN}Hardhat configuration successfully improved!${NC}"
fi

# Check documentation
echo -e "\n${YELLOW}Checking documentation improvements...${NC}"
DOC_ISSUES=0

if [ -f "docs/ci/README.md" ] && [ -f "docs/ci/IMAGE-MANAGEMENT.md" ] && [ -f "docs/ci/CICD-PROCESS.md" ]; then
  echo -e "  ✓ ${GREEN}Created comprehensive documentation${NC}"
else
  echo -e "  ✗ ${RED}Missing comprehensive documentation${NC}"
  DOC_ISSUES=$((DOC_ISSUES + 1))
fi

if [ -f "docs/ci/CICD-PROCESS.md" ] && grep -q "flowchart\|mermaid" docs/ci/CICD-PROCESS.md; then
  echo -e "  ✓ ${GREEN}Added diagrams to visualize the process${NC}"
else
  echo -e "  ✗ ${RED}Missing visual diagrams${NC}"
  DOC_ISSUES=$((DOC_ISSUES + 1))
fi

if [ $DOC_ISSUES -gt 0 ]; then
  echo -e "\n${RED}Error: Documentation still has $DOC_ISSUES issues${NC}"
else
  echo -e "\n${GREEN}Documentation successfully improved!${NC}"
fi

# Summary
echo -e "\n${BLUE}${BOLD}Verification Summary:${NC}"
TOTAL_ISSUES=$((DOCKER_BUILD_ISSUES + DEPLOY_DEVNET_ISSUES + DOCKERFILE_ISSUES + HARDHAT_ISSUES + DOC_ISSUES + MISSING_FILES))

if [ $TOTAL_ISSUES -eq 0 ]; then
  echo -e "${GREEN}✅ All CI/CD improvements have been successfully implemented!${NC}"
  echo -e "${GREEN}The project is ready for review and can be pushed to Git.${NC}"
  exit 0
else
  echo -e "${RED}❌ Found $TOTAL_ISSUES issues that need to be fixed:${NC}"
  echo -e "  - ${RED}Missing files: $MISSING_FILES${NC}"
  echo -e "  - ${RED}Docker build workflow issues: $DOCKER_BUILD_ISSUES${NC}"
  echo -e "  - ${RED}DevNet deployment issues: $DEPLOY_DEVNET_ISSUES${NC}"
  echo -e "  - ${RED}Dockerfile issues: $DOCKERFILE_ISSUES${NC}"
  echo -e "  - ${RED}Hardhat configuration issues: $HARDHAT_ISSUES${NC}"
  echo -e "  - ${RED}Documentation issues: $DOC_ISSUES${NC}"
  echo -e "\nPlease fix the identified issues before pushing to Git."
  exit 1
fi