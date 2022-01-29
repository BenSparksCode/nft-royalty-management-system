// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import '@openzeppelin/contracts/access/Ownable.sol';

contract RoyaltyManager is Ownable {
	// ------------------------------
	// STORAGE
	// ------------------------------

	uint256 public constant SCALE = 1e18;

	// TODO Start with global royalty, do individual control after
	uint256 public royaltyFraction;

	address public secondaryRoyaltyRecipient; // common

	// NFT ID => address of specific royalty collector contract
	mapping(uint256 => address) public nftRoyaltyCollectors;
	address[] public royaltyCollectors;

	// ------------------------------
	// CONSTRUCTOR
	// ------------------------------

	constructor() {}

	// ------------------------------
	// STATE-MODIFYING FUNCTIONS
	// ------------------------------

	function createRoyaltyCollector(uint256 _ID, string memory _uri) public returns (address) {
		// TODO

		address newRoyaltyCollector = address(0); //TODO complete

		emit RoyaltyCollectorCreated(_ID, _uri, newRoyaltyCollector);
	}

	// ------------------------------
	// VIEW FUNCTIONS
	// ------------------------------

	function allRoyalties(address _token) public view returns (uint256, uint256) {
		// TODO loop through array of RoyaltyCollectors and sum up all royalties
	}
}
