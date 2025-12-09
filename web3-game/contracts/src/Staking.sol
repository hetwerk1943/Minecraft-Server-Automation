// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title Staking
 * @author Dominik Opałka
 * @notice NFT staking contract for earning $ASSASSIN tokens
 * @dev Stake NFTs for configured lock periods to earn dynamic rewards
 */
contract Staking is AccessControl, ReentrancyGuard, Pausable {
    /// @notice Reward token (ASSASSIN)
    IERC20 public immutable rewardToken;

    /// @notice Base reward rate (tokens per day)
    uint256 public baseRewardRate;

    /// @notice Daily emission cap
    uint256 public dailyCap;

    /// @notice Total emitted today
    uint256 public dailyEmitted;

    /// @notice Last reset timestamp
    uint256 public lastResetTimestamp;

    /// @notice Valid lock periods (in seconds)
    uint256[] public validLockPeriods;

    /// @notice Lock period multipliers (in basis points, 10000 = 1.0x)
    mapping(uint256 => uint256) public lockMultipliers;

    /// @notice Whitelisted NFT collections
    mapping(address => bool) public whitelistedCollections;

    /// @notice Stake information
    struct StakeInfo {
        address owner;
        address collection;
        uint256 tokenId;
        uint256 startTime;
        uint256 lockPeriod;
        uint256 rewardRate;
        uint256 lastClaimTime;
    }

    /// @notice Mapping from collection + tokenId to stake info
    mapping(address => mapping(uint256 => StakeInfo)) public stakes;

    /// @notice User stakes (for enumeration)
    mapping(address => mapping(address => uint256[])) private userStakes;

    /// @notice Total value locked (number of staked NFTs)
    uint256 public totalStaked;

    /// @notice Emitted when NFT is staked
    event Staked(
        address indexed user,
        address indexed collection,
        uint256 indexed tokenId,
        uint256 lockPeriod,
        uint256 rewardRate
    );

    /// @notice Emitted when NFT is unstaked
    event Unstaked(
        address indexed user,
        address indexed collection,
        uint256 indexed tokenId,
        uint256 reward
    );

    /// @notice Emitted when rewards are claimed
    event RewardsClaimed(
        address indexed user,
        address indexed collection,
        uint256 indexed tokenId,
        uint256 reward
    );

    /// @notice Emitted when emergency withdraw is used
    event EmergencyWithdraw(address indexed user, address indexed collection, uint256 indexed tokenId);

    /**
     * @notice Contract constructor
     * @param admin Admin address
     * @param rewardToken_ Reward token address
     * @param baseRewardRate_ Base reward rate (tokens per day)
     * @param dailyCap_ Daily emission cap
     */
    constructor(
        address admin,
        address rewardToken_,
        uint256 baseRewardRate_,
        uint256 dailyCap_
    ) {
        require(admin != address(0), "Admin cannot be zero address");
        require(rewardToken_ != address(0), "Reward token cannot be zero address");
        require(baseRewardRate_ > 0, "Base reward rate must be greater than 0");
        require(dailyCap_ > 0, "Daily cap must be greater than 0");

        _grantRole(DEFAULT_ADMIN_ROLE, admin);

        rewardToken = IERC20(rewardToken_);
        baseRewardRate = baseRewardRate_;
        dailyCap = dailyCap_;
        lastResetTimestamp = block.timestamp;

        // Initialize lock periods (30, 60, 90 days)
        validLockPeriods.push(30 days);
        validLockPeriods.push(60 days);
        validLockPeriods.push(90 days);

        // Initialize multipliers
        lockMultipliers[30 days] = 10000; // 1.0x
        lockMultipliers[60 days] = 13000; // 1.3x
        lockMultipliers[90 days] = 17000; // 1.7x
    }

    /**
     * @notice Stake an NFT
     * @param collection NFT collection address
     * @param tokenId NFT token ID
     * @param lockPeriod Lock period in seconds
     */
    function stake(
        address collection,
        uint256 tokenId,
        uint256 lockPeriod
    ) external nonReentrant whenNotPaused {
        require(whitelistedCollections[collection], "Collection not whitelisted");
        require(_isValidLockPeriod(lockPeriod), "Invalid lock period");
        require(stakes[collection][tokenId].owner == address(0), "Already staked");

        IERC721 nft = IERC721(collection);
        require(nft.ownerOf(tokenId) == msg.sender, "Not token owner");

        // Calculate reward rate
        uint256 rewardRate = _calculateRewardRate(lockPeriod);

        // Transfer NFT to this contract
        nft.transferFrom(msg.sender, address(this), tokenId);

        // Store stake info
        stakes[collection][tokenId] = StakeInfo({
            owner: msg.sender,
            collection: collection,
            tokenId: tokenId,
            startTime: block.timestamp,
            lockPeriod: lockPeriod,
            rewardRate: rewardRate,
            lastClaimTime: block.timestamp
        });

        // Add to user stakes
        userStakes[msg.sender][collection].push(tokenId);
        totalStaked++;

        emit Staked(msg.sender, collection, tokenId, lockPeriod, rewardRate);
    }

    /**
     * @notice Unstake an NFT and claim rewards
     * @param collection NFT collection address
     * @param tokenId NFT token ID
     */
    function unstake(address collection, uint256 tokenId) external nonReentrant {
        StakeInfo storage stakeInfo = stakes[collection][tokenId];
        require(stakeInfo.owner == msg.sender, "Not stake owner");
        require(block.timestamp >= stakeInfo.startTime + stakeInfo.lockPeriod, "Lock period not expired");

        // Calculate and claim pending rewards
        uint256 pendingRewards = _calculatePendingRewards(collection, tokenId);
        uint256 rewardToClaim = _enforceDailyCap(pendingRewards);

        // Transfer NFT back to owner
        IERC721(collection).transferFrom(address(this), msg.sender, tokenId);

        // Transfer rewards
        if (rewardToClaim > 0) {
            require(rewardToken.transfer(msg.sender, rewardToClaim), "Reward transfer failed");
        }

        // Remove from user stakes
        _removeUserStake(msg.sender, collection, tokenId);
        totalStaked--;

        // Delete stake info
        delete stakes[collection][tokenId];

        emit Unstaked(msg.sender, collection, tokenId, rewardToClaim);
    }

    /**
     * @notice Claim rewards without unstaking
     * @param collection NFT collection address
     * @param tokenId NFT token ID
     */
    function claimRewards(address collection, uint256 tokenId) external nonReentrant {
        StakeInfo storage stakeInfo = stakes[collection][tokenId];
        require(stakeInfo.owner == msg.sender, "Not stake owner");

        uint256 pendingRewards = _calculatePendingRewards(collection, tokenId);
        require(pendingRewards > 0, "No rewards to claim");

        uint256 rewardToClaim = _enforceDailyCap(pendingRewards);
        stakeInfo.lastClaimTime = block.timestamp;

        require(rewardToken.transfer(msg.sender, rewardToClaim), "Reward transfer failed");

        emit RewardsClaimed(msg.sender, collection, tokenId, rewardToClaim);
    }

    /**
     * @notice Emergency withdraw NFT (forfeit all rewards)
     * @param collection NFT collection address
     * @param tokenId NFT token ID
     */
    function emergencyWithdraw(address collection, uint256 tokenId) external nonReentrant {
        StakeInfo storage stakeInfo = stakes[collection][tokenId];
        require(stakeInfo.owner == msg.sender, "Not stake owner");

        // Transfer NFT back (no rewards)
        IERC721(collection).transferFrom(address(this), msg.sender, tokenId);

        // Remove from user stakes
        _removeUserStake(msg.sender, collection, tokenId);
        totalStaked--;

        // Delete stake info
        delete stakes[collection][tokenId];

        emit EmergencyWithdraw(msg.sender, collection, tokenId);
    }

    /**
     * @notice Get pending rewards for a stake
     * @param collection NFT collection address
     * @param tokenId NFT token ID
     * @return Pending rewards amount
     */
    function pendingRewards(address collection, uint256 tokenId) external view returns (uint256) {
        return _calculatePendingRewards(collection, tokenId);
    }

    /**
     * @notice Get user's staked tokens in a collection
     * @param user User address
     * @param collection Collection address
     * @return Array of token IDs
     */
    function getUserStakes(address user, address collection) external view returns (uint256[] memory) {
        return userStakes[user][collection];
    }

    /**
     * @notice Whitelist NFT collection
     * @param collection Collection address
     */
    function whitelistCollection(address collection) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(collection != address(0), "Collection cannot be zero address");
        whitelistedCollections[collection] = true;
    }

    /**
     * @notice Remove collection from whitelist
     * @param collection Collection address
     */
    function removeCollection(address collection) external onlyRole(DEFAULT_ADMIN_ROLE) {
        whitelistedCollections[collection] = false;
    }

    /**
     * @notice Update base reward rate
     * @param newRate New rate
     */
    function setBaseRewardRate(uint256 newRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newRate > 0, "Rate must be greater than 0");
        baseRewardRate = newRate;
    }

    /**
     * @notice Update daily cap
     * @param newCap New cap
     */
    function setDailyCap(uint256 newCap) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newCap > 0, "Cap must be greater than 0");
        dailyCap = newCap;
    }

    /**
     * @notice Pause staking
     */
    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    /**
     * @notice Unpause staking
     */
    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    /**
     * @notice Calculate pending rewards for a stake
     * @param collection Collection address
     * @param tokenId Token ID
     * @return Pending rewards
     */
    function _calculatePendingRewards(address collection, uint256 tokenId) internal view returns (uint256) {
        StakeInfo storage stakeInfo = stakes[collection][tokenId];
        if (stakeInfo.owner == address(0)) return 0;

        uint256 timeStaked = block.timestamp - stakeInfo.lastClaimTime;
        uint256 daysStaked = timeStaked / 1 days;
        
        return (daysStaked * stakeInfo.rewardRate) / 1; // rewardRate is per day
    }

    /**
     * @notice Calculate reward rate based on lock period and TVL
     * @param lockPeriod Lock period
     * @return Reward rate
     */
    function _calculateRewardRate(uint256 lockPeriod) internal view returns (uint256) {
        uint256 multiplier = lockMultipliers[lockPeriod];
        
        // Base rate with lock multiplier
        uint256 rate = (baseRewardRate * multiplier) / 10000;
        
        // Dynamic adjustment based on TVL (simplified - can be enhanced)
        // Rate decreases as more NFTs are staked
        if (totalStaked > 100) {
            uint256 tvlAdjustment = 10000 - (totalStaked * 10); // 0.1% decrease per staked NFT
            if (tvlAdjustment < 5000) tvlAdjustment = 5000; // Min 50% of base rate
            rate = (rate * tvlAdjustment) / 10000;
        }
        
        return rate;
    }

    /**
     * @notice Enforce daily emission cap
     * @param amount Requested amount
     * @return Actual amount that can be emitted
     */
    function _enforceDailyCap(uint256 amount) internal returns (uint256) {
        // Reset daily counter if new day
        if (block.timestamp >= lastResetTimestamp + 1 days) {
            dailyEmitted = 0;
            lastResetTimestamp = block.timestamp;
        }

        // Check remaining cap
        uint256 remaining = dailyCap > dailyEmitted ? dailyCap - dailyEmitted : 0;
        uint256 toEmit = amount > remaining ? remaining : amount;

        dailyEmitted += toEmit;
        return toEmit;
    }

    /**
     * @notice Check if lock period is valid
     * @param lockPeriod Lock period to check
     * @return True if valid
     */
    function _isValidLockPeriod(uint256 lockPeriod) internal view returns (bool) {
        for (uint256 i = 0; i < validLockPeriods.length; i++) {
            if (validLockPeriods[i] == lockPeriod) return true;
        }
        return false;
    }

    /**
     * @notice Remove token from user stakes array
     * @param user User address
     * @param collection Collection address
     * @param tokenId Token ID to remove
     */
    function _removeUserStake(address user, address collection, uint256 tokenId) internal {
        uint256[] storage stakes = userStakes[user][collection];
        for (uint256 i = 0; i < stakes.length; i++) {
            if (stakes[i] == tokenId) {
                stakes[i] = stakes[stakes.length - 1];
                stakes.pop();
                break;
            }
        }
    }
}
