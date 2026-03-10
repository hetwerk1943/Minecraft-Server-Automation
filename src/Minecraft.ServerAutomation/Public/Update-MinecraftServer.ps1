function Update-MinecraftServer {
    <#
    .SYNOPSIS
        Guides through updating the Minecraft server binary, with optional pre-update backup.
    .PARAMETER ServerPath
        Path to the Minecraft server directory.
    .PARAMETER BackupPath
        Path for the pre-update backup archive.
    .PARAMETER Version
        Target server version label (informational).
    .PARAMETER SkipBackup
        When specified, skips creating a backup before updating.
    .PARAMETER LogPath
        Optional directory for structured log output.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ServerPath,

        [Parameter()]
        [string]$BackupPath = '',

        [Parameter()]
        [string]$Version = 'latest',

        [Parameter()]
        [switch]$SkipBackup,

        [Parameter()]
        [string]$LogPath = ''
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    Assert-PathSafe -Path $ServerPath -ParameterName 'ServerPath'
    if (-not [string]::IsNullOrWhiteSpace($BackupPath)) {
        Assert-PathSafe -Path $BackupPath -ParameterName 'BackupPath'
    }

    Write-ColorMessage "`n=== Minecraft Server Update ===" 'Cyan'
    Write-ColorMessage "Server path : $ServerPath" 'White'
    Write-ColorMessage "Target      : $Version`n" 'White'
    Write-StructuredLog -LogPath $LogPath -Severity 'INFO' -Message "Update started. ServerPath=$ServerPath Version=$Version SkipBackup=$SkipBackup"

    if (-not (Test-Path $ServerPath)) {
        throw "Server directory not found: $ServerPath"
    }

    # Show current jar info
    $serverJar = Join-Path $ServerPath 'server.jar'
    if (Test-Path $serverJar) {
        $jarInfo = Get-Item $serverJar
        Write-ColorMessage "Current server.jar: $([Math]::Round($jarInfo.Length / 1MB, 2)) MB  (modified: $($jarInfo.LastWriteTime))" 'White'
    }
    else {
        Write-ColorMessage 'No server.jar found.' 'Yellow'
    }

    # Pre-update backup
    if (-not $SkipBackup) {
        $effectiveBackupPath = if ([string]::IsNullOrWhiteSpace($BackupPath)) {
            Join-Path (Split-Path $ServerPath -Parent) 'Backups'
        }
        else {
            $BackupPath
        }
        Write-ColorMessage "Creating pre-update backup to: $effectiveBackupPath" 'Cyan'
        Write-StructuredLog -LogPath $LogPath -Severity 'INFO' -Message "Pre-update backup to: $effectiveBackupPath"
        Invoke-ServerBackup -ServerPath $ServerPath -BackupPath $effectiveBackupPath -LogPath $LogPath
    }
    else {
        Write-ColorMessage 'Skipping backup (-SkipBackup specified).' 'Yellow'
        Write-StructuredLog -LogPath $LogPath -Severity 'WARN' -Message 'Pre-update backup skipped.'
    }

    # Manual update instructions
    Write-ColorMessage "`nManual steps to update server.jar:" 'Cyan'
    if ($Version -eq 'latest') {
        Write-ColorMessage "  1. Visit: https://www.minecraft.net/en-us/download/server" 'White'
        Write-ColorMessage "  2. Download the latest server.jar" 'White'
    }
    else {
        Write-ColorMessage "  1. Find server.jar for version $Version" 'White'
        Write-ColorMessage "  2. Download server.jar" 'White'
    }
    Write-ColorMessage "  3. Replace server.jar in: $ServerPath" 'White'

    # Verify config files still present
    $requiredFiles = @('eula.txt', 'server.properties')
    $allPresent = $true
    foreach ($file in $requiredFiles) {
        $fp = Join-Path $ServerPath $file
        if (Test-Path $fp) {
            Write-ColorMessage "[OK] $file" 'Green'
        }
        else {
            Write-ColorMessage "[MISSING] $file" 'Red'
            $allPresent = $false
        }
    }
    if (-not $allPresent) {
        Write-ColorMessage 'Some configuration files are missing. Run Install-MinecraftServer to regenerate.' 'Yellow'
        Write-StructuredLog -LogPath $LogPath -Severity 'WARN' -Message 'One or more configuration files missing after update check.'
    }

    Write-ColorMessage "`n=== Update guidance complete ===" 'Green'
    Write-StructuredLog -LogPath $LogPath -Severity 'INFO' -Message 'Update guidance completed.'
}
