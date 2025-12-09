# Przykładowe Konfiguracje
## Example Configurations for Minecraft Server

Ten katalog zawiera przykładowe konfiguracje dla różnych typów serwerów Minecraft.

---

## 📁 Dostępne Przykłady

### 1. [basic/](basic/) - Podstawowy Serwer Vanilla
Prosty serwer vanilla bez modyfikacji.
- **Graczy:** 5-10
- **RAM:** 2 GB
- **Pluginy:** Brak
- **Cel:** Testowanie, mała grupa znajomych

### 2. [survival/](survival/) - Serwer Survival
Klasyczny tryb przetrwania z podstawowymi pluginami.
- **Graczy:** 20-50
- **RAM:** 4-8 GB
- **Pluginy:** Essentials, LuckPerms, CoreProtect
- **Cel:** Community survival server

### 3. [creative/](creative/) - Serwer Creative
Serwer dla budowniczych i twórców.
- **Graczy:** 10-30
- **RAM:** 2-4 GB
- **Pluginy:** WorldEdit, VoxelSniper, Essentials
- **Cel:** Budowanie, creative projects

### 4. [pvp/](pvp/) - Serwer PvP
Serwer z naciskiem na walki PvP.
- **Graczy:** 30-100
- **RAM:** 6-12 GB
- **Pluginy:** PvP plugins, Areny, Rankingi
- **Cel:** Competitive PvP

### 5. [monetization/](monetization/) - Serwer z Monetyzacją
Konfiguracja dla serwera komercyjnego.
- **Graczy:** 50-200
- **RAM:** 8-16 GB
- **Pluginy:** Tebex, VIP system, Economy
- **Cel:** Profit-oriented server

### 6. [production/](production/) - Konfiguracja Produkcyjna
Enterprise-ready configuration dla dużych serwerów.
- **Graczy:** 100-500+
- **RAM:** 16-32 GB
- **Pluginy:** Full stack, monitoring, security
- **Cel:** Professional server network

---

## 🚀 Jak Użyć

### Metoda 1: Kopiowanie Plików

```powershell
# 1. Wybierz przykład
cd examples/survival

# 2. Skopiuj server.properties
Copy-Item server.properties C:\MinecraftServer\server.properties

# 3. Skopiuj plugins configs (jeśli są)
Copy-Item plugins\* C:\MinecraftServer\plugins\ -Recurse

# 4. Uruchom serwer
cd ..\..
.\StartServer.ps1 -ServerPath C:\MinecraftServer
```

### Metoda 2: Użycie jako Template

```powershell
# 1. Stwórz nowy serwer z szablonem
.\MinecraftServerSetup.ps1 -ServerPath C:\NewServer

# 2. Zastosuj konfigurację z przykładu
$ExampleConfig = Get-Content examples\survival\server.properties
$ExampleConfig | Out-File C:\NewServer\server.properties

# 3. Dostosuj do swoich potrzeb
notepad C:\NewServer\server.properties

# 4. Uruchom
.\StartServer.ps1 -ServerPath C:\NewServer
```

### Metoda 3: Interaktywny Setup (TODO)

```powershell
# Przyszła funkcja - automatyczny wizard
.\SetupWizard.ps1
# Wybierz typ serwera: [1] Basic [2] Survival [3] Creative [4] PvP [5] Monetization
```

---

## ⚙️ Dostosowywanie Konfiguracji

### Podstawowe Ustawienia

```properties
# server.properties - kluczowe parametry

# Nazwa świata
level-name=world

# Port serwera
server-port=25565

# Maksymalna liczba graczy
max-players=20

# Tryb gry
gamemode=survival

# Difficulty
difficulty=normal

# PvP on/off
pvp=true

# View distance (6-32)
view-distance=10
```

### Wydajność

```properties
# Dla lepszej wydajności:
view-distance=8              # Niższy = lepiej
simulation-distance=8        # Niższy = lepiej
entity-broadcast-range-percentage=100

# Dla lepszej grafiki:
view-distance=16             # Wyższy = ładniej
simulation-distance=10       # Wyższy = więcej akcji
```

### Bezpieczeństwo

```properties
# Bezpieczna konfiguracja:
online-mode=true             # ZAWSZE true dla produkcji
prevent-proxy-connections=true
white-list=false             # Włącz dla prywatnego serwera
enforce-whitelist=false      # Włącz gdy whitelist=true
```

---

## 📊 Porównanie Konfiguracji

| Feature | Basic | Survival | Creative | PvP | Monetization | Production |
|---------|-------|----------|----------|-----|--------------|------------|
| Graczy | 5-10 | 20-50 | 10-30 | 30-100 | 50-200 | 100-500+ |
| RAM | 2GB | 4-8GB | 2-4GB | 6-12GB | 8-16GB | 16-32GB+ |
| Pluginy | 0 | 5-10 | 5-8 | 10-15 | 15-20 | 20-30+ |
| Complexity | ⭐ | ⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Cost | 20 PLN | 50 PLN | 40 PLN | 100 PLN | 150 PLN | 300+ PLN |
| Setup Time | 15 min | 30 min | 30 min | 1-2 hr | 2-4 hr | 4-8 hr |

---

## 🛠️ Wymagane Pluginy

### Survival Server Essentials:
```
1. EssentialsX - Podstawowe komendy i funkcje
2. LuckPerms - Zarządzanie uprawnieniami
3. CoreProtect - Logowanie i rollback
4. WorldGuard - Ochrona regionów
5. Vault - API dla ekonomii
```

### PvP Server Essentials:
```
1. KitPvP - System kitów
2. CombatTagPlus - Anti-logout
3. SkillAPI - System umiejętności
4. Arenas - System aren
5. Leaderboards - Rankingi
```

### Monetization Server Essentials:
```
1. Tebex/BuyCraft - Donations
2. LuckPerms - VIP permissions
3. EssentialsX - Economy
4. ChestShop - Player shops
5. AuctionHouse - Aukcje
```

---

## 📝 Checklist Przed Uruchomieniem

```markdown
Dla każdej konfiguracji, sprawdź:

☐ server.properties
  ☐ server-port ustawiony
  ☐ max-players odpowiedni
  ☐ online-mode=true
  ☐ motd ustawiony
  
☐ JVM Settings
  ☐ Xmx = wystarczająca RAM
  ☐ Xms = połowa Xmx
  ☐ Optymalne flagi JVM
  
☐ Pluginy
  ☐ Wszystkie pobrane
  ☐ Kompatybilne wersje
  ☐ Configs skonfigurowane
  ☐ Dependencies zainstalowane
  
☐ Bezpieczeństwo
  ☐ Whitelist (jeśli potrzeba)
  ☐ Firewall skonfigurowany
  ☐ Backupy ustawione
  ☐ EULA zaakceptowane
  
☐ Network
  ☐ Porty otwarte
  ☐ DNS skonfigurowany
  ☐ DDoS protection (dla produkcji)
```

---

## 🎯 Best Practices

### Development vs Production

**Development:**
```properties
# Szybkie testy, debug mode
view-distance=6
max-players=10
white-list=true
generate-structures=false  # Szybsze generowanie
```

**Production:**
```properties
# Optymalna wydajność i experience
view-distance=10
max-players=100
white-list=false
generate-structures=true
```

### Resource Optimization

```yaml
Low-end Server (2GB RAM):
  view-distance: 6
  simulation-distance: 4
  max-players: 10
  entity-limits: Aggressive
  
Mid-range Server (8GB RAM):
  view-distance: 10
  simulation-distance: 8
  max-players: 50
  entity-limits: Moderate
  
High-end Server (16GB+ RAM):
  view-distance: 12
  simulation-distance: 10
  max-players: 200
  entity-limits: Relaxed
```

---

## 🔗 Przydatne Linki

**Server Software:**
- Vanilla: https://www.minecraft.net/en-us/download/server
- Paper: https://papermc.io/
- Spigot: https://www.spigotmc.org/
- Purpur: https://purpurmc.org/

**Plugins:**
- SpigotMC: https://www.spigotmc.org/resources/
- Bukkit: https://dev.bukkit.org/
- Hangar (Paper): https://hangar.papermc.io/

**Tools:**
- Tebex: https://tebex.io/
- NameMC: https://namemc.com/
- MCVersions: https://mcversions.net/

**Communities:**
- r/admincraft: https://www.reddit.com/r/admincraft/
- SpigotMC Forums: https://www.spigotmc.org/forums/
- Paper Discord: https://discord.gg/papermc

---

## 💡 Tips & Tricks

### Testing Configuration

```powershell
# Test konfiguracji bez uruchamiania na żywo:

# 1. Uruchom w trybie dev
.\StartServer.ps1 -ServerPath "C:\TestServer" -MaxMemory 2048

# 2. Sprawdź logi
Get-Content "C:\TestServer\logs\latest.log" -Tail 20

# 3. Test konektywności
Test-NetConnection -ComputerName localhost -Port 25565

# 4. Jeśli OK, skopiuj na produkcję
Copy-Item "C:\TestServer\server.properties" "C:\ProductionServer\"
```

### Configuration Backup

```powershell
# Zawsze backupuj przed zmianami:
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
Copy-Item "C:\MinecraftServer\server.properties" `
    "C:\ConfigBackups\server.properties.$Timestamp"
```

---

**Autor:** GitHub Copilot Agent  
**Wersja:** 1.0  
**Data:** 2025-12-09

Masz pytania? Zobacz [TROUBLESHOOTING.md](../TROUBLESHOOTING.md) lub otwórz issue na GitHubie!
