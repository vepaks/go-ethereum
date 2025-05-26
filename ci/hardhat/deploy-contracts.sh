#!/bin/sh
# deploy-contracts.sh - Dedicated script for smart contract deployment
# This script handles only the contract deployment part of initialization
# It should be run after the Ethereum node is fully operational

set -e  # Exit on any error

echo "===== Contract Deployment Script ====="

# Function to check if the node is ready for deployment
check_node_ready() {
  echo "Checking if Ethereum node is ready for deployment..."
  
  # Try to get block number to verify node is responding
  RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
    ${RPC_URL:-http://localhost:8545})
  
  if echo "$RESPONSE" | grep -q "result"; then
    echo "✓ Node is responsive"
    return 0
  else
    echo "✗ Node is not responding properly"
    echo "Response: $RESPONSE"
    return 1
  fi
}

# Function to retrieve available accounts
get_accounts() {
  ACCOUNTS=$(curl -s -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' \
    ${RPC_URL:-http://localhost:8545} | jq -r '.result[0]')
  
  echo "Deployment account: $ACCOUNTS"
}

# Wait for node to be ready before deployment
MAX_ATTEMPTS=10
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
  if check_node_ready; then
    break
  fi
  ATTEMPT=$((ATTEMPT + 1))
  echo "Waiting for node to be ready... (attempt $ATTEMPT/$MAX_ATTEMPTS)"
  sleep 2
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
  echo "ERROR: Ethereum node not ready after maximum attempts"
  exit 1
fi

# Get accounts for deployment
get_accounts

# Execute contract deployment using Hardhat
echo "Deploying smart contracts..."
cd ${HARDHAT_DIR:-/app}

# Use appropriate network configuration based on environment
if [ -z "$HARDHAT_NETWORK" ]; then
  export HARDHAT_NETWORK=localhost
fi

# Deploy contracts
if npx hardhat run scripts/deploy.js --network ${HARDHAT_NETWORK}; then
  echo "✓ Contracts deployed successfully"
  
  # Get deployment addresses for verification
  echo "Deployed contract addresses:"
  grep -rE "Contract deployed to: [0-9a-fA-Fx]+" .
else
  echo "ERROR: Contract deployment failed"
  exit 1
fi

# Log successful deployment
echo "===== Contract Deployment Completed ====="

# Return success
exit 0