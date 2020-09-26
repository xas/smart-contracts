module.exports = {
  networks: {
    development: {
     host: "127.0.0.1",     // Localhost (default: none)
     port: 7545,            // Standard Ethereum port (default: none)
     network_id: "5777",       // Any network (default: none)
    },
  },

  mocha: {
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.7.1",    // Fetch exact version from solc-bin (default: truffle's version)
    },
  },
};
