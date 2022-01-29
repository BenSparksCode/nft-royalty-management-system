const hre = require("hardhat");
const { ethers } = require("hardhat");
require("@nomiclabs/hardhat-etherscan");
const chalk = require("chalk");
const fs = require("fs");
const ProgressBar = require("progress");

const { constants } = require("../utils/TestConstants");

const gasLimit = 10000000; // 10 million
const gasPrice = 2000000000; // 2 gwei

// For waiting to not spam public RPCs on deploy
const pause = (time) => new Promise((resolve) => setTimeout(resolve, time));
// If deploy network is here, will attempt to verify on Etherscan
const verifiableNetwork = [
  "mainnet",
  "ropsten",
  "rinkeby",
  "goerli",
  "kovan",
  "polygon",
  "mumbai",
];

const deploy = async (
  contractName,
  _args = [],
  overrides = {},
  libraries = {}
) => {
  console.log(`👀 Deploying: ${contractName}`);

  const contractArgs = _args || [];
  const stringifiedArgs = JSON.stringify(contractArgs);
  const contractArtifacts = await ethers.getContractFactory(contractName, {
    libraries: libraries,
  });
  const contract = await contractArtifacts.deploy(...contractArgs, overrides);
  const contractAddress = contract.address;
  fs.writeFileSync(`artifacts/${contractName}.address`, contractAddress);
  fs.writeFileSync(`artifacts/${contractName}.args`, stringifiedArgs);

  console.log(
    "Deploying",
    chalk.cyan(contractName),
    "contract to",
    chalk.magenta(contractAddress)
  );

  await contract.deployed();

  const deployed = {
    name: contractName,
    address: contractAddress,
    args: contractArgs,
    contract,
  };

  return deployed;
};

async function main() {
  const network =
    process.env.HARDHAT_NETWORK === undefined
      ? "localhost"
      : process.env.HARDHAT_NETWORK;

  console.log("🚀 Deploying to", chalk.magenta(network), "!");

  const [deployer] = await ethers.getSigners();

  console.log(
    chalk.cyan("Deploying contracts with the account:"),
    chalk.green(deployer.address)
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  // this array stores the data for contract verification
  let contracts = [];

  // some notes on the deploy function:
  //    - arguments should be passed in an array after the contract name
  //      args need to be formatted properly for verification to pass
  //      see: https://hardhat.org/plugins/nomiclabs-hardhat-etherscan.html#complex-arguments
  //      example: await deploy("Token", ["Test", "TST"]);
  //    - custom ethers parameters like gasLimit go in an object after that
  //      EVEN IF THERE ARE NO ARGS (put an empty array for the args)
  //      example: await deploy("Token", [], { gasLimit: 300000 });
  //    - libraries can be added by address after that
  //      example: await deploy("Token", [], {}, { "SafeMath": "0x..."});
  //    - function calls: use this format: `token.contact.mint()`

  // === CONTRACT DEPLOYMENT ===

  // TODO

  // === EXTRA SETUP TRANSACTIONS ===

  // TODO

  // === VERIFICATION ===
  if (verifiableNetwork.includes(network)) {
    console.log(
      "Beginning Etherscan verification process...\n",
      chalk.yellow(
        `WARNING: The process will wait two minutes for Etherscan \nto update their backend before commencing, please wait \nand do not stop the terminal process...`
      )
    );

    const bar = new ProgressBar("Etherscan update: [:bar] :percent :etas", {
      total: 50,
      complete: "\u2588",
      incomplete: "\u2591",
    });
    // 1 minute timeout to let Etherscan update
    const timer = setInterval(() => {
      bar.tick();
      if (bar.complete) {
        clearInterval(timer);
      }
    }, 2300);

    await pause(60000);

    console.log(chalk.cyan("\n🔍 Running Etherscan verification..."));

    await Promise.all(
      contracts.map(async (contract) => {
        console.log(`Verifying ${contract.name}...`);
        try {
          await hre.run("verify:verify", {
            address: contract.address,
            constructorArguments: contract.args,
          });
          console.log(chalk.cyan(`✅ ${contract.name} verified!`));
        } catch (error) {
          console.log(error);
        }
      })
    );
  }

  console.log("✅✅ Deployment script completed! ✅✅");

  tableContracts = contracts.map((c) => ({
    name: c.name,
    address: c.address,
  }));

  console.table(tableContracts);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
