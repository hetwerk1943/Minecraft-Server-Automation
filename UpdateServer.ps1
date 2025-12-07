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
        
        Compress-Archive -Path "$ServerPath\*" -DestinationPath $backupFullPath -Force
        
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

function Update-ServerJar {
    param(
        [string]$ServerPath,
        [string]$Version
    )
    
    try {
        Write-ColorMessage "Aktualizacja serwera do wersji: $Version" "Cyan"
        
        $serverJar = Join-Path $ServerPath "server.jar"
        
        if ($Version -eq "latest") {
            Write-ColorMessage "Sprawdzanie najnowszej wersji..." "Cyan"
            # Tu powinna być logika pobierania najnowszej wersji z oficjalnego źródła
            Write-ColorMessage "UWAGA: Pobierz najnowszą wersję server.jar ręcznie z:" "Yellow"
            Write-ColorMessage "https://www.minecraft.net/en-us/download/server" "Yellow"
            Write-ColorMessage "I umieść ją w katalogu: $ServerPath" "Yellow"
        }
        else {
            Write-ColorMessage "Pobieranie wersji $Version..." "Cyan"
            Write-ColorMessage "UWAGA: Pobierz wersję $Version ręcznie i umieść w: $ServerPath" "Yellow"
        }
        
        # Sprawdzenie czy plik server.jar został zaktualizowany
        if (Test-Path $serverJar) {
            $fileInfo = Get-Item $serverJar
            Write-ColorMessage "Plik server.jar obecny (ostatnia modyfikacja: $($fileInfo.LastWriteTime))" "Green"
        }
        
        return $true
    }
    catch {
        Write-ColorMessage "Błąd podczas aktualizacji: $_" "Red"
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
    
    # Aktualizacja server.jar
    if (-not (Update-ServerJar -ServerPath $ServerPath -Version $Version)) {
        throw "Nie udało się zaktualizować serwera"
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
