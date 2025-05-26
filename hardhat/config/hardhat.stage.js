require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config({ path: process.env.ENV_FILE || '.env' });

/**
 * Staging environment configuration for Hardhat
 * This config is optimized for testing in staging environments
 * with more robust settings than development but less strict than production
 */
module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000
      }
    }
  },
  networks: {
    hardhat: {
      chainId: 31337
    },
    localhost: {
      url: process.env.HARDHAT_NETWORK_URL || "http://127.0.0.1:8545",
      chainId: 1337,
      accounts: process.env.TEST_MNEMONIC 
        ? { mnemonic: process.env.TEST_MNEMONIC }
        : [process.env.TEST_PRIVATE_KEY || "0x4f3edf983ac636a65a842ce7c78d9aa706d3b113b37c6d8a8c7e3b8b8b8b8b8b"],
      timeout: 60000,
      gasMultiplier: 1.2
    },
    stage: {
      url: process.env.STAGE_NETWORK_URL || "http://127.0.0.1:8545",
      chainId: process.env.STAGE_CHAIN_ID ? parseInt(process.env.STAGE_CHAIN_ID) : 1337,
      accounts: process.env.TEST_MNEMONIC 
        ? { mnemonic: process.env.TEST_MNEMONIC }
        : [process.env.TEST_PRIVATE_KEY || "0x4f3edf983ac636a65a842ce7c78d9aa706d3b113b37c6d8a8c7e3b8b8b8b8b8b"],
      timeout: 60000,
      gasMultiplier: 1.2
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 60000
  },
  gasReporter: {
    enabled: true,
    currency: "USD",
    outputFile: "gas-report.txt",
    noColors: true
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY || ""
  }
};