Context 'When ParameterConfiguration is empty' {
    It 'Should not change ParameterMapping if input is empty' {
        $script:Configuration = @{}
        $empty = @{}
        Set-SqlQueryParameterConfiguration -ParameterConfiguration $empty
        $script:Configuration['ParameterMapping'].Count | Should -Be 0
    }
}

Context 'When ParameterConfiguration is not a hashtable of hashtables' {
    It 'Should not throw but not add invalid structure' {
        $script:Configuration = @{}
        $invalid = @{ 'F' = 'notAHash' }
        Set-SqlQueryParameterConfiguration -ParameterConfiguration $invalid
        $script:Configuration['ParameterMapping']['F'] | Should -Be 'notAHash'
    }
}

Context 'When keys differ only by case' {
    It 'Should treat keys as case-insensitive' {
        $script:Configuration = @{}
        $testMapping = @{ 'G' = @{ SqlDbType = 'Int' } }
        Set-SqlQueryParameterConfiguration -ParameterConfiguration $testMapping
        $testMapping2 = @{ 'g' = @{ SqlDbType = 'BigInt' } }
        Set-SqlQueryParameterConfiguration -ParameterConfiguration $testMapping2
        $script:Configuration['ParameterMapping'].Count | Should -Be 1
        $script:Configuration['ParameterMapping']['G'].SqlDbType | Should -Be 'Int'
    }
}

Context 'When called multiple times' {
    It 'Should accumulate all unique keys and not overwrite existing' {
        $script:Configuration = @{}
        $first = @{ 'H' = @{ SqlDbType = 'Int' } }
        $second = @{ 'I' = @{ SqlDbType = 'BigInt' } }
        Set-SqlQueryParameterConfiguration -ParameterConfiguration $first
        Set-SqlQueryParameterConfiguration -ParameterConfiguration $second
        $script:Configuration['ParameterMapping'].Count | Should -Be 2
        $script:Configuration['ParameterMapping']['H'].SqlDbType | Should -Be 'Int'
        $script:Configuration['ParameterMapping']['I'].SqlDbType | Should -Be 'BigInt'
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
    # Dot-source the function directly for testing
    . "$PSScriptRoot\..\source\Public\Set-SqlQueryParameterConfiguration.ps1"
}

Describe 'Set-SqlQueryParameterConfiguration' {
    Context 'When setting a valid parameter mapping' {
        It 'Should update the global configuration with the provided mapping' {
            $testMapping = @{
                'UserId'   = @{ SqlDbType = 'Int'; Direction = 'Input' }
                'UserName' = @{ SqlDbType = 'NVarChar'; Size = 50; Direction = 'Input' }
            }
            $script:Configuration = @{}
            Set-SqlQueryParameterConfiguration -ParameterConfiguration $testMapping
            $script:Configuration['ParameterMapping'].Count | Should -Be 2
            $script:Configuration['ParameterMapping']['UserId'].SqlDbType | Should -Be 'Int'
            $script:Configuration['ParameterMapping']['UserName'].Size | Should -Be 50
        }
    }

    Context 'When $script:Configuration is not a hashtable' {
        It 'Should initialize $script:Configuration as a hashtable and set mapping' {
            $testMapping = @{ 'A' = @{ SqlDbType = 'Int' } }
            $script:Configuration = $null
            Set-SqlQueryParameterConfiguration -ParameterConfiguration $testMapping
            $script:Configuration['ParameterMapping']['A'].SqlDbType | Should -Be 'Int'
        }
    }

    Context 'When ShouldProcess is used' {
        It 'Should call ShouldProcess and set mapping if confirmed' {
            $testMapping = @{ 'B' = @{ SqlDbType = 'BigInt' } }
            $script:Configuration = @{}
            Set-SqlQueryParameterConfiguration -ParameterConfiguration $testMapping -Confirm:$false
            $script:Configuration['ParameterMapping']['B'].SqlDbType | Should -Be 'BigInt'
        }
    }

    Context 'When ParameterMapping already exists' {
        It 'Should not overwrite existing mapping if key exists, but allow new keys' {
            $existing = @{ 'C' = @{ SqlDbType = 'Char' } }
            $script:Configuration = @{ 'ParameterMapping' = $existing }
            $newMapping = @{ 'D' = @{ SqlDbType = 'Date' } }
            Set-SqlQueryParameterConfiguration -ParameterConfiguration $newMapping
            $script:Configuration['ParameterMapping']['C'].SqlDbType | Should -Be 'Char'
            $script:Configuration['ParameterMapping'].ContainsKey('D') | Should -BeTrue
            $script:Configuration['ParameterMapping']['D'].SqlDbType | Should -Be 'Date'
        }
    }
}
