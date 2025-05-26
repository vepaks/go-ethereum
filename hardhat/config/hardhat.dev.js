require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config({ path: process.env.ENV_FILE || '.env' });

/**
 * Development environment configuration for Hardhat
 * This config is optimized for local development and testing
 */
module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    hardhat: {
      chainId: 31337,
      gas: "auto",
      gasPrice: "auto",
      mining: {
        auto: true,
        interval: 0
      }
    },
    localhost: {
      url: process.env.HARDHAT_NETWORK_URL || "http://127.0.0.1:8545",
      chainId: 1337,
      // Default test account with known private key for development only
      accounts: [
        process.env.TEST_PRIVATE_KEY || "0x4f3edf983ac636a65a842ce7c78d9aa706d3b113b37c6d8a8c7e3b8b8b8b8b8b"
      ],
      timeout: 30000
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 40000
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD"
  },
  etherscan: {
    // Skip API key for local development
    apiKey: process.env.ETHERSCAN_API_KEY || ""
  }
};