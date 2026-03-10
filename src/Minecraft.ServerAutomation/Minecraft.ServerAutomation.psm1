#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Auto-import Private helpers (not exported)
$privateFiles = Get-ChildItem -Path "$PSScriptRoot/Private" -Filter '*.ps1' -ErrorAction SilentlyContinue
foreach ($file in $privateFiles) {
    . $file.FullName
}

# Auto-import Public functions (exported via psd1 FunctionsToExport)
$publicFiles = Get-ChildItem -Path "$PSScriptRoot/Public" -Filter '*.ps1' -ErrorAction SilentlyContinue
foreach ($file in $publicFiles) {
    . $file.FullName
}
