# StartServer.ps1
# Skrypt do uruchamiania serwera Minecraft
# © 2025 Dominik Opałka

param(
    [string]$ServerPath = ".\MinecraftServer",
    [int]$MaxMemory = 2048,
    [int]$MinMemory = 1024,
    [switch]$NoGUI
)

Import-Module (Join-Path $PSScriptRoot "lib\SharedFunctions.psm1") -Force

function Test-ServerFiles {
    param([string]$Path)
    
    $serverJar = Join-Path $Path "server.jar"
    
    if (-not (Test-Path $Path)) {
        Write-ColorMessage "Katalog serwera nie istnieje: $Path" "Red"
        return $false
    }
    
    if (-not (Test-Path $serverJar)) {
        Write-ColorMessage "Brak pliku server.jar w katalogu: $Path" "Red"
        return $false
    }
    
    return $true
}

function Start-MinecraftServer {
    param(
        [string]$Path,
        [int]$MaxMem,
        [int]$MinMem,
        [bool]$NoGUIMode
    )
    
    try {
        # Sprawdzenie Java
        if (-not (Test-JavaInstallation)) {
            Write-ColorMessage "Java nie jest zainstalowana lub niedostępna w PATH" "Red"
            Write-ColorMessage "Zainstaluj Java 17+ i upewnij się, że jest dodana do PATH" "Yellow"
            return $false
        }
        
        $serverJar = Join-Path $Path "server.jar"
        $currentLocation = Get-Location
        
        Set-Location $Path
        
        Write-ColorMessage "Uruchamianie serwera Minecraft..." "Cyan"
        Write-ColorMessage "Maksymalna pamięć: ${MaxMem}MB" "White"
        Write-ColorMessage "Minimalna pamięć: ${MinMem}MB" "White"
        
        $arguments = @(
            "-Xmx${MaxMem}M",
            "-Xms${MinMem}M",
            "-jar",
            "server.jar"
        )
        
        if ($NoGUIMode) {
            $arguments += "nogui"
            Write-ColorMessage "Tryb: nogui" "White"
        }
        
        Write-ColorMessage "`nUruchamianie serwera...`n" "Green"
        
        & java $arguments
        
        Set-Location $currentLocation
        return $true
    }
    catch {
        Write-ColorMessage "Błąd podczas uruchamiania serwera: $_" "Red"
        Set-Location $currentLocation
        return $false
    }
}

# Główna logika skryptu
try {
    Write-ColorMessage "`n=== Minecraft Server Starter ===" "Cyan"
    
    # Sprawdzenie czy serwer istnieje
    if (-not (Test-ServerFiles -Path $ServerPath)) {
        throw "Nie znaleziono plików serwera"
    }
    
    # Uruchomienie serwera
    if (-not (Start-MinecraftServer -Path $ServerPath -MaxMem $MaxMemory -MinMem $MinMemory -NoGUIMode $NoGUI)) {
        throw "Nie udało się uruchomić serwera"
    }
    
    Write-ColorMessage "`n=== Serwer został zatrzymany ===" "Yellow"
}
catch {
    Write-ColorMessage "`n=== Błąd ===" "Red"
    Write-ColorMessage "Szczegóły: $_" "Red"
    exit 1
}
