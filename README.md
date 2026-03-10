# Minecraft-Server-Automation

> PowerShell automation toolkit for Minecraft server management and monetization.

[![CI](https://github.com/hetwerk1943/Minecraft-Server-Automation/actions/workflows/ci.yml/badge.svg)](https://github.com/hetwerk1943/Minecraft-Server-Automation/actions/workflows/ci.yml)

## Quick start

```powershell
# 1. Clone
git clone https://github.com/hetwerk1943/Minecraft-Server-Automation.git
cd Minecraft-Server-Automation

# 2. Setup server directory
.\scripts\MinecraftServerSetup.ps1 -ServerPath 'C:\MinecraftServer' -MaxMemory 4096

# 3. Place server.jar in C:\MinecraftServer (download from minecraft.net)

# 4. Start server
.\scripts\StartServer.ps1 -ServerPath 'C:\MinecraftServer' -MaxMemory 4096 -NoGUI
```

## Scripts

| Script | Description |
|--------|-------------|
| `scripts/MinecraftServerSetup.ps1` | Creates server directory, `eula.txt`, `server.properties`, start scripts |
| `scripts/StartServer.ps1` | Launches the JVM server process |
| `scripts/BackupServer.ps1` | Creates a ZIP backup; enforces retention limit |
| `scripts/UpdateServer.ps1` | Pre-update backup + guided jar update |
| `scripts/ServerMonitoring.ps1` | Continuous health-check loop |
| `scripts/PlayerManagement.ps1` | Player statistics and activity reports |
| `scripts/MonetizationSetup.ps1` | Generates monetization configuration templates |

> **Note:** Root-level scripts (`BackupServer.ps1`, etc.) are **deprecated** legacy scripts kept for backward compatibility.
> Prefer the `scripts/` versions going forward to avoid diverging behavior.

## Module (advanced usage)

```powershell
Import-Module .\src\Minecraft.ServerAutomation\Minecraft.ServerAutomation.psd1

# Backup
Invoke-ServerBackup -ServerPath 'C:\MinecraftServer' -BackupPath 'E:\Backups' -MaxBackups 14

# Health check
Get-ServerHealthCheck -ServerPath 'C:\MinecraftServer' -ServerPort 25565

# Setup
Install-MinecraftServer -ServerPath 'C:\MinecraftServer' -ServerPort 25565 -MaxMemory 4096
```

## Documentation

| Document | Contents |
|----------|----------|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Module structure, design decisions |
| [docs/DEVELOPMENT_GUIDE.md](docs/DEVELOPMENT_GUIDE.md) | Local dev setup, testing, adding functions |
| [docs/OPERATIONS.md](docs/OPERATIONS.md) | Backup/restore, scheduling, log rotation |
| [docs/SECURITY.md](docs/SECURITY.md) | Secrets management, responsible disclosure |
| [docs/MONETIZATION.md](docs/MONETIZATION.md) | VIP tiers, revenue estimates, legal checklist |
| [QUICK_START.md](QUICK_START.md) | Step-by-step first-run guide |

## Requirements

- PowerShell 5.1+ (PowerShell 7.x recommended)
- Java 17+ (for running the server)
- Windows, Linux, or macOS with `pwsh`

## License

© 2025 Dominik Opałka. All Rights Reserved.  
See [COPYRIGHT.md](COPYRIGHT.md) for details.
