# 🎮 Minecraft Server Automation

> **PowerShell Omega scripts + configs for automated Minecraft server management and monetization**

[![PowerShell](https://img.shields.io/badge/PowerShell-7.0+-blue.svg)](https://github.com/PowerShell/PowerShell)
[![Java](https://img.shields.io/badge/Java-17+-orange.svg)](https://adoptium.net/)
[![License](https://img.shields.io/badge/License-All%20Rights%20Reserved-red.svg)](COPYRIGHT.md)
[![Status](https://img.shields.io/badge/Status-In%20Development-yellow.svg)](PLAN_DZIAŁANIA.md)

## 📋 Spis Treści

- [O Projekcie](#-o-projekcie)
- [Status Projektu](#-status-projektu)
- [Funkcje](#-funkcje)
- [Wymagania](#-wymagania)
- [Dokumentacja](#-dokumentacja)
- [Wsparcie](#-wsparcie)
- [Licencja](#-licencja)

---

## 🎯 O Projekcie

**Minecraft Server Automation** to kompleksowy zestaw skryptów PowerShell zaprojektowanych do automatyzacji zarządzania serwerem Minecraft. Projekt ma na celu:

✅ **Uproszczenie instalacji** - jeden skrypt do pełnej konfiguracji serwera  
✅ **Automatyzację zadań** - backupy, aktualizacje, monitoring bez ręcznej interwencji  
✅ **Cross-platform** - działa na Windows, Linux i macOS  
✅ **Bezpieczeństwo** - automatyczne backupy, bezpieczne aktualizacje z rollback  
✅ **Monitoring** - śledzenie wydajności, alerty, logi  
✅ **Łatwość użycia** - kolorowe outputy, jasne komunikaty, polska dokumentacja  

---

## 🚧 Status Projektu

Projekt jest w **aktywnym rozwoju**. Zobacz szczegółowy plan działania:

📖 **[PLAN_DZIAŁANIA.md](PLAN_DZIAŁANIA.md)** - Kompleksowy plan rozwoju projektu  
🔧 **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Przewodnik rozwiązywania problemów  

### Aktualny Etap: Etap 1 - Fundamenty

- [x] Utworzenie podstawowej struktury repozytorium
- [x] Stworzenie pliku .gitignore
- [x] Przygotowanie README.md z pełną dokumentacją
- [x] Stworzenie kompleksowego planu działania
- [x] Utworzenie przewodnika rozwiązywania problemów
- [ ] Stworzenie QUICK_START.md
- [ ] Utworzenie struktury katalogów
- [ ] Przygotowanie pierwszych skryptów

---

## ✨ Funkcje

### 🎯 Planowane Funkcje (Zobacz [PLAN_DZIAŁANIA.md](PLAN_DZIAŁANIA.md))

#### Podstawowe
- 🚀 **Automatyczna instalacja** - pobieranie Java, server.jar, konfiguracja
- ▶️ **Zarządzanie serwerem** - start, stop, restart z graceful shutdown
- 💾 **System backupów** - automatyczne, zaplanowane kopie zapasowe z rotacją
- 🔄 **Aktualizacje** - bezpieczne aktualizacje z backup i rollback
- 📊 **Monitoring** - CPU, RAM, TPS, liczba graczy

#### Zaawansowane
- 🔔 **Alerty** - powiadomienia o problemach (email/webhook)
- 📝 **Logowanie** - strukturalne logi z rotacją
- 🛡️ **Bezpieczeństwo** - weryfikacja backupów, safe mode
- 🌐 **Multi-platform** - Windows, Linux, macOS
- 💰 **Monetyzacja** - integracje z systemami płatności (przyszłość)

---

## 🔧 Wymagania

### Minimalne Wymagania Systemowe

| Komponent | Minimum | Zalecane |
|-----------|---------|----------|
| **System Operacyjny** | Windows 10, Ubuntu 20.04, macOS 10.15 | Windows 11, Ubuntu 22.04, macOS 12+ |
| **PowerShell** | 7.0 | 7.4+ |
| **Java** | JDK 17 | JDK 21 |
| **RAM** | 2GB | 4GB+ |
| **Dysk** | 5GB wolnego miejsca | 20GB+ (dla backupów) |
| **Sieć** | Port 25565 | Stabilne łącze |

### Instalacja Wymagań

#### Windows
```powershell
# PowerShell 7
winget install Microsoft.PowerShell

# Java 17+
winget install EclipseAdoptium.Temurin.17.JDK
```

#### Linux (Ubuntu/Debian)
```bash
# PowerShell 7
wget https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/powershell_7.4.0-1.deb_amd64.deb
sudo dpkg -i powershell_7.4.0-1.deb_amd64.deb

# Java 17+
sudo apt update
sudo apt install openjdk-17-jdk
```

#### macOS
```bash
# PowerShell 7
brew install powershell

# Java 17+
brew install openjdk@17
```

### Weryfikacja Instalacji
```powershell
# Sprawdź PowerShell
$PSVersionTable.PSVersion

# Sprawdź Java
java -version
```

---

## 📚 Dokumentacja

### Główne Dokumenty

| Dokument | Opis |
|----------|------|
| **[README.md](README.md)** | Ten dokument - ogólne informacje o projekcie |
| **[PLAN_DZIAŁANIA.md](PLAN_DZIAŁANIA.md)** | Kompleksowy plan rozwoju z przewidywanymi problemami |
| **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** | Przewodnik rozwiązywania problemów krok po kroku |
| **[QUICK_START.md](QUICK_START.md)** | Szybki start dla początkujących *(wkrótce)* |
| **[COPYRIGHT.md](COPYRIGHT.md)** | Informacje o prawach autorskich |

### Struktura Projektu (Planowana)

```
Minecraft-Server-Automation/
├── 📄 README.md                    # Główna dokumentacja
├── 📄 PLAN_DZIAŁANIA.md            # Plan rozwoju projektu
├── 📄 TROUBLESHOOTING.md           # Rozwiązywanie problemów
├── 📄 QUICK_START.md               # Szybki start
├── 📄 COPYRIGHT.md                 # Prawa autorskie
├── 📄 .gitignore                   # Wykluczenia Git
├── 📁 config/                      # Pliki konfiguracyjne
│   ├── server.properties.template
│   ├── backup-config.json
│   └── monetization-config.json
├── 📁 scripts/                     # Główne skrypty PowerShell
│   ├── MinecraftServerSetup.ps1   # Instalacja
│   ├── StartServer.ps1            # Uruchamianie
│   ├── StopServer.ps1             # Zatrzymywanie
│   ├── BackupServer.ps1           # Backupy
│   ├── UpdateServer.ps1           # Aktualizacje
│   ├── MonitorServer.ps1          # Monitoring
│   └── RestoreBackup.ps1          # Przywracanie
├── 📁 logs/                        # Logi (ignorowane)
├── 📁 backups/                     # Kopie zapasowe (ignorowane)
└── 📁 tests/                       # Testy
    └── Test-Scripts.ps1
```

---

## 🚀 Szybki Start (Gdy skrypty będą gotowe)

### 1. Sklonuj Repozytorium
```bash
git clone https://github.com/hetwerk1943/Minecraft-Server-Automation.git
cd Minecraft-Server-Automation
```

### 2. Instalacja Serwera (Przyszłość)
```powershell
# Automatyczna instalacja i konfiguracja
.\scripts\MinecraftServerSetup.ps1
```

### 3. Uruchomienie Serwera (Przyszłość)
```powershell
# Start serwera z 4GB RAM
.\scripts\StartServer.ps1 -MaxMemory 4096
```

### 4. Zarządzanie (Przyszłość)
```powershell
# Backup
.\scripts\BackupServer.ps1

# Aktualizacja
.\scripts\UpdateServer.ps1

# Stop
.\scripts\StopServer.ps1
```

---

## 🎓 Dla Kontrybutorów

Chcesz pomóc w rozwoju projektu? Świetnie! 

### Jak zacząć?

1. **Przeczytaj dokumentację:**
   - [PLAN_DZIAŁANIA.md](PLAN_DZIAŁANIA.md) - zobacz co jest do zrobienia
   - [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - poznaj częste problemy

2. **Zapoznaj się z konwencjami:**
   - Kod PowerShell zgodny ze standardami
   - Komentarze i dokumentacja w języku polskim
   - Obsługa błędów przez try-catch
   - Cross-platform path handling

3. **Wybierz zadanie:**
   - Zobacz otwarte Issues
   - Sprawdź TODO w PLAN_DZIAŁANIA.md
   - Zaproponuj nowe funkcje

4. **Twórz zgodnie ze standardami:**
```powershell
# Przykładowa struktura skryptu
param(
    [int]$MaxMemory = 2048
)

function Write-ColorMessage {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

try {
    # Główna logika
    Write-ColorMessage "Wykonuję operację..." "Green"
    
} catch {
    Write-ColorMessage "Błąd: $_" "Red"
    exit 1
}
```

---

## 🐛 Zgłaszanie Problemów

Znalazłeś bug? Masz sugestię? 

1. **Sprawdź istniejące Issues** - może problem już jest zgłoszony
2. **Przeczytaj [TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - może znajdziesz rozwiązanie
3. **Utwórz nowy Issue** - używając szablonu z TROUBLESHOOTING.md

### Co powinno zawierać zgłoszenie?
- Opis problemu
- Kroki do reprodukcji
- Oczekiwane vs rzeczywiste zachowanie
- Środowisko (OS, PowerShell, Java)
- Relevantne logi

---

## 💡 FAQ

### Dlaczego PowerShell?
PowerShell Core jest cross-platform, ma doskonałe wsparcie dla automatyzacji, i jest łatwy w nauce. Skrypty działają identycznie na Windows, Linux i macOS.

### Czy mogę używać tego komercyjnie?
Zobacz [COPYRIGHT.md](COPYRIGHT.md) - wszystkie prawa zastrzeżone. Skontaktuj się z autorem w sprawie licencji komercyjnej.

### Czy wspieracie pluginy/mody?
Tak! Skrypty są kompatybilne z Vanilla, Spigot, Paper, Purpur i innymi implementacjami. Pluginy działają normalnie.

### Czy to działa z Bedrock Edition?
Obecnie projekt skupia się na Java Edition. Bedrock może być dodany w przyszłości.

### Jak często robić backupy?
Zalecamy:
- Małe serwery (1-5 graczy): codziennie
- Średnie serwery (5-20 graczy): 2x dziennie
- Duże serwery (20+ graczy): co 4-6 godzin

### Ile pamięci RAM potrzebuję?
- Vanilla (1-5 graczy): 2GB
- Vanilla (5-10 graczy): 4GB
- Z pluginami: +1-2GB
- Z modami: +2-4GB

---

## 📞 Wsparcie

### Potrzebujesz pomocy?

1. **Dokumentacja:**
   - [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - rozwiązywanie problemów
   - [PLAN_DZIAŁANIA.md](PLAN_DZIAŁANIA.md) - szczegółowe informacje

2. **Community:**
   - GitHub Issues - pytania i dyskusje
   - GitHub Discussions - pomysły i feedback

3. **Kontakt bezpośredni:**
   - **Email:** hetwerk1943@gmail.com
   - **GitHub:** [@hetwerk1943](https://github.com/hetwerk1943)

---

## 🙏 Podziękowania

Projekt inspirowany przez społeczność adminów serwerów Minecraft i potrzebę prostszej automatyzacji.

Specjalne podziękowania dla:
- Społeczności PowerShell
- Deweloperów Paper/Spigot
- Wszystkich kontrybutorów

---

## 📄 Licencja

**© 2025 Dominik Opałka. All Rights Reserved.**

Ten projekt jest własnością prywatną. Wszystkie prawa zastrzeżone.  
Zobacz [COPYRIGHT.md](COPYRIGHT.md) dla pełnych informacji.

**Kontakt w sprawie licencji:** hetwerk1943@gmail.com

---

## 🗺️ Roadmap

### ✅ Etap 1: Fundamenty (Aktualny)
- [x] Podstawowa struktura repozytorium
- [x] Dokumentacja i plan działania
- [x] Przewodnik rozwiązywania problemów
- [ ] Struktura katalogów
- [ ] Pierwsze skrypty

### 🚧 Etap 2: Skrypty Podstawowe (Następny)
- [ ] MinecraftServerSetup.ps1
- [ ] StartServer.ps1
- [ ] StopServer.ps1

### 📋 Etap 3: Automatyzacja Zaawansowana
- [ ] BackupServer.ps1
- [ ] UpdateServer.ps1
- [ ] RestoreBackup.ps1

### 🔮 Etap 4: Monitoring i Diagnostyka
- [ ] MonitorServer.ps1
- [ ] System logowania
- [ ] Alerty

### 💰 Etap 5: Monetyzacja
- [ ] Integracje płatności
- [ ] System rangów
- [ ] Sklep

---

## 📊 Status

| Obszar | Status | Postęp |
|--------|--------|--------|
| Dokumentacja | 🟢 W trakcie | 80% |
| Skrypty podstawowe | 🔴 Nie rozpoczęte | 0% |
| Automatyzacja | 🔴 Nie rozpoczęte | 0% |
| Monitoring | 🔴 Nie rozpoczęte | 0% |
| Testy | 🔴 Nie rozpoczęte | 0% |
| **Ogółem** | 🟡 Wczesna faza | 15% |

---

## 🎯 Następne Kroki

1. ✅ ~~Utworzenie podstawowej dokumentacji~~
2. ✅ ~~Stworzenie kompleksowego planu~~
3. ✅ ~~Przewodnik rozwiązywania problemów~~
4. 🔄 Utworzenie Quick Start guide
5. 📝 Rozpoczęcie implementacji skryptów
6. 🧪 Testy pierwszych skryptów

---

**Ostatnia aktualizacja:** 2025-12-07  
**Autor:** Dominik Opałka (hetwerk1943@gmail.com)  
**Status:** Aktywny rozwój

---

<div align="center">

### ⭐ Jeśli projekt Ci się podoba, zostaw gwiazdkę! ⭐

**Made with ❤️ for Minecraft Server Admins**

</div>
