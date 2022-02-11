// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IRoyaltyManager {
    struct RoyaltyConfig {
        uint256 royaltyPercentageOfSale; // numerator over SCALE (1e18)
        uint256 royaltySplitForArtist;
        address royaltyCollector; // address of the Collector for specific NFT ID
        address artist; // artist = primary royalty recipient
    }

    function nftRoyaltyConfigs(uint256 _tokenID)
        external
        view
        returns (
            uint256 royaltyPercentageOfSale, // numerator over SCALE (1e18)
            uint256 royaltySplitForArtist,
            address royaltyCollector, // address of the Collector for specific NFT ID
            address artist
        );

    function secondaryRoyaltyRecipient()
        external
        view
        returns (address secondaryRecipient);

    function royaltyInfo(uint256 _tokenID, uint256 _salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);

    function registerTokenForRoyalties(uint256 _tokenID, address _artist)
        external
        returns (address royaltyCollector);
}
