@{
    # PSScriptAnalyzer rule configuration for Minecraft-Server-Automation
    # https://github.com/PowerShell/PSScriptAnalyzer

    ExcludeRules = @(
        # Write-Host is intentional in console automation scripts
        'PSAvoidUsingWriteHost'
        # ShouldProcess would add significant complexity to simple automation scripts
        'PSUseShouldProcessForStateChangingFunctions'
        # Invoke-Expression is intentionally used in controlled automation scenarios
        'PSAvoidUsingInvokeExpression'
    )

    Rules = @{
        PSUseConsistentIndentation = @{
            Enable          = $true
            IndentationSize = 4
            PipelineIndentation = 'IncreaseIndentationAfterEveryPipeline'
            Kind            = 'space'
        }

        PSUseConsistentWhitespace = @{
            Enable                          = $true
            CheckInnerBrace                 = $true
            CheckOpenBrace                  = $true
            CheckOpenParen                  = $true
            CheckOperator                   = $false
            CheckPipe                       = $true
            CheckPipeForRedundantWhitespace = $false
            CheckSeparator                  = $true
            CheckParameter                  = $false
        }

        PSAlignAssignmentStatement = @{
            Enable         = $false
        }

        PSUseCorrectCasing = @{
            Enable = $true
        }
    }
}
