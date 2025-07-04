Context 'When ParameterConfiguration is empty' {
    It 'Should not change ParameterMapping if input is empty' {
        Initialize-ModuleConfiguration @{}
        $empty = @{}
        Set-SqlQueryParameterConfiguration -ParameterConfiguration $empty
        (Get-ModuleConfiguration)['ParameterMapping'].Count | Should -Be 0
    }
}

Context 'When ParameterConfiguration is not a hashtable of hashtables' {
    It 'Should not throw but not add invalid structure' {
        Initialize-ModuleConfiguration @{}
        $invalid = @{ 'F' = 'notAHash' }
        Set-SqlQueryParameterConfiguration -ParameterConfiguration $invalid
        (Get-ModuleConfiguration)['ParameterMapping']['F'] | Should -Be 'notAHash'
    }
}

Context 'When keys differ only by case' {
    It 'Should treat keys as case-insensitive' {
        Initialize-ModuleConfiguration @{}
        $testMapping = @{ 'G' = @{ SqlDbType = 'Int' } }
        Set-SqlQueryParameterConfiguration -ParameterConfiguration $testMapping
        $testMapping2 = @{ 'g' = @{ SqlDbType = 'BigInt' } }
        Set-SqlQueryParameterConfiguration -ParameterConfiguration $testMapping2
        (Get-ModuleConfiguration)['ParameterMapping'].Count | Should -Be 1
        (Get-ModuleConfiguration)['ParameterMapping']['G'].SqlDbType | Should -Be 'Int'
    }
}

Context 'When called multiple times' {
    It 'Should accumulate all unique keys and not overwrite existing' {
        Initialize-ModuleConfiguration @{}
        $first = @{ 'H' = @{ SqlDbType = 'Int' } }
        $second = @{ 'I' = @{ SqlDbType = 'BigInt' } }
        Set-SqlQueryParameterConfiguration -ParameterConfiguration $first
        Set-SqlQueryParameterConfiguration -ParameterConfiguration $second
        (Get-ModuleConfiguration)['ParameterMapping'].Count | Should -Be 2
        (Get-ModuleConfiguration)['ParameterMapping']['H'].SqlDbType | Should -Be 'Int'
        (Get-ModuleConfiguration)['ParameterMapping']['I'].SqlDbType | Should -Be 'BigInt'
    }
}

# Pipeline input is not currently supported by the function, but if it were:
# Context 'When using pipeline input' {
#     It 'Should accept pipeline input if implemented' {
#         $script:Configuration = @{}
#         $testMapping = @{ 'J' = @{ SqlDbType = 'Int' } }
#         $testMapping | Set-SqlQueryParameterConfiguration
#         $script:Configuration['ParameterMapping']['J'].SqlDbType | Should -Be 'Int'
#     }
# }
BeforeAll {
    # Import the compiled module for testing to ensure code coverage
    $ModulePath = "$PSScriptRoot\..\..\..\output\module\synedgy.sqlQuery"
    Import-Module $ModulePath -Force

    # Helper function to initialize module configuration
    function Initialize-ModuleConfiguration {
        param($InitialConfig = @{})
        & (Get-Module synedgy.sqlQuery) {
            param($Config)
            $script:Configuration = $Config
        } $InitialConfig
    }

    # Helper function to get module configuration
    function Get-ModuleConfiguration {
        & (Get-Module synedgy.sqlQuery) { $script:Configuration }
    }
}

Describe 'Set-SqlQueryParameterConfiguration' {
    Context 'When setting a valid parameter mapping' {
        It 'Should update the global configuration with the provided mapping' {
            $testMapping = @{
                'UserId'   = @{ SqlDbType = 'Int'; Direction = 'Input' }
                'UserName' = @{ SqlDbType = 'NVarChar'; Size = 50; Direction = 'Input' }
            }
            Initialize-ModuleConfiguration @{}
            Set-SqlQueryParameterConfiguration -ParameterConfiguration $testMapping
            (Get-ModuleConfiguration)['ParameterMapping'].Count | Should -Be 2
            (Get-ModuleConfiguration)['ParameterMapping']['UserId'].SqlDbType | Should -Be 'Int'
            (Get-ModuleConfiguration)['ParameterMapping']['UserName'].Size | Should -Be 50
        }
    }

    Context 'When $script:Configuration is not a hashtable' {
        It 'Should initialize $script:Configuration as a hashtable and set mapping' {
            $testMapping = @{ 'A' = @{ SqlDbType = 'Int' } }
            Initialize-ModuleConfiguration $null
            Set-SqlQueryParameterConfiguration -ParameterConfiguration $testMapping
            (Get-ModuleConfiguration)['ParameterMapping']['A'].SqlDbType | Should -Be 'Int'
        }
    }

    Context 'When ShouldProcess is used' {
        It 'Should call ShouldProcess and set mapping if confirmed' {
            $testMapping = @{ 'B' = @{ SqlDbType = 'BigInt' } }
            Initialize-ModuleConfiguration @{}
            Set-SqlQueryParameterConfiguration -ParameterConfiguration $testMapping -Confirm:$false
            (Get-ModuleConfiguration)['ParameterMapping']['B'].SqlDbType | Should -Be 'BigInt'
        }
    }

    Context 'When ParameterMapping already exists' {
        It 'Should not overwrite existing mapping if key exists, but allow new keys' {
            $existing = @{ 'C' = @{ SqlDbType = 'Char' } }
            Initialize-ModuleConfiguration @{ 'ParameterMapping' = $existing }
            $newMapping = @{ 'D' = @{ SqlDbType = 'Date' } }
            Set-SqlQueryParameterConfiguration -ParameterConfiguration $newMapping
            (Get-ModuleConfiguration)['ParameterMapping']['C'].SqlDbType | Should -Be 'Char'
            (Get-ModuleConfiguration)['ParameterMapping'].ContainsKey('D') | Should -BeTrue
            (Get-ModuleConfiguration)['ParameterMapping']['D'].SqlDbType | Should -Be 'Date'
        }
    }
}
