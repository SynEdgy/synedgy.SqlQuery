BeforeAll {
    # Import the module for testing
    Import-Module -Name "$PSScriptRoot\..\output\module\synedgy.sqlQuery" -Force
}

Describe 'Invoke-SqlQuery' {
    It 'Should exist as a function' {
        (Get-Command Invoke-SqlQuery).CommandType | Should -Be 'Function'
    }
}
