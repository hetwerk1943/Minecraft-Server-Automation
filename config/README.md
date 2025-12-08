# ⚙️ Config - Pliki Konfiguracyjne

Ten katalog zawiera szablony i pliki konfiguracyjne dla serwera Minecraft.

## 📁 Zawartość

### 🎮 server.properties.template
**Status:** 🔴 Nie utworzony

Szablon konfiguracji serwera Minecraft.

**Zawiera:**
- Podstawowe ustawienia serwera
- Konfigurację świata
- Ustawienia sieciowe
- Parametry wydajności

**Użycie:**
Plik jest kopiowany do głównego katalogu podczas pierwszej instalacji.

---

### 💾 backup-config.json
**Status:** 🔴 Nie utworzony

Konfiguracja systemu kopii zapasowych.

**Zawiera:**
```json
{
  "backupDirectory": "./backups",
  "compressionLevel": "Optimal",
  "retentionDays": 7,
  "maxBackups": 10,
  "includePlugins": true,
  "excludePatterns": ["*.tmp", "cache/*"]
}
```

---

### 💰 monetization-config.json
**Status:** 🔴 Nie utworzony (Przyszła wersja)

Konfiguracja systemu monetyzacji.

**Zawiera:**
- Integracje z systemami płatności
- Konfigurację rangów VIP
- Ustawienia sklepu
- Limity czasowe

---

## 🔧 Jak Używać Szablonów

1. **Automatyczne użycie:**
   Skrypt `MinecraftServerSetup.ps1` automatycznie kopiuje szablony.

2. **Ręczne użycie:**
   ```powershell
   # Skopiuj szablon
   Copy-Item config/server.properties.template server.properties
   
   # Edytuj według potrzeb
   notepad server.properties
   ```

3. **Dostosowywanie:**
   - Edytuj szablony w katalogu `config/`
   - Nie modyfikuj aktywnych plików w głównym katalogu
   - Używaj kontroli wersji dla szablonów

---

## 📝 Format Plików

### JSON (*.json)
- Używaj 2 spac do wcięć
- UTF-8 bez BOM
- Waliduj przed commitowaniem

### Properties (*.properties)
- Kodowanie: UTF-8
- Format: `klucz=wartość`
- Komentarze: `#` na początku linii

---

## 🔐 Bezpieczeństwo

⚠️ **NIGDY** nie commituj:
- Haseł
- Kluczy API
- Tokenów autoryzacyjnych
- Danych osobowych

Używaj zmiennych środowiskowych lub plików `.env` (dodanych do `.gitignore`).

---

**Zobacz także:**
- [PLAN_DZIAŁANIA.md](../PLAN_DZIAŁANIA.md) - Plan rozwoju projektu
- [MinecraftServerSetup.ps1](../scripts/MinecraftServerSetup.ps1) - Skrypt instalacyjny
