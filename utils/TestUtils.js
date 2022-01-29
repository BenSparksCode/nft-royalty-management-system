const { ethers } = require("hardhat");
const { BigNumber } = require("@ethersproject/bignumber");
const { constants } = require("./TestConstants");

let donor1, donor1Address;
let project1Owner1, project1Owner1Address;
let grant1Admin1, grant1Admin1Address;
let owner, ownerAddress;

let CoreContract, CoreInstance;
const ERC20_ABI = require("../artifacts/@openzeppelin/contracts/token/ERC20/ERC20.sol/ERC20.json");

const DAI = new ethers.Contract(
  constants.POLYGON.DAI,
  ERC20_ABI.abi,
  ethers.provider
);

// Gets the time of the last block.
const currentTime = async () => {
  const { timestamp } = await ethers.provider.getBlock("latest");
  return timestamp;
};

// Increases the time in the EVM.
// seconds = number of seconds to increase the time by
const fastForward = async (seconds) => {
  await ethers.provider.send("evm_increaseTime", [seconds]);
  await ethers.provider.send("evm_mine", []);
};

const toJSNum = (bigNum) => {
  return parseInt(bigNum.toString());
};

const burnTokenBalance = async (signer, tokenContract) => {
  const addr = await signer.getAddress();
  const bal = await tokenContract.balanceOf(addr);
  tokenContract
    .connect(signer)
    .transfer("0x000000000000000000000000000000000000dEaD", bal);
};

const calcAdminFee = (totalDonations) => {
  return totalDonations
    .mul(constants.DEPLOY.fees.admin)
    .div(constants.DEPLOY.SCALE);
};

const addWhaleBalance = async (donor) => {
  await donor.sendTransaction({
    to: whaleAddress,
    value: ethers.utils.parseEther("1"),
  });
};

const sendDaiFromWhale = async (amount, whaleSigner, toSigner, coreAddress) => {
  await DAI.connect(whaleSigner).transfer(toSigner.address, amount);
  await DAI.connect(toSigner).approve(coreAddress, amount);
};

const calcAmountAfterFees = (amountBeforeFees) => {
  return amountBeforeFees.sub(
    amountBeforeFees
      .mul(
        BigNumber.from(
          constants.DEPLOY.fees.admin + constants.DEPLOY.fees.protocol
        )
      )
      .div(BigNumber.from(constants.DEPLOY.SCALE))
  );
};

const transferDAI = async (donorAddress, amount) => {
  await DAI.connect(daiWhale).transfer(donorAddress, amount);
};

const approveDAI = async (donor, coreAddress, amount) => {
  await DAI.connect(donor).approve(coreAddress, amount);
};

const createGrantTest = async (grantID, admins, startTime, endTime) => {
  const grant = {
    grantID: grantID,
    grantAdmins: admins,
    startTime: startTime,
    endTime: endTime,
    totalVotePoints: 0,
    totalDonations: 0,
    totalProtocolFees: 0,
    cancelled: false,
  };

  return grant;
};

const createGrantQuick = async (CoreInstance, owner) => {
  startTime = await currentTime();
  endTime = startTime + constants.TEST.oneMonth;

  [, , , , , , , , , , , , , , donor1, grant1Admin1, project1Owner1] =
    await ethers.getSigners();

  ownerAddress = await owner.getAddress();
  donor1Address = await donor1.getAddress();
  grant1Admin1Address = await grant1Admin1.getAddress();
  project1Owner1Address = await project1Owner1.getAddress();

  // create grant
  await CoreInstance.connect(owner).createGrant(
    [grant1Admin1Address],
    startTime,
    endTime
  );
  // create project
  await CoreInstance.connect(owner).createProject(constants.TEST.projectOne, [
    project1Owner1Address,
  ]);

  // Set fees
  await CoreInstance.connect(owner).setFees(
    constants.TEST.protocolFee,
    constants.TEST.adminFee
  );

  await CoreInstance.connect(owner).setProjectInGrant(1, 1, true);
  //set up donor
  await addWhaleBalance(donor1);
  await transferDAI(donor1Address, constants.TEST.oneDai.mul(200));
  await approveDAI(
    donor1,
    CoreInstance.address,
    constants.TEST.oneDai.mul(200)
  );
  // donate
  await CoreInstance.connect(donor1).donate(
    1,
    constants.TEST.oneDai.mul(150),
    donor1Address
  );

  await CoreInstance.connect(donor1).vote(1, 1, 10);

  return {
    donor: donor1,
    grantAdmin: grant1Admin1,
    projectOwner: project1Owner1,
  };
};

const payRewards = async (CoreInstance, owner, grantID) => {
  await CoreInstance.connect(owner).payGrantAdminFees(grantID);
  await CoreInstance.connect(owner).payDonationsToAllProjectsInGrant(grantID);
};

const feesEarnedOnDeposit = async (amount) => {
  return amount.mul(constants.DEPLOY.fees.protocol).div(constants.DEPLOY.SCALE);
};

module.exports = {
  DAI: DAI,
  currentTime: currentTime,
  fastForward: fastForward,
  burnTokenBalance: burnTokenBalance,
  addWhaleBalance: addWhaleBalance,
  transferDAI: transferDAI,
  sendDaiFromWhale: sendDaiFromWhale,
  approveDAI: approveDAI,
  createGrantTest: createGrantTest,
  calcAdminFee: calcAdminFee,
  createGrantQuick: createGrantQuick,
  payRewards: payRewards,
  calcAmountAfterFees: calcAmountAfterFees,
  feesEarnedOnDeposit: feesEarnedOnDeposit,
};
