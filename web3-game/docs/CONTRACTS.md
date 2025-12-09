# Smart Contracts Documentation

## 📋 Przegląd Kontraktów

Projekt składa się z 6 głównych smart kontraktów:

1. **AssassinToken.sol** - ERC20 token z role-based access
2. **WeaponNFT.sol** - ERC721 NFT dla broni
3. **MountNFT.sol** - ERC721 NFT dla mountów
4. **SkinNFT.sol** - ERC721 NFT dla skinów
5. **Marketplace.sol** - Trading platform z EIP-712 signed offers
6. **Staking.sol** - NFT staking dla passive income

## 1. AssassinToken (ERC20)

### Specyfikacja
- **Standard:** ERC20
- **Name:** Assassin Token
- **Symbol:** ASSASSIN
- **Decimals:** 18
- **Total Supply:** 1,000,000,000 (fixed)
- **Upgradeable:** Nie (immutable)

### Funkcje

#### Mint (Only Minter Role)
```solidity
function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE)
```
- Tworzy nowe tokeny
- Cap: Total supply - już zmintowane
- Emituje: `Transfer(address(0), to, amount)`

#### Burn
```solidity
function burn(uint256 amount) public
function burnFrom(address account, uint256 amount) public
```
- Niszczy tokeny (permanent deflation)
- Dostępne dla każdego gracza
- Używane w token sinks

#### Role Management
```solidity
bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
```

### Security Features
- ✅ AccessControl dla minting
- ✅ Fixed supply (nie można przekroczyć 1B)
- ✅ Pausable (emergency stop)
- ✅ Permit (EIP-2612) dla gasless approvals
- ✅ No upgradeable (immutable po deploy)

### Deployment Parameters
```solidity
constructor(
    address admin,
    address[] memory minters
)
```

## 2. WeaponNFT / MountNFT / SkinNFT (ERC721)

### Specyfikacja
- **Standard:** ERC721Enumerable
- **Base URI:** IPFS (ipfs://...)
- **Max Supply:** 1,000 per collection (configurable)
- **Royalties:** EIP-2981 (2.5-5%)
- **Reveal:** Delayed reveal mechanizm

### Funkcje

#### Mint (Only Minter Role)
```solidity
function mint(address to, uint256 tokenId) external onlyRole(MINTER_ROLE)
function batchMint(address to, uint256[] calldata tokenIds) external onlyRole(MINTER_ROLE)
```

#### Metadata
```solidity
function tokenURI(uint256 tokenId) public view returns (string memory)
function setBaseURI(string memory baseURI) external onlyRole(DEFAULT_ADMIN_ROLE)
```

#### Reveal Mechanism
```solidity
function reveal() external onlyRole(DEFAULT_ADMIN_ROLE)
function isRevealed() public view returns (bool)
```
- Pre-reveal: Wszystkie tokeny pokazują placeholder
- Post-reveal: Pokazuje prawdziwe metadata

#### Royalties (EIP-2981)
```solidity
function setRoyaltyInfo(address receiver, uint96 feeNumerator) external onlyRole(DEFAULT_ADMIN_ROLE)
function royaltyInfo(uint256 tokenId, uint256 salePrice) external view returns (address, uint256)
```

### Attributes (Off-chain Metadata)

#### Weapon NFT
```json
{
  "name": "Shadow Blade #42",
  "description": "Legendary weapon forged in darkness",
  "image": "ipfs://QmXXX.../42.png",
  "attributes": [
    {"trait_type": "Rarity", "value": "Legendary"},
    {"trait_type": "Damage", "value": 150},
    {"trait_type": "Speed", "value": 85},
    {"trait_type": "Durability", "value": 100},
    {"trait_type": "Element", "value": "Shadow"}
  ]
}
```

#### Mount NFT
```json
{
  "name": "Spectral Horse #13",
  "description": "Swift mount from the ethereal plane",
  "image": "ipfs://QmYYY.../13.png",
  "attributes": [
    {"trait_type": "Rarity", "value": "Epic"},
    {"trait_type": "Speed", "value": 120},
    {"trait_type": "Stamina", "value": 200},
    {"trait_type": "Type", "value": "Horse"}
  ]
}
```

#### Skin NFT
```json
{
  "name": "Dark Assassin Outfit #7",
  "description": "Stealthy armor for true assassins",
  "image": "ipfs://QmZZZ.../7.png",
  "attributes": [
    {"trait_type": "Rarity", "value": "Rare"},
    {"trait_type": "Set", "value": "Dark Assassin"},
    {"trait_type": "Bonus", "value": "+10% Stealth"}
  ]
}
```

### Security Features
- ✅ Role-based minting
- ✅ Max supply enforced
- ✅ Enumerable (for indexing)
- ✅ Pausable
- ✅ Royalties standard (EIP-2981)
- ✅ No upgradeable

## 3. Marketplace

### Specyfikacja
- **Trading:** EIP-712 signed offers
- **Fee:** 2-5% configurable
- **Royalties:** Automatic enforcement (EIP-2981)
- **Payment:** Native ETH lub $ASSASSIN token

### Strukcts

#### Offer
```solidity
struct Offer {
    address collection;      // NFT contract address
    uint256 tokenId;         // NFT token ID
    address seller;          // Current owner
    uint256 price;           // Sale price
    address paymentToken;    // address(0) for ETH, token address for ERC20
    uint256 deadline;        // Offer expiry timestamp
    uint256 nonce;          // Unique nonce (prevent replay)
}
```

### Funkcje

#### Create Offer (Off-chain Signing)
```solidity
// Seller signs off-chain (EIP-712)
bytes32 offerHash = _hashOffer(offer);
bytes signature = wallet.signTypedData(domain, types, offer);
```

#### Buy
```solidity
function buy(
    Offer calldata offer,
    bytes calldata signature
) external payable
```

**Logika:**
1. Verify EIP-712 signature
2. Check deadline, nonce
3. Transfer NFT: seller → buyer
4. Calculate fees (marketplace + royalty)
5. Transfer payment: buyer → seller (minus fees)
6. Emit `Sale` event

#### Cancel Offer
```solidity
function cancelOffer(uint256 nonce) external
```
- Invalidates nonce
- Tylko seller może cancelować

#### Update Fee
```solidity
function setFee(uint256 newFee) external onlyRole(DEFAULT_ADMIN_ROLE)
```
- Fee w basis points (100 = 1%, 500 = 5%)
- Max fee: 1000 (10%)

### Fee Distribution
```
Sale Price: 100 ETH
├── Marketplace Fee (2.5%): 2.5 ETH → Protocol Treasury
├── Royalty (5%): 5 ETH → Creator
└── Seller Proceeds: 92.5 ETH → Seller
```

### EIP-712 Typed Data
```solidity
bytes32 private constant OFFER_TYPEHASH = keccak256(
    "Offer(address collection,uint256 tokenId,address seller,uint256 price,address paymentToken,uint256 deadline,uint256 nonce)"
);
```

### Security Features
- ✅ EIP-712 signed offers (no frontrunning)
- ✅ Nonce system (prevent replay)
- ✅ Deadline (time-bound offers)
- ✅ Reentrancy guard
- ✅ Pull payment pattern
- ✅ Royalty enforcement
- ✅ Pausable

### Events
```solidity
event Sale(
    address indexed collection,
    uint256 indexed tokenId,
    address indexed seller,
    address buyer,
    uint256 price,
    uint256 fee,
    uint256 royalty
);

event OfferCancelled(
    address indexed seller,
    uint256 nonce
);

event FeeUpdated(uint256 oldFee, uint256 newFee);
```

## 4. Staking

### Specyfikacja
- **Input:** NFT (weapon/mount/skin)
- **Output:** $ASSASSIN tokens
- **Lock Periods:** 30, 60, 90 dni
- **APY:** Dynamic (spada przy high TVL)
- **Daily Cap:** Limit dziennej emisji

### Structs

#### StakeInfo
```solidity
struct StakeInfo {
    address collection;      // NFT contract
    uint256 tokenId;         // NFT token ID
    uint256 startTime;       // Stake timestamp
    uint256 lockPeriod;      // Lock duration (seconds)
    uint256 rewardRate;      // Tokens per day at stake time
}
```

### Funkcje

#### Stake NFT
```solidity
function stake(
    address collection,
    uint256 tokenId,
    uint256 lockPeriod
) external
```

**Requirements:**
- NFT approved for staking contract
- Valid lock period (30/60/90 days)
- Collection whitelisted

**Logic:**
1. Transfer NFT: user → staking contract
2. Calculate reward rate (based on TVL, lock period)
3. Store stake info
4. Emit `Staked` event

#### Unstake NFT
```solidity
function unstake(address collection, uint256 tokenId) external
```

**Requirements:**
- Lock period expired
- User is original staker

**Logic:**
1. Calculate pending rewards
2. Transfer NFT: staking → user
3. Mint rewards (if under daily cap)
4. Delete stake info
5. Emit `Unstaked` event

#### Claim Rewards (Without Unstaking)
```solidity
function claimRewards(address collection, uint256 tokenId) external
```

**Logic:**
1. Calculate pending rewards
2. Mint rewards (if under daily cap)
3. Reset reward counter
4. Emit `RewardsClaimed` event

#### Emergency Withdraw
```solidity
function emergencyWithdraw(address collection, uint256 tokenId) external
```
- Forfeit all rewards
- Get NFT back immediately
- No lock period check

### Dynamic Reward Rate

**Formula:**
```solidity
rewardRate = baseRate × lockMultiplier × (1 - TVLRatio)

gdzie:
- baseRate = 100 tokens/day (base dla 30 dni)
- lockMultiplier = 1.0 (30d), 1.3 (60d), 1.7 (90d)
- TVLRatio = totalStakedValue / totalSupply
```

**Przykład:**
- Base: 100 tokens/day
- Lock 90 dni: 100 × 1.7 = 170 tokens/day
- TVL 20%: 170 × (1 - 0.2) = 136 tokens/day
- Rocznie: 136 × 365 = 49,640 tokens (49.6k APY)

### Daily Emission Cap

```solidity
uint256 public constant DAILY_CAP = 171232e18; // ~171k tokens/day
uint256 public dailyEmitted;
uint256 public lastResetTimestamp;

function _enforceDailyCap(uint256 amount) internal {
    if (block.timestamp >= lastResetTimestamp + 1 days) {
        dailyEmitted = 0;
        lastResetTimestamp = block.timestamp;
    }
    
    require(dailyEmitted + amount <= DAILY_CAP, "Daily cap exceeded");
    dailyEmitted += amount;
}
```

### Security Features
- ✅ Lock periods enforced
- ✅ Daily emission cap
- ✅ Emergency withdraw (safety net)
- ✅ Reentrancy guard
- ✅ Cooldown period
- ✅ Whitelist collections
- ✅ Pausable

### Events
```solidity
event Staked(
    address indexed user,
    address indexed collection,
    uint256 indexed tokenId,
    uint256 lockPeriod,
    uint256 rewardRate
);

event Unstaked(
    address indexed user,
    address indexed collection,
    uint256 indexed tokenId,
    uint256 reward
);

event RewardsClaimed(
    address indexed user,
    address indexed collection,
    uint256 indexed tokenId,
    uint256 reward
);

event EmergencyWithdraw(
    address indexed user,
    address indexed collection,
    uint256 indexed tokenId
);
```

## 🔐 Security Considerations

### All Contracts

#### Access Control
- Role-based permissions (OpenZeppelin AccessControl)
- Multi-sig dla admin operations
- Timelock dla critical changes

#### Reentrancy
- ReentrancyGuard na wszystkich payable/external funkcjach
- Checks-Effects-Interactions pattern

#### Overflow/Underflow
- Solidity 0.8+ (built-in overflow checks)
- SafeMath deprecated (nie potrzebny)

#### Front-running
- EIP-712 signed offers (marketplace)
- Commit-reveal (jeśli potrzebne)
- Deadline enforcement

#### Emergency Features
- Pausable (circuit breaker)
- Emergency withdraw (staking)
- No self-destruct (no rug pull)

### Pre-Deploy Checklist

- [ ] Fuzz testing (Foundry)
- [ ] Invariant tests
- [ ] Slither analysis
- [ ] Solhint linting
- [ ] Gas optimization
- [ ] Unit test coverage > 95%
- [ ] Integration tests
- [ ] External audit (2+ firms)
- [ ] Testnet deployment
- [ ] Bug bounty program

## 📊 Gas Optimization

### Tips Implemented
1. **Pack structs:** Zmienne w kolejności od największych
2. **uint256 > uint128:** Unless packing benefit
3. **Calldata > memory:** Dla external read-only params
4. **Batch operations:** batchMint, batchStake
5. **Events > Storage:** Store off-chain gdy możliwe
6. **Immutable:** Dla deploy-time constants
7. **Custom errors:** Zamiast require strings (Solidity 0.8.4+)

### Gas Estimates

| Operation | Gas Cost | USD (50 gwei, $2000 ETH) |
|-----------|----------|--------------------------|
| Mint Token | ~50,000 | $5 |
| Mint NFT | ~80,000 | $8 |
| List on Marketplace | ~70,000 (off-chain sign) | $0 (off-chain) |
| Buy from Marketplace | ~150,000 | $15 |
| Stake NFT | ~120,000 | $12 |
| Claim Rewards | ~70,000 | $7 |
| Unstake NFT | ~100,000 | $10 |

## 🧪 Testing Strategy

### Unit Tests (Foundry)
```bash
forge test -vv
```
- Każda funkcja osobny test
- Edge cases (zero address, max uint, etc.)
- Reverts i error messages
- Events emission

### Fuzz Tests
```bash
forge test --fuzz-runs 10000
```
- Random inputs (addresses, amounts)
- Invariants check po każdej operacji
- Boundary testing

### Invariant Tests
```solidity
// Example: Total supply = sum of balances
invariant_totalSupply() {
    assertEq(token.totalSupply(), sumOfBalances);
}
```

### Integration Tests
- Multi-contract interactions
- Full user flows (mint → stake → claim → trade)
- E2E scenarios

### Testnet Testing
1. Deploy na Sepolia/Mumbai
2. Manual testing (UI)
3. Load testing (bots)
4. Monitoring (events, state changes)
5. Security testing (attack vectors)

## 📦 Deployment

### Networks

**Testnet:**
- Sepolia (Ethereum)
- Mumbai (Polygon)
- Arbitrum Goerli
- Base Goerli

**Mainnet (wybór 1):**
- Polygon (low fees, fast)
- Arbitrum (Ethereum L2, lower fees)
- Base (Coinbase L2, growing ecosystem)

### Deployment Order
1. AssassinToken
2. WeaponNFT, MountNFT, SkinNFT
3. Marketplace
4. Staking
5. Grant roles (MINTER_ROLE)
6. Configure parameters (fees, caps)
7. Transfer ownership (multi-sig)
8. Verify on Etherscan

### Scripts
```bash
# Deploy all contracts
forge script script/Deploy.s.sol --rpc-url $RPC --broadcast --verify

# Verify individual contract
forge verify-contract $ADDRESS src/AssassinToken.sol:AssassinToken --chain-id $CHAIN_ID
```

---

© 2025 Dominik Opałka. All Rights Reserved.
