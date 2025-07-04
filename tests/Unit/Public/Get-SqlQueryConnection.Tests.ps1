BeforeAll {
    # Import the compiled module for testing to ensure code coverage
    $ModulePath = "$PSScriptRoot\..\..\..\output\module\synedgy.sqlQuery"
    Import-Module $ModulePath -Force
}

Describe 'Get-SqlQueryConnection' {
    Context 'When providing a valid connection string' {
        It 'Should return a SqlConnection object' {
            $connStr = 'Server=localhost;Database=master;Integrated Security=True;'
            $result = Get-SqlQueryConnection -ConnectionString $connStr
            $result | Should -BeOfType 'System.Data.SqlClient.SqlConnection'
        }

        It 'Should set the ConnectionString property correctly' {
            $connStr = 'Server=localhost;Database=master;Integrated Security=True;'
            $result = Get-SqlQueryConnection -ConnectionString $connStr
            $result.ConnectionString | Should -Be $connStr
        }

        It 'Should create a connection in Closed state' {
            $connStr = 'Server=localhost;Database=master;Integrated Security=True;'
            $result = Get-SqlQueryConnection -ConnectionString $connStr
            $result.State | Should -Be 'Closed'
        }
    }

    Context 'When providing invalid parameters' {
        It 'Should throw when ConnectionString is null' {
            { Get-SqlQueryConnection -ConnectionString $null } | Should -Throw
        }

        It 'Should throw when ConnectionString is empty' {
            { Get-SqlQueryConnection -ConnectionString '' } | Should -Throw
        }
    }

    Context 'When using the function with a real connection' {
        It 'Should be able to open and close the connection' -Skip {
            # Note: This test is skipped by default as it requires a real SQL Server
            $connStr = 'Server=localhost;Database=master;Integrated Security=True;'
            $conn = Get-SqlQueryConnection -ConnectionString $connStr
            { $conn.Open() } | Should -Not -Throw
            $conn.State | Should -Be 'Open'
            $conn.Close()
            $conn.State | Should -Be 'Closed'
        }
    }
}
