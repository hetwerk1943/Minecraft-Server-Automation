function Test-JavaAvailable {
    <#
    .SYNOPSIS
        Returns $true when the 'java' executable is available on PATH.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    try {
        $null = & java -version 2>&1
        return ($LASTEXITCODE -eq 0)
    }
    catch {
        return $false
    }
}
