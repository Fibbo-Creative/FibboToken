const FibboDao = artifacts.require("FibboDao");
const FibboToken = artifacts.require("FibboToken");

module.exports = async function (deployer) {
  await deployer.deploy(FibboDao, "0x1a84F1f9CE6f4bF0FD2b1B4689Db53776e64bF1c", "1000000000000000000000000") // TODO: Cambiar wallet del equipo y tokens mínimos.
  const fibboDao = await FibboDao.deployed()

  await deployer.deploy(FibboToken, "0x1a84F1f9CE6f4bF0FD2b1B4689Db53776e64bF1c", fibboDao.address) //TODO: Cambiar wallet del equipo.
  const fibboToken = await FibboToken.deployed()

  await fibboDao.setToken(fibboToken.address)
};