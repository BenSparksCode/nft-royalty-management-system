const { expect } = require("chai");
const { ethers } = require("hardhat");
const hre = require("hardhat");
const { BigNumber, Signer } = require("ethers");
const { constants } = require("../utils/TestConstants");
const {} = require("../utils/TestUtils");

let owner, ownerAddress;
let NFT, RoyaltyManager;

describe("Scenario Tests", function () {
  beforeEach(async () => {
    [owner] = await ethers.getSigners();
    ownerAddress = await owner.getAddress();

    const nftFactory = await ethers.getContractFactory("NFT");
    NFT = await nftFactory.deploy("Test NFT", "TNFT", "hidden", "revealed");
  });

  it("Minting an NFT deploys a Collector", async () => {});

  it("ETH royalties work with 1 NFT and Collector", async () => {});

  it("Token royalties work with 1 NFT and Collector", async () => {});

  it("Mint 5 NFTs, ETH royalties for each, collected and paid out", async () => {});

  it("Mint 20 NFTs, Token royalties for each, collected and paid out", async () => {});
});
