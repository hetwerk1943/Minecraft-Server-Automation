#Requires -Version 5.1
<#
.SYNOPSIS
    Thin entrypoint for server update. Delegates to the Minecraft.ServerAutomation module.
.PARAMETER ServerPath
    Path to the Minecraft server directory.
.PARAMETER BackupPath
    Path for the pre-update backup.
.PARAMETER Version
    Target version label.
.PARAMETER SkipBackup
    Skip pre-update backup.
.PARAMETER LogPath
    Optional directory for structured log output.
#>
param(
    [string]$ServerPath = '.\MinecraftServer',
    [string]$BackupPath = '.\Backups',
    [string]$Version    = 'latest',
    [switch]$SkipBackup,
    [string]$LogPath    = ''
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '../src/Minecraft.ServerAutomation/Minecraft.ServerAutomation.psd1') -Force

try {
    Update-MinecraftServer -ServerPath $ServerPath -BackupPath $BackupPath `
        -Version $Version -SkipBackup:$SkipBackup -LogPath $LogPath
}
catch {
    Write-Error "Update failed: $_"
    exit 1
}
