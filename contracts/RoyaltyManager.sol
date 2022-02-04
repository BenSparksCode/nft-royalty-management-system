// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import '@openzeppelin/contracts/access/Ownable.sol';

import './RoyaltyCollector.sol';
import './interfaces/IRoyaltyManager.sol';

contract RoyaltyManager is IRoyaltyManager, Ownable {
	// -------------------------------------
	// STORAGE
	// -------------------------------------

	uint256 public constant SCALE = 1e18;

	// TODO Start with global royalty, do individual control after
	uint256 public defaultRoyaltyPercentageOfSale;
	uint256 public defaultRoyaltySplitForArtist;

	address public secondaryRoyaltyRecipient; // common recipient - i.e. protocol treasury

	address public immutable whitelistedNFT; // only contract that can create new RoyaltyCollectors

	// NFT ID => Royalty config for that NFT ID
	mapping(uint256 => RoyaltyConfig) public nftRoyaltyConfigs;
	address[] public royaltyCollectorContracts; //TODO get rid of array and use NFT ID to loop in mapping

	struct RoyaltyConfig {
		uint256 royaltyPercentageOfSale; // numerator over SCALE (1e18)
		uint256 royaltySplitForArtist;
		address royaltyCollector; // address of the Collector for specific NFT ID
		address artist; // artist = primary royalty recipient
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

	function registerTokenForRoyalties(uint256 _tokenID, address _artist) public returns (address royaltyCollector) {
		// TODO
		require(msg.sender == whitelistedNFT, 'RMS: NO TOKEN REGISTRATION AUTH');
		require(nftRoyaltyConfigs[_tokenID].royaltyCollector == address(0), 'RMS: TOKEN ID ALREADY REGISTERED');

		royaltyCollector = _createNewRoyaltyCollector(_tokenID, _artist);
	}

	// -------------------------------------
	// ONLY-OWNER FUNCTIONS
	// -------------------------------------

	function payRoyaltyByID(uint256 _tokenID) public onlyOwner {
		// TODO
	}

	function payAllRoyalties() public onlyOwner {
		// TODO
	}

	// Can only change royalty % and artist cut
	function setSpecificRoyaltyConfig(
		uint256 _tokenID,
		uint256 _newRoyaltyPercentageOfSale,
		uint256 _newRoyaltySplitForArtist
	) public onlyOwner {
		require(_newRoyaltyPercentageOfSale <= SCALE, 'RMS: INVALID ROYALTY PERCENTAGE');
		require(_newRoyaltySplitForArtist <= SCALE, 'RMS: INVALID ARTIST SPLIT');

		RoyaltyConfig memory _royaltyConfig = nftRoyaltyConfigs[_tokenID];

		require(_royaltyConfig.royaltyCollector != address(0), 'RMS: TOKEN ID NOT REGISTERED');

		_royaltyConfig.royaltyPercentageOfSale = _newRoyaltyPercentageOfSale;
		_royaltyConfig.royaltySplitForArtist = _newRoyaltySplitForArtist;

		nftRoyaltyConfigs[_tokenID] = _royaltyConfig;

		// TODO add event
	}

	function setDefaultRoyaltyPercentageOfSale(uint256 _newRoyaltyPercentageOfSale) public onlyOwner {
		require(_newRoyaltyPercentageOfSale <= SCALE, 'RMS: INVALID ROYALTY PERCENTAGE');
		defaultRoyaltyPercentageOfSale = _newRoyaltyPercentageOfSale;
		// TODO add event
	}

	function setDefaultRoyaltySplitForArtist(uint256 _newRoyaltySplitForArtist) public onlyOwner {
		require(_newRoyaltySplitForArtist <= SCALE, 'RMS: INVALID ARTIST SPLIT');
		defaultRoyaltySplitForArtist = _newRoyaltySplitForArtist;
		// TODO add event
	}

	function setSecondaryRoyaltyRecipient(address _newSecondaryRoyaltyRecipient) public onlyOwner {
		secondaryRoyaltyRecipient = _newSecondaryRoyaltyRecipient;
		// TODO add event
	}

	// -------------------------------------
	// INTERNAL STATE-MODIFYING FUNCTIONS
	// -------------------------------------

	function _createNewRoyaltyCollector(uint256 _tokenID, address _artist)
		internal
		returns (address royaltyCollectorAddr)
	{
		RoyaltyCollector _royaltyCollector = new RoyaltyCollector(_tokenID);
		royaltyCollectorAddr = address(_royaltyCollector);

		RoyaltyConfig memory _royaltyConfig = RoyaltyConfig(
			defaultRoyaltyPercentageOfSale,
			defaultRoyaltySplitForArtist,
			royaltyCollectorAddr,
			_artist
		);

		royaltyCollectorContracts.push(royaltyCollectorAddr); //TODO only use mapping

		emit RoyaltyCollectorCreated(_tokenID, royaltyCollectorAddr);
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
		royaltyAmount = (_salePrice * _royaltyConfig.royaltyPercentageOfSale) / SCALE;
	}

	function royaltyConfig(uint256 _tokenID)
		public
		returns (
			uint256 royaltyPercentageOfSale,
			uint256 royaltySplitForArtist,
			address royaltyCollector,
			address artist
		)
	{
		RoyaltyConfig memory _royaltyConfig = nftRoyaltyConfigs[_tokenID];
		royaltyPercentageOfSale = _royaltyConfig.royaltyPercentageOfSale;
		royaltySplitForArtist = _royaltyConfig.royaltySplitForArtist;
		royaltyCollector = _royaltyConfig.royaltyCollector;
		artist = _royaltyConfig.artist;
	}

	function allRoyalties(address _royaltyToken) public view returns (uint256, uint256) {
		// Use address(0) for ETH royalties
		// TODO loop through array of RoyaltyCollectors and sum up all royalties
	}
}
