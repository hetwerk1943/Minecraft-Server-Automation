#Requires -Version 5.1
<#
.SYNOPSIS
    Thin entrypoint for monetization setup. Preserved from original script.
.NOTES
    Full monetization logic lives in MonetizationSetup.ps1 (root, legacy).
    This entrypoint re-uses it directly for backward compatibility.
#>
param(
    [string]$ServerPath      = '.\MinecraftServer',
    [string]$DonationSystem  = 'Tebex',
    [switch]$EnableVIPSystem,
    [switch]$EnableEconomy,
    [string]$CurrencyName    = 'Monety'
)

$ErrorActionPreference = 'Stop'

# Re-use the root script logic for now; forward all parameters
$splat = @{
    ServerPath     = $ServerPath
    DonationSystem = $DonationSystem
    CurrencyName   = $CurrencyName
}
if ($EnableVIPSystem) { $splat['EnableVIPSystem'] = $true }
if ($EnableEconomy) { $splat['EnableEconomy'] = $true }

& "$PSScriptRoot/../MonetizationSetup.ps1" @splat
