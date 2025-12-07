# Minecraft Server Automation

PowerShell scripts and configuration files for automated Minecraft server management, setup, and maintenance.

## 📋 Spis Treści

- [Wymagania](#wymagania)
- [Szybki Start](#szybki-start)
- [Dostępne Skrypty](#dostępne-skrypty)
- [Konfiguracja](#konfiguracja)
- [Użytkowanie](#użytkowanie)
- [Rozwiązywanie Problemów](#rozwiązywanie-problemów)

## 🔧 Wymagania

- **System Operacyjny**: Windows 10/11 lub Windows Server 2016+
- **PowerShell**: 5.1 lub nowszy
- **Uprawnienia**: Administrator (do instalacji Java i konfiguracji zapory)
- **Internet**: Połączenie internetowe do pobierania Javy i serwera Minecraft

## 🚀 Szybki Start

1. **Pobierz repozytorium**
   ```powershell
   git clone https://github.com/hetwerk1943/Minecraft-Server-Automation.git
   cd Minecraft-Server-Automation
   ```

2. **Uruchom PowerShell jako Administrator**
   - Kliknij prawym przyciskiem myszy na PowerShell
   - Wybierz "Uruchom jako administrator"

3. **Ustaw politykę wykonywania** (jeśli potrzebne)
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

4. **Uruchom skrypt instalacyjny**
   ```powershell
   .\MinecraftServerSetup.ps1
   ```

5. **Serwer zostanie skonfigurowany i możesz go uruchomić**

## 📜 Dostępne Skrypty

### MinecraftServerSetup.ps1
Główny skrypt instalacyjny, który:
- ✅ Instaluje Javę (jeśli nie jest zainstalowana)
- ✅ Tworzy strukturę folderów serwera
- ✅ Pobiera plik JAR serwera Minecraft
- ✅ Akceptuje EULA
- ✅ Konfiguruje zaporę Windows (port 25565)
- ✅ Oferuje natychmiastowe uruchomienie serwera

**Użycie:**
```powershell
.\MinecraftServerSetup.ps1
```

### StartServer.ps1
Szybkie uruchamianie serwera Minecraft.

**Użycie:**
```powershell
# Domyślne ustawienia
.\StartServer.ps1

# Niestandardowe ustawienia
.\StartServer.ps1 -ServerFolder "D:\MyServer" -RamAlloc "-Xmx4G -Xms2G"
```

**Parametry:**
- `-ServerFolder`: Ścieżka do folderu serwera (domyślnie: `C:\MinecraftServer`)
- `-RamAlloc`: Alokacja pamięci RAM (domyślnie: `-Xmx2G -Xms1G`)
- `-ServerJarName`: Nazwa pliku JAR (domyślnie: `server.jar`)

### BackupServer.ps1
Tworzenie kopii zapasowych serwera.

**Użycie:**
```powershell
# Podstawowy backup
.\BackupServer.ps1

# Backup z logami
.\BackupServer.ps1 -IncludeLogs

# Niestandardowa lokalizacja
.\BackupServer.ps1 -ServerFolder "D:\MyServer" -BackupFolder "E:\Backups"
```

**Parametry:**
- `-ServerFolder`: Ścieżka do folderu serwera (domyślnie: `C:\MinecraftServer`)
- `-BackupFolder`: Folder dla kopii zapasowych (domyślnie: `C:\MinecraftBackups`)
- `-IncludeLogs`: Włącz logi w backupie (domyślnie: wyłączone)

### UpdateServer.ps1
Aktualizacja serwera Minecraft do nowszej wersji.

**Użycie:**
```powershell
# Podstawowa aktualizacja
.\UpdateServer.ps1 -NewServerUrl "https://piston-data.mojang.com/.../server.jar"

# Aktualizacja bez automatycznego backupu
.\UpdateServer.ps1 -NewServerUrl "URL" -SkipBackup

# Niestandardowa lokalizacja
.\UpdateServer.ps1 -NewServerUrl "URL" -ServerFolder "D:\MyServer" -BackupFolder "E:\Backups"
```

**Parametry:**
- `-NewServerUrl`: URL do nowego pliku JAR serwera (wymagane)
- `-ServerFolder`: Ścieżka do folderu serwera (domyślnie: `C:\MinecraftServer`)
- `-BackupFolder`: Folder dla kopii zapasowych (domyślnie: `C:\MinecraftBackups`)
- `-SkipBackup`: Pomiń automatyczny backup przed aktualizacją (domyślnie: false)

**Uwaga:** Zawsze sprawdzaj najnowszy URL na [minecraft.net/download/server](https://www.minecraft.net/download/server)

## ⚙️ Konfiguracja

### config.json
Plik konfiguracyjny zawiera wszystkie podstawowe ustawienia:

```json
{
  "minecraft": {
    "version": "1.20.4",
    "serverFolder": "C:\\MinecraftServer",
    "downloadUrl": "https://..."
  },
  "performance": {
    "ramAllocation": "-Xmx2G -Xms1G",
    "maxPlayers": 20,
    "viewDistance": 10
  },
  "backup": {
    "backupFolder": "C:\\MinecraftBackups",
    "includeLogs": false
  },
  "network": {
    "port": 25565,
    "enableFirewall": true
  }
}
```

### Dostosowywanie Ustawień Serwera

Po pierwszym uruchomieniu, możesz edytować plik `server.properties` w folderze serwera:

```properties
# Podstawowe ustawienia
max-players=20
view-distance=10
difficulty=normal
gamemode=survival
pvp=true

# Sieć
server-port=25565
enable-query=true
```

## 📖 Użytkowanie

### Pierwsze Uruchomienie

1. Uruchom `MinecraftServerSetup.ps1` jako Administrator
2. Poczekaj na instalację Java i pobranie serwera
3. Akceptuj uruchomienie serwera lub uruchom później
4. Połącz się z serwerem używając adresu: `localhost:25565` (lokalnie) lub `TWÓJ_IP:25565` (zdalnie)

### Codzienne Zarządzanie

**Uruchomienie serwera:**
```powershell
.\StartServer.ps1
```

**Zatrzymanie serwera:**
W konsoli serwera wpisz: `stop`

**Tworzenie backupu:**
```powershell
.\BackupServer.ps1
```

**Aktualizacja serwera:**
```powershell
.\UpdateServer.ps1 -NewServerUrl "https://piston-data.mojang.com/.../server.jar"
```

### Komendy Administratora

Po uruchomieniu serwera, możesz używać komend w konsoli:

```
stop                    - Zatrzymuje serwer
op <nazwa_gracza>       - Nadaje uprawnienia administratora
deop <nazwa_gracza>     - Odbiera uprawnienia administratora
whitelist add <gracz>   - Dodaje gracza do whitelisty
whitelist remove <gracz>- Usuwa gracza z whitelisty
ban <gracz>            - Banuje gracza
pardon <gracz>         - Odbanowuje gracza
say <wiadomość>        - Wysyła wiadomość do wszystkich graczy
```

## 🔍 Rozwiązywanie Problemów

### Java nie jest zainstalowana
**Problem:** Błąd "Java nie jest dostępna w PATH"

**Rozwiązanie:**
1. Uruchom ponownie `MinecraftServerSetup.ps1` jako Administrator
2. Lub zainstaluj ręcznie Java 17+: `choco install temurin17jre`
3. Uruchom ponownie PowerShell

### Port jest zajęty
**Problem:** "Address already in use: bind"

**Rozwiązanie:**
1. Sprawdź czy inny serwer nie używa portu 25565
2. Zmień port w `server.properties`
3. Zaktualizuj regułę zapory

### Brak uprawnień
**Problem:** "Upewnij się, że uruchomiłeś skrypt jako Administrator"

**Rozwiązanie:**
1. Kliknij prawym przyciskiem myszy na PowerShell
2. Wybierz "Uruchom jako administrator"
3. Uruchom skrypt ponownie

### Serwer się zawiesza
**Problem:** Serwer nie odpowiada lub jest wolny

**Rozwiązanie:**
1. Zwiększ alokację RAM: `.\StartServer.ps1 -RamAlloc "-Xmx4G -Xms2G"`
2. Zmniejsz `view-distance` w `server.properties`
3. Zmniejsz `max-players` jeśli masz mniej zasobów

### Nie można pobrać pliku JAR
**Problem:** Błąd podczas pobierania serwera

**Rozwiązanie:**
1. Sprawdź połączenie internetowe
2. Zaktualizuj URL w pliku `config.json` lub bezpośrednio w skrypcie
3. Pobierz ręcznie z [minecraft.net](https://www.minecraft.net/download/server) i umieść w folderze serwera

## 📝 Notatki

- **Backup**: Regularnie twórz kopie zapasowe przed aktualizacjami
- **Aktualizacje**: Aby zaktualizować serwer, pobierz nowy JAR i zastąp stary
- **Wydajność**: Dla lepszej wydajności, rozważ SSD i więcej RAM
- **Bezpieczeństwo**: Używaj whitelisty lub hasła, jeśli serwer jest publiczny

## 🤝 Wkład

Chcesz pomóc? Otwórz Issue lub Pull Request!

## 📄 Licencja

Ten projekt jest dostępny na licencji open-source. Sprawdź plik LICENSE dla szczegółów.

## 🔗 Przydatne Linki

- [Minecraft Wiki](https://minecraft.wiki/)
- [Server Properties](https://minecraft.wiki/w/Server.properties)
- [Official Minecraft](https://www.minecraft.net/)
- [Paper MC](https://papermc.io/) - Alternatywna implementacja serwera
