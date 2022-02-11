pragma solidity 0.8.11;

import "@rari-capital/solmate/src/tokens/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

import "./interfaces/IRoyaltyManager.sol";

// TODO natspec for everything
contract NFT1155 is ERC1155, IERC2981, Ownable {
    // -------------------------------------
    // STORAGE
    // -------------------------------------

    uint256 public count = 1;
    address public royaltyManager;

    // TODO change URI to standard system
    mapping(uint256 => string) private uris; // custom URI per NFT

    // -------------------------------------
    // EVENTS
    // -------------------------------------

    event RoyaltyManagerUpdated(
        address indexed oldRoyaltyManager,
        address indexed newRoyaltyManager
    );

    // -------------------------------------
    // CONSTRUCTOR
    // -------------------------------------

    constructor() {}

    // -------------------------------------
    // PUBLIC STATE-MODIFYING FUNCTIONS
    // -------------------------------------

    // TODO change NFT to be standard 1155 - can adapt to usecase later
    function mint(
        address to,
        uint256 amount,
        string memory uri,
        address artist
    ) external returns (uint256 tokenID) {
        tokenID = count++;
        uris[tokenID] = uri;
        _mint(to, tokenID, amount, "");
        IRoyaltyManager(royaltyManager).registerTokenForRoyalties(
            tokenID,
            artist
        );
    }

    // -------------------------------------
    // ONLY-OWNER FUNCTIONS
    // -------------------------------------

    function setRoyaltyManager(address _royaltyManager) public onlyOwner {
        address _oldManager = royaltyManager;
        royaltyManager = _royaltyManager;

        emit RoyaltyManagerUpdated(_oldManager, _royaltyManager);
    }

    // -------------------------------------
    // VIEW AND PURE FUNCTIONS
    // -------------------------------------

    function uri(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        return uris[_tokenId];
    }

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        public
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        (receiver, royaltyAmount) = IRoyaltyManager(royaltyManager).royaltyInfo(
            tokenId,
            salePrice
        );
    }

    function supportsInterface(bytes4 interfaceId)
        public
        pure
        override(ERC1155, IERC165)
        returns (bool)
    {
        return
            ERC1155.supportsInterface(interfaceId) ||
            interfaceId == type(IERC2981).interfaceId;
    }
}
