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
		uint256 royaltyFraction; // numerator over SCALE (1e18)
		address royaltyCollector;
		address artist;
	}

	// -------------------------------------
	// EVENTS
	// -------------------------------------

	event RoyaltyCollectorCreated(uint256 nftID, string nftURI, address royaltyCollector);

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

	// -------------------------------------
	// VIEW FUNCTIONS
	// -------------------------------------

	// Called from NFT to retrieve latest royalty data
	function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
		public
		view
		returns (address receiver, uint256 royaltyAmount)
	{
		RoyaltyConfig memory _royaltyConfig = nftRoyaltyConfigs[_tokenId];
		receiver = _royaltyConfig.royaltyCollector;
		royaltyAmount = (_salePrice * _royaltyConfig.royaltyFraction) / SCALE;
	}

	function royaltyConfig(uint256 _ID)
		public
		returns (
			uint256 royaltyFraction,
			address royaltyCollector,
			address artist
		)
	{
		RoyaltyConfig memory _royaltyConfig = nftRoyaltyConfigs[_ID];
		royaltyFraction = _royaltyConfig.royaltyFraction;
		royaltyCollector = _royaltyConfig.royaltyCollector;
		artist = _royaltyConfig.artist;
	}

	function allRoyalties(address _token) public view returns (uint256, uint256) {
		// TODO loop through array of RoyaltyCollectors and sum up all royalties
	}
}
