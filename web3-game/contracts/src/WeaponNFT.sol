// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./GameNFT.sol";

/**
 * @title WeaponNFT
 * @author Dominik Opałka
 * @notice ERC721 NFT for in-game weapons
 */
contract WeaponNFT is GameNFT {
    constructor(
        address admin,
        address royaltyReceiver,
        uint96 royaltyFeeNumerator
    )
        GameNFT(
            "Assassin Weapon",
            "AWEAPON",
            1000, // max supply
            admin,
            royaltyReceiver,
            royaltyFeeNumerator
        )
    {}
}
