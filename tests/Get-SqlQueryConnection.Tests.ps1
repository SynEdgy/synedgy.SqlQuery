BeforeAll {
    # Import the module for testing
    Import-Module -Name "$PSScriptRoot\..\output\module\synedgy.sqlQuery" -Force
}

Describe 'Get-SqlQueryConnection' {
    It 'Should return a SqlConnection object' {
        $connStr = 'Server=localhost;Database=master;Integrated Security=True;'
        $result = Get-SqlQueryConnection -ConnectionString $connStr
        $result | Should -BeOfType 'System.Data.SqlClient.SqlConnection'
    }
}
