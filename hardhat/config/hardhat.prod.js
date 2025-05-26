require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config({ path: process.env.ENV_FILE || '.env.prod' });

/**
 * Production environment configuration for Hardhat
 * This config is optimized for production deployments with
 * strict security and optimization settings
 */
module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 2000
      },
      viaIR: true,
      evmVersion: "paris"
    }
  },
  networks: {
    hardhat: {
      chainId: 31337,
      forking: {
        url: process.env.MAINNET_RPC_URL || "",
        enabled: !!process.env.MAINNET_RPC_URL
      }
    },
    localhost: {
      url: process.env.HARDHAT_NETWORK_URL || "http://127.0.0.1:8545",
      timeout: 120000
    },
    mainnet: {
      url: process.env.MAINNET_RPC_URL || "",
      chainId: 1,
      accounts: process.env.PROD_PRIVATE_KEY ? [process.env.PROD_PRIVATE_KEY] : [],
      gasPrice: parseInt(process.env.GAS_PRICE) || "auto",
      gasMultiplier: 1.1,
      timeout: 120000,
      verify: {
        etherscan: {
          apiKey: process.env.ETHERSCAN_API_KEY || ""
        }
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache-prod",
    artifacts: "./artifacts-prod"
  },
  mocha: {
    timeout: 120000
  },
  gasReporter: {
    enabled: true,
    currency: "USD",
    outputFile: "gas-report-prod.txt",
    noColors: true
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY || ""
  },
  // Strict security checks for production
  typechain: {
    outDir: "typechain",
    target: "ethers-v6"
  },
  // Avoid excessive console output in production
  logger: {
    timestamp: true
  }
};