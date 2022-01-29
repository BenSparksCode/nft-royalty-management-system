// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import '@openzeppelin/contracts/access/Ownable.sol';

contract RoyaltyManager is Ownable {
	// -------------------------------------
	// STORAGE
	// -------------------------------------

	uint256 public constant SCALE = 1e18;
	uint256 public nftCollectorCount = 1;

	// TODO Start with global royalty, do individual control after
	uint256 public royaltyFraction;

	address public secondaryRoyaltyRecipient; // common

	// NFT ID => Royalty config for that NFT
	mapping(uint256 => RoyaltyConfig) public nftRoyaltyConfigs;
	address[] public royaltyCollectorContracts;

	struct RoyaltyConfig {
		uint256 royaltyFraction;
		address royaltyCollector;
		address artist;
	}

	// -------------------------------------
	// EVENTS
	// -------------------------------------

	event RoyaltyCollectorCreated();

	// -------------------------------------
	// CONSTRUCTOR
	// -------------------------------------

	constructor() {}

	// -------------------------------------
	// STATE-MODIFYING FUNCTIONS
	// -------------------------------------

	function createRoyaltyCollector(uint256 _ID, string memory _uri) public returns (address) {
		// TODO

		// TODO Use Squeeth increment code in creation here

		address newRoyaltyCollector = address(0); //TODO complete

		emit RoyaltyCollectorCreated(_ID, _uri, newRoyaltyCollector);
	}

	function checkVRFSetup(uint256 _nftID) {
		// TODO ??

		emit RoyaltyCollectorCreated(_nftID, _uri, newRoyaltyCollector);
	}

	// -------------------------------------
	// VIEW FUNCTIONS
	// -------------------------------------

	function royaltyConfig(uint256 _ID) public returns (RoyaltyConfig) {
		return nftRoyaltyConfigs[_ID];
	}

	function allRoyalties(address _token) public view returns (uint256, uint256) {
		// TODO loop through array of RoyaltyCollectors and sum up all royalties
	}
}
