# Monetization Guide

This document describes the built-in monetization configuration system
(`MonetizationSetup.ps1` / `scripts/MonetizationSetup.ps1`).

> **Compliance notice:** Always review the
> [Minecraft Commercial Usage Guidelines](https://www.minecraft.net/en-us/usage-guidelines)
> before enabling paid features.  Consult a legal/tax professional for your jurisdiction.

## Overview

The monetization setup script generates configuration templates for:

- **VIP rank system** – 4 tiers (Bronze / Silver / Gold / Platinum)
- **Donation packages** – one-time purchase bundles
- **In-game economy** – currency, shop prices, auctions
- **Lifetime donor ranks** – permanent recognitions
- **Monthly donation goals**
- **Tebex / BuyCraft integration guidance**

## Quick start

```powershell
.\scripts\MonetizationSetup.ps1 `
    -ServerPath   'D:\Servers\Minecraft' `
    -DonationSystem 'Tebex' `
    -EnableVIPSystem `
    -EnableEconomy `
    -CurrencyName  'Diamonds'
```

## VIP system

| Tier | Suggested Price | Key Perks |
|------|----------------|-----------|
| Bronze | 15 PLN/mo | /fly in lobby, colored name |
| Silver | 30 PLN/mo | /fly everywhere, extra homes |
| Gold | 60 PLN/mo | Custom particles, priority queue |
| Platinum | 120 PLN/mo | All perks + exclusive access |

> **Rule:** Sell *convenience and cosmetics*, never pay-to-win gameplay advantages.

## Donation packages

| Package | Price | Contents |
|---------|-------|----------|
| Starter | 10 PLN | Starter kit, 1 000 in-game currency |
| Builder | 20 PLN | Extended kit, 3 000 currency, creative plots |
| PvP | 30 PLN | PvP kit, special weapons (cosmetic) |
| Ultimate | 50 PLN | All kits + 10 000 currency |

## In-game economy

Suggested currency income per activity:

| Activity | Currency reward |
|----------|----------------|
| Playing 1 hour | 100 |
| Killing a player | 50 |
| Mining 64 blocks | 25 |
| Voting | 200 |

## Revenue estimates (100 active players)

| Revenue stream | Conversion | Monthly estimate |
|----------------|-----------|-----------------|
| VIP subscriptions (10%) | 10 players × 30 PLN avg | 300 PLN |
| One-time donations (15%) | 15 players × 20 PLN avg | 300 PLN |
| Currency purchases (20%) | 20 players × 15 PLN avg | 300 PLN |
| **Total** | | **~900 PLN** |

Estimated costs: ~150 PLN/mo (hosting + payment processor fees).  
**Net: ~750 PLN/mo** at 100 players.

## Tebex integration

1. Register at [tebex.io](https://www.tebex.io).
2. Connect your Minecraft server using the Tebex plugin.
3. Create packages matching the tiers above.
4. Pass your Tebex store URL in the configuration.

## Legal checklist (Poland)

- [ ] Register a sole trader (JDG) or company.
- [ ] Issue invoices / receipts for all transactions.
- [ ] Publish a Privacy Policy (GDPR / RODO compliant).
- [ ] Publish Terms of Service and Refund Policy.
- [ ] Collect parental consent for users under 16.
- [ ] Consult an accountant for VAT and income tax obligations.
