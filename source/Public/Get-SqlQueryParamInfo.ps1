function Get-SqlQueryParamInfo
{
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
