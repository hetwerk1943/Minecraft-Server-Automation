# StartServer.ps1
# Uruchamianie serwera Minecraft z odpowiednią konfiguracją
# © 2025 Dominik Opałka - Minecraft Server Automation

#Requires -Version 7.0

<#
.SYNOPSIS
    Uruchamia serwer Minecraft z odpowiednią konfiguracją JVM
.DESCRIPTION
    Ten skrypt uruchamia serwer Minecraft z:
    - Optymalną konfiguracją pamięci JVM
    - Kolorowymi logami konsoli
    - Sprawdzaniem wymagań przed startem
    - Monitorowaniem procesu
.PARAMETER MaxMemory
    Maksymalna pamięć RAM dla serwera w MB (domyślnie: odczyt z config)
.PARAMETER MinMemory
    Minimalna pamięć RAM dla serwera w MB (domyślnie: połowa MaxMemory)
.PARAMETER ServerPath
    Ścieżka do katalogu serwera (domyślnie: bieżący katalog)
.PARAMETER NoGui
    Uruchom bez GUI (domyślnie: true)
.EXAMPLE
    .\StartServer.ps1 -MaxMemory 4096
.EXAMPLE
    .\StartServer.ps1 -MaxMemory 8192 -MinMemory 4096
#>

param(
    [Parameter(Mandatory = $false)]
    [int]$MaxMemory = 0,
    
    [Parameter(Mandatory = $false)]
    [int]$MinMemory = 0,
    
    [Parameter(Mandatory = $false)]
    [string]$ServerPath = (Get-Location).Path,
    
    [Parameter(Mandatory = $false)]
    [switch]$NoGui = $true
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
    Write-Host "║   ▶️  Minecraft Server Automation - Start  ▶️           ║" -ForegroundColor Cyan
    Write-Host "║   © 2025 Dominik Opałka                                  ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

# Główna funkcja startu
function Start-MinecraftServer {
    Show-Banner
    
    Write-ColorMessage "🚀 Przygotowuję serwer Minecraft do uruchomienia..." -Type Info
    Write-Host ""
    
    # Krok 1: Sprawdzanie wymagań
    Write-ColorMessage "📋 Krok 1/5: Sprawdzanie wymagań..." -Type Info
    
    if (-not (Test-PowerShellVersion -MinimumVersion 7)) {
        Write-ColorMessage "❌ Uruchomienie przerwane - nieodpowiednia wersja PowerShell" -Type Error
        exit 1
    }
    
    if (-not (Test-JavaInstallation -MinimumVersion 17)) {
        Write-ColorMessage "❌ Uruchomienie przerwane - brak Java 17+" -Type Error
        exit 1
    }
    
    Write-Host ""
    
    # Krok 2: Sprawdzanie plików serwera
    Write-ColorMessage "📋 Krok 2/5: Sprawdzanie plików serwera..." -Type Info
    
    $serverJarPath = Join-Path $ServerPath "server.jar"
    if (-not (Test-Path $serverJarPath)) {
        Write-ColorMessage "❌ Nie znaleziono server.jar!" -Type Error
        Write-ColorMessage "   Uruchom najpierw: .\scripts\MinecraftServerSetup.ps1" -Type Info
        exit 1
    }
    
    $eulaPath = Join-Path $ServerPath "eula.txt"
    if (-not (Test-Path $eulaPath)) {
        Write-ColorMessage "❌ Nie znaleziono eula.txt!" -Type Error
        Write-ColorMessage "   Uruchom najpierw: .\scripts\MinecraftServerSetup.ps1" -Type Info
        exit 1
    }
    
    # Sprawdź czy EULA jest zaakceptowane
    $eulaContent = Get-Content $eulaPath
    if ($eulaContent -notmatch 'eula=true') {
        Write-ColorMessage "❌ EULA nie jest zaakceptowane!" -Type Error
        Write-ColorMessage "   Edytuj eula.txt i ustaw eula=true" -Type Info
        Write-ColorMessage "   Przeczytaj EULA: https://aka.ms/MinecraftEULA" -Type Info
        exit 1
    }
    
    Write-ColorMessage "  ✓ server.jar - OK" -Type Success
    Write-ColorMessage "  ✓ eula.txt - OK" -Type Success
    
    Write-Host ""
    
    # Krok 3: Wczytanie konfiguracji
    Write-ColorMessage "📋 Krok 3/5: Wczytywanie konfiguracji..." -Type Info
    
    $configPath = Join-Path $ServerPath "server-config.json"
    if (Test-Path $configPath) {
        $config = Get-Content $configPath | ConvertFrom-Json
        
        if ($MaxMemory -eq 0) {
            $MaxMemory = $config.MaxMemory
        }
        if ($MinMemory -eq 0) {
            $MinMemory = $config.MinMemory
        }
        
        Write-ColorMessage "  ✓ Konfiguracja wczytana z server-config.json" -Type Success
    }
    else {
        Write-ColorMessage "  ⚠️  Brak server-config.json, używam automatycznej konfiguracji" -Type Warning
        
        if ($MaxMemory -eq 0 -or $MinMemory -eq 0) {
            $memoryConfig = Get-OptimalJvmMemory
            $MaxMemory = $memoryConfig.MaxMemory
            $MinMemory = $memoryConfig.MinMemory
        }
    }
    
    Write-ColorMessage "  ℹ️  Pamięć JVM: -Xms${MinMemory}M -Xmx${MaxMemory}M" -Type Info
    
    Write-Host ""
    
    # Krok 4: Przygotowanie argumentów JVM
    Write-ColorMessage "📋 Krok 4/5: Przygotowanie argumentów JVM..." -Type Info
    
    $jvmArgs = @(
        "-Xms${MinMemory}M",
        "-Xmx${MaxMemory}M",
        "-XX:+UseG1GC",
        "-XX:+ParallelRefProcEnabled",
        "-XX:MaxGCPauseMillis=200",
        "-XX:+UnlockExperimentalVMOptions",
        "-XX:+DisableExplicitGC",
        "-XX:+AlwaysPreTouch",
        "-XX:G1NewSizePercent=30",
        "-XX:G1MaxNewSizePercent=40",
        "-XX:G1HeapRegionSize=8M",
        "-XX:G1ReservePercent=20",
        "-XX:G1HeapWastePercent=5",
        "-XX:G1MixedGCCountTarget=4",
        "-XX:InitiatingHeapOccupancyPercent=15",
        "-XX:G1MixedGCLiveThresholdPercent=90",
        "-XX:G1RSetUpdatingPauseTimePercent=5",
        "-XX:SurvivorRatio=32",
        "-XX:+PerfDisableSharedMem",
        "-XX:MaxTenuringThreshold=1",
        "-Dusing.aikars.flags=https://mcflags.emc.gs",
        "-Daikars.new.flags=true"
    )
    
    if ($NoGui) {
        $jvmArgs += "nogui"
    }
    
    Write-ColorMessage "  ✓ Używam zoptymalizowanych flag Aikar's" -Type Success
    Write-ColorMessage "  ℹ️  Więcej info: https://mcflags.emc.gs" -Type Info
    
    Write-Host ""
    
    # Krok 5: Uruchomienie serwera
    Write-ColorMessage "📋 Krok 5/5: Uruchamianie serwera..." -Type Info
    Write-Host ""
    
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║   ✅ Serwer uruchamiany! Logi poniżej...  ✅             ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-ColorMessage "   Aby zatrzymać serwer, użyj: stop" -Type Info
    Write-ColorMessage "   Aby bezpiecznie zatrzymać, użyj: .\scripts\StopServer.ps1" -Type Info
    Write-Host ""
    Write-Host "════════════════════ LOGI SERWERA ════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    # Zmień katalog roboczy na ServerPath
    Push-Location $ServerPath
    
    try {
        # Uruchom serwer
        & java $jvmArgs -jar server.jar
        
        $exitCode = $LASTEXITCODE
        
        Write-Host ""
        Write-Host "══════════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host ""
        
        if ($exitCode -eq 0) {
            Write-ColorMessage "✅ Serwer został zatrzymany prawidłowo" -Type Success
        }
        else {
            Write-ColorMessage "⚠️  Serwer zakończył działanie z kodem: $exitCode" -Type Warning
        }
    }
    catch {
        Write-ColorMessage "❌ Błąd podczas uruchamiania serwera: $_" -Type Error
        exit 1
    }
    finally {
        Pop-Location
    }
}

# Uruchom serwer
try {
    Start-MinecraftServer
}
catch {
    Write-ColorMessage "❌ Błąd krytyczny: $_" -Type Error
    Write-ColorMessage "   Stack trace: $($_.ScriptStackTrace)" -Type Error
    exit 1
}
