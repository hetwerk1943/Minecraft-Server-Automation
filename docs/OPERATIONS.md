# Operations Guide

Covers day-to-day operations: backups, restore, scheduling, log rotation, and health monitoring.

## Backup

### Create a backup

```powershell
# Via scripts/ (recommended)
.\scripts\BackupServer.ps1 -ServerPath 'D:\Servers\Minecraft' -BackupPath 'E:\Backups' -MaxBackups 14

# Via module
Import-Module .\src\Minecraft.ServerAutomation\Minecraft.ServerAutomation.psd1
Invoke-ServerBackup -ServerPath 'D:\Servers\Minecraft' -BackupPath 'E:\Backups' -MaxBackups 14
```

Backups are named `Backup_<yyyy-MM-dd_HH-mm-ss>.zip`.  
Archives older than the `MaxBackups` limit are automatically deleted (oldest first).

### Restore from backup

1. Stop the Minecraft server.
2. Extract the desired `Backup_*.zip` over the server directory:

```powershell
Expand-Archive -Path 'E:\Backups\Backup_2025-01-15_03-00-00.zip' `
               -DestinationPath 'D:\Servers\Minecraft' -Force
```

3. Start the server again.

## Scheduling backups

### Windows – Task Scheduler

```powershell
$action  = New-ScheduledTaskAction `
    -Execute 'pwsh.exe' `
    -Argument '-NonInteractive -File "D:\scripts\BackupServer.ps1" -ServerPath "D:\Servers\Minecraft" -BackupPath "E:\Backups"'
$trigger = New-ScheduledTaskTrigger -Daily -At '03:00'
Register-ScheduledTask -TaskName 'MinecraftBackup' -Action $action -Trigger $trigger -RunLevel Highest
```

### Linux – cron

```cron
0 3 * * * /usr/bin/pwsh /opt/minecraft/scripts/BackupServer.ps1 \
    -ServerPath /opt/minecraft/server -BackupPath /opt/minecraft/backups \
    -MaxBackups 14 -LogPath /opt/minecraft/logs
```

## Log rotation

Structured logs are written to `<LogPath>/minecraft-automation_<yyyy-MM-dd>.log`.  
Each daily run creates a new file. Clean up old log files with:

```powershell
Get-ChildItem -Path .\Logs -Filter '*.log' |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } |
    Remove-Item -Force
```

Or add a cron/Task Scheduler entry to run this weekly.

## Server start script (Linux systemd)

Create `/etc/systemd/system/minecraft.service`:

```ini
[Unit]
Description=Minecraft Server
After=network.target

[Service]
Type=simple
User=minecraft
WorkingDirectory=/opt/minecraft
ExecStart=/usr/bin/pwsh /opt/minecraft/scripts/StartServer.ps1 \
    -ServerPath /opt/minecraft/server -NoGUI
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable minecraft
sudo systemctl start minecraft
```

## Health monitoring

### One-shot check

```powershell
Import-Module .\src\Minecraft.ServerAutomation\Minecraft.ServerAutomation.psd1
$status = Get-ServerHealthCheck -ServerPath 'D:\Servers\Minecraft' -ServerPort 25565
Write-Host "Online: $($status.IsOnline)  Method: $($status.Method)  $($status.Details)"
```

### Continuous monitoring

```powershell
.\scripts\ServerMonitoring.ps1 -ServerPath 'D:\Servers\Minecraft' -LogPath '.\Logs' -MonitorIntervalSeconds 30
```

Press `Ctrl+C` to stop.

## Updating the server

The update workflow backs up first, then guides through manually replacing `server.jar`:

```powershell
.\scripts\UpdateServer.ps1 -ServerPath 'D:\Servers\Minecraft' -BackupPath 'E:\Backups'
```

To skip the automatic backup:

```powershell
.\scripts\UpdateServer.ps1 -ServerPath 'D:\Servers\Minecraft' -SkipBackup
```
