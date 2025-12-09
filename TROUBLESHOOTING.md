# Przewodnik Rozwiązywania Problemów
## Minecraft Server Automation - Troubleshooting Guide

Wersja: 1.0  
Ostatnia aktualizacja: 2025-12-09

---

## 📋 Spis Treści

1. [Problemy z Instalacją](#instalacja)
2. [Problemy z Uruchomieniem Serwera](#uruchomienie)
3. [Problemy z Kopiami Zapasowymi](#backup)
4. [Problemy z Aktualizacją](#aktualizacja)
5. [Problemy z Monetyzacją](#monetyzacja)
6. [Problemy z Monitoringiem](#monitoring)
7. [Problemy Sieciowe](#network)
8. [Problemy Wydajnościowe](#performance)
9. [Procedury Debugowania](#debugging)
10. [Procedury Awaryjne](#emergency)

---

## 1. Problemy z Instalacją {#instalacja}

### ❌ Problem: "Java nie została znaleziona"

**Objawy:**
```
Java nie została znaleziona. Zainstaluj Javę przed kontynuowaniem.
```

**Rozwiązanie:**

1. **Sprawdź instalację Java:**
   ```powershell
   java -version
   ```

2. **Zainstaluj Java 17 lub nowszą:**
   - Pobierz z: https://adoptium.net/
   - Zainstaluj dla wszystkich użytkowników
   - Zaznacz "Set JAVA_HOME variable"

3. **Dodaj Java do PATH (Windows):**
   ```powershell
   # Sprawdź zmienne środowiskowe
   $env:PATH -split ';' | Where-Object { $_ -like '*java*' }
   
   # Jeśli nie ma, dodaj ręcznie:
   # System Properties → Environment Variables → Path → Edit
   # Dodaj: C:\Program Files\Eclipse Adoptium\jdk-17.x.x\bin
   ```

4. **Sprawdź ponownie:**
   ```powershell
   # Zamknij i otwórz nowe okno PowerShell
   java -version
   ```

**Dodatkowe informacje:**
- Minecraft 1.18+ wymaga Java 17
- Minecraft 1.17 wymaga Java 16
- Minecraft 1.16 i starsze - Java 8

---

### ❌ Problem: "PowerShell - wykonywanie skryptów jest wyłączone"

**Objawy:**
```
File cannot be loaded because running scripts is disabled on this system.
```

**Rozwiązanie:**

1. **Sprawdź aktualną politykę:**
   ```powershell
   Get-ExecutionPolicy
   ```

2. **Zmień politykę (uruchom PowerShell jako Administrator):**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **Alternatywnie, dla jednorazowego wykonania:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\MinecraftServerSetup.ps1
   ```

**Uwaga bezpieczeństwa:**
- `RemoteSigned` jest bezpieczną opcją
- Nigdy nie używaj `Unrestricted` bez zrozumienia ryzyka

---

### ❌ Problem: "Access denied" / "Odmowa dostępu"

**Objawy:**
```
Access to the path 'C:\MinecraftServer' is denied.
```

**Rozwiązanie:**

1. **Uruchom PowerShell jako Administrator:**
   - Prawy przycisk na PowerShell → "Run as Administrator"

2. **Lub zmień lokalizację na katalog użytkownika:**
   ```powershell
   .\MinecraftServerSetup.ps1 -ServerPath "$env:USERPROFILE\MinecraftServer"
   ```

3. **Sprawdź uprawnienia do katalogu:**
   ```powershell
   # Sprawdź uprawnienia
   Get-Acl "C:\MinecraftServer" | Format-List
   
   # Nadaj uprawnienia
   icacls "C:\MinecraftServer" /grant "$env:USERNAME:(OI)(CI)F" /T
   ```

---

### ❌ Problem: "Insufficient disk space" / "Brak miejsca na dysku"

**Objawy:**
```
There is not enough space on the disk.
```

**Rozwiązanie:**

1. **Sprawdź dostępne miejsce:**
   ```powershell
   Get-PSDrive C | Select-Object Used,Free
   ```

2. **Wymagania miejsca:**
   - Minimalne: 2 GB
   - Zalecane: 10 GB
   - Produkcja: 50 GB+

3. **Zwolnij miejsce:**
   ```powershell
   # Usuń stare backupy
   Remove-Item ".\Backups\*" -Force -ErrorAction SilentlyContinue
   
   # Wyczyść logi
   Remove-Item ".\Logs\*" -Force -ErrorAction SilentlyContinue
   ```

4. **Zmień lokalizację na inny dysk:**
   ```powershell
   .\MinecraftServerSetup.ps1 -ServerPath "D:\MinecraftServer"
   ```

---

## 2. Problemy z Uruchomieniem Serwera {#uruchomienie}

### ❌ Problem: "server.jar not found"

**Objawy:**
```
Błąd: Plik server.jar nie istnieje w: C:\MinecraftServer\server.jar
```

**Rozwiązanie:**

1. **Pobierz server.jar:**
   - Odwiedź: https://www.minecraft.net/en-us/download/server
   - Pobierz najnowszą wersję
   - Zapisz jako `server.jar` (dokładnie ta nazwa)

2. **Umieść w katalogu serwera:**
   ```powershell
   # Przykład
   Move-Item "C:\Downloads\server.jar" "C:\MinecraftServer\server.jar"
   ```

3. **Sprawdź czy plik istnieje:**
   ```powershell
   Test-Path "C:\MinecraftServer\server.jar"
   # Powinno zwrócić: True
   ```

**Alternatywne nazwy:**
- Niektóre serwery używają: `minecraft_server.jar`, `spigot.jar`, `paper.jar`
- Zmień nazwę na `server.jar` lub edytuj skrypt startowy

---

### ❌ Problem: "EULA not accepted"

**Objawy:**
```
You need to agree to the EULA in order to run the server.
```

**Rozwiązanie:**

1. **Automatyczne (skrypt robi to za Ciebie):**
   ```powershell
   .\MinecraftServerSetup.ps1
   ```

2. **Ręcznie:**
   ```powershell
   # Utwórz lub edytuj eula.txt
   "eula=true" | Out-File -FilePath "C:\MinecraftServer\eula.txt" -Encoding ASCII
   ```

3. **Sprawdź zawartość:**
   ```powershell
   Get-Content "C:\MinecraftServer\eula.txt"
   # Powinno zawierać: eula=true
   ```

**Ważne:** Akceptując EULA, zgadzasz się na warunki licencji Minecraft.

---

### ❌ Problem: "Port already in use" / "Port jest już używany"

**Objawy:**
```
**** FAILED TO BIND TO PORT!
Perhaps a server is already running on that port?
```

**Rozwiązanie:**

1. **Sprawdź co używa portu:**
   ```powershell
   # Windows
   netstat -ano | findstr :25565
   
   # PowerShell
   Get-NetTCPConnection -LocalPort 25565 -ErrorAction SilentlyContinue
   ```

2. **Zamknij proces używający portu:**
   ```powershell
   # Znajdź PID z powyższego polecenia
   Stop-Process -Id <PID> -Force
   ```

3. **Lub zmień port w server.properties:**
   ```properties
   server-port=25566
   ```

4. **Sprawdź czy port jest wolny:**
   ```powershell
   Test-NetConnection -ComputerName localhost -Port 25565
   # Powinno pokazać failed connection jeśli port wolny
   ```

---

### ❌ Problem: "OutOfMemoryError: Java heap space"

**Objawy:**
```
java.lang.OutOfMemoryError: Java heap space
```

**Rozwiązanie:**

1. **Zwiększ alokację pamięci:**
   ```powershell
   .\StartServer.ps1 -MaxMemory 4096 -MinMemory 2048
   ```

2. **Sprawdź dostępną pamięć RAM:**
   ```powershell
   Get-CimInstance Win32_OperatingSystem | 
       Select-Object @{Name="FreeMemoryGB";Expression={[math]::Round($_.FreePhysicalMemory/1MB,2)}}
   ```

3. **Zalecane ustawienia pamięci:**
   ```
   Graczy: RAM
   1-10:   2-4 GB
   10-20:  4-6 GB
   20-50:  6-10 GB
   50+:    10-16 GB
   ```

4. **Zamknij inne aplikacje:**
   ```powershell
   # Sprawdź zużycie pamięci
   Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10
   ```

5. **Edytuj JVM flags:**
   ```powershell
   # W start.bat lub StartServer.ps1 dodaj:
   -XX:+UseG1GC -XX:MaxGCPauseMillis=50
   ```

---

### ❌ Problem: "JVM Crash" / "Crash serwera przy starcie"

**Objawy:**
```
A fatal error has been detected by the Java Runtime Environment
```

**Rozwiązanie:**

1. **Sprawdź wersję Java:**
   ```powershell
   java -version
   # Upewnij się że to Java 17+ dla Minecraft 1.18+
   ```

2. **Zaktualizuj Java:**
   - Pobierz najnowszą wersję z https://adoptium.net/

3. **Sprawdź logi crashu:**
   ```powershell
   Get-Content "C:\MinecraftServer\crash-reports\*.txt" -Tail 50
   ```

4. **Usuń problematyczne pluginy:**
   ```powershell
   # Przenieś wszystkie pluginy do folderu tymczasowego
   Move-Item "C:\MinecraftServer\plugins\*" "C:\MinecraftServer\plugins-backup\"
   
   # Uruchom serwer
   # Następnie dodawaj pluginy po jednym
   ```

5. **Sprawdź kompatybilność:**
   - Wersja serwera vs pluginy
   - Java version requirements
   - Dependencies między pluginami

---

## 3. Problemy z Kopiami Zapasowymi {#backup}

### ❌ Problem: "Insufficient disk space for backup"

**Objawy:**
```
Błąd podczas tworzenia kopii zapasowej: Brak miejsca na dysku
```

**Rozwiązanie:**

1. **Sprawdź miejsce na backupach:**
   ```powershell
   Get-ChildItem "C:\Backups" | 
       Measure-Object -Property Length -Sum | 
       Select-Object @{Name="SizeGB";Expression={[math]::Round($_.Sum/1GB,2)}}
   ```

2. **Usuń stare backupy ręcznie:**
   ```powershell
   # Usuń backupy starsze niż 30 dni
   Get-ChildItem "C:\Backups\*.zip" | 
       Where-Object { $_.CreationTime -lt (Get-Date).AddDays(-30) } | 
       Remove-Item -Force
   ```

3. **Zmniejsz MaxBackups:**
   ```powershell
   .\BackupServer.ps1 -MaxBackups 5
   ```

4. **Zmień lokalizację backupów:**
   ```powershell
   .\BackupServer.ps1 -BackupPath "D:\Backups"
   ```

---

### ❌ Problem: "Backup corruption" / "Uszkodzony backup"

**Objawy:**
```
Nie można wyodrębnić archiwum: plik uszkodzony
```

**Rozwiązanie:**

1. **Test integralności backupu:**
   ```powershell
   # Test archiwum ZIP
   Add-Type -AssemblyName System.IO.Compression.FileSystem
   try {
       [System.IO.Compression.ZipFile]::OpenRead("C:\Backups\backup.zip").Dispose()
       Write-Host "Backup OK" -ForegroundColor Green
   }
   catch {
       Write-Host "Backup uszkodzony!" -ForegroundColor Red
   }
   ```

2. **Użyj poprzedniego backupu:**
   ```powershell
   # Lista backupów od najnowszego
   Get-ChildItem "C:\Backups\*.zip" | 
       Sort-Object CreationTime -Descending
   ```

3. **Zapobieganie:**
   - Zawsze rób backup przed aktualizacją
   - Trzymaj minimum 3 kopie
   - Przechowuj backupy w różnych lokalizacjach
   - Regularnie testuj restore

---

### ❌ Problem: "Restore failed" / "Przywracanie nie powiodło się"

**Objawy:**
```
Błąd podczas przywracania backupu
```

**Rozwiązanie:**

1. **Ręczne przywracanie:**
   ```powershell
   # 1. Zatrzymaj serwer
   Stop-Process -Name "java" -Force -ErrorAction SilentlyContinue
   
   # 2. Backup aktualnego stanu (na wszelki wypadek)
   Compress-Archive -Path "C:\MinecraftServer" -DestinationPath "C:\Temp\emergency-backup.zip"
   
   # 3. Usuń aktualne pliki (OSTROŻNIE!)
   Remove-Item "C:\MinecraftServer\world" -Recurse -Force
   
   # 4. Wypakuj backup
   Expand-Archive -Path "C:\Backups\backup.zip" -DestinationPath "C:\MinecraftServer" -Force
   
   # 5. Uruchom serwer
   .\StartServer.ps1
   ```

2. **Sprawdź uprawnienia:**
   ```powershell
   icacls "C:\MinecraftServer" /grant "$env:USERNAME:(OI)(CI)F" /T
   ```

3. **Sprawdź strukturę backupu:**
   ```powershell
   # Podejrzyj zawartość bez wypakowywania
   [System.IO.Compression.ZipFile]::OpenRead("C:\Backups\backup.zip").Entries.FullName
   ```

---

## 4. Problemy z Aktualizacją {#aktualizacja}

### ❌ Problem: "Version compatibility issues"

**Objawy:**
```
Plugin not compatible with this server version
```

**Rozwiązanie:**

1. **Sprawdź wersję serwera:**
   ```powershell
   # Sprawdź version.json lub server.log
   Get-Content "C:\MinecraftServer\logs\latest.log" | Select-String "Starting minecraft server version"
   ```

2. **Lista pluginów do aktualizacji:**
   ```
   Plugin           Old Version    New Version    Compatible
   EssentialsX      2.19.0        2.20.0         ✅
   LuckPerms        5.3           5.4            ✅
   Vault            1.7.3         1.7.3          ❌ (needs update)
   ```

3. **Aktualizuj pluginy:**
   - Sprawdź każdy plugin na SpigotMC/Bukkit
   - Pobierz wersje kompatybilne z nową wersją serwera
   - Test na dev server przed produkcją

4. **Rollback jeśli potrzeba:**
   ```powershell
   .\UpdateServer.ps1 -ServerPath "C:\MinecraftServer"
   # Użyj automatycznie utworzonego backupu
   ```

---

### ❌ Problem: "Config migration issues"

**Objawy:**
```
Configuration file outdated or invalid
```

**Rozwiązanie:**

1. **Backup konfiguracji:**
   ```powershell
   Copy-Item "C:\MinecraftServer\server.properties" "C:\Temp\server.properties.bak"
   Copy-Item "C:\MinecraftServer\plugins\*\config.yml" "C:\Temp\configs-backup\" -Recurse
   ```

2. **Reset do domyślnych:**
   ```powershell
   # Usuń stare, pozwól serwerowi wygenerować nowe
   Remove-Item "C:\MinecraftServer\server.properties"
   # Przy pierwszym uruchomieniu zostaną wygenerowane nowe
   ```

3. **Migruj ważne ustawienia:**
   ```powershell
   # Porównaj stary i nowy plik
   Compare-Object (Get-Content old.properties) (Get-Content new.properties)
   ```

4. **Użyj narzędzi migracji:**
   - SpigotMC config updater
   - Plugin-specific migration tools

---

## 5. Problemy z Monetyzacją {#monetyzacja}

### ❌ Problem: "Tebex integration failed"

**Objawy:**
```
Failed to connect to Tebex API
```

**Rozwiązanie:**

1. **Sprawdź Secret Key:**
   ```powershell
   # Pobierz z: https://tebex.io/
   # Panel → Settings → Secret Key
   ```

2. **Test połączenia:**
   ```powershell
   $secret = "your-secret-key"
   $headers = @{
       "X-Tebex-Secret" = $secret
   }
   try {
       $response = Invoke-RestMethod -Uri "https://plugin.tebex.io/information" -Headers $headers
       Write-Host "Connected to: $($response.account.name)" -ForegroundColor Green
   }
   catch {
       Write-Host "Connection failed: $_" -ForegroundColor Red
   }
   ```

3. **Sprawdź firewall:**
   ```powershell
   # Dodaj wyjątek dla plugin.tebex.io
   Test-NetConnection -ComputerName plugin.tebex.io -Port 443
   ```

4. **Aktualizuj plugin Tebex:**
   - Pobierz najnowszą wersję z https://www.spigotmc.org/resources/tebex.1475/

---

### ❌ Problem: "VIP permissions not working"

**Objawy:**
```
Gracz ma VIP ale nie ma uprawnień
```

**Rozwiązanie:**

1. **Sprawdź LuckPerms:**
   ```
   /lp user <nick> info
   /lp user <nick> permission info
   ```

2. **Dodaj grupę VIP:**
   ```
   /lp creategroup vip
   /lp group vip permission set essentials.fly true
   /lp user <nick> parent add vip
   ```

3. **Sprawdź config LuckPerms:**
   ```yaml
   # plugins/LuckPerms/config.yml
   storage-method: sqlite  # lub mysql
   ```

4. **Reload permissions:**
   ```
   /lp sync
   /lp reloadconfig
   ```

---

### ❌ Problem: "Economy not working"

**Objawy:**
```
/balance - Command not found
```

**Rozwiązanie:**

1. **Sprawdź czy Vault jest zainstalowany:**
   ```
   /plugins
   # Powinno pokazać: Vault (green)
   ```

2. **Zainstaluj plugin ekonomii:**
   - EssentialsX (zawiera ekonomię)
   - lub CMI, nebo Treasury

3. **Skonfiguruj Vault:**
   ```yaml
   # plugins/Vault/config.yml
   economy:
     enabled: true
   ```

4. **Test ekonomii:**
   ```
   /balance
   /eco give <player> 1000
   ```

---

## 6. Problemy z Monitoringiem {#monitoring}

### ❌ Problem: "Discord webhook failed"

**Objawy:**
```
Błąd podczas wysyłania do Discord
```

**Rozwiązanie:**

1. **Sprawdź URL webhooka:**
   ```powershell
   $webhook = "https://discord.com/api/webhooks/..."
   # Poprawny format: https://discord.com/api/webhooks/{id}/{token}
   ```

2. **Test webhooka:**
   ```powershell
   $body = @{
       content = "Test message from Minecraft Server"
   } | ConvertTo-Json
   
   try {
       Invoke-RestMethod -Uri $webhook -Method Post -Body $body -ContentType "application/json"
       Write-Host "Webhook OK" -ForegroundColor Green
   }
   catch {
       Write-Host "Webhook failed: $_" -ForegroundColor Red
   }
   ```

3. **Sprawdź rate limiting:**
   - Discord limit: 5 wiadomości / 2 sekundy
   - Zmniejsz częstotliwość monitoringu

4. **Regeneruj webhook jeśli nieważny:**
   - Discord → Server Settings → Integrations → Webhooks
   - Delete old, create new

---

### ❌ Problem: "Monitoring script not collecting data"

**Objawy:**
```
Metrics show 0 or no data
```

**Rozwiązanie:**

1. **Sprawdź czy serwer działa:**
   ```powershell
   Get-Process -Name "java" -ErrorAction SilentlyContinue
   ```

2. **Sprawdź uprawnienia do logów:**
   ```powershell
   Test-Path "C:\MinecraftServer\logs\latest.log"
   Get-Acl "C:\MinecraftServer\logs\latest.log"
   ```

3. **Uruchom monitoring z debugowaniem:**
   ```powershell
   .\ServerMonitoring.ps1 -ServerPath "C:\MinecraftServer" -Verbose
   ```

4. **Sprawdź logi monitoringu:**
   ```powershell
   Get-Content ".\Logs\monitoring.log" -Tail 50
   ```

---

### ❌ Problem: "Report generation failed"

**Objawy:**
```
Nie można wygenerować raportu
```

**Rozwiązanie:**

1. **Sprawdź katalog Logs:**
   ```powershell
   Test-Path ".\Logs"
   # Jeśli false, utwórz:
   New-Item -ItemType Directory -Path ".\Logs" -Force
   ```

2. **Sprawdź dane źródłowe:**
   ```powershell
   Get-Content "C:\MinecraftServer\logs\latest.log" | Measure-Object -Line
   # Powinno być >0 linii
   ```

3. **Ręcznie wygeneruj raport:**
   ```powershell
   .\ServerMonitoring.ps1 -GenerateReports -ServerPath "C:\MinecraftServer"
   ```

4. **Sprawdź błędy w console:**
   ```powershell
   # Uruchom bez -ErrorAction SilentlyContinue
   ```

---

## 7. Problemy Sieciowe {#network}

### ❌ Problem: "Can't connect from outside network"

**Objawy:**
```
Connection timed out - no further information
```

**Rozwiązanie:**

1. **Port Forwarding:**
   ```
   Router Settings:
   - External Port: 25565
   - Internal Port: 25565
   - Protocol: TCP & UDP
   - IP: [Your local server IP]
   ```

2. **Sprawdź lokalny IP:**
   ```powershell
   Get-NetIPAddress -AddressFamily IPv4 | 
       Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.*" }
   ```

3. **Sprawdź publiczny IP:**
   ```powershell
   Invoke-RestMethod -Uri "https://api.ipify.org"
   ```

4. **Test portu z zewnątrz:**
   - Użyj: https://www.yougetsignal.com/tools/open-ports/
   - Wpisz IP i port 25565

5. **Firewall - dodaj wyjątek:**
   ```powershell
   # Windows Firewall
   New-NetFirewallRule -DisplayName "Minecraft Server" `
       -Direction Inbound `
       -LocalPort 25565 `
       -Protocol TCP `
       -Action Allow
   
   New-NetFirewallRule -DisplayName "Minecraft Server UDP" `
       -Direction Inbound `
       -LocalPort 25565 `
       -Protocol UDP `
       -Action Allow
   ```

---

### ❌ Problem: "High ping / Lag"

**Objawy:**
```
Gracz ma wysoki ping (>200ms)
```

**Rozwiązanie:**

1. **Sprawdź lokalizację serwera:**
   - Serwer w Polsce, gracze w Polsce = low ping
   - Serwer w USA, gracze w EU = high ping

2. **Optymalizuj server.properties:**
   ```properties
   network-compression-threshold=256
   max-tick-time=60000
   ```

3. **Sprawdź użycie bandwidth:**
   ```powershell
   Get-NetAdapterStatistics
   ```

4. **Ogranicz view-distance:**
   ```properties
   view-distance=8  # Zamiast 10
   simulation-distance=8
   ```

5. **Użyj lepszego hostingu:**
   - Hosting w Polsce: OVH, home.pl, nazwa.pl
   - Dedykowany serwer lepszy niż VPS

---

### ❌ Problem: "Connection reset / Disconnected"

**Objawy:**
```
Internal Exception: java.io.IOException: Connection reset
```

**Rozwiązanie:**

1. **Zwiększ limity sieciowe:**
   ```properties
   # server.properties
   max-players=100
   network-compression-threshold=256
   ```

2. **Sprawdź stabilność połączenia:**
   ```powershell
   Test-NetConnection -ComputerName google.com -InformationLevel Detailed
   ```

3. **Restart routera:**
   - Czasami pomaga prosty restart sprzętu sieciowego

4. **Aktualizuj sterowniki sieciowe:**
   ```powershell
   # Device Manager → Network Adapters → Update Driver
   ```

---

## 8. Problemy Wydajnościowe {#performance}

### ❌ Problem: "High CPU usage"

**Objawy:**
```
CPU at 100%, server lagging
```

**Rozwiązanie:**

1. **Sprawdź użycie CPU przez Java:**
   ```powershell
   Get-Process java | Select-Object Id,CPU,WorkingSet
   ```

2. **Optymalizuj JVM flags:**
   ```powershell
   # W StartServer.ps1 użyj:
   -XX:+UseG1GC 
   -XX:+ParallelRefProcEnabled 
   -XX:MaxGCPauseMillis=200
   -XX:+UnlockExperimentalVMOptions 
   -XX:+DisableExplicitGC 
   -XX:G1NewSizePercent=30 
   -XX:G1MaxNewSizePercent=40 
   -XX:G1HeapRegionSize=8M
   ```

3. **Ogranicz entities:**
   ```yaml
   # plugins/ClearLag/config.yml
   clear-task:
     enabled: true
     interval: 300  # co 5 minut
   ```

4. **Sprawdź plugins:**
   ```
   /timings  # Paper/Spigot
   # Zidentyfikuj problematyczne pluginy
   ```

5. **Użyj Paper/Purpur zamiast Spigot:**
   - Lepiej zoptymalizowane
   - Więcej opcji wydajności

---

### ❌ Problem: "High memory usage / Memory leak"

**Objawy:**
```
Pamięć rośnie i nie spada, eventual crash
```

**Rozwiązanie:**

1. **Sprawdź użycie pamięci:**
   ```powershell
   Get-Process java | 
       Select-Object @{Name="MemoryGB";Expression={[math]::Round($_.WorkingSet64/1GB,2)}}
   ```

2. **Analiza memory leak:**
   ```
   # Dodaj do JVM args:
   -XX:+HeapDumpOnOutOfMemoryError 
   -XX:HeapDumpPath=./heap_dumps/
   
   # Analizuj dumpy z VisualVM lub MAT (Memory Analyzer Tool)
   ```

3. **Restartuj serwer regularnie:**
   ```powershell
   # Task Scheduler - restart co 24h
   # Lub użyj plugin: RestartScheduler
   ```

4. **Ogranicz ładowane chunki:**
   ```properties
   view-distance=8
   simulation-distance=6
   ```

5. **Wyczyść niepotrzebne dane:**
   ```
   # Plugin: WorldBorder
   /wb fill  # pre-generate world
   /wb trim  # remove unused chunks
   ```

---

### ❌ Problem: "TPS drops / Server lagging"

**Objawy:**
```
TPS < 20, gracze doświadczają laga
```

**Rozwiązanie:**

1. **Sprawdź TPS:**
   ```
   /tps  # Wymaga Paper/Spigot
   # Powinno być: 20.0
   ```

2. **Identyfikuj źródło laga:**
   ```
   /timings paste
   # Wklej link do analizy
   ```

3. **Optymalizacje server.properties:**
   ```properties
   view-distance=8
   simulation-distance=8
   entity-broadcast-range-percentage=100
   ```

4. **Optymalizacje spigot.yml:**
   ```yaml
   mob-spawn-range: 6  # Zamiast 8
   entity-activation-range:
     animals: 32
     monsters: 32
     raiders: 48
     misc: 16
   ```

5. **Optymalizacje paper.yml:**
   ```yaml
   anti-xray:
     enabled: false  # Jeśli nie potrzeba
   max-auto-save-chunks-per-tick: 6
   optimize-explosions: true
   ```

6. **Wyczyść entities:**
   ```
   /minecraft:kill @e[type=!player]  # OSTROŻNIE!
   # Lub użyj ClearLag plugin
   ```

---

## 9. Procedury Debugowania {#debugging}

### 🔍 Analiza Logów

**1. Server Logs:**
```powershell
# Najnowsze błędy
Get-Content "C:\MinecraftServer\logs\latest.log" | 
    Select-String -Pattern "ERROR|SEVERE|WARN" | 
    Select-Object -Last 20

# Wyszukaj konkretny błąd
Get-Content "C:\MinecraftServer\logs\latest.log" | 
    Select-String -Pattern "OutOfMemory"

# Analiza czasu uruchomienia
Get-Content "C:\MinecraftServer\logs\latest.log" | 
    Select-String -Pattern "Done \("
```

**2. Crash Reports:**
```powershell
# Najnowszy crash report
Get-ChildItem "C:\MinecraftServer\crash-reports" | 
    Sort-Object LastWriteTime -Descending | 
    Select-Object -First 1 | 
    Get-Content

# Identyfikuj pattern
Get-ChildItem "C:\MinecraftServer\crash-reports\*.txt" | 
    ForEach-Object { 
        Get-Content $_ | Select-String -Pattern "Exception" 
    }
```

**3. Event Logs (Windows):**
```powershell
# Błędy aplikacji
Get-EventLog -LogName Application -EntryType Error -Newest 20 | 
    Where-Object { $_.Source -like "*Java*" }
```

---

### 🔍 Diagnostyka Procesów

**Sprawdź procesy Java:**
```powershell
# Wszystkie procesy Java
Get-Process java | Format-Table Id,CPU,WorkingSet,StartTime

# Szczegóły procesu
Get-Process -Id <PID> | Format-List *

# Wątki procesu
Get-Process -Id <PID> | Select-Object -ExpandProperty Threads

# Połączenia sieciowe
Get-NetTCPConnection -OwningProcess <PID>
```

---

### 🔍 Diagnostyka Sieci

**Test connectivity:**
```powershell
# Local connectivity
Test-NetConnection -ComputerName localhost -Port 25565

# Remote connectivity
Test-NetConnection -ComputerName your-server-ip -Port 25565

# Trace route
Test-NetConnection -ComputerName your-server-ip -TraceRoute

# DNS resolution
Resolve-DnsName your-server-domain.com
```

---

### 🔍 Diagnostyka Wydajności

**Performance Monitor:**
```powershell
# CPU Usage
Get-Counter -Counter "\Processor(_Total)\% Processor Time" -SampleInterval 1 -MaxSamples 10

# Memory Usage
Get-Counter -Counter "\Memory\Available MBytes" -SampleInterval 1 -MaxSamples 10

# Disk I/O
Get-Counter -Counter "\PhysicalDisk(_Total)\Disk Reads/sec" -SampleInterval 1 -MaxSamples 10

# Network
Get-Counter -Counter "\Network Interface(*)\Bytes Total/sec" -SampleInterval 1 -MaxSamples 10
```

---

## 10. Procedury Awaryjne {#emergency}

### 🚨 Server Crash - Recovery

**Krok 1: Zatrzymaj wszystkie procesy**
```powershell
Get-Process java | Stop-Process -Force
```

**Krok 2: Backup aktualnego stanu**
```powershell
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
Compress-Archive -Path "C:\MinecraftServer" `
    -DestinationPath "C:\EmergencyBackup\crash-backup-$timestamp.zip"
```

**Krok 3: Sprawdź crash reports**
```powershell
Get-ChildItem "C:\MinecraftServer\crash-reports" | 
    Sort-Object LastWriteTime -Descending | 
    Select-Object -First 1 | 
    Get-Content
```

**Krok 4: Przywróć ostatni działający backup**
```powershell
# Znajdź ostatni backup
$lastBackup = Get-ChildItem "C:\Backups\*.zip" | 
    Sort-Object CreationTime -Descending | 
    Select-Object -First 1

# Restore
Expand-Archive -Path $lastBackup.FullName `
    -DestinationPath "C:\MinecraftServer" -Force
```

**Krok 5: Uruchom w safe mode**
```powershell
# Przenieś wszystkie pluginy
Move-Item "C:\MinecraftServer\plugins\*" "C:\Temp\plugins-disabled\"

# Uruchom vanilla server
.\StartServer.ps1 -NoGUI
```

---

### 🚨 Data Corruption - Recovery

**World corruption:**
```powershell
# 1. Stop server
Get-Process java | Stop-Process -Force

# 2. Backup skorumpowanych danych
Move-Item "C:\MinecraftServer\world" "C:\Temp\corrupted-world"

# 3. Restore from backup
$lastGoodBackup = Get-ChildItem "C:\Backups\*.zip" | 
    Where-Object { $_.CreationTime -lt (Get-Date).AddDays(-1) } |
    Sort-Object CreationTime -Descending | 
    Select-Object -First 1

Expand-Archive -Path $lastGoodBackup.FullName -DestinationPath "C:\Temp\restore"
Copy-Item "C:\Temp\restore\world" "C:\MinecraftServer\" -Recurse

# 4. Restart
.\StartServer.ps1
```

**Player data corruption:**
```powershell
# Usuń skorumpowane dane gracza
Remove-Item "C:\MinecraftServer\world\playerdata\<UUID>.dat"

# Gracz zacznie od nowa ale server będzie działał
```

---

### 🚨 Security Breach - Response

**Krok 1: Natychmiastowe działania**
```powershell
# Stop server
Get-Process java | Stop-Process -Force

# Backup dla analizy forensic
Compress-Archive -Path "C:\MinecraftServer" `
    -DestinationPath "C:\SecurityIncident\breach-$(Get-Date -Format 'yyyyMMdd').zip"
```

**Krok 2: Analiza**
```powershell
# Sprawdź ops.json - nieautoryzowani admini
Get-Content "C:\MinecraftServer\ops.json"

# Sprawdź bannedplayers
Get-Content "C:\MinecraftServer\banned-players.json"

# Przejrzyj logi
Get-Content "C:\MinecraftServer\logs\latest.log" | 
    Select-String -Pattern "issued server command"
```

**Krok 3: Cleanup**
```powershell
# Usuń nieautoryzowanych ops
# Edytuj ops.json ręcznie

# Zmień hasła/klucze
# - Tebex Secret Key
# - Discord Webhooks
# - Rcon password
```

**Krok 4: Restore i hardening**
```powershell
# Restore z czystego backupu
# Zaktualizuj wszystkie pluginy
# Włącz authentication plugin
# Dodaj whitelist
```

---

### 📞 Kontakt i Wsparcie

**GitHub Issues:**
- Repository: https://github.com/hetwerk1943/Minecraft-Server-Automation
- Otwórz issue z szczegółami problemu

**Email Support:**
- hetwerk1943@gmail.com
- Załącz: logi, crash reports, kroki reprodukcji

**Community:**
- Discord: [będzie dodany]
- Forum: [będzie dodany]

**Emergency Checklist:**
```
☐ Backup zrobiony
☐ Crash reports przeczytane
☐ Logi przeanalizowane
☐ Procesy sprawdzone
☐ Sieć zdiagnozowana
☐ Restore wypróbowany
☐ Support kontaktowany (jeśli potrzeba)
```

---

**Dokument stworzony przez:** GitHub Copilot Agent  
**Wersja:** 1.0  
**Data:** 2025-12-09  
**Ostatnia aktualizacja:** 2025-12-09

---

## Przydatne Komendy - Quick Reference

```powershell
# === Podstawowe ===
.\MinecraftServerSetup.ps1 -ServerPath "C:\MC" -MaxMemory 4096
.\StartServer.ps1 -ServerPath "C:\MC" -NoGUI
.\BackupServer.ps1 -ServerPath "C:\MC"
.\UpdateServer.ps1 -ServerPath "C:\MC"

# === Diagnostyka ===
Get-Process java
Test-NetConnection -ComputerName localhost -Port 25565
Get-Content "C:\MC\logs\latest.log" -Tail 50
Get-Counter -Counter "\Processor(_Total)\% Processor Time"

# === Recovery ===
Get-Process java | Stop-Process -Force
Expand-Archive -Path "backup.zip" -DestinationPath "C:\MC" -Force

# === Monitoring ===
.\ServerMonitoring.ps1 -GenerateReports
.\PlayerManagement.ps1 -Action stats -PlayerName "player"
```

**Zawsze pamiętaj:**
1. ✅ Rób backup przed każdą większą zmianą
2. ✅ Czytaj logi przy problemach
3. ✅ Testuj na dev server przed produkcją
4. ✅ Dokumentuj zmiany
5. ✅ Proś o pomoc gdy potrzeba
