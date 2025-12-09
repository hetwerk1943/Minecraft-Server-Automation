# Assassin Game - Frontend

## 📋 Przegląd

Frontend aplikacji Assassin Game zbudowany w Next.js 14 z Web3 integracją (wagmi + RainbowKit).

## 🚀 Quick Start

### Instalacja

```bash
cd web3-game/frontend
npm install
```

### Konfiguracja

Skopiuj `.env.example` do `.env.local`:

```bash
cp .env.example .env.local
```

Edytuj `.env.local`:
```env
NEXT_PUBLIC_ALCHEMY_ID=your_alchemy_id
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_walletconnect_id
NEXT_PUBLIC_CHAIN_ID=137
NEXT_PUBLIC_API_URL=http://localhost:3001
```

### Development

```bash
npm run dev
```

Otwórz [http://localhost:3000](http://localhost:3000)

### Build

```bash
npm run build
npm start
```

## 📁 Struktura

```
src/
├── app/                 # Next.js App Router
│   ├── page.tsx        # Landing page
│   ├── dashboard/      # Dashboard (protected)
│   ├── mint/           # NFT minting
│   ├── marketplace/    # Marketplace
│   └── staking/        # Staking interface
├── components/         # React komponenty
│   ├── ui/            # Podstawowe UI (Button, Card, etc.)
│   ├── web3/          # Web3 komponenty (ConnectButton, etc.)
│   └── game/          # Game-specific komponenty
├── hooks/             # Custom React hooks
│   ├── useAuth.ts     # Authentication
│   ├── useContract.ts # Contract interactions
│   └── useNFT.ts      # NFT operations
├── lib/               # Utilities
│   ├── wagmi.ts       # Wagmi config
│   ├── contracts.ts   # Contract ABIs & addresses
│   └── api.ts         # API client
└── styles/            # Global styles
```

## 🔧 Technologie

- **Framework:** Next.js 14 (App Router)
- **Web3:** wagmi + viem + RainbowKit
- **State:** Zustand
- **Styling:** Tailwind CSS
- **Animations:** Framer Motion
- **API Client:** Axios
- **Forms:** React Hook Form + Zod
- **Testing:** Playwright

## 🎨 Komponenty

### ConnectButton

```tsx
import { ConnectButton } from '@/components/web3/ConnectButton';

<ConnectButton />
```

### NFTCard

```tsx
import { NFTCard } from '@/components/game/NFTCard';

<NFTCard
  collection="0x..."
  tokenId={42}
  image="ipfs://..."
  name="Shadow Blade #42"
  rarity="Legendary"
/>
```

### StakeModal

```tsx
import { StakeModal } from '@/components/game/StakeModal';

<StakeModal
  nft={nft}
  onStake={handleStake}
/>
```

## 🔐 Authentication (SIWE)

```typescript
import { useAuth } from '@/hooks/useAuth';

function Profile() {
  const { login, logout, user } = useAuth();
  
  return (
    <button onClick={login}>
      Sign In with Ethereum
    </button>
  );
}
```

## 📡 API Integration

```typescript
import { api } from '@/lib/api';

// Get user profile
const profile = await api.get('/user/profile');

// Complete quest
await api.post('/quest/complete', { questId });

// Get NFT metadata
const metadata = await api.get(`/nft/${collection}/${tokenId}`);
```

## 🎮 Game Integration

```typescript
// Unity WebGL
import { Unity, useUnityContext } from "react-unity-webgl";

function GameView() {
  const { unityProvider, loadingProgression } = useUnityContext({
    loaderUrl: "/game/Build/game.loader.js",
    dataUrl: "/game/Build/game.data",
    frameworkUrl: "/game/Build/game.framework.js",
    codeUrl: "/game/Build/game.wasm",
  });

  return <Unity unityProvider={unityProvider} />;
}
```

## 🧪 Testing

```bash
# Unit tests
npm test

# E2E tests
npm run test:e2e

# Type checking
npm run type-check
```

## 🚀 Deployment

### Vercel (Recommended)

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel
```

### Environment Variables na Vercel

Dodaj w dashboard:
- `NEXT_PUBLIC_ALCHEMY_ID`
- `NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID`
- `NEXT_PUBLIC_CHAIN_ID`
- `NEXT_PUBLIC_API_URL`

### Docker

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
EXPOSE 3000
CMD ["npm", "start"]
```

## 📚 Dokumentacja

- [Next.js Docs](https://nextjs.org/docs)
- [wagmi Docs](https://wagmi.sh/)
- [RainbowKit Docs](https://www.rainbowkit.com/docs)
- [Tailwind CSS](https://tailwindcss.com/docs)

---

© 2025 Dominik Opałka. All Rights Reserved.
