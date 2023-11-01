function Get-SqlQueryConnection
{
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
