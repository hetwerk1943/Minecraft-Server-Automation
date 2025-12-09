// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title AssassinToken
 * @author Dominik Opałka
 * @notice ERC20 token for the Assassin Web3 Game
 * @dev Fixed supply with role-based minting control
 */
contract AssassinToken is ERC20, ERC20Burnable, ERC20Permit, AccessControl, Pausable {
    /// @notice Role for minting new tokens
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    /// @notice Role for pausing the contract
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /// @notice Maximum total supply (1 billion tokens)
    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10**18;

    /// @notice Total amount of tokens minted
    uint256 public totalMinted;

    /// @notice Emitted when tokens are minted
    event TokensMinted(address indexed to, uint256 amount);

    /// @notice Emitted when tokens are burned
    event TokensBurned(address indexed from, uint256 amount);

    /**
     * @notice Contract constructor
     * @param admin Address that will have admin role
     * @param minters Array of addresses that will have minter role
     */
    constructor(
        address admin,
        address[] memory minters
    ) ERC20("Assassin Token", "ASSASSIN") ERC20Permit("Assassin Token") {
        require(admin != address(0), "Admin cannot be zero address");
        
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
        
        // Grant minter role to specified addresses
        for (uint256 i = 0; i < minters.length; i++) {
            require(minters[i] != address(0), "Minter cannot be zero address");
            _grantRole(MINTER_ROLE, minters[i]);
        }
    }

    /**
     * @notice Mint new tokens
     * @param to Address to receive tokens
     * @param amount Amount of tokens to mint
     * @dev Only callable by addresses with MINTER_ROLE
     * @dev Total minted cannot exceed MAX_SUPPLY
     */
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) whenNotPaused {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be greater than 0");
        require(totalMinted + amount <= MAX_SUPPLY, "Exceeds max supply");

        totalMinted += amount;
        _mint(to, amount);
        
        emit TokensMinted(to, amount);
    }

    /**
     * @notice Burn tokens from caller's balance
     * @param amount Amount of tokens to burn
     * @dev Override to add event emission
     */
    function burn(uint256 amount) public override whenNotPaused {
        super.burn(amount);
        emit TokensBurned(msg.sender, amount);
    }

    /**
     * @notice Burn tokens from specified account
     * @param account Account to burn from
     * @param amount Amount to burn
     * @dev Override to add event emission
     */
    function burnFrom(address account, uint256 amount) public override whenNotPaused {
        super.burnFrom(account, amount);
        emit TokensBurned(account, amount);
    }

    /**
     * @notice Pause all token transfers
     * @dev Only callable by addresses with PAUSER_ROLE
     */
    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @notice Unpause token transfers
     * @dev Only callable by addresses with PAUSER_ROLE
     */
    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /**
     * @notice Get remaining mintable supply
     * @return Amount of tokens that can still be minted
     */
    function remainingSupply() external view returns (uint256) {
        return MAX_SUPPLY - totalMinted;
    }

    /**
     * @notice Hook that is called before any transfer of tokens
     * @dev Includes minting and burning
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }
}
