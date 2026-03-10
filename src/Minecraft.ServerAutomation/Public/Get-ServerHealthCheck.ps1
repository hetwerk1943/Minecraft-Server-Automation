function Get-ServerHealthCheck {
    <#
    .SYNOPSIS
        Performs a lightweight health check on the Minecraft server using multiple heuristics.
    .DESCRIPTION
        Uses three heuristics (tried in order, any positive = online):
          1. PID file written by Start-MinecraftServer (server.pid in ServerPath)
          2. TCP port connectivity check on ServerPort
          3. Log freshness check (logs/latest.log modified within LogFreshnessMinutes)
    .PARAMETER ServerPath
        Path to the Minecraft server directory.
    .PARAMETER ServerPort
        TCP port to probe (default: read from server.properties, fallback 25565).
    .PARAMETER LogFreshnessMinutes
        Maximum age (minutes) of logs/latest.log to consider the server alive.
    .PARAMETER LogPath
        Optional directory for structured log output.
    .OUTPUTS
        [PSCustomObject] with IsOnline, Method, Details properties.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ServerPath,

        [Parameter()]
        [int]$ServerPort = 0,

        [Parameter()]
        [int]$LogFreshnessMinutes = 5,

        [Parameter()]
        [string]$LogPath = ''
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Continue'

    Assert-PathSafe -Path $ServerPath -ParameterName 'ServerPath'

    $result = [PSCustomObject]@{
        IsOnline = $false
        Method   = 'none'
        Details  = ''
    }

    # --- Heuristic 1: PID file ---
    $pidFile = Join-Path $ServerPath 'server.pid'
    if (Test-Path $pidFile) {
        try {
            $pidValue = [int](Get-Content $pidFile -Raw).Trim()
            $proc = Get-Process -Id $pidValue -ErrorAction SilentlyContinue
            if ($proc) {
                $result.IsOnline = $true
                $result.Method   = 'PIDFile'
                $result.Details  = "Process $pidValue ($($proc.Name)) is running."
                Write-StructuredLog -LogPath $LogPath -Severity 'INFO' -Message "Health check OK via PID file. PID=$pidValue"
                return $result
            }
        }
        catch {
            # PID file stale or unreadable; continue to next check
            Write-Verbose "Get-ServerHealthCheck: PID file check skipped: $_"
        }
    }

    # --- Heuristic 2: TCP port probe ---
    $effectivePort = $ServerPort
    if ($effectivePort -le 0) {
        $propsFile = Join-Path $ServerPath 'server.properties'
        if (Test-Path $propsFile) {
            $portLine = Get-Content $propsFile | Where-Object { $_ -match '^server-port\s*=' }
            if ($portLine) {
                $effectivePort = [int]($portLine -replace '^server-port\s*=\s*', '')
            }
        }
    }
    if ($effectivePort -le 0) { $effectivePort = 25565 }

    try {
        $tcp = [System.Net.Sockets.TcpClient]::new()
        $connectTask = $tcp.ConnectAsync('127.0.0.1', $effectivePort)
        $completed = $connectTask.Wait(2000)   # 2-second timeout
        if ($completed -and $tcp.Connected) {
            $result.IsOnline = $true
            $result.Method   = 'TCPPort'
            $result.Details  = "Port $effectivePort is accepting connections."
            Write-StructuredLog -LogPath $LogPath -Severity 'INFO' -Message "Health check OK via TCP port $effectivePort."
            $tcp.Dispose()
            return $result
        }
        $tcp.Dispose()
    }
    catch {
        # Port not open or connection refused; continue to log-freshness check
        Write-Verbose "Get-ServerHealthCheck: TCP port check failed: $_"
    }

    # --- Heuristic 3: Log freshness ---
    $latestLog = Join-Path $ServerPath 'logs/latest.log'
    if (Test-Path $latestLog) {
        $logAge = (Get-Date) - (Get-Item $latestLog).LastWriteTime
        if ($logAge.TotalMinutes -le $LogFreshnessMinutes) {
            $result.IsOnline = $true
            $result.Method   = 'LogFreshness'
            $result.Details  = "logs/latest.log modified $([Math]::Round($logAge.TotalMinutes, 1)) min ago."
            Write-StructuredLog -LogPath $LogPath -Severity 'INFO' -Message "Health check OK via log freshness ($([Math]::Round($logAge.TotalMinutes,1)) min)."
            return $result
        }
    }

    $result.Details = 'All health-check heuristics returned negative.'
    Write-StructuredLog -LogPath $LogPath -Severity 'WARN' -Message 'Health check: server appears offline.'
    return $result
}
