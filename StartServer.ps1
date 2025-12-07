# =====================================================================
# Start Minecraft Server Script
# =====================================================================
# Skrypt do szybkiego uruchamiania serwera Minecraft

param(
    [string]$ServerFolder = "C:\MinecraftServer",
    [string]$RamAlloc = "-Xmx2G -Xms1G",
    [string]$ServerJarName = "server.jar"
)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  URUCHAMIANIE SERWERA MINECRAFT" -ForegroundColor Cyan
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

# Sprawdź czy Java jest dostępna
if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
    Write-Error "Java nie jest zainstalowana lub niedostępna w PATH."
    Write-Host "Zainstaluj Javę lub uruchom MinecraftServerSetup.ps1" -ForegroundColor Red
    exit 1
}

# Przejdź do folderu serwera
Set-Location $ServerFolder

Write-Host "Folder serwera: $ServerFolder" -ForegroundColor Green
Write-Host "Alokacja RAM: $RamAlloc" -ForegroundColor Green
Write-Host "Plik JAR: $ServerJarName" -ForegroundColor Green
Write-Host ""
Write-Host "Uruchamianie serwera..." -ForegroundColor Cyan
Write-Host "Aby zatrzymać serwer, wpisz 'stop' w konsoli serwera." -ForegroundColor Yellow
Write-Host ""

# Uruchom serwer
try {
    java $RamAlloc.Split() -jar $ServerJarName nogui
} catch {
    Write-Error "Błąd podczas uruchamiania serwera: $_"
    exit 1
}
