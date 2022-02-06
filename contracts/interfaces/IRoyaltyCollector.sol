// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IRoyaltyCollector {
	function royaltiesAvailable(address _token) external view returns (uint256, uint256);
}
