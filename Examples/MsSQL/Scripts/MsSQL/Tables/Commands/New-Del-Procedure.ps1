param (
    [Parameter(ValueFromPipeline = $true)]$data = $null
)

# connString
$conn = new-object System.Data.SqlClient.SqlConnection $data.Metadata.ConnectionString
$conn.Open()

$table = ($data.ProcessItem.GetEnumerator() | select -first 1).Value["Name"]

$Name = $table + "_DEL"
$Command = 'CREATE'
$CreateCommand = $false


## query & cmd
$q = (Get-Content .\Scripts\MsSQL\Tables\SQL\New-Del-Procedure.sql -Encoding UTF8) -join "`n"
$cmd = new-object System.Data.SqlClient.SqlCommand($q, $conn)

$cmd.Parameters.AddWithValue('@ID_Table', $table) | Out-Null
#$cmd.Parameters.AddWithValue('@Name', $Name) | Out-Null
$cmd.Parameters.AddWithValue('@Command', $Command) | Out-Null
$cmd.Parameters.AddWithValue('@CreateCommand', $CreateCommand) | Out-Null

$reader = $cmd.ExecuteReader() 

if ($reader.Read()) {
    # save definition to temp
    $output = $reader['SQL']
    $path = Join-Path -Path $env:temp -ChildPath "$($Name).sql"
    $output | Out-File -filepath $path
    # and run
    Start-Process -filepath $path
}

$reader.Close()
$conn.Close() 

$data