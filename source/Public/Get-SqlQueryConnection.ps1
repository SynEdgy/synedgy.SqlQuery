function Get-SqlQueryConnection
{
    <#
    .SYNOPSIS
    Creates and returns a SQL Server connection object.

    .DESCRIPTION
    Creates a new [System.Data.SqlClient.SqlConnection] using the provided connection string. This function is used to establish a connection to a SQL Server database for use in other commands. The connection string must be valid and not empty.

    .PARAMETER ConnectionString
    The connection string to use for connecting to the SQL Server database. This parameter is mandatory.

    .EXAMPLE
    PS> Get-SqlQueryConnection -ConnectionString "Server=localhost;Database=Test;Integrated Security=True;"
    Returns a SqlConnection object for the specified database.
    #>
    [CmdletBinding()]
    [OutputType([System.Data.SqlClient.SqlConnection])]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'ByConnectionString')]
        [string]
        [ValidateNotNullOrEmpty()]
        $ConnectionString
    )

    if ($PSCmdlet.ParameterSetName -eq 'ByConnectionString' -and -not [string]::IsNullOrEmpty($ConnectionString))
    {
        $SqlConnection = [System.Data.SqlClient.SqlConnection]::new($ConnectionString)
    }

    return $SqlConnection
}
