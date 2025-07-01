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
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [string]
        [ValidateNotNullOrEmpty()]
        $ParameterName
    )

    process
    {
        # Support hashtable pipeline input
        $paramName = $ParameterName
        if ($_ -is [hashtable] -and $_.ContainsKey('ParameterName'))
        {
            $paramName = $_['ParameterName']
        }

        # Throw if null, empty, or whitespace
        if ([string]::IsNullOrWhiteSpace($paramName))
        {
            $PSCmdlet.ThrowTerminatingError((New-Object System.Management.Automation.ErrorRecord (
                (New-Object System.ArgumentException 'ParameterName cannot be null, empty, or whitespace.'),
                        'ParameterArgumentValidationError',
                        [System.Management.Automation.ErrorCategory]::InvalidArgument,
                        $paramName
                    )))
        }

        if ($script:Configuration -isnot [hashtable])
        {
            $script:Configuration = @{}
        }

        if ($script:Configuration.ContainsKey('ParameterMapping') -and $script:Configuration['ParameterMapping'].ContainsKey($paramName))
        {
            return $script:Configuration['ParameterMapping'][$paramName]
        }
        elseif (-not $script:Configuration.ContainsKey('ParameterMapping') -and (Test-Path -Path (Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath 'config/parameter.config.psd1')))
        {
            $script:Configuration['ParameterMapping'] = Import-PowerShellDataFile -Path (Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath 'config/parameter.config.psd1')
            return $script:Configuration['ParameterMapping'][$paramName]
        }
        else
        {
            return $null
        }
    }
}
