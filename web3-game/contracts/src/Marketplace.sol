// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

/**
 * @title Marketplace
 * @author Dominik Opałka
 * @notice NFT marketplace with EIP-712 signed offers and configurable fees
 */
contract Marketplace is AccessControl, ReentrancyGuard, Pausable, EIP712 {
    using ECDSA for bytes32;

    /// @notice Marketplace fee in basis points (100 = 1%, 500 = 5%)
    uint256 public marketplaceFee;

    /// @notice Maximum fee (10%)
    uint256 public constant MAX_FEE = 1000;

    /// @notice Treasury address that receives fees
    address public treasury;

    /// @notice Mapping to track used nonces
    mapping(address => mapping(uint256 => bool)) public usedNonces;

    /// @notice Offer struct for EIP-712 signing
    struct Offer {
        address collection;
        uint256 tokenId;
        address seller;
        uint256 price;
        address paymentToken; // address(0) for ETH
        uint256 deadline;
        uint256 nonce;
    }

    /// @notice EIP-712 typehash for Offer
    bytes32 private constant OFFER_TYPEHASH =
        keccak256(
            "Offer(address collection,uint256 tokenId,address seller,uint256 price,address paymentToken,uint256 deadline,uint256 nonce)"
        );

    /// @notice Emitted when NFT is sold
    event Sale(
        address indexed collection,
        uint256 indexed tokenId,
        address indexed seller,
        address buyer,
        uint256 price,
        uint256 marketplaceFeeAmount,
        uint256 royaltyAmount,
        address paymentToken
    );

    /// @notice Emitted when offer is cancelled
    event OfferCancelled(address indexed seller, uint256 nonce);

    /// @notice Emitted when fee is updated
    event FeeUpdated(uint256 oldFee, uint256 newFee);

    /// @notice Emitted when treasury is updated
    event TreasuryUpdated(address oldTreasury, address newTreasury);

    /**
     * @notice Contract constructor
     * @param admin Admin address
     * @param treasury_ Treasury address
     * @param initialFee Initial marketplace fee in basis points
     */
    constructor(
        address admin,
        address treasury_,
        uint256 initialFee
    ) EIP712("AssassinMarketplace", "1") {
        require(admin != address(0), "Admin cannot be zero address");
        require(treasury_ != address(0), "Treasury cannot be zero address");
        require(initialFee <= MAX_FEE, "Fee exceeds maximum");

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        treasury = treasury_;
        marketplaceFee = initialFee;
    }

    /**
     * @notice Buy NFT with signed offer
     * @param offer Offer details
     * @param signature EIP-712 signature from seller
     */
    function buy(Offer calldata offer, bytes calldata signature)
        external
        payable
        nonReentrant
        whenNotPaused
    {
        // Verify signature
        require(_verifyOffer(offer, signature), "Invalid signature");

        // Check deadline
        require(block.timestamp <= offer.deadline, "Offer expired");

        // Check nonce
        require(!usedNonces[offer.seller][offer.nonce], "Nonce already used");

        // Mark nonce as used
        usedNonces[offer.seller][offer.nonce] = true;

        // Verify seller owns the NFT
        IERC721 nft = IERC721(offer.collection);
        require(nft.ownerOf(offer.tokenId) == offer.seller, "Seller does not own NFT");

        // Calculate fees
        uint256 marketplaceFeeAmount = (offer.price * marketplaceFee) / 10000;
        uint256 royaltyAmount = 0;
        address royaltyReceiver = address(0);

        // Check for royalties (EIP-2981)
        if (_supportsERC2981(offer.collection)) {
            (royaltyReceiver, royaltyAmount) = IERC2981(offer.collection).royaltyInfo(
                offer.tokenId,
                offer.price
            );
        }

        uint256 sellerProceeds = offer.price - marketplaceFeeAmount - royaltyAmount;

        // Handle payment
        if (offer.paymentToken == address(0)) {
            // ETH payment
            require(msg.value == offer.price, "Incorrect ETH amount");

            // Transfer fees
            (bool successFee, ) = treasury.call{value: marketplaceFeeAmount}("");
            require(successFee, "Fee transfer failed");

            if (royaltyAmount > 0 && royaltyReceiver != address(0)) {
                (bool successRoyalty, ) = royaltyReceiver.call{value: royaltyAmount}("");
                require(successRoyalty, "Royalty transfer failed");
            }

            // Transfer proceeds to seller
            (bool successSeller, ) = offer.seller.call{value: sellerProceeds}("");
            require(successSeller, "Seller payment failed");
        } else {
            // ERC20 payment
            IERC20 token = IERC20(offer.paymentToken);

            // Transfer from buyer
            require(token.transferFrom(msg.sender, treasury, marketplaceFeeAmount), "Fee transfer failed");

            if (royaltyAmount > 0 && royaltyReceiver != address(0)) {
                require(
                    token.transferFrom(msg.sender, royaltyReceiver, royaltyAmount),
                    "Royalty transfer failed"
                );
            }

            require(
                token.transferFrom(msg.sender, offer.seller, sellerProceeds),
                "Seller payment failed"
            );
        }

        // Transfer NFT
        nft.safeTransferFrom(offer.seller, msg.sender, offer.tokenId);

        emit Sale(
            offer.collection,
            offer.tokenId,
            offer.seller,
            msg.sender,
            offer.price,
            marketplaceFeeAmount,
            royaltyAmount,
            offer.paymentToken
        );
    }

    /**
     * @notice Cancel an offer by invalidating nonce
     * @param nonce Nonce to cancel
     */
    function cancelOffer(uint256 nonce) external {
        require(!usedNonces[msg.sender][nonce], "Nonce already used");
        usedNonces[msg.sender][nonce] = true;
        emit OfferCancelled(msg.sender, nonce);
    }

    /**
     * @notice Update marketplace fee
     * @param newFee New fee in basis points
     */
    function setFee(uint256 newFee) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newFee <= MAX_FEE, "Fee exceeds maximum");
        uint256 oldFee = marketplaceFee;
        marketplaceFee = newFee;
        emit FeeUpdated(oldFee, newFee);
    }

    /**
     * @notice Update treasury address
     * @param newTreasury New treasury address
     */
    function setTreasury(address newTreasury) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newTreasury != address(0), "Treasury cannot be zero address");
        address oldTreasury = treasury;
        treasury = newTreasury;
        emit TreasuryUpdated(oldTreasury, newTreasury);
    }

    /**
     * @notice Pause marketplace
     */
    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    /**
     * @notice Unpause marketplace
     */
    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    /**
     * @notice Verify EIP-712 signature for offer
     * @param offer Offer to verify
     * @param signature Signature to check
     * @return bool True if signature is valid
     */
    function _verifyOffer(Offer calldata offer, bytes calldata signature) internal view returns (bool) {
        bytes32 structHash = keccak256(
            abi.encode(
                OFFER_TYPEHASH,
                offer.collection,
                offer.tokenId,
                offer.seller,
                offer.price,
                offer.paymentToken,
                offer.deadline,
                offer.nonce
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);
        address signer = hash.recover(signature);
        
        return signer == offer.seller;
    }

    /**
     * @notice Check if contract supports ERC2981
     * @param contractAddress Contract to check
     * @return bool True if contract supports ERC2981
     */
    function _supportsERC2981(address contractAddress) internal view returns (bool) {
        try IERC165(contractAddress).supportsInterface(type(IERC2981).interfaceId) returns (bool supported) {
            return supported;
        } catch {
            return false;
        }
    }

    /**
     * @notice Get domain separator for EIP-712
     * @return bytes32 Domain separator
     */
    function getDomainSeparator() external view returns (bytes32) {
        return _domainSeparatorV4();
    }
}
