# Minecraft-Server-Automation
„PowerShell Omega scripts + configs for automated Minecraft server management and monetization"

## 📋 Opis

Zestaw skryptów PowerShell do automatyzacji zarządzania serwerem Minecraft. Skrypty obejmują:
- Automatyczną konfigurację i instalację serwera
- Uruchamianie serwera z konfigurowalnymi parametrami
- Tworzenie kopii zapasowych
- Aktualizację wersji serwera

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

### MinecraftServerSetup.ps1
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

## 📝 Licencja

© 2025 Dominik Opałka. All Rights Reserved.  
Contact: hetwerk1943@gmail.com

## 🤝 Wsparcie

W razie problemów lub pytań, otwórz issue na GitHubie lub skontaktuj się przez email.
