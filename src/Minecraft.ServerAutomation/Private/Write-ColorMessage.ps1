function Write-ColorMessage {
    <#
    .SYNOPSIS
        Writes a colored message to the host console.
    .PARAMETER Message
        The message text to display.
    .PARAMETER Color
        The foreground color (default: White).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter()]
        [string]$Color = 'White'
    )
    Write-Host $Message -ForegroundColor $Color
}
