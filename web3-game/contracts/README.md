# Assassin Game - Smart Contracts

## 📋 Przegląd

Smart kontrakty dla gry Assassin Web3 zbudowane w Solidity z użyciem Foundry.

### Kontrakty

1. **AssassinToken.sol** - ERC20 token ($ASSASSIN)
2. **GameNFT.sol** - Bazowy kontrakt NFT
3. **WeaponNFT.sol** - NFT dla broni
4. **MountNFT.sol** - NFT dla mountów
5. **SkinNFT.sol** - NFT dla skinów
6. **Marketplace.sol** - Marketplace z EIP-712
7. **Staking.sol** - Staking NFT → tokens

## 🚀 Quick Start

### Wymagania

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [Node.js](https://nodejs.org/) (opcjonalnie, dla dodatkowych narzędzi)

### Instalacja

1. **Zainstaluj Foundry:**
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

2. **Zainstaluj zależności:**
```bash
cd web3-game/contracts
forge install OpenZeppelin/openzeppelin-contracts
forge install foundry-rs/forge-std
```

3. **Skopiuj .env:**
```bash
cp .env.example .env
# Edytuj .env z własnymi wartościami
```

### Kompilacja

```bash
forge build
```

### Testy

```bash
# Uruchom wszystkie testy
forge test

# Testy z szczegółami
forge test -vv

# Testy z gas reports
forge test --gas-report

# Fuzz testing (10k runs)
forge test --fuzz-runs 10000
```

### Deployment

#### Testnet (np. Sepolia)

```bash
# Edytuj .env z PRIVATE_KEY i SEPOLIA_RPC_URL
forge script script/Deploy.s.sol \
  --rpc-url $SEPOLIA_RPC_URL \
  --broadcast \
  --verify
```

#### Mainnet (np. Polygon)

```bash
# UWAGA: Sprawdź wszystko przed deploymentem na mainnet!
forge script script/Deploy.s.sol \
  --rpc-url $POLYGON_RPC_URL \
  --broadcast \
  --verify \
  --slow
```

### Weryfikacja Kontraktu (Manual)

```bash
forge verify-contract \
  --chain-id 11155111 \
  --compiler-version 0.8.23 \
  <CONTRACT_ADDRESS> \
  src/AssassinToken.sol:AssassinToken
```

## 📝 Konfiguracja Kontraktów

### AssassinToken

```solidity
// Deploy parameters
admin: address           // Admin address
minters: address[]       // Addresses with mint permission

// Key features
- Total supply: 1B fixed
- Burnable
- Pausable
- Permit (EIP-2612)
```

### NFT Collections (Weapon/Mount/Skin)

```solidity
// Deploy parameters
admin: address           // Admin address
royaltyReceiver: address // Royalty recipient
royaltyFeeNumerator: 96  // 250 = 2.5%

// Key features
- Max supply: 1000 each
- ERC721Enumerable
- EIP-2981 royalties
- Delayed reveal
- Pausable
```

### Marketplace

```solidity
// Deploy parameters
admin: address           // Admin address
treasury: address        // Fee recipient
initialFee: uint256      // 250 = 2.5%

// Key features
- EIP-712 signed offers
- Configurable fees (max 10%)
- Automatic royalty enforcement
- Support ETH and ERC20 payments
```

### Staking

```solidity
// Deploy parameters
admin: address           // Admin address
rewardToken: address     // AssassinToken address
baseRewardRate: uint256  // 100e18 = 100 tokens/day
dailyCap: uint256        // 171232e18 = daily emission cap

// Key features
- Lock periods: 30/60/90 days
- Dynamic APY (based on TVL)
- Daily emission cap
- Emergency withdraw
```

## 🧪 Testing

### Unit Tests

Testy podstawowe dla każdego kontraktu:

```bash
forge test --match-contract AssassinTokenTest
forge test --match-contract WeaponNFTTest
forge test --match-contract MarketplaceTest
forge test --match-contract StakingTest
```

### Fuzz Tests

Testy z losowymi inputami:

```bash
forge test --fuzz-runs 10000
```

### Coverage

```bash
forge coverage
```

### Gas Snapshots

```bash
forge snapshot
```

## 🔐 Security

### Przed Deploymentem

- [ ] Wszystkie testy przechodzą
- [ ] Coverage > 95%
- [ ] Fuzz tests (10k runs)
- [ ] Slither analysis
- [ ] Manual code review
- [ ] External audit (zalecane)

### Slither

```bash
pip install slither-analyzer
slither .
```

### Mythril (opcjonalnie)

```bash
pip install mythril
myth analyze src/AssassinToken.sol
```

## 📊 Gas Optimization

### Tips

1. **Use calldata** zamiast memory dla read-only params
2. **Pack structs** - zmienne od największych
3. **Batch operations** - mint/stake wielu NFT
4. **Custom errors** zamiast require strings
5. **Immutable** dla deploy-time constants

### Gas Reports

```bash
forge test --gas-report > gas-report.txt
```

## 🌐 Sieci

### Testnet

| Network | Chain ID | RPC |
|---------|----------|-----|
| Sepolia | 11155111 | https://eth-sepolia.g.alchemy.com/v2/... |
| Mumbai | 80001 | https://polygon-mumbai.g.alchemy.com/v2/... |
| Base Goerli | 84531 | https://goerli.base.org |
| Arbitrum Goerli | 421613 | https://goerli-rollup.arbitrum.io/rpc |

### Mainnet (Wybór 1)

| Network | Chain ID | RPC | Zalety |
|---------|----------|-----|--------|
| **Polygon** | 137 | https://polygon-rpc.com | Niskie fees (~$0.01), szybki |
| **Arbitrum** | 42161 | https://arb1.arbitrum.io/rpc | Ethereum L2, bezpieczny |
| **Base** | 8453 | https://mainnet.base.org | Coinbase, rosnący ecosystem |

**Rekomendacja:** Polygon dla MVP (najniższe koszty)

## 🔧 Troubleshooting

### "Out of gas" podczas deploymentu

```bash
# Zwiększ gas limit
forge script script/Deploy.s.sol --gas-limit 10000000
```

### "Nonce too low"

```bash
# Reset nonce
cast nonce <YOUR_ADDRESS> --rpc-url $RPC_URL
```

### Verification failed

```bash
# Użyj --force
forge verify-contract --force <ADDRESS> src/Contract.sol:Contract
```

### Dependencies nie installują się

```bash
# Wyczyść cache
forge clean
rm -rf lib/
forge install
```

## 📚 Dodatkowe Zasoby

- [Foundry Book](https://book.getfoundry.sh/)
- [Solidity Docs](https://docs.soliditylang.org/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [EIP-712](https://eips.ethereum.org/EIPS/eip-712)
- [EIP-2981](https://eips.ethereum.org/EIPS/eip-2981)

## 📄 Licencja

© 2025 Dominik Opałka. All Rights Reserved.
