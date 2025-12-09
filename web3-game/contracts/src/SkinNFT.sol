// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./GameNFT.sol";

/**
 * @title SkinNFT
 * @author Dominik Opałka
 * @notice ERC721 NFT for in-game character skins
 */
contract SkinNFT is GameNFT {
    constructor(
        address admin,
        address royaltyReceiver,
        uint96 royaltyFeeNumerator
    )
        GameNFT(
            "Assassin Skin",
            "ASKIN",
            1000, // max supply
            admin,
            royaltyReceiver,
            royaltyFeeNumerator
        )
    {}
}
