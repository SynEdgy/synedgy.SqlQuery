BeforeAll {
    # Dot-source the function directly for testing
    . "$PSScriptRoot\..\source\Public\Get-SqlQueryParamInfo.ps1"

    # Create a mock configuration for testing
    $script:Configuration = @{
        'ParameterMapping' = @{
            'UserId'   = @{
                'SqlDbType' = 'Int'
                'Direction' = 'Input'
            }
            'UserName' = @{
                'SqlDbType' = 'NVarChar'
                'Size'      = 50
                'Direction' = 'Input'
            }
            'OrderId'  = @{
                'SqlDbType'  = 'BigInt'
                'Direction'  = 'InputOutput'
                'IsNullable' = $true
            }
        }
    }
}

Describe 'Get-SqlQueryParamInfo' {
    BeforeAll {

    }
    Context 'When parameter exists in configuration' {
        # Define test cases for existing parameters
        $testCases = @(
            @{
                ParameterName     = 'UserId'
                ExpectedType      = 'Int'
                ExpectedDirection = 'Input'
                HasSize           = $false
                ExpectedSize      = $null
                IsNullable        = $false
            },
            @{
                ParameterName     = 'UserName'
                ExpectedType      = 'NVarChar'
                ExpectedDirection = 'Input'
                HasSize           = $true
                ExpectedSize      = 50
                IsNullable        = $false
            },
            @{
                ParameterName     = 'OrderId'
                ExpectedType      = 'BigInt'
                ExpectedDirection = 'InputOutput'
                HasSize           = $false
                ExpectedSize      = $null
                IsNullable        = $true
            }
        )

        It 'Should return the correct parameter information for <ParameterName>' -TestCases $testCases {
            param($ParameterName, $ExpectedType, $ExpectedDirection, $HasSize, $ExpectedSize, $IsNullable)

            $result = Get-SqlQueryParamInfo -ParameterName $ParameterName
            $result | Should -Not -BeNullOrEmpty
            $result.SqlDbType | Should -Be $ExpectedType
            $result.Direction | Should -Be $ExpectedDirection

            if ($HasSize)
            {
                $result.Size | Should -Be $ExpectedSize
            }

            if ($IsNullable)
            {
                $result.IsNullable | Should -BeTrue
            }
        }
    }

    Context 'When parameter does not exist in configuration' {
        $nonExistentTestCases = @(
            @{ ParameterName = 'NonExistentParam' },
            @{ ParameterName = 'AnotherNonExistentParam' },
            @{ ParameterName = 'MissingParameter123' }
        )

        It 'Should return null for a non-existent parameter: <ParameterName>' -TestCases $nonExistentTestCases {
            param($ParameterName)
            $result = Get-SqlQueryParamInfo -ParameterName $ParameterName
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'Parameter validation' {
        $validationTestCases = @(
            @{ Name = 'null'; Value = $null; ErrorPattern = 'ParameterArgumentValidationError,Get-SqlQueryParamInfo' },
            @{ Name = 'empty string'; Value = ''; ErrorPattern = 'ParameterArgumentValidationError,Get-SqlQueryParamInfo' },
            @{ Name = 'whitespace only'; Value = '   '; ErrorPattern = 'ParameterArgumentValidationError,Get-SqlQueryParamInfo' }
        )

        It 'Should throw when parameter name is <Name>' -TestCases $validationTestCases {
            param($Name, $Value, $ErrorPattern)
            { Get-SqlQueryParamInfo -ParameterName $Value } | Should -Throw -ErrorId $ErrorPattern
        }

        It 'Should handle case sensitivity properly' {
            # First check that exact case matches work
            $result = Get-SqlQueryParamInfo -ParameterName 'UserId'
            $result | Should -Not -BeNullOrEmpty
            $result.SqlDbType | Should -Be 'Int'

            # Now check case insensitivity with different case
            $result = Get-SqlQueryParamInfo -ParameterName 'USERID'
            $result | Should -Not -BeNullOrEmpty
            $result.SqlDbType | Should -Be 'Int'

            $result = Get-SqlQueryParamInfo -ParameterName 'userid'
            $result | Should -Not -BeNullOrEmpty
            $result.SqlDbType | Should -Be 'Int'
        }
    }

    Context 'When accepting pipeline input' {
        $pipelineTestCases = @(
            @{
                ParameterName     = 'UserId'
                ExpectedType      = 'Int'
                ExpectedDirection = 'Input'
                InputType         = 'PSCustomObject'
                Description       = 'Basic pipeline input as PSCustomObject'
            },
            @{
                ParameterName     = 'UserName'
                ExpectedType      = 'NVarChar'
                ExpectedDirection = 'Input'
                InputType         = 'PSObject with calculated property'
                Description       = 'Pipeline input with calculated property'
            },
            @{
                ParameterName     = 'OrderId'
                ExpectedType      = 'BigInt'
                ExpectedDirection = 'InputOutput'
                InputType         = 'Hashtable'
                Description       = 'Pipeline input as Hashtable'
            }
        )

        BeforeAll {
            # Workaround for calculated property pipeline test
            Set-Variable -Name ParameterName -Scope Global -Value $null
        }
        It 'Should accept parameter name from pipeline by property name: <ParameterName> (<InputType>)' -TestCases $pipelineTestCases {
            param($ParameterName, $ExpectedType, $ExpectedDirection, $InputType)

            $inputObject = $null

            switch ($InputType)
            {
                'PSCustomObject'
                {
                    $inputObject = [PSCustomObject]@{
                        ParameterName = $ParameterName
                    }
                }
                'PSObject with calculated property'
                {
                    # Use a closure to capture the current value
                    $pn = $ParameterName
                    $inputObject = New-Object PSObject -Property @{
                        Name = 'Some name'
                    }
                    Add-Member -InputObject $inputObject -MemberType ScriptProperty -Name 'ParameterName' -Value { $pn }
                }
                'Hashtable'
                {
                    $inputObject = @{
                        ParameterName = $ParameterName
                        OtherProperty = 'Other value'
                    }
                }
            }

            $result = $inputObject | Get-SqlQueryParamInfo
            $result | Should -Not -BeNullOrEmpty
            $result.SqlDbType | Should -Be $ExpectedType
            $result.Direction | Should -Be $ExpectedDirection
        }
    }
}
