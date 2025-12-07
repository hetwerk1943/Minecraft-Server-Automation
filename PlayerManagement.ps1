# PlayerManagement.ps1
# Skrypt do zarządzania graczami i analityki
# © 2025 Dominik Opałka

param(
    [string]$ServerPath = ".\MinecraftServer",
    [string]$Action = "stats",
    [string]$PlayerName = "",
    [int]$TopPlayersCount = 10
)

function Write-ColorMessage {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Get-PlayerDatabase {
    param([string]$ServerPath)
    
    try {
        $dbPath = Join-Path $ServerPath "playerdata.json"
        
        if (Test-Path $dbPath) {
            $json = Get-Content $dbPath -Raw | ConvertFrom-Json
            return $json
        }
        else {
            # Inicjalizacja nowej bazy danych
            return @{
                players = @()
                lastUpdate = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            }
        }
    }
    catch {
        Write-ColorMessage "Błąd podczas odczytu bazy graczy: $_" "Red"
        return $null
    }
}

function Save-PlayerDatabase {
    param(
        [string]$ServerPath,
        [object]$Database
    )
    
    try {
        $dbPath = Join-Path $ServerPath "playerdata.json"
        $Database.lastUpdate = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        $Database | ConvertTo-Json -Depth 10 | Out-File -FilePath $dbPath -Encoding UTF8
        return $true
    }
    catch {
        Write-ColorMessage "Błąd podczas zapisywania bazy graczy: $_" "Red"
        return $false
    }
}

function Get-PlayerStats {
    param(
        [string]$ServerPath,
        [string]$PlayerName
    )
    
    try {
        $statsFile = Join-Path $ServerPath "stats\$PlayerName.json"
        
        if (-not (Test-Path $statsFile)) {
            Write-ColorMessage "Nie znaleziono statystyk dla gracza: $PlayerName" "Yellow"
            return $null
        }
        
        $stats = Get-Content $statsFile -Raw | ConvertFrom-Json
        
        $playerStats = @{
            Name = $PlayerName
            PlayTime = 0
            Deaths = 0
            Kills = 0
            BlocksMined = 0
            BlocksPlaced = 0
            ItemsCrafted = 0
            DistanceTraveled = 0
            DamageDealt = 0
            DamageTaken = 0
        }
        
        # Parsowanie statystyk (uproszczone)
        if ($stats.stats) {
            if ($stats.stats.'minecraft:custom') {
                $custom = $stats.stats.'minecraft:custom'
                
                if ($custom.'minecraft:play_time') {
                    $playerStats.PlayTime = [Math]::Round($custom.'minecraft:play_time' / 72000, 2)  # w godzinach
                }
                if ($custom.'minecraft:deaths') {
                    $playerStats.Deaths = $custom.'minecraft:deaths'
                }
                if ($custom.'minecraft:mob_kills') {
                    $playerStats.Kills = $custom.'minecraft:mob_kills'
                }
            }
            
            if ($stats.stats.'minecraft:mined') {
                $playerStats.BlocksMined = ($stats.stats.'minecraft:mined'.PSObject.Properties.Value | Measure-Object -Sum).Sum
            }
            
            if ($stats.stats.'minecraft:used') {
                $playerStats.BlocksPlaced = ($stats.stats.'minecraft:used'.PSObject.Properties.Value | Measure-Object -Sum).Sum
            }
        }
        
        return $playerStats
    }
    catch {
        Write-ColorMessage "Błąd podczas odczytu statystyk gracza: $_" "Red"
        return $null
    }
}

function Get-TopPlayers {
    param(
        [string]$ServerPath,
        [int]$Count
    )
    
    try {
        $statsPath = Join-Path $ServerPath "stats"
        
        if (-not (Test-Path $statsPath)) {
            Write-ColorMessage "Brak katalogu statystyk" "Yellow"
            return @()
        }
        
        $allPlayers = @()
        $statsFiles = Get-ChildItem -Path $statsPath -Filter "*.json"
        
        foreach ($file in $statsFiles) {
            $playerName = $file.BaseName
            $stats = Get-PlayerStats -ServerPath $ServerPath -PlayerName $playerName
            
            if ($stats) {
                $allPlayers += $stats
            }
        }
        
        $topPlayers = $allPlayers | Sort-Object -Property PlayTime -Descending | Select-Object -First $Count
        return $topPlayers
    }
    catch {
        Write-ColorMessage "Błąd podczas pobierania topowych graczy: $_" "Red"
        return @()
    }
}

function Show-PlayerReport {
    param([object]$Stats)
    
    if (-not $Stats) {
        return
    }
    
    Write-ColorMessage "`n=== Raport Gracza: $($Stats.Name) ===" "Cyan"
    Write-ColorMessage "Czas gry: $($Stats.PlayTime) godzin" "White"
    Write-ColorMessage "Śmierci: $($Stats.Deaths)" "Red"
    Write-ColorMessage "Zabójstwa mobów: $($Stats.Kills)" "Green"
    Write-ColorMessage "Wykopane bloki: $($Stats.BlocksMined)" "Yellow"
    Write-ColorMessage "Umieszczone bloki: $($Stats.BlocksPlaced)" "Yellow"
    
    # KDR (Kill-Death Ratio)
    if ($Stats.Deaths -gt 0) {
        $kdr = [Math]::Round($Stats.Kills / $Stats.Deaths, 2)
        Write-ColorMessage "KDR: $kdr" "Cyan"
    }
    
    # Średnia aktywność
    if ($Stats.PlayTime -gt 0) {
        $blocksPerHour = [Math]::Round($Stats.BlocksMined / $Stats.PlayTime, 0)
        Write-ColorMessage "Średnio bloków/godz: $blocksPerHour" "White"
    }
}

function Show-TopPlayersReport {
    param(
        [array]$TopPlayers
    )
    
    if ($TopPlayers.Count -eq 0) {
        Write-ColorMessage "Brak danych o graczach" "Yellow"
        return
    }
    
    Write-ColorMessage "`n=== Top $($TopPlayers.Count) Graczy ===" "Cyan"
    Write-ColorMessage ("=" * 80) "Cyan"
    Write-ColorMessage $("{0,-5} {1,-20} {2,-15} {3,-10} {4,-10}" -f "#", "Nick", "Czas Gry", "Śmierci", "Zabójstwa") "Yellow"
    Write-ColorMessage ("=" * 80) "Cyan"
    
    $position = 1
    foreach ($player in $TopPlayers) {
        $color = switch ($position) {
            1 { "Green" }
            2 { "Cyan" }
            3 { "Yellow" }
            default { "White" }
        }
        
        Write-ColorMessage $("{0,-5} {1,-20} {2,-15} {3,-10} {4,-10}" -f `
            $position, `
            $player.Name, `
            "$($player.PlayTime)h", `
            $player.Deaths, `
            $player.Kills) $color
        
        $position++
    }
    
    Write-ColorMessage ("=" * 80) "Cyan"
    
    # Statystyki agregowane
    $totalPlayTime = ($TopPlayers | Measure-Object -Property PlayTime -Sum).Sum
    $avgPlayTime = ($TopPlayers | Measure-Object -Property PlayTime -Average).Average
    
    Write-ColorMessage "`nStatystyki agregatowe:" "Cyan"
    Write-ColorMessage "Łączny czas gry: $([Math]::Round($totalPlayTime, 2)) godzin" "White"
    Write-ColorMessage "Średni czas gry: $([Math]::Round($avgPlayTime, 2)) godzin" "White"
}

function New-PlayerActivityReport {
    param(
        [string]$ServerPath
    )
    
    try {
        $date = Get-Date -Format "yyyy-MM-dd"
        $topPlayers = Get-TopPlayers -ServerPath $ServerPath -Count 20
        
        if ($topPlayers.Count -eq 0) {
            Write-ColorMessage "Brak danych do wygenerowania raportu" "Yellow"
            return
        }
        
        $report = @"
# Raport Aktywności Graczy
Data: $date

## 📊 Top 20 Graczy wg Czasu Gry

| # | Nick | Czas Gry (h) | Śmierci | Zabójstwa | KDR | Bloki Wykopane |
|---|------|--------------|---------|-----------|-----|----------------|
"@
        
        $position = 1
        foreach ($player in $topPlayers) {
            $kdr = if ($player.Deaths -gt 0) { [Math]::Round($player.Kills / $player.Deaths, 2) } else { "N/A" }
            $report += "| $position | $($player.Name) | $($player.PlayTime) | $($player.Deaths) | $($player.Kills) | $kdr | $($player.BlocksMined) |`n"
            $position++
        }
        
        $report += @"

## 📈 Statystyki Agregatowe

- **Łączny czas gry wszystkich graczy**: $([Math]::Round(($topPlayers | Measure-Object -Property PlayTime -Sum).Sum, 2)) godzin
- **Średni czas gry**: $([Math]::Round(($topPlayers | Measure-Object -Property PlayTime -Average).Average, 2)) godzin
- **Najwięcej wykopanych bloków**: $($topPlayers | Sort-Object -Property BlocksMined -Descending | Select-Object -First 1 | Select-Object -ExpandProperty Name) ($($topPlayers | Sort-Object -Property BlocksMined -Descending | Select-Object -First 1 | Select-Object -ExpandProperty BlocksMined) bloków)
- **Najwięcej zabójstw**: $($topPlayers | Sort-Object -Property Kills -Descending | Select-Object -First 1 | Select-Object -ExpandProperty Name) ($($topPlayers | Sort-Object -Property Kills -Descending | Select-Object -First 1 | Select-Object -ExpandProperty Kills) zabójstw)

## 💡 Insights

### Zaangażowanie Graczy
"@
        
        $avgPlayTime = ($topPlayers | Measure-Object -Property PlayTime -Average).Average
        if ($avgPlayTime -gt 50) {
            $report += "✅ Bardzo wysokie zaangażowanie graczy! Średni czas gry powyżej 50 godzin.`n"
        }
        elseif ($avgPlayTime -gt 20) {
            $report += "✅ Dobre zaangażowanie graczy. Średni czas gry: $([Math]::Round($avgPlayTime, 2)) godzin.`n"
        }
        else {
            $report += "⚠️ Niskie zaangażowanie graczy. Rozważ dodanie nowych atrakcji.`n"
        }
        
        $report += @"

### Rekomendacje
- Nagradzaj najaktywniejszych graczy (top 10) specjalnymi rangami lub przedmiotami
- Organizuj eventy dla graczy z niższą aktywnością
- Rozważ system lojalnościowy za czas gry

## 💰 Potencjał Monetyzacji

Bazując na $($topPlayers.Count) aktywnych graczy:
- Potencjalni płatni gracze (10% konwersja): $([Math]::Round($topPlayers.Count * 0.1, 0))
- Szacowany miesięczny przychód (30 PLN/gracz): $([Math]::Round($topPlayers.Count * 0.1 * 30, 0)) PLN
- Potencjał roczny: $([Math]::Round($topPlayers.Count * 0.1 * 30 * 12, 0)) PLN

---
Wygenerowano: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@
        
        $reportFile = Join-Path $ServerPath "player_activity_$date.md"
        $report | Out-File -FilePath $reportFile -Encoding UTF8
        
        Write-ColorMessage "Wygenerowano raport aktywności: $reportFile" "Green"
        return $reportFile
    }
    catch {
        Write-ColorMessage "Błąd podczas generowania raportu aktywności: $_" "Red"
        return $null
    }
}

function Send-RewardsToTopPlayers {
    param(
        [string]$ServerPath,
        [int]$TopCount
    )
    
    try {
        $topPlayers = Get-TopPlayers -ServerPath $ServerPath -Count $TopCount
        
        if ($topPlayers.Count -eq 0) {
            Write-ColorMessage "Brak graczy do nagrodzenia" "Yellow"
            return
        }
        
        Write-ColorMessage "`n=== Generowanie nagród dla Top $TopCount graczy ===" "Cyan"
        
        $commandsFile = Join-Path $ServerPath "reward_commands.txt"
        $commands = @()
        
        $position = 1
        foreach ($player in $topPlayers) {
            $reward = switch ($position) {
                1 { 
                    @{
                        Money = 10000
                        Items = "diamond_block 5, emerald_block 3, netherite_ingot 2"
                        Rank = "Legend"
                    }
                }
                2 { 
                    @{
                        Money = 5000
                        Items = "diamond_block 3, emerald_block 2, netherite_ingot 1"
                        Rank = "Elite"
                    }
                }
                3 { 
                    @{
                        Money = 2500
                        Items = "diamond_block 2, emerald_block 1"
                        Rank = "Master"
                    }
                }
                default { 
                    @{
                        Money = 1000
                        Items = "diamond_block 1"
                        Rank = "Expert"
                    }
                }
            }
            
            $commands += "# Pozycja $position : $($player.Name)"
            $commands += "eco give $($player.Name) $($reward.Money)"
            $commands += "lp user $($player.Name) parent set $($reward.Rank)"
            
            foreach ($item in $reward.Items -split ", ") {
                $itemParts = $item -split " "
                $commands += "give $($player.Name) $($itemParts[0]) $($itemParts[1])"
            }
            $commands += ""
            
            Write-ColorMessage "$position. $($player.Name) - $($reward.Money) monet + $($reward.Items) + ranga $($reward.Rank)" "Green"
            $position++
        }
        
        $commands | Out-File -FilePath $commandsFile -Encoding UTF8
        Write-ColorMessage "`nKomendy nagród zapisane do: $commandsFile" "Cyan"
        Write-ColorMessage "Skopiuj i wklej do konsoli serwera aby przyznać nagrody" "Yellow"
        
        return $commandsFile
    }
    catch {
        Write-ColorMessage "Błąd podczas generowania nagród: $_" "Red"
        return $null
    }
}

# Główna logika skryptu
try {
    Write-ColorMessage "`n=== Minecraft Player Management ===" "Cyan"
    
    switch ($Action.ToLower()) {
        "stats" {
            if ([string]::IsNullOrEmpty($PlayerName)) {
                Write-ColorMessage "Podaj nazwę gracza: -PlayerName <nick>" "Yellow"
                exit 1
            }
            
            $stats = Get-PlayerStats -ServerPath $ServerPath -PlayerName $PlayerName
            Show-PlayerReport -Stats $stats
        }
        
        "top" {
            $topPlayers = Get-TopPlayers -ServerPath $ServerPath -Count $TopPlayersCount
            Show-TopPlayersReport -TopPlayers $topPlayers
        }
        
        "report" {
            $reportFile = New-PlayerActivityReport -ServerPath $ServerPath
            if ($reportFile) {
                Write-ColorMessage "`nRaport wygenerowany: $reportFile" "Green"
            }
        }
        
        "rewards" {
            $commandsFile = Send-RewardsToTopPlayers -ServerPath $ServerPath -TopCount $TopPlayersCount
            if ($commandsFile) {
                Write-ColorMessage "`nNagrody przygotowane!" "Green"
            }
        }
        
        default {
            Write-ColorMessage "Nieznana akcja: $Action" "Red"
            Write-ColorMessage "`nDostępne akcje:" "Cyan"
            Write-ColorMessage "  stats   - Wyświetl statystyki gracza (-PlayerName wymagany)" "White"
            Write-ColorMessage "  top     - Wyświetl topowych graczy (-TopPlayersCount opcjonalny)" "White"
            Write-ColorMessage "  report  - Wygeneruj raport aktywności" "White"
            Write-ColorMessage "  rewards - Przygotuj nagrody dla topowych graczy" "White"
        }
    }
}
catch {
    Write-ColorMessage "`n=== Błąd zarządzania graczami ===" "Red"
    Write-ColorMessage "Szczegóły: $_" "Red"
    Write-ColorMessage $_.ScriptStackTrace "Red"
    exit 1
}
