param (
    [Parameter(ValueFromPipeline = $true)]$data = $null
)

If (!(Get-module Powergene)) {
    Import-Module .\Scripts\modules\Powergene\Powergene.psm1
}

# connString
$conn = new-object System.Data.SqlClient.SqlConnection $data.Metadata.ConnectionString
$conn.Open()

## query & cmd
$q = "SELECT TABLE_NAME, TABLE_SCHEMA, TABLE_CATALOG from information_schema.views"
$cmd = new-object System.Data.SqlClient.SqlCommand($q, $conn)
#$cmd.Parameters.AddWithValue('@ProcName', $proc) | Out-Null
$reader = $cmd.ExecuteReader() 

$views = [ordered]@{} 

while ($reader.Read()){
    # add view to views
    $name = $reader['TABLE_NAME']
    if (!$data.Views.ContainsKey($name)) {
        $views.Add($name, [ordered]@{
            DisplayName = ($reader['TABLE_SCHEMA']+'.'+$name)
            Schema = $reader['TABLE_SCHEMA']
            Name = $name
        })
    }
}

$temp = $views.Keys | Out-GridView -PassThru -Title "Select item(s"
foreach ($v in $temp) {      
    $val = $views[$v]
    $data.Views.Add($val.Name, $val)
}


$reader.Close()
$conn.Close() 

$data