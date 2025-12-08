# MinecraftServerSetup.ps1
# Automatyczna instalacja i konfiguracja serwera Minecraft
# © 2025 Dominik Opałka - Minecraft Server Automation

#Requires -Version 7.0

<#
.SYNOPSIS
    Automatyczna instalacja i konfiguracja serwera Minecraft
.DESCRIPTION
    Ten skrypt automatyzuje proces instalacji serwera Minecraft, w tym:
    - Sprawdzanie wymagań systemowych
    - Pobieranie server.jar
    - Konfigurację server.properties
    - Akceptację EULA
.PARAMETER ServerVersion
    Wersja serwera Minecraft do pobrania (domyślnie: latest)
.PARAMETER ServerType
    Typ serwera: vanilla, paper, spigot (domyślnie: paper)
.PARAMETER MaxMemory
    Maksymalna pamięć RAM dla serwera w MB (domyślnie: auto)
.PARAMETER ServerPort
    Port serwera (domyślnie: 25565)
.PARAMETER ServerPath
    Ścieżka instalacji serwera (domyślnie: bieżący katalog)
.EXAMPLE
    .\MinecraftServerSetup.ps1 -ServerType paper -MaxMemory 4096
.EXAMPLE
    .\MinecraftServerSetup.ps1 -ServerVersion "1.20.4" -ServerPort 25566
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$ServerVersion = "latest",
    
    [Parameter(Mandatory = $false)]
    [ValidateSet('vanilla', 'paper', 'spigot')]
    [string]$ServerType = "paper",
    
    [Parameter(Mandatory = $false)]
    [int]$MaxMemory = 0,
    
    [Parameter(Mandatory = $false)]
    [int]$ServerPort = 25565,
    
    [Parameter(Mandatory = $false)]
    [string]$ServerPath = (Get-Location).Path
)

# Importuj wspólne funkcje
$commonScript = Join-Path $PSScriptRoot "Common.ps1"
if (Test-Path $commonScript) {
    . $commonScript
}
else {
    Write-Host "[ERROR] Nie znaleziono pliku Common.ps1!" -ForegroundColor Red
    exit 1
}

# Banner
function Show-Banner {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   🎮 Minecraft Server Automation - Setup  🎮            ║" -ForegroundColor Cyan
    Write-Host "║   © 2025 Dominik Opałka                                  ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

# Główna funkcja setup
function Start-MinecraftServerSetup {
    Show-Banner
    
    Write-ColorMessage "🚀 Rozpoczynam instalację serwera Minecraft..." -Type Info
    Write-ColorMessage "   Typ: $ServerType | Wersja: $ServerVersion | Port: $ServerPort" -Type Info
    Write-Host ""
    
    # Krok 1: Sprawdzanie wymagań systemowych
    Write-ColorMessage "📋 Krok 1/7: Sprawdzanie wymagań systemowych..." -Type Info
    
    if (-not (Test-PowerShellVersion -MinimumVersion 7)) {
        Write-ColorMessage "❌ Instalacja przerwana - nieodpowiednia wersja PowerShell" -Type Error
        exit 1
    }
    
    if (-not (Test-JavaInstallation -MinimumVersion 17)) {
        Write-ColorMessage "❌ Instalacja przerwana - brak Java 17+" -Type Error
        Write-ColorMessage "   Zainstaluj Java z: https://adoptium.net/" -Type Info
        exit 1
    }
    
    if (-not (Test-DiskSpace -Path $ServerPath -RequiredSpaceGB 5)) {
        Write-ColorMessage "❌ Instalacja przerwana - brak miejsca na dysku" -Type Error
        exit 1
    }
    
    Write-Host ""
    
    # Krok 2: Sprawdzanie portu
    Write-ColorMessage "📋 Krok 2/7: Sprawdzanie dostępności portu..." -Type Info
    
    if (-not (Test-Port -Port $ServerPort)) {
        Write-ColorMessage "⚠️  Port $ServerPort jest zajęty, ale kontynuuję..." -Type Warning
    }
    
    Write-Host ""
    
    # Krok 3: Tworzenie struktury katalogów
    Write-ColorMessage "📋 Krok 3/7: Tworzenie struktury katalogów..." -Type Info
    
    $directories = @('logs', 'backups', 'plugins', 'world')
    foreach ($dir in $directories) {
        $dirPath = Join-Path $ServerPath $dir
        if (Ensure-Directory -Path $dirPath) {
            Write-ColorMessage "  ✓ $dir/" -Type Success
        }
    }
    
    Write-Host ""
    
    # Krok 4: Pobieranie server.jar
    Write-ColorMessage "📋 Krok 4/7: Pobieranie server.jar..." -Type Info
    
    $serverJarPath = Join-Path $ServerPath "server.jar"
    
    if (Test-Path $serverJarPath) {
        Write-ColorMessage "⚠️  server.jar już istnieje, pomijam pobieranie" -Type Warning
    }
    else {
        $downloadUrl = Get-ServerDownloadUrl -ServerType $ServerType -Version $ServerVersion
        
        if ($downloadUrl) {
            if (-not (Get-FileFromUrl -Url $downloadUrl -OutputPath $serverJarPath -Description "server.jar")) {
                Write-ColorMessage "❌ Nie udało się pobrać server.jar" -Type Error
                exit 1
            }
        }
        else {
            Write-ColorMessage "❌ Nie można określić URL do pobrania" -Type Error
            exit 1
        }
    }
    
    Write-Host ""
    
    # Krok 5: Konfiguracja server.properties
    Write-ColorMessage "📋 Krok 5/7: Konfiguracja server.properties..." -Type Info
    
    $serverPropertiesPath = Join-Path $ServerPath "server.properties"
    $templatePath = Join-Path (Split-Path $PSScriptRoot -Parent) "config" "server.properties.template"
    
    if (Test-Path $templatePath) {
        Copy-Item $templatePath $serverPropertiesPath -Force
        
        # Aktualizuj port w server.properties
        $content = Get-Content $serverPropertiesPath
        $content = $content -replace 'server-port=25565', "server-port=$ServerPort"
        Set-Content $serverPropertiesPath $content
        
        Write-ColorMessage "  ✓ server.properties utworzony" -Type Success
    }
    else {
        Write-ColorMessage "  ⚠️  Brak szablonu, używam domyślnej konfiguracji" -Type Warning
    }
    
    Write-Host ""
    
    # Krok 6: Akceptacja EULA
    Write-ColorMessage "📋 Krok 6/7: Akceptacja EULA..." -Type Info
    
    $eulaPath = Join-Path $ServerPath "eula.txt"
    $eulaContent = @"
#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://aka.ms/MinecraftEULA).
#Generated by Minecraft Server Automation
eula=true
"@
    
    Set-Content $eulaPath $eulaContent
    Write-ColorMessage "  ✓ EULA zaakceptowane automatycznie" -Type Success
    Write-ColorMessage "  ℹ️  Przeczytaj EULA: https://aka.ms/MinecraftEULA" -Type Info
    
    Write-Host ""
    
    # Krok 7: Obliczanie pamięci JVM
    Write-ColorMessage "📋 Krok 7/7: Konfiguracja pamięci JVM..." -Type Info
    
    if ($MaxMemory -eq 0) {
        $memoryConfig = Get-OptimalJvmMemory
    }
    else {
        $memoryConfig = Get-OptimalJvmMemory -MaxMemoryMB $MaxMemory
    }
    
    # Zapisz konfigurację startową
    $startConfig = @{
        MaxMemory = $memoryConfig.MaxMemory
        MinMemory = $memoryConfig.MinMemory
        ServerPort = $ServerPort
        ServerType = $ServerType
    }
    
    $configPath = Join-Path $ServerPath "server-config.json"
    $startConfig | ConvertTo-Json | Set-Content $configPath
    
    Write-ColorMessage "  ✓ Konfiguracja zapisana w server-config.json" -Type Success
    
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║   ✅ Instalacja zakończona pomyślnie! ✅                 ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-ColorMessage "🎮 Aby uruchomić serwer, użyj:" -Type Success
    Write-ColorMessage "   .\scripts\StartServer.ps1" -Type Info
    Write-Host ""
}

# Funkcja do uzyskania URL pobierania
function Get-ServerDownloadUrl {
    param(
        [string]$ServerType,
        [string]$Version
    )
    
    switch ($ServerType) {
        'vanilla' {
            # Dla vanilla używamy Mojang API
            if ($Version -eq "latest") {
                return "https://piston-data.mojang.com/v1/objects/145ff0858209bcfc164859ba735d4199aafa1eea/server.jar"
            }
            else {
                Write-ColorMessage "⚠️  Automatyczne pobieranie konkretnej wersji vanilla nie jest jeszcze zaimplementowane" -Type Warning
                Write-ColorMessage "   Pobierz ręcznie z: https://www.minecraft.net/download/server" -Type Info
                return $null
            }
        }
        'paper' {
            # Paper API
            if ($Version -eq "latest") {
                return "https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/496/downloads/paper-1.20.4-496.jar"
            }
            else {
                Write-ColorMessage "⚠️  Automatyczne pobieranie konkretnej wersji Paper nie jest jeszcze zaimplementowane" -Type Warning
                Write-ColorMessage "   Pobierz ręcznie z: https://papermc.io/downloads" -Type Info
                return $null
            }
        }
        'spigot' {
            Write-ColorMessage "⚠️  Automatyczne pobieranie Spigot nie jest obsługiwane (wymaga kompilacji)" -Type Warning
            Write-ColorMessage "   Użyj BuildTools z: https://www.spigotmc.org/wiki/buildtools/" -Type Info
            return $null
        }
    }
}

# Uruchom setup
try {
    Start-MinecraftServerSetup
}
catch {
    Write-ColorMessage "❌ Błąd krytyczny podczas instalacji: $_" -Type Error
    Write-ColorMessage "   Stack trace: $($_.ScriptStackTrace)" -Type Error
    exit 1
}
