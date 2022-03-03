const FibboDao = artifacts.require("FibboDao");
const Vesting = artifacts.require("Vesting");
const FriendsPresale = artifacts.require("FriendsPresale");
const FirstPresale = artifacts.require("FirstPresale");
const SecondPresale = artifacts.require("SecondPresale");
const FibboToken = artifacts.require("FibboToken");

module.exports = async function (deployer) {
  await deployer.deploy(FibboDao, "0xa44bA3EFB35e04D6120890D7ce6d375031F1Df6D", "1000000000000000000000000") // TODO: Cambiar wallet del equipo y tokens mínimos.
  const fibboDao = await FibboDao.deployed()

  await deployer.deploy(Vesting, "0xa44bA3EFB35e04D6120890D7ce6d375031F1Df6D", "0x70eFD7a1768FB4F2Cbefc0034fF1a74050697600") // TODO: Cambiar wallet del equipo y tokens mínimos.
  const vesting = await Vesting.deployed()

  await deployer.deploy(FriendsPresale, "0xa44bA3EFB35e04D6120890D7ce6d375031F1Df6D") // TODO: Cambiar wallet del equipo.
  const friendsPresale = await FriendsPresale.deployed()

  await deployer.deploy(FirstPresale, "0xa44bA3EFB35e04D6120890D7ce6d375031F1Df6D") // TODO: Cambiar wallet del equipo.
  const firstPresale = await FirstPresale.deployed()

  await deployer.deploy(SecondPresale, "0xa44bA3EFB35e04D6120890D7ce6d375031F1Df6D") // TODO: Cambiar wallet del equipo.
  const secondPresale = await SecondPresale.deployed()

  await deployer.deploy(FibboToken, "0xa44bA3EFB35e04D6120890D7ce6d375031F1Df6D", "0xa44bA3EFB35e04D6120890D7ce6d375031F1Df6D", "0xa44bA3EFB35e04D6120890D7ce6d375031F1Df6D", "0xa44bA3EFB35e04D6120890D7ce6d375031F1Df6D", fibboDao.address, friendsPresale.address, firstPresale.address, secondPresale.address) //TODO: Cambiar wallet de fundadores, equipo, devs y marketing.
  const fibboToken = await FibboToken.deployed()

  await fibboDao.setToken(fibboToken.address)
  await friendsPresale.setToken(fibboToken.address)
  await firstPresale.setToken(fibboToken.address)
  await secondPresale.setToken(fibboToken.address) 
};