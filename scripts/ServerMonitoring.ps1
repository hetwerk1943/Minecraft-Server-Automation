#Requires -Version 5.1
<#
.SYNOPSIS
    Thin entrypoint for server monitoring. Delegates to the Minecraft.ServerAutomation module.
.PARAMETER ServerPath
    Path to the Minecraft server directory.
.PARAMETER LogPath
    Path for monitoring logs and reports.
.PARAMETER MonitorIntervalSeconds
    Seconds between health checks in continuous mode.
.PARAMETER GenerateReports
    Generate a daily report instead of continuous monitoring.
.PARAMETER ServerPort
    TCP port to probe for health checks.
#>
param(
    [string]$ServerPath              = '.\MinecraftServer',
    [string]$LogPath                 = '.\Logs',
    [int]$MonitorIntervalSeconds     = 60,
    [switch]$GenerateReports,
    [int]$ServerPort                 = 0
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '../src/Minecraft.ServerAutomation/Minecraft.ServerAutomation.psd1') -Force

try {
    if ($GenerateReports) {
        $check = Get-ServerHealthCheck -ServerPath $ServerPath -ServerPort $ServerPort -LogPath $LogPath
        Write-Host "Server status: $(if ($check.IsOnline) { 'ONLINE' } else { 'OFFLINE' }) (method: $($check.Method))" -ForegroundColor $(if ($check.IsOnline) { 'Green' } else { 'Red' })
        Write-Host $check.Details -ForegroundColor Cyan
    }
    else {
        Write-Host "`n=== Minecraft Server Monitoring ===" -ForegroundColor Cyan
        Write-Host "Server path : $ServerPath" -ForegroundColor White
        Write-Host "Log path    : $LogPath" -ForegroundColor White
        Write-Host "Interval    : $MonitorIntervalSeconds s" -ForegroundColor White
        Write-Host "Press Ctrl+C to stop.`n" -ForegroundColor Yellow

        while ($true) {
            $check = Get-ServerHealthCheck -ServerPath $ServerPath -ServerPort $ServerPort -LogPath $LogPath
            $ts    = Get-Date -Format 'HH:mm:ss'
            $color = if ($check.IsOnline) { 'Green' } else { 'Red' }
            Write-Host "[$ts] $(if ($check.IsOnline) { 'ONLINE ' } else { 'OFFLINE' })  $($check.Details)" -ForegroundColor $color
            Start-Sleep -Seconds $MonitorIntervalSeconds
        }
    }
}
catch {
    Write-Error "Monitoring error: $_"
    exit 1
}
