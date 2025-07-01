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
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [hashtable]$ParameterConfiguration
    )

    process
    {
        if (-not ($script:Configuration -is [hashtable]))
        {
            $script:Configuration = @{}
        }

        if (-not $script:Configuration.ContainsKey('ParameterMapping'))
        {
            $script:Configuration['ParameterMapping'] = @{}
        }

        foreach ($key in $ParameterConfiguration.Keys)
        {
            if (-not $script:Configuration['ParameterMapping'].ContainsKey($key))
            {
                if ($PSCmdlet.ShouldProcess('ParameterMapping', "Add mapping for $key"))
                {
                    $script:Configuration['ParameterMapping'][$key] = $ParameterConfiguration[$key]
                }
            }
        }
    }
}
