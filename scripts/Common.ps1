# Common.ps1
# Wspólne funkcje używane przez wszystkie skrypty automatyzacji
# © 2025 Dominik Opałka - Minecraft Server Automation

#Requires -Version 7.0

<#
.SYNOPSIS
    Funkcje pomocnicze dla skryptów automatyzacji serwera Minecraft
.DESCRIPTION
    Ten moduł zawiera wspólne funkcje używane przez wszystkie skrypty projektu
#>

# Funkcja do wyświetlania kolorowych komunikatów
function Write-ColorMessage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Type = 'Info'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    switch ($Type) {
        'Info' {
            Write-Host "[$timestamp] [INFO]    " -ForegroundColor Cyan -NoNewline
            Write-Host $Message
        }
        'Success' {
            Write-Host "[$timestamp] [SUCCESS] " -ForegroundColor Green -NoNewline
            Write-Host $Message
        }
        'Warning' {
            Write-Host "[$timestamp] [WARNING] " -ForegroundColor Yellow -NoNewline
            Write-Host $Message
        }
        'Error' {
            Write-Host "[$timestamp] [ERROR]   " -ForegroundColor Red -NoNewline
            Write-Host $Message
        }
    }
}

# Funkcja do sprawdzania wersji PowerShell
function Test-PowerShellVersion {
    param(
        [Parameter(Mandatory = $false)]
        [int]$MinimumVersion = 7
    )
    
    $currentVersion = $PSVersionTable.PSVersion.Major
    
    if ($currentVersion -lt $MinimumVersion) {
        Write-ColorMessage "PowerShell $currentVersion wykryty. Wymagany jest PowerShell $MinimumVersion lub nowszy!" -Type Error
        return $false
    }
    
    Write-ColorMessage "PowerShell $currentVersion - OK ✓" -Type Success
    return $true
}

# Funkcja do sprawdzania czy Java jest zainstalowana
function Test-JavaInstallation {
    param(
        [Parameter(Mandatory = $false)]
        [int]$MinimumVersion = 17
    )
    
    try {
        $javaVersion = java -version 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-ColorMessage "Java nie jest zainstalowana!" -Type Error
            return $false
        }
        
        # Wyciągnij numer wersji z output
        $versionString = $javaVersion | Select-Object -First 1
        if ($versionString -match '(\d+)\.(\d+)\.(\d+)' -or $versionString -match 'version "(\d+)"') {
            $majorVersion = [int]$matches[1]
            
            if ($majorVersion -lt $MinimumVersion) {
                Write-ColorMessage "Java $majorVersion wykryta. Wymagana Java $MinimumVersion lub nowsza!" -Type Warning
                return $false
            }
            
            Write-ColorMessage "Java $majorVersion wykryta - OK ✓" -Type Success
            return $true
        }
        
        Write-ColorMessage "Nie można określić wersji Java" -Type Warning
        return $false
    }
    catch {
        Write-ColorMessage "Błąd podczas sprawdzania Java: $_" -Type Error
        return $false
    }
}

# Funkcja do sprawdzania czy port jest wolny
function Test-Port {
    param(
        [Parameter(Mandatory = $true)]
        [int]$Port
    )
    
    try {
        $tcpConnection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
        
        if ($tcpConnection) {
            Write-ColorMessage "Port $Port jest już używany!" -Type Warning
            return $false
        }
        
        Write-ColorMessage "Port $Port jest wolny - OK ✓" -Type Success
        return $true
    }
    catch {
        # Na systemach Linux/macOS Get-NetTCPConnection może nie działać
        # Używamy alternatywnej metody
        if ($IsLinux -or $IsMacOS) {
            $result = netstat -an | Select-String ":$Port "
            if ($result) {
                Write-ColorMessage "Port $Port jest już używany!" -Type Warning
                return $false
            }
            Write-ColorMessage "Port $Port jest wolny - OK ✓" -Type Success
            return $true
        }
        
        Write-ColorMessage "Nie można sprawdzić portu $Port" -Type Warning
        return $true
    }
}

# Funkcja do pobierania plików z internetu
function Get-FileFromUrl {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url,
        
        [Parameter(Mandatory = $true)]
        [string]$OutputPath,
        
        [Parameter(Mandatory = $false)]
        [string]$Description = "pliku"
    )
    
    try {
        Write-ColorMessage "Pobieranie $Description z: $Url" -Type Info
        
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($Url, $OutputPath)
        
        if (Test-Path $OutputPath) {
            $fileSize = (Get-Item $OutputPath).Length / 1MB
            Write-ColorMessage "Pobrano $Description ($([math]::Round($fileSize, 2)) MB) - OK ✓" -Type Success
            return $true
        }
        
        Write-ColorMessage "Nie udało się pobrać $Description" -Type Error
        return $false
    }
    catch {
        Write-ColorMessage "Błąd podczas pobierania $Description : $_" -Type Error
        return $false
    }
}

# Funkcja do tworzenia katalogu jeśli nie istnieje
function Ensure-Directory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    
    if (-not (Test-Path $Path)) {
        try {
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
            Write-ColorMessage "Utworzono katalog: $Path" -Type Success
            return $true
        }
        catch {
            Write-ColorMessage "Nie można utworzyć katalogu: $Path - $_" -Type Error
            return $false
        }
    }
    
    return $true
}

# Funkcja do sprawdzania wolnego miejsca na dysku
function Test-DiskSpace {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        
        [Parameter(Mandatory = $false)]
        [long]$RequiredSpaceGB = 5
    )
    
    try {
        $drive = (Get-Item $Path).PSDrive
        $freeSpaceGB = [math]::Round($drive.Free / 1GB, 2)
        
        if ($freeSpaceGB -lt $RequiredSpaceGB) {
            Write-ColorMessage "Niewystarczające miejsce na dysku! Wymagane: ${RequiredSpaceGB}GB, Dostępne: ${freeSpaceGB}GB" -Type Error
            return $false
        }
        
        Write-ColorMessage "Wolne miejsce: ${freeSpaceGB}GB - OK ✓" -Type Success
        return $true
    }
    catch {
        Write-ColorMessage "Nie można sprawdzić miejsca na dysku: $_" -Type Warning
        return $true
    }
}

# Funkcja do obliczania optymalnej pamięci dla JVM
function Get-OptimalJvmMemory {
    param(
        [Parameter(Mandatory = $false)]
        [int]$MaxMemoryMB
    )
    
    # Pobierz dostępną pamięć RAM
    if ($IsWindows) {
        $totalMemoryGB = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB
    }
    else {
        # Linux/macOS
        $memInfo = Get-Content /proc/meminfo -ErrorAction SilentlyContinue
        if ($memInfo) {
            $totalMemoryKB = ($memInfo | Select-String "MemTotal:" | ForEach-Object { $_ -replace '\D+(\d+).*', '$1' })
            $totalMemoryGB = [long]$totalMemoryKB / 1MB
        }
        else {
            $totalMemoryGB = 8 # Domyślna wartość jeśli nie można określić
        }
    }
    
    # Jeśli nie podano MaxMemory, użyj 50% dostępnej pamięci
    if (-not $MaxMemoryMB) {
        $MaxMemoryMB = [math]::Floor($totalMemoryGB * 1024 * 0.5)
    }
    
    # MinMemory to połowa MaxMemory, ale minimum 512MB
    $MinMemoryMB = [math]::Max(512, [math]::Floor($MaxMemoryMB / 2))
    
    Write-ColorMessage "Zalecana pamięć JVM: -Xms${MinMemoryMB}M -Xmx${MaxMemoryMB}M" -Type Info
    
    return @{
        MinMemory = $MinMemoryMB
        MaxMemory = $MaxMemoryMB
    }
}

# Eksportuj funkcje
Export-ModuleMember -Function Write-ColorMessage, Test-PowerShellVersion, Test-JavaInstallation, `
    Test-Port, Get-FileFromUrl, Ensure-Directory, Test-DiskSpace, Get-OptimalJvmMemory
