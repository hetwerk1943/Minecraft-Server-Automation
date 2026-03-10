function Install-MinecraftServer {
    <#
    .SYNOPSIS
        Prepares a Minecraft server directory with configuration files and a start script.
    .PARAMETER ServerPath
        Path where the server files will be installed.
    .PARAMETER ServerVersion
        Desired server version label (informational; download is manual).
    .PARAMETER ServerPort
        TCP port the server will listen on (written to server.properties).
    .PARAMETER MaxMemory
        Maximum JVM heap in MB (used in start script).
    .PARAMETER LogPath
        Optional directory for structured log output.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ServerPath,

        [Parameter()]
        [string]$ServerVersion = 'latest',

        [Parameter()]
        [ValidateRange(1, 65535)]
        [int]$ServerPort = 25565,

        [Parameter()]
        [ValidateRange(256, 65536)]
        [int]$MaxMemory = 2048,

        [Parameter()]
        [string]$LogPath = ''
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    Assert-PathSafe -Path $ServerPath -ParameterName 'ServerPath'

    Write-ColorMessage "`n=== Minecraft Server Setup ===" 'Cyan'
    Write-ColorMessage "Server path : $ServerPath" 'White'
    Write-ColorMessage "Version     : $ServerVersion" 'White'
    Write-ColorMessage "Port        : $ServerPort" 'White'
    Write-ColorMessage "Max memory  : ${MaxMemory} MB`n" 'White'
    Write-StructuredLog -LogPath $LogPath -Severity 'INFO' -Message "Setup started. ServerPath=$ServerPath Version=$ServerVersion Port=$ServerPort MaxMemory=$MaxMemory"

    # Check Java
    if (-not (Test-JavaAvailable)) {
        Write-ColorMessage 'Java not found on PATH. Install Java 17+ and ensure it is in PATH.' 'Yellow'
        Write-StructuredLog -LogPath $LogPath -Severity 'WARN' -Message 'Java not found on PATH.'
    }

    # Create server directory
    if (-not (Test-Path $ServerPath)) {
        $null = New-Item -ItemType Directory -Path $ServerPath -Force
        Write-ColorMessage "Created server directory: $ServerPath" 'Green'
        Write-StructuredLog -LogPath $LogPath -Severity 'INFO' -Message "Created server directory: $ServerPath"
    }
    else {
        Write-ColorMessage "Server directory already exists: $ServerPath" 'Yellow'
    }

    # Write eula.txt
    $eulaPath = Join-Path $ServerPath 'eula.txt'
    "eula=true" | Out-File -FilePath $eulaPath -Encoding ASCII -Force
    Write-ColorMessage 'Created eula.txt' 'Green'
    Write-StructuredLog -LogPath $LogPath -Severity 'INFO' -Message 'Created eula.txt'

    # Write server.properties
    $propertiesPath = Join-Path $ServerPath 'server.properties'
    @"
server-port=$ServerPort
max-players=20
motd=Minecraft Server - Automated Setup
difficulty=normal
gamemode=survival
pvp=true
enable-command-block=true
"@ | Out-File -FilePath $propertiesPath -Encoding ASCII -Force
    Write-ColorMessage 'Created server.properties' 'Green'
    Write-StructuredLog -LogPath $LogPath -Severity 'INFO' -Message 'Created server.properties'

    # Write start script (cross-platform)
    $minMemory = [Math]::Max(512, [int]($MaxMemory / 2))

    $startBatPath = Join-Path $ServerPath 'start.bat'
    @"
@echo off
java -Xmx${MaxMemory}M -Xms${minMemory}M -jar server.jar nogui
pause
"@ | Out-File -FilePath $startBatPath -Encoding ASCII -Force

    $startShPath = Join-Path $ServerPath 'start.sh'
    @"
#!/usr/bin/env bash
java -Xmx${MaxMemory}M -Xms${minMemory}M -jar server.jar nogui
"@ | Out-File -FilePath $startShPath -Encoding UTF8 -Force

    Write-ColorMessage 'Created start.bat and start.sh' 'Green'
    Write-StructuredLog -LogPath $LogPath -Severity 'INFO' -Message 'Created start.bat and start.sh'

    Write-ColorMessage "`n=== Setup completed successfully ===" 'Green'
    Write-ColorMessage "Place server.jar in: $ServerPath" 'Yellow'
    Write-ColorMessage "Download from: https://www.minecraft.net/en-us/download/server" 'Cyan'
    Write-StructuredLog -LogPath $LogPath -Severity 'INFO' -Message 'Setup completed successfully.'
}
