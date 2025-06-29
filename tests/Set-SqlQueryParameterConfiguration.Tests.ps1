BeforeAll {
    # Import the module for testing
    Import-Module -Name "$PSScriptRoot\..\output\module\synedgy.sqlQuery" -Force
}

Describe 'Set-SqlQueryParameterConfiguration' {
    It 'Should exist as a function' {
        (Get-Command Set-SqlQueryParameterConfiguration).CommandType | Should -Be 'Function'
    }
}
