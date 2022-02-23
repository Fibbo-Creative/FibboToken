const FibboDao = artifacts.require("FibboDao");
const FriendsPresale = artifacts.require("FriendsPresale");
const FirstPresale = artifacts.require("FirstPresale");
const SecondPresale = artifacts.require("SecondPresale");
const FibboToken = artifacts.require("FibboToken");

module.exports = async function (deployer) {
  await deployer.deploy(FibboDao, "0x1a84F1f9CE6f4bF0FD2b1B4689Db53776e64bF1c", "1000000000000000000000000") // TODO: Cambiar wallet del equipo y tokens mínimos.
  const fibboDao = await FibboDao.deployed()

  await deployer.deploy(FriendsPresale, "0x1a84F1f9CE6f4bF0FD2b1B4689Db53776e64bF1c") // TODO: Cambiar wallet del equipo.
  const friendsPresale = await FriendsPresale.deployed()

  await deployer.deploy(FirstPresale, "0x1a84F1f9CE6f4bF0FD2b1B4689Db53776e64bF1c") // TODO: Cambiar wallet del equipo.
  const firstPresale = await FirstPresale.deployed()

  await deployer.deploy(SecondPresale, "0x1a84F1f9CE6f4bF0FD2b1B4689Db53776e64bF1c") // TODO: Cambiar wallet del equipo.
  const secondPresale = await SecondPresale.deployed()

  await deployer.deploy(FibboToken, "0x1a84F1f9CE6f4bF0FD2b1B4689Db53776e64bF1c", "0x1a84F1f9CE6f4bF0FD2b1B4689Db53776e64bF1c", "0x1a84F1f9CE6f4bF0FD2b1B4689Db53776e64bF1c", "0x1a84F1f9CE6f4bF0FD2b1B4689Db53776e64bF1c", fibboDao.address, friendsPresale.address, firstPresale.address, secondPresale.address) //TODO: Cambiar wallet de fundadores, equipo, devs y marketing.
  const fibboToken = await FibboToken.deployed()

  await fibboDao.setToken(fibboToken.address)
  await friendsPresale.setToken(fibboToken.address)
  await firstPresale.setToken(fibboToken.address)
  await secondPresale.setToken(fibboToken.address) 
};