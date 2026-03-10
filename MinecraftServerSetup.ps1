# MinecraftServerSetup.ps1
# Skrypt do konfiguracji i instalacji serwera Minecraft
# © 2025 Dominik Opałka
#
# DEPRECATED: This root script is a compatibility wrapper.
# Use scripts/MinecraftServerSetup.ps1 or Import-Module + Install-MinecraftServer instead.
# This wrapper will be removed in a future release.

param(
    [string]$ServerPath = ".\MinecraftServer",
    [string]$ServerVersion = "latest",
    [int]$ServerPort = 25565,
    [int]$MaxMemory = 2048
)

Write-Warning "MinecraftServerSetup.ps1 at the repository root is deprecated. Use 'scripts/MinecraftServerSetup.ps1' instead."

function Write-ColorMessage {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Test-JavaInstallation {
    try {
        $javaVersion = java -version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-ColorMessage "Java jest zainstalowana: $($javaVersion[0])" "Green"
            return $true
        }
    }
    catch {
        Write-ColorMessage "Java nie została znaleziona. Zainstaluj Javę przed kontynuowaniem." "Red"
        return $false
    }
    return $false
}

function New-ServerDirectory {
    param([string]$Path)
    
    try {
        if (-not (Test-Path $Path)) {
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
            Write-ColorMessage "Utworzono katalog serwera: $Path" "Green"
        }
        else {
            Write-ColorMessage "Katalog serwera już istnieje: $Path" "Yellow"
        }
        return $true
    }
    catch {
        Write-ColorMessage "Błąd podczas tworzenia katalogu: $_" "Red"
        return $false
    }
}

function Get-MinecraftServer {
    param(
        [string]$Path,
        [string]$Version
    )
    
    try {
        Write-ColorMessage "Pobieranie serwera Minecraft wersja: $Version..." "Cyan"
        
        # Przykładowy URL - należy dostosować do konkretnej wersji
        $serverJarPath = Join-Path $Path "server.jar"
        
        if ($Version -eq "latest") {
            Write-ColorMessage "Sprawdzanie najnowszej wersji serwera..." "Cyan"
            # Tu powinna być logika pobierania najnowszej wersji
            # Na razie tylko informacja
            Write-ColorMessage "Pobierz server.jar ręcznie z https://www.minecraft.net/en-us/download/server" "Yellow"
        }
        
        # Tworzenie pliku eula.txt
        $eulaPath = Join-Path $Path "eula.txt"
        "eula=true" | Out-File -FilePath $eulaPath -Encoding ASCII
        Write-ColorMessage "Utworzono plik eula.txt" "Green"
        
        # Tworzenie pliku server.properties
        $propertiesPath = Join-Path $Path "server.properties"
        @"
server-port=$ServerPort
max-players=20
motd=Minecraft Server - Automated Setup
difficulty=normal
gamemode=survival
pvp=true
enable-command-block=true
"@ | Out-File -FilePath $propertiesPath -Encoding ASCII
        Write-ColorMessage "Utworzono plik server.properties" "Green"
        
        return $true
    }
    catch {
        Write-ColorMessage "Błąd podczas konfiguracji serwera: $_" "Red"
        return $false
    }
}

function New-StartScript {
    param(
        [string]$Path,
        [int]$Memory
    )
    
    try {
        $startScriptPath = Join-Path $Path "start.bat"
        $minMemory = [Math]::Max(512, [int]($Memory / 2))
        @"
@echo off
java -Xmx${Memory}M -Xms${minMemory}M -jar server.jar nogui
pause
"@ | Out-File -FilePath $startScriptPath -Encoding ASCII
        Write-ColorMessage "Utworzono skrypt startowy: start.bat" "Green"
        return $true
    }
    catch {
        Write-ColorMessage "Błąd podczas tworzenia skryptu startowego: $_" "Red"
        return $false
    }
}

# Główna logika skryptu
try {
    Write-ColorMessage "`n=== Minecraft Server Setup ===" "Cyan"
    Write-ColorMessage "Ścieżka serwera: $ServerPath" "White"
    Write-ColorMessage "Wersja: $ServerVersion" "White"
    Write-ColorMessage "Port: $ServerPort" "White"
    Write-ColorMessage "Maksymalna pamięć: ${MaxMemory}MB`n" "White"
    
    # Sprawdzenie Java
    if (-not (Test-JavaInstallation)) {
        throw "Java nie jest zainstalowana"
    }
    
    # Utworzenie katalogu
    if (-not (New-ServerDirectory -Path $ServerPath)) {
        throw "Nie udało się utworzyć katalogu serwera"
    }
    
    # Konfiguracja serwera
    if (-not (Get-MinecraftServer -Path $ServerPath -Version $ServerVersion)) {
        throw "Nie udało się skonfigurować serwera"
    }
    
    # Utworzenie skryptu startowego
    if (-not (New-StartScript -Path $ServerPath -Memory $MaxMemory)) {
        throw "Nie udało się utworzyć skryptu startowego"
    }
    
    Write-ColorMessage "`n=== Setup zakończony pomyślnie! ===" "Green"
    Write-ColorMessage "Pamiętaj o umieszczeniu server.jar w katalogu $ServerPath" "Yellow"
    Write-ColorMessage "Uruchom serwer za pomocą StartServer.ps1" "Cyan"
}
catch {
    Write-ColorMessage "`n=== Błąd podczas instalacji ===" "Red"
    Write-ColorMessage "Szczegóły: $_" "Red"
    Write-ColorMessage $_.ScriptStackTrace "Red"
    exit 1
}
