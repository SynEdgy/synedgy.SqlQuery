function Get-SqlQueryParamInfo
{
    <#
    .SYNOPSIS
    Retrieves parameter mapping information for a SQL query parameter.

    .DESCRIPTION
    Looks up the mapping information for a given parameter name from the configuration. Returns a hashtable with parameter mapping details if found, otherwise returns $null.

    .PARAMETER ParameterName
    The name of the parameter to retrieve mapping information for. This parameter is mandatory.

    .EXAMPLE
    PS> Get-SqlQueryParamInfo -ParameterName "UserId"
    Returns the mapping information for the parameter 'UserId'.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        [ValidateNotNullOrEmpty()]
        $ParameterName
    )

    process
    {
        if ($script:Configuration -isnot [hashtable])
        {
            $script:Configuration =  @{}
        }

        if ($script:Configuration.ContainsKey('ParameterMapping') -and $script:Configuration['ParameterMapping'].ContainsKey($ParameterName))
        {
            return $script:Configuration['ParameterMapping'][$ParameterName]
        }
        elseif (-not $script:Configuration.ContainsKey('ParameterMapping') -and (Test-Path -Path (Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath 'config/parameter.config.psd1')))
        {
            $script:Configuration['ParameterMapping'] = Import-PowerShellDataFile -Path (Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath 'config/parameter.config.psd1')
            return $script:Configuration['ParameterMapping'][$ParameterName]
        }
        else
        {
            return $null
        }
    }
}
