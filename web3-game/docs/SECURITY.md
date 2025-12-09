# Security Best Practices - Assassin Game

## 🔐 Przegląd Bezpieczeństwa

Dokument opisuje praktyki bezpieczeństwa dla projektu Assassin Game Web3.

## Smart Contracts

### Access Control

#### Role-Based Access Control (RBAC)
```solidity
// OpenZeppelin AccessControl
bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

// Grant roles
_grantRole(DEFAULT_ADMIN_ROLE, admin);
_grantRole(MINTER_ROLE, stakingContract);
```

**Best Practices:**
- ✅ Użyj multi-sig dla DEFAULT_ADMIN_ROLE
- ✅ Minimalizuj liczbę adresów z MINTER_ROLE
- ✅ Timelock na krytyczne operacje
- ✅ Audytuj wszystkie role przed deploymentem

#### Multi-Sig Wallet

**Rekomendacje:**
- **Gnosis Safe** (zalecane)
- **2-of-3** dla testnet
- **3-of-5** dla mainnet (team + auditor + community rep)

### Reentrancy Protection

```solidity
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Marketplace is ReentrancyGuard {
    function buy(...) external payable nonReentrant {
        // Safe from reentrancy
    }
}
```

**Wzorce:**
- ✅ ReentrancyGuard na wszystkich payable funkcjach
- ✅ Checks-Effects-Interactions pattern
- ✅ Transfer ETH na końcu funkcji

### Integer Overflow/Underflow

**Solidity 0.8+:**
- ✅ Built-in overflow checks (nie potrzeba SafeMath)
- ✅ Explicit unchecked dla gas optimization (tylko jeśli pewny)

```solidity
// Safe (default)
uint256 result = a + b; // reverts on overflow

// Unsafe (only if you know what you're doing)
unchecked {
    uint256 result = a + b;
}
```

### Front-Running Protection

#### EIP-712 Signed Offers (Marketplace)

```solidity
// Off-chain signing
bytes32 structHash = keccak256(abi.encode(OFFER_TYPEHASH, offer));
bytes32 hash = _hashTypedDataV4(structHash);
bytes signature = wallet.signTypedData(domain, types, offer);

// On-chain verification
address signer = hash.recover(signature);
require(signer == offer.seller, "Invalid signature");
```

**Zalety:**
- ✅ Brak on-chain order book
- ✅ Gratis listing (tylko podpis off-chain)
- ✅ Deadline enforcement
- ✅ Nonce system (prevent replay)

#### Commit-Reveal (dla NFT mint, jeśli potrzebne)

```solidity
// Phase 1: Commit
function commit(bytes32 commitment) external {
    commitments[msg.sender] = commitment;
}

// Phase 2: Reveal (po X blocks)
function reveal(uint256 value, bytes32 salt) external {
    require(keccak256(abi.encode(value, salt)) == commitments[msg.sender]);
    // Mint based on value
}
```

### Pausable Contracts

```solidity
import "@openzeppelin/contracts/security/Pausable.sol";

function pause() external onlyRole(PAUSER_ROLE) {
    _pause();
}

function unpause() external onlyRole(PAUSER_ROLE) {
    _unpause();
}
```

**Kiedy pausować:**
- 🚨 Exploit wykryty
- 🚨 Anomalia ekonomiczna (nagły spike)
- 🚨 Bug w kontrakcie

**Uwaga:** Używaj oszczędnie, by nie stracić zaufania community.

### Gas Optimization vs Security

**Nigdy nie poświęcaj security dla gas savings:**
- ❌ Removing require checks
- ❌ Unchecked math bez pewności
- ❌ Removing events (potrzebne do auditu)

**OK optymalizacje:**
- ✅ Packing structs
- ✅ Calldata vs memory
- ✅ Custom errors
- ✅ Batch operations

## Backend Security

### Authentication

#### SIWE (Sign-In With Ethereum)

```typescript
import { SiweMessage } from 'siwe';

// Client creates message
const message = new SiweMessage({
  domain: window.location.host,
  address: account,
  statement: 'Sign in to Assassin Game',
  uri: window.location.origin,
  version: '1',
  chainId: 1,
  nonce: generateNonce(),
});

// Server verifies
const fields = await siweMessage.verify({ signature });
```

**Best Practices:**
- ✅ Nonce z entropią (crypto.randomBytes)
- ✅ Expiry time (np. 5 min)
- ✅ Domain validation
- ✅ Signature verification on backend

#### JWT Tokens

```typescript
import jwt from 'jsonwebtoken';

// Generate
const token = jwt.sign(
  { address, role },
  process.env.JWT_SECRET!,
  { expiresIn: '7d' }
);

// Verify
const decoded = jwt.verify(token, process.env.JWT_SECRET!);
```

**Best Practices:**
- ✅ Strong secret (minimum 256 bits)
- ✅ Short expiry (7 days max)
- ✅ Refresh tokens dla długich sesji
- ✅ Blacklist dla logout

### Rate Limiting

```typescript
import rateLimit from 'express-rate-limit';

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 min
  max: 100, // 100 requests
  message: 'Too many requests',
});

app.use('/api/', limiter);
```

**Per-Endpoint Limits:**
- `/api/mint`: 10 per hour
- `/api/claim`: 10 per day
- `/api/quest/complete`: 50 per day

### Input Validation

```typescript
import { body, validationResult } from 'express-validator';

app.post('/api/mint',
  body('collection').isEthereumAddress(),
  body('amount').isInt({ min: 1, max: 10 }),
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    // Process...
  }
);
```

**Validation Rules:**
- ✅ Ethereum addresses
- ✅ Token amounts (min/max)
- ✅ String lengths
- ✅ Enum values

### SQL Injection Prevention

```typescript
// ✅ Good (Parameterized queries with Prisma)
const user = await prisma.user.findUnique({
  where: { address: userAddress }
});

// ❌ Bad (Never do this!)
const user = await db.query(`SELECT * FROM users WHERE address = '${userAddress}'`);
```

**ORM Benefits:**
- ✅ Auto-escaping
- ✅ Type safety
- ✅ Query builder
- ✅ Migrations

### XSS Prevention

```typescript
import DOMPurify from 'isomorphic-dompurify';

// Sanitize user input
const clean = DOMPurify.sanitize(userInput);

// React escapes by default, but be careful with dangerouslySetInnerHTML
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(html) }} />
```

### CSRF Protection

```typescript
import csrf from 'csurf';

const csrfProtection = csrf({ cookie: true });
app.use(csrfProtection);

// Include in forms
<input type="hidden" name="_csrf" value={csrfToken} />
```

## Frontend Security

### Wallet Connection

```typescript
import { useAccount, useConnect } from 'wagmi';

function ConnectButton() {
  const { connect, connectors } = useConnect();
  
  return (
    <button onClick={() => connect({ connector: connectors[0] })}>
      Connect Wallet
    </button>
  );
}
```

**Best Practices:**
- ✅ Prompt user before signing
- ✅ Show clear message content
- ✅ Verify chain ID
- ✅ Handle errors gracefully

### Transaction Signing

```typescript
// Always show user what they're signing
const { data, signTypedData } = useSignTypedData({
  domain: {
    name: 'Assassin Marketplace',
    version: '1',
    chainId: 137,
    verifyingContract: marketplaceAddress,
  },
  types: {
    Offer: [
      { name: 'collection', type: 'address' },
      { name: 'tokenId', type: 'uint256' },
      // ...
    ],
  },
  value: offer,
});
```

**Checklist przed signing:**
- ✅ Pokaż wszystkie parametry
- ✅ Highlight critical values (price, amount)
- ✅ Confirm button z captcha (dla dużych transakcji)

### Environment Variables

```bash
# .env.local (NEVER commit!)
NEXT_PUBLIC_ALCHEMY_ID=xxx
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=xxx
JWT_SECRET=xxx
DATABASE_URL=xxx
```

**Rules:**
- ✅ `NEXT_PUBLIC_` dla client-side (non-sensitive)
- ✅ No prefix dla server-side (sensitive)
- ✅ `.env.local` w `.gitignore`
- ✅ `.env.example` w repo (bez wartości)

## Monitoring & Alerts

### Contract Events

```typescript
// Monitor critical events
marketplace.on('Sale', (collection, tokenId, seller, buyer, price) => {
  // Alert if price > threshold
  if (price > ethers.utils.parseEther('100')) {
    sendDiscordAlert(`Large sale: ${price} ETH`);
  }
});
```

### Anomaly Detection

```typescript
// Track metrics
const metrics = {
  mintsLastHour: 0,
  avgMintPrice: 0,
  totalVolume: 0,
};

// Alert on spikes
if (mintsLastHour > 100) {
  alert('Potential bot activity');
}
```

### Logging

```typescript
import winston from 'winston';

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' }),
  ],
});

logger.info('User minted NFT', { address, tokenId });
```

## Incident Response

### Security Incident Playbook

1. **Detect**
   - Monitoring alerts
   - Community reports
   - Audit findings

2. **Assess**
   - Severity (Critical/High/Medium/Low)
   - Impact (users affected, funds at risk)
   - Exploitability

3. **Contain**
   - Pause affected contracts
   - Block malicious addresses
   - Disable vulnerable endpoints

4. **Communicate**
   - Discord/Twitter announcement
   - Transparent about issue
   - Estimated fix time

5. **Fix**
   - Deploy patch (if upgradeable)
   - Or deploy new contract + migration
   - Verify fix

6. **Post-Mortem**
   - Root cause analysis
   - Improvements to prevent recurrence
   - Update docs

### Emergency Contacts

```
Security Lead: [Discord: @security]
Dev Lead: [Discord: @dev]
Community Manager: [Discord: @cm]
Auditor: [Email: audit@firm.com]
```

## Pre-Launch Checklist

### Smart Contracts
- [ ] All tests pass (100% coverage)
- [ ] Fuzz tests (10k+ runs)
- [ ] Slither/Mythril analysis
- [ ] Manual code review
- [ ] External audit (2+ firms)
- [ ] Bug bounty program active
- [ ] Multi-sig configured
- [ ] Timelock on admin functions

### Backend
- [ ] SIWE authentication tested
- [ ] Rate limiting configured
- [ ] Input validation comprehensive
- [ ] SQL injection tests pass
- [ ] XSS prevention verified
- [ ] CORS properly configured
- [ ] API keys rotated
- [ ] Logs & monitoring active

### Frontend
- [ ] Wallet connection secure
- [ ] Transaction prompts clear
- [ ] Error handling robust
- [ ] No sensitive data in client
- [ ] CSP headers configured
- [ ] HTTPS enforced
- [ ] Dependencies updated

### Infrastructure
- [ ] Backups automated
- [ ] Disaster recovery plan
- [ ] Incident response playbook
- [ ] Team training complete
- [ ] Community guidelines published

## Bug Bounty Program

### Scope
- ✅ Smart contracts
- ✅ Backend API
- ✅ Frontend (XSS, CSRF)
- ❌ Social engineering
- ❌ DDoS

### Rewards
- **Critical:** 10,000 - 50,000 USD
- **High:** 5,000 - 10,000 USD
- **Medium:** 1,000 - 5,000 USD
- **Low:** 100 - 1,000 USD

### Platform
- [Immunefi](https://immunefi.com/)
- [HackerOne](https://www.hackerone.com/)

---

© 2025 Dominik Opałka. All Rights Reserved.

**Remember: Security is not a one-time task, it's an ongoing process.**
