# Minecraft-Server-Automation
„PowerShell Omega scripts + configs for automated Minecraft server management and monetization"

## 📋 Opis

Kompletny zestaw skryptów PowerShell do profesjonalnego zarządzania serwerem Minecraft z systemem monetyzacji. Skrypty obejmują:

### 🎮 Podstawowe Zarządzanie
- Automatyczną konfigurację i instalację serwera
- Uruchamianie serwera z konfigurowalnymi parametrami
- Tworzenie kopii zapasowych z automatycznym zarządzaniem
- Aktualizację wersji serwera

### 💰 System Monetyzacji
- System VIP z 4 poziomami (Bronze, Silver, Gold, Platinum)
- Pakiety donacji (Starter, Builder, PvP, Ultimate)
- System ekonomii in-game z walutą, sklepem i aukcjami
- Rangi donatorów lifetime (Supporter, Patron, Benefactor, Legend)
- Cele donacji (monthly goals, upgrade goals)
- Integracja z Tebex/BuyCraft

### 📊 Monitoring i Analityka
- Ciągłe monitorowanie wydajności serwera
- Tracking graczy i ich aktywności
- Automatyczne raporty dzienne i miesięczne
- Integracja z Discord webhooks
- System nagród dla najaktywniejszych graczy
- Metryki biznesowe i szacowanie przychodów

## 🚀 Szybki Start

### Wymagania
- PowerShell 5.1 lub nowszy (zalecane PowerShell 7.x)
- Java 17 lub nowsza (dla Minecraft 1.18+)
- System Windows lub Linux/MacOS z PowerShell Core

### Instalacja

1. **Sklonuj repozytorium:**
   ```bash
   git clone https://github.com/hetwerk1943/Minecraft-Server-Automation.git
   cd Minecraft-Server-Automation
   ```

2. **Konfiguracja serwera:**
   ```powershell
   .\MinecraftServerSetup.ps1 -ServerPath "C:\MinecraftServer" -MaxMemory 4096
   ```

3. **Pobierz server.jar:**
   - Odwiedź https://www.minecraft.net/en-us/download/server
   - Pobierz najnowszą wersję server.jar
   - Umieść plik w katalogu serwera

4. **Uruchom serwer:**
   ```powershell
   .\StartServer.ps1 -ServerPath "C:\MinecraftServer" -MaxMemory 4096
   ```

## 📜 Dostępne Skrypty

### 🎮 Podstawowe Zarządzanie

#### MinecraftServerSetup.ps1
Skrypt do inicjalnej konfiguracji serwera Minecraft.

**Parametry:**
- `-ServerPath` - Ścieżka do katalogu serwera (domyślnie: `.\MinecraftServer`)
- `-ServerVersion` - Wersja serwera do zainstalowania (domyślnie: `latest`)
- `-ServerPort` - Port serwera (domyślnie: `25565`)
- `-MaxMemory` - Maksymalna ilość pamięci RAM w MB (domyślnie: `2048`)

**Przykład:**
```powershell
.\MinecraftServerSetup.ps1 -ServerPath "D:\Servers\Minecraft" -MaxMemory 8192 -ServerPort 25565
```

### StartServer.ps1
Skrypt do uruchamiania serwera Minecraft.

**Parametry:**
- `-ServerPath` - Ścieżka do katalogu serwera (domyślnie: `.\MinecraftServer`)
- `-MaxMemory` - Maksymalna ilość pamięci RAM w MB (domyślnie: `2048`)
- `-MinMemory` - Minimalna ilość pamięci RAM w MB (domyślnie: `1024`)
- `-NoGUI` - Uruchom serwer bez interfejsu graficznego

**Przykład:**
```powershell
.\StartServer.ps1 -ServerPath "D:\Servers\Minecraft" -MaxMemory 8192 -NoGUI
```

### BackupServer.ps1
Skrypt do tworzenia kopii zapasowych serwera.

**Parametry:**
- `-ServerPath` - Ścieżka do katalogu serwera (domyślnie: `.\MinecraftServer`)
- `-BackupPath` - Ścieżka do katalogu kopii zapasowych (domyślnie: `.\Backups`)
- `-MaxBackups` - Maksymalna liczba przechowywanych kopii (domyślnie: `10`)

**Przykład:**
```powershell
.\BackupServer.ps1 -ServerPath "D:\Servers\Minecraft" -BackupPath "E:\Backups" -MaxBackups 20
```

### UpdateServer.ps1
Skrypt do aktualizacji serwera Minecraft.

**Parametry:**
- `-ServerPath` - Ścieżka do katalogu serwera (domyślnie: `.\MinecraftServer`)
- `-BackupPath` - Ścieżka do katalogu kopii zapasowych (domyślnie: `.\Backups`)
- `-Version` - Wersja do aktualizacji (domyślnie: `latest`)
- `-SkipBackup` - Pomiń tworzenie kopii zapasowej przed aktualizacją

**Przykład:**
```powershell
.\UpdateServer.ps1 -ServerPath "D:\Servers\Minecraft" -Version "latest"
```

### 💰 Monetyzacja

#### MonetizationSetup.ps1
Skrypt do konfiguracji kompletnego systemu monetyzacji serwera.

**Parametry:**
- `-ServerPath` - Ścieżka do katalogu serwera (domyślnie: `.\MinecraftServer`)
- `-DonationSystem` - System donacji: Tebex, BuyCraft (domyślnie: `Tebex`)
- `-EnableVIPSystem` - Włącz system VIP
- `-EnableEconomy` - Włącz system ekonomii
- `-CurrencyName` - Nazwa waluty serwera (domyślnie: `Monety`)

**Przykład:**
```powershell
.\MonetizationSetup.ps1 -ServerPath "D:\Servers\Minecraft" -EnableVIPSystem -EnableEconomy -CurrencyName "Diamenty"
```

**Funkcje:**
- 4 poziomy VIP (15-120 PLN)
- 4 pakiety donacji (10-50 PLN)
- System ekonomii z zarobkami za aktywności
- Sklep serwera z cenami
- System aukcji i loterii
- Rangi donatorów lifetime
- Cele miesięczne i upgrade goals
- Przewodnik monetyzacji z szacowanymi przychodami

**Szacowane przychody:** 650-1200 PLN/miesiąc (100 graczy)

#### ServerMonitoring.ps1
Skrypt do zaawansowanego monitorowania serwera i generowania raportów.

**Parametry:**
- `-ServerPath` - Ścieżka do katalogu serwera (domyślnie: `.\MinecraftServer`)
- `-LogPath` - Ścieżka do logów (domyślnie: `.\Logs`)
- `-MonitorIntervalSeconds` - Interwał monitorowania w sekundach (domyślnie: `60`)
- `-EnableDiscordWebhook` - Włącz powiadomienia Discord
- `-DiscordWebhookUrl` - URL webhooka Discord
- `-GenerateReports` - Generuj raport dzienny

**Przykład - Ciągłe monitorowanie:**
```powershell
.\ServerMonitoring.ps1 -ServerPath "D:\Servers\Minecraft" -MonitorIntervalSeconds 30 -EnableDiscordWebhook -DiscordWebhookUrl "https://discord.com/api/webhooks/..."
```

**Przykład - Generowanie raportu:**
```powershell
.\ServerMonitoring.ps1 -ServerPath "D:\Servers\Minecraft" -GenerateReports
```

**Monitorowane metryki:**
- Status serwera (online/offline)
- Liczba graczy online
- Użycie pamięci RAM
- Użycie CPU
- Wolne miejsce na dysku
- Aktywność graczy (dołączenia/wyjścia)
- TPS (ticks per second)

#### PlayerManagement.ps1
Skrypt do zarządzania graczami i analityki ich aktywności.

**Parametry:**
- `-ServerPath` - Ścieżka do katalogu serwera (domyślnie: `.\MinecraftServer`)
- `-Action` - Akcja do wykonania: stats, top, report, rewards
- `-PlayerName` - Nazwa gracza (dla akcji stats)
- `-TopPlayersCount` - Liczba topowych graczy (domyślnie: `10`)

**Przykład - Statystyki gracza:**
```powershell
.\PlayerManagement.ps1 -Action stats -PlayerName "Steve123"
```

**Przykład - Top 10 graczy:**
```powershell
.\PlayerManagement.ps1 -Action top -TopPlayersCount 10
```

**Przykład - Raport aktywności:**
```powershell
.\PlayerManagement.ps1 -Action report
```

**Przykład - Generowanie nagród:**
```powershell
.\PlayerManagement.ps1 -Action rewards -TopPlayersCount 10
```

**Funkcje:**
- Tracking czasu gry, śmierci, zabójstw
- Statystyki wykopanych/umieszczonych bloków
- Rankingi najaktywniejszych graczy
- KDR (Kill-Death Ratio)
- Automatyczne generowanie nagród dla topowych graczy
- Raporty aktywności z insights biznesowymi
- Szacowanie potencjału monetyzacji

## 🔧 Konfiguracja

### server.properties
Główny plik konfiguracyjny serwera jest tworzony automatycznie przez `MinecraftServerSetup.ps1`. 
Możesz edytować go ręcznie aby dostosować ustawienia serwera.

### eula.txt
Skrypt automatycznie akceptuje EULA (End User License Agreement). 
Uruchamiając serwer, zgadzasz się na warunki EULA Minecraft.

## 📦 Automatyzacja

### Zaplanowane Kopie Zapasowe (Windows Task Scheduler)
```powershell
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\path\to\BackupServer.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At 3am
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "MinecraftBackup" -Description "Daily Minecraft Server Backup"
```

### Automatyczne Uruchamianie (Linux systemd)
Utwórz plik `/etc/systemd/system/minecraft.service`:
```ini
[Unit]
Description=Minecraft Server
After=network.target

[Service]
Type=simple
User=minecraft
WorkingDirectory=/opt/minecraft
ExecStart=/usr/bin/pwsh /opt/minecraft/StartServer.ps1 -NoGUI
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

## 🛡️ Bezpieczeństwo

- Wszystkie skrypty używają bloków `try-catch` dla obsługi błędów
- Kolorowe komunikaty dla lepszej czytelności
- Automatyczne tworzenie kopii zapasowych przed aktualizacją
- Walidacja plików przed operacjami
- Brak podatności command injection
- Bezpieczne zarządzanie hasłami i kluczami API

## 💼 Przewodnik Biznesowy

### Szacowane Przychody Miesięczne (100 aktywnych graczy)

**System VIP (10% konwersja):**
- 10 graczy × średnio 30 PLN = **300 PLN**

**Pakiety Donacji (15% konwersja jednorazowa):**
- 15 graczy × średnio 20 PLN = **300 PLN**

**Waluta In-Game (20% konwersja):**
- 20 graczy × średnio 15 PLN = **300 PLN**

**Razem: 900 PLN/miesiąc** (10,800 PLN/rok)

### Koszty Miesięczne
- Hosting: 100-200 PLN
- Domena: 5-10 PLN
- Prowizja Tebex: 5-8%
- Discord Nitro: 20 PLN
- **Razem: ~150 PLN/miesiąc**

### Zysk Netto
**750 PLN/miesiąc** (9,000 PLN/rok) przy 100 graczach

**Przy 200 graczach: ~1,800 PLN/miesiąc** (21,600 PLN/rok)

### ROI (Return on Investment)
- Setup time: 5-10 godzin
- Break-even: 1-2 miesiące
- ROI roczny: 500-1000%

## 📊 Metryki do Śledzenia

- **Conversion Rate**: % graczy którzy płacą
- **ARPU**: Average Revenue Per User
- **LTV**: Lifetime Value gracza
- **Churn Rate**: % graczy którzy odchodzą
- **Retention Rate**: % graczy którzy zostają
- **Daily Active Users (DAU)**
- **Monthly Active Users (MAU)**

## 🎯 Strategia Wzrostu

### Faza 1: Launch (Miesiąc 1-2)
- Setup wszystkich skryptów
- Promocja startowa -30%
- Budowanie community
- Target: 50-100 graczy

### Faza 2: Growth (Miesiąc 3-6)
- Optymalizacja ofert
- Eventy tematyczne
- Marketing w social media
- Target: 150-200 graczy

### Faza 3: Scale (Miesiąc 7-12)
- Dodatkowe serwery (skyblock, factions)
- Influencer partnerships
- Seasonal promotions
- Target: 300-500 graczy

### Faza 4: Maturity (Rok 2+)
- Network serwerów
- Profesjonalny staff
- Konkursy i turnieje
- Target: 500-1000+ graczy

## ⚖️ Aspekty Prawne (Polska)

**Wymagane:**
1. Działalność gospodarcza (JDG) lub wpis do KRS
2. Fakturowanie transakcji
3. Polityka prywatności (RODO)
4. Regulamin serwera i sklepu
5. Zgoda rodziców dla nieletnich

**Podatki:**
- PIT: 19% (liniowy) lub 17%/32% (skala)
- VAT: Zwolnienie do 200k PLN obrotu
- ZUS: Preferencyjne stawki (2 lata)

**WAŻNE:** Skonsultuj się z księgowym przed uruchomieniem!

## 🎁 Najlepsze Praktyki Monetyzacji

### ✅ DO:
- Sprzedawaj convenience (TP, fly, kits)
- Oferuj cosmetics i prestiż
- Dawaj economic boosts
- Bądź transparentny z cenami
- Dziękuj donatorom publicznie
- Organizuj eventy dla VIPów

### ❌ NIE:
- Nie sprzedawaj pay-to-win items
- Nie łam EULA Minecraft
- Nie ignoruj community feedback
- Nie zaniedbuj graczy non-premium
- Nie ukrywaj rzeczywistych kosztów

## 📝 Licencja

© 2025 Dominik Opałka. All Rights Reserved.  
Contact: hetwerk1943@gmail.com

## 🤝 Wsparcie

W razie problemów lub pytań, otwórz issue na GitHubie lub skontaktuj się przez email.
