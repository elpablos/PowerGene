param (
    [Parameter(ValueFromPipeline = $true)]$data = $null
)

$func = ($data.ProcessItem.GetEnumerator() | Select-Object -first 1).Key
Write-Host $func

# remove
$data.Functions.Remove($func) | Out-Null

# vratim data
$data