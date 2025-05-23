#!/bin/sh

# Function to check if geth is ready
check_geth() {
    curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' http://localhost:8545 > /dev/null
    return $?
}

# Start geth in dev mode with the configured options
echo "Starting geth in dev mode..."
geth $GETH_ARGS &

# Wait for geth to start and initialize
echo "Waiting for geth to initialize..."
timeout=30
while [ $timeout -gt 0 ]; do
    if check_geth; then
        echo "Geth is ready!"
        break
    fi
    echo "Waiting for geth to be ready... ($timeout attempts remaining)"
    sleep 1
    timeout=$((timeout-1))
done

if [ $timeout -eq 0 ]; then
    echo "Failed to start geth"
    exit 1
fi

# Get the dev account address (first account returned by eth_accounts)
DEV_ACCOUNT=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' http://localhost:8545 | jq -r '.result[0]')
echo "Using dev account address: $DEV_ACCOUNT"

# Show balance for dev account
BALANCE=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_getBalance","params":["'$DEV_ACCOUNT'", "latest"],"id":1}' http://localhost:8545 | jq -r '.result')
echo "Dev account balance: $BALANCE"

# Deploy the contracts using Hardhat
echo "Deploying contracts..."
cd /app
npx hardhat run scripts/deploy.js --network localhost

# Verify deployment
if [ $? -ne 0 ]; then
    echo "Failed to deploy contracts"
    exit 1
fi

# Save the blockchain state
echo "Saving blockchain state..."
curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"miner_stop","params":[],"id":1}' http://localhost:8545

# Wait for the state to be saved
sleep 2

# Restart mining to continue block production
echo "Restarting mining..."
curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"miner_start","params":[1],"id":1}' http://localhost:8545

# Final verification
if check_geth; then
    echo "Devnet is ready with deployed contracts!"
    echo "RPC endpoint: http://localhost:8545"
    echo "WebSocket endpoint: ws://localhost:8546"
    
    # Show some useful information
    echo "Current block number:"
    curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' http://localhost:8545
    echo "Mining status:"
    curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_mining","params":[],"id":1}' http://localhost:8545
    echo "Dev account balance:"
    curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_getBalance","params":["'$DEV_ACCOUNT'", "latest"],"id":1}' http://localhost:8545
else
    echo "Failed to verify devnet status"
    exit 1
fi