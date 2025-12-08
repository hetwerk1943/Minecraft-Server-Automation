# 🧪 Tests - Testy Automatyczne

Ten katalog zawiera testy jednostkowe i integracyjne dla skryptów PowerShell.

## 📋 Struktura Testów

### 🎯 Test-Scripts.ps1
**Status:** 🔴 Nie zaimplementowany

Główny plik testowy zawierający testy dla wszystkich skryptów.

**Zawiera testy dla:**
- MinecraftServerSetup.ps1
- StartServer.ps1
- StopServer.ps1
- BackupServer.ps1
- UpdateServer.ps1
- MonitorServer.ps1
- RestoreBackup.ps1

---

## 🚀 Uruchamianie Testów

### Wszystkie testy:
```powershell
.\tests\Test-Scripts.ps1
```

### Konkretny moduł:
```powershell
.\tests\Test-Scripts.ps1 -TestName "Setup"
```

### Z verbose output:
```powershell
.\tests\Test-Scripts.ps1 -Verbose
```

---

## 🎨 Framework Testowy

Używamy **Pester** - framework testowy dla PowerShell.

### Instalacja Pester:
```powershell
# Windows PowerShell 5.1
Install-Module -Name Pester -Force -SkipPublisherCheck

# PowerShell 7+
Install-Module -Name Pester -Force
```

### Weryfikacja instalacji:
```powershell
Get-Module -ListAvailable Pester
```

---

## 📝 Przykład Testu

```powershell
Describe "MinecraftServerSetup Tests" {
    Context "Sprawdzanie wymagań" {
        It "Powinien wykryć PowerShell 7+" {
            $PSVersionTable.PSVersion.Major | Should -BeGreaterOrEqual 7
        }
        
        It "Powinien wykryć Java" {
            $javaVersion = java -version 2>&1
            $javaVersion | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Pobieranie plików" {
        It "Powinien pobrać server.jar" {
            # Mock funkcji pobierania
            Mock Invoke-WebRequest { return @{ StatusCode = 200 } }
            
            # Test logiki
            $result = Get-ServerJar -Version "1.20.4"
            $result | Should -Be $true
        }
    }
}
```

---

## ✅ Checklist Przed Commitem

Przed commitowaniem nowego skryptu, upewnij się że:

- [ ] Wszystkie testy przechodzą
- [ ] Kod coverage > 80%
- [ ] Nie ma syntax errors
- [ ] Działa na Windows i Linux
- [ ] Dokumentacja jest aktualna
- [ ] Nie ma hardcoded passwords/secrets

---

## 📊 Continuous Integration

Testy są automatycznie uruchamiane przez GitHub Actions przy każdym:
- Push do brancha
- Pull Request
- Merge do main

### Zobacz wyniki:
- GitHub Actions tab w repozytorium
- Badge w README.md

---

## 🐛 Debugowanie Testów

### Uruchom z debuggerem:
```powershell
# VSCode
code --wait .\tests\Test-Scripts.ps1

# PowerShell ISE
ise .\tests\Test-Scripts.ps1
```

### Przeglądaj logi:
```powershell
# Włącz szczegółowe logowanie
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

# Uruchom testy
.\tests\Test-Scripts.ps1
```

---

## 📚 Zasoby

- [Pester Documentation](https://pester.dev/)
- [PowerShell Testing Best Practices](https://docs.microsoft.com/powershell/scripting/dev-cross-plat/test/)
- [PLAN_DZIAŁANIA.md](../PLAN_DZIAŁANIA.md) - Plan rozwoju projektu

---

## 🎯 Cel

**100% code coverage** dla wszystkich krytycznych funkcji!

Każdy nowy skrypt MUSI mieć testy przed mergem do main.
