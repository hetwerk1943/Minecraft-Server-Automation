// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title GameNFT
 * @author Dominik Opałka
 * @notice Base ERC721 NFT contract for Assassin Game items
 * @dev Includes royalties (EIP-2981), enumerable, and delayed reveal
 */
abstract contract GameNFT is ERC721Enumerable, ERC721Royalty, AccessControl, Pausable {
    using Counters for Counters.Counter;

    /// @notice Role for minting NFTs
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    /// @notice Role for pausing the contract
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /// @notice Maximum supply of NFTs
    uint256 public immutable maxSupply;

    /// @notice Base URI for token metadata
    string private _baseTokenURI;

    /// @notice URI for unrevealed tokens
    string private _unrevealedURI;

    /// @notice Whether tokens have been revealed
    bool public isRevealed;

    /// @notice Counter for token IDs
    Counters.Counter private _tokenIdCounter;

    /// @notice Emitted when NFT is minted
    event NFTMinted(address indexed to, uint256 indexed tokenId);

    /// @notice Emitted when base URI is updated
    event BaseURIUpdated(string newBaseURI);

    /// @notice Emitted when collection is revealed
    event CollectionRevealed();

    /**
     * @notice Contract constructor
     * @param name_ Token name
     * @param symbol_ Token symbol
     * @param maxSupply_ Maximum supply
     * @param admin Admin address
     * @param royaltyReceiver Address to receive royalties
     * @param royaltyFeeNumerator Royalty fee in basis points (e.g., 250 = 2.5%)
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maxSupply_,
        address admin,
        address royaltyReceiver,
        uint96 royaltyFeeNumerator
    ) ERC721(name_, symbol_) {
        require(admin != address(0), "Admin cannot be zero address");
        require(maxSupply_ > 0, "Max supply must be greater than 0");
        
        maxSupply = maxSupply_;
        
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);
        
        // Set default royalty
        _setDefaultRoyalty(royaltyReceiver, royaltyFeeNumerator);
    }

    /**
     * @notice Mint a new NFT
     * @param to Address to receive the NFT
     * @return tokenId ID of the minted token
     */
    function mint(address to) external onlyRole(MINTER_ROLE) whenNotPaused returns (uint256) {
        require(to != address(0), "Cannot mint to zero address");
        require(_tokenIdCounter.current() < maxSupply, "Max supply reached");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        
        _safeMint(to, tokenId);
        
        emit NFTMinted(to, tokenId);
        return tokenId;
    }

    /**
     * @notice Batch mint NFTs
     * @param to Address to receive NFTs
     * @param amount Number of NFTs to mint
     */
    function batchMint(address to, uint256 amount) external onlyRole(MINTER_ROLE) whenNotPaused {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be greater than 0");
        require(_tokenIdCounter.current() + amount <= maxSupply, "Exceeds max supply");

        for (uint256 i = 0; i < amount; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(to, tokenId);
            emit NFTMinted(to, tokenId);
        }
    }

    /**
     * @notice Set base URI for revealed tokens
     * @param baseURI_ New base URI
     */
    function setBaseURI(string memory baseURI_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _baseTokenURI = baseURI_;
        emit BaseURIUpdated(baseURI_);
    }

    /**
     * @notice Set URI for unrevealed tokens
     * @param unrevealedURI_ New unrevealed URI
     */
    function setUnrevealedURI(string memory unrevealedURI_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unrevealedURI = unrevealedURI_;
    }

    /**
     * @notice Reveal the collection
     * @dev After reveal, all tokens show their real metadata
     */
    function reveal() external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!isRevealed, "Already revealed");
        isRevealed = true;
        emit CollectionRevealed();
    }

    /**
     * @notice Update royalty info
     * @param receiver Address to receive royalties
     * @param feeNumerator Royalty fee in basis points
     */
    function setRoyaltyInfo(address receiver, uint96 feeNumerator) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    /**
     * @notice Pause all transfers
     */
    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @notice Unpause transfers
     */
    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /**
     * @notice Get total minted tokens
     * @return Total number of minted tokens
     */
    function totalMinted() external view returns (uint256) {
        return _tokenIdCounter.current();
    }

    /**
     * @notice Get token URI
     * @param tokenId Token ID
     * @return Token URI string
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        if (!isRevealed) {
            return _unrevealedURI;
        }

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, Strings.toString(tokenId), ".json")) : "";
    }

    /**
     * @notice Get base URI
     * @return Base URI string
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @notice Hook called before any token transfer
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal virtual override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    /**
     * @notice Check if contract supports interface
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Enumerable, ERC721Royalty, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @notice Internal burn function override
     */
    function _burn(uint256 tokenId) internal virtual override(ERC721, ERC721Royalty) {
        super._burn(tokenId);
    }
}
