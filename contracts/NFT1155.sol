pragma solidity 0.8.11;

import '@rari-capital/solmate/src/tokens/ERC1155.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/common/ERC2981.sol';

// TODO natspec for everything
contract NFT1155 is ERC1155, ERC2981 {
	uint256 public count = 1;

	// TODO change URI to standard system
	mapping(uint256 => string) private uris; // custom URI per NFT

	constructor() {}

	function mint(
		address to,
		uint256 amount,
		string memory uri
	) external returns (uint256 tokenId) {
		uris[tokenId] = uri;
		// Increment method based on Opyn's Squeeth ShortPowerPerp code
		_mint(to, tokenId = count++, amount, '');
	}

	function uri(uint256 _tokenId) public view override returns (string memory) {
		return uris[_tokenId];
	}

	function supportsInterface(bytes4 interfaceId) public pure override(ERC1155, ERC2981) returns (bool) {
		return ERC1155.supportsInterface(interfaceId) || interfaceId == type(IERC2981).interfaceId;
	}
}
