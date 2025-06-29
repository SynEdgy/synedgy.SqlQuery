BeforeAll {
    # Import the module for testing
    Import-Module -Name "$PSScriptRoot\..\output\module\synedgy.sqlQuery" -Force
}

Describe 'Get-SqlQueryConvertedDataSet' {
    It 'Should return a PSCustomObject by default' {
        $ds = New-Object System.Data.DataSet
        $dt = $ds.Tables.Add('Test')
        $dt.Columns.Add('Col1') | Out-Null
        $row = $dt.NewRow()
        $row['Col1'] = 'val'
        $dt.Rows.Add($row)
        $result = Get-SqlQueryConvertedDataSet -DataSet $ds
        $result | Should -BeOfType 'System.Management.Automation.PSCustomObject'
    }
}
