// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import './interfaces/IRoyaltyManager.sol';

contract RoyaltyCollector {
	// ------------------------------
	// STORAGE
	// ------------------------------

	address public immutable manager;
	uint256 public immutable nftID;

	// ------------------------------
	// CONSTRUCTOR
	// ------------------------------

	constructor(uint256 _nftID) {
		manager = msg.sender;
		nftID = _nftID;
	}

	// ------------------------------
	// STATE-MODIFYING FUNCTIONS
	// ------------------------------

	function payRoyaltiesETH() public {
		// TODO
	}

	function payRoyalties(address _token) public {
		// Use _token = address(0) for ETH royalties
		// TODO
	}

	// ------------------------------
	// VIEW FUNCTIONS
	// ------------------------------

	function royaltiesAvailable(address _token) public view returns (uint256, uint256) {
		// Use _token = address(0) for ETH royalties
		// TODO returns royalties for artist, system
	}

	// ------------------------------
	// MODIFIERS
	// ------------------------------

	modifier onlyRoyaltyManager() {
		require(msg.sender == manager, 'RMS: NOT ROYALTY MANAGER');
		_;
	}
}
