#Requires -Version 5.1
<#
.SYNOPSIS
    Thin entrypoint for starting the server. Delegates to the Minecraft.ServerAutomation module.
.PARAMETER ServerPath
    Path to the Minecraft server directory.
.PARAMETER MaxMemory
    Maximum JVM heap in MB.
.PARAMETER MinMemory
    Minimum JVM heap in MB.
.PARAMETER NoGUI
    Pass 'nogui' to the server process.
.PARAMETER LogPath
    Optional directory for structured log output.
#>
param(
    [string]$ServerPath = '.\MinecraftServer',
    [int]$MaxMemory     = 2048,
    [int]$MinMemory     = 1024,
    [switch]$NoGUI,
    [string]$LogPath    = ''
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '../src/Minecraft.ServerAutomation/Minecraft.ServerAutomation.psd1') -Force

try {
    Start-MinecraftServer -ServerPath $ServerPath -MaxMemory $MaxMemory `
        -MinMemory $MinMemory -NoGUI:$NoGUI -LogPath $LogPath
}
catch {
    Write-Error "Server start failed: $_"
    exit 1
}
