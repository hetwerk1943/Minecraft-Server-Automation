# SharedFunctions.psm1
# Shared utility functions for Minecraft Server Automation scripts
# © 2025 Dominik Opałka

function Write-ColorMessage {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Test-JavaInstallation {
    try {
        $javaVersion = java -version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-ColorMessage "Java jest zainstalowana: $($javaVersion[0])" "Green"
            return $true
        }
    }
    catch {
        Write-ColorMessage "Java nie została znaleziona. Zainstaluj Javę przed kontynuowaniem." "Red"
        return $false
    }
    return $false
}

Export-ModuleMember -Function Write-ColorMessage, Test-JavaInstallation
