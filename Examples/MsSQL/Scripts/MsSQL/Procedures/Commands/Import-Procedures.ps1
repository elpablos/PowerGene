param (
    [Parameter(ValueFromPipeline = $true)]$data = $null
)

# connString
$conn = new-object System.Data.SqlClient.SqlConnection $data.Metadata.ConnectionString
$conn.Open()

## query & cmd
$q = "select SPECIFIC_NAME, SPECIFIC_SCHEMA, SPECIFIC_CATALOG from information_schema.routines where routine_type = 'PROCEDURE'"
$cmd = new-object System.Data.SqlClient.SqlCommand($q, $conn)
#$cmd.Parameters.AddWithValue('@ProcName', $proc) | Out-Null
$reader = $cmd.ExecuteReader() 

$procedures = [ordered]@{} 

while ($reader.Read()){
    # add proc to procedures
    $name = $reader['SPECIFIC_NAME']
    if (!$data.Procedures.ContainsKey($name)) {
        $procedures.Add($name, [ordered]@{
            DisplayName = ($reader['SPECIFIC_SCHEMA']+'.'+$name)
            Schema = $reader['SPECIFIC_SCHEMA']
            Name = $name
        })
    }
}

$temp = $procedures.Keys | Out-GridView -PassThru -Title "Select item(s"
foreach ($proc in $temp) {      
    $val = $procedures[$proc]
    $data.Procedures.Add($val.Name, $val)
}

$reader.Close()
$conn.Close() 

$data