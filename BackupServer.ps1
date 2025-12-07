# BackupServer.ps1
# Skrypt do tworzenia kopii zapasowych serwera Minecraft
# © 2025 Dominik Opałka

param(
    [string]$ServerPath = ".\MinecraftServer",
    [string]$BackupPath = ".\Backups",
    [int]$MaxBackups = 10
)

function Write-ColorMessage {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function New-BackupDirectory {
    param([string]$Path)
    
    try {
        if (-not (Test-Path $Path)) {
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
            Write-ColorMessage "Utworzono katalog kopii zapasowych: $Path" "Green"
        }
        return $true
    }
    catch {
        Write-ColorMessage "Błąd podczas tworzenia katalogu kopii zapasowych: $_" "Red"
        return $false
    }
}

function New-ServerBackup {
    param(
        [string]$ServerPath,
        [string]$BackupPath
    )
    
    try {
        if (-not (Test-Path $ServerPath)) {
            Write-ColorMessage "Katalog serwera nie istnieje: $ServerPath" "Red"
            return $false
        }
        
        $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
        $backupName = "Backup_$timestamp.zip"
        $backupFullPath = Join-Path $BackupPath $backupName
        
        Write-ColorMessage "Tworzenie kopii zapasowej..." "Cyan"
        Write-ColorMessage "Źródło: $ServerPath" "White"
        Write-ColorMessage "Cel: $backupFullPath" "White"
        
        # Kompresja katalogu serwera
        Compress-Archive -Path "$ServerPath\*" -DestinationPath $backupFullPath -Force
        
        $backupSize = (Get-Item $backupFullPath).Length / 1MB
        Write-ColorMessage "Kopia zapasowa utworzona pomyślnie! Rozmiar: $([Math]::Round($backupSize, 2)) MB" "Green"
        
        return $true
    }
    catch {
        Write-ColorMessage "Błąd podczas tworzenia kopii zapasowej: $_" "Red"
        return $false
    }
}

function Remove-OldBackups {
    param(
        [string]$BackupPath,
        [int]$MaxCount
    )
    
    try {
        $backups = Get-ChildItem -Path $BackupPath -Filter "Backup_*.zip" | Sort-Object CreationTime -Descending
        
        if ($backups.Count -gt $MaxCount) {
            $toRemove = $backups | Select-Object -Skip $MaxCount
            Write-ColorMessage "Usuwanie starych kopii zapasowych..." "Yellow"
            
            foreach ($backup in $toRemove) {
                Remove-Item $backup.FullName -Force
                Write-ColorMessage "Usunięto: $($backup.Name)" "Yellow"
            }
            
            Write-ColorMessage "Pozostawiono $MaxCount najnowszych kopii zapasowych" "Green"
        }
        else {
            Write-ColorMessage "Liczba kopii zapasowych ($($backups.Count)) jest mniejsza niż limit ($MaxCount)" "Cyan"
        }
        
        return $true
    }
    catch {
        Write-ColorMessage "Błąd podczas usuwania starych kopii zapasowych: $_" "Red"
        return $false
    }
}

# Główna logika skryptu
try {
    Write-ColorMessage "`n=== Minecraft Server Backup ===" "Cyan"
    Write-ColorMessage "Ścieżka serwera: $ServerPath" "White"
    Write-ColorMessage "Ścieżka kopii zapasowych: $BackupPath" "White"
    Write-ColorMessage "Maksymalna liczba kopii: $MaxBackups`n" "White"
    
    # Utworzenie katalogu kopii zapasowych
    if (-not (New-BackupDirectory -Path $BackupPath)) {
        throw "Nie udało się utworzyć katalogu kopii zapasowych"
    }
    
    # Utworzenie kopii zapasowej
    if (-not (New-ServerBackup -ServerPath $ServerPath -BackupPath $BackupPath)) {
        throw "Nie udało się utworzyć kopii zapasowej"
    }
    
    # Usunięcie starych kopii zapasowych
    if (-not (Remove-OldBackups -BackupPath $BackupPath -MaxCount $MaxBackups)) {
        Write-ColorMessage "Ostrzeżenie: Nie udało się usunąć starych kopii zapasowych" "Yellow"
    }
    
    Write-ColorMessage "`n=== Backup zakończony pomyślnie! ===" "Green"
}
catch {
    Write-ColorMessage "`n=== Błąd podczas tworzenia kopii zapasowej ===" "Red"
    Write-ColorMessage "Szczegóły: $_" "Red"
    Write-ColorMessage $_.ScriptStackTrace "Red"
    exit 1
}
