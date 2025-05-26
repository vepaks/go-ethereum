require("@nomicfoundation/hardhat-toolbox");

// Try to load dotenv if available
try {
  require('dotenv').config({ path: process.env.ENV_FILE || '.env' });
} catch (error) {
  console.log('dotenv module not found, using process.env only');
  // Continue without dotenv
}

/**
 * Simplified Hardhat Configuration
 * This config selects the appropriate environment configuration based on NODE_ENV
 */

// Determine which environment to use
const environment = process.env.NODE_ENV || 'development';

let configFile;
switch (environment) {
  case 'production':
  case 'prod':
    console.log('Using production configuration');
    configFile = './config/hardhat.prod.js';
    break;
  case 'staging':
  case 'stage':
    console.log('Using staging configuration');
    configFile = './config/hardhat.stage.js';
    break;
  case 'development':
  case 'dev':
  default:
    console.log('Using development configuration');
    configFile = './config/hardhat.dev.js';
    break;
}

// Load the appropriate configuration
const config = require(configFile);

// Export the loaded configuration
module.exports = config;