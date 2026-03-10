# Development Guide

This guide explains how to work on the **Minecraft-Server-Automation** toolkit locally.

## Prerequisites

| Tool | Minimum version | Purpose |
|------|----------------|---------|
| PowerShell (pwsh) | 5.1 | Run scripts |
| PSScriptAnalyzer | latest | Linting |
| Pester | 5.x | Unit tests |
| Java (optional) | 17+ | Running actual server |

### Install development tools

```powershell
# From a PowerShell session
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force
Install-Module -Name Pester -Scope CurrentUser -Force -MinimumVersion 5.0.0
```

## Repository layout

See [ARCHITECTURE.md](ARCHITECTURE.md) for a full directory tree.

## Running tests locally

```powershell
cd /path/to/Minecraft-Server-Automation

$cfg = New-PesterConfiguration
$cfg.Run.Path         = './tests'
$cfg.Output.Verbosity = 'Detailed'
Invoke-Pester -Configuration $cfg
```

## Linting locally

```powershell
Invoke-ScriptAnalyzer -Path ./src -Settings ./PSScriptAnalyzerSettings.psd1 -Recurse
Invoke-ScriptAnalyzer -Path ./scripts -Settings ./PSScriptAnalyzerSettings.psd1 -Recurse
```

## Adding a new Public function

1. Create `src/Minecraft.ServerAutomation/Public/Your-Function.ps1`.
2. Use `[CmdletBinding()]` and typed parameters.
3. Call `Assert-PathSafe` for any path arguments.
4. Use `Write-StructuredLog` for file-based logging when `-LogPath` is provided.
5. Add the function name to `FunctionsToExport` in `Minecraft.ServerAutomation.psd1`.
6. Add a thin entrypoint in `scripts/` if needed.
7. Add Pester tests in `tests/`.

## Adding a new Private helper

1. Create `src/Minecraft.ServerAutomation/Private/Your-Helper.ps1`.
2. The module loader (`Minecraft.ServerAutomation.psm1`) auto-imports it.
3. Do **not** add it to `FunctionsToExport` in the psd1.

## Code style

- `Set-StrictMode -Version Latest` at the top of every Public function.
- `$ErrorActionPreference = 'Stop'` in functions that must not silently fail.
- 4-space indentation (enforced by PSScriptAnalyzer settings).
- `PascalCase` for function and parameter names.
- No PowerShell aliases in committed code (use full cmdlet names).
- English comments and variable names in module code; existing Polish-language root scripts are grandfathered.

## Branching & PRs

- All changes go through pull requests.
- CI must pass (PSScriptAnalyzer + Pester) before merge.
- Keep individual commits small and focused.
