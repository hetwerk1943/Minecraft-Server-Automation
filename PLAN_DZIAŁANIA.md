# 📋 Kompleksowy Plan Działania - Minecraft Server Automation

## 🎯 Cel Projektu
Stworzenie kompleksowego zestawu skryptów PowerShell do automatyzacji zarządzania serwerem Minecraft, włączając w to konfigurację, uruchamianie, kopie zapasowe, aktualizacje i monetyzację.

---

## 🗂️ Struktura Projektu

### Planowana Organizacja Plików
```
Minecraft-Server-Automation/
├── README.md                          # Główna dokumentacja (PL)
├── QUICK_START.md                     # Szybki start (PL)
├── PLAN_DZIAŁANIA.md                  # Ten dokument
├── TROUBLESHOOTING.md                 # Przewodnik rozwiązywania problemów
├── COPYRIGHT.md                       # Informacje o prawach autorskich
├── .gitignore                         # Wykluczenia Git
├── config/                            # Pliki konfiguracyjne
│   ├── server.properties.template     # Szablon konfiguracji serwera
│   ├── backup-config.json             # Konfiguracja kopii zapasowych
│   └── monetization-config.json       # Konfiguracja monetyzacji
├── scripts/                           # Główne skrypty
│   ├── MinecraftServerSetup.ps1       # Instalacja i konfiguracja
│   ├── StartServer.ps1                # Uruchamianie serwera
│   ├── StopServer.ps1                 # Zatrzymywanie serwera
│   ├── BackupServer.ps1               # Kopie zapasowe
│   ├── UpdateServer.ps1               # Aktualizacje serwera
│   ├── MonitorServer.ps1              # Monitoring wydajności
│   └── RestoreBackup.ps1              # Przywracanie z kopii
├── logs/                              # Logi (ignorowane przez git)
├── backups/                           # Kopie zapasowe (ignorowane przez git)
└── tests/                             # Testy skryptów
    └── Test-Scripts.ps1               # Testy jednostkowe
```

---

## 📝 Etapy Realizacji

### Etap 1: Fundamenty (Priorytet: WYSOKI)
- [x] Utworzenie podstawowej struktury repozytorium
- [ ] Stworzenie pliku .gitignore
- [ ] Przygotowanie README.md z pełną dokumentacją
- [ ] Stworzenie QUICK_START.md
- [ ] Utworzenie struktury katalogów

### Etap 2: Skrypty Podstawowe (Priorytet: WYSOKI)
- [ ] MinecraftServerSetup.ps1 - instalacja i konfiguracja
  - Pobieranie Java JDK
  - Pobieranie server.jar
  - Pierwsza konfiguracja
  - Akceptacja EULA
- [ ] StartServer.ps1 - uruchamianie serwera
  - Konfiguracja pamięci JVM
  - Kolorowe logi
  - Sprawdzanie wymagań
- [ ] StopServer.ps1 - bezpieczne zatrzymywanie
  - Ostrzeżenia dla graczy
  - Zapis świata
  - Graceful shutdown

### Etap 3: Automatyzacja Zaawansowana (Priorytet: ŚREDNI)
- [ ] BackupServer.ps1 - system kopii zapasowych
  - Automatyczne kopie
  - Kompresja
  - Rotacja starych kopii
  - Weryfikacja integralności
- [ ] UpdateServer.ps1 - aktualizacje
  - Sprawdzanie wersji
  - Bezpieczna aktualizacja
  - Backup przed aktualizacją
  - Rollback w razie problemów
- [ ] RestoreBackup.ps1 - przywracanie
  - Lista dostępnych kopii
  - Weryfikacja przed przywróceniem
  - Bezpieczne przywracanie

### Etap 4: Monitoring i Diagnostyka (Priorytet: ŚREDNI)
- [ ] MonitorServer.ps1 - monitoring
  - Użycie CPU/RAM
  - TPS (Ticks Per Second)
  - Liczba graczy
  - Alerty
- [ ] System logowania
  - Strukturalne logi
  - Rotacja logów
  - Poziomy ważności
- [ ] TROUBLESHOOTING.md - przewodnik

### Etap 5: Monetyzacja i Dodatki (Priorytet: NISKI)
- [ ] Integracja z systemami płatności
- [ ] Zarządzanie rangami/uprawnieniami
- [ ] System sklepu
- [ ] Statystyki i raporty

### Etap 6: Testy i Jakość (Priorytet: WYSOKI)
- [ ] Testy jednostkowe skryptów
- [ ] Testy integracyjne
- [ ] Walidacja na różnych systemach
- [ ] Dokumentacja wszystkich funkcji

---

## ⚠️ Potencjalne Problemy i Rozwiązania

### Problem 1: Kompatybilność Systemów Operacyjnych
**Opis:** PowerShell działa różnie na Windows vs Linux/macOS
**Rozwiązanie:**
- Używać PowerShell Core (7+) zamiast Windows PowerShell
- Stosować `Join-Path` zamiast hardcoded separatorów ścieżek
- Testować na wszystkich platformach
- Używać komend cross-platform

**Kod:**
```powershell
# ❌ ZŁE
$path = "C:\server\world"

# ✅ DOBRE
$path = Join-Path $serverPath "world"
```

### Problem 2: Zarządzanie Pamięcią Java
**Opis:** Niewłaściwa konfiguracja pamięci JVM może prowadzić do crashy
**Rozwiązanie:**
- Xms (min) = 50% Xmx (max) dla lepszej wydajności
- Minimum 512MB RAM dla małych serwerów
- Używać G1GC dla lepszego garbage collection
- Monitorować użycie pamięci

**Kod:**
```powershell
# Dynamiczna alokacja pamięci
$MinMemory = [Math]::Max(512, $MaxMemory / 2)
java -Xms${MinMemory}M -Xmx${MaxMemory}M -XX:+UseG1GC -jar server.jar nogui
```

### Problem 3: Obsługa Błędów i Wyjątków
**Opis:** Skrypty mogą się crashować bez odpowiedniej obsługi błędów
**Rozwiązanie:**
- Używać try-catch we wszystkich krytycznych operacjach
- Dostarczać czytelne komunikaty błędów
- Logować wszystkie błędy
- Umożliwić graceful degradation

**Kod:**
```powershell
try {
    # Operacja ryzykowna
    Start-Process java -ArgumentList $arguments
} catch {
    Write-ColorMessage "Błąd: Nie można uruchomić serwera - $_" "Red"
    Write-Log "ERROR: $($_.Exception.Message)"
    exit 1
}
```

### Problem 4: Dostęp do Plików i Uprawnienia
**Opis:** Brak uprawnień do zapisu/odczytu plików
**Rozwiązanie:**
- Sprawdzać uprawnienia przed operacjami
- Wymagać uruchomienia z odpowiednimi uprawnieniami
- Tworzyć katalogi jeśli nie istnieją
- Używać `-Force` gdzie potrzeba

**Kod:**
```powershell
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
}
```

### Problem 5: Proces Serwera się Zawiesza
**Opis:** Serwer Minecraft nie odpowiada, ale proces wciąż działa
**Rozwiązanie:**
- Implementować timeout dla operacji
- Monitorować responsywność serwera
- Umożliwić force kill w ostateczności
- Zapisywać świat przed kill

**Kod:**
```powershell
# Graceful stop z timeout
$process = Get-Process -Name java -ErrorAction SilentlyContinue
if ($process) {
    $process.CloseMainWindow()
    Start-Sleep -Seconds 30
    if (-not $process.HasExited) {
        $process.Kill()
    }
}
```

### Problem 6: Kopie Zapasowe Zajmują Za Dużo Miejsca
**Opis:** Backupy rosną i zapełniają dysk
**Rozwiązanie:**
- Implementować rotację backupów (np. ostatnie 7 dni)
- Używać kompresji (ZIP)
- Różnicowe backupy dla większych światów
- Opcja przechowywania w chmurze

**Kod:**
```powershell
# Usuwanie starych backupów
Get-ChildItem $backupDir -Filter "*.zip" | 
    Where-Object { $_.CreationTime -lt (Get-Date).AddDays(-7) } |
    Remove-Item -Force
```

### Problem 7: Aktualizacje Psują Świat
**Opis:** Nowa wersja serwera nie jest kompatybilna z istniejącym światem
**Rozwiązanie:**
- ZAWSZE robić backup przed aktualizacją
- Sprawdzać changelog wersji
- Testować aktualizacje na kopii świata
- Umożliwić łatwy rollback

**Kod:**
```powershell
# Backup przed aktualizacją
Write-ColorMessage "Tworzenie kopii zapasowej przed aktualizacją..." "Yellow"
& $PSScriptRoot\BackupServer.ps1 -BackupName "pre-update-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
```

### Problem 8: Brak Java lub Niewłaściwa Wersja
**Opis:** Serwer wymaga konkretnej wersji Java
**Rozwiązanie:**
- Sprawdzać wersję Java przed startem
- Dostarczać instrukcje instalacji
- Opcjonalnie automatycznie pobierać Java
- Wspierać JAVA_HOME

**Kod:**
```powershell
# Sprawdzanie wersji Java
try {
    $javaVersion = java -version 2>&1 | Select-Object -First 1
    if ($javaVersion -match '"(\d+)\.') {
        $majorVersion = [int]$Matches[1]
        if ($majorVersion -lt 17) {
            throw "Wymagana Java 17 lub nowsza. Obecna wersja: $majorVersion"
        }
    }
} catch {
    Write-ColorMessage "Błąd: Java nie jest zainstalowana!" "Red"
    exit 1
}
```

### Problem 9: Konflikty Portów
**Opis:** Port 25565 jest już zajęty przez inny proces
**Rozwiązanie:**
- Sprawdzać dostępność portu przed startem
- Umożliwić konfigurację alternatywnego portu
- Wyświetlać który proces zajmuje port
- Opcja automatycznego wyboru wolnego portu

**Kod:**
```powershell
# Sprawdzanie portu
$port = 25565
$portInUse = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
if ($portInUse) {
    Write-ColorMessage "Port $port jest zajęty!" "Red"
    exit 1
}
```

### Problem 10: Kodowanie Znaków w Logach
**Opis:** Polskie znaki wyświetlają się niepoprawnie
**Rozwiązanie:**
- Używać UTF-8 dla wszystkich plików
- Ustawiać odpowiednie kodowanie w konsoli
- Zapisywać logi w UTF-8
- Testować z polskimi znakami

**Kod:**
```powershell
# Ustawienie kodowania UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
```

### Problem 11: Wydajność podczas Backupów
**Opis:** Backup zamraża serwer lub trwa bardzo długo
**Rozwiązanie:**
- Używać komendy `/save-off` i `/save-on`
- Robić backupy w czasie niskiej aktywności
- Używać szybkiej kompresji
- Backup asynchronicznie jeśli możliwe

**Kod:**
```powershell
# Zatrzymanie auto-save przed backupem
Invoke-MinecraftCommand "save-off"
Invoke-MinecraftCommand "save-all"
Start-Sleep -Seconds 5
# ... backup ...
Invoke-MinecraftCommand "save-on"
```

### Problem 12: Monitorowanie i Alerty
**Opis:** Brak informacji gdy coś idzie nie tak
**Rozwiązanie:**
- Implementować health checks
- Monitoring TPS, RAM, graczy
- Alerty email/webhook przy problemach
- Dashboard ze statusem serwera

**Kod:**
```powershell
# Prosty health check
function Test-ServerHealth {
    $javaProcess = Get-Process -Name java -ErrorAction SilentlyContinue
    if (-not $javaProcess) { return $false }
    
    $memoryUsage = $javaProcess.WorkingSet64 / 1GB
    if ($memoryUsage -gt 0.9 * $MaxMemoryGB) {
        Send-Alert "Wysokie użycie pamięci: $memoryUsage GB"
    }
    
    return $true
}
```

---

## 🔧 Wymagania Techniczne

### Minimalne Wymagania
- **System Operacyjny:** Windows 10/11, Linux (Ubuntu 20.04+), macOS 10.15+
- **PowerShell:** 7.0 lub nowszy (PowerShell Core)
- **Java:** JDK 17 lub nowszy
- **RAM:** Minimum 2GB (zalecane 4GB+)
- **Dysk:** 5GB wolnego miejsca (więcej dla backupów)
- **Sieć:** Otwarte porty (domyślnie 25565)

### Zalecane Narzędzia
- **Git:** Do wersjonowania i aktualizacji
- **7-Zip/tar:** Do kompresji backupów
- **Screen/tmux:** Do uruchamiania w tle (Linux)
- **Windows Terminal:** Lepsze wsparcie kolorów (Windows)

---

## 📚 Standardy i Konwencje

### Kod PowerShell
1. **Nazewnictwo:**
   - PascalCase dla funkcji: `Start-MinecraftServer`
   - camelCase dla zmiennych: `$serverPath`
   - UPPERCASE dla stałych: `$DEFAULT_PORT`

2. **Struktura:**
   - Blok `param()` na początku każdego skryptu
   - Funkcja `Write-ColorMessage` dla wszystkich outputów
   - Try-catch dla obsługi błędów
   - Komentarze w języku polskim

3. **Kompatybilność:**
   - Używać `Join-Path` zamiast hardcoded separatorów
   - Testować na Windows i Linux
   - Obsługiwać różnice platformowe

### Dokumentacja
- **Język:** Polski (PL)
- **Format:** Markdown
- **Struktura:** Jasne nagłówki, przykłady kodu, sekcja rozwiązywania problemów
- **Emoji:** Używać dla lepszej czytelności 🎯 📋 ⚠️

---

## 🎯 Kryteria Sukcesu

### Funkcjonalne
- ✅ Jeden skrypt instaluje i konfiguruje serwer od zera
- ✅ Serwer uruchamia się i działa stabilnie
- ✅ Automatyczne backupy działają bez interakcji użytkownika
- ✅ Aktualizacje są bezpieczne z możliwością rollback
- ✅ System działa na Windows i Linux

### Jakościowe
- ✅ Kod jest czytelny i dobrze udokumentowany
- ✅ Wszystkie operacje logują swoje działania
- ✅ Błędy są obsługiwane gracefully
- ✅ Użytkownik otrzymuje jasne komunikaty
- ✅ Dokumentacja jest kompletna i zrozumiała

### Techniczne
- ✅ Wszystkie skrypty używają try-catch
- ✅ Kolorowe outputy dla lepszego UX
- ✅ Cross-platform path handling
- ✅ Dynamiczna alokacja pamięci JVM
- ✅ Rotacja logów i backupów

---

## 🚀 Quick Start - Przewodnik dla Kontrybutorów

### Jak zacząć rozwijać projekt?

1. **Sklonuj repozytorium:**
```bash
git clone https://github.com/hetwerk1943/Minecraft-Server-Automation.git
cd Minecraft-Server-Automation
```

2. **Przygotuj środowisko:**
```powershell
# Sprawdź wersję PowerShell (wymagana 7.0+)
$PSVersionTable.PSVersion

# Sprawdź wersję Java (wymagana 17+)
java -version
```

3. **Twórz zgodnie z konwencjami:**
   - Czytaj istniejący kod jako wzór
   - Używaj Write-ColorMessage dla outputów
   - Dodawaj try-catch dla obsługi błędów
   - Dokumentuj w języku polskim

4. **Testuj przed commitowaniem:**
```powershell
# Testuj na swojej platformie
.\scripts\NazwaSkryptu.ps1 -TestMode

# Sprawdź czy nie ma syntax errors
Get-Command .\scripts\*.ps1 -Syntax
```

---

## 📞 Wsparcie i Kontakt

- **Autor:** Dominik Opałka
- **Email:** hetwerk1943@gmail.com
- **Issues:** https://github.com/hetwerk1943/Minecraft-Server-Automation/issues

---

## 📄 Licencja

© 2025 Dominik Opałka. All Rights Reserved.

Zobacz [COPYRIGHT.md](COPYRIGHT.md) dla szczegółów.

---

## 🔄 Aktualizacje Dokumentu

- **2025-12-07:** Utworzenie kompleksowego planu działania
- Dokument będzie aktualizowany wraz z postępem projektu

---

## ✨ Podsumowanie

Ten plan działania ma na celu:
1. ✅ Zapewnić jasną mapę drogową rozwoju projektu
2. ✅ Przewidzieć i udokumentować potencjalne problemy
3. ✅ Zminimalizować frustrację podczas rozwoju
4. ✅ Umożliwić płynną współpracę
5. ✅ Stworzyć wysokiej jakości, niezawodne narzędzie

**Następny krok:** Rozpocznij od Etapu 1 - stworzenie podstawowej struktury i dokumentacji!
