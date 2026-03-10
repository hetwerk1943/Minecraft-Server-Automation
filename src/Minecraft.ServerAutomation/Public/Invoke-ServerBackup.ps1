function Invoke-ServerBackup {
    <#
    .SYNOPSIS
        Creates a compressed backup of the Minecraft server directory and enforces retention.
    .PARAMETER ServerPath
        Path to the Minecraft server directory.
    .PARAMETER BackupPath
        Path to the backup destination directory.
    .PARAMETER MaxBackups
        Maximum number of backup archives to retain (oldest are deleted first).
    .PARAMETER LogPath
        Optional directory for structured log output.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ServerPath,

        [Parameter(Mandatory = $true)]
        [string]$BackupPath,

        [Parameter()]
        [ValidateRange(1, 9999)]
        [int]$MaxBackups = 10,

        [Parameter()]
        [string]$LogPath = ''
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    Assert-PathSafe -Path $ServerPath -ParameterName 'ServerPath'
    Assert-PathSafe -Path $BackupPath -ParameterName 'BackupPath'

    Write-ColorMessage "`n=== Minecraft Server Backup ===" 'Cyan'
    Write-ColorMessage "Server path : $ServerPath" 'White'
    Write-ColorMessage "Backup path : $BackupPath" 'White'
    Write-ColorMessage "Max backups : $MaxBackups`n" 'White'
    Write-StructuredLog -LogPath $LogPath -Severity 'INFO' -Message "Backup started. ServerPath=$ServerPath BackupPath=$BackupPath MaxBackups=$MaxBackups"

    if (-not (Test-Path $ServerPath)) {
        $msg = "Server directory not found: $ServerPath"
        Write-ColorMessage $msg 'Red'
        Write-StructuredLog -LogPath $LogPath -Severity 'ERROR' -Message $msg
        throw $msg
    }

    # Ensure backup directory exists
    if (-not (Test-Path $BackupPath)) {
        $null = New-Item -ItemType Directory -Path $BackupPath -Force
        Write-ColorMessage "Created backup directory: $BackupPath" 'Green'
        Write-StructuredLog -LogPath $LogPath -Severity 'INFO' -Message "Created backup directory: $BackupPath"
    }

    # Create archive
    $timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
    $backupName = "Backup_$timestamp.zip"
    $backupFullPath = Join-Path $BackupPath $backupName

    Write-ColorMessage 'Creating backup archive...' 'Cyan'
    Write-ColorMessage "Source : $ServerPath" 'White'
    Write-ColorMessage "Target : $backupFullPath" 'White'

    $serverPathPattern = Join-Path $ServerPath '*'
    Compress-Archive -Path $serverPathPattern -DestinationPath $backupFullPath -Force

    $backupSizeMB = [Math]::Round((Get-Item $backupFullPath).Length / 1MB, 2)
    $msg = "Backup created: $backupName ($backupSizeMB MB)"
    Write-ColorMessage $msg 'Green'
    Write-StructuredLog -LogPath $LogPath -Severity 'INFO' -Message $msg

    # Retention: remove oldest backups beyond MaxBackups
    [array]$allBackups = @(
        Get-ChildItem -Path $BackupPath -Filter 'Backup_*.zip' |
            Sort-Object -Property CreationTime -Descending
    )

    if ($allBackups.Count -gt $MaxBackups) {
        $toRemove = $allBackups | Select-Object -Skip $MaxBackups
        Write-ColorMessage 'Removing old backups...' 'Yellow'
        foreach ($old in $toRemove) {
            Remove-Item $old.FullName -Force
            Write-ColorMessage "Removed: $($old.Name)" 'Yellow'
            Write-StructuredLog -LogPath $LogPath -Severity 'INFO' -Message "Removed old backup: $($old.Name)"
        }
        Write-ColorMessage "Retained $MaxBackups most-recent backups." 'Green'
    }
    else {
        Write-ColorMessage "Backup count ($($allBackups.Count)) within limit ($MaxBackups)." 'Cyan'
    }

    Write-ColorMessage "`n=== Backup completed successfully ===" 'Green'
    Write-StructuredLog -LogPath $LogPath -Severity 'INFO' -Message 'Backup completed successfully.'
}
