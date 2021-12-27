const FibboToken = artifacts.require("FibboToken");

module.exports = function (deployer) {
  deployer.deploy(FibboToken, "0x1a84F1f9CE6f4bF0FD2b1B4689Db53776e64bF1c");
};