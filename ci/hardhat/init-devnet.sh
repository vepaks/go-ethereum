#!/bin/sh
# Simplified initialization script for Go Ethereum devnet
# This script starts geth in dev mode and deploys contracts

set -e  # Exit on any error

echo "===== Go Ethereum DevNet Initialization ====="
echo "Starting initialization at $(date)"

# Function to check if geth is responsive
is_geth_ready() {
    curl -s -X POST \
        -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
        http://localhost:8545 > /dev/null
    return $?
}

# Function to show node status information
show_node_status() {
    echo "--- Node Status ---"
    echo "Block number:"
    curl -s -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
        http://localhost:8545 | jq
    
    echo "Mining status:"
    curl -s -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_mining","params":[],"id":1}' \
        http://localhost:8545 | jq
    
    # Get the dev account address
    DEV_ACCOUNT=$(curl -s -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' \
        http://localhost:8545 | jq -r '.result[0]')
    
    echo "Dev account: $DEV_ACCOUNT"
    echo "Dev account balance:"
    curl -s -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_getBalance","params":["'$DEV_ACCOUNT'", "latest"],"id":1}' \
        http://localhost:8545 | jq
}

# Start geth in dev mode in the background
echo "Starting geth with arguments: $GETH_ARGS"
geth $GETH_ARGS &
GETH_PID=$!

# Check if geth started successfully
if ! ps -p $GETH_PID > /dev/null; then
    echo "ERROR: Failed to start geth process"
    exit 1
fi

# Wait for geth to be ready
echo "Waiting for geth RPC endpoint to be available..."
MAX_ATTEMPTS=20
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    if is_geth_ready; then
        echo "✓ Geth is ready!"
        break
    fi
    ATTEMPT=$((ATTEMPT + 1))
    echo "Waiting for geth to be ready... (attempt $ATTEMPT/$MAX_ATTEMPTS)"
    sleep 1
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    echo "ERROR: Geth failed to start within the timeout period"
    exit 1
fi

# Deploy contracts using Hardhat
echo "Deploying contracts with Hardhat..."
cd /app
if npx hardhat run scripts/deploy.js --network localhost; then
    echo "✓ Contracts deployed successfully"
else
    echo "ERROR: Contract deployment failed"
    exit 1
fi

# Print node status after deployment
show_node_status

echo "===== DevNet initialization completed successfully ====="
echo "RPC endpoint: http://localhost:8545"
echo "WebSocket endpoint: ws://localhost:8546"

# Keep the container running by following the geth process
echo "Node is running. Use Ctrl+C to stop."
wait $GETH_PID