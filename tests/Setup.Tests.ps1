#Requires -Version 5.1
<#
.SYNOPSIS
    Pester tests for Install-MinecraftServer (file generation).
#>

BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '../src/Minecraft.ServerAutomation/Minecraft.ServerAutomation.psd1'
    Import-Module $modulePath -Force
}

Describe 'Install-MinecraftServer' {

    BeforeEach {
        $script:tempRoot  = Join-Path ([System.IO.Path]::GetTempPath()) "McSetupTest_$([System.Guid]::NewGuid().ToString('N'))"
        $script:serverDir = Join-Path $script:tempRoot 'server'
    }

    AfterEach {
        if (Test-Path $script:tempRoot) {
            Remove-Item $script:tempRoot -Recurse -Force
        }
    }

    Context 'File generation' {
        It 'Creates the server directory' {
            Install-MinecraftServer -ServerPath $script:serverDir
            Test-Path $script:serverDir | Should -Be $true
        }

        It 'Creates eula.txt with eula=true' {
            Install-MinecraftServer -ServerPath $script:serverDir
            $eulaPath = Join-Path $script:serverDir 'eula.txt'
            Test-Path $eulaPath | Should -Be $true
            Get-Content $eulaPath | Should -Contain 'eula=true'
        }

        It 'Creates server.properties' {
            Install-MinecraftServer -ServerPath $script:serverDir
            $propsPath = Join-Path $script:serverDir 'server.properties'
            Test-Path $propsPath | Should -Be $true
        }

        It 'Writes the correct port to server.properties' {
            Install-MinecraftServer -ServerPath $script:serverDir -ServerPort 19132
            $propsPath = Join-Path $script:serverDir 'server.properties'
            $content = Get-Content $propsPath -Raw
            $content | Should -Match 'server-port=19132'
        }

        It 'Creates start.bat' {
            Install-MinecraftServer -ServerPath $script:serverDir
            Test-Path (Join-Path $script:serverDir 'start.bat') | Should -Be $true
        }

        It 'Creates start.sh' {
            Install-MinecraftServer -ServerPath $script:serverDir
            Test-Path (Join-Path $script:serverDir 'start.sh') | Should -Be $true
        }

        It 'Embeds MaxMemory in start.bat' {
            Install-MinecraftServer -ServerPath $script:serverDir -MaxMemory 4096
            $bat = Get-Content (Join-Path $script:serverDir 'start.bat') -Raw
            $bat | Should -Match '\-Xmx4096M'
        }
    }

    Context 'Idempotency' {
        It 'Does not throw when run twice on the same directory' {
            Install-MinecraftServer -ServerPath $script:serverDir
            { Install-MinecraftServer -ServerPath $script:serverDir } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Throws on root path' {
            { Install-MinecraftServer -ServerPath '/' } | Should -Throw
        }

        It 'Throws on empty path' {
            { Install-MinecraftServer -ServerPath '' } | Should -Throw
        }
    }

    Context 'Structured log output' {
        It 'Creates a log file when LogPath is specified' {
            $logDir = Join-Path $script:tempRoot 'logs'
            Install-MinecraftServer -ServerPath $script:serverDir -LogPath $logDir
            $logs = Get-ChildItem $logDir -Filter '*.log' -ErrorAction SilentlyContinue
            $logs.Count | Should -BeGreaterThan 0
        }
    }
}
