@{
    # General settings
    IncludeRules = @(
        'PSAvoidUsingWriteHost',          # Prefer Write-Output or logging functions
        'PSAvoidUsingEmptyCatchBlock',    # Always handle exceptions
        'PSAvoidGlobalVars',              # Avoid global variables in automation scripts
        'PSAvoidUsingInvokeExpression',   # Prevent unsafe dynamic execution
        'PSUseDeclaredVarsMoreThanAssignments', # Flag unused variables
        'PSUseConsistentIndentation',     # Enforce indentation
        'PSUseConsistentWhitespace',      # Enforce whitespace rules
        'PSUseConsistentFormatting',      # General formatting consistency
        'PSUseCorrectCasing',             # Cmdlet names must use correct casing
        'PSUseShouldProcessForStateChangingFunctions', # Add ShouldProcess for destructive actions
        'PSUseSupportsShouldProcess',     # Ensure functions support -WhatIf/-Confirm
        'PSUseApprovedVerbs',             # Enforce approved verb usage in function names
        'PSUseOutputTypeCorrectly',       # Ensure functions declare output types
        'PSAvoidUsingPlainTextForPassword', # Security best practice
        'PSAvoidUsingConvertToSecureStringWithPlainText', # Security best practice
        'PSAvoidUsingUsernameAndPasswordParams' # Security best practice
    )

    ExcludeRules = @(
        'PSAvoidUsingWriteHost' # Optional: allow Write-Host if you rely on console output
    )

    Rules = @{
        PSUseConsistentIndentation = @{
            Enable = $true
            IndentationSize = 4
        }
        PSUseConsistentWhitespace = @{
            Enable = $true
        }
        PSUseCorrectCasing = @{
            Enable = $true
        }
    }
}
