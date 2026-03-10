function Write-StructuredLog {
    <#
    .SYNOPSIS
        Appends a structured, timestamped log entry to a log file.
    .PARAMETER LogPath
        Directory where log files are written.  When empty the function is a no-op.
    .PARAMETER Severity
        Log severity: INFO, WARN, ERROR.
    .PARAMETER Message
        The message to log.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$LogPath = '',

        [Parameter()]
        [ValidateSet('INFO', 'WARN', 'ERROR')]
        [string]$Severity = 'INFO',

        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    if ([string]::IsNullOrWhiteSpace($LogPath)) {
        return
    }

    try {
        if (-not (Test-Path $LogPath)) {
            $null = New-Item -ItemType Directory -Path $LogPath -Force
        }
        $timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        $entry = "[$timestamp] [$Severity] $Message"
        $logFile = Join-Path $LogPath "minecraft-automation_$(Get-Date -Format 'yyyy-MM-dd').log"
        Add-Content -Path $logFile -Value $entry -Encoding UTF8
    }
    catch {
        # Logging failure must never crash the caller
        Write-Warning "Write-StructuredLog: could not write to '$LogPath': $_"
    }
}
