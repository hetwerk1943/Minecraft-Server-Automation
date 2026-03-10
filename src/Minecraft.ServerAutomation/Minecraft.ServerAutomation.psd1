@{
    RootModule        = 'Minecraft.ServerAutomation.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author            = 'Dominik Opalka'
    CompanyName       = 'hetwerk1943'
    Copyright         = '(c) 2025 Dominik Opalka. All Rights Reserved.'
    Description       = 'PowerShell automation toolkit for Minecraft server management and monetization.'
    PowerShellVersion = '5.1'

    FunctionsToExport = @(
        'Invoke-ServerBackup'
        'Install-MinecraftServer'
        'Start-MinecraftServer'
        'Update-MinecraftServer'
        'Get-ServerHealthCheck'
    )

    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData = @{
        PSData = @{
            Tags       = @('Minecraft', 'Server', 'Automation', 'Backup', 'Monitoring')
            ProjectUri = 'https://github.com/hetwerk1943/Minecraft-Server-Automation'
        }
    }
}
