param (
    [Parameter(ValueFromPipeline = $true)]$data = $null
)

# connString
$conn = new-object System.Data.SqlClient.SqlConnection $data.Metadata.ConnectionString
$conn.Open()

$table = ($data.ProcessItem.GetEnumerator() | Select-Object -first 1).Value["Name"]

## query & cmd
$q = (Get-Content .\Scripts\MsSQL\Tables\SQL\Show-Table-Detail.sql -Encoding UTF8) -join "`n"
$cmd = new-object System.Data.SqlClient.SqlCommand($q, $conn)
$cmd.Parameters.AddWithValue('@name', $table) | Out-Null
$reader = $cmd.ExecuteReader() 

if ($reader.Read()) {
    # save definition to temp
    $output = $reader['definition']
    $path = Join-Path -Path $env:temp -ChildPath "$($table).sql"
    $output | Out-File -filepath $path
    # and run
    Start-Process -filepath $path
}

$reader.Close()
$conn.Close() 

# vratim data
$data