# Przewodnik Wdrożenia Produkcyjnego
## Production Deployment Guide

Kompleksowy przewodnik wdrożenia serwera Minecraft do środowiska produkcyjnego.

Wersja: 1.0  
Data: 2025-12-09

---

## 📋 Spis Treści

1. [Pre-Deployment Checklist](#pre-deployment)
2. [Hardware Requirements](#hardware)
3. [Software Requirements](#software)
4. [Network Configuration](#network)
5. [Security Hardening](#security)
6. [Installation Process](#installation)
7. [Configuration Best Practices](#configuration)
8. [Monitoring Setup](#monitoring)
9. [Backup Strategy](#backup)
10. [Performance Tuning](#performance)
11. [Scaling Strategy](#scaling)
12. [Maintenance](#maintenance)
13. [Troubleshooting](#troubleshooting)
14. [Rollback Procedures](#rollback)

---

## 1. Pre-Deployment Checklist {#pre-deployment}

### 📋 Business Requirements

```markdown
☐ Business Plan
  ☐ Target audience defined
  ☐ Revenue model planned
  ☐ Marketing strategy prepared
  ☐ Budget allocated
  
☐ Legal Requirements (Poland)
  ☐ Działalność gospodarcza registered (JDG/spółka)
  ☐ NIP obtained
  ☐ REGON obtained
  ☐ Bank account business
  ☐ Księgowy hired
  
☐ Documentation
  ☐ Privacy Policy (RODO)
  ☐ Terms of Service
  ☐ Store Terms
  ☐ Refund Policy
  ☐ Age verification process
  
☐ Payment Systems
  ☐ Tebex account created
  ☐ Payment gateway configured
  ☐ VAT settings configured
  ☐ Test purchases completed
```

### 🔧 Technical Requirements

```markdown
☐ Hardware
  ☐ Server ordered/provisioned
  ☐ Specs meet requirements
  ☐ Backup solution available
  ☐ Network capacity verified
  
☐ Software
  ☐ OS installed and updated
  ☐ PowerShell 7.x installed
  ☐ Java 17+ installed
  ☐ Git installed
  ☐ Monitoring tools ready
  
☐ Network
  ☐ Domain registered
  ☐ DNS configured
  ☐ SSL certificate obtained
  ☐ Ports opened
  ☐ DDoS protection configured
  
☐ Accounts & Services
  ☐ Discord server created
  ☐ Discord webhooks configured
  ☐ Tebex account setup
  ☐ Email service configured
  ☐ Backup storage provisioned
```

### 🧪 Testing

```markdown
☐ Development Environment
  ☐ All features tested
  ☐ Load testing completed
  ☐ Security audit passed
  ☐ Backup/restore verified
  
☐ Staging Environment
  ☐ Production-like setup
  ☐ Full system test
  ☐ Performance benchmarks met
  ☐ Monitoring tested
  
☐ Documentation
  ☐ All scripts documented
  ☐ Runbooks created
  ☐ Emergency procedures defined
  ☐ Team trained
```

---

## 2. Hardware Requirements {#hardware}

### Minimum Requirements (10-20 graczy)

```yaml
CPU: 
  - Cores: 2-4 cores
  - Speed: 3.0+ GHz
  - Architecture: x64

RAM:
  - Minimum: 4 GB
  - Recommended: 8 GB
  - OS: 1-2 GB
  - Minecraft: 2-4 GB
  - Overhead: 1-2 GB

Storage:
  - Type: SSD (REQUIRED)
  - Space: 50 GB minimum
  - IOPS: 1000+ recommended
  - Backups: Additional 100+ GB

Network:
  - Bandwidth: 100 Mbps minimum
  - Upload: 10 Mbps per 10 graczy
  - Latency: <50ms (to players)
```

### Recommended Production (50-100 graczy)

```yaml
CPU:
  - Cores: 6-8 cores (12-16 threads)
  - Speed: 3.5+ GHz (high single-thread)
  - Architecture: x64
  - Model: Intel i7/i9, AMD Ryzen 7/9

RAM:
  - Total: 16-32 GB
  - OS: 2-4 GB
  - Minecraft: 8-16 GB
  - Plugins: 2-4 GB
  - Overhead: 4-8 GB

Storage:
  - Primary: NVMe SSD 250+ GB
  - IOPS: 3000+ 
  - Read: 2000+ MB/s
  - Write: 1000+ MB/s
  - Backups: Separate 500+ GB HDD/SSD

Network:
  - Bandwidth: 1 Gbps port
  - Upload: 50+ Mbps
  - Latency: <30ms
  - DDoS Protection: YES
```

### High Performance (200+ graczy)

```yaml
CPU:
  - Cores: 16+ cores (32+ threads)
  - Speed: 4.0+ GHz boost
  - Model: Intel Xeon/i9, AMD Ryzen 9/Threadripper

RAM:
  - Total: 64+ GB ECC
  - Minecraft: 32+ GB
  - OS & Services: 16+ GB
  - Cache: 16+ GB

Storage:
  - Primary: Enterprise NVMe 500+ GB
  - IOPS: 10000+
  - RAID: RAID 10 recommended
  - Backups: Separate storage array

Network:
  - Bandwidth: 10 Gbps
  - Upload: 200+ Mbps
  - Multiple NICs
  - Enterprise DDoS protection
  - Load balancing
```

### Cloud vs Dedicated

**Cloud (VPS) - Pros:**
- ✅ Flexible scaling
- ✅ Pay-as-you-go
- ✅ Easy setup
- ✅ Good for starting

**Cloud (VPS) - Cons:**
- ❌ Shared resources
- ❌ Higher long-term cost
- ❌ Performance inconsistent
- ❌ Less control

**Recommended VPS Providers (Poland):**
- OVH Poland: https://www.ovhcloud.com/pl/
- nazwa.pl: https://www.nazwa.pl/
- home.pl: https://home.pl/
- DigitalOcean (EU region)

**Dedicated Server - Pros:**
- ✅ Full resources
- ✅ Better performance
- ✅ Lower long-term cost
- ✅ Full control

**Dedicated Server - Cons:**
- ❌ Higher upfront cost
- ❌ More setup needed
- ❌ Physical maintenance
- ❌ Less flexible

**Recommended Dedicated (Poland):**
- OVH Dedicated: 300-1000 PLN/msc
- Hetzner: 200-800 PLN/msc
- nazwa.pl Dedicated

---

## 3. Software Requirements {#software}

### Operating System

**Recommended: Windows Server 2022 lub Ubuntu 22.04 LTS**

**Windows Server 2022:**
```powershell
# Advantages:
- Native PowerShell support
- Easy administration
- GUI available
- Good for Windows admins

# Disadvantages:
- License cost (~500-1000 PLN/year)
- Higher resource usage
- More attack surface

# Installation:
1. Install Windows Server 2022
2. Install PowerShell 7.x
3. Enable Remote Desktop
4. Configure Windows Firewall
5. Install updates
```

**Ubuntu 22.04 LTS:**
```bash
# Advantages:
- Free & open source
- Lower resource usage
- Better performance
- Stable LTS support

# Disadvantages:
- Requires PowerShell Core installation
- Command-line only (typically)
- Linux knowledge required

# Installation:
sudo apt update && sudo apt upgrade -y
sudo apt install -y powershell
pwsh --version  # Verify installation
```

### PowerShell

**Required: PowerShell 7.3+**

**Windows:**
```powershell
# Install via winget
winget install Microsoft.PowerShell

# Or via MSI
# Download from: https://github.com/PowerShell/PowerShell/releases
```

**Linux:**
```bash
# Ubuntu/Debian
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update
sudo apt install -y powershell

# Verify
pwsh --version
```

### Java

**Required: Java 17+ (for Minecraft 1.18+)**

**Windows:**
```powershell
# Eclipse Temurin (recommended)
winget install EclipseAdoptium.Temurin.17.JDK

# Verify
java -version
# Should show: openjdk version "17.x.x"
```

**Linux:**
```bash
# Ubuntu
sudo apt install -y openjdk-17-jdk

# Verify
java -version
```

### Additional Tools

**Required:**
```powershell
# Git (version control)
winget install Git.Git  # Windows
sudo apt install -y git  # Linux

# 7-Zip or similar (for backups)
winget install 7zip.7zip  # Windows
sudo apt install -y p7zip-full  # Linux
```

**Recommended:**
```powershell
# Process Monitor
# htop (Linux) or Process Explorer (Windows)

# Network tools
# netstat, tcpdump, wireshark

# Text editor
# VS Code, Nano, Vim
```

---

## 4. Network Configuration {#network}

### Domain Setup

**1. Register Domain:**
```
Recommended registrars (Poland):
- nazwa.pl
- home.pl
- OVH
- Cloudflare Registrar

Domain options:
- yourserver.pl (75-150 PLN/rok)
- yourserver.com (50-100 PLN/rok)
- yourserver.eu (40-80 PLN/rok)
```

**2. DNS Configuration:**
```
Type    Name        Value               TTL
A       @           YOUR.SERVER.IP      3600
A       www         YOUR.SERVER.IP      3600
A       play        YOUR.SERVER.IP      3600
SRV     _minecraft  play.yourdomain.pl  3600
        (Priority: 0, Weight: 5, Port: 25565)
```

**3. Test DNS:**
```powershell
# Windows
nslookup play.yourdomain.pl

# Linux
dig play.yourdomain.pl

# Test SRV record
nslookup -type=SRV _minecraft._tcp.play.yourdomain.pl
```

### Firewall Configuration

**Windows Firewall:**
```powershell
# Minecraft Server (TCP & UDP)
New-NetFirewallRule -DisplayName "Minecraft Server TCP" `
    -Direction Inbound -LocalPort 25565 -Protocol TCP -Action Allow

New-NetFirewallRule -DisplayName "Minecraft Server UDP" `
    -Direction Inbound -LocalPort 25565 -Protocol UDP -Action Allow

# RCON (if needed)
New-NetFirewallRule -DisplayName "Minecraft RCON" `
    -Direction Inbound -LocalPort 25575 -Protocol TCP -Action Allow

# Query (if needed)
New-NetFirewallRule -DisplayName "Minecraft Query" `
    -Direction Inbound -LocalPort 25565 -Protocol UDP -Action Allow

# SSH/RDP (for management)
New-NetFirewallRule -DisplayName "Remote Desktop" `
    -Direction Inbound -LocalPort 3389 -Protocol TCP -Action Allow
```

**Linux UFW:**
```bash
# Enable firewall
sudo ufw enable

# Minecraft
sudo ufw allow 25565/tcp comment 'Minecraft TCP'
sudo ufw allow 25565/udp comment 'Minecraft UDP'

# SSH
sudo ufw allow 22/tcp comment 'SSH'

# Check status
sudo ufw status verbose
```

### Port Forwarding (If Router)

**Router Configuration:**
```
Service: Minecraft Server
External Port: 25565
Internal Port: 25565
Protocol: TCP & UDP
Internal IP: 192.168.x.x (your server local IP)

Service: SSH/RDP
External Port: 2222 (changed for security)
Internal Port: 22 (Linux) or 3389 (Windows)
Protocol: TCP
Internal IP: 192.168.x.x
```

### DDoS Protection

**Cloudflare Spectrum (Recommended):**
```yaml
Setup:
  1. Sign up for Cloudflare
  2. Add domain
  3. Enable Spectrum (requires Pro+ plan: $20/mo)
  4. Add Minecraft application
  5. Configure proxy settings

Benefits:
  - DDoS protection
  - Traffic filtering
  - Analytics
  - Global anycast network
```

**Alternative: OVH Game DDoS:**
```yaml
- Included with OVH Game servers
- Automatic mitigation
- Good for Minecraft
- Poland datacenter available
```

**TCPShield (Free for small servers):**
```yaml
- Free tier: up to 50 players
- Easy setup
- Anti-bot protection
- DDoS mitigation
```

---

## 5. Security Hardening {#security}

### Operating System Security

**Windows:**
```powershell
# 1. Updates
Install-WindowsUpdate -AcceptAll -AutoReboot

# 2. Disable unnecessary services
Set-Service -Name "PrintSpooler" -StartupType Disabled
Set-Service -Name "RemoteRegistry" -StartupType Disabled

# 3. Configure Windows Defender
Set-MpPreference -DisableRealtimeMonitoring $false
Update-MpSignature

# 4. Enable BitLocker (for data protection)
Enable-BitLocker -MountPoint "C:" -EncryptionMethod XtsAes256

# 5. Audit Policy
auditpol /set /category:"Logon/Logoff" /success:enable /failure:enable
```

**Linux:**
```bash
# 1. Updates
sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y

# 2. Install fail2ban (brute-force protection)
sudo apt install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# 3. Configure SSH
sudo nano /etc/ssh/sshd_config
# Set: PermitRootLogin no
# Set: PasswordAuthentication no (use keys)
# Set: Port 2222 (non-standard)
sudo systemctl restart sshd

# 4. Install unattended-upgrades (auto security updates)
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades

# 5. Configure firewall (see Network section)
```

### Minecraft Server Security

**server.properties:**
```properties
# Network
online-mode=true                    # REQUIRED for security
prevent-proxy-connections=true      # Block VPNs/proxies
network-compression-threshold=256   # Prevent compression attacks

# Authentication
enforce-whitelist=false             # Enable after testing
white-list=false                    # Enable for private server

# Resource limits
max-players=100                     # Set realistic limit
max-world-size=29999984            # Limit world size
rate-limit=0                       # 0 = disabled, or set limit

# Command blocks (security risk if abused)
enable-command-block=false         # Disable unless needed

# Query (potential info leak)
enable-query=false                 # Disable unless needed
enable-rcon=false                  # Disable unless needed

# View distance (DDoS mitigation)
view-distance=8                    # Lower = better performance
simulation-distance=8              # Lower = less resource usage
```

**Plugins for Security:**
```yaml
AuthMe:
  - Password protection
  - Prevent cracked accounts
  - IP logging

CoreProtect:
  - Block logging
  - Rollback griefing
  - Audit trail

LuckPerms:
  - Permission management
  - Role-based access
  - Secure by default

AntiCheat:
  - Spartan AntiCheat
  - Matrix AntiCheat
  - NoCheatPlus
```

### Backup Security

**Encryption:**
```powershell
# Encrypt backups before storing
$BackupPath = "C:\Backups\server-backup.zip"
$EncryptedPath = "C:\Backups\server-backup.zip.enc"
$Password = ConvertTo-SecureString "YourStrongPassword" -AsPlainText -Force

# Using 7-Zip with password
& "C:\Program Files\7-Zip\7z.exe" a -p"$Password" -mhe=on "$EncryptedPath" "$BackupPath"

# Or use PowerShell encryption
```

**Off-site Backups:**
```yaml
Recommended services:
  - Google Drive (15 GB free)
  - Dropbox (2 GB free)
  - Backblaze B2 (10 GB free)
  - AWS S3 (pay-as-you-go)
  - Azure Blob Storage
  - OVH Cloud Storage

Automation:
  - Use rclone for sync
  - Daily encrypted backups
  - 3-2-1 rule (3 copies, 2 media, 1 offsite)
```

### Monitoring & Alerting

**Log Monitoring:**
```powershell
# Monitor for suspicious activity
Get-Content "C:\MinecraftServer\logs\latest.log" -Wait | 
    Select-String -Pattern "banned|kicked|hack|cheat|exploit"

# Alert on server errors
Get-Content "C:\MinecraftServer\logs\latest.log" -Wait | 
    Select-String -Pattern "ERROR|SEVERE" |
    ForEach-Object {
        # Send Discord alert
        Send-DiscordAlert -Message "Error detected: $_"
    }
```

**Security Alerts:**
```powershell
# Failed login attempts
# Unusual player behavior
# Resource exhaustion
# Network anomalies
# Unauthorized access attempts
```

---

## 6. Installation Process {#installation}

### Step-by-Step Production Setup

**Phase 1: System Preparation**

```powershell
# 1. Create service account (best practice)
New-LocalUser -Name "minecraft" -Description "Minecraft Server Service Account" -PasswordNeverExpires
Add-LocalGroupMember -Group "Users" -Member "minecraft"

# 2. Create directory structure
$BaseDir = "C:\MinecraftProduction"
New-Item -ItemType Directory -Path $BaseDir -Force
New-Item -ItemType Directory -Path "$BaseDir\server" -Force
New-Item -ItemType Directory -Path "$BaseDir\backups" -Force
New-Item -ItemType Directory -Path "$BaseDir\logs" -Force
New-Item -ItemType Directory -Path "$BaseDir\scripts" -Force

# 3. Set permissions
icacls $BaseDir /grant "minecraft:(OI)(CI)M"

# 4. Clone automation scripts
cd $BaseDir\scripts
git clone https://github.com/hetwerk1943/Minecraft-Server-Automation.git .
```

**Phase 2: Server Installation**

```powershell
# 1. Run setup script
cd $BaseDir\scripts
.\MinecraftServerSetup.ps1 `
    -ServerPath "$BaseDir\server" `
    -MaxMemory 8192 `
    -ServerPort 25565

# 2. Download server.jar
# Download dari https://www.minecraft.net/en-us/download/server
# Or Paper: https://papermc.io/downloads
Move-Item "~\Downloads\server.jar" "$BaseDir\server\server.jar"

# 3. First run (will generate world)
.\StartServer.ps1 -ServerPath "$BaseDir\server" -MaxMemory 8192 -NoGUI

# Wait for "Done!" message, then stop with /stop
```

**Phase 3: Monetization Setup**

```powershell
# 1. Configure monetization
.\MonetizationSetup.ps1 `
    -ServerPath "$BaseDir\server" `
    -EnableVIPSystem `
    -EnableEconomy `
    -CurrencyName "Monety" `
    -DonationSystem "Tebex"

# 2. Install required plugins manually:
# - LuckPerms (permissions)
# - Vault (economy API)
# - EssentialsX (economy implementation)
# - Tebex plugin (donations)

# Download to: $BaseDir\server\plugins\
```

**Phase 4: Monitoring Setup**

```powershell
# 1. Create Discord webhook
# Discord Server → Settings → Integrations → Webhooks → New Webhook
$WebhookUrl = "https://discord.com/api/webhooks/YOUR/WEBHOOK/URL"

# 2. Start monitoring
.\ServerMonitoring.ps1 `
    -ServerPath "$BaseDir\server" `
    -MonitorIntervalSeconds 60 `
    -EnableDiscordWebhook `
    -DiscordWebhookUrl $WebhookUrl
```

**Phase 5: Backup Configuration**

```powershell
# 1. Test backup
.\BackupServer.ps1 `
    -ServerPath "$BaseDir\server" `
    -BackupPath "$BaseDir\backups" `
    -MaxBackups 10

# 2. Schedule daily backups (Windows Task Scheduler)
$Action = New-ScheduledTaskAction `
    -Execute "pwsh.exe" `
    -Argument "-File `"$BaseDir\scripts\BackupServer.ps1`" -ServerPath `"$BaseDir\server`" -BackupPath `"$BaseDir\backups`""

$Trigger = New-ScheduledTaskTrigger -Daily -At 3am

$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable

Register-ScheduledTask `
    -TaskName "MinecraftDailyBackup" `
    -Action $Action `
    -Trigger $Trigger `
    -Settings $Settings `
    -User "SYSTEM" `
    -RunLevel Highest
```

---

## 7. Configuration Best Practices {#configuration}

### server.properties Optimization

```properties
# === NETWORK ===
server-ip=                           # Leave empty (bind all)
server-port=25565
max-players=100                      # Set realistic limit
network-compression-threshold=256    # Optimize bandwidth
online-mode=true                     # MUST be true

# === PERFORMANCE ===
view-distance=8                      # Lower = better performance
simulation-distance=8                # Lower = less CPU usage
max-tick-time=60000                  # Watchdog timeout
entity-broadcast-range-percentage=100 # Default, adjust if needed

# === WORLD ===
level-name=world
level-seed=                          # Custom seed (optional)
generate-structures=true
spawn-protection=16                  # Spawn protection radius
max-world-size=29999984             # Default, can lower

# === GAMEPLAY ===
difficulty=normal                    # easy/normal/hard
hardcore=false
pvp=true                            # Enable PvP
allow-flight=false                   # Enable dla VIP w plugins
spawn-animals=true
spawn-monsters=true
spawn-npcs=true

# === MISC ===
motd=Your Server Name Here!
enable-command-block=false          # Security
enable-query=false                  # Disable unless needed
enable-rcon=false                   # Disable unless needed
```

### JVM Optimization (StartServer.ps1)

```powershell
# For 8GB RAM server (100 players)
$JVMArgs = @(
    "-Xms4G",                       # Initial memory (half of Xmx)
    "-Xmx8G",                       # Max memory
    "-XX:+UseG1GC",                 # G1 Garbage Collector
    "-XX:+ParallelRefProcEnabled",  # Parallel reference processing
    "-XX:MaxGCPauseMillis=200",     # Target max GC pause
    "-XX:+UnlockExperimentalVMOptions",
    "-XX:+DisableExplicitGC",       # Disable explicit GC calls
    "-XX:G1NewSizePercent=30",      # G1 new generation min
    "-XX:G1MaxNewSizePercent=40",   # G1 new generation max
    "-XX:G1HeapRegionSize=8M",      # G1 heap region size
    "-XX:G1ReservePercent=20",      # G1 reserve
    "-XX:G1HeapWastePercent=5",     # G1 heap waste
    "-XX:G1MixedGCCountTarget=4",   # G1 mixed GC target
    "-XX:InitiatingHeapOccupancyPercent=15", # GC trigger
    "-XX:G1MixedGCLiveThresholdPercent=90",  # G1 live threshold
    "-XX:G1RSetUpdatingPauseTimePercent=5",  # G1 RSet updating pause
    "-XX:SurvivorRatio=32",         # Survivor space ratio
    "-XX:+PerfDisableSharedMem",    # Disable perf shared memory
    "-XX:MaxTenuringThreshold=1",   # Max tenuring threshold
    "-Dusing.aikars.flags=https://mcflags.emc.gs", # Credit
    "-Daikars.new.flags=true"
)

# Join with spaces
$JVMArgsString = $JVMArgs -join " "

# Start command
java $JVMArgsString -jar server.jar nogui
```

### Plugin Configuration

**LuckPerms (Permissions):**
```yaml
# plugins/LuckPerms/config.yml
storage-method: h2                   # or mysql for multi-server
server: production                   # Server name

# Grupy podstawowe
# /lp creategroup default
# /lp creategroup vip
# /lp creategroup moderator
# /lp creategroup admin
```

**EssentialsX (Economy):**
```yaml
# plugins/Essentials/config.yml
starting-balance: 100                # Starting money
currency-symbol: 'PLN'               # Currency
max-money: 1000000                   # Max balance
min-money: 0                         # Min balance (no debt)

# Kits dla VIP
kits:
  starter:
    delay: 86400                     # 24h cooldown
    items:
      - diamond_sword 1
      - cooked_beef 32
```

**Tebex:**
```yaml
# Konfiguracja poprzez https://tebex.io/
# 1. Create account
# 2. Add server
# 3. Get Secret Key
# 4. Insert in-game: /tebex secret <key>
# 5. Configure packages on website
```

---

## 8. Monitoring Setup {#monitoring}

### Discord Webhook Configuration

```powershell
# 1. Create webhook w Discord
# Server Settings → Integrations → Webhooks → New Webhook

# 2. Configure webhook
Name: "Minecraft Server Monitor"
Channel: #server-status
Avatar: [Upload Minecraft icon]

# 3. Copy webhook URL
$WebhookUrl = "https://discord.com/api/webhooks/123456789/abcdefgh..."

# 4. Test webhook
$Body = @{
    content = "🎮 Minecraft Server - Test Message"
    username = "Server Monitor"
} | ConvertTo-Json

Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $Body -ContentType "application/json"

# 5. Start monitoring with webhook
.\ServerMonitoring.ps1 `
    -ServerPath "C:\MinecraftProduction\server" `
    -MonitorIntervalSeconds 60 `
    -EnableDiscordWebhook `
    -DiscordWebhookUrl $WebhookUrl
```

### Metrics to Track

```yaml
Server Health:
  - Online/Offline status
  - Uptime
  - Last restart time
  
Performance:
  - TPS (ticks per second)
  - Memory usage (%)
  - CPU usage (%)
  - Disk usage (%)
  
Players:
  - Current online count
  - Peak online today
  - New players today
  - Total unique players
  
Business:
  - Daily revenue
  - New VIP subscriptions
  - Donation packages sold
  - Conversion rate
  
Alerts:
  - Server down
  - Low TPS (<18)
  - High memory (>90%)
  - Disk space low (<10%)
  - Unusual player activity
```

### Automated Reports

```powershell
# Daily report generation
.\ServerMonitoring.ps1 -GenerateReports -ServerPath "C:\MinecraftProduction\server"

# Schedule daily report (Task Scheduler)
$Action = New-ScheduledTaskAction `
    -Execute "pwsh.exe" `
    -Argument "-File `"C:\MinecraftProduction\scripts\ServerMonitoring.ps1`" -GenerateReports"

$Trigger = New-ScheduledTaskTrigger -Daily -At 11:59pm

Register-ScheduledTask `
    -TaskName "MinecraftDailyReport" `
    -Action $Action `
    -Trigger $Trigger `
    -User "SYSTEM"
```

---

## 9. Backup Strategy {#backup}

### 3-2-1 Backup Rule

```
3 = Three copies of data
2 = Two different media types
1 = One copy offsite
```

### Backup Schedule

```yaml
Frequency:
  Hourly: 
    - Quick snapshot (world only)
    - Keep: Last 6 hours
    - Size: ~500 MB
    
  Daily:
    - Full server backup
    - Keep: Last 7 days
    - Size: ~2-5 GB
    
  Weekly:
    - Complete backup + logs
    - Keep: Last 4 weeks
    - Size: ~5-10 GB
    
  Monthly:
    - Archive backup
    - Keep: Last 12 months
    - Size: ~5-10 GB each
```

### Backup Script Enhancement

```powershell
# Enhanced backup with rotation
param(
    [string]$ServerPath = "C:\MinecraftProduction\server",
    [string]$LocalBackup = "C:\MinecraftProduction\backups",
    [string]$OffSiteBackup = "D:\OffSiteBackups",  # Different drive
    [switch]$UploadToCloud
)

# 1. Create local backup
.\BackupServer.ps1 -ServerPath $ServerPath -BackupPath $LocalBackup -MaxBackups 7

# 2. Copy to different drive
$LatestBackup = Get-ChildItem $LocalBackup\*.zip | 
    Sort-Object CreationTime -Descending | 
    Select-Object -First 1

Copy-Item $LatestBackup.FullName -Destination $OffSiteBackup

# 3. Upload to cloud (optional)
if ($UploadToCloud) {
    # Using rclone (install separately)
    rclone copy $LatestBackup.FullName "remote:minecraft-backups/"
}

# 4. Verify backup integrity
if (Test-Path $LatestBackup.FullName) {
    try {
        [System.IO.Compression.ZipFile]::OpenRead($LatestBackup.FullName).Dispose()
        Write-Host "Backup verification: SUCCESS" -ForegroundColor Green
    }
    catch {
        Write-Host "Backup verification: FAILED!" -ForegroundColor Red
        # Send alert
    }
}
```

### Disaster Recovery Plan

```markdown
## Disaster Recovery Procedure

### Scenario 1: Server Crash
1. Stop all server processes
2. Create emergency backup of current state
3. Restore last known good backup
4. Verify world data integrity
5. Start server
6. Monitor for issues
7. Document incident

### Scenario 2: Data Corruption
1. Identify corrupted files
2. Stop server immediately
3. Backup corrupted state (for analysis)
4. Restore from most recent clean backup
5. Validate restored data
6. Start server in safe mode
7. Full testing before going live

### Scenario 3: Hardware Failure
1. Provision new hardware
2. Install OS and software
3. Restore complete backup
4. Update DNS if IP changed
5. Test all functionality
6. Notify players of downtime
7. Monitor stability

### Recovery Time Objectives (RTO)
- Critical: 1 hour
- High: 4 hours
- Normal: 24 hours
- Low: 48 hours

### Recovery Point Objectives (RPO)
- Maximum data loss: 1 hour (hourly backups)
- Target: 15 minutes (with frequent snapshots)
```

---

## 10. Performance Tuning {#performance}

### Server Optimization Checklist

```markdown
☐ JVM Flags
  ☐ Using Aikar's flags
  ☐ Xms = Xmx/2
  ☐ G1GC enabled
  ☐ Appropriate heap size

☐ server.properties
  ☐ view-distance optimized (6-10)
  ☐ simulation-distance optimized
  ☐ entity limits configured
  ☐ redstone limits (if issues)

☐ Plugins
  ☐ Only necessary plugins
  ☐ All updated to latest
  ☐ No conflicting plugins
  ☐ Performance plugins added:
    - ClearLag (entity cleanup)
    - ChunkMaster (pre-generation)
    - LagAssist (lag management)

☐ World
  ☐ Pre-generate world chunks
  ☐ WorldBorder set
  ☐ Old chunks trimmed
  ☐ Mob spawners limited

☐ Hardware
  ☐ Running on SSD
  ☐ Sufficient RAM
  ☐ Good CPU (high single-thread)
  ☐ Fast network
```

### Benchmarking

```powershell
# Performance test script
function Test-ServerPerformance {
    param([string]$ServerPath)
    
    Write-Host "=== Server Performance Test ===" -ForegroundColor Cyan
    
    # 1. TPS Check
    # In-game: /tps (requires Paper/Spigot)
    Write-Host "Check TPS in-game with /tps command"
    Write-Host "Target: 20.0 TPS" -ForegroundColor Green
    
    # 2. Memory Usage
    $Process = Get-Process java | Where-Object { $_.Path -like "*$ServerPath*" }
    if ($Process) {
        $MemoryGB = [Math]::Round($Process.WorkingSet64 / 1GB, 2)
        Write-Host "Memory Usage: $MemoryGB GB" -ForegroundColor Yellow
    }
    
    # 3. CPU Usage
    $CPU = (Get-Process java).CPU
    Write-Host "CPU Time: $CPU seconds" -ForegroundColor Yellow
    
    # 4. Disk I/O
    $DiskCounter = Get-Counter "\PhysicalDisk(_Total)\Disk Reads/sec"
    Write-Host "Disk Reads/sec: $($DiskCounter.CounterSamples[0].CookedValue)" -ForegroundColor Yellow
    
    # 5. Network
    $NetworkCounter = Get-Counter "\Network Interface(*)\Bytes Total/sec"
    $TotalBytes = ($NetworkCounter.CounterSamples | Measure-Object -Property CookedValue -Sum).Sum
    Write-Host "Network: $([Math]::Round($TotalBytes/1MB, 2)) MB/s" -ForegroundColor Yellow
}

# Run benchmark
Test-ServerPerformance -ServerPath "C:\MinecraftProduction\server"
```

### Common Bottlenecks

**1. TPS Drops:**
```yaml
Causes:
  - Too many entities (mobs, items, minecarts)
  - Redstone lag (complex circuits)
  - Excessive chunk loading
  - Plugin overhead
  - Insufficient CPU

Solutions:
  - Install ClearLag
  - Limit hoppers/redstone
  - Pre-generate world
  - Profile with /timings
  - Upgrade CPU
```

**2. Memory Issues:**
```yaml
Causes:
  - Insufficient RAM allocation
  - Memory leaks (plugins)
  - Too many loaded chunks
  - Large player count

Solutions:
  - Increase Xmx
  - Update/remove leaky plugins
  - Lower view-distance
  - Optimize GC flags
```

**3. Disk I/O:**
```yaml
Causes:
  - Running on HDD (slow)
  - Excessive world saves
  - Large log files
  - Frequent backups

Solutions:
  - Migrate to SSD/NVMe
  - Adjust save intervals
  - Rotate logs
  - Optimize backup schedule
```

---

## 11. Scaling Strategy {#scaling}

### Vertical Scaling (Single Server)

```yaml
Phase 1: 0-50 players
  - Single server
  - 4 GB RAM
  - 4 cores
  - Cost: 50-100 PLN/msc

Phase 2: 50-100 players
  - Single server
  - 8 GB RAM
  - 6 cores
  - Cost: 100-200 PLN/msc

Phase 3: 100-200 players
  - Single server
  - 16 GB RAM
  - 8 cores
  - Cost: 200-400 PLN/msc

Limit: ~200-300 players per server (optimized)
```

### Horizontal Scaling (Multiple Servers)

```yaml
Phase 4: 200+ players
  - Multiple servers
  - BungeeCord/Velocity proxy
  - Shared database
  - Shared storage

Architecture:
  Proxy Server (BungeeCord):
    - 2 GB RAM
    - Player routing
    - Network hub
    
  Game Servers:
    - Lobby (4 GB)
    - Survival 1 (8 GB)
    - Survival 2 (8 GB)
    - Creative (4 GB)
    - Minigames (4 GB)
    
  Database Server:
    - MySQL/MariaDB
    - 4 GB RAM
    - Shared player data
    
  Web Server (optional):
    - Map viewer
    - Player stats
    - Shop interface
```

### Multi-Server Setup

```powershell
# Network architecture for 500+ players

# 1. Proxy Server (BungeeCord/Velocity)
.\MinecraftServerSetup.ps1 -ServerPath "C:\MC\Proxy" -MaxMemory 2048

# 2. Hub/Lobby Server
.\MinecraftServerSetup.ps1 -ServerPath "C:\MC\Hub" -MaxMemory 4096 -ServerPort 25566

# 3. Survival Server 1
.\MinecraftServerSetup.ps1 -ServerPath "C:\MC\Survival1" -MaxMemory 8192 -ServerPort 25567

# 4. Survival Server 2
.\MinecraftServerSetup.ps1 -ServerPath "C:\MC\Survival2" -MaxMemory 8192 -ServerPort 25568

# 5. Creative Server
.\MinecraftServerSetup.ps1 -ServerPath "C:\MC\Creative" -MaxMemory 4096 -ServerPort 25569

# 6. Minigames Server
.\MinecraftServerSetup.ps1 -ServerPath "C:\MC\Minigames" -MaxMemory 4096 -ServerPort 25570

# Configure BungeeCord config.yml to route players
```

---

## 12. Maintenance {#maintenance}

### Daily Tasks

```powershell
# Daily maintenance script
# Schedule: Every day at 4 AM

# 1. Check server status
$ServerProcess = Get-Process java -ErrorAction SilentlyContinue
if (-not $ServerProcess) {
    # Server is down, send alert
    Send-DiscordAlert "🔴 SERVER DOWN - Auto-restart attempted"
    .\StartServer.ps1 -NoGUI
}

# 2. Backup
.\BackupServer.ps1 -ServerPath "C:\MC\server"

# 3. Clean logs
Get-ChildItem "C:\MC\server\logs\*.log.gz" | 
    Where-Object { $_.CreationTime -lt (Get-Date).AddDays(-7) } | 
    Remove-Item -Force

# 4. Monitor disk space
$Disk = Get-PSDrive C
$FreeGB = [Math]::Round($Disk.Free / 1GB, 2)
if ($FreeGB -lt 10) {
    Send-DiscordAlert "⚠️ Low disk space: $FreeGB GB free"
}

# 5. Generate report
.\ServerMonitoring.ps1 -GenerateReports
```

### Weekly Tasks

```markdown
☐ Performance Review
  ☐ Check TPS trends
  ☐ Review memory usage
  ☐ Analyze player count trends
  ☐ Review revenue metrics
  
☐ Security Review
  ☐ Check for suspicious activity
  ☐ Review banned players
  ☐ Update security rules
  ☐ Check for plugin updates
  
☐ Community Management
  ☐ Respond to support tickets
  ☐ Review player feedback
  ☐ Plan events
  ☐ Update announcements
  
☐ Backup Verification
  ☐ Test restore process
  ☐ Verify backup integrity
  ☐ Check offsite backups
  ☐ Update disaster recovery plan
```

### Monthly Tasks

```markdown
☐ System Updates
  ☐ Windows/Linux updates
  ☐ PowerShell updates
  ☐ Java updates
  ☐ Plugin updates
  ☐ Server software updates
  
☐ Financial Review
  ☐ Revenue analysis
  ☐ Cost optimization
  ☐ Pricing adjustments
  ☐ Tax preparation (księgowy)
  
☐ Strategic Planning
  ☐ Growth metrics review
  ☐ Marketing campaigns
  ☐ New features planning
  ☐ Community feedback analysis
  
☐ Infrastructure Review
  ☐ Hardware health check
  ☐ Network performance
  ☐ Scaling needs
  ☐ Cost optimization
```

---

## 13. Troubleshooting {#troubleshooting}

Dla szczegółowego troubleshootingu, zobacz [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

### Quick Diagnostics

```powershell
# Quick server diagnostic script
function Get-ServerDiagnostics {
    Write-Host "=== SERVER DIAGNOSTICS ===" -ForegroundColor Cyan
    
    # Server process
    $Process = Get-Process java -ErrorAction SilentlyContinue
    if ($Process) {
        Write-Host "✅ Server is running (PID: $($Process.Id))" -ForegroundColor Green
    } else {
        Write-Host "❌ Server is NOT running" -ForegroundColor Red
    }
    
    # Port check
    $Port = Test-NetConnection -ComputerName localhost -Port 25565 -InformationLevel Quiet
    if ($Port) {
        Write-Host "✅ Port 25565 is open" -ForegroundColor Green
    } else {
        Write-Host "❌ Port 25565 is NOT accessible" -ForegroundColor Red
    }
    
    # Disk space
    $Disk = Get-PSDrive C
    $FreePercent = [Math]::Round(($Disk.Free / $Disk.Used) * 100, 2)
    if ($FreePercent -gt 20) {
        Write-Host "✅ Disk space OK: $FreePercent% free" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Low disk space: $FreePercent% free" -ForegroundColor Yellow
    }
    
    # Memory
    $OS = Get-CimInstance Win32_OperatingSystem
    $FreeMemPercent = [Math]::Round(($OS.FreePhysicalMemory / $OS.TotalVisibleMemorySize) * 100, 2)
    if ($FreeMemPercent -gt 10) {
        Write-Host "✅ Memory OK: $FreeMemPercent% free" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Low memory: $FreeMemPercent% free" -ForegroundColor Yellow
    }
    
    # Recent errors
    $ErrorCount = (Get-Content "C:\MC\server\logs\latest.log" | Select-String "ERROR|SEVERE").Count
    Write-Host "⚠️ Recent errors in log: $ErrorCount" -ForegroundColor $(if($ErrorCount -gt 0){"Yellow"}else{"Green"})
}

# Run diagnostics
Get-ServerDiagnostics
```

---

## 14. Rollback Procedures {#rollback}

### Emergency Rollback

```powershell
# Emergency rollback script
param(
    [Parameter(Mandatory=$true)]
    [string]$BackupFile,
    [string]$ServerPath = "C:\MinecraftProduction\server"
)

Write-Host "=== EMERGENCY ROLLBACK ===" -ForegroundColor Red
Write-Host "Backup: $BackupFile" -ForegroundColor Yellow
Write-Host "Target: $ServerPath" -ForegroundColor Yellow

# Confirm
$Confirm = Read-Host "Type 'YES' to proceed"
if ($Confirm -ne "YES") {
    Write-Host "Rollback cancelled" -ForegroundColor Yellow
    exit
}

try {
    # 1. Stop server
    Write-Host "Stopping server..." -ForegroundColor Cyan
    Get-Process java | Where-Object { $_.Path -like "*$ServerPath*" } | Stop-Process -Force
    Start-Sleep -Seconds 5
    
    # 2. Backup current state (emergency backup)
    Write-Host "Creating emergency backup of current state..." -ForegroundColor Cyan
    $EmergencyBackup = "C:\EmergencyBackup\rollback-$(Get-Date -Format 'yyyyMMdd-HHmmss').zip"
    Compress-Archive -Path $ServerPath -DestinationPath $EmergencyBackup
    
    # 3. Clear current server
    Write-Host "Clearing current server files..." -ForegroundColor Cyan
    Remove-Item "$ServerPath\*" -Recurse -Force -Exclude "server.jar"
    
    # 4. Restore backup
    Write-Host "Restoring from backup..." -ForegroundColor Cyan
    Expand-Archive -Path $BackupFile -DestinationPath $ServerPath -Force
    
    # 5. Verify
    Write-Host "Verifying restoration..." -ForegroundColor Cyan
    if (Test-Path "$ServerPath\world") {
        Write-Host "✅ Restoration successful" -ForegroundColor Green
    } else {
        Write-Host "❌ Restoration failed!" -ForegroundColor Red
        exit 1
    }
    
    # 6. Start server
    Write-Host "Starting server..." -ForegroundColor Cyan
    .\StartServer.ps1 -ServerPath $ServerPath -NoGUI
    
    Write-Host "✅ Rollback completed successfully" -ForegroundColor Green
    Write-Host "Emergency backup saved to: $EmergencyBackup" -ForegroundColor Yellow
}
catch {
    Write-Host "❌ Rollback failed: $_" -ForegroundColor Red
    Write-Host "Emergency backup location: $EmergencyBackup" -ForegroundColor Yellow
    exit 1
}
```

---

## 📞 Support & Resources

**Official Documentation:**
- [README.md](README.md) - Project overview
- [QUICK_START.md](QUICK_START.md) - Quick start guide
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Problem solving
- [CONTRIBUTING.md](CONTRIBUTING.md) - How to contribute

**Community:**
- GitHub Issues: https://github.com/hetwerk1943/Minecraft-Server-Automation/issues
- Email: hetwerk1943@gmail.com

**External Resources:**
- Minecraft Wiki: https://minecraft.fandom.com/
- Paper Docs: https://docs.papermc.io/
- Spigot Forums: https://www.spigotmc.org/
- Aikar's Flags: https://aikar.co/2018/07/02/tuning-the-jvm-g1gc-garbage-collector-flags-for-minecraft/

---

**Dokument utworzony przez:** GitHub Copilot Agent  
**Wersja:** 1.0  
**Data:** 2025-12-09  
**Status:** ✅ Production Ready

**Next Review:** Po pierwszym wdrożeniu produkcyjnym
