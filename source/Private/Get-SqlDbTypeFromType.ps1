using namespace System.Data

function Get-SqlDbTypeFromType
{
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
