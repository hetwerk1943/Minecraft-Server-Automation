#Requires -Version 5.1
<#
.SYNOPSIS
    Thin entrypoint for server setup. Delegates to the Minecraft.ServerAutomation module.
.PARAMETER ServerPath
    Path where the server will be installed.
.PARAMETER ServerVersion
    Version label (informational).
.PARAMETER ServerPort
    TCP port for the server.
.PARAMETER MaxMemory
    Maximum JVM heap in MB.
.PARAMETER LogPath
    Optional directory for structured log output.
#>
param(
    [string]$ServerPath    = '.\MinecraftServer',
    [string]$ServerVersion = 'latest',
    [int]$ServerPort       = 25565,
    [int]$MaxMemory        = 2048,
    [string]$LogPath       = ''
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '../src/Minecraft.ServerAutomation/Minecraft.ServerAutomation.psd1') -Force

try {
    Install-MinecraftServer -ServerPath $ServerPath -ServerVersion $ServerVersion `
        -ServerPort $ServerPort -MaxMemory $MaxMemory -LogPath $LogPath
}
catch {
    Write-Error "Setup failed: $_"
    exit 1
}
