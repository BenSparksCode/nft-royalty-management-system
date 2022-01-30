// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import '@openzeppelin/contracts/access/Ownable.sol';

import './interfaces/IRoyaltyManager.sol';

// TODO note: need to deploy a RoyaltyManager contract per NFT contract
// Could extend to single manager for multiple NFT contracts in future
contract RoyaltyManager is IRoyaltyManager, Ownable {
	// -------------------------------------
	// STORAGE
	// -------------------------------------

	uint256 public constant SCALE = 1e18;

	// TODO Start with global royalty, do individual control after
	uint256 public royaltyFraction;

	address public secondaryRoyaltyRecipient; // common

	address public immutable whitelistedNFT; // only contract that can create new RoyaltyCollectors

	// NFT ID => Royalty config for that NFT ID
	mapping(uint256 => RoyaltyConfig) public nftRoyaltyConfigs;
	address[] public royaltyCollectorContracts;

	struct RoyaltyConfig {
		uint256 royaltyFraction; // numerator over SCALE (1e18)
		address royaltyCollector;
		address artist;
	}

	// -------------------------------------
	// EVENTS
	// -------------------------------------

	event RoyaltyCollectorCreated(uint256 nftID, address royaltyCollector);

	// -------------------------------------
	// CONSTRUCTOR
	// -------------------------------------

	constructor(address _NFT) {
		// Only this NFT can create new Royalty Collectors
		whitelistedNFT = _NFT;
	}

	// -------------------------------------
	// PUBLIC STATE-MODIFYING FUNCTIONS
	// -------------------------------------

	function registerTokenForRoyalties(uint256 _tokenID) public returns (address royaltyCollector) {
		// TODO
		require(msg.sender == whitelistedNFT, 'RMS: NO TOKEN REGISTRATION AUTH');
		require(nftRoyaltyConfigs[_tokenID].royaltyCollector == address(0), 'RMS: TOKEN ID ALREADY REGISTERED');

		royaltyCollector = _createNewRoyaltyCollector(_tokenID);
	}

	// -------------------------------------
	// INTERNAL STATE-MODIFYING FUNCTIONS
	// -------------------------------------

	function _createNewRoyaltyCollector(uint256 _tokenID) internal returns (address royaltyCollector) {
		// TODO

		// TODO Use Squeeth increment code in creation here

		address newRoyaltyCollector = address(0); //TODO complete

		emit RoyaltyCollectorCreated(_tokenID, newRoyaltyCollector);
	}

	// -------------------------------------
	// VIEW FUNCTIONS
	// -------------------------------------

	// Called from NFT to retrieve latest royalty data
	function royaltyInfo(uint256 _tokenID, uint256 _salePrice)
		public
		view
		returns (address receiver, uint256 royaltyAmount)
	{
		RoyaltyConfig memory _royaltyConfig = nftRoyaltyConfigs[_tokenID];
		receiver = _royaltyConfig.royaltyCollector;
		royaltyAmount = (_salePrice * _royaltyConfig.royaltyFraction) / SCALE;
	}

	function royaltyConfig(uint256 _tokenID)
		public
		returns (
			uint256 royaltyFraction,
			address royaltyCollector,
			address artist
		)
	{
		RoyaltyConfig memory _royaltyConfig = nftRoyaltyConfigs[_tokenID];
		royaltyFraction = _royaltyConfig.royaltyFraction;
		royaltyCollector = _royaltyConfig.royaltyCollector;
		artist = _royaltyConfig.artist;
	}

	function allRoyalties(address _royaltyToken) public view returns (uint256, uint256) {
		// Use address(0) for ETH royalties
		// TODO loop through array of RoyaltyCollectors and sum up all royalties
	}
}
