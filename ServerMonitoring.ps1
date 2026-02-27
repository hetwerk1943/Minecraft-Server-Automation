# ServerMonitoring.ps1
# Skrypt do monitorowania i analityki serwera Minecraft
# © 2025 Dominik Opałka

param(
    [string]$ServerPath = ".\MinecraftServer",
    [string]$LogPath = ".\Logs",
    [int]$MonitorIntervalSeconds = 60,
    [switch]$EnableDiscordWebhook,
    [string]$DiscordWebhookUrl = "",
    [switch]$GenerateReports
)

Import-Module (Join-Path $PSScriptRoot "lib\SharedFunctions.psm1") -Force

function Get-ServerMetrics {
    param([string]$ServerPath)
    
    try {
        $metrics = @{
            Timestamp = Get-Date
            ServerOnline = $false
            PlayerCount = 0
            TPS = 0
            MemoryUsed = 0
            MemoryMax = 0
            CPUUsage = 0
            DiskSpace = 0
        }
        
        # Sprawdzenie czy serwer działa
        $serverProcess = Get-Process -Name "java" -ErrorAction SilentlyContinue | 
            Where-Object { $_.Path -and $_.Path -like "*$ServerPath*" }
        
        if ($serverProcess) {
            # Jeśli jest wiele procesów, użyj pierwszego
            if ($serverProcess -is [array]) {
                $serverProcess = $serverProcess[0]
            }
            
            $metrics.ServerOnline = $true
            
            # Użycie pamięci
            $metrics.MemoryUsed = [Math]::Round($serverProcess.WorkingSet64 / 1MB, 2)
            
            # Użycie CPU
            $cpuCounter = Get-Counter "\Process($($serverProcess.Name))\% Processor Time" -ErrorAction SilentlyContinue
            if ($cpuCounter) {
                $metrics.CPUUsage = [Math]::Round($cpuCounter.CounterSamples[0].CookedValue, 2)
            }
        }
        
        # Miejsce na dysku
        $drive = (Get-Item $ServerPath).PSDrive
        $diskInfo = Get-PSDrive -Name $drive.Name
        $metrics.DiskSpace = [Math]::Round($diskInfo.Free / 1GB, 2)
        
        return $metrics
    }
    catch {
        Write-ColorMessage "Błąd podczas zbierania metryk: $_" "Red"
        return $null
    }
}

function Get-PlayerActivity {
    param([string]$ServerPath)
    
    try {
        $logFile = Join-Path $ServerPath (Join-Path "logs" "latest.log")
        if (-not (Test-Path $logFile)) {
            return @{
                CurrentPlayers = @()
                PeakPlayers = 0
                TotalJoins = 0
                TotalLeaves = 0
            }
        }
        
        $logContent = Get-Content $logFile -Tail 1000
        
        $joins = ($logContent | Select-String "joined the game").Count
        $leaves = ($logContent | Select-String "left the game").Count
        
        # Aktualni gracze (uproszczona logika)
        $currentPlayers = @()
        $playerPattern = "\[.*\]: (\w+) joined the game"
        $logContent | Select-String $playerPattern | ForEach-Object {
            $currentPlayers += $_.Matches.Groups[1].Value
        }
        $currentPlayers = $currentPlayers | Select-Object -Unique
        
        return @{
            CurrentPlayers = $currentPlayers
            PlayerCount = $currentPlayers.Count
            TotalJoins = $joins
            TotalLeaves = $leaves
            PeakPlayers = [Math]::Max($currentPlayers.Count, 0)
        }
    }
    catch {
        Write-ColorMessage "Błąd podczas analizy aktywności graczy: $_" "Red"
        return $null
    }
}

function Send-DiscordNotification {
    param(
        [string]$WebhookUrl,
        [hashtable]$Metrics,
        [hashtable]$PlayerActivity
    )
    
    try {
        if ([string]::IsNullOrEmpty($WebhookUrl)) {
            return
        }
        
        $status = if ($Metrics.ServerOnline) { "🟢 Online" } else { "🔴 Offline" }
        $color = if ($Metrics.ServerOnline) { 3066993 } else { 15158332 }
        
        $embed = @{
            embeds = @(
                @{
                    title = "Minecraft Server Status"
                    description = "Status serwera: $status"
                    color = $color
                    fields = @(
                        @{
                            name = "👥 Gracze Online"
                            value = "$($PlayerActivity.PlayerCount)"
                            inline = $true
                        },
                        @{
                            name = "📊 Peak Graczy"
                            value = "$($PlayerActivity.PeakPlayers)"
                            inline = $true
                        },
                        @{
                            name = "💾 Użycie Pamięci"
                            value = "$($Metrics.MemoryUsed) MB"
                            inline = $true
                        },
                        @{
                            name = "⚡ Użycie CPU"
                            value = "$($Metrics.CPUUsage)%"
                            inline = $true
                        },
                        @{
                            name = "💿 Wolne Miejsce"
                            value = "$($Metrics.DiskSpace) GB"
                            inline = $true
                        },
                        @{
                            name = "🔄 Dołączenia/Wyjścia"
                            value = "$($PlayerActivity.TotalJoins) / $($PlayerActivity.TotalLeaves)"
                            inline = $true
                        }
                    )
                    timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                    footer = @{
                        text = "Minecraft Server Monitoring"
                    }
                }
            )
        } | ConvertTo-Json -Depth 10
        
        try {
            Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $embed -ContentType "application/json" | Out-Null
            Write-ColorMessage "Wysłano powiadomienie na Discord" "Green"
        }
        catch [System.Net.WebException] {
            $statusCode = $_.Exception.Response.StatusCode.value__
            if ($statusCode -eq 429) {
                Write-ColorMessage "Rate limit Discord - spróbuj ponownie później" "Yellow"
            }
            elseif ($statusCode -eq 404) {
                Write-ColorMessage "Nieprawidłowy webhook URL Discord" "Red"
            }
            else {
                Write-ColorMessage "Błąd HTTP $statusCode podczas wysyłania do Discord" "Red"
            }
        }
    }
    catch {
        Write-ColorMessage "Błąd podczas wysyłania powiadomienia Discord: $_" "Red"
    }
}

function Save-MetricsLog {
    param(
        [string]$LogPath,
        [hashtable]$Metrics,
        [hashtable]$PlayerActivity
    )
    
    try {
        if (-not (Test-Path $LogPath)) {
            New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
        }
        
        $date = Get-Date -Format "yyyy-MM-dd"
        $logFile = Join-Path $LogPath "metrics_$date.csv"
        
        $logEntry = [PSCustomObject]@{
            Timestamp = $Metrics.Timestamp.ToString("yyyy-MM-dd HH:mm:ss")
            ServerOnline = $Metrics.ServerOnline
            PlayerCount = $PlayerActivity.PlayerCount
            MemoryUsedMB = $Metrics.MemoryUsed
            CPUUsagePercent = $Metrics.CPUUsage
            DiskSpaceGB = $Metrics.DiskSpace
            TotalJoins = $PlayerActivity.TotalJoins
            TotalLeaves = $PlayerActivity.TotalLeaves
        }
        
        if (-not (Test-Path $logFile)) {
            $logEntry | Export-Csv -Path $logFile -NoTypeInformation -Encoding UTF8
        }
        else {
            $logEntry | Export-Csv -Path $logFile -NoTypeInformation -Append -Encoding UTF8
        }
        
        Write-ColorMessage "Zapisano metryki do: $logFile" "Green"
    }
    catch {
        Write-ColorMessage "Błąd podczas zapisywania metryk: $_" "Red"
    }
}

function New-DailyReport {
    param(
        [string]$LogPath,
        [string]$ServerPath
    )
    
    try {
        $date = Get-Date -Format "yyyy-MM-dd"
        $metricsFile = Join-Path $LogPath "metrics_$date.csv"
        
        if (-not (Test-Path $metricsFile)) {
            Write-ColorMessage "Brak danych metryk dla dnia $date" "Yellow"
            return
        }
        
        $metrics = Import-Csv $metricsFile
        
        $report = @"
# Raport Dzienny Serwera Minecraft
Data: $date

## 📊 Statystyki

### Gracze
- Maksymalna liczba graczy online: $($metrics | Measure-Object -Property PlayerCount -Maximum | Select-Object -ExpandProperty Maximum)
- Średnia liczba graczy: $([Math]::Round(($metrics | Measure-Object -Property PlayerCount -Average | Select-Object -ExpandProperty Average), 2))
- Łączne dołączenia: $($metrics | Select-Object -Last 1 | Select-Object -ExpandProperty TotalJoins)
- Łączne wyjścia: $($metrics | Select-Object -Last 1 | Select-Object -ExpandProperty TotalLeaves)

### Wydajność
- Średnie użycie pamięci: $([Math]::Round(($metrics | Measure-Object -Property MemoryUsedMB -Average | Select-Object -ExpandProperty Average), 2)) MB
- Maksymalne użycie pamięci: $($metrics | Measure-Object -Property MemoryUsedMB -Maximum | Select-Object -ExpandProperty Maximum) MB
- Średnie użycie CPU: $([Math]::Round(($metrics | Measure-Object -Property CPUUsagePercent -Average | Select-Object -ExpandProperty Average), 2))%
- Maksymalne użycie CPU: $($metrics | Measure-Object -Property CPUUsagePercent -Maximum | Select-Object -ExpandProperty Maximum)%

### System
- Wolne miejsce na dysku: $($metrics | Select-Object -Last 1 | Select-Object -ExpandProperty DiskSpaceGB) GB
- Czas działania serwera: $([Math]::Round((($metrics | Where-Object { $_.ServerOnline -eq 'True' }).Count / $metrics.Count * 100), 2))%

## 📈 Rekomendacje

"@
        
        # Analiza i rekomendacje
        $avgMemory = $metrics | Measure-Object -Property MemoryUsedMB -Average | Select-Object -ExpandProperty Average
        if ($avgMemory -gt 1500) {
            $report += "⚠️ **Pamięć**: Średnie użycie pamięci jest wysokie. Rozważ zwiększenie alokacji RAM.`n"
        }
        
        $avgCPU = $metrics | Measure-Object -Property CPUUsagePercent -Average | Select-Object -ExpandProperty Average
        if ($avgCPU -gt 70) {
            $report += "⚠️ **CPU**: Wysokie użycie CPU. Zoptymalizuj konfigurację serwera lub rozważ upgrade.`n"
        }
        
        $avgPlayers = $metrics | Measure-Object -Property PlayerCount -Average | Select-Object -ExpandProperty Average
        if ($avgPlayers -lt 5) {
            $report += "💡 **Marketing**: Niska średnia graczy. Zwiększ działania marketingowe.`n"
        }
        elseif ($avgPlayers -gt 15) {
            $report += "🎉 **Sukces**: Wysoka średnia graczy! Rozważ ekspansję serwera.`n"
        }
        
        $diskSpace = $metrics | Select-Object -Last 1 | Select-Object -ExpandProperty DiskSpaceGB
        if ($diskSpace -lt 10) {
            $report += "⚠️ **Dysk**: Mało miejsca na dysku. Wykonaj czyszczenie lub zwiększ przestrzeń.`n"
        }
        
        $report += @"

## 💰 Szacowane Przychody

Bazując na średniej liczby graczy ($([Math]::Round($avgPlayers, 0))) i konwersji 10%:
- Potencjalni płatni gracze: $([Math]::Round($avgPlayers * 0.1, 0))
- Szacowany przychód miesięczny: $([Math]::Round($avgPlayers * 0.1 * 30, 0)) PLN

---
Wygenerowano: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@
        
        $reportFile = Join-Path $LogPath "report_$date.md"
        $report | Out-File -FilePath $reportFile -Encoding UTF8
        
        Write-ColorMessage "Wygenerowano raport dzienny: $reportFile" "Green"
        return $reportFile
    }
    catch {
        Write-ColorMessage "Błąd podczas generowania raportu: $_" "Red"
        return $null
    }
}

function Start-ContinuousMonitoring {
    param(
        [string]$ServerPath,
        [string]$LogPath,
        [int]$IntervalSeconds,
        [bool]$UseDiscord,
        [string]$WebhookUrl
    )
    
    Write-ColorMessage "`n=== Rozpoczęto ciągłe monitorowanie ===" "Cyan"
    Write-ColorMessage "Interwał: $IntervalSeconds sekund" "White"
    Write-ColorMessage "Naciśnij Ctrl+C aby zatrzymać`n" "Yellow"
    
    $iteration = 0
    while ($true) {
        try {
            $iteration++
            Write-ColorMessage "`n--- Iteracja #$iteration ---" "Cyan"
            
            # Zbieranie metryk
            $metrics = Get-ServerMetrics -ServerPath $ServerPath
            $playerActivity = Get-PlayerActivity -ServerPath $ServerPath
            
            if ($metrics) {
                Write-ColorMessage "Status serwera: $(if ($metrics.ServerOnline) { 'Online' } else { 'Offline' })" "$(if ($metrics.ServerOnline) { 'Green' } else { 'Red' })"
                Write-ColorMessage "Gracze online: $($playerActivity.PlayerCount)" "White"
                Write-ColorMessage "Pamięć: $($metrics.MemoryUsed) MB" "White"
                Write-ColorMessage "CPU: $($metrics.CPUUsage)%" "White"
                Write-ColorMessage "Dysk: $($metrics.DiskSpace) GB wolne" "White"
                
                # Zapisywanie metryk
                Save-MetricsLog -LogPath $LogPath -Metrics $metrics -PlayerActivity $playerActivity
                
                # Discord webhook
                if ($UseDiscord -and -not [string]::IsNullOrEmpty($WebhookUrl)) {
                    if ($iteration % 10 -eq 0) {  # Co 10 iteracji
                        Send-DiscordNotification -WebhookUrl $WebhookUrl -Metrics $metrics -PlayerActivity $playerActivity
                    }
                }
            }
            
            Start-Sleep -Seconds $IntervalSeconds
        }
        catch {
            Write-ColorMessage "Błąd w pętli monitorowania: $_" "Red"
            Start-Sleep -Seconds $IntervalSeconds
        }
    }
}

# Główna logika skryptu
try {
    Write-ColorMessage "`n=== Minecraft Server Monitoring ===" "Cyan"
    Write-ColorMessage "Ścieżka serwera: $ServerPath" "White"
    Write-ColorMessage "Ścieżka logów: $LogPath" "White"
    
    if ($GenerateReports) {
        Write-ColorMessage "`nGenerowanie raportu dziennego..." "Cyan"
        $reportFile = New-DailyReport -LogPath $LogPath -ServerPath $ServerPath
        if ($reportFile) {
            Write-ColorMessage "Raport wygenerowany pomyślnie!" "Green"
            Write-ColorMessage "Zobacz: $reportFile" "Cyan"
        }
    }
    else {
        # Tryb ciągłego monitorowania
        Start-ContinuousMonitoring -ServerPath $ServerPath -LogPath $LogPath `
            -IntervalSeconds $MonitorIntervalSeconds -UseDiscord $EnableDiscordWebhook `
            -WebhookUrl $DiscordWebhookUrl
    }
}
catch {
    Write-ColorMessage "`n=== Błąd monitorowania ===" "Red"
    Write-ColorMessage "Szczegóły: $_" "Red"
    Write-ColorMessage $_.ScriptStackTrace "Red"
    exit 1
}
