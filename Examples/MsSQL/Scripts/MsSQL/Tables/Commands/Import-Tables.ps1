param (
    [Parameter(ValueFromPipeline = $true)]$data = $null
)

# connString
$conn = new-object System.Data.SqlClient.SqlConnection $data.Metadata.ConnectionString
$conn.Open()

## query & cmd
$q = "SELECT TABLE_NAME, TABLE_SCHEMA, TABLE_CATALOG FROM INFORMATION_SCHEMA.TABLES"
$cmd = new-object System.Data.SqlClient.SqlCommand($q, $conn)
#$cmd.Parameters.AddWithValue('@ProcName', $proc) | Out-Null
$reader = $cmd.ExecuteReader() 

$tables = [ordered]@{} 

while ($reader.Read()){
    # add table to tables
    $name = $reader['TABLE_NAME']
   if (!$data.Tables.ContainsKey($name)) {
        $tables.Add($name, [ordered]@{
            DisplayName = ($reader['TABLE_SCHEMA']+'.'+$name)
            Schema = $reader['TABLE_SCHEMA']
            Name = $name
        })
    }
}

$reader.Close()
$conn.Close() 

$temp = $tables.Keys | Out-GridView -PassThru -Title "Select item(s"
foreach ($tbl in $temp) {      
    $val = $tables[$tbl]
    $data.Tables.Add($val.Name, $val)
}

$reader.Close()
$conn.Close() 

$data