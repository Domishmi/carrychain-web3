require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.20",

  networks: {
    hardhat: {},

    arcTestnet: {
      url: process.env.ARC_RPC_URL || "",
      chainId: 5042002,
      accounts: process.env.PRIVATE_KEY
        ? [process.env.PRIVATE_KEY]
        : []
    }
  }
};
