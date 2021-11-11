require('babel-register');
require('babel-polyfill');  //this is done so that the truffle project uses the correct Javascript code from babel
require('dotenv').config(); //injects environment variables into truffle project
const HDWalletProvider = require('@truffle/hdwallet-provider');

const privateKeys = process.env.PRIVATE_KEYS || ""

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*" // match any network id
    },
    goerli: {
      provider: function() { // need to connect to kovan with an ethereum provider
        return new HDWalletProvider(
          //privateKey,
          privateKeys.split(","), // Private key
          `https://goerli.infura.io/v3/${process.env.INFURA_API_KEY}`, // URL to an ethereum node
          0,
          2
        )
      },
    
      gas: 5000000,
      gasPrice: 25000000000,
      network_id: 5
    },
    rinkeby: {
      provider: function() { // need to connect to kovan with an ethereum provider
        return new HDWalletProvider(
          //privateKey,
          privateKeys.split(","), // Private key
          `https://rinkeby.infura.io/v3/${process.env.INFURA_API_KEY}`, // URL to an ethereum node
          0,
          2
        )
      },
    
      gas: 5000000,
      gasPrice: 25000000000,
      network_id: 4,
      networkCheckTimeout: 999999,
    }
  },
  contracts_directory: './src/contracts/', //so whenever we create new smart contracts they go into this directory
  contracts_build_directory: './src/abis/', //done to have all source code in one directory
  compilers: {
    solc: {
      version: "0.6.0",
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
}