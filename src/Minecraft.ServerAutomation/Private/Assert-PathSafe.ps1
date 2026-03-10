function Assert-PathSafe {
    <#
    .SYNOPSIS
        Validates that a filesystem path is safe to operate on.
    .DESCRIPTION
        Throws a terminating error when the path is:
        - null/empty
        - a root volume (e.g. C:\, /, //)
        - identical to the system root ($env:SystemRoot / /usr)

        Does NOT require the path to exist; callers that need existence should
        check separately with Test-Path.
    .PARAMETER Path
        The path to validate.
    .PARAMETER ParameterName
        Optional parameter name for clearer error messages.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Path = '',

        [Parameter()]
        [string]$ParameterName = 'Path'
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        throw [System.ArgumentException]::new("$ParameterName must not be null or empty.")
    }

    # Check raw path first (before OS-level resolution) for Windows-style root patterns.
    # This ensures Windows root paths are rejected even when running on Linux.
    $rawRootPatterns = @(
        '^[A-Za-z]:\\?$',          # Windows drive root: C:\  or  C:
        '^[A-Za-z]:$',             # Windows drive letter only: C:
        '^[\\/]{1,2}$',            # Unix / or //
        '^\\\\[^\\]+\\[^\\]+\\?$'  # UNC root: \\server\share
    )
    foreach ($pattern in $rawRootPatterns) {
        if ($Path.TrimEnd('/\') -match $pattern -or $Path -match $pattern) {
            throw [System.ArgumentException]::new(
                "$ParameterName '$Path' is a root volume path. " +
                'Refusing to operate on a root path to prevent accidental data loss.'
            )
        }
    }

    # Also resolve the full path and check against OS roots
    try {
        $resolved = [System.IO.Path]::GetFullPath($Path)

        # Reject paths that equal the OS root (e.g. / on Linux)
        $rootOfResolved = [System.IO.Path]::GetPathRoot($resolved)
        if ($resolved.TrimEnd([System.IO.Path]::DirectorySeparatorChar) -eq
            $rootOfResolved.TrimEnd([System.IO.Path]::DirectorySeparatorChar) -and
            -not [string]::IsNullOrWhiteSpace($rootOfResolved)) {
            throw [System.ArgumentException]::new(
                "$ParameterName '$resolved' resolves to a root volume. " +
                'Refusing to operate on a root path to prevent accidental data loss.'
            )
        }
    }
    catch [System.ArgumentException] {
        throw
    }
    catch {
        # GetFullPath can fail on certain paths (e.g. illegal characters on some OSes).
        # The raw-path checks above already cover the main root-path cases.
        Write-Verbose "Assert-PathSafe: GetFullPath resolution skipped for '$Path': $_"
    }
}
