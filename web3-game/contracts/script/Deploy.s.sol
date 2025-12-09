// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "../src/AssassinToken.sol";
import "../src/WeaponNFT.sol";
import "../src/MountNFT.sol";
import "../src/SkinNFT.sol";
import "../src/Marketplace.sol";
import "../src/Staking.sol";

/**
 * @title DeployScript
 * @notice Deployment script for all Assassin Game contracts
 * @dev Run with: forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast
 */
contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        address admin = vm.envOr("ADMIN_ADDRESS", deployer);
        
        console.log("Deploying contracts...");
        console.log("Deployer:", deployer);
        console.log("Admin:", admin);

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy AssassinToken
        address[] memory minters = new address[](1);
        minters[0] = admin;
        
        AssassinToken token = new AssassinToken(admin, minters);
        console.log("AssassinToken deployed at:", address(token));

        // 2. Deploy NFT Collections
        WeaponNFT weaponNFT = new WeaponNFT(
            admin,
            admin, // royalty receiver
            250 // 2.5% royalty
        );
        console.log("WeaponNFT deployed at:", address(weaponNFT));

        MountNFT mountNFT = new MountNFT(
            admin,
            admin, // royalty receiver
            250 // 2.5% royalty
        );
        console.log("MountNFT deployed at:", address(mountNFT));

        SkinNFT skinNFT = new SkinNFT(
            admin,
            admin, // royalty receiver
            250 // 2.5% royalty
        );
        console.log("SkinNFT deployed at:", address(skinNFT));

        // 3. Deploy Marketplace
        Marketplace marketplace = new Marketplace(
            admin,
            admin, // treasury
            250 // 2.5% marketplace fee
        );
        console.log("Marketplace deployed at:", address(marketplace));

        // 4. Deploy Staking
        Staking staking = new Staking(
            admin,
            address(token),
            100 * 10**18, // 100 tokens per day base rate
            171232 * 10**18 // daily cap
        );
        console.log("Staking deployed at:", address(staking));

        // 5. Grant MINTER_ROLE to Staking contract
        token.grantRole(token.MINTER_ROLE(), address(staking));
        console.log("Granted MINTER_ROLE to Staking contract");

        // 6. Whitelist NFT collections in Staking
        staking.whitelistCollection(address(weaponNFT));
        staking.whitelistCollection(address(mountNFT));
        staking.whitelistCollection(address(skinNFT));
        console.log("Whitelisted NFT collections in Staking");

        vm.stopBroadcast();

        // Save deployment addresses
        console.log("\n=== Deployment Complete ===");
        console.log("AssassinToken:", address(token));
        console.log("WeaponNFT:", address(weaponNFT));
        console.log("MountNFT:", address(mountNFT));
        console.log("SkinNFT:", address(skinNFT));
        console.log("Marketplace:", address(marketplace));
        console.log("Staking:", address(staking));
        console.log("\nSave these addresses to your .env file!");
    }
}
