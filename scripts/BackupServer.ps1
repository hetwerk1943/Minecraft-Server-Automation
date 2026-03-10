#Requires -Version 5.1
<#
.SYNOPSIS
    Thin entrypoint for server backup. Delegates to the Minecraft.ServerAutomation module.
.PARAMETER ServerPath
    Path to the Minecraft server directory.
.PARAMETER BackupPath
    Path to the backup destination directory.
.PARAMETER MaxBackups
    Maximum number of backup archives to retain.
.PARAMETER LogPath
    Optional directory for structured log output.
#>
param(
    [string]$ServerPath  = '.\MinecraftServer',
    [string]$BackupPath  = '.\Backups',
    [int]$MaxBackups     = 10,
    [string]$LogPath     = ''
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '../src/Minecraft.ServerAutomation/Minecraft.ServerAutomation.psd1') -Force

try {
    Invoke-ServerBackup -ServerPath $ServerPath -BackupPath $BackupPath `
        -MaxBackups $MaxBackups -LogPath $LogPath
}
catch {
    Write-Error "Backup failed: $_"
    exit 1
}
