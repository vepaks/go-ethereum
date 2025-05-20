require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  networks: {
    hardhat: {
      chainId: 31337
    },
    localhost: {
      url: "http://127.0.0.1:8545",
      chainId: 1337,
      accounts: [
        "0x4f3edf983ac636a65a842ce7c78d9aa706d3b113b37c6d8a8c7e3b8b8b8b8b8b"
      ]
    }
  }
};
