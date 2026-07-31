require("@nomicfoundation/hardhat-ethers");
require("dotenv").config();

const GIWA_SEPOLIA_RPC_URL = process.env.GIWA_SEPOLIA_RPC_URL || "https://sepolia-rpc.giwa.io";
const DEPLOYER_PRIVATE_KEY = process.env.DEPLOYER_PRIVATE_KEY || "";

module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    giwaSepolia: {
      url: GIWA_SEPOLIA_RPC_URL,
      chainId: 91342,
      accounts: DEPLOYER_PRIVATE_KEY ? [DEPLOYER_PRIVATE_KEY] : []
    }
  }
};
