@{
    # Only block parse errors and errors
    Severity = @('Error','ParseError')

    # Rules to include/exclude
    IncludeRules = @(
        'PSUseConsistentWhitespace',
        'PSUseConsistentIndentation',
        'PSUseCorrectOperators',
        'PSAvoidTrailingWhitespace',
        'PSAvoidAssignmentToAutomaticVariable'
    )

    ExcludeRules = @(
        'PSAvoidUsingWriteHost',
        'PSUseApprovedVerbs',
        'PSAvoidUsingEmptyCatchBlock',
        'PSAvoidUsingCmdletAliases'
    )
}
