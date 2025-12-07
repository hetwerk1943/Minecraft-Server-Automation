# =====================================================================
# Update Minecraft Server Script
# =====================================================================
# Skrypt do aktualizacji serwera Minecraft do nowszej wersji

param(
    [string]$ServerFolder = "C:\MinecraftServer",
    [string]$NewServerUrl = "",
    [string]$BackupFolder = "C:\MinecraftBackups",
    [switch]$SkipBackup = $false
)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  AKTUALIZACJA SERWERA MINECRAFT" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Sprawdź czy folder serwera istnieje
if (-not (Test-Path $ServerFolder)) {
    Write-Error "Folder serwera nie istnieje: $ServerFolder"
    exit 1
}

# Sprawdź czy podano URL nowego serwera
if ([string]::IsNullOrEmpty($NewServerUrl)) {
    Write-Host "Nie podano URL nowego serwera." -ForegroundColor Yellow
    Write-Host "Przykład użycia:" -ForegroundColor Cyan
    Write-Host '  .\UpdateServer.ps1 -NewServerUrl "https://piston-data.mojang.com/v1/objects/.../server.jar"' -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Pobierz najnowszy link z: https://www.minecraft.net/download/server" -ForegroundColor Cyan
    exit 1
}

Write-Host "Folder serwera: $ServerFolder" -ForegroundColor Green
Write-Host "Nowy URL: $NewServerUrl" -ForegroundColor Green
Write-Host ""

# Ostrzeżenie
Write-Warning "UWAGA: Aktualizacja serwera może zająć kilka minut."
Write-Warning "Upewnij się, że serwer jest zatrzymany przed kontynuowaniem!"
Write-Host ""

$response = Read-Host "Czy kontynuować aktualizację? (T/N)"
if ($response -ne "T" -and $response -ne "t") {
    Write-Host "Aktualizacja anulowana." -ForegroundColor Yellow
    exit 0
}

# Utwórz backup jeśli nie pominięto
if (-not $SkipBackup) {
    Write-Host ""
    Write-Host "Tworzenie kopii zapasowej przed aktualizacją..." -ForegroundColor Cyan
    try {
        & "$PSScriptRoot\BackupServer.ps1" -ServerFolder $ServerFolder -BackupFolder $BackupFolder
        Write-Host "Kopia zapasowa utworzona pomyślnie." -ForegroundColor Green
    } catch {
        Write-Warning "Nie udało się utworzyć kopii zapasowej: $_"
        $response = Read-Host "Czy kontynuować mimo to? (T/N)"
        if ($response -ne "T" -and $response -ne "t") {
            Write-Host "Aktualizacja anulowana." -ForegroundColor Yellow
            exit 0
        }
    }
}

Write-Host ""
Write-Host "Pobieranie nowej wersji serwera..." -ForegroundColor Cyan

try {
    # Utwórz backup starego pliku JAR
    $oldJarPath = Join-Path $ServerFolder "server.jar"
    if (Test-Path $oldJarPath) {
        $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
        $backupJarPath = Join-Path $ServerFolder "server_backup_$timestamp.jar"
        Copy-Item -Path $oldJarPath -Destination $backupJarPath
        Write-Host "Stary plik JAR zapisany jako: server_backup_$timestamp.jar" -ForegroundColor Yellow
    }
    
    # Pobierz nowy plik JAR
    $newJarPath = Join-Path $ServerFolder "server.jar"
    Write-Host "Pobieranie z: $NewServerUrl" -ForegroundColor Gray
    
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile($NewServerUrl, $newJarPath)
    
    $fileSize = (Get-Item $newJarPath).Length / 1MB
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "  AKTUALIZACJA ZAKOŃCZONA POMYŚLNIE" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "Nowy plik serwera: $newJarPath" -ForegroundColor Green
    Write-Host "Rozmiar: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Green
    Write-Host ""
    Write-Host "Możesz teraz uruchomić serwer używając:" -ForegroundColor Cyan
    Write-Host "  .\StartServer.ps1" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "UWAGA: Światy mogą wymagać konwersji przy pierwszym uruchomieniu." -ForegroundColor Yellow
    
} catch {
    Write-Error "Błąd podczas pobierania nowego serwera: $_"
    
    # Przywróć stary JAR jeśli istnieje backup
    $backupFiles = Get-ChildItem -Path $ServerFolder -Filter "server_backup_*.jar" | Sort-Object LastWriteTime -Descending
    if ($backupFiles.Count -gt 0) {
        $latestBackup = $backupFiles[0]
        Write-Host "Przywracanie poprzedniej wersji z: $($latestBackup.Name)" -ForegroundColor Yellow
        Copy-Item -Path $latestBackup.FullName -Destination $oldJarPath -Force
        Write-Host "Poprzednia wersja przywrócona." -ForegroundColor Green
    }
    
    exit 1
}

Write-Host ""
Write-Host "Aktualizacja zakończona." -ForegroundColor Cyan
