
using namespace System.Data

function Get-SqlDbTypeFromType
{
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

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true,  ParameterSetName = 'ByValue')]
        [object]
        $Value
    )

    process
    {
        if ($PSCmdlet.ParameterSetName -eq 'ByValue' -and $null -ne $Value)
        {
            $Type = $Value.GetType()
            Write-Verbose -Message ('Getting the SQL DB type by Value: {0}' -f $Type.ToString())
        }
        elseif ($null -eq $Value)
        {
            [SqlDbType]::dbNull
            Write-Verbose -Message ('SQL DB type is DBNull.')
        }
        else
        {
            Write-Verbose -Message ('Getting the SQL DB type by Type: {0}' -f $Type.ToString())
        }

        [SqlDbType] $dbType = switch ($Type)
        {
            [SqlDbType]
            {
                $_
            }

            [System.Boolean]
            {
                [SqlDbType]::Bit
            }

            [System.Byte]
            {
                [SqlDbType]::TinyInt
            }

            [System.Byte[]]
            {
                [SqlDbType]::Binary
            }

            [System.Char]
            {
                [SqlDbType]::Char
            }

            [System.Char[]]
            {
                [SqlDbType]::VarChar
            }

            [System.DateTime]
            {
                [SqlDbType]::DateTime
            }

            [System.DateTimeOffset]
            {
                [SqlDbType]::DateTimeOffset
            }

            [System.Decimal]
            {
                [SqlDbType]::Decimal
            }

            [System.Double]
            {
                [SqlDbType]::Float
            }

            [System.Guid]
            {
                [SqlDbType]::UniqueIdentifier
            }

            [System.Int16]
            {
                [SqlDbType]::SmallInt
            }

            [System.Int32]
            {
                [SqlDbType]::Int
            }

            [System.Int64]
            {
                [SqlDbType]::BigInt
            }

            [System.SByte]
            {
                [SqlDbType]::SmallInt
            }

            [System.Single]
            {
                [SqlDbType]::Real
            }

            [System.String]
            {
                [SqlDbType]::nVarChar
            }

            [System.TimeSpan]
            {
                [SqlDbType]::Time
            }

            [System.UInt16]
            {
                [SqlDbType]::Int
            }

            [System.UInt32]
            {
                [SqlDbType]::BigInt
            }

            [System.UInt64]
            {
                [SqlDbType]::BigInt
            }

            [System.Xml.XmlDocument]
            {
                [SqlDbType]::Xml
            }

            default
            {
                [SqlDbType]::variant
            }
        }

        Write-Debug -Message ('SQL DB type is {0}.' -f $dbType.ToString())
        return $dbType
    }
}
