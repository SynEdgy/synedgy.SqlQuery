function Set-SqlQueryParameterConfiguration
{
    <#
    .SYNOPSIS
    Sets the parameter mapping configuration for SQL queries.

    .DESCRIPTION
    Updates the internal configuration with a new parameter mapping hashtable. Used to control how parameters are mapped for SQL queries.

    .PARAMETER ParameterConfiguration
    The hashtable containing parameter mapping configuration. This parameter is mandatory.

    .EXAMPLE
    PS> Set-SqlQueryParameterConfiguration -ParameterConfiguration $mapping
    Sets the parameter mapping configuration for SQL queries.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [hashtable]
        $ParameterConfiguration
    )

    process
    {
        if ($PSCmdlet.ShouldProcess('ParameterMapping', 'Set parameter mapping configuration'))
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
}
