# Web3 Game Development Framework - Assassin Game

## 📋 Przegląd

Kompletny framework do budowy gry Web3 z integracją blockchain, NFT i tokenami. Projekt realizuje 12-miesięczny plan rozwoju gry typu action RPG z pełną ekonomią Web3.

## 🎯 Cele Projektu

### Finansowe
- **Horyzont:** 12 miesięcy
- **Cel przychodu:** ≥1 000 000 zł/USD
- **Warunki sukcesu:** ≥10 000 aktywnych graczy, stabilna ekonomia, kontrola inflacji

### Techniczne
- MVP gry z podstawowym combat loop
- Testnet i mainnet ekonomii (token + NFT)
- Marketplace z fee 2-5%
- System stakingu NFT → ERC20
- Integracja Web3 wallet (SIWE)

## 🗓️ Roadmap (12 miesięcy)

### M1-M2: MVP + Testnet Ekonomii
**Dostarczalne:**
- ✅ Ruch/kamera/kolizje w grze
- ✅ 1-2 mapy PvE z podstawowym combat
- ✅ UI: HP/XP/loot
- ✅ Testnet kontrakty: ERC20 + 3×ERC721
- ✅ Landing page + waitlista
- ✅ Dashboard: saldo testnet, NFT podgląd
- ✅ CI/CD: lint/test/fuzz/slither

**KPI:** 500-2000 zapisów na waitlistę, stabilny build gry

### M3: Premint + TGE Wstępny
**Dostarczalne:**
- 600-1000 NFT (allowlist + public)
- TGE: mały unlock public (5-10%), reszta vest
- Marketplace v0 na testnet
- Staking v0 na testnet
- Monitoring eventów blockchain

**KPI:** >70% wyprzedany drop

### M4-M6: Beta Otwarta + Marketplace v1
**Dostarczalne:**
- 5 lokacji PvE
- PvP (1v1/3v3) z matchmaking
- Marketplace v1 na mainnet (fee 2-5%)
- Staking v1 w produkcji
- Leaderboard off-chain

**KPI:** 2-5k MAU, GMV 30-150k zł/mies.

### M7-M9: Live Ops + Sezony
**Dostarczalne:**
- Sezony z battle pass v1
- Turnieje PvP z wejściówką
- Nowe dropy NFT (mount/loot)
- Token sinki (craft/repair/upgrade)

**KPI:** GMV 150-300k zł/mies., ARPPU ↑10-30%

### M10-M12: Battle Pass NFT + Gildie
**Dostarczalne:**
- Battle Pass NFT (10k × 50 zł)
- System gildii
- Ranking PvP rozbudowany
- Premium lootboxy (z disclosure)

**KPI:** GMV 200-400k zł/mies., 10-20k MAU

## 🏗️ Architektura

```
web3-game/
├── contracts/          # Smart kontrakty (Solidity + Foundry)
│   ├── src/
│   │   ├── AssassinToken.sol      # ERC20 token
│   │   ├── WeaponNFT.sol          # ERC721 weapon
│   │   ├── MountNFT.sol           # ERC721 mount
│   │   ├── SkinNFT.sol            # ERC721 skin
│   │   ├── Marketplace.sol        # EIP-712 marketplace
│   │   └── Staking.sol            # NFT staking
│   ├── script/                     # Deploy scripts
│   └── test/                       # Testy (fuzz, invariant)
├── frontend/           # Next.js + wagmi + Tailwind
│   ├── src/
│   │   ├── components/            # UI komponenty
│   │   ├── pages/                 # Strony (landing, dashboard, mint)
│   │   ├── hooks/                 # Web3 hooks
│   │   └── utils/                 # Helpers
│   └── public/                    # Statyczne pliki
├── backend/            # Node.js + TypeScript
│   ├── src/
│   │   ├── auth/                  # SIWE/JWT
│   │   ├── api/                   # REST endpoints
│   │   ├── indexer/               # Event indexer
│   │   ├── quests/                # Quest system
│   │   └── middleware/            # Rate limiting, anti-bot
│   └── tests/                     # Testy backend
├── game/               # Unity WebGL lub Three.js
│   ├── assets/                    # Grafika, modele, dźwięki
│   ├── scripts/                   # Game logic
│   └── scenes/                    # PvE/PvP mapy
├── docs/               # Dokumentacja
│   ├── TOKENOMICS.md             # Ekonomia tokena
│   ├── CONTRACTS.md              # Dokumentacja kontraktów
│   ├── API.md                    # API backend
│   └── SECURITY.md               # Bezpieczeństwo
└── config/             # Konfiguracje
    ├── networks.json             # Sieci blockchain
    ├── deployment.json           # Adresy kontraktów
    └── game-config.json          # Parametry gry
```

## 💰 Tokenomics

### $ASSASSIN Token (ERC20)
- **Total Supply:** 1 000 000 000 (1B)
- **Vesting:**
  - Team: cliff 12 miesięcy, vest 36 miesięcy
  - Public: 5-10% unlock, reszta vest
  - Marketing: transze miesięczne
  - Staking: emisja z dziennym capem

### NFT Collections
- **Weapon NFT:** 600-1000 szt. (fala 1)
- **Mount NFT:** 500-1000 szt. (sezonowe dropy)
- **Skin NFT:** 500-1000 szt. (sezonowe dropy)
- **Baseuri:** IPFS
- **Royalties:** 2.5-5% (EIP-2981)

### Marketplace
- **Trading Fee:** 2-5% (konfigurowalne)
- **Royalties:** 2.5-5% dla twórców
- **Mechanizm:** EIP-712 signed offers

### Staking
- **Input:** NFT (weapon/mount/skin)
- **Output:** $ASSASSIN tokens
- **Lock Period:** 30-90 dni
- **APY:** Dynamiczne (spada przy wysokim stake)
- **Cap:** Dzienny limit emisji

### Token Sinks (kontrola inflacji)
- Craft/upgrade equipment
- Repair durability
- Reroll statystyk
- Entry fees (turnieje, rajdy)
- Marketplace fees

## 🔐 Bezpieczeństwo

### Smart Contracts
- ✅ Minimalny upgrade surface (UUPS tylko gdy konieczne)
- ✅ Role-based access control (RBAC)
- ✅ Timelock na krytyczne funkcje
- ✅ CEI pattern (Checks-Effects-Interactions)
- ✅ Reentrancy guards
- ✅ Fuzz testing (Foundry)
- ✅ Invariant tests
- ✅ Slither + Solhint
- ✅ Audyt przed mainnet/TGE

### Backend
- ✅ SIWE authentication
- ✅ Rate limiting (per IP, per user)
- ✅ Device fingerprinting
- ✅ Cooldowns na akcje
- ✅ Signed actions (EIP-712)
- ✅ Input validation
- ✅ SQL injection prevention
- ✅ XSS protection

### Monitoring
- ✅ Event indexer z alertami
- ✅ Anomaly detection (spike mint/transfer)
- ✅ Economic metrics tracking
- ✅ Bot farm detection

## 📊 KPI Kontrolne

### Produkt
- Czas do pierwszej walki: < 2 min
- Crash rate: < 1% sesji
- Retention: D1/D7/D30

### Ekonomia
- Dzienny cap emisji
- Monitor inflacji tokena
- GMV/fee marketplace
- ARPPU/ARPU
- TVL staking

### Wzrost
- MAU (Monthly Active Users)
- DAU (Daily Active Users)
- Conversion rate
- Churn rate

## 🚀 Quick Start

### Wymagania
- Node.js 18+
- Foundry lub Hardhat
- Docker (opcjonalnie)
- PostgreSQL (backend)

### Instalacja

1. **Klonowanie repo:**
```bash
git clone https://github.com/hetwerk1943/Minecraft-Server-Automation.git
cd Minecraft-Server-Automation/web3-game
```

2. **Setup kontraktów:**
```bash
cd contracts
forge install
forge build
forge test
```

3. **Setup frontend:**
```bash
cd frontend
npm install
npm run dev
```

4. **Setup backend:**
```bash
cd backend
npm install
cp .env.example .env
npm run dev
```

### Deployment Testnet

1. **Deploy kontraktów:**
```bash
cd contracts
# Edytuj .env z private key
forge script script/Deploy.s.sol --rpc-url $TESTNET_RPC --broadcast
```

2. **Verify kontraktów:**
```bash
forge verify-contract $CONTRACT_ADDRESS src/AssassinToken.sol:AssassinToken --chain-id $CHAIN_ID
```

3. **Run backend indexer:**
```bash
cd backend
npm run indexer
```

## 🎮 Gameplay Loop

1. **Wejście:** Wallet connect (SIWE)
2. **Wybór:** Postać + ekwipunek (NFT)
3. **Misja:** PvE lub PvP
4. **Loot:** Tokeny + XP + items
5. **Progres:** Upgrade statystyk
6. **Craft:** Token sink (spalanie)
7. **Trade:** Marketplace
8. **Stake:** NFT → passive income

## 📈 Strumienie Przychodu

### Rok 1 (szacunki)
1. **Premint NFT:** ~200k zł
2. **Dropy sezonowe:** 50-200k zł per drop
3. **Battle Pass:** 300-500k zł/rok
4. **Marketplace fee:** 24-180k zł/rok (przy GMV 100-300k zł/mies.)
5. **Turnieje:** 2-5k zł/sezon
6. **Premium lootboxy:** z disclosure (nie główny strumień)

**Łącznie:** ~900k - 1.5M zł/rok (przy założeniu sukcesu)

## ⚠️ Ryzyka i Mitigacje

### Ryzyko: Niski popyt
**Mitigacja:**
- Małe fale mintu (600-800 zamiast 1000)
- Tiered pricing
- Partnerstwa cross-IP
- Community building przed minting

### Ryzyko: Inflacja tokena
**Mitigacja:**
- Twarde capy dzienne na emisję
- Dynamic reward rate
- Token sinki w grze
- Kontrola podaży NFT

### Ryzyko: Boty/Sybil
**Mitigacja:**
- Podpisane akcje (EIP-712)
- Cooldowns
- Device fingerprinting
- Captcha przy claimach
- Monitoring anomalii

### Ryzyko: Regulacje
**Mitigacja:**
- Utility-first (nie investment)
- Brak obietnicy zysku
- Jasne disclosure lootboxów
- VRF dla RNG
- Konsultacje prawne

### Ryzyko: Fee za wysokie
**Mitigacja:**
- Zacząć od 2-5%
- Testować elastycznie
- Nie przekraczać 5% (dusi GMV)

## 🛠️ Stack Technologiczny

### Smart Contracts
- **Framework:** Foundry (lub Hardhat)
- **Language:** Solidity 0.8.20+
- **Testing:** Forge fuzz, invariant tests
- **Security:** Slither, Solhint
- **Standards:** ERC20, ERC721, EIP-712, EIP-2981

### Frontend
- **Framework:** Next.js 14+ (App Router)
- **Web3:** wagmi + viem (lub ethers.js)
- **Styling:** Tailwind CSS
- **State:** Zustand (lub Redux)
- **Testing:** Playwright/Cypress

### Backend
- **Runtime:** Node.js 18+ / TypeScript
- **Framework:** Express.js (lub Fastify)
- **Database:** PostgreSQL + Prisma ORM
- **Auth:** SIWE + JWT
- **Indexer:** ethers.js event listeners
- **Cache:** Redis
- **Testing:** Jest

### Game
**Opcja A: Unity WebGL**
- Cross-platform
- Rich asset store
- C# scripting
- WebGL build

**Opcja B: Three.js**
- Pure web
- TypeScript
- Lżejsze
- Łatwiejsza integracja z frontend

### Infrastructure
- **Hosting:** Vercel (frontend), Render/Railway (backend)
- **RPC:** Alchemy, Infura
- **IPFS:** Pinata, NFT.Storage
- **Monitoring:** Datadog, Sentry
- **CI/CD:** GitHub Actions

## 📚 Dokumentacja Szczegółowa

Szczegółowe dokumenty znajdują się w folderze `/docs`:

- **[TOKENOMICS.md](./docs/TOKENOMICS.md)** - Pełna ekonomia tokena
- **[CONTRACTS.md](./docs/CONTRACTS.md)** - Specyfikacja kontraktów
- **[API.md](./docs/API.md)** - Backend API endpoints
- **[SECURITY.md](./docs/SECURITY.md)** - Security best practices
- **[DEPLOYMENT.md](./docs/DEPLOYMENT.md)** - Deployment guide
- **[TESTING.md](./docs/TESTING.md)** - Testing strategy

## 🤝 Kontakt i Wsparcie

- **Author:** Dominik Opałka
- **Email:** hetwerk1943@gmail.com
- **Repository:** https://github.com/hetwerk1943/Minecraft-Server-Automation

## 📄 Licencja

© 2025 Dominik Opałka. All Rights Reserved.

---

**Status:** 🚧 W rozwoju - Faza M1 (MVP)
