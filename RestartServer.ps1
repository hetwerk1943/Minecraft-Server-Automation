# =====================================================================
# Restart Minecraft Server Script
# =====================================================================
# Skrypt do bezpiecznego restartu serwera Minecraft

param(
    [string]$ServerFolder = "C:\MinecraftServer",
    [string]$RamAlloc = "-Xmx4G -Xms2G",
    [string]$ServerJarName = "server.jar",
    [int]$WaitSeconds = 10
)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  RESTART SERWERA MINECRAFT" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Sprawdź czy folder serwera istnieje
if (-not (Test-Path $ServerFolder)) {
    Write-Error "Folder serwera nie istnieje: $ServerFolder"
    Write-Host "Uruchom najpierw MinecraftServerSetup.ps1" -ForegroundColor Red
    exit 1
}

# Sprawdź czy plik JAR istnieje
$jarPath = Join-Path $ServerFolder $ServerJarName
if (-not (Test-Path $jarPath)) {
    Write-Error "Plik serwera nie znaleziony: $jarPath"
    Write-Host "Uruchom najpierw MinecraftServerSetup.ps1" -ForegroundColor Red
    exit 1
}

Write-Host "Szukanie uruchomionego procesu serwera Minecraft..." -ForegroundColor Cyan

# Znajdź proces Java uruchamiający serwer Minecraft
$serverProcess = Get-Process -Name "java" -ErrorAction SilentlyContinue | Where-Object {
    $_.CommandLine -like "*$ServerJarName*"
}

if ($serverProcess) {
    Write-Host "Znaleziono uruchomiony serwer (PID: $($serverProcess.Id))" -ForegroundColor Yellow
    Write-Host ""
    
    # Ostrzeżenie dla użytkownika
    Write-Warning "Restart serwera spowoduje rozłączenie wszystkich graczy!"
    $response = Read-Host "Czy kontynuować restart? (T/N)"
    
    if ($response -ne "T" -and $response -ne "t") {
        Write-Host "Restart anulowany." -ForegroundColor Yellow
        exit 0
    }
    
    Write-Host ""
    Write-Host "Zatrzymywanie serwera..." -ForegroundColor Yellow
    
    try {
        # Próba łagodnego zakończenia procesu
        $serverProcess | Stop-Process -Force
        Write-Host "Serwer zatrzymany." -ForegroundColor Green
    } catch {
        Write-Error "Błąd podczas zatrzymywania serwera: $_"
        exit 1
    }
    
    # Poczekaj, aby proces się zakończył
    Write-Host "Oczekiwanie $WaitSeconds sekund przed ponownym uruchomieniem..." -ForegroundColor Cyan
    Start-Sleep -Seconds $WaitSeconds
    
} else {
    Write-Host "Nie znaleziono uruchomionego serwera." -ForegroundColor Yellow
    Write-Host "Uruchamianie nowego serwera..." -ForegroundColor Cyan
}

# Uruchom serwer ponownie
Write-Host ""
Write-Host "Uruchamianie serwera Minecraft..." -ForegroundColor Green
Write-Host "Folder serwera: $ServerFolder" -ForegroundColor Gray
Write-Host "Alokacja RAM: $RamAlloc" -ForegroundColor Gray
Write-Host ""

# Sprawdź czy Java jest dostępna
if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
    Write-Error "Java nie jest zainstalowana lub niedostępna w PATH."
    Write-Host "Zainstaluj Javę lub uruchom MinecraftServerSetup.ps1" -ForegroundColor Red
    exit 1
}

# Przejdź do folderu serwera
Set-Location $ServerFolder

# Uruchom serwer
try {
    Write-Host "Serwer zostanie uruchomiony w nowym oknie..." -ForegroundColor Cyan
    Write-Host "Aby zatrzymać serwer, wpisz 'stop' w konsoli serwera." -ForegroundColor Yellow
    Write-Host ""
    
    # Uruchom serwer w nowym oknie PowerShell
    $RamArgs = $RamAlloc.Split()
    $Arguments = $RamArgs + @('-jar', $ServerJarName, 'nogui')
    
    Start-Process -FilePath "java" -ArgumentList $Arguments -WorkingDirectory $ServerFolder
    
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "  SERWER ZRESTARTOWANY POMYŚLNIE" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Serwer uruchamia się w osobnym oknie." -ForegroundColor Green
    Write-Host "Poczekaj aż zobaczysz komunikat 'Done!' w konsoli serwera." -ForegroundColor Cyan
    
} catch {
    Write-Error "Błąd podczas uruchamiania serwera: $_"
    exit 1
}

Write-Host ""
Write-Host "Restart zakończony." -ForegroundColor Cyan
