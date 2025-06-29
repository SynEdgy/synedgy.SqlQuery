function Get-SqlQueryConvertedDataSet
{
    <#
    .SYNOPSIS
    Converts a DataSet to various output formats.

    .DESCRIPTION
    Converts a [System.Data.DataSet] object to a specified format such as hashtable, xml, json, pscustomobject, dataset, none, or table. Useful for transforming SQL query results for further processing or output.

    .PARAMETER ConvertTo
    The format to convert the DataSet to. Valid values are: hashtable, xml, json, pscustomobject, dataset, none, table. Default is pscustomobject.

    .PARAMETER DataSet
    The DataSet object to convert.

    .EXAMPLE
    PS> Get-SqlQueryConvertedDataSet -ConvertTo json -DataSet $ds
    Returns the DataSet as a JSON string.
    #>
    [CmdletBinding()]
    [OutputType([System.Data.DataSet], [System.Data.DataTable], [string], [hashtable[]], [PSCustomObject[]], [object])]
    param
    (
        [Parameter()]
        [string]
        [ValidateSet('hashtable','xml','json','pscustomobject','dataset','none','table')]
        $ConvertTo = 'pscustomobject',

        [Parameter()]
        [System.Data.DataSet]
        $DataSet
    )

    process
    {
        switch ($ConvertTo)
        {
            'none'
            {
                return $DataSet
            }

            'table'
            {
                return $DataSet.Tables[0]
            }

            'json'
            {
                return ($DataSet.Tables[0].rows | ConvertTo-Json -Depth 10)
            }

            'xml'
            {
                return (ConvertTo-Xml -InputObject $DataSet -Depth 10).OuterXml
            }

            'rows'
            {
                return $DataSet.Tables[0].Rows
            }

            'hashtable'
            {
                $DataSet.Tables[0].Rows.ForEach{
                    $row = $_
                    $rowHash = [ordered]@{}
                    @($row.Table.Columns).ForEach({
                        if ($row[$_] -is [System.DBNull])
                        {
                            $rowHash[$_.ColumnName] = $null
                        }
                        elseif (-not [string]::IsNullOrEmpty($row[$_]) -and $row[$_] -is [string])
                        {
                            $rowHash[$_.ColumnName] = $row[$_].Trim()
                        }
                        else
                        {
                            $rowHash[$_.ColumnName] = $row[$_]
                        }
                    })

                    $rowHash
                }
            }

            'PSCustomObject'
            {
                $DataSet.Tables[0].Rows.ForEach{
                    $row = $_
                    $psTypeName = $DataSet.Tables[0].TableName
                    $rowHash = [ordered]@{
                        'PSTypeName' = $psTypeName
                    }

                    @($row.Table.Columns).ForEach({
                        if ($row[$_] -is [System.DBNull])
                        {
                            $rowHash[$_.ColumnName] = $null
                        }
                        elseif (-not [string]::IsNullOrEmpty($row[$_]) -and $row[$_] -is [string])
                        {
                            $rowHash[$_.ColumnName] = $row[$_].Trim()
                        }
                        else
                        {
                            $rowHash[$_.ColumnName] = $row[$_]
                        }
                    })

                    [PSCustomObject]$rowHash
                }
            }
        }
    }
}
