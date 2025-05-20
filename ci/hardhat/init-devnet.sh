#!/bin/bash

# Start geth in dev mode with the configured options
# This will start a local Ethereum development network
echo "Starting geth in dev mode..."
geth $GETH_OPTS &

# Wait for geth to start and initialize
# This ensures the network is ready before we deploy contracts
echo "Waiting for geth to initialize..."
sleep 5

# Deploy the contracts using Hardhat
# This will deploy all contracts to the local network
echo "Deploying contracts..."
cd /app
npx hardhat run scripts/deploy.js --network localhost

# Save the blockchain state
# This ensures the deployed contracts are preserved
echo "Saving blockchain state..."
geth --exec "miner.stop()" attach http://localhost:8545

# Wait for the state to be saved
sleep 2

# Restart mining to continue block production
echo "Restarting mining..."
geth --exec "miner.start()" attach http://localhost:8545

echo "Devnet is ready with deployed contracts!"
echo "RPC endpoint: http://localhost:8545"
echo "WebSocket endpoint: ws://localhost:8546"