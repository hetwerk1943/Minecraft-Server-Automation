#Requires -Version 5.1
<#
.SYNOPSIS
    Pester tests for the Assert-PathSafe private helper.
#>

BeforeAll {
    # Import the module so private functions are available via the psm1
    $modulePath = Join-Path $PSScriptRoot '../src/Minecraft.ServerAutomation/Minecraft.ServerAutomation.psd1'
    Import-Module $modulePath -Force

    # Dot-source the private helper directly so we can call it in tests
    $privatePath = Join-Path $PSScriptRoot '../src/Minecraft.ServerAutomation/Private/Assert-PathSafe.ps1'
    . $privatePath
}

Describe 'Assert-PathSafe' {

    Context 'Valid paths' {
        It 'Accepts a normal subdirectory path' {
            { Assert-PathSafe -Path '/tmp/minecraft-server' } | Should -Not -Throw
        }

        It 'Accepts a Windows-style subdirectory path' {
            { Assert-PathSafe -Path 'C:\Users\test\MinecraftServer' } | Should -Not -Throw
        }

        It 'Accepts a relative path with subdirectory' {
            { Assert-PathSafe -Path '.\MinecraftServer' } | Should -Not -Throw
        }

        It 'Accepts a deeply nested path' {
            { Assert-PathSafe -Path '/opt/games/servers/minecraft/world' } | Should -Not -Throw
        }
    }

    Context 'Invalid paths - empty/null' {
        It 'Throws on empty string' {
            { Assert-PathSafe -Path '' } | Should -Throw
        }

        It 'Throws on whitespace-only string' {
            { Assert-PathSafe -Path '   ' } | Should -Throw
        }
    }

    Context 'Invalid paths - root volumes' {
        It 'Throws on Unix root /' {
            { Assert-PathSafe -Path '/' } | Should -Throw
        }

        It 'Throws on Windows drive root C:\' {
            { Assert-PathSafe -Path 'C:\' } | Should -Throw
        }

        It 'Throws on Windows drive root C: without trailing slash' {
            { Assert-PathSafe -Path 'C:' } | Should -Throw
        }

        It 'Throws on UNC root path' {
            { Assert-PathSafe -Path '\\server\share' } | Should -Throw
        }
    }

    Context 'ParameterName in error messages' {
        It 'Includes the parameter name in the error message' {
            $err = $null
            try {
                Assert-PathSafe -Path '' -ParameterName 'BackupPath'
            }
            catch {
                $err = $_
            }
            $err | Should -Not -BeNullOrEmpty
            $err.Exception.Message | Should -BeLike '*BackupPath*'
        }
    }
}
