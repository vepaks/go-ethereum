require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  networks: {
    hardhat: {
      chainId: 31337
    },
    localhost: {
      url: "http://localhost:8545",
      chainId: 1337,
      accounts: {
        mnemonic: process.env.TEST_MNEMONIC || "test test test test test test test test test test test junk"
      }
    }
  }
};
