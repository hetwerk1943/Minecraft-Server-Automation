#Requires -Version 5.1
<#
.SYNOPSIS
    Pester tests for Invoke-ServerBackup (backup creation and retention).
#>

BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '../src/Minecraft.ServerAutomation/Minecraft.ServerAutomation.psd1'
    Import-Module $modulePath -Force
}

Describe 'Invoke-ServerBackup' {

    BeforeEach {
        # Create a clean temp server directory with a dummy file
        $script:tempRoot   = Join-Path ([System.IO.Path]::GetTempPath()) "McBackupTest_$([System.Guid]::NewGuid().ToString('N'))"
        $script:serverDir  = Join-Path $script:tempRoot 'server'
        $script:backupDir  = Join-Path $script:tempRoot 'backups'

        $null = New-Item -ItemType Directory -Path $script:serverDir  -Force
        $null = New-Item -ItemType Directory -Path $script:backupDir  -Force

        # Place a dummy file in server dir so archive is non-empty
        'hello world' | Out-File -FilePath (Join-Path $script:serverDir 'test.txt') -Encoding ASCII
    }

    AfterEach {
        if (Test-Path $script:tempRoot) {
            Remove-Item $script:tempRoot -Recurse -Force
        }
    }

    Context 'Successful backup creation' {
        It 'Creates a .zip archive in the backup directory' {
            Invoke-ServerBackup -ServerPath $script:serverDir -BackupPath $script:backupDir -MaxBackups 5
            $zips = Get-ChildItem $script:backupDir -Filter 'Backup_*.zip'
            $zips.Count | Should -Be 1
        }

        It 'The created archive is a valid zip file (non-zero size)' {
            Invoke-ServerBackup -ServerPath $script:serverDir -BackupPath $script:backupDir -MaxBackups 5
            $zip = Get-ChildItem $script:backupDir -Filter 'Backup_*.zip' | Select-Object -First 1
            $zip.Length | Should -BeGreaterThan 0
        }

        It 'Archive name matches Backup_<timestamp>.zip pattern' {
            Invoke-ServerBackup -ServerPath $script:serverDir -BackupPath $script:backupDir -MaxBackups 5
            $zip = Get-ChildItem $script:backupDir -Filter 'Backup_*.zip' | Select-Object -First 1
            $zip.Name | Should -Match '^Backup_\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}\.zip$'
        }
    }

    Context 'Retention enforcement' {
        It 'Removes oldest backups when count exceeds MaxBackups' {
            # Create 5 pre-existing backup stubs with spaced timestamps
            for ($i = 1; $i -le 5; $i++) {
                $name = "Backup_2024-01-0${i}_00-00-00.zip"
                $path = Join-Path $script:backupDir $name
                'old' | Out-File $path -Encoding ASCII
                # Stagger creation times so Sort-Object gives consistent order
                $file = Get-Item $path
                $file.CreationTime = [datetime]::Parse("2024-01-0${i} 00:00:00")
            }

            # Run backup with MaxBackups = 3; should leave only 3 newest
            Invoke-ServerBackup -ServerPath $script:serverDir -BackupPath $script:backupDir -MaxBackups 3
            $remaining = Get-ChildItem $script:backupDir -Filter 'Backup_*.zip'
            $remaining.Count | Should -Be 3
        }
    }

    Context 'Error handling' {
        It 'Throws when server directory does not exist' {
            $missing = Join-Path $script:tempRoot 'nonexistent'
            { Invoke-ServerBackup -ServerPath $missing -BackupPath $script:backupDir } |
                Should -Throw
        }

        It 'Throws on root path for ServerPath' {
            { Invoke-ServerBackup -ServerPath '/' -BackupPath $script:backupDir } |
                Should -Throw
        }
    }

    Context 'Structured log output' {
        It 'Creates a log file in LogPath when specified' {
            $logDir = Join-Path $script:tempRoot 'logs'
            Invoke-ServerBackup -ServerPath $script:serverDir -BackupPath $script:backupDir `
                -MaxBackups 5 -LogPath $logDir
            $logs = Get-ChildItem $logDir -Filter '*.log' -ErrorAction SilentlyContinue
            $logs.Count | Should -BeGreaterThan 0
        }
    }
}
