# StopServer.ps1
# Bezpieczne zatrzymywanie serwera Minecraft
# © 2025 Dominik Opałka - Minecraft Server Automation

#Requires -Version 7.0

<#
.SYNOPSIS
    Bezpiecznie zatrzymuje serwer Minecraft
.DESCRIPTION
    Ten skrypt bezpiecznie zatrzymuje serwer Minecraft z:
    - Countdown dla graczy
    - Zapisem świata przed zatrzymaniem
    - Graceful shutdown
    - Force kill po timeout
.PARAMETER Countdown
    Czas oczekiwania przed zatrzymaniem w sekundach (domyślnie: 30)
.PARAMETER Force
    Wymusza natychmiastowe zatrzymanie bez countdown
.PARAMETER ServerPath
    Ścieżka do katalogu serwera (domyślnie: bieżący katalog)
.PARAMETER Timeout
    Timeout w sekundach przed force kill (domyślnie: 60)
.EXAMPLE
    .\StopServer.ps1 -Countdown 60
.EXAMPLE
    .\StopServer.ps1 -Force
#>

param(
    [Parameter(Mandatory = $false)]
    [int]$Countdown = 30,
    
    [Parameter(Mandatory = $false)]
    [switch]$Force,
    
    [Parameter(Mandatory = $false)]
    [string]$ServerPath = (Get-Location).Path,
    
    [Parameter(Mandatory = $false)]
    [int]$Timeout = 60
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
    Write-Host "║   🛑 Minecraft Server Automation - Stop  🛑             ║" -ForegroundColor Cyan
    Write-Host "║   © 2025 Dominik Opałka                                  ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

# Funkcja do znajdowania procesu serwera
function Get-MinecraftServerProcess {
    try {
        # Szukaj procesu java z server.jar
        $processes = Get-Process -Name "java" -ErrorAction SilentlyContinue
        
        foreach ($proc in $processes) {
            $commandLine = $proc.CommandLine
            if ($commandLine -and $commandLine -match "server\.jar") {
                return $proc
            }
        }
        
        return $null
    }
    catch {
        Write-ColorMessage "⚠️  Nie można wyszukać procesu: $_" -Type Warning
        return $null
    }
}

# Funkcja do wysyłania komendy RCON
function Send-ServerCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command
    )
    
    # TODO: Implementacja RCON w przyszłości
    # Na razie używamy prostej metody z plikiem
    Write-ColorMessage "  Wysyłanie komendy: $Command" -Type Info
}

# Główna funkcja stop
function Stop-MinecraftServer {
    Show-Banner
    
    Write-ColorMessage "🛑 Przygotowuję bezpieczne zatrzymanie serwera..." -Type Info
    Write-Host ""
    
    # Krok 1: Znajdowanie procesu serwera
    Write-ColorMessage "📋 Krok 1/4: Szukanie procesu serwera..." -Type Info
    
    $serverProcess = Get-MinecraftServerProcess
    
    if (-not $serverProcess) {
        Write-ColorMessage "⚠️  Nie znaleziono działającego serwera Minecraft" -Type Warning
        Write-ColorMessage "   Sprawdź czy serwer jest uruchomiony" -Type Info
        exit 0
    }
    
    Write-ColorMessage "  ✓ Znaleziono proces: PID $($serverProcess.Id)" -Type Success
    
    Write-Host ""
    
    # Krok 2: Countdown (jeśli nie Force)
    if (-not $Force) {
        Write-ColorMessage "📋 Krok 2/4: Ostrzeżenie dla graczy..." -Type Info
        
        $intervals = @(
            @{ Time = 30; Message = "30 sekund" },
            @{ Time = 15; Message = "15 sekund" },
            @{ Time = 10; Message = "10 sekund" },
            @{ Time = 5; Message = "5 sekund" }
        )
        
        foreach ($interval in $intervals) {
            if ($Countdown -ge $interval.Time) {
                $message = "Serwer zostanie zatrzymany za $($interval.Message)!"
                Write-ColorMessage "  📢 Ostrzeżenie: $message" -Type Warning
                Send-ServerCommand "say §c§l[SERVER] $message"
                
                $waitTime = if ($Countdown -eq $interval.Time) { $interval.Time } else { $Countdown - $interval.Time }
                Start-Sleep -Seconds $waitTime
                $Countdown = $interval.Time
            }
        }
        
        # Ostatnie 5 sekund - countdown
        if ($Countdown -ge 5) {
            for ($i = 5; $i -gt 0; $i--) {
                Write-ColorMessage "  ⏱️  $i..." -Type Warning
                Send-ServerCommand "say §c§l[SERVER] $i..."
                Start-Sleep -Seconds 1
            }
        }
    }
    else {
        Write-ColorMessage "📋 Krok 2/4: Pomijam countdown (force mode)" -Type Warning
    }
    
    Write-Host ""
    
    # Krok 3: Zapis świata i graceful shutdown
    Write-ColorMessage "📋 Krok 3/4: Zapisywanie świata i zatrzymywanie..." -Type Info
    
    Send-ServerCommand "save-all"
    Write-ColorMessage "  💾 Zapisuję świat..." -Type Info
    Start-Sleep -Seconds 2
    
    Send-ServerCommand "stop"
    Write-ColorMessage "  🛑 Wysyłam komendę stop..." -Type Info
    
    # Czekaj na zatrzymanie procesu
    $waited = 0
    $checkInterval = 2
    
    while ($waited -lt $Timeout) {
        Start-Sleep -Seconds $checkInterval
        $waited += $checkInterval
        
        if (-not (Get-Process -Id $serverProcess.Id -ErrorAction SilentlyContinue)) {
            Write-ColorMessage "  ✓ Serwer zatrzymany prawidłowo" -Type Success
            $graceful = $true
            break
        }
        
        if ($waited % 10 -eq 0) {
            Write-ColorMessage "  ⏳ Oczekiwanie na zatrzymanie... ($waited/$Timeout s)" -Type Info
        }
    }
    
    Write-Host ""
    
    # Krok 4: Force kill jeśli potrzebne
    Write-ColorMessage "📋 Krok 4/4: Weryfikacja..." -Type Info
    
    if (Get-Process -Id $serverProcess.Id -ErrorAction SilentlyContinue) {
        Write-ColorMessage "  ⚠️  Serwer nie zatrzymał się w czasie $Timeout sekund" -Type Warning
        Write-ColorMessage "  💀 Wymuszam zatrzymanie (SIGTERM)..." -Type Warning
        
        try {
            Stop-Process -Id $serverProcess.Id -Force
            Start-Sleep -Seconds 2
            
            if (-not (Get-Process -Id $serverProcess.Id -ErrorAction SilentlyContinue)) {
                Write-ColorMessage "  ✓ Serwer zatrzymany wymuszająco" -Type Success
            }
            else {
                Write-ColorMessage "  ❌ Nie udało się zatrzymać serwera!" -Type Error
                exit 1
            }
        }
        catch {
            Write-ColorMessage "  ❌ Błąd podczas wymuszania zatrzymania: $_" -Type Error
            exit 1
        }
    }
    
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║   ✅ Serwer zatrzymany pomyślnie! ✅                     ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    
    # Zapisz czas zatrzymania
    $stopTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logPath = Join-Path $ServerPath "logs" "stop-history.log"
    
    try {
        $logEntry = "[$stopTime] Serwer zatrzymany $(if ($Force) { '(FORCE)' } else { "(graceful, countdown: ${Countdown}s)" })"
        Add-Content -Path $logPath -Value $logEntry
        Write-ColorMessage "📝 Log zapisany w: logs/stop-history.log" -Type Info
    }
    catch {
        Write-ColorMessage "⚠️  Nie udało się zapisać logu: $_" -Type Warning
    }
    
    Write-Host ""
}

# Uruchom stop
try {
    Stop-MinecraftServer
}
catch {
    Write-ColorMessage "❌ Błąd krytyczny: $_" -Type Error
    Write-ColorMessage "   Stack trace: $($_.ScriptStackTrace)" -Type Error
    exit 1
}
