function Start-MinecraftServer {
    <#
    .SYNOPSIS
        Launches the Minecraft server process from a configured server directory.
    .PARAMETER ServerPath
        Path to the Minecraft server directory (must contain server.jar).
    .PARAMETER MaxMemory
        Maximum JVM heap size in MB.
    .PARAMETER MinMemory
        Minimum JVM heap size in MB.
    .PARAMETER NoGUI
        When specified, passes 'nogui' to the server process.
    .PARAMETER LogPath
        Optional directory for structured log output.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ServerPath,

        [Parameter()]
        [ValidateRange(256, 65536)]
        [int]$MaxMemory = 2048,

        [Parameter()]
        [ValidateRange(128, 65536)]
        [int]$MinMemory = 1024,

        [Parameter()]
        [switch]$NoGUI,

        [Parameter()]
        [string]$LogPath = ''
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    Assert-PathSafe -Path $ServerPath -ParameterName 'ServerPath'

    Write-ColorMessage "`n=== Minecraft Server Starter ===" 'Cyan'

    if (-not (Test-Path $ServerPath)) {
        throw "Server directory not found: $ServerPath"
    }

    $serverJar = Join-Path $ServerPath 'server.jar'
    if (-not (Test-Path $serverJar)) {
        throw "server.jar not found in: $ServerPath"
    }

    if (-not (Test-JavaAvailable)) {
        throw 'Java is not installed or not on PATH. Install Java 17+ first.'
    }

    Write-ColorMessage "Max memory : ${MaxMemory} MB" 'White'
    Write-ColorMessage "Min memory : ${MinMemory} MB" 'White'
    if ($NoGUI) {
        Write-ColorMessage "Mode       : nogui" 'White'
    }
    Write-StructuredLog -LogPath $LogPath -Severity 'INFO' -Message "Starting server. Path=$ServerPath MaxMem=$MaxMemory MinMem=$MinMemory NoGUI=$NoGUI"

    $prevLocation = Get-Location
    try {
        Set-Location $ServerPath

        $jvmArgs = @(
            "-Xmx${MaxMemory}M",
            "-Xms${MinMemory}M",
            '-jar',
            'server.jar'
        )
        if ($NoGUI) { $jvmArgs += 'nogui' }

        Write-ColorMessage "`nStarting server...`n" 'Green'
        & java @jvmArgs
    }
    finally {
        Set-Location $prevLocation
    }

    Write-ColorMessage "`n=== Server stopped ===" 'Yellow'
    Write-StructuredLog -LogPath $LogPath -Severity 'INFO' -Message 'Server process stopped.'
}
