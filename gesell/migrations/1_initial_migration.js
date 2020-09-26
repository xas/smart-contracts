const Dai = artifacts.require("Dai");
const Gesell = artifacts.require("Gesell");

module.exports = function (deployer) {
  deployer.deploy(Dai).then(function (instanceDai){
    return deployer.deploy(Gesell, instanceDai.address);
  });
};
