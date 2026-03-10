# Architecture

This document describes the high-level structure of the **Minecraft-Server-Automation** PowerShell toolkit.

## Repository layout

```
Minecraft-Server-Automation/
│
├── src/
│   └── Minecraft.ServerAutomation/     # PowerShell module
│       ├── Minecraft.ServerAutomation.psd1   # Module manifest
│       ├── Minecraft.ServerAutomation.psm1   # Module loader
│       ├── Private/                    # Internal helpers (not exported)
│       │   ├── Assert-PathSafe.ps1
│       │   ├── Test-JavaAvailable.ps1
│       │   ├── Write-ColorMessage.ps1
│       │   └── Write-StructuredLog.ps1
│       └── Public/                     # Exported API functions
│           ├── Get-ServerHealthCheck.ps1
│           ├── Install-MinecraftServer.ps1
│           ├── Invoke-ServerBackup.ps1
│           ├── Start-MinecraftServer.ps1
│           └── Update-MinecraftServer.ps1
│
├── scripts/                            # Thin CLI entrypoints
│   ├── BackupServer.ps1
│   ├── MinecraftServerSetup.ps1
│   ├── PlayerManagement.ps1
│   ├── MonetizationSetup.ps1
│   ├── ServerMonitoring.ps1
│   ├── StartServer.ps1
│   └── UpdateServer.ps1
│
├── tests/                              # Pester unit tests
│   ├── Assert-PathSafe.Tests.ps1
│   ├── Backup.Tests.ps1
│   └── Setup.Tests.ps1
│
├── docs/                               # Documentation
│   ├── ARCHITECTURE.md                 # This file
│   ├── DEVELOPMENT_GUIDE.md
│   ├── MONETIZATION.md
│   ├── OPERATIONS.md
│   └── SECURITY.md
│
├── .github/workflows/ci.yml            # CI: PSScriptAnalyzer + Pester
├── PSScriptAnalyzerSettings.psd1       # Linter rule configuration
│
│   # Legacy root scripts (deprecated wrappers → scripts/)
├── BackupServer.ps1
├── MinecraftServerSetup.ps1
├── MonetizationSetup.ps1
├── PlayerManagement.ps1
├── ServerMonitoring.ps1
├── StartServer.ps1
└── UpdateServer.ps1
```

## Module design

The `Minecraft.ServerAutomation` module follows a split Public/Private pattern:

| Layer | Purpose |
|-------|---------|
| **Private** | Internal helpers loaded at module import; not exported. |
| **Public** | Exported functions callable after `Import-Module`. |

### Private helpers

| Function | Purpose |
|----------|---------|
| `Write-ColorMessage` | Consistent colored console output across all scripts. |
| `Write-StructuredLog` | Timestamped, severity-tagged log entries to file. |
| `Assert-PathSafe` | Guard against accidentally operating on root volumes (`/`, `C:\`). |
| `Test-JavaAvailable` | Test whether `java` is on PATH. |

### Public functions

| Function | Description |
|----------|-------------|
| `Invoke-ServerBackup` | Compress server directory to ZIP; enforce retention. |
| `Install-MinecraftServer` | Create server directory, `eula.txt`, `server.properties`, start scripts. |
| `Start-MinecraftServer` | Launch the server JVM process. |
| `Update-MinecraftServer` | Optional pre-update backup + guided manual jar update. |
| `Get-ServerHealthCheck` | Multi-heuristic health check (PID file → TCP port → log freshness). |

## CLI entrypoints (scripts/)

Each file in `scripts/` is a thin wrapper that:

1. Declares the same parameters as the equivalent root script.
2. Imports the module with `Import-Module`.
3. Calls the appropriate Public function.

This keeps business logic out of entrypoints and inside testable module functions.

## Health-check heuristics

`Get-ServerHealthCheck` tries the following heuristics in order and returns
`IsOnline = $true` on the **first positive** result:

1. **PID file** – reads `server.pid` from `ServerPath` and checks if the process is alive.
2. **TCP port** – attempts a 2-second `TcpClient` connection to `127.0.0.1:<port>`.  
   Port is read from `server.properties` if not passed explicitly.
3. **Log freshness** – checks whether `logs/latest.log` was modified within the last N minutes.

This avoids brittle Java process-path matching that breaks on Linux.

## CI pipeline

The GitHub Actions workflow (`.github/workflows/ci.yml`) runs on every push/PR:

1. Install **PSScriptAnalyzer** from PSGallery.
2. Analyse `src/` and `scripts/` with project-specific settings.
3. Install **Pester 5.x**.
4. Run tests under `tests/` and publish NUnit XML results as an artifact.
