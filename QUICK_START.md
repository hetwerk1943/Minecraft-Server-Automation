# Szybki Start - Minecraft Server Automation

## Krok 1: Przygotowanie Środowiska

### Sprawdź Wymagania

1. **PowerShell:**
   ```powershell
   $PSVersionTable.PSVersion
   ```
   Wymagana wersja: 5.1 lub wyższa (zalecane 7.x)

2. **Java:**
   ```bash
   java -version
   ```
   Wymagana wersja: Java 17+ dla Minecraft 1.18+

## Krok 2: Podstawowa Konfiguracja

### Automatyczna Instalacja

Użyj skryptu `MinecraftServerSetup.ps1` do automatycznej konfiguracji:

```powershell
.\MinecraftServerSetup.ps1 -ServerPath "C:\MinecraftServer" -MaxMemory 4096 -ServerPort 25565
```

Co robi ten skrypt:
- ✅ Tworzy katalog serwera
- ✅ Generuje plik `eula.txt`
- ✅ Tworzy `server.properties` z podstawową konfiguracją
- ✅ Generuje skrypt startowy `start.bat`
- ✅ Sprawdza instalację Java

### Ręczna Instalacja

Jeśli wolisz konfigurację ręczną:

1. Utwórz katalog serwera
2. Pobierz `server.jar` z https://www.minecraft.net/en-us/download/server
3. Utwórz `eula.txt` z zawartością: `eula=true`
4. (Opcjonalnie) Utwórz `server.properties` z własnymi ustawieniami

## Krok 3: Pierwsze Uruchomienie

### Uruchomienie Serwera

```powershell
.\StartServer.ps1 -ServerPath "C:\MinecraftServer" -MaxMemory 4096 -NoGUI
```

Parametry:
- `-ServerPath`: Lokalizacja katalogu serwera
- `-MaxMemory`: Maksymalna pamięć RAM w MB
- `-MinMemory`: Minimalna pamięć RAM w MB (opcjonalnie)
- `-NoGUI`: Uruchom bez GUI (zalecane dla serwerów)

### Pierwsze Logowanie

1. Zaczekaj, aż serwer się uruchomi (komunikat "Done!")
2. Otwórz Minecraft
3. Multiplayer → Direct Connect
4. Wpisz: `localhost` lub `127.0.0.1`

## Krok 4: Kopia Zapasowa

### Tworzenie Kopii Zapasowej

```powershell
.\BackupServer.ps1 -ServerPath "C:\MinecraftServer" -BackupPath "C:\Backups"
```

Skrypt:
- Tworzy archiwum ZIP z całym katalogiem serwera
- Automatycznie nazywa pliki według daty
- Usuwa stare kopie zapasowe (domyślnie zachowuje 10 najnowszych)

### Automatyczne Kopie Zapasowe

**Windows (Task Scheduler):**
```powershell
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\path\to\BackupServer.ps1 -ServerPath C:\MinecraftServer"
$trigger = New-ScheduledTaskTrigger -Daily -At 3am
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "MinecraftBackup"
```

**Linux (cron):**
```bash
0 3 * * * /usr/bin/pwsh /opt/minecraft/BackupServer.ps1 -ServerPath /opt/minecraft/server
```

## Krok 5: Aktualizacja Serwera

### Aktualizacja do Nowej Wersji

```powershell
.\UpdateServer.ps1 -ServerPath "C:\MinecraftServer" -Version "latest"
```

Skrypt:
- ✅ Automatycznie tworzy kopię zapasową przed aktualizacją
- ✅ Sprawdza aktualną wersję
- ✅ Weryfikuje pliki konfiguracyjne
- ✅ Informuje o krokach do wykonania

**Uwaga:** Musisz ręcznie pobrać nowy plik `server.jar` i umieścić go w katalogu serwera.

## Typowe Problemy

### Problem: "Java nie została znaleziona"

**Rozwiązanie:**
1. Zainstaluj Java 17+ z https://adoptium.net/
2. Sprawdź instalację: `java -version`
3. Dodaj Java do PATH

### Problem: "Server.jar nie został znaleziony"

**Rozwiązanie:**
1. Pobierz `server.jar` z oficjalnej strony Minecraft
2. Umieść go w katalogu serwera
3. Upewnij się, że nazwa pliku to dokładnie `server.jar`

### Problem: "Błąd pamięci" / OutOfMemoryError

**Rozwiązanie:**
1. Zwiększ parametr `-MaxMemory`:
   ```powershell
   .\StartServer.ps1 -MaxMemory 8192
   ```
2. Upewnij się, że masz wystarczająco RAM
3. Zamknij inne aplikacje

### Problem: "Port już używany"

**Rozwiązanie:**
1. Zmień port w `server.properties`:
   ```
   server-port=25566
   ```
2. Lub zamknij proces używający portu 25565

## Dobre Praktyki

### 1. Regularne Kopie Zapasowe
- Twórz kopie przed każdą aktualizacją
- Ustaw automatyczne codzienne kopie zapasowe
- Przechowuj kopie w osobnej lokalizacji

### 2. Monitorowanie Zasobów
- Sprawdzaj zużycie RAM i CPU
- Dostosuj `-MaxMemory` do potrzeb
- Używaj `-NoGUI` aby oszczędzać zasoby

### 3. Bezpieczeństwo
- Zmieniaj domyślny port (25565)
- Włącz whitelist w `server.properties`
- Regularnie aktualizuj server.jar

### 4. Wydajność
- Używaj SSD dla katalogu serwera
- Optymalizuj `server.properties`:
  - `view-distance=8` (zamiast 10)
  - `max-tick-time=60000`
- Rozważ użycie Paper lub Spigot dla lepszej wydajności

## Następne Kroki

1. **Personalizacja:**
   - Edytuj `server.properties`
   - Zainstaluj pluginy (Bukkit/Spigot)
   - Dostosuj ustawienia świata

2. **Administracja:**
   - Naucz się komend serwera
   - Skonfiguruj uprawnienia
   - Dodaj operatorów: `/op [gracz]`

3. **Automatyzacja:**
   - Skonfiguruj automatyczne restarty
   - Ustaw harmonogram kopii zapasowych
   - Monitoruj logi serwera

## Wsparcie

- **Issues:** https://github.com/hetwerk1943/Minecraft-Server-Automation/issues
- **Email:** hetwerk1943@gmail.com
- **Dokumentacja:** Sprawdź README.md dla szczegółów

---

© 2025 Dominik Opałka. All Rights Reserved.
