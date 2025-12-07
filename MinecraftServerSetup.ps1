# =====================================================================
# Minecraft Server Automation Script
# =====================================================================
# Uruchom ten skrypt w PowerShell ISE lub konsoli działającej JAKO ADMINISTRATOR.

# --- PARAMETRY KONFIGURACYJNE ---
$MinecraftVersion = "1.20.4" # Zmień na pożądaną wersję
$ServerFolder   = "C:\MinecraftServer"
$RamAlloc       = "-Xmx4G -Xms2G" # 4GB maksymalnie, 2GB startowo
$ServerJarName  = "server.jar"
$EulaAgreement  = "eula=true"

# Adres URL do pobrania pliku JAR serwera (dla wybranej wersji)
# ZAWSZE sprawdź aktualny link na oficjalnej stronie Minecrafta!
$DownloadUrl = "https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar"

# ---------------------------------

function Install-JavaRuntime {
    Write-Host "Sprawdzanie i instalacja Java Runtime Environment (JRE)..." -ForegroundColor Cyan
    # Prosta weryfikacja, czy Java jest w PATH.
    if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
        Write-Host "Java nie znaleziona. Użycie Chocolatey do instalacji OpenJDK..." -ForegroundColor Yellow
        # Automatyczna instalacja Chocolatey (menedżer pakietów Windows)
        if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
            Write-Host "Instalacja Chocolatey..." -ForegroundColor Yellow
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        }
        # Instalacja Javy (np. temurin-jre)
        choco install -y temurin17jre # Wersja 17 lub nowsza jest wymagana
        Write-Host "Java zainstalowana. Może być wymagane ponowne uruchomienie sesji PowerShell." -ForegroundColor Green
        # Odśwież zmienne środowiskowe
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    } else {
        $javaVersion = java -version 2>&1 | Select-Object -First 1
        Write-Host "Java jest już zainstalowana: $javaVersion" -ForegroundColor Green
    }
}

function Setup-ServerFolders {
    Write-Host "Tworzenie folderów serwera w $ServerFolder..." -ForegroundColor Cyan
    if (-not (Test-Path $ServerFolder)) {
        New-Item -Path $ServerFolder -ItemType Directory | Out-Null
        Write-Host "Utworzono folder serwera: $ServerFolder" -ForegroundColor Green
    } else {
        Write-Host "Folder serwera już istnieje: $ServerFolder" -ForegroundColor Yellow
    }
    Set-Location $ServerFolder
}

function Download-MinecraftServer {
    Write-Host "Pobieranie pliku serwera Minecraft JAR..." -ForegroundColor Cyan
    $FilePath = Join-Path $ServerFolder $ServerJarName

    if (-not (Test-Path $FilePath)) {
        try {
            Write-Host "Pobieranie z: $DownloadUrl" -ForegroundColor Yellow
            $WebClient = New-Object System.Net.WebClient
            $WebClient.DownloadFile($DownloadUrl, $FilePath)
            Write-Host "Pobrano plik: $ServerJarName" -ForegroundColor Green
        } catch {
            Write-Error "Błąd podczas pobierania pliku serwera: $_"
            Write-Host "Sprawdź URL pobierania lub połączenie internetowe." -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "Plik $ServerJarName już istnieje, pomijanie pobierania." -ForegroundColor Yellow
    }
}

function Accept-EULA {
    Write-Host "Akceptacja umowy EULA..." -ForegroundColor Cyan
    $EulaPath = Join-Path $ServerFolder "eula.txt"
    if (-not (Test-Path $EulaPath)) {
        Out-File -FilePath $EulaPath -Encoding ASCII -InputObject $EulaAgreement
        Write-Host "Utworzono eula.txt i zaakceptowano warunki." -ForegroundColor Green
    } else {
        # Sprawdź czy EULA jest zaakceptowana
        $eulaContent = Get-Content $EulaPath
        if ($eulaContent -match "eula=true") {
            Write-Host "eula.txt już istnieje i jest zaakceptowana." -ForegroundColor Green
        } else {
            Write-Host "Aktualizacja eula.txt..." -ForegroundColor Yellow
            Out-File -FilePath $EulaPath -Encoding ASCII -InputObject $EulaAgreement
        }
    }
}

function Configure-Firewall {
    Write-Host "Konfiguracja zapory sieciowej (Port TCP 25565)..." -ForegroundColor Cyan
    # Upewnij się, że port 25565 jest otwarty dla ruchu TCP
    try {
        # Sprawdź czy reguła już istnieje
        $existingRule = Get-NetFirewallRule -DisplayName "Minecraft Server (TCP 25565)" -ErrorAction SilentlyContinue
        if ($existingRule) {
            Write-Host "Reguła zapory już istnieje." -ForegroundColor Yellow
        } else {
            New-NetFirewallRule -DisplayName "Minecraft Server (TCP 25565)" -Direction Inbound -LocalPort 25565 -Protocol TCP -Action Allow -Force | Out-Null
            Write-Host "Reguła zapory dodana pomyślnie." -ForegroundColor Green
        }
    } catch {
        Write-Error "Nie można dodać reguły zapory: $_"
        Write-Host "Upewnij się, że uruchomiłeś skrypt jako Administrator." -ForegroundColor Red
    }
}

function Start-MinecraftServer {
    Write-Host "Uruchamianie serwera Minecraft..." -ForegroundColor Cyan
    Write-Host "Aby zatrzymać serwer, użyj Ctrl+C lub wpisz 'stop' w konsoli serwera." -ForegroundColor Yellow
    
    # Sprawdź czy Java jest dostępna
    if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
        Write-Error "Java nie jest dostępna w PATH. Uruchom ponownie PowerShell lub komputer."
        exit 1
    }
    
    # Uruchomienie serwera za pomocą Javy
    $RamArgs = $RamAlloc.Split()
    $Arguments = $RamArgs + @('-jar', $ServerJarName, 'nogui')
    
    try {
        Write-Host "Uruchamianie polecenia: java $RamAlloc -jar $ServerJarName nogui" -ForegroundColor Cyan
        # Używamy Start-Process aby uruchomić serwer
        Start-Process -FilePath "java" -ArgumentList $Arguments -WorkingDirectory $ServerFolder -Wait
    } catch {
        Write-Error "Błąd podczas uruchamiania serwera: $_"
        exit 1
    }
}

# --- GŁÓWNA ORKIESTRACJA ---
function Invoke-MinecraftServerSetup {
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "  MINECRAFT SERVER AUTOMATION SCRIPT" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Sprawdź czy skrypt jest uruchomiony jako Administrator
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Warning "Ten skrypt wymaga uprawnień administratora!"
        Write-Host "Uruchom PowerShell jako Administrator i spróbuj ponownie." -ForegroundColor Red
        exit 1
    }
    
    Install-JavaRuntime
    Setup-ServerFolders
    Download-MinecraftServer
    Accept-EULA
    Configure-Firewall
    
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "  KONFIGURACJA ZAKOŃCZONA POMYŚLNIE" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    
    $response = Read-Host "Czy chcesz uruchomić serwer teraz? (T/N)"
    if ($response -eq "T" -or $response -eq "t") {
        Start-MinecraftServer
    } else {
        Write-Host "Aby uruchomić serwer później, użyj polecenia:" -ForegroundColor Cyan
        Write-Host "  cd $ServerFolder" -ForegroundColor Yellow
        Write-Host "  java $RamAlloc -jar $ServerJarName nogui" -ForegroundColor Yellow
    }
}

# Uruchomienie głównej funkcji
Invoke-MinecraftServerSetup

Write-Host ""
Write-Host "Skrypt zakończył działanie." -ForegroundColor Cyan
