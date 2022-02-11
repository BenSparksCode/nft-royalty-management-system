// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./interfaces/IRoyaltyManager.sol";
import "./interfaces/IRoyaltyCollector.sol";

contract RoyaltyCollector is IRoyaltyCollector {
    // -------------------------------------
    // STORAGE
    // -------------------------------------

    uint256 public constant SCALE = 1e18;

    address public immutable manager;
    uint256 public immutable nftID;

    // -------------------------------------
    // EVENTS
    // -------------------------------------

    event RoyaltyPaid(
        address indexed royaltyToken,
        address indexed artist,
        uint256 artistRoyalty,
        uint256 secondaryRoyalty
    );

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
        uint256 balance;
        if (_token == address(0)) {
            balance = address(this).balance;
        } else {
            balance = IERC20(_token).balanceOf(address(this));
        }

        require(balance > 0, "RMS: NO ROYALTIES TO PAY");

        // Royalty data will be set dependent on ETH/Token payment
        address secondaryRecipient = IRoyaltyManager(manager)
            .secondaryRoyaltyRecipient();

        (
            uint256 artistRoyalty,
            uint256 secondaryRoyalty,
            address artist
        ) = getRoyaltySplitData(balance);

        if (_token == address(0)) {
            // ETH royalties
            (bool artistSent, ) = artist.call{value: artistRoyalty}("");
            (bool secondarySent, ) = secondaryRecipient.call{
                value: secondaryRoyalty
            }("");

            require(artistSent && secondarySent, "RMS: ETH PAYMENT FAILED");
        } else {
            // ERC20 royalties
            bool artistSent = IERC20(_token).transfer(artist, artistRoyalty);
            bool secondarySent = IERC20(_token).transfer(
                secondaryRecipient,
                secondaryRoyalty
            );

            require(artistSent && secondarySent, "RMS: ERC20 PAYMENT FAILED");
        }

        emit RoyaltyPaid(_token, artist, artistRoyalty, secondaryRoyalty);
    }

    // -------------------------------------
    // VIEW FUNCTIONS
    // -------------------------------------

    function royaltiesAvailable(address _token)
        public
        view
        returns (uint256, uint256)
    {
        // Use _token = address(0) for ETH royalties
        uint256 balance;
        if (_token == address(0)) {
            balance = address(this).balance;
        } else {
            balance = IERC20(_token).balanceOf(address(this));
        }

        (
            uint256 artistRoyalty,
            uint256 secondaryRoyalty,

        ) = getRoyaltySplitData(balance);

        return (artistRoyalty, secondaryRoyalty);
    }

    function getRoyaltySplitData(uint256 _totalRoyalty)
        public
        view
        returns (
            uint256,
            uint256,
            address
        )
    {
        // Pull data from manager
        (, uint256 royaltySplitForArtist, , address artist) = IRoyaltyManager(
            manager
        ).nftRoyaltyConfigs(nftID);

        uint256 artistRoyalty = (_totalRoyalty * royaltySplitForArtist) / SCALE;
        uint256 secondaryRoyalty = (_totalRoyalty *
            (SCALE - royaltySplitForArtist)) / SCALE;

        return (artistRoyalty, secondaryRoyalty, artist);
    }

    // -------------------------------------
    // MODIFIERS
    // -------------------------------------

    modifier onlyRoyaltyManager() {
        require(msg.sender == manager, "RMS: NOT ROYALTY MANAGER");
        _;
    }
}

interface IERC20 {
    function balanceOf(address _account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);
}
