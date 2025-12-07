# 🚀 Przewodnik Szybki Start

## Dla Początkujących - Krok po Kroku

### 1. Przygotowanie

**Sprawdź wymagania:**
- ✅ Windows 10/11 lub Windows Server
- ✅ Połączenie z internetem
- ✅ Co najmniej 4GB wolnej pamięci RAM
- ✅ Co najmniej 2GB wolnego miejsca na dysku

### 2. Pobranie Projektu

**Opcja A: Używając Git**
```powershell
git clone https://github.com/hetwerk1943/Minecraft-Server-Automation.git
cd Minecraft-Server-Automation
```

**Opcja B: Pobieranie ZIP**
1. Przejdź do: https://github.com/hetwerk1943/Minecraft-Server-Automation
2. Kliknij zielony przycisk "Code"
3. Wybierz "Download ZIP"
4. Rozpakuj archiwum

### 3. Uruchomienie PowerShell jako Administrator

**Sposób 1:**
1. Naciśnij `Windows + X`
2. Wybierz "Windows PowerShell (Admin)" lub "Terminal (Admin)"

**Sposób 2:**
1. Wyszukaj "PowerShell" w menu Start
2. Kliknij prawym przyciskiem myszy
3. Wybierz "Uruchom jako administrator"

### 4. Przejdź do Folderu Projektu

```powershell
cd ścieżka\do\Minecraft-Server-Automation
```

Przykład:
```powershell
cd C:\Users\TwojeImie\Downloads\Minecraft-Server-Automation
```

### 5. Pozwól na Wykonywanie Skryptów

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Potwierdź naciskając `T` (Tak) lub `Y` (Yes)

### 6. Uruchom Instalator

```powershell
.\MinecraftServerSetup.ps1
```

### 7. Co się Wydarzy?

Skrypt automatycznie:
1. ✅ Sprawdzi czy Java jest zainstalowana
2. ✅ Zainstaluje Javę jeśli potrzeba (przez Chocolatey)
3. ✅ Utworzy folder serwera w `C:\MinecraftServer`
4. ✅ Pobierze serwer Minecraft
5. ✅ Zaakceptuje EULA
6. ✅ Skonfiguruje zaporę Windows
7. ✅ Zapyta czy chcesz uruchomić serwer

### 8. Po Instalacji

**Jeśli wybrałeś uruchomienie serwera:**
- Serwer uruchomi się automatycznie
- Poczekaj aż zobaczysz "Done!" w konsoli
- Serwer jest gotowy!

**Jeśli NIE uruchomiłeś serwera:**
```powershell
.\StartServer.ps1
```

### 9. Jak Połączyć się z Serwerem?

**Grając lokalnie (na tym samym komputerze):**
1. Uruchom Minecraft
2. Multiplayer → Direct Connect
3. Wpisz: `localhost` lub `localhost:25565`
4. Połącz

**Grając przez internet (przyjaciele):**
1. Znajdź swoje IP publiczne: https://whatismyipaddress.com/
2. Podaj znajomym swoje IP
3. Oni wpisują: `TWOJE_IP:25565`

⚠️ **UWAGA:** Może być potrzebne przekierowanie portu w routerze!

### 10. Podstawowe Komendy

**W konsoli serwera:**
```
stop                    - Zatrzymuje serwer
op TwojaNick           - Daje ci uprawnienia admina
whitelist add Nick     - Dodaje gracza do whitelisty
ban Nick               - Banuje gracza
list                   - Pokazuje listę graczy online
```

## 🎮 Codzienne Użytkowanie

### Uruchomienie Serwera
```powershell
.\StartServer.ps1
```

### Zatrzymanie Serwera
W konsoli serwera wpisz: `stop`

### Backup Serwera
```powershell
.\BackupServer.ps1
```

## ❓ Najczęstsze Problemy

### "Nie można uruchomić skryptu"
**Rozwiązanie:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "Odmowa dostępu" / "Access Denied"
**Rozwiązanie:** Uruchom PowerShell jako Administrator

### Serwer nie startuje
**Sprawdź:**
1. Czy Java jest zainstalowana: `java -version`
2. Czy port 25565 nie jest zajęty
3. Czy masz wystarczająco RAM

### Nie mogę się połączyć
**Sprawdź:**
1. Czy serwer jest uruchomiony?
2. Czy używasz właściwego IP?
3. Czy zapora Windows pozwala na połączenia?
4. Czy port jest przekierowany w routerze (dla graczy z internetu)?

## 📞 Pomoc

Jeśli napotkasz problemy:
1. Sprawdź pełną dokumentację w `README.md`
2. Zajrzyj do sekcji "Rozwiązywanie Problemów"
3. Otwórz Issue na GitHubie

## 🎉 Gotowe!

Twój serwer Minecraft jest gotowy do użycia!

Miłej zabawy! 🎮⛏️
