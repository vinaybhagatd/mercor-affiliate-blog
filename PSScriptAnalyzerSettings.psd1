@{
    Severity     = @('Error', 'Warning')
    IncludeRules = @(
        'PSAvoidAssignmentToAutomaticVariable',
        'PSAvoidUsingEmptyCatchBlock',
        'PSAvoidGlobalVars',
        'PSAvoidUsingConvertToSecureStringWithPlainText'
    )
    ExcludeRules = @(
        'PSAvoidUsingWriteHost',
        'PSUseDeclaredVarsMoreThanAssignments',
        'PSUseApprovedVerbs'
    )
}
