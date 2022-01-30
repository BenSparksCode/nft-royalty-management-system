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

	event RoyaltyCollectorCreated(uint256 nftID, string nftURI, address royaltyCollector);

	// -------------------------------------
	// CONSTRUCTOR
	// -------------------------------------

	constructor(address _NFT) {
		// Only this NFT can create new Royalty Collectors
		whitelistedNFT = _NFT;
	}

	// -------------------------------------
	// STATE-MODIFYING FUNCTIONS
	// -------------------------------------

	function registerTokenForRoyalties(uint256 _tokenID) public {
		// TODO
		require(msg.sender == whitelistedNFT, 'RMS: NO TKOEN REGISTRATION AUTH');
	}

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
