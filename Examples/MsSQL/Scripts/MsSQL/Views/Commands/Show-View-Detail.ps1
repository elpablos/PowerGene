param (
    [Parameter(ValueFromPipeline = $true)]$data = $null
)

If (!(Get-module Powergene)) {
    Import-Module .\Scripts\modules\Powergene\Powergene.psm1
}

# connString
$conn = new-object System.Data.SqlClient.SqlConnection $data.Metadata.ConnectionString
$conn.Open()

$func = ""
$func = ($data.ProcessItem.GetEnumerator() | select -first 1).Value["Name"]

Write-Host $func

## query & cmd
$q = "
select sys.sql_modules.definition from sysobjects 
left join sys.sql_modules on sys.sql_modules.object_id = sysobjects.id
where name = @name
"
$cmd = new-object System.Data.SqlClient.SqlCommand($q, $conn)
$cmd.Parameters.AddWithValue('@name', $func) | Out-Null
$reader = $cmd.ExecuteReader() 

if ($reader.Read()) {
    # save definition to temp
    $output = $reader['definition']
    $path = Join-Path -Path $env:temp -ChildPath "$($func).sql"
    $output | Out-File -filepath $path
    # and run
    Start-Process -filepath $path
}

$reader.Close()
$conn.Close() 

#$data | ConvertTo-Json -Depth 5 -Compress # | $dataString #  > "data.json"
$data