using namespace System.Data

function Get-SqlDbTypeFromType {
    <#
    .SYNOPSIS
    Maps a .NET type or value to a corresponding SQL DbType.

    .DESCRIPTION
    Given a .NET type or value, returns the corresponding [System.Data.SqlDbType] for use in SQL parameter mapping. Supports a wide range of .NET types and values.

    .PARAMETER Type
    The .NET type to map to a SQL DbType. Optional if Value is provided.

    .PARAMETER Value
    The value whose type will be mapped to a SQL DbType. Optional if Type is provided.

    .EXAMPLE
    PS> Get-SqlDbTypeFromType -Type ([int])
    Returns 'Int' SqlDbType.

    .EXAMPLE
    PS> Get-SqlDbTypeFromType -Value 1
    Returns 'Int' SqlDbType for the value 1.
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByValue')]
    [OutputType([SqlDbType])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByType')]
        [Type]
        $Type,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByValue')]
        [object]
        $Value
    )    process {
        if ($PSCmdlet.ParameterSetName -eq 'ByValue') {
            if ($null -eq $Value) {
                Write-Verbose -Message ('SQL DB type is DBNull.')
                return [SqlDbType]::DbNull
            }

            # If a SqlDbType is passed directly, return it unchanged
            if ($Value -is [SqlDbType]) {
                Write-Verbose -Message ('SQL DB type is directly provided as {0}.' -f $Value.ToString())
                return $Value
            }

            $Type = $Value.GetType()
            Write-Verbose -Message ('Getting the SQL DB type by Value: {0}' -f $Type.ToString())
        } else {
            Write-Verbose -Message ('Getting the SQL DB type by Type: {0}' -f $Type.ToString())
        }

        # Use equality comparison for reliable type matching
        [SqlDbType] $dbType = switch ($Type) {

            { $_.Equals([System.Boolean]) } {
                [SqlDbType]::Bit
            }

            { $_.Equals([System.Byte]) } {
                [SqlDbType]::TinyInt
            }

            { $_.Equals([System.Byte[]]) } {
                [SqlDbType]::Binary
            }

            { $_.Equals([System.Char]) } {
                [SqlDbType]::Char
            }

            { $_.Equals([System.Char[]]) } {
                [SqlDbType]::VarChar
            }

            { $_.Equals([System.DateTime]) } {
                [SqlDbType]::DateTime
            }

            { $_.Equals([System.DateTimeOffset]) } {
                [SqlDbType]::DateTimeOffset
            }

            { $_.Equals([System.Decimal]) } {
                [SqlDbType]::Decimal
            }

            { $_.Equals([System.Double]) } {
                [SqlDbType]::Float
            }

            { $_.Equals([System.Guid]) } {
                [SqlDbType]::UniqueIdentifier
            }

            { $_.Equals([System.Int16]) } {
                [SqlDbType]::SmallInt
            }

            { $_.Equals([System.Int32]) } {
                [SqlDbType]::Int
            }

            { $_.Equals([System.Int64]) } {
                [SqlDbType]::BigInt
            }

            { $_.Equals([System.SByte]) } {
                [SqlDbType]::SmallInt
            }

            { $_.Equals([System.Single]) } {
                [SqlDbType]::Real
            }

            { $_.Equals([System.String]) } {
                [SqlDbType]::NVarChar
            }

            { $_.Equals([System.TimeSpan]) } {
                [SqlDbType]::Time
            }

            { $_.Equals([System.UInt16]) } {
                [SqlDbType]::Int
            }

            { $_.Equals([System.UInt32]) } {
                [SqlDbType]::BigInt
            }

            { $_.Equals([System.UInt64]) } {
                [SqlDbType]::BigInt
            }

            { $_.Equals([System.Xml.XmlDocument]) } {
                [SqlDbType]::Xml
            }

            default {
                [SqlDbType]::Variant
            }
        }

        Write-Debug -Message ('SQL DB type is {0}.' -f $dbType.ToString())
        return $dbType
    }
}
