# Changelog

All notable changes to this project will be documented in this file.

## [1.1.0] - 2025-12-07

### Added
- **RestartServer.ps1**: Server restart utility
  - Safe server restart with player warning
  - Automatic process detection and termination
  - Configurable wait time between stop and start
  - Graceful handling of server not running

### Changed
- **Default RAM allocation increased from 2GB to 4GB**
  - Updated MinecraftServerSetup.ps1 default: `-Xmx4G -Xms2G`
  - Updated StartServer.ps1 default: `-Xmx4G -Xms2G`
  - Updated RestartServer.ps1 default: `-Xmx4G -Xms2G`
  - Updated config.json: `ramAllocation: "-Xmx4G -Xms2G"`
- Updated README.md with RestartServer.ps1 documentation
- Updated daily management section with restart command

## [1.0.0] - 2025-12-07

### Added
- **MinecraftServerSetup.ps1**: Complete server installation and setup script
  - Automatic Java installation via Chocolatey
  - Server folder structure creation
  - Minecraft server JAR download
  - EULA acceptance
  - Windows Firewall configuration
  - Interactive server launch option
  
- **StartServer.ps1**: Quick server startup utility
  - Configurable server folder path
  - Configurable RAM allocation
  - Pre-flight checks for Java and server files
  
- **BackupServer.ps1**: Automated backup solution
  - Compression to ZIP format
  - Selective file backup (worlds, configs, player data)
  - Optional log inclusion
  - Timestamp-based naming
  - Backup count warnings
  
- **UpdateServer.ps1**: Server version update utility
  - Automatic backup before update
  - Old JAR preservation
  - Automatic rollback on failure
  - Download progress feedback
  
- **config.json**: Centralized configuration file
  - Minecraft version and download URL
  - Performance settings
  - Backup preferences
  - Network configuration
  
- **README.md**: Comprehensive documentation
  - Requirements and prerequisites
  - Quick start guide
  - Detailed script documentation
  - Troubleshooting section
  - Server administration commands
  
- **QUICK_START.md**: Beginner-friendly guide
  - Step-by-step installation
  - Visual instructions
  - Common problems and solutions
  - Daily usage guide
  
- **.gitignore**: Repository hygiene
  - Excludes server files and logs
  - Excludes backup archives
  - Excludes editor and system files

### Fixed
- Removed duplicate function definitions from original code
- Fixed incomplete function structures
- Fixed missing closing braces
- Corrected Minecraft server download URL
- Fixed Start-Process argument handling for proper Java execution
- Added comprehensive error handling throughout all scripts

### Security
- All scripts validated for syntax errors
- No hardcoded credentials
- Safe use of Invoke-Expression (only for verified Chocolatey install)
- Proper error handling to prevent information leakage
- Administrator privilege checks where required

### Changed
- Extracted PowerShell code from agent file to proper script files
- Reorganized code into modular, reusable scripts
- Improved user feedback with colored console output
- Enhanced error messages with actionable guidance

## [0.1.0] - 2025-12-04

### Added
- Initial project structure
- Basic PowerShell script in agent file (incomplete)

### Issues
- Code had duplicate functions
- Incomplete function implementations
- Missing error handling
- No proper documentation
- Scripts were in agent file instead of proper .ps1 files
