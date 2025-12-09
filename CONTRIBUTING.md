# Przewodnik Kontrybutora
## Contributing to Minecraft Server Automation

Dziękujemy za zainteresowanie wkładem w projekt Minecraft Server Automation! 🎮

---

## 📋 Spis Treści

1. [Getting Started](#getting-started)
2. [Jak Mogę Pomóc](#jak-moge-pomoc)
3. [Development Setup](#development-setup)
4. [Code Standards](#code-standards)
5. [Testing Guidelines](#testing-guidelines)
6. [Documentation Standards](#documentation-standards)
7. [Pull Request Process](#pull-request-process)
8. [Code Review Guidelines](#code-review)
9. [Community Guidelines](#community)

---

## 1. Getting Started {#getting-started}

### Przed Rozpoczęciem

1. **Przeczytaj dokumentację:**
   - [README.md](README.md) - Overview projektu
   - [EVALUATION.md](EVALUATION.md) - Ocena i analiza
   - [ACTION_PLAN.md](ACTION_PLAN.md) - Plan rozwoju
   - [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Rozwiązywanie problemów

2. **Sprawdź istniejące issues:**
   - Zobacz [Issues](https://github.com/hetwerk1943/Minecraft-Server-Automation/issues)
   - Szukaj tagów: `good first issue`, `help wanted`

3. **Dołącz do community:**
   - GitHub Discussions
   - Discord (będzie dodany)
   - Email: hetwerk1943@gmail.com

### Fork & Clone

```bash
# 1. Fork repozytorium przez GitHub UI

# 2. Clone twojego fork
git clone https://github.com/YOUR-USERNAME/Minecraft-Server-Automation.git
cd Minecraft-Server-Automation

# 3. Dodaj upstream remote
git remote add upstream https://github.com/hetwerk1943/Minecraft-Server-Automation.git

# 4. Weryfikacja
git remote -v
# origin    https://github.com/YOUR-USERNAME/Minecraft-Server-Automation.git (fetch)
# origin    https://github.com/YOUR-USERNAME/Minecraft-Server-Automation.git (push)
# upstream  https://github.com/hetwerk1943/Minecraft-Server-Automation.git (fetch)
# upstream  https://github.com/hetwerk1943/Minecraft-Server-Automation.git (push)
```

---

## 2. Jak Mogę Pomóc {#jak-moge-pomoc}

### 🐛 Zgłaszanie Bugów

Znalazłeś bug? Pomóż nam go naprawić!

**Przed zgłoszeniem:**
1. Sprawdź czy bug nie został już zgłoszony
2. Przejrzyj [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
3. Upewnij się że używasz najnowszej wersji

**Szablon zgłoszenia buga:**
```markdown
**Opis problemu:**
Jasny opis co się dzieje.

**Kroki reprodukcji:**
1. Uruchom skrypt X
2. Wykonaj akcję Y
3. Zobacz błąd Z

**Oczekiwane zachowanie:**
Co powinno się stać.

**Aktualne zachowanie:**
Co się faktycznie dzieje.

**Środowisko:**
- OS: [np. Windows 11, Ubuntu 22.04]
- PowerShell Version: [np. 7.3.0]
- Java Version: [np. 17.0.2]
- Minecraft Version: [np. 1.20.1]

**Logi:**
```
Wklej relevant logi tutaj
```

**Screenshots:**
Jeśli applicable
```

### 💡 Proponowanie Nowych Funkcji

Masz pomysł na nową funkcję?

**Szablon propozycji:**
```markdown
**Feature Request:**
Krótki opis funkcji.

**Problem do rozwiązania:**
Jaki problem rozwiązuje ta funkcja?

**Proponowane rozwiązanie:**
Jak widzisz implementację?

**Alternatywy:**
Czy rozważałeś inne podejścia?

**Dodatkowy kontekst:**
Screeny, mockupy, linki, etc.
```

### 📝 Poprawianie Dokumentacji

Dokumentacja zawsze potrzebuje ulepszeń!

**Areas to help:**
- Poprawianie literówek
- Wyjaśnianie niejasnych sekcji
- Dodawanie przykładów
- Tłumaczenia (TODO: English version)
- Tworzenie tutoriali video

### 💻 Pisanie Kodu

Gotowy do kodowania? Świetnie!

**Good first issues:**
- Tag: `good first issue`
- Małe poprawki
- Dodawanie testów
- Refactoring

**Help wanted:**
- Tag: `help wanted`
- Średnia złożoność
- Nowe funkcje
- Optymalizacje

---

## 3. Development Setup {#development-setup}

### Prerequisites

**Wymagane:**
```powershell
# PowerShell 7.x (zalecane)
winget install Microsoft.PowerShell

# Visual Studio Code
winget install Microsoft.VisualStudioCode

# Git
winget install Git.Git

# Java 17+
winget install EclipseAdoptium.Temurin.17.JDK
```

**Opcjonalne:**
```powershell
# PSScriptAnalyzer (linting)
Install-Module -Name PSScriptAnalyzer -Scope CurrentUser

# Pester (testing)
Install-Module -Name Pester -Scope CurrentUser -Force

# PowerShell extension dla VS Code
# Install przez VS Code Extensions
```

### Local Development Environment

```powershell
# 1. Setup development branch
git checkout -b feature/my-new-feature

# 2. Utwórz test directory
New-Item -ItemType Directory -Path "./test-server" -Force

# 3. Test setup
.\MinecraftServerSetup.ps1 -ServerPath "./test-server" -MaxMemory 2048

# 4. Pobierz test server.jar
# Download vanilla server.jar dla testów
```

### Running Tests

```powershell
# Uruchom wszystkie testy (gdy będą dostępne)
Invoke-Pester -Path "./tests" -Output Detailed

# Uruchom konkretny test
Invoke-Pester -Path "./tests/Unit/MinecraftServerSetup.Tests.ps1"

# Z code coverage
Invoke-Pester -Path "./tests" -CodeCoverage "*.ps1" -Output Detailed
```

### Linting

```powershell
# Lint wszystkich skryptów
Invoke-ScriptAnalyzer -Path "./*.ps1" -Recurse

# Lint konkretnego pliku
Invoke-ScriptAnalyzer -Path "./MinecraftServerSetup.ps1"

# Z severity filter
Invoke-ScriptAnalyzer -Path "./*.ps1" -Severity Error,Warning
```

---

## 4. Code Standards {#code-standards}

### PowerShell Style Guide

**Naming Conventions:**
```powershell
# Variables - PascalCase
$ServerPath = "C:\Server"
$MaxMemory = 4096

# Functions - Verb-Noun format
function Write-ColorMessage { }
function Test-JavaInstallation { }
function New-ServerDirectory { }

# Parameters - PascalCase
param(
    [string]$ServerPath,
    [int]$MaxMemory
)

# Constants - UPPER_CASE (jeśli używane)
$MAX_RETRIES = 3
```

**File Structure:**
```powershell
# 1. Header Comment
# ScriptName.ps1
# Description of script
# © 2025 Dominik Opałka

# 2. Parameters
param(
    [string]$ServerPath = ".\MinecraftServer",
    [int]$MaxMemory = 2048
)

# 3. Helper Functions
function Write-ColorMessage {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# 4. Main Functions
function New-ServerDirectory {
    # Implementation
}

# 5. Main Script Logic
try {
    # Main code here
}
catch {
    Write-ColorMessage "Error: $_" "Red"
    exit 1
}
```

**Error Handling:**
```powershell
# ZAWSZE używaj try-catch dla operacji które mogą failować
try {
    # Risky operation
    New-Item -ItemType Directory -Path $ServerPath -Force -ErrorAction Stop
    Write-ColorMessage "Success!" "Green"
}
catch {
    Write-ColorMessage "Failed: $_" "Red"
    # Cleanup jeśli potrzeba
    return $false
}
```

**Output Messages:**
```powershell
# Używaj Write-ColorMessage wrapper zamiast Write-Host
Write-ColorMessage "Starting server..." "Cyan"
Write-ColorMessage "Server started successfully!" "Green"
Write-ColorMessage "Warning: Low memory" "Yellow"
Write-ColorMessage "Error: Server failed to start" "Red"

# NIE używaj bezpośrednio:
Write-Host "Message" -ForegroundColor Green  # ❌
```

**Path Handling:**
```powershell
# ZAWSZE używaj Join-Path dla cross-platform compatibility
$pluginsPath = Join-Path $ServerPath "plugins"  # ✅

# NIE używaj backslash concatenation:
$pluginsPath = "$ServerPath\plugins"  # ❌ (only Windows)
```

**Comments:**
```powershell
# Komentarze po polsku (język projektu)

# Single-line comments dla krótkich wyjaśnień
$ServerPort = 25565  # Default Minecraft port

<#
Multi-line comments dla dłuższych wyjaśnień
lub documentation blocks
#>
```

**Parameters Validation:**
```powershell
param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ServerPath,
    
    [Parameter(Mandatory=$false)]
    [ValidateRange(512, 32768)]
    [int]$MaxMemory = 2048,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Tebex", "BuyCraft")]
    [string]$DonationSystem = "Tebex"
)
```

### Code Formatting

**Indentation:**
- Używaj 4 spacji (nie tabs)
- VS Code: Ustaw "Tab Size: 4" i "Insert Spaces: true"

**Line Length:**
- Preferowane: Max 100 znaków
- Twarde limit: 120 znaków

**Braces:**
```powershell
# Opening brace na tej samej linii
if ($condition) {
    # code
}

# Function braces
function Test-Function {
    # code
}

# Try-catch
try {
    # code
}
catch {
    # error handling
}
```

**Spacing:**
```powershell
# Spacje wokół operatorów
$result = $a + $b  # ✅
$result=$a+$b      # ❌

# Spacje po przecinkach
function Test($param1, $param2, $param3) { }  # ✅
function Test($param1,$param2,$param3) { }    # ❌

# No spaces wewnątrz nawiasów
if ($condition) { }     # ✅
if ( $condition ) { }   # ❌
```

---

## 5. Testing Guidelines {#testing-guidelines}

### Test Structure (Pester)

```powershell
# MinecraftServerSetup.Tests.ps1
Describe "MinecraftServerSetup" {
    BeforeAll {
        # Setup test environment
        $TestServerPath = Join-Path $TestDrive "TestServer"
    }
    
    Context "When creating server directory" {
        It "Should create directory if not exists" {
            # Arrange
            $path = Join-Path $TestDrive "NewServer"
            
            # Act
            New-ServerDirectory -Path $path
            
            # Assert
            Test-Path $path | Should -Be $true
        }
        
        It "Should not fail if directory exists" {
            # Arrange
            $path = Join-Path $TestDrive "ExistingServer"
            New-Item -ItemType Directory -Path $path -Force
            
            # Act & Assert
            { New-ServerDirectory -Path $path } | Should -Not -Throw
        }
    }
    
    Context "When testing Java installation" {
        It "Should return true if Java is installed" {
            # Requires Java to be installed on test machine
            Test-JavaInstallation | Should -Be $true
        }
    }
    
    AfterAll {
        # Cleanup
        Remove-Item $TestServerPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}
```

### Test Categories

**Unit Tests:**
- Testują pojedyncze funkcje
- Izolowane od external dependencies
- Szybkie wykonanie

**Integration Tests:**
- Testują interakcje między komponentami
- Mogą używać real files/processes
- Wolniejsze wykonanie

**E2E Tests:**
- Testują całe flow
- Full server lifecycle
- Najwolniejsze

### Test Coverage Goals

- **Minimum:** 60% coverage
- **Target:** 80% coverage
- **Functions:** 100% critical paths tested

### Running Tests Locally

```powershell
# All tests
Invoke-Pester -Path "./tests" -Output Detailed

# Specific category
Invoke-Pester -Path "./tests/Unit" -Output Detailed

# With coverage
Invoke-Pester -Path "./tests" -CodeCoverage "*.ps1" -CodeCoverageOutputFile "./coverage.xml"

# Watch mode (re-run on file change)
# Requires: Install-Module -Name Watch-Command
Watch-Command -ScriptBlock { Invoke-Pester -Path "./tests" }
```

---

## 6. Documentation Standards {#documentation-standards}

### Markdown Formatting

**Headers:**
```markdown
# H1 - Document Title
## H2 - Main Sections
### H3 - Subsections
#### H4 - Details

Używaj consistent numbering dla navigation:
## 1. Section One
## 2. Section Two
### 2.1 Subsection
### 2.2 Subsection
```

**Code Blocks:**
````markdown
# Zawsze specify język dla syntax highlighting
```powershell
.\StartServer.ps1 -MaxMemory 4096
```

```yaml
config:
  enabled: true
```

```properties
server-port=25565
```
````

**Lists:**
```markdown
# Unordered lists
- Item 1
- Item 2
  - Sub-item 2.1
  - Sub-item 2.2

# Ordered lists
1. First step
2. Second step
3. Third step

# Checklist
- [ ] Todo item
- [x] Completed item
```

**Links:**
```markdown
# Internal links (relative)
[README](README.md)
[Section](#section-name)

# External links
[GitHub](https://github.com)

# Reference-style
[link-text][reference]

[reference]: https://example.com
```

**Tables:**
```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Data 1   | Data 2   | Data 3   |
| Data 4   | Data 5   | Data 6   |

# Alignment
| Left | Center | Right |
|:-----|:------:|------:|
| L    | C      | R     |
```

### Documentation Language

**Primary Language: Polish**
- Wszystkie dokumenty w języku polskim
- Komentarze w kodzie po polsku
- Commit messages po angielsku (convention)

**Code Comments:**
```powershell
# Komentarze w kodzie po polsku
# Sprawdź czy katalog istnieje
if (Test-Path $ServerPath) {
    # Katalog istnieje, wyświetl ostrzeżenie
    Write-ColorMessage "Katalog już istnieje" "Yellow"
}
```

**Commit Messages (English):**
```bash
# Good commit messages:
git commit -m "Add validation for server path parameter"
git commit -m "Fix memory leak in monitoring script"
git commit -m "Update README with new examples"

# Bad commit messages:
git commit -m "fixes"  # ❌ Not descriptive
git commit -m "Dodano walidację"  # ❌ Should be English
```

### Documentation Requirements

**Każdy skrypt musi mieć:**
1. Header comment z opisem
2. Parameter documentation
3. Function documentation
4. Usage examples
5. Error handling documentation

**Example:**
```powershell
<#
.SYNOPSIS
    Skrypt do konfiguracji serwera Minecraft

.DESCRIPTION
    Ten skrypt automatycznie konfiguruje serwer Minecraft poprzez:
    - Tworzenie struktury katalogów
    - Generowanie plików konfiguracyjnych
    - Konfigurację parametrów JVM

.PARAMETER ServerPath
    Ścieżka do katalogu serwera (domyślnie: .\MinecraftServer)

.PARAMETER MaxMemory
    Maksymalna ilość pamięci RAM w MB (domyślnie: 2048)

.EXAMPLE
    .\MinecraftServerSetup.ps1 -ServerPath "C:\Server" -MaxMemory 4096
    
    Konfiguruje serwer w C:\Server z 4GB RAM

.NOTES
    Autor: Dominik Opałka
    Data: 2025-12-09
    Wersja: 1.0
#>
```

---

## 7. Pull Request Process {#pull-request-process}

### Branch Naming

```bash
# Format: type/short-description

# Types:
feature/add-backup-encryption      # Nowa funkcja
bugfix/fix-memory-leak            # Poprawka buga
hotfix/critical-security-issue    # Pilna poprawka
docs/update-troubleshooting       # Dokumentacja
refactor/optimize-monitoring      # Refactoring
test/add-unit-tests              # Testy
chore/update-dependencies        # Maintenance
```

### Commit Messages

```bash
# Format: type: description

# Examples:
git commit -m "feat: add automatic backup rotation"
git commit -m "fix: resolve memory leak in monitoring"
git commit -m "docs: update CONTRIBUTING guide"
git commit -m "test: add unit tests for backup script"
git commit -m "refactor: optimize path handling"
git commit -m "chore: update PSScriptAnalyzer version"

# Multi-line commits:
git commit -m "fix: resolve server startup issues

- Add validation for Java version
- Improve error messages
- Add retry logic for port binding

Fixes #123"
```

### Before Submitting PR

**Checklist:**
```markdown
- [ ] Kod follows style guide
- [ ] Wszystkie testy przechodzą
- [ ] Dodano nowe testy dla nowej funkcjonalności
- [ ] Zaktualizowano dokumentację
- [ ] Uruchomiono linter (PSScriptAnalyzer)
- [ ] Sprawdzono czy nie ma konfliktów
- [ ] Self-review wykonany
- [ ] Commits są atomic i well-described
```

**Commands to run:**
```powershell
# 1. Sync z upstream
git fetch upstream
git rebase upstream/main

# 2. Run tests
Invoke-Pester -Path "./tests"

# 3. Run linter
Invoke-ScriptAnalyzer -Path "./*.ps1"

# 4. Check for issues
git status
git diff

# 5. Commit if all good
git add .
git commit -m "type: description"
git push origin feature/my-feature
```

### Creating Pull Request

**PR Template:**
```markdown
## Description
Krótki opis zmian w PR.

## Type of Change
- [ ] Bug fix (non-breaking change)
- [ ] New feature (non-breaking change)
- [ ] Breaking change
- [ ] Documentation update
- [ ] Refactoring
- [ ] Test addition

## Related Issues
Fixes #123
Related to #456

## Changes Made
- Added X functionality
- Fixed Y bug
- Updated Z documentation

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing performed

## Screenshots (if applicable)
[Add screenshots here]

## Checklist
- [ ] Code follows style guide
- [ ] Self-review performed
- [ ] Documentation updated
- [ ] Tests passing
- [ ] No conflicts with main
```

### PR Review Process

1. **Automated Checks:**
   - CI/CD pipeline runs
   - Tests execution
   - Linting
   - Security scan

2. **Code Review:**
   - At least 1 approval required
   - Review comments addressed
   - Changes requested implemented

3. **Merge:**
   - Squash and merge (preferred)
   - Regular merge (for large features)
   - Rebase and merge (for clean history)

---

## 8. Code Review Guidelines {#code-review}

### For Authors

**Before requesting review:**
- Self-review your code
- Ensure tests pass
- Update documentation
- Add descriptive PR description

**Responding to feedback:**
- Be open to suggestions
- Ask questions if unclear
- Make requested changes
- Mark conversations as resolved

### For Reviewers

**What to look for:**

**Functionality:**
- Does code do what it's supposed to?
- Are edge cases handled?
- Is error handling appropriate?

**Code Quality:**
- Follows style guide?
- DRY (Don't Repeat Yourself)?
- Readable and maintainable?
- Appropriate complexity?

**Testing:**
- Adequate test coverage?
- Tests are meaningful?
- Edge cases tested?

**Documentation:**
- Code comments where needed?
- Function documentation complete?
- README updated if needed?

**Security:**
- No hardcoded secrets?
- Input validation present?
- No injection vulnerabilities?

**Performance:**
- No obvious bottlenecks?
- Appropriate algorithms?
- Resource usage reasonable?

**Review Comments Format:**
```markdown
# Suggestion
💡 Consider using `Join-Path` here for cross-platform compatibility.

# Question
❓ Why is this timeout set to 5 seconds? Is this enough?

# Issue
⚠️ This could cause a memory leak. Consider using `.Dispose()`.

# Praise
✅ Great error handling here!

# Critical
🔴 Security issue: User input not validated.
```

---

## 9. Community Guidelines {#community}

### Code of Conduct

**Be Respectful:**
- Treat everyone with respect
- Be constructive in feedback
- No harassment or discrimination
- Be patient with beginners

**Be Professional:**
- Keep discussions on-topic
- No spam or self-promotion
- Respect intellectual property
- Follow GitHub's Terms of Service

**Be Helpful:**
- Help others learn
- Share knowledge
- Provide constructive feedback
- Welcome new contributors

### Communication Channels

**GitHub Issues:**
- Bug reports
- Feature requests
- Technical discussions

**GitHub Discussions:**
- General questions
- Ideas and brainstorming
- Show and tell
- Community support

**Email:**
- Security issues: hetwerk1943@gmail.com
- Private matters
- Partnership inquiries

### Recognition

**Contributors will be:**
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Featured on project website (future)
- Invited to contributor events (future)

---

## 🎉 Thank You!

Thank you for contributing to Minecraft Server Automation! Your help makes this project better for everyone. 

**Questions?**
- Open an issue
- Start a discussion
- Email: hetwerk1943@gmail.com

**Happy Coding! 🚀**

---

**Dokument utworzony przez:** GitHub Copilot Agent  
**Wersja:** 1.0  
**Data:** 2025-12-09
