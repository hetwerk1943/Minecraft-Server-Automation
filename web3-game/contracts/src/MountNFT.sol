// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./GameNFT.sol";

/**
 * @title MountNFT
 * @author Dominik Opałka
 * @notice ERC721 NFT for in-game mounts
 */
contract MountNFT is GameNFT {
    constructor(
        address admin,
        address royaltyReceiver,
        uint96 royaltyFeeNumerator
    )
        GameNFT(
            "Assassin Mount",
            "AMOUNT",
            1000, // max supply
            admin,
            royaltyReceiver,
            royaltyFeeNumerator
        )
    {}
}
