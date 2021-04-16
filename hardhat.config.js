/**
 * @type import('hardhat/config').HardhatUserConfig
 */

require("dotenv").config();
require("@nomiclabs/hardhat-web3");
require("@nomiclabs/hardhat-truffle5");

module.exports = {
  networks: {
    hardhat: {
      forking: {
        url: "https://rpc-mainnet.maticvigil.com/",
        blockNumber: 12e6,
      },
    },
    testnet: {
      url: "https://rpc-mumbai.maticvigil.com/",
      accounts: [process.env.TESTNET_PRIVATE_KEY],
    },
    mainnet: {
      url: "https://rpc-mainnet.maticvigil.com/",
      accounts: [process.env.MAINNET_PRIVATE_KEY],
    },
  },
  solidity: {
    version: "0.8.1",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  mocha: {
    timeout: 240000,
  },
};
