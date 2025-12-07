# 🚀 Szybki Start - Minecraft Server Automation

> **Przewodnik dla początkujących - uruchom swój serwer Minecraft w 5 minut!**

## 📋 Czego Potrzebujesz?

Przed rozpoczęciem upewnij się, że masz:

- ✅ Komputer z Windows, Linux lub macOS
- ✅ Połączenie z internetem
- ✅ 30 minut czasu (pierwsze uruchomienie)
- ✅ Podstawowa znajomość terminala/PowerShell

---

## 🎯 Krok 1: Przygotowanie Środowiska

### Windows

#### 1.1. Zainstaluj PowerShell 7
```powershell
# Otwórz Windows PowerShell jako Administrator i uruchom:
winget install Microsoft.PowerShell
```

Alternatywnie, pobierz instalator z: https://github.com/PowerShell/PowerShell/releases

#### 1.2. Zainstaluj Java 17
```powershell
# W PowerShell jako Administrator:
winget install EclipseAdoptium.Temurin.17.JDK
```

Alternatywnie, pobierz z: https://adoptium.net/

#### 1.3. Uruchom PowerShell 7
- Znajdź "PowerShell 7" w menu Start
- Uruchom jako Administrator (prawy klik → "Uruchom jako administrator")

### Linux (Ubuntu/Debian)

#### 1.1. Zainstaluj PowerShell 7
```bash
# Pobierz i zainstaluj PowerShell
# UWAGA: Sprawdź najnowszą wersję na https://github.com/PowerShell/PowerShell/releases
wget https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/powershell_7.4.0-1.deb_amd64.deb
sudo dpkg -i powershell_7.4.0-1.deb_amd64.deb
sudo apt-get install -f  # Naprawia zależności jeśli są problemy
```

#### 1.2. Zainstaluj Java 17
```bash
sudo apt update
sudo apt install openjdk-17-jdk
```

#### 1.3. Uruchom PowerShell
```bash
pwsh
```

### macOS

#### 1.1. Zainstaluj Homebrew (jeśli nie masz)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### 1.2. Zainstaluj PowerShell i Java
```bash
brew install powershell
brew install openjdk@17
```

#### 1.3. Uruchom PowerShell
```bash
pwsh
```

### ✅ Weryfikacja Instalacji

Po zainstalowaniu sprawdź wersje:

```powershell
# Sprawdź PowerShell (powinno być 7.0 lub wyżej)
$PSVersionTable.PSVersion

# Sprawdź Java (powinno być 17 lub wyżej)
java -version
```

Jeśli widzisz poprawne wersje - świetnie! Możesz przejść dalej.

---

## 🎯 Krok 2: Pobierz Projekt

### 2.1. Zainstaluj Git (jeśli nie masz)

**Windows:**
```powershell
winget install Git.Git
```

**Linux:**
```bash
sudo apt install git
```

**macOS:**
```bash
brew install git
```

### 2.2. Sklonuj Repozytorium

```bash
# Przejdź do folderu, gdzie chcesz mieć serwer
cd ~

# Sklonuj projekt
git clone https://github.com/hetwerk1943/Minecraft-Server-Automation.git

# Wejdź do folderu
cd Minecraft-Server-Automation
```

---

## 🎯 Krok 3: Instalacja Serwera (Gdy będzie gotowe)

> ⚠️ **UWAGA:** Skrypty są obecnie w rozwoju. Poniższe kroki pokazują planowaną funkcjonalność.

### 3.1. Uruchom Skrypt Instalacyjny

```powershell
# W folderze projektu uruchom:
.\scripts\MinecraftServerSetup.ps1
```

Skrypt automatycznie:
- ✅ Pobierze najnowszą wersję server.jar
- ✅ Utworzy podstawową strukturę katalogów
- ✅ Wygeneruje domyślne pliki konfiguracyjne
- ✅ Zaakceptuje EULA
- ✅ Przeprowadzi pierwszą konfigurację

### 3.2. Co Robić Podczas Instalacji?

Skrypt zada Ci kilka pytań:

1. **Wersja serwera:**
   - Vanilla (standardowy Minecraft)
   - Paper (zoptymalizowany, zalecany)
   - Purpur (jeszcze lepsze performance)

2. **Maksymalna pamięć RAM:**
   - Dla 1-5 graczy: 2048 MB (2 GB)
   - Dla 5-10 graczy: 4096 MB (4 GB)
   - Dla 10+ graczy: 8192 MB (8 GB)

3. **Port serwera:**
   - Domyślnie: 25565
   - Zmień jeśli masz konflikt

4. **Tryb online:**
   - true - weryfikacja kont Mojang (zalecane)
   - false - tylko dla LAN/piratów

### 3.3. Poczekaj na Zakończenie

Instalacja może potrwać 5-10 minut (zależy od internetu).

---

## 🎯 Krok 4: Pierwsze Uruchomienie

### 4.1. Uruchom Serwer

```powershell
# Podstawowe uruchomienie
.\scripts\StartServer.ps1

# Lub z określoną ilością RAM
.\scripts\StartServer.ps1 -MaxMemory 4096
```

### 4.2. Co Zobaczysz?

Serwer uruchamia się! Zobaczysz:
```
✅ Sprawdzanie wymagań...
✅ Java 17 znaleziona
✅ Uruchamianie serwera Minecraft...
[INFO] Starting minecraft server version 1.20.4
[INFO] Loading properties
[INFO] Default game type: SURVIVAL
[INFO] Preparing level "world"
[INFO] Done! For help, type "help"
```

### 4.3. Sprawdź Status

Gdy zobaczysz "Done!" - serwer działa! 🎉

Możesz teraz:
- Wpisywać komendy bezpośrednio w konsoli
- Połączyć się z serwerem przez Minecrafta

---

## 🎯 Krok 5: Połącz Się z Serwerem

### 5.1. Znajdź Swój Adres IP

**Dla lokalnej gry (ten sam komputer):**
```
localhost
```
lub
```
127.0.0.1
```

**Dla graczy w tej samej sieci (LAN):**

```powershell
# Windows/macOS/Linux
ipconfig  # Windows
ifconfig  # Linux/macOS
ip addr   # Linux (nowsze systemy)
```

Szukaj czegoś w stylu: `192.168.1.100`

**Dla graczy z internetu:**

```powershell
# Sprawdź IP publiczne
(Invoke-WebRequest -Uri "https://api.ipify.org").Content
```

### 5.2. Otwórz Minecraft

1. Uruchom Minecraft (Java Edition)
2. Kliknij "Multiplayer"
3. Kliknij "Add Server"
4. Wprowadź:
   - **Server Name:** Mój Serwer
   - **Server Address:** localhost (lub IP z kroku 5.1)
5. Kliknij "Done"
6. Połącz się z serwerem!

### 5.3. Problem? Nie Możesz Się Połączyć?

Sprawdź [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - sekcja "Problemy Sieciowe"

---

## 🎯 Krok 6: Podstawowe Zarządzanie

### Komendy Serwera (w konsoli)

```
/help                    # Lista komend
/list                    # Lista graczy online
/op GraczNick           # Nadaj operatora
/deop GraczNick         # Odbierz operatora
/whitelist add GraczNick # Dodaj do whitelisty
/ban GraczNick          # Zbanuj gracza
/kick GraczNick         # Wyrzuć gracza
/stop                    # Zatrzymaj serwer
```

### Zatrzymywanie Serwera

**Metoda 1 - Komenda:**
```
/stop
```
w konsoli serwera

**Metoda 2 - Skrypt:**
```powershell
.\scripts\StopServer.ps1
```

### Tworzenie Kopii Zapasowej

```powershell
.\scripts\BackupServer.ps1
```

Backup zostanie zapisany w folderze `backups/`

### Aktualizacja Serwera

```powershell
.\scripts\UpdateServer.ps1
```

⚠️ Skrypt automatycznie zrobi backup przed aktualizacją!

---

## 🎯 Krok 7: Konfiguracja Serwera

### 7.1. Podstawowa Konfiguracja

Edytuj plik `server.properties`:

```properties
# Podstawowe ustawienia
server-name=Mój Serwer Minecraft
motd=Witaj na moim serwerze!
gamemode=survival
difficulty=normal
max-players=20

# Świat
level-name=world
level-seed=
level-type=default
generate-structures=true

# Wydajność
view-distance=10
simulation-distance=10
max-tick-time=60000

# Sieć
server-port=25565
enable-query=true
```

### 7.2. Ważne Ustawienia

**gamemode:**
- `survival` - Tryb przetrwania
- `creative` - Tryb kreatywny
- `adventure` - Tryb przygody
- `spectator` - Tryb obserwatora

**difficulty:**
- `peaceful` - Pokój (bez mobów)
- `easy` - Łatwy
- `normal` - Normalny
- `hard` - Trudny

**pvp:**
- `true` - Gracze mogą się atakować
- `false` - PvP wyłączone

**view-distance:**
- `6-8` - Niskie (lepsze FPS)
- `10-12` - Średnie (zalecane)
- `16-32` - Wysokie (wymaga mocnego serwera)

### 7.3. Po Zmianie Konfiguracji

Restartuj serwer:
```powershell
# Zatrzymaj
.\scripts\StopServer.ps1

# Uruchom ponownie
.\scripts\StartServer.ps1
```

---

## 🎯 Krok 8: Udostępnianie Serwera Dla Znajomych

### 8.1. Gracze w Tej Samej Sieci (LAN)

Po prostu podaj im swoje lokalne IP (np. 192.168.1.100) i port (25565)

### 8.2. Gracze Przez Internet

#### Opcja 1: Przekierowanie Portów (Port Forwarding)

1. Wejdź do panelu routera (zwykle http://192.168.1.1)
2. Znajdź "Port Forwarding" lub "Virtual Servers"
3. Dodaj nową regułę:
   - **Port zewnętrzny:** 25565
   - **Port wewnętrzny:** 25565
   - **Protokół:** TCP
   - **IP:** Twój lokalny IP (np. 192.168.1.100)
4. Zapisz

Podaj znajomym swoje publiczne IP + port 25565

⚠️ **Bezpieczeństwo:** Upewnij się, że masz silne hasło na koncie administratora i używasz whitelisty!

#### Opcja 2: Usługi Tunelowe

Jeśli nie możesz przekierować portów, użyj:
- **Ngrok:** https://ngrok.com/
- **Playit.gg:** https://playit.gg/
- **Hamachi:** https://www.vpn.net/

#### Opcja 3: Hosting

Dla poważniejszych serwerów rozważ:
- **Własny VPS:** DigitalOcean, Linode, Vultr
- **Minecraft hosting:** Apex Hosting, BisectHosting, Shockbyte

---

## 🎯 Krok 9: Regularna Konserwacja

### Codzienne Zadania

✅ **Sprawdzaj logi:** czy nie ma błędów
✅ **Monitoruj wydajność:** TPS, RAM, CPU
✅ **Odpowiadaj na feedback:** graczy

### Cotygodniowe Zadania

✅ **Ręczne backupy:** przed większymi zmianami
✅ **Czyszczenie logów:** usuń stare
✅ **Sprawdź aktualizacje:** Minecraft, pluginy

### Comiesięczne Zadania

✅ **Pełny backup:** z uplodem do chmury
✅ **Testuj przywracanie:** czy backupy działają
✅ **Optymalizacja:** sprawdź TPS, usuń lag

### Automatyzacja (Gdy skrypty będą gotowe)

```powershell
# Automatyczne backupy codziennie o 3:00
# Skonfiguruj Task Scheduler (Windows) lub Cron (Linux)

# Windows - Task Scheduler
$action = New-ScheduledTaskAction -Execute 'pwsh.exe' -Argument '-File C:\path\to\BackupServer.ps1'
$trigger = New-ScheduledTaskTrigger -Daily -At 3am
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Minecraft Backup"

# Linux - Crontab
# crontab -e
# 0 3 * * * /usr/bin/pwsh /path/to/BackupServer.ps1
```

---

## 🆘 Pomoc i Wsparcie

### Coś Nie Działa?

1. **Przeczytaj [TROUBLESHOOTING.md](TROUBLESHOOTING.md)**
   - Znajdziesz rozwiązania najczęstszych problemów

2. **Sprawdź logi:**
```powershell
# Ostatnie błędy
Get-Content logs/latest.log -Tail 50

# Tylko błędy i ostrzeżenia
Get-Content logs/latest.log | Select-String "ERROR|WARN"
```

3. **Szukaj pomocy:**
   - GitHub Issues tego projektu
   - r/admincraft na Reddit
   - Minecraft Forum

4. **Kontakt z autorem:**
   - Email: hetwerk1943@gmail.com
   - GitHub: @hetwerk1943

---

## 📚 Następne Kroki

Gratulacje! Twój serwer działa! 🎉

### Co Dalej?

1. **Zapoznaj się z dokumentacją:**
   - [PLAN_DZIAŁANIA.md](PLAN_DZIAŁANIA.md) - szczegółowy plan projektu
   - [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - rozwiązywanie problemów

2. **Dodaj pluginy** (dla Paper/Spigot):
   - Essentials - podstawowe komendy
   - WorldEdit - edycja świata
   - Vault - ekonomia
   - LuckPerms - zarządzanie uprawnieniami

3. **Optymalizuj wydajność:**
   - Użyj Paper zamiast Vanilla
   - Ogranicz view-distance
   - Pregenerate chunks
   - Użyj Chunky do pre-generacji

4. **Zabezpiecz serwer:**
   - Używaj whitelisty
   - Włącz online-mode
   - Regularnie rób backupy
   - Monitoruj logi

5. **Baw się dobrze!** 🎮

---

## 💡 Przydatne Komendy

### PowerShell

```powershell
# Sprawdź czy serwer działa
Get-Process -Name java

# Zobacz użycie pamięci
Get-Process -Name java | Select-Object CPU, WorkingSet

# Monitoring w czasie rzeczywistym
Get-Content logs/latest.log -Wait -Tail 50

# Ile miejsca zajmuje serwer
Get-ChildItem -Recurse | Measure-Object -Property Length -Sum
```

### Minecraft (w grze)

```
/gamemode creative      # Tryb kreatywny
/gamemode survival      # Tryb przetrwania
/tp @a 0 100 0         # Teleportuj wszystkich
/give @p diamond 64    # Daj sobie 64 diamenty
/time set day          # Ustaw dzień
/weather clear         # Wyczyść pogodę
/difficulty peaceful   # Ustaw pokój
```

---

## ⚠️ Najczęstsze Pomyłki Początkujących

### 1. Nie czytają EULA
❌ Serwer nie startuje  
✅ Skrypt automatycznie akceptuje EULA

### 2. Za mało RAM
❌ OutOfMemoryError  
✅ Zwiększ `-MaxMemory` parameter

### 3. Nie otwierają portu
❌ Nikt nie może się połączyć  
✅ Skonfiguruj firewall i port forwarding

### 4. Zapominają o backupach
❌ Świat się zepsuł, brak backupu  
✅ Automatyczne backupy przez skrypt

### 5. Nie monitorują logów
❌ Problemy się kumulują  
✅ Regularnie sprawdzaj `logs/latest.log`

---

## 🎉 Podsumowanie

Nauczyłeś się:
- ✅ Instalować wymagane narzędzia
- ✅ Pobrać i skonfigurować projekt
- ✅ Uruchomić serwer Minecraft
- ✅ Zarządzać serwerem (start/stop/backup)
- ✅ Konfigurować podstawowe ustawienia
- ✅ Udostępniać serwer dla znajomych
- ✅ Utrzymywać serwer w dobrej kondycji

**Teraz ciesz się swoim serwerem!** 🎮✨

---

**Masz pytania?** Zobacz [TROUBLESHOOTING.md](TROUBLESHOOTING.md) lub skontaktuj się: hetwerk1943@gmail.com

**Ostatnia aktualizacja:** 2025-12-07
