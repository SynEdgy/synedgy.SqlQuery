function Set-SqlQueryParameterConfiguration
{
    [CmdletBinding()]
    [OutputType([void])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [hashtable]
        $ParameterConfiguration
    )

    begin
    {
        if ($script:Configuration -isnot [hashtable])
        {
            $script:Configuration['ParameterMapping'] = @{}
        }

        if (-not $script:Configuration.ContainsKey('ParameterMapping'))
        {
            $script:Configuration['ParameterMapping'] = $ParameterConfiguration
        }
    }
}
