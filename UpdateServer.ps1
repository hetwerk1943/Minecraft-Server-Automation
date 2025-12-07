# UpdateServer.ps1
# Skrypt do aktualizacji serwera Minecraft
# © 2025 Dominik Opałka

param(
    [string]$ServerPath = ".\MinecraftServer",
    [string]$BackupPath = ".\Backups",
    [string]$Version = "latest",
    [switch]$SkipBackup
)

function Write-ColorMessage {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Backup-ServerBeforeUpdate {
    param(
        [string]$ServerPath,
        [string]$BackupPath
    )
    
    try {
        Write-ColorMessage "Tworzenie kopii zapasowej przed aktualizacją..." "Cyan"
        
        if (-not (Test-Path $BackupPath)) {
            New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
        }
        
        $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
        $backupName = "PreUpdate_$timestamp.zip"
        $backupFullPath = Join-Path $BackupPath $backupName
        
        $serverPathPattern = Join-Path $ServerPath "*"
        Compress-Archive -Path $serverPathPattern -DestinationPath $backupFullPath -Force
        
        Write-ColorMessage "Kopia zapasowa utworzona: $backupName" "Green"
        return $true
    }
    catch {
        Write-ColorMessage "Błąd podczas tworzenia kopii zapasowej: $_" "Red"
        return $false
    }
}

function Get-CurrentServerVersion {
    param([string]$ServerPath)
    
    try {
        $serverJar = Join-Path $ServerPath "server.jar"
        
        if (Test-Path $serverJar) {
            $fileInfo = Get-Item $serverJar
            Write-ColorMessage "Obecna wersja serwera (data modyfikacji): $($fileInfo.LastWriteTime)" "White"
            return $true
        }
        else {
            Write-ColorMessage "Brak pliku server.jar" "Yellow"
            return $false
        }
    }
    catch {
        Write-ColorMessage "Błąd podczas sprawdzania wersji: $_" "Red"
        return $false
    }
}

function Get-ManualServerUpdate {
    param(
        [string]$ServerPath,
        [string]$Version
    )
    
    try {
        Write-ColorMessage "Sprawdzanie aktualizacji serwera do wersji: $Version" "Cyan"
        Write-ColorMessage "UWAGA: Ten skrypt wymaga ręcznego pobrania server.jar" "Yellow"
        
        $serverJar = Join-Path $ServerPath "server.jar"
        
        if ($Version -eq "latest") {
            Write-ColorMessage "`nKroki do wykonania:" "Cyan"
            Write-ColorMessage "1. Odwiedź: https://www.minecraft.net/en-us/download/server" "White"
            Write-ColorMessage "2. Pobierz najnowszą wersję server.jar" "White"
            Write-ColorMessage "3. Zastąp stary plik w katalogu: $ServerPath" "White"
        }
        else {
            Write-ColorMessage "`nKroki do wykonania:" "Cyan"
            Write-ColorMessage "1. Znajdź wersję $Version server.jar" "White"
            Write-ColorMessage "2. Pobierz plik server.jar" "White"
            Write-ColorMessage "3. Zastąp stary plik w katalogu: $ServerPath" "White"
        }
        
        # Sprawdzenie czy plik server.jar istnieje
        if (Test-Path $serverJar) {
            $fileInfo = Get-Item $serverJar
            Write-ColorMessage "`nObecny plik server.jar:" "Cyan"
            Write-ColorMessage "  Rozmiar: $([Math]::Round($fileInfo.Length / 1MB, 2)) MB" "White"
            Write-ColorMessage "  Ostatnia modyfikacja: $($fileInfo.LastWriteTime)" "White"
        }
        else {
            Write-ColorMessage "`nBrak pliku server.jar w katalogu serwera" "Red"
        }
        
        return $true
    }
    catch {
        Write-ColorMessage "Błąd podczas sprawdzania aktualizacji: $_" "Red"
        return $false
    }
}

function Test-ServerConfiguration {
    param([string]$ServerPath)
    
    try {
        Write-ColorMessage "Sprawdzanie konfiguracji serwera..." "Cyan"
        
        $requiredFiles = @("eula.txt", "server.properties")
        $allExist = $true
        
        foreach ($file in $requiredFiles) {
            $filePath = Join-Path $ServerPath $file
            if (Test-Path $filePath) {
                Write-ColorMessage "✓ $file" "Green"
            }
            else {
                Write-ColorMessage "✗ $file (brak)" "Red"
                $allExist = $false
            }
        }
        
        return $allExist
    }
    catch {
        Write-ColorMessage "Błąd podczas sprawdzania konfiguracji: $_" "Red"
        return $false
    }
}

# Główna logika skryptu
try {
    Write-ColorMessage "`n=== Minecraft Server Update ===" "Cyan"
    Write-ColorMessage "Ścieżka serwera: $ServerPath" "White"
    Write-ColorMessage "Wersja docelowa: $Version`n" "White"
    
    # Sprawdzenie czy katalog serwera istnieje
    if (-not (Test-Path $ServerPath)) {
        throw "Katalog serwera nie istnieje: $ServerPath"
    }
    
    # Wyświetlenie obecnej wersji
    Get-CurrentServerVersion -ServerPath $ServerPath
    
    # Utworzenie kopii zapasowej (jeśli nie pominięto)
    if (-not $SkipBackup) {
        if (-not (Backup-ServerBeforeUpdate -ServerPath $ServerPath -BackupPath $BackupPath)) {
            throw "Nie udało się utworzyć kopii zapasowej przed aktualizacją"
        }
    }
    else {
        Write-ColorMessage "Pominięto tworzenie kopii zapasowej (użyto -SkipBackup)" "Yellow"
    }
    
    # Instrukcje aktualizacji server.jar
    if (-not (Get-ManualServerUpdate -ServerPath $ServerPath -Version $Version)) {
        throw "Nie udało się sprawdzić aktualizacji serwera"
    }
    
    # Sprawdzenie konfiguracji
    if (-not (Test-ServerConfiguration -ServerPath $ServerPath)) {
        Write-ColorMessage "Ostrzeżenie: Niektóre pliki konfiguracyjne są niedostępne" "Yellow"
    }
    
    Write-ColorMessage "`n=== Aktualizacja zakończona ===" "Green"
    Write-ColorMessage "Uruchom serwer za pomocą StartServer.ps1" "Cyan"
}
catch {
    Write-ColorMessage "`n=== Błąd podczas aktualizacji ===" "Red"
    Write-ColorMessage "Szczegóły: $_" "Red"
    Write-ColorMessage $_.ScriptStackTrace "Red"
    exit 1
}
