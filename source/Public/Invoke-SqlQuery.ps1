
using namespace System.Data

function Invoke-SqlQuery
{
    <#
    .SYNOPSIS
    Executes a SQL query or stored procedure and returns the result.

    .DESCRIPTION
    Executes a SQL command using the provided connection and parameters. Supports returning results in various formats and handling output/return values for stored procedures.

    .PARAMETER SqlConnection
    The SQL connection to use. If not provided, a new connection is created.

    .PARAMETER Cmd
    The SQL command text or stored procedure name to execute.

    .PARAMETER SqlCommandType
    The type of SQL command (Text or StoredProcedure).

    .PARAMETER Parameters
    Hashtable of parameters to pass to the SQL command.

    .PARAMETER CmdTimeoutSec
    Command timeout in seconds.

    .PARAMETER ConvertResultDataSetTo
    Format to convert the result DataSet to. Default is 'table'.

    .PARAMETER KeepAlive
    If specified, keeps the connection open after execution.

    .PARAMETER ReturnValue
    If specified, returns the stored procedure return value.

    .PARAMETER OutputVariable
    Array of hashtables describing output variables for stored procedures.

    .EXAMPLE
    PS> Invoke-SqlQuery -SqlConnection $conn -Cmd "SELECT * FROM Users" -SqlCommandType Text
    Executes a query and returns the result as a table.
    #>
    [CmdletBinding()]
    [OutputType([System.Data.DataSet],[object])]
    param
    (
        [Parameter()]
        [System.Data.SqlClient.SqlConnection]
        $SqlConnection = (Get-SqlQueryConnection),

        [Parameter()]
        [string]
        $Cmd,

        [Parameter(Mandatory)]
        [System.Data.CommandType]
        $SqlCommandType,

        [Parameter()]
        [hashtable]
        $Parameters,

        [Parameter()]
        [int]
        $CmdTimeoutSec,

        [Parameter()]
        [ValidateSet('hashtable','xml','json','pscustomobject','none','table', 'rows')]
        [string]
        $ConvertResultDataSetTo = 'table',

        [Parameter()]
        [switch]
        $KeepAlive,

        [Parameter()]
        [switch]
        $ReturnValue,

        [Parameter()]
        [hashtable[]]
        $OutputVariable = @(
            # @{
            #     Name = '@RETURN_VALUE'
            #     SqlDbType = [System.Data.SqlDbType]::Int
            # }
        )
    )

    begin
    {
        [System.Data.IDbCommand] $SqlCommand = [System.Data.SqlClient.SqlCommand]::new($Cmd, $SqlConnection)
        $SqlCommand.CommandType = $SqlCommandType
        $SqlCommand.CommandTimeout = $CmdTimeoutSec

        if ($SqlCommandType -eq [System.Data.CommandType]::StoredProcedure -and $PSBoundParameters.ContainsKey('Parameters'))
        {
            $Parameters.Keys.ForEach({
                $psParameterName = $_
                $paramInfo = Get-SqlQueryParamInfo -ParameterName $psParameterName
                if ($null -eq $paramInfo)
                {
                    Write-Warning -Message ('Parameter {0} mapping not found. Using @{0}.' -f $psParameterName)
                    $paramInfo = @{
                        SqlParamName   = ''
                        SqlDbType      = [System.Data.SqlDbType]::Variant
                        SqlColumnName  = ''
                        # Size         = 0
                        # Precision    = 0
                        # Scale        = 0
                        # Direction    = [System.Data.ParameterDirection]::Input
                    }
                }

                # Default to use the PS parameter name if the SqlParamName is not specified
                if ([string]::IsNullOrEmpty($paramInfo.SqlParamName))
                {
                    Write-Warning -Message ('Parameter {0} mapping not found. Using @{0}.' -f $psParameterName)
                    $paramInfo['sqlParamName'] = $psParameterName
                }

                if ([string]::IsNullOrEmpty($paramInfo.SqlDbType) -and $null -ne $Parameters[$psParameterName])
                {
                    $paramInfo['sqlDbType'] = Get-SqlDbTypeFromType -Value $Parameters[$psParameterName]
                }
                else
                {
                    $paramInfo['sqlDbType'] = [System.Data.SqlDbType]::Variant
                }

                $p = [System.Data.SqlClient.SqlParameter]::new(
                    $paramInfo.SqlParamName,
                    $paramInfo.SqlDbType
                )

                # Add all other properties defined for the parameter in the mapping
                $paramInfo.Keys.Where({$_ -notin @('SqlParamName','SqlDbType','SqlColumnName')}).ForEach({
                    Write-Debug -Message ('Setting {0} to {1}' -f $_, $paramInfo['sqlParamName'])
                    $p.($_) = $paramInfo[$_]
                })

                $null = $SqlCommand.Parameters.Add($p)
            })
        }

        if ($SqlCommandType -eq [CommandType]::StoredProcedure -and $ReturnValue.IsPresent)
        {

            $p = [System.Data.SqlClient.SqlParameter]::new(
                '@RETURN_VALUE',
                [System.Data.SqlDbType]::Int
            )

            $p.Direction = [System.Data.ParameterDirection]::ReturnValue
            $null = $SqlCommand.Parameters.Add($p)
        }

        if ($SqlCommandType -eq [CommandType]::StoredProcedure -and $OutputVariable.count -gt 0)
        {
            $OutputVariable.ForEach({
                $p = [System.Data.SqlClient.SqlParameter]::new(
                    $_.Name,
                    [System.Data.SqlDbType]($_.SqlDbType)
                )

                $p.Direction = [System.Data.ParameterDirection]::Output
                $null = $SqlCommand.Parameters.Add($p)
            })
        }

        if ($SqlConnection.State -ne 'Open')
        {
            Write-Verbose -Message 'Opening the SQL connection...'
            $SqlConnection.Open()
            Write-Verbose -Message 'opened.'
        }

        $sqlDataAdapter = [System.Data.SqlClient.SqlDataAdapter]::new($SqlCommand)
        $dataSet = [System.Data.DataSet]::new()

        try
        {
            $resultRows = $sqlDataAdapter.Fill($DataSet)

            if ($resultRows.count -gt 0 -and $ConvertResultDataSetTo -eq 'none')
            {
                return $dataSet
            }
            elseif ($resultRows.count -gt 0)
            {
                Get-SqlQueryConvertedDataSet -ConvertTo $ConvertResultDataSetTo -DataSet $dataSet
            }
            else
            {
                Write-Verbose -Message 'No result rows.'
            }
        }
        catch
        {
            Write-Warning -Message ('Error executing ''{0}'' the SQL query: {1}' -f $SqlCommand, $_.Exception.Message)
        }
        finally
        {
            try
            {
                if ($null -ne $sqlDataAdapter)
                {
                    $null = $sqlDataAdapter.Dispose()
                }

                if ($null -ne $dataSet)
                {
                    $null = $dataSet.Dispose()
                }

                if ($null -eq $SqlConnection -and -not $KeepAlive.IsPresent)
                {
                    Write-Verbose -Message 'Closing the SQL connection...'
                    $null = $SqlConnection.Close()
                    Write-Verbose -Message 'closed.'

                    $SqlConnection.Dispose()
                }
            }
            catch
            {
                Write-Verbose -Message ('Error closing the SQL connection: {0}' -f $_.Exception.Message)
            }
        }
    }
}
