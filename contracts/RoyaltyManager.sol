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

	uint256 public defaultRoyaltyPercentageOfSale;
	uint256 public defaultRoyaltySplitForArtist;

	uint256 public lastTokenIDRegistered; // acts as counter for looping

	address public secondaryRoyaltyRecipient; // common recipient - i.e. protocol treasury

	address public immutable whitelistedNFT; // only contract that can create new RoyaltyCollectors

	// NFT ID => Royalty config for that NFT ID
	// Use lastTokenIDRegistered as max index, for looping
	mapping(uint256 => RoyaltyConfig) public nftRoyaltyConfigs;

	// -------------------------------------
	// EVENTS
	// -------------------------------------

	event RoyaltyCollectorCreated(uint256 nftID, address royaltyCollector);
	event SingleTokenRoyaltyPaid();
	event AllRoyaltiesPaid();
	event SpecificRoyaltyConfigSet();
	event DefaultRoyaltyPercentageOfSaleSet();
	event DefaultRoyaltySplitForArtistSet();
	event SecondaryRoyaltyRecipientSet();

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
		require(msg.sender == whitelistedNFT, 'RMS: NO TOKEN REGISTRATION AUTH');
		require(nftRoyaltyConfigs[_tokenID].royaltyCollector == address(0), 'RMS: TOKEN ID ALREADY REGISTERED');

		lastTokenIDRegistered = _tokenID;
		royaltyCollector = _createNewRoyaltyCollector(_tokenID, _artist);
		// event emitted in internal function
	}

	// -------------------------------------
	// ONLY-OWNER FUNCTIONS
	// -------------------------------------

	function payRoyaltyByID(uint256 _tokenID) public onlyOwner {
		// TODO

		RoyaltyConfig memory _royaltyConfig = nftRoyaltyConfigs[_tokenID];
		require(_royaltyConfig.royaltyCollector != address(0), 'RMS: TOKEN ID NOT REGISTERED');

		// TODO event
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

		nftRoyaltyConfigs[_tokenID] = _royaltyConfig;

		emit RoyaltyCollectorCreated(_tokenID, royaltyCollectorAddr);
	}

	function _payRoyalty() internal {}

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
