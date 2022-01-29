pragma solidity 0.8.11;

import '@rari-capital/solmate/src/tokens/ERC1155.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/common/ERC2981.sol';

// TODO natspec for everything
contract NFT1155 is ERC1155, ERC2981, Ownable {
	uint256 public count = 1;
	address public royaltyManager;

	// TODO change URI to standard system
	mapping(uint256 => string) private uris; // custom URI per NFT

	event RoyaltyManagerUpdated(address indexed oldRoyaltyManager, address indexed newRoyaltyManager);

	constructor() {}

	function mint(
		address to,
		uint256 amount,
		string memory uri
	) external returns (uint256 tokenId) {
		uint256 _tokenID = count++;
		uris[_tokenID] = uri;
		_mint(to, _tokenID, amount, '');
	}

	function setRoyaltyManager(address _royaltyManager) public onlyOwner {
		address _oldManager = royaltyManager;
		royaltyManager = _royaltyManager;

		emit RoyaltyManagerUpdated(_oldManager, _royaltyManager);
	}

	function uri(uint256 _tokenId) public view override returns (string memory) {
		return uris[_tokenId];
	}

	function supportsInterface(bytes4 interfaceId) public pure override(ERC1155, ERC2981) returns (bool) {
		return ERC1155.supportsInterface(interfaceId) || interfaceId == type(IERC2981).interfaceId;
	}

	function _registerTokenRoyalties(uint256 _nftID) internal {
		// TODO
	}
}
