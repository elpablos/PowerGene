param (
    [Parameter(ValueFromPipeline = $true)]$data = $null
)

# connString
$conn = new-object System.Data.SqlClient.SqlConnection $data.Metadata.ConnectionString
$conn.Open()

## query & cmd
$q = "select SPECIFIC_NAME, SPECIFIC_SCHEMA, SPECIFIC_CATALOG from information_schema.routines where routine_type = 'function'"
$cmd = new-object System.Data.SqlClient.SqlCommand($q, $conn)
#$cmd.Parameters.AddWithValue('@ProcName', $proc) | Out-Null
$reader = $cmd.ExecuteReader() 

$functions = [ordered]@{} 

while ($reader.Read()){
    # add func to functions
    $name = $reader['SPECIFIC_NAME']
    if (!$data.Functions.ContainsKey($name)) {
        $functions.Add($name, [ordered]@{
            DisplayName = ($reader['SPECIFIC_SCHEMA']+'.'+$name)
            Schema = $reader['SPECIFIC_SCHEMA']
            Name = $name
        })
    }
}

$temp = $functions.Keys | Out-GridView -PassThru -Title "Select item(s"
foreach ($fnc in $temp) {      
    $val = $functions[$fnc]
    $data.Functions.Add($val.Name, $val)
}

$reader.Close()
$conn.Close() 

$data