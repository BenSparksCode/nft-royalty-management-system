// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import './interfaces/IRoyaltyManager.sol';

contract RoyaltyCollector {
	// -------------------------------------
	// STORAGE
	// -------------------------------------

	address public immutable manager;
	uint256 public immutable nftID;

	uint256 public constant SCALE = 1e18;

	// -------------------------------------
	// CONSTRUCTOR
	// -------------------------------------

	constructor(uint256 _nftID) {
		manager = msg.sender;
		nftID = _nftID;
	}

	// -------------------------------------
	// PUBLIC STATE-MODIFYING FUNCTIONS
	// -------------------------------------

	function payRoyalty(address _token) public {
		// Use _token = address(0) for ETH royalties
		// TODO

		if (_token == address(0)) {
			// ETH royalties
			// TODO
		} else {
			// ERC20 royalties
			// TODO
		}

		// TODO event
	}

	// -------------------------------------
	// INTERNAL STATE-MODIFYING FUNCTIONS
	// -------------------------------------

	function _calcRoyaltySplit(uint256 _totalRoyalty) internal returns (uint256, uint256) {
		// Pull data from manager
		RoyaltyConfig memory _config = IRoyaltyManager(manager).nftRoyaltyConfigs(nftID);

		uint256 _artistRoyalty = (_totalRoyalty * royaltySplitForArtist) / SCALE;
		uint256 _secondaryRoyalty = (_totalRoyalty * (SCALE - royaltySplitForArtist)) / SCALE;

		return (_artistRoyalty, _secondaryRoyalty);
	}

	// -------------------------------------
	// VIEW FUNCTIONS
	// -------------------------------------

	function royaltiesAvailable(address _token) public view returns (uint256, uint256) {
		// Use _token = address(0) for ETH royalties
		// TODO returns royalties for artist, system
	}

	// -------------------------------------
	// MODIFIERS
	// -------------------------------------

	modifier onlyRoyaltyManager() {
		require(msg.sender == manager, 'RMS: NOT ROYALTY MANAGER');
		_;
	}
}
