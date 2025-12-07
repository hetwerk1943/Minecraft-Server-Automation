# MonetizationSetup.ps1
# Skrypt do konfiguracji systemu monetyzacji serwera Minecraft
# © 2025 Dominik Opałka

param(
    [string]$ServerPath = ".\MinecraftServer",
    [string]$DonationSystem = "Tebex",
    [switch]$EnableVIPSystem,
    [switch]$EnableEconomy,
    [string]$CurrencyName = "Monety"
)

function Write-ColorMessage {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function New-PluginsDirectory {
    param([string]$ServerPath)
    
    try {
        $pluginsPath = Join-Path $ServerPath "plugins"
        if (-not (Test-Path $pluginsPath)) {
            New-Item -ItemType Directory -Path $pluginsPath -Force | Out-Null
            Write-ColorMessage "Utworzono katalog plugins: $pluginsPath" "Green"
        }
        return $pluginsPath
    }
    catch {
        Write-ColorMessage "Błąd podczas tworzenia katalogu plugins: $_" "Red"
        return $null
    }
}

function New-VIPConfiguration {
    param(
        [string]$PluginsPath
    )
    
    try {
        Write-ColorMessage "Konfiguracja systemu VIP..." "Cyan"
        
        $vipConfigPath = Join-Path $PluginsPath "VIPSystem"
        New-Item -ItemType Directory -Path $vipConfigPath -Force | Out-Null
        
        $configFile = Join-Path $vipConfigPath "config.yml"
        @"
# Konfiguracja systemu VIP
vip-tiers:
  bronze:
    duration-days: 30
    price: 15.00
    permissions:
      - 'essentials.kit.bronze'
      - 'essentials.back'
      - 'minecraft.command.fly'
    commands:
      - 'give {player} diamond 5'
    prefix: '&6[VIP Bronze]&r'
    
  silver:
    duration-days: 30
    price: 30.00
    permissions:
      - 'essentials.kit.silver'
      - 'essentials.back'
      - 'essentials.tpa'
      - 'minecraft.command.fly'
      - 'essentials.speed'
    commands:
      - 'give {player} diamond 10'
      - 'give {player} emerald 5'
    prefix: '&7[VIP Silver]&r'
    
  gold:
    duration-days: 30
    price: 50.00
    permissions:
      - 'essentials.kit.gold'
      - 'essentials.back'
      - 'essentials.tpa'
      - 'minecraft.command.fly'
      - 'essentials.speed'
      - 'essentials.god'
      - 'worldedit.use'
    commands:
      - 'give {player} diamond 20'
      - 'give {player} emerald 10'
      - 'give {player} netherite_ingot 2'
    prefix: '&e[VIP Gold]&r'
    
  platinum:
    duration-days: 90
    price: 120.00
    permissions:
      - 'essentials.*'
      - 'minecraft.command.*'
      - 'worldedit.*'
    commands:
      - 'give {player} diamond_block 10'
      - 'give {player} emerald_block 5'
      - 'give {player} netherite_ingot 5'
    prefix: '&b[VIP Platinum]&r'

# Ustawienia automatycznego odnowienia
auto-renewal:
  enabled: true
  reminder-days: 7
  discount-percent: 10

# Powiadomienia
notifications:
  on-purchase: true
  on-expiry: true
  broadcast-purchase: true
"@ | Out-File -FilePath $configFile -Encoding UTF8
        
        Write-ColorMessage "Utworzono konfigurację VIP: $configFile" "Green"
        Write-ColorMessage "  - Bronze VIP: 15 PLN/miesiąc" "White"
        Write-ColorMessage "  - Silver VIP: 30 PLN/miesiąc" "White"
        Write-ColorMessage "  - Gold VIP: 50 PLN/miesiąc" "White"
        Write-ColorMessage "  - Platinum VIP: 120 PLN/3 miesiące" "White"
        
        return $true
    }
    catch {
        Write-ColorMessage "Błąd podczas konfiguracji VIP: $_" "Red"
        return $false
    }
}

function New-EconomyConfiguration {
    param(
        [string]$PluginsPath,
        [string]$CurrencyName
    )
    
    try {
        Write-ColorMessage "Konfiguracja systemu ekonomii..." "Cyan"
        
        $economyConfigPath = Join-Path $PluginsPath "Economy"
        New-Item -ItemType Directory -Path $economyConfigPath -Force | Out-Null
        
        $configFile = Join-Path $economyConfigPath "config.yml"
        @"
# Konfiguracja systemu ekonomii
economy:
  currency-name: '$CurrencyName'
  currency-symbol: '⛃'
  starting-balance: 1000
  max-balance: 1000000000
  
  # Zarobki za aktywności
  earnings:
    block-break:
      stone: 0.5
      coal_ore: 2.0
      iron_ore: 5.0
      gold_ore: 10.0
      diamond_ore: 50.0
      ancient_debris: 100.0
    
    mob-kill:
      zombie: 5.0
      skeleton: 5.0
      creeper: 8.0
      spider: 5.0
      enderman: 15.0
      wither_skeleton: 25.0
      blaze: 20.0
      ender_dragon: 5000.0
      wither: 3000.0
    
    fishing:
      fish: 3.0
      treasure: 50.0
      junk: 0.5
    
    playtime:
      per-minute: 1.0
      daily-bonus: 500.0
      weekly-bonus: 3500.0

  # System handlu
  trading:
    tax-percent: 5.0
    max-trade-amount: 100000
    
  # Sklep serwera
  server-shop:
    prices:
      # Bloki budowlane
      stone: 0.5
      cobblestone: 0.3
      dirt: 0.1
      oak_log: 2.0
      glass: 1.5
      
      # Żywność
      bread: 5.0
      cooked_beef: 10.0
      golden_apple: 100.0
      
      # Narzędzia i bronie
      iron_sword: 50.0
      iron_pickaxe: 60.0
      diamond_sword: 500.0
      diamond_pickaxe: 600.0
      
      # Zbroja
      iron_helmet: 80.0
      iron_chestplate: 120.0
      diamond_helmet: 800.0
      diamond_chestplate: 1200.0
      
      # Specjalne przedmioty
      enchanted_book: 200.0
      totem_of_undying: 5000.0
      elytra: 10000.0
      
  # Aukcje
  auctions:
    enabled: true
    duration-hours: 24
    fee-percent: 3.0
    max-items: 5
    
  # Loterie
  lottery:
    enabled: true
    ticket-price: 100.0
    jackpot-percentage: 70
    draw-interval-hours: 168  # Tygodniowo
    max-tickets-per-player: 50

# System rankingów
leaderboard:
  enabled: true
  update-interval-minutes: 30
  top-players: 10
  rewards:
    top1: 10000
    top2: 5000
    top3: 2500
    top4-10: 1000
"@ | Out-File -FilePath $configFile -Encoding UTF8
        
        Write-ColorMessage "Utworzono konfigurację ekonomii: $configFile" "Green"
        Write-ColorMessage "  - Waluta: $CurrencyName" "White"
        Write-ColorMessage "  - Startowy balans: 1000" "White"
        Write-ColorMessage "  - Zarobki za aktywności włączone" "White"
        Write-ColorMessage "  - Sklep serwera skonfigurowany" "White"
        Write-ColorMessage "  - System aukcji i loterii włączony" "White"
        
        return $true
    }
    catch {
        Write-ColorMessage "Błąd podczas konfiguracji ekonomii: $_" "Red"
        return $false
    }
}

function New-DonationConfiguration {
    param(
        [string]$PluginsPath,
        [string]$DonationSystem
    )
    
    try {
        Write-ColorMessage "Konfiguracja systemu donacji ($DonationSystem)..." "Cyan"
        
        $donationConfigPath = Join-Path $PluginsPath "Donations"
        New-Item -ItemType Directory -Path $donationConfigPath -Force | Out-Null
        
        $configFile = Join-Path $donationConfigPath "config.yml"
        @"
# Konfiguracja systemu donacji - $DonationSystem
donation-system:
  provider: '$DonationSystem'
  
  # Pakiety donacji
  packages:
    starter-pack:
      name: 'Pakiet Startowy'
      price: 10.00
      description: 'Idealny start na serwerze!'
      items:
        - 'diamond 10'
        - 'emerald 5'
        - 'golden_apple 3'
      commands:
        - 'give {player} diamond 10'
        - 'give {player} emerald 5'
        - 'give {player} golden_apple 3'
        - 'eco give {player} 5000'
      
    builder-pack:
      name: 'Pakiet Budowniczego'
      price: 20.00
      description: 'Wszystko czego potrzebujesz do budowy!'
      items:
        - 'oak_log 320'
        - 'stone 640'
        - 'glass 256'
        - 'iron_block 64'
      commands:
        - 'give {player} oak_log 320'
        - 'give {player} stone 640'
        - 'give {player} glass 256'
        - 'give {player} iron_block 64'
        - 'eco give {player} 10000'
      
    pvp-pack:
      name: 'Pakiet PvP'
      price: 25.00
      description: 'Zdominuj pole bitwy!'
      items:
        - 'diamond_sword (Sharpness V) 1'
        - 'diamond_helmet (Protection IV) 1'
        - 'diamond_chestplate (Protection IV) 1'
        - 'diamond_leggings (Protection IV) 1'
        - 'diamond_boots (Protection IV) 1'
        - 'golden_apple 16'
      commands:
        - 'give {player} diamond_sword{Enchantments:[{id:sharpness,lvl:5}]} 1'
        - 'eco give {player} 15000'
      
    ultimate-pack:
      name: 'Pakiet Ultimate'
      price: 50.00
      description: 'Najlepszy pakiet na serwerze!'
      items:
        - 'Wszystko z poprzednich pakietów'
        - 'netherite_sword (Sharpness V, Mending) 1'
        - 'elytra 1'
        - 'totem_of_undying 3'
      commands:
        - 'give {player} netherite_sword{Enchantments:[{id:sharpness,lvl:5},{id:mending,lvl:1}]} 1'
        - 'give {player} elytra 1'
        - 'give {player} totem_of_undying 3'
        - 'eco give {player} 50000'
        - 'lp user {player} permission set vip.ultimate true'
  
  # Cele donacji (goal tracking)
  goals:
    monthly-goal:
      target: 1000.00
      description: 'Cel miesięczny serwera'
      rewards:
        - 'Podwójne XP dla wszystkich przez tydzień'
        - 'Specjalny event PvP'
        - 'Nowa mapa survival'
    
    upgrade-goal:
      target: 2500.00
      description: 'Upgrade serwera do lepszego hostingu'
      rewards:
        - 'Zwiększona pojemność serwera do 100 graczy'
        - 'Lepsze TPS i wydajność'
        - 'Nowe mini-gry'
  
  # Rangi donatorów
  donor-ranks:
    total-100:
      rank: 'Supporter'
      prefix: '&a[Supporter]&r'
      permissions:
        - 'donor.supporter'
    
    total-250:
      rank: 'Patron'
      prefix: '&b[Patron]&r'
      permissions:
        - 'donor.patron'
        - 'essentials.fly'
    
    total-500:
      rank: 'Benefactor'
      prefix: '&d[Benefactor]&r'
      permissions:
        - 'donor.benefactor'
        - 'essentials.*'
    
    total-1000:
      rank: 'Legend'
      prefix: '&6[Legend]&r'
      permissions:
        - 'donor.legend'
        - '*'
  
  # Ustawienia
  settings:
    broadcast-purchases: true
    thank-you-message: true
    email-receipts: true
    webhook-url: 'https://discord.com/api/webhooks/YOUR_WEBHOOK'
"@ | Out-File -FilePath $configFile -Encoding UTF8
        
        Write-ColorMessage "Utworzono konfigurację donacji: $configFile" "Green"
        Write-ColorMessage "  - System: $DonationSystem" "White"
        Write-ColorMessage "  - Pakiety: Starter (10 PLN), Builder (20 PLN), PvP (25 PLN), Ultimate (50 PLN)" "White"
        Write-ColorMessage "  - Cele miesięczne skonfigurowane" "White"
        Write-ColorMessage "  - Rangi donatorów: Supporter, Patron, Benefactor, Legend" "White"
        
        return $true
    }
    catch {
        Write-ColorMessage "Błąd podczas konfiguracji systemu donacji: $_" "Red"
        return $false
    }
}

function New-MonetizationGuide {
    param([string]$ServerPath)
    
    try {
        $guidePath = Join-Path $ServerPath "MONETIZATION_GUIDE.md"
        @"
# Przewodnik Monetyzacji Serwera Minecraft

## 🎯 Strategia Monetyzacji

### 1. System VIP (Subskrypcje)
Miesięczne/kwartalne subskrypcje z różnymi poziomami:
- **Bronze VIP**: 15 PLN/miesiąc - Podstawowe udogodnienia
- **Silver VIP**: 30 PLN/miesiąc - Rozszerzone uprawnienia
- **Gold VIP**: 50 PLN/miesiąc - Premium features
- **Platinum VIP**: 120 PLN/3 miesiące - Wszystko + rabat

**Przewidywany przychód**: 100 graczy × 10% konwersja × średnio 30 PLN = 300 PLN/miesiąc

### 2. Pakiety Donacji (Jednorazowe)
- **Pakiet Startowy**: 10 PLN - Dobry początek dla nowych graczy
- **Pakiet Budowniczego**: 20 PLN - Dla miłośników budowania
- **Pakiet PvP**: 25 PLN - Dla walczących graczy
- **Pakiet Ultimate**: 50 PLN - Wszystko co najlepsze

**Przewidywany przychód**: 100 graczy × 15% × średnio 20 PLN = 300 PLN/miesiąc

### 3. System Ekonomii In-Game
- Gracze zarabiają walutę za grę
- Mogą kupować items/rangi za in-game currency
- Opcja zakupu waluty za real money (0.01 PLN = 100 monet)

**Przewidywany przychód**: 100 graczy × 20% × średnio 15 PLN = 300 PLN/miesiąc

### 4. Cele Donacji (Stretch Goals)
- Cel miesięczny: 1000 PLN → Specjalne eventy
- Cel upgrade: 2500 PLN → Lepszy hosting
- Społeczność angażuje się w osiąganie celów

### 5. Rangi Donatorów (Lifetime)
- Po przekroczeniu określonej kwoty łącznych donacji
- Prestiżowe rangi bez wygasania
- Motywacja do większych wpłat

## 💰 Szacowane Przychody

### Miesięczne (100 aktywnych graczy):
- VIP Subskrypcje: 300-500 PLN
- Pakiety Donacji: 200-400 PLN
- Waluta In-Game: 150-300 PLN
- **RAZEM: 650-1200 PLN/miesiąc**

### Roczne (wzrost do 200 graczy):
- **RAZEM: 15,000-30,000 PLN/rok**

## 📊 Koszty Operacyjne

### Miesięczne:
- Hosting serwera: 100-200 PLN
- Domena: 5-10 PLN
- Panel donacji (Tebex): 0 PLN (prowizja 5-8%)
- Discord Nitro Boost: 20 PLN
- **RAZEM: 125-230 PLN/miesiąc**

### Zysk netto:
**525-970 PLN/miesiąc** (6,300-11,640 PLN/rok)

## 🎮 Najlepsze Praktyki

### 1. Balance Pay-to-Win
- ❌ NIE sprzedawaj items które dają nieuczciwą przewagę
- ✅ Sprzedawaj convenience (TP, fly, kits)
- ✅ Sprzedawaj cosmetyki i prestiż
- ✅ Sprzedawaj economic boosts (nie game-breaking)

### 2. Zgodność z EULA Minecraft
- Items można dawać tylko jako nagrody
- Permissions i convenience są OK
- Nie sprzedawaj gameplay advantages

### 3. Przejrzystość
- Jasne opisy co gracz dostaje
- Pokazuj cele i postępy
- Dziękuj publicznie donatorom

### 4. Engagement
- Regularne eventy dla VIPów
- Specjalne strefy dla donatorów
- Dedykowany support dla płacących

### 5. Marketing
- Discord z kanałami dla VIPów
- Social media presence
- Influencer partnerships
- Referral program

## 🚀 Implementacja

### Faza 1 (Tydzień 1):
1. Skonfiguruj pluginy VIP i ekonomii
2. Ustaw pakiety donacji w Tebex
3. Przetestuj wszystkie transakcje

### Faza 2 (Tydzień 2):
1. Ogłoś system monetyzacji
2. Uruchom promocję startową (-20%)
3. Zbierz feedback od community

### Faza 3 (Miesięczne):
1. Monitoruj statystyki sprzedaży
2. Optymalizuj ceny i oferty
3. Dodawaj nowe pakiety sezonowe

## 📈 Tracking Metryk

Śledź te wskaźniki:
- Conversion rate (ile % graczy płaci)
- ARPU (Average Revenue Per User)
- LTV (Lifetime Value per player)
- Churn rate (ile % graczy odchodzi)
- Retention rate (ile % zostaje)

## ⚠️ Aspekty Prawne

### Wymagane w Polsce:
1. Działalność gospodarcza lub wpisy do KRS
2. Fakturowanie (jeśli przychody > 50% minimalnej krajowej rocznie)
3. Polityka prywatności i regulamin
4. Zgodność z RODO
5. Ochrona małoletnich

### Podatki:
- Podatek dochodowy: 19% (liniowy) lub skala 17%/32%
- VAT: Zwolnienie do 200k PLN rocznego obrotu
- ZUS: Preferencyjne stawki dla startujących (2 lata)

**WAŻNE**: Skonsultuj się z księgowym!

## 🎁 Przykładowe Promocje

### Launch Promotion:
- -30% na wszystkie pakiety przez pierwszy tydzień
- Gratis Bronze VIP dla pierwszych 50 donatorów

### Sezonowe:
- Black Friday: -50% na Platinum VIP
- Wakacje: 2+1 gratis na pakiety
- Święta: Specjalne festive pakiety

### Eventy:
- Double donation weekends
- Raffles dla donatorów
- Exclusive tournaments z nagrodami

---

© 2025 Dominik Opałka. All Rights Reserved.
"@ | Out-File -FilePath $guidePath -Encoding UTF8
        
        Write-ColorMessage "Utworzono przewodnik monetyzacji: $guidePath" "Green"
        return $true
    }
    catch {
        Write-ColorMessage "Błąd podczas tworzenia przewodnika: $_" "Red"
        return $false
    }
}

# Główna logika skryptu
try {
    Write-ColorMessage "`n=== Minecraft Server Monetization Setup ===" "Cyan"
    Write-ColorMessage "Ścieżka serwera: $ServerPath" "White"
    Write-ColorMessage "System donacji: $DonationSystem" "White"
    Write-ColorMessage "System VIP: $(if ($EnableVIPSystem) { 'Włączony' } else { 'Wyłączony' })" "White"
    Write-ColorMessage "System ekonomii: $(if ($EnableEconomy) { 'Włączony' } else { 'Wyłączony' })`n" "White"
    
    # Sprawdzenie katalogu serwera
    if (-not (Test-Path $ServerPath)) {
        throw "Katalog serwera nie istnieje: $ServerPath. Uruchom najpierw MinecraftServerSetup.ps1"
    }
    
    # Utworzenie katalogu plugins
    $pluginsPath = New-PluginsDirectory -ServerPath $ServerPath
    if (-not $pluginsPath) {
        throw "Nie udało się utworzyć katalogu plugins"
    }
    
    # Konfiguracja VIP
    if ($EnableVIPSystem) {
        if (-not (New-VIPConfiguration -PluginsPath $pluginsPath)) {
            throw "Nie udało się skonfigurować systemu VIP"
        }
    }
    
    # Konfiguracja ekonomii
    if ($EnableEconomy) {
        if (-not (New-EconomyConfiguration -PluginsPath $pluginsPath -CurrencyName $CurrencyName)) {
            throw "Nie udało się skonfigurować systemu ekonomii"
        }
    }
    
    # Konfiguracja donacji
    if (-not (New-DonationConfiguration -PluginsPath $pluginsPath -DonationSystem $DonationSystem)) {
        throw "Nie udało się skonfigurować systemu donacji"
    }
    
    # Utworzenie przewodnika monetyzacji
    if (-not (New-MonetizationGuide -ServerPath $ServerPath)) {
        Write-ColorMessage "Ostrzeżenie: Nie udało się utworzyć przewodnika monetyzacji" "Yellow"
    }
    
    Write-ColorMessage "`n=== Konfiguracja monetyzacji zakończona! ===" "Green"
    Write-ColorMessage "`nNastępne kroki:" "Cyan"
    Write-ColorMessage "1. Zainstaluj pluginy: Vault, EssentialsX, LuckPerms" "White"
    Write-ColorMessage "2. Zarejestruj się na $DonationSystem (tebex.io)" "White"
    Write-ColorMessage "3. Skonfiguruj webhook Discord dla powiadomień" "White"
    Write-ColorMessage "4. Przeczytaj MONETIZATION_GUIDE.md w katalogu serwera" "White"
    Write-ColorMessage "5. Przetestuj wszystkie pakiety przed uruchomieniem" "White"
    Write-ColorMessage "`nSzacowane przychody: 650-1200 PLN/miesiąc (100 graczy)" "Yellow"
    Write-ColorMessage "Zysk netto: 525-970 PLN/miesiąc" "Green"
}
catch {
    Write-ColorMessage "`n=== Błąd podczas konfiguracji monetyzacji ===" "Red"
    Write-ColorMessage "Szczegóły: $_" "Red"
    Write-ColorMessage $_.ScriptStackTrace "Red"
    exit 1
}
