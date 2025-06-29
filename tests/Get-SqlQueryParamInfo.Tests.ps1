BeforeAll {
    # Import the module for testing
    Import-Module -Name "$PSScriptRoot\..\output\module\synedgy.sqlQuery" -Force
}

Describe 'Get-SqlQueryParamInfo' {
    It 'Should exist as a function' {
        { Get-Command -Name Get-SqlQueryParamInfo -ErrorAction Stop } | Should -Not -Throw
    }
}
