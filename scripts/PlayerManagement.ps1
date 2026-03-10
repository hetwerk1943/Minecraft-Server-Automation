#Requires -Version 5.1
<#
.SYNOPSIS
    Thin entrypoint for player management. Preserved from original script.
.NOTES
    Full player management logic lives in PlayerManagement.ps1 (root, legacy).
    This entrypoint re-uses it directly for backward compatibility.
#>
param(
    [string]$ServerPath      = '.\MinecraftServer',
    [string]$Action          = 'stats',
    [string]$PlayerName      = '',
    [int]$TopPlayersCount    = 10
)

$ErrorActionPreference = 'Stop'

# Re-use the root script logic for now; forward all parameters
& "$PSScriptRoot/../PlayerManagement.ps1" `
    -ServerPath $ServerPath `
    -Action $Action `
    -PlayerName $PlayerName `
    -TopPlayersCount $TopPlayersCount
