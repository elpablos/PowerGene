param (
    [Parameter(ValueFromPipeline = $true)]$data = $null
)

$table = ($data.ProcessItem.GetEnumerator() | Select-Object -first 1).Key
Write-Host $table

# remove
$data.Tables.Remove($table) | Out-Null

# vratim data
$data