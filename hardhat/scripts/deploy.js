// scripts/deploy.js
// Script to deploy contracts to the local Ethereum network

async function main() {
  try {
    // Get the contract factory
    const Token = await ethers.getContractFactory("Token");
    console.log("Deploying Token contract...");
    
    // Deploy the contract
    const token = await Token.deploy();
    
    // Wait for deployment to finish
    await token.deployed();
    
    console.log(`Token contract deployed to: ${token.address}`);
    
    // Get deployer address
    const [deployer] = await ethers.getSigners();
    console.log(`Deployed by: ${deployer.address}`);
    
    // Log initial token balance
    const balance = await token.balanceOf(deployer.address);
    console.log(`Initial supply: ${balance.toString()} tokens`);
    
    return { token };
  } catch (error) {
    console.error("Error in deployment:", error);
    throw error;
  }
}

// Execute deployment
if (require.main === module) {
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
}

module.exports = main;