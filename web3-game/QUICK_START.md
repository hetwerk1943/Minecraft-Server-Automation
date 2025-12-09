# Quick Start Guide - Assassin Game

## 🚀 Szybki Start (5 minut)

Ten przewodnik pomoże Ci szybko uruchomić projekt Assassin Game Web3.

## Wymagania

- **Node.js** 18+ ([Download](https://nodejs.org/))
- **Foundry** ([Install](https://book.getfoundry.sh/getting-started/installation))
- **PostgreSQL** 14+ (dla backend)
- **Git** ([Download](https://git-scm.com/))

## Krok 1: Klonowanie Repo

```bash
git clone https://github.com/hetwerk1943/Minecraft-Server-Automation.git
cd Minecraft-Server-Automation/web3-game
```

## Krok 2: Smart Contracts (Testnet)

```bash
cd contracts

# Zainstaluj zależności
forge install OpenZeppelin/openzeppelin-contracts
forge install foundry-rs/forge-std

# Skompiluj kontrakty
forge build

# Uruchom testy
forge test

# Konfiguracja deployment
cp .env.example .env
# Edytuj .env z swoimi wartościami:
# - PRIVATE_KEY (testnet wallet)
# - SEPOLIA_RPC_URL (np. Alchemy)
```

### Deploy na Testnet (Sepolia)

```bash
forge script script/Deploy.s.sol \
  --rpc-url $SEPOLIA_RPC_URL \
  --broadcast \
  --verify
```

**Zapisz adresy kontraktów!** Będą potrzebne dla frontend/backend.

## Krok 3: Backend API

```bash
cd ../backend

# Zainstaluj pakiety
npm install

# Konfiguracja
cp .env.example .env
# Edytuj .env:
# - DATABASE_URL (PostgreSQL)
# - JWT_SECRET (random string)
# - Contract addresses (z kroku 2)
# - RPC_URL (Sepolia)

# Setup bazy danych
npm run prisma:generate
npm run prisma:migrate

# Uruchom backend
npm run dev
```

Backend dostępny na: http://localhost:3001

## Krok 4: Frontend

```bash
cd ../frontend

# Zainstaluj pakiety
npm install

# Konfiguracja
cp .env.example .env.local
# Edytuj .env.local:
# - NEXT_PUBLIC_ALCHEMY_ID
# - NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID
# - NEXT_PUBLIC_CHAIN_ID=11155111 (Sepolia)
# - NEXT_PUBLIC_API_URL=http://localhost:3001

# Uruchom frontend
npm run dev
```

Frontend dostępny na: http://localhost:3000

## Krok 5: Testowanie

### 1. Połącz Wallet (MetaMask)

- Otwórz http://localhost:3000
- Kliknij "Connect Wallet"
- Wybierz MetaMask
- Przełącz na Sepolia testnet
- Połącz

### 2. Mint NFT (testnet)

```bash
# Z konta admin/deployer
cast send $WEAPON_NFT_ADDRESS \
  "mint(address)" \
  $YOUR_ADDRESS \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY
```

Lub użyj frontend UI (jeśli masz MINTER_ROLE).

### 3. List NFT na Marketplace

- Przejdź do Dashboard
- Wybierz NFT
- Kliknij "List for Sale"
- Ustaw cenę
- Podpisz message (off-chain)

### 4. Stake NFT

- Przejdź do Staking
- Wybierz NFT
- Wybierz lock period (30/60/90 dni)
- Approve NFT
- Stake

### 5. Claim Rewards

Po czasie:
- Wróć do Staking
- Kliknij "Claim Rewards"
- Otrzymaj $ASSASSIN tokens

## Struktura Projektu

```
web3-game/
├── contracts/          # Smart kontrakty (Foundry)
│   ├── src/           # Solidity pliki
│   ├── script/        # Deploy scripts
│   └── test/          # Testy
├── frontend/          # Next.js app
│   ├── src/app/       # Pages (App Router)
│   ├── src/components/ # React komponenty
│   └── src/hooks/     # Custom hooks
├── backend/           # Node.js API
│   ├── src/routes/    # API endpoints
│   ├── src/services/  # Business logic
│   └── prisma/        # Database schema
├── game/              # Unity game (placeholder)
├── docs/              # Dokumentacja
└── config/            # Config files
```

## Częste Problemy

### "Cannot find Foundry"

```bash
# Zainstaluj Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### "Database connection failed"

```bash
# Sprawdź czy PostgreSQL działa
psql -U postgres

# Utwórz bazę
createdb assassin_game

# Update DATABASE_URL w .env
```

### "RPC error" / "Network not supported"

```bash
# Sprawdź chain ID
cast chain-id --rpc-url $RPC_URL

# Update w .env
NEXT_PUBLIC_CHAIN_ID=11155111
```

### "Insufficient funds" na testnet

Pobierz Sepolia ETH:
- [Alchemy Faucet](https://sepoliafaucet.com/)
- [Infura Faucet](https://www.infura.io/faucet/sepolia)

## Następne Kroki

### 1. Konfiguracja Mainnet

- Deploy na Polygon/Arbitrum/Base
- Update wszystkich .env z mainnet RPC
- Zmień NEXT_PUBLIC_CHAIN_ID

### 2. Setup IPFS

- Utwórz konto na [Pinata](https://pinata.cloud/)
- Upload metadata do IPFS
- Ustaw baseURI w NFT kontraktach

### 3. Frontend Customization

- Edytuj logo/branding
- Dostosuj kolory (Tailwind config)
- Dodaj własne grafiki

### 4. Add Game Content

- Upload Unity build do `frontend/public/game/`
- Lub zintegruj Three.js
- Connect game logic z blockchain

### 5. Marketing

- Setup Discord/Twitter
- Utwórz whitepaper
- Launch waitlista
- Plan premint campaign

## Dodatkowa Pomoc

- **Dokumentacja:** Zobacz `/docs` dla szczegółów
- **Contracts:** [contracts/README.md](./contracts/README.md)
- **Frontend:** [frontend/README.md](./frontend/README.md)
- **Backend:** [backend/README.md](./backend/README.md)

## Wsparcie

- **Email:** hetwerk1943@gmail.com
- **GitHub Issues:** [Create Issue](https://github.com/hetwerk1943/Minecraft-Server-Automation/issues)

---

**Powodzenia z budową gry!** 🎮🚀

© 2025 Dominik Opałka. All Rights Reserved.
