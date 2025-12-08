# 📜 Scripts - Skrypty PowerShell

Ten katalog zawiera główne skrypty automatyzacji serwera Minecraft.

## 📋 Skrypty Podstawowe

### 🚀 MinecraftServerSetup.ps1
**Status:** 🔴 Nie zaimplementowany

Automatyczna instalacja i konfiguracja serwera Minecraft.

**Funkcje:**
- Sprawdzanie wymagań systemowych
- Pobieranie Java JDK (jeśli brak)
- Pobieranie server.jar
- Pierwsza konfiguracja
- Automatyczna akceptacja EULA
- Generowanie domyślnej konfiguracji

**Użycie:**
```powershell
.\scripts\MinecraftServerSetup.ps1 [-ServerVersion "1.20.4"] [-MaxMemory 4096]
```

---

### ▶️ StartServer.ps1
**Status:** 🔴 Nie zaimplementowany

Uruchamianie serwera Minecraft z odpowiednią konfiguracją.

**Funkcje:**
- Konfiguracja pamięci JVM (Xms, Xmx)
- Kolorowe logi konsoli
- Sprawdzanie wymagań przed startem
- Automatyczne tworzenie skryptów startowych
- Monitorowanie procesu

**Użycie:**
```powershell
.\scripts\StartServer.ps1 [-MaxMemory 4096] [-MinMemory 2048]
```

---

### 🛑 StopServer.ps1
**Status:** 🔴 Nie zaimplementowany

Bezpieczne zatrzymywanie serwera Minecraft.

**Funkcje:**
- Ostrzeżenia dla graczy (countdown)
- Zapis świata przed zatrzymaniem
- Graceful shutdown
- Timeout z force kill
- Logowanie operacji

**Użycie:**
```powershell
.\scripts\StopServer.ps1 [-Countdown 60] [-Force]
```

---

## 🔄 Skrypty Automatyzacji (Planowane)

### 💾 BackupServer.ps1
System automatycznych kopii zapasowych.

### 🔄 UpdateServer.ps1
Bezpieczne aktualizacje z backup i rollback.

### 📊 MonitorServer.ps1
Monitoring wydajności w czasie rzeczywistym.

### ↩️ RestoreBackup.ps1
Przywracanie z kopii zapasowej.

---

## 📚 Konwencje Kodowania

Wszystkie skrypty w tym katalogu powinny przestrzegać następujących zasad:

1. **Nazewnictwo:**
   - PascalCase dla funkcji
   - camelCase dla zmiennych
   - UPPERCASE dla stałych

2. **Struktura:**
   - Blok `param()` na początku
   - Funkcja `Write-ColorMessage` dla outputów
   - Try-catch dla obsługi błędów
   - Komentarze w języku polskim

3. **Cross-platform:**
   - Używaj `Join-Path` zamiast hardcoded separatorów
   - Testuj na Windows i Linux
   - Obsługuj różnice platformowe

## 🧪 Testowanie

Przed commitowaniem, przetestuj skrypt:
```powershell
# Sprawdź składnię
Get-Command .\scripts\TwojaSkrypt.ps1 -Syntax

# Uruchom w trybie testowym
.\scripts\TwojaSkrypt.ps1 -WhatIf
```

---

**Zobacz także:**
- [PLAN_DZIAŁANIA.md](../PLAN_DZIAŁANIA.md) - Szczegółowy plan rozwoju
- [TROUBLESHOOTING.md](../TROUBLESHOOTING.md) - Rozwiązywanie problemów
