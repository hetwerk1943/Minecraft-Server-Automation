# =====================================================================
# Backup Minecraft Server Script
# =====================================================================
# Skrypt do tworzenia kopii zapasowych serwera Minecraft

param(
    [string]$ServerFolder = "C:\MinecraftServer",
    [string]$BackupFolder = "C:\MinecraftBackups",
    [switch]$IncludeLogs = $false
)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  KOPIA ZAPASOWA SERWERA MINECRAFT" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Sprawdź czy folder serwera istnieje
if (-not (Test-Path $ServerFolder)) {
    Write-Error "Folder serwera nie istnieje: $ServerFolder"
    exit 1
}

# Utwórz folder backupów jeśli nie istnieje
if (-not (Test-Path $BackupFolder)) {
    New-Item -Path $BackupFolder -ItemType Directory | Out-Null
    Write-Host "Utworzono folder backupów: $BackupFolder" -ForegroundColor Green
}

# Wygeneruj nazwę pliku backupu z datą
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$backupName = "minecraft_backup_$timestamp"
$backupPath = Join-Path $BackupFolder "$backupName.zip"

Write-Host "Tworzenie kopii zapasowej..." -ForegroundColor Cyan
Write-Host "Źródło: $ServerFolder" -ForegroundColor Yellow
Write-Host "Cel: $backupPath" -ForegroundColor Yellow
Write-Host ""

try {
    # Utwórz tymczasowy folder dla backupu
    $tempBackupFolder = Join-Path $env:TEMP $backupName
    New-Item -Path $tempBackupFolder -ItemType Directory -Force | Out-Null
    
    # Kopiuj ważne pliki i foldery
    $itemsToCopy = @(
        "world",
        "world_nether",
        "world_the_end",
        "server.properties",
        "ops.json",
        "whitelist.json",
        "banned-players.json",
        "banned-ips.json",
        "eula.txt"
    )
    
    foreach ($item in $itemsToCopy) {
        $sourcePath = Join-Path $ServerFolder $item
        if (Test-Path $sourcePath) {
            Write-Host "Kopiowanie: $item" -ForegroundColor Gray
            Copy-Item -Path $sourcePath -Destination $tempBackupFolder -Recurse -Force
        }
    }
    
    # Opcjonalnie kopiuj logi
    if ($IncludeLogs) {
        $logsPath = Join-Path $ServerFolder "logs"
        if (Test-Path $logsPath) {
            Write-Host "Kopiowanie: logs" -ForegroundColor Gray
            Copy-Item -Path $logsPath -Destination $tempBackupFolder -Recurse -Force
        }
    }
    
    # Kompresuj do ZIP
    Write-Host "Kompresowanie..." -ForegroundColor Cyan
    Compress-Archive -Path "$tempBackupFolder\*" -DestinationPath $backupPath -Force
    
    # Usuń tymczasowy folder
    Remove-Item -Path $tempBackupFolder -Recurse -Force
    
    $backupSize = (Get-Item $backupPath).Length / 1MB
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "  KOPIA ZAPASOWA UTWORZONA POMYŚLNIE" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "Plik: $backupPath" -ForegroundColor Green
    Write-Host "Rozmiar: $([math]::Round($backupSize, 2)) MB" -ForegroundColor Green
    
    # Sprawdź liczbę backupów i ostrzeż jeśli jest ich dużo
    $backupCount = (Get-ChildItem $BackupFolder -Filter "minecraft_backup_*.zip").Count
    if ($backupCount -gt 10) {
        Write-Warning "Masz $backupCount kopii zapasowych. Rozważ usunięcie starszych backupów."
    }
    
} catch {
    Write-Error "Błąd podczas tworzenia kopii zapasowej: $_"
    # Sprzątanie w przypadku błędu
    if (Test-Path $tempBackupFolder) {
        Remove-Item -Path $tempBackupFolder -Recurse -Force -ErrorAction SilentlyContinue
    }
    exit 1
}

Write-Host ""
Write-Host "Backup zakończony." -ForegroundColor Cyan
