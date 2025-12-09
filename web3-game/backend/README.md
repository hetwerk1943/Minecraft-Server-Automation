# Assassin Game - Backend

## 📋 Przegląd

Backend API dla gry Assassin zbudowany w Node.js + TypeScript + Express + Prisma.

## 🚀 Quick Start

### Instalacja

```bash
cd web3-game/backend
npm install
```

### Konfiguracja

Skopiuj `.env.example` do `.env`:

```bash
cp .env.example .env
```

Edytuj `.env`:
```env
# Database
DATABASE_URL="postgresql://user:password@localhost:5432/assassin_game"

# JWT
JWT_SECRET="your-super-secret-key-min-256-bits"

# Blockchain
RPC_URL="https://polygon-rpc.com"
CHAIN_ID=137

# Contracts
ASSASSIN_TOKEN_ADDRESS="0x..."
WEAPON_NFT_ADDRESS="0x..."
MARKETPLACE_ADDRESS="0x..."
STAKING_ADDRESS="0x..."

# Redis
REDIS_URL="redis://localhost:6379"

# API
PORT=3001
NODE_ENV=development
```

### Database Setup

```bash
# Generate Prisma Client
npm run prisma:generate

# Run migrations
npm run prisma:migrate

# (Opcjonalnie) Open Prisma Studio
npm run prisma:studio
```

### Development

```bash
npm run dev
```

API dostępne na [http://localhost:3001](http://localhost:3001)

## 📁 Struktura

```
src/
├── index.ts              # Entry point
├── config/              # Konfiguracje
│   ├── database.ts      # Prisma
│   ├── redis.ts         # Redis
│   └── contracts.ts     # Contract ABIs
├── middleware/          # Express middleware
│   ├── auth.ts          # JWT verification
│   ├── rateLimit.ts     # Rate limiting
│   ├── validate.ts      # Input validation
│   └── errorHandler.ts  # Error handling
├── routes/              # API routes
│   ├── auth.ts          # SIWE authentication
│   ├── user.ts          # User profile
│   ├── nft.ts           # NFT operations
│   ├── marketplace.ts   # Marketplace
│   ├── staking.ts       # Staking
│   └── quest.ts         # Quests
├── controllers/         # Request handlers
├── services/            # Business logic
├── models/              # Data models
├── indexer/             # Blockchain event indexer
├── utils/               # Helpers
└── types/               # TypeScript types
```

## 🔐 Authentication (SIWE)

### Login Flow

```typescript
// POST /api/auth/nonce
// Returns: { nonce: "random-string" }

// POST /api/auth/verify
// Body: { message, signature }
// Returns: { token: "jwt-token", user }
```

### Protected Routes

```typescript
import { authMiddleware } from '@/middleware/auth';

router.get('/profile', authMiddleware, async (req, res) => {
  const user = req.user; // Populated by middleware
  res.json({ user });
});
```

## 📡 API Endpoints

### Auth
- `POST /api/auth/nonce` - Get nonce for SIWE
- `POST /api/auth/verify` - Verify signature & get JWT
- `POST /api/auth/logout` - Logout (blacklist token)

### User
- `GET /api/user/profile` - Get user profile
- `PUT /api/user/profile` - Update profile
- `GET /api/user/stats` - Get user stats
- `GET /api/user/inventory` - Get NFT inventory

### NFT
- `GET /api/nft/:collection/:tokenId` - Get NFT metadata
- `POST /api/nft/mint` - Mint NFT (admin)
- `GET /api/nft/owned/:address` - Get owned NFTs

### Marketplace
- `GET /api/marketplace/offers` - Get active offers
- `POST /api/marketplace/create-offer` - Create offer (returns signature data)
- `POST /api/marketplace/cancel-offer` - Cancel offer

### Staking
- `GET /api/staking/stakes/:address` - Get user stakes
- `GET /api/staking/rewards/:collection/:tokenId` - Get pending rewards
- `GET /api/staking/stats` - Get staking stats (TVL, APY, etc.)

### Quest
- `GET /api/quest/available` - Get available quests
- `POST /api/quest/start` - Start quest
- `POST /api/quest/complete` - Complete quest
- `GET /api/quest/progress` - Get quest progress

## 🔧 Services

### UserService

```typescript
import { UserService } from '@/services/UserService';

const userService = new UserService();

// Create or update user
await userService.upsert(address, data);

// Get profile
const profile = await userService.getProfile(address);

// Update stats
await userService.updateStats(address, { xp: 100 });
```

### NFTService

```typescript
import { NFTService } from '@/services/NFTService';

const nftService = new NFTService();

// Get NFT metadata (IPFS)
const metadata = await nftService.getMetadata(tokenURI);

// Get owned NFTs
const nfts = await nftService.getOwnedNFTs(address);
```

### QuestService

```typescript
import { QuestService } from '@/services/QuestService';

const questService = new QuestService();

// Get available quests
const quests = await questService.getAvailable(userId);

// Complete quest
await questService.complete(userId, questId);
```

## 📊 Event Indexer

Indexer śledzi eventy z blockchain i zapisuje w bazie.

```typescript
// Start indexer
npm run indexer
```

**Monitorowane eventy:**
- `Sale` (Marketplace)
- `Staked` / `Unstaked` (Staking)
- `Transfer` (NFT)
- `TokensMinted` (AssassinToken)

```typescript
// src/indexer/index.ts
marketplace.on('Sale', async (collection, tokenId, seller, buyer, price) => {
  await prisma.sale.create({
    data: {
      collection,
      tokenId: tokenId.toString(),
      seller,
      buyer,
      price: price.toString(),
      timestamp: new Date(),
    },
  });
});
```

## 🧪 Testing

```bash
# Unit tests
npm test

# Watch mode
npm run test:watch

# Coverage
npm run test:coverage
```

## 🚀 Deployment

### Production Build

```bash
npm run build
npm start
```

### Docker

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
RUN npm run prisma:generate

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/prisma ./prisma
EXPOSE 3001
CMD ["npm", "start"]
```

### Environment Variables

Production:
- `NODE_ENV=production`
- `DATABASE_URL` (production DB)
- `JWT_SECRET` (rotate!)
- `REDIS_URL` (production Redis)
- Contract addresses (mainnet)

## 📈 Monitoring

### Logging (Winston)

```typescript
import { logger } from '@/utils/logger';

logger.info('User minted NFT', { address, tokenId });
logger.error('Failed to process quest', { error, userId });
```

### Metrics

```typescript
import { metrics } from '@/utils/metrics';

metrics.increment('api.requests');
metrics.timing('db.query', duration);
metrics.gauge('staking.tvl', tvl);
```

## 🔐 Security

- ✅ SIWE authentication
- ✅ JWT with expiry
- ✅ Rate limiting
- ✅ Input validation
- ✅ SQL injection prevention (Prisma)
- ✅ XSS prevention
- ✅ CORS configured
- ✅ Helmet security headers

## 📚 Dokumentacja

- [Express Docs](https://expressjs.com/)
- [Prisma Docs](https://www.prisma.io/docs)
- [ethers.js Docs](https://docs.ethers.org/)
- [Redis Docs](https://redis.io/docs/)

---

© 2025 Dominik Opałka. All Rights Reserved.
