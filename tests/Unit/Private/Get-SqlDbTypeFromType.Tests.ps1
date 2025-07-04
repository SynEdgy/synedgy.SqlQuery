using namespace System.Data
using namespace System.Xml

BeforeAll {
    # Import the compiled module for testing to ensure code coverage
    $ModulePath = "$PSScriptRoot\..\..\..\output\module\synedgy.sqlQuery"
    Import-Module $ModulePath -Force

    # Create a wrapper function that calls the private function from the module scope
    function Get-SqlDbTypeFromType {
        param($Type, $Value)
        & (Get-Module synedgy.sqlQuery) {
            param($Type, $Value)
            Get-SqlDbTypeFromType @PSBoundParameters
        } @PSBoundParameters
    }
}

Describe 'Get-SqlDbTypeFromType' {
    BeforeAll {
        # Initialize some variables for testing
        $intValue = 42
        $stringValue = 'test'
        $boolValue = $true
        $nullValue = $null
        $dateTimeValue = [DateTime]::Now
        $guidValue = [Guid]::NewGuid()
        $byteValue = [byte]5
        $byteArrayValue = [byte[]]@(1, 2, 3)
        $charValue = [char]'A'
        $charArrayValue = [char[]]@('A', 'B', 'C')
        $dateTimeOffsetValue = [DateTimeOffset]::Now
        $decimalValue = [decimal]10.5
        $doubleValue = [double]12.34
        $int16Value = [Int16]16
        $int64Value = [Int64]64
        $sbyteValue = [sbyte]8
        $singleValue = [single]3.14
        $timeSpanValue = [TimeSpan]::FromHours(1)
        $uint16Value = [uint16]16
        $uint32Value = [uint32]32
        $uint64Value = [uint64]64
        $xmlDocValue = New-Object System.Xml.XmlDocument
        $sqlDbTypeValue = [SqlDbType]::Image
    }

    Context 'Basic Function Tests' {
        It 'Function should exist' {
            { Get-Command -Name Get-SqlDbTypeFromType -ErrorAction Stop } | Should -Not -Throw
        }
        It 'Should handle Value parameter - Int' {
            # Suppress verbose and debug output
            $VerbosePreference = 'SilentlyContinue'
            $DebugPreference = 'SilentlyContinue'

            $result = Get-SqlDbTypeFromType -Value $intValue
            $result | Should -Be ([SqlDbType]::Int)
        }

        It 'Should handle Type parameter - Int' {
            # Suppress verbose and debug output
            $VerbosePreference = 'SilentlyContinue'
            $DebugPreference = 'SilentlyContinue'

            $result = Get-SqlDbTypeFromType -Type ([int])
            $result | Should -Be ([SqlDbType]::Int)
        }
    }

    Context 'Value Parameter Tests' {
        BeforeAll {
            # Suppress verbose and debug output
            $VerbosePreference = 'SilentlyContinue'
            $DebugPreference = 'SilentlyContinue'
        }
        It 'Should handle null value parameter' {
            $result = Get-SqlDbTypeFromType -Value $null
            $result | Should -Be ([SqlDbType]::DbNull)
        }

        It 'Should handle string value parameter' {
            $result = Get-SqlDbTypeFromType -Value $stringValue
            $result | Should -Be ([SqlDbType]::NVarChar)
        }

        It 'Should handle boolean value parameter' {
            $result = Get-SqlDbTypeFromType -Value $boolValue
            $result | Should -Be ([SqlDbType]::Bit)
        }

        It 'Should handle DateTime value parameter' {
            $result = Get-SqlDbTypeFromType -Value $dateTimeValue
            $result | Should -Be ([SqlDbType]::DateTime)
        }

        It 'Should handle Guid value parameter' {
            $result = Get-SqlDbTypeFromType -Value $guidValue
            $result | Should -Be ([SqlDbType]::UniqueIdentifier)
        }

        It 'Should handle byte array value parameter' {
            $result = Get-SqlDbTypeFromType -Value $byteArrayValue
            $result | Should -Be ([SqlDbType]::Binary)
        }

        It 'Should handle char value parameter' {
            $result = Get-SqlDbTypeFromType -Value $charValue
            $result | Should -Be ([SqlDbType]::Char)
        }

        It 'Should handle char array value parameter' {
            $result = Get-SqlDbTypeFromType -Value $charArrayValue
            $result | Should -Be ([SqlDbType]::VarChar)
        }

        It 'Should handle byte value parameter' {
            $result = Get-SqlDbTypeFromType -Value $byteValue
            $result | Should -Be ([SqlDbType]::TinyInt)
        }
    }

    Context 'Type Parameter Tests' {
        BeforeAll {
            # Suppress verbose and debug output
            $VerbosePreference = 'SilentlyContinue'
            $DebugPreference = 'SilentlyContinue'
        }
        It 'Should handle Boolean type parameter' {
            $result = Get-SqlDbTypeFromType -Type ([bool])
            $result | Should -Be ([SqlDbType]::Bit)
        }

        It 'Should handle Byte type parameter' {
            $result = Get-SqlDbTypeFromType -Type ([byte])
            $result | Should -Be ([SqlDbType]::TinyInt)
        }

        It 'Should handle Byte[] type parameter' {
            $result = Get-SqlDbTypeFromType -Type ([byte[]])
            $result | Should -Be ([SqlDbType]::Binary)
        }

        It 'Should handle Char type parameter' {
            $result = Get-SqlDbTypeFromType -Type ([char])
            $result | Should -Be ([SqlDbType]::Char)
        }

        It 'Should handle Char[] type parameter' {
            $result = Get-SqlDbTypeFromType -Type ([char[]])
            $result | Should -Be ([SqlDbType]::VarChar)
        }

        It 'Should handle DateTime type parameter' {
            $result = Get-SqlDbTypeFromType -Type ([DateTime])
            $result | Should -Be ([SqlDbType]::DateTime)
        }

        It 'Should handle DateTimeOffset type parameter' {
            $result = Get-SqlDbTypeFromType -Type ([DateTimeOffset])
            $result | Should -Be ([SqlDbType]::DateTimeOffset)
        }

        It 'Should handle Decimal type parameter' {
            $result = Get-SqlDbTypeFromType -Type ([decimal])
            $result | Should -Be ([SqlDbType]::Decimal)
        }
        It 'Should handle Double type parameter' {
            $result = Get-SqlDbTypeFromType -Type ([double])
            $result | Should -Be ([SqlDbType]::Float)
        }

        It 'Should handle Guid type parameter' {
            $result = Get-SqlDbTypeFromType -Type ([guid])
            $result | Should -Be ([SqlDbType]::UniqueIdentifier)
        }

        It 'Should handle Int16 type parameter' {
            $result = Get-SqlDbTypeFromType -Type ([Int16])
            $result | Should -Be ([SqlDbType]::SmallInt)
        }

        It 'Should handle Int32 type parameter' {
            $result = Get-SqlDbTypeFromType -Type ([Int32])
            $result | Should -Be ([SqlDbType]::Int)
        }

        It 'Should handle Int64 type parameter' {
            $result = Get-SqlDbTypeFromType -Type ([Int64])
            $result | Should -Be ([SqlDbType]::BigInt)
        }

        It 'Should handle SByte type parameter' {
            $result = Get-SqlDbTypeFromType -Type ([SByte])
            $result | Should -Be ([SqlDbType]::SmallInt)
        }

        It 'Should handle Single type parameter' {
            $result = Get-SqlDbTypeFromType -Type ([Single])
            $result | Should -Be ([SqlDbType]::Real)
        }

        It 'Should handle String type parameter' {
            $result = Get-SqlDbTypeFromType -Type ([String])
            $result | Should -Be ([SqlDbType]::NVarChar)
        }
        It 'Should handle TimeSpan type parameter' {
            $result = Get-SqlDbTypeFromType -Type ([TimeSpan])
            $result | Should -Be ([SqlDbType]::Time)
        }

        It 'Should handle UInt16 type parameter' {
            $result = Get-SqlDbTypeFromType -Type ([UInt16])
            $result | Should -Be ([SqlDbType]::Int)
        }

        It 'Should handle UInt32 type parameter' {
            $result = Get-SqlDbTypeFromType -Type ([UInt32])
            $result | Should -Be ([SqlDbType]::BigInt)
        }

        It 'Should handle UInt64 type parameter' {
            $result = Get-SqlDbTypeFromType -Type ([UInt64])
            $result | Should -Be ([SqlDbType]::BigInt)
        }

        It 'Should handle XmlDocument type parameter' {
            $result = Get-SqlDbTypeFromType -Type ([System.Xml.XmlDocument])
            $result | Should -Be ([SqlDbType]::Xml)
        }

        It 'Should handle default case (unknown type)' {
            $result = Get-SqlDbTypeFromType -Type ([System.Collections.ArrayList])
            $result | Should -Be ([SqlDbType]::Variant) }

        It 'Should handle SqlDbType type parameter' {
            $result = Get-SqlDbTypeFromType -Type ([SqlDbType])
            $result | Should -Be ([SqlDbType]::Variant)
        }

        It 'Should pass through SqlDbType value' {
            $inputSqlDbType = [SqlDbType]::Image
            $result = Get-SqlDbTypeFromType -Value $inputSqlDbType
            $result | Should -Be $inputSqlDbType
        }
    }
}
