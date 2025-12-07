# 🔧 Przewodnik Rozwiązywania Problemów

## Spis Treści
- [Problemy z Instalacją](#problemy-z-instalacją)
- [Problemy z Uruchamianiem](#problemy-z-uruchamianiem)
- [Problemy z Wydajnością](#problemy-z-wydajnością)
- [Problemy z Kopiami Zapasowymi](#problemy-z-kopiami-zapasowymi)
- [Problemy z Aktualizacjami](#problemy-z-aktualizacjami)
- [Problemy Sieciowe](#problemy-sieciowe)
- [Diagnostyka Zaawansowana](#diagnostyka-zaawansowana)

---

## Problemy z Instalacją

### ❌ "Java nie jest zainstalowana"

**Objawy:**
```
Błąd: Java nie jest zainstalowana!
```

**Rozwiązanie:**
1. Zainstaluj Java JDK 17 lub nowszą:
   - **Windows:** Pobierz z https://adoptium.net/
   - **Linux:** `sudo apt install openjdk-17-jdk`
   - **macOS:** `brew install openjdk@17`

2. Sprawdź instalację:
```bash
java -version
```

3. Jeśli wciąż nie działa, dodaj Java do PATH:
   - **Windows:** Panel sterowania → System → Zaawansowane → Zmienne środowiskowe
   - **Linux/macOS:** Dodaj do `~/.bashrc` lub `~/.zshrc`:
```bash
export JAVA_HOME=/path/to/java
export PATH=$JAVA_HOME/bin:$PATH
```

### ❌ "PowerShell nie rozpoznaje polecenia"

**Objawy:**
```
The term 'nazwa-skryptu.ps1' is not recognized...
```

**Rozwiązanie:**
1. Uruchom z pełną ścieżką:
```powershell
.\scripts\NazwaSkryptu.ps1
```

2. Lub dodaj katalog do PATH:
```powershell
$env:PATH += ";$PWD\scripts"
```

### ❌ "Execution policy prevents running scripts"

**Objawy:**
```
cannot be loaded because running scripts is disabled on this system
```

**Rozwiązanie:**
1. Tymczasowo na tej sesji:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

2. Dla bieżącego użytkownika (zalecane):
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

3. Lub uruchom z flagą:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\NazwaSkryptu.ps1
```

---

## Problemy z Uruchamianiem

### ❌ Serwer nie startuje - "Address already in use"

**Objawy:**
```
Failed to bind to port 25565
```

**Rozwiązanie:**
1. Sprawdź, który proces używa portu:
```powershell
# Windows
Get-NetTCPConnection -LocalPort 25565

# Linux
sudo lsof -i :25565
```

2. Zatrzymaj konfliktujący proces:
```powershell
# Windows
Stop-Process -Id <PID>

# Linux
kill <PID>
```

3. Lub zmień port w `server.properties`:
```properties
server-port=25566
```

### ❌ Serwer crashuje przy starcie - Out of Memory

**Objawy:**
```
java.lang.OutOfMemoryError: Java heap space
```

**Rozwiązanie:**
1. Zwiększ alokowaną pamięć w `StartServer.ps1`:
```powershell
.\StartServer.ps1 -MaxMemory 4096  # 4GB RAM
```

2. Sprawdź dostępną pamięć:
```powershell
# Windows
Get-CimInstance Win32_OperatingSystem | Select-Object FreePhysicalMemory

# Linux
free -h
```

3. Zamknij inne aplikacje zużywające pamięć

### ❌ "EULA not accepted"

**Objawy:**
```
You need to agree to the EULA in order to run the server
```

**Rozwiązanie:**
1. Automatycznie przez skrypt:
```powershell
.\scripts\MinecraftServerSetup.ps1
```

2. Lub manualnie edytuj `eula.txt`:
```
eula=true
```

### ❌ Serwer uruchamia się ale jest niedostępny

**Objawy:**
- Serwer działa lokalnie
- Gracze nie mogą się połączyć z zewnątrz

**Rozwiązanie:**
1. Sprawdź firewall:
```powershell
# Windows - dodaj regułę
New-NetFirewallRule -DisplayName "Minecraft Server" -Direction Inbound -Port 25565 -Protocol TCP -Action Allow

# Linux
sudo ufw allow 25565/tcp
```

2. Sprawdź `server.properties`:
```properties
server-ip=0.0.0.0  # Nasłuchuj na wszystkich interfejsach
online-mode=true   # Weryfikacja Mojang
```

3. Sprawdź przekierowanie portów na routerze

---

## Problemy z Wydajnością

### 🐌 Niski TPS (Ticks Per Second)

**Objawy:**
- TPS poniżej 20
- Lag dla graczy
- Powolne ładowanie chunków

**Rozwiązanie:**
1. Sprawdź TPS:
```
/tps  # Wymaga pluginu lub Spigot/Paper
```

2. Optymalizuj `server.properties`:
```properties
view-distance=8          # Zmniejsz z 10
simulation-distance=6    # Zmniejsz z 10
max-tick-time=60000     # Zwiększ timeout
```

3. Użyj lepszej implementacji serwera:
   - Paper zamiast Vanilla (lepsze performance)
   - Purpur dla jeszcze lepszej optymalizacji

4. Sprawdź obciążenie:
```powershell
# Windows
Get-Process java | Select-Object CPU, WorkingSet

# Linux
top -p $(pgrep -f minecraft)
```

### 💾 Wysokie użycie RAM

**Objawy:**
- Serwer używa więcej RAM niż alokowano
- System się zacina

**Rozwiązanie:**
1. Zoptymalizuj ustawienia JVM:
```powershell
java -Xms2G -Xmx4G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -jar server.jar nogui
```

2. Ogranicz ilość loaded chunks:
   - Zmniejsz view-distance
   - Używaj world borders
   - Pregenerate chunks

3. Wyczyść nieużywane światy/backupy

### 💿 Wysokie użycie dysku

**Objawy:**
- Dysk zapełnia się szybko
- Powolne operacje I/O

**Rozwiązanie:**
1. Sprawdź rozmiar plików:
```powershell
Get-ChildItem -Recurse | Measure-Object -Property Length -Sum
```

2. Wyczyść stare backupy:
```powershell
Get-ChildItem backups -Filter "*.zip" | 
    Where-Object { $_.CreationTime -lt (Get-Date).AddDays(-7) } |
    Remove-Item -Force
```

3. Wyczyść stare logi:
```powershell
Get-ChildItem logs -Filter "*.log" |
    Where-Object { $_.CreationTime -lt (Get-Date).AddDays(-14) } |
    Remove-Item -Force
```

4. Użyj lepszej kompresji dla backupów

---

## Problemy z Kopiami Zapasowymi

### ❌ Backup zawiesza serwer

**Objawy:**
- Serwer się zacina podczas backupu
- Gracze doświadczają laga

**Rozwiązanie:**
1. Użyj komendy save-off:
```powershell
# W skrypcie BackupServer.ps1
Invoke-MinecraftCommand "save-off"
Invoke-MinecraftCommand "save-all flush"
Start-Sleep -Seconds 5
# ... backup ...
Invoke-MinecraftCommand "save-on"
```

2. Planuj backupy w czasie niskiej aktywności:
```powershell
# Cron job o 3:00
0 3 * * * /path/to/BackupServer.ps1
```

3. Użyj szybszej kompresji:
```powershell
# Kompresja "fast" zamiast "max"
Compress-Archive -CompressionLevel Fastest
```

### ❌ Backup się nie wykonuje

**Objawy:**
- Brak nowych plików backup
- Błędy w logach

**Rozwiązanie:**
1. Sprawdź uprawnienia:
```powershell
# Sprawdź czy możesz zapisywać w katalogu backups
Test-Path -Path "backups" -PathType Container
```

2. Sprawdź miejsce na dysku:
```powershell
# Windows
Get-PSDrive C | Select-Object Used,Free

# Linux
df -h
```

3. Sprawdź logi:
```powershell
Get-Content logs/backup.log -Tail 50
```

### ❌ Przywracanie z backupu nie działa

**Objawy:**
- Backup się nie rozpakowuje
- Świat jest uszkodzony po przywróceniu

**Rozwiązanie:**
1. Weryfikuj integralność backupu:
```powershell
# Sprawdź archiwum ZIP
Test-Archive -Path "backup.zip"
```

2. Zatrzymaj serwer przed przywracaniem:
```powershell
.\scripts\StopServer.ps1
Start-Sleep -Seconds 10
```

3. Zrób backup obecnego stanu przed przywróceniem:
```powershell
Copy-Item -Path "world" -Destination "world.pre-restore" -Recurse
```

---

## Problemy z Aktualizacjami

### ❌ Świat się zepsuł po aktualizacji

**Objawy:**
- Missing chunks
- Błędy w logach
- Gracze spadają przez świat

**Rozwiązanie:**
1. Natychmiast zatrzymaj serwer:
```powershell
.\scripts\StopServer.ps1
```

2. Przywróć z pre-update backupu:
```powershell
.\scripts\RestoreBackup.ps1 -BackupName "pre-update-20250107"
```

3. Poczekaj na stabilną wersję lub użyj beta na testowym serwerze

### ❌ Pluginy przestały działać po aktualizacji

**Objawy:**
- Server crashes on startup
- Komendy pluginów nie działają

**Rozwiązanie:**
1. Sprawdź kompatybilność pluginów:
   - Przeczytaj changelog wersji serwera
   - Sprawdź strony pluginów na SpigotMC/Bukkit

2. Aktualizuj pluginy:
```powershell
# Usuń stare wersje
Remove-Item plugins/*.jar.old

# Pobierz nowe wersje pluginów
# (manualnie lub przez plugin manager)
```

3. Temporary disable problematycznych pluginów:
```powershell
# Zmień rozszerzenie
Rename-Item plugins/problem-plugin.jar plugins/problem-plugin.jar.disabled
```

---

## Problemy Sieciowe

### 🌐 Gracze nie mogą się połączyć

**Objawy:**
- "Connection timed out"
- "Can't reach server"

**Diagnostyka:**
1. Sprawdź czy serwer działa:
```powershell
Get-Process -Name java
```

2. Sprawdź port:
```powershell
Test-NetConnection -ComputerName localhost -Port 25565
```

3. Sprawdź IP publiczne:
```powershell
(Invoke-WebRequest -Uri "https://api.ipify.org").Content
```

**Rozwiązanie:**
1. Skonfiguruj przekierowanie portów (port forwarding) na routerze:
   - Port zewnętrzny: 25565
   - Port wewnętrzny: 25565
   - IP: [IP twojego komputera w sieci lokalnej]

2. Sprawdź firewall (patrz wyżej)

3. Jeśli masz dynamic IP, użyj DynDNS

### 🔒 "Failed to verify username"

**Objawy:**
```
Failed to verify username because of an exception
```

**Rozwiązanie:**
1. Sprawdź `server.properties`:
```properties
online-mode=true  # Zmień na false tylko dla LAN
```

2. Sprawdź połączenie z serwerami Mojang:
```powershell
Test-NetConnection -ComputerName session.minecraft.net -Port 443
```

3. Poczekaj - może to być problem po stronie Mojang

### 📶 Wysoki ping/latency

**Objawy:**
- Ping >100ms
- Rubber-banding graczy

**Rozwiązanie:**
1. Sprawdź network stats:
```powershell
Test-Connection -ComputerName localhost -Count 10
```

2. Ogranicz bandwidth pluginów:
   - Disable heavy analytics plugins
   - Optimize view distance

3. Użyj lepszego hostingu:
   - Dedykowany serwer
   - Lokalizacja blisko graczy

---

## Diagnostyka Zaawansowana

### 📊 Analiza Logów

**Jak czytać logi:**
```powershell
# Ostatnie błędy
Get-Content logs/latest.log | Select-String "ERROR|WARN"

# Crashe serwera
Get-Content logs/latest.log | Select-String "Exception|Error"

# Monitoring w czasie rzeczywistym
Get-Content logs/latest.log -Wait -Tail 50
```

**Typowe błędy:**
- `OutOfMemoryError` → Zwiększ RAM
- `StackOverflowError` → Bug w pluginie/modzie
- `BindException` → Port zajęty
- `FileNotFoundException` → Brak plików świata

### 🔍 Thread Dump

**Gdy serwer się zawiesza:**
```powershell
# Windows
jstack <PID> > thread_dump.txt

# Linux
kill -3 <PID>  # Zapisuje do logu
```

**Analiza:**
- Szukaj "BLOCKED" threads
- Sprawdź "WAITING" na co czekają
- Identyfikuj deadlocki

### 📈 Profiling Wydajności

**Spark Profiler (Paper/Spigot):**
```
/spark profiler start
# Poczekaj 2-5 minut
/spark profiler stop
/spark profiler open
```

**JVM Flight Recorder:**
```powershell
java -XX:StartFlightRecording=duration=60s,filename=recording.jfr -jar server.jar
```

### 🩺 Health Check Script

**Utwórz automatyczny monitoring:**
```powershell
# Test-ServerHealth.ps1
while ($true) {
    $process = Get-Process -Name java -ErrorAction SilentlyContinue
    
    if (-not $process) {
        Write-Host "⚠️ Serwer nie działa!" -ForegroundColor Red
        # Opcjonalnie: automatyczny restart
        # .\scripts\StartServer.ps1
    } else {
        $cpu = $process.CPU
        $ram = [math]::Round($process.WorkingSet64 / 1GB, 2)
        Write-Host "✅ Serwer działa - CPU: $cpu, RAM: ${ram}GB" -ForegroundColor Green
    }
    
    Start-Sleep -Seconds 60
}
```

---

## 🆘 Gdy Nic Nie Pomaga

### Ostateczne Rozwiązania:

1. **Świeża instalacja:**
```powershell
# Backup obecnego stanu
.\scripts\BackupServer.ps1 -BackupName "before-reinstall"

# Usuń i zainstaluj od nowa
Remove-Item server.jar
.\scripts\MinecraftServerSetup.ps1
```

2. **Sprawdź community:**
   - Minecraft Forums
   - Reddit r/admincraft
   - Spigot/Paper Discord

3. **Zbierz informacje do zgłoszenia:**
   - Wersja serwera i Java
   - System operacyjny
   - Pełny log błędu
   - Kroki do reprodukcji

4. **Kontakt z autorem projektu:**
   - Email: hetwerk1943@gmail.com
   - GitHub Issues: [Link do issues]

---

## 📝 Szablon Zgłoszenia Problemu

Gdy zgłaszasz problem, użyj tego szablonu:

```markdown
### Opis Problemu
[Krótki opis co się dzieje]

### Kroki do Reprodukcji
1. [Pierwszy krok]
2. [Drugi krok]
3. [Trzeci krok]

### Oczekiwane Zachowanie
[Co powinno się stać]

### Rzeczywiste Zachowanie
[Co faktycznie się dzieje]

### Środowisko
- System Operacyjny: [Windows 11 / Ubuntu 22.04 / macOS]
- PowerShell: [wersja]
- Java: [wersja]
- Wersja Serwera: [1.20.4 / Paper / itp.]

### Logi
```
[Wklej relevantne fragmenty logów]
```

### Dodatkowe Informacje
[Wszystko co może pomóc w diagnozie]
```

---

**Dokument będzie aktualizowany z nowymi problemami i rozwiązaniami.**

**Ostatnia aktualizacja:** 2025-12-07
