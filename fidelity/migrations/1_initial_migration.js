const Dai = artifacts.require("Dai");
const Fidelity = artifacts.require("Fidelity");

module.exports = function (deployer) {
  deployer.deploy(Dai).then(function (instanceDai){
    return deployer.deploy(Fidelity, instanceDai.address);
  });
};
