param (
    [Parameter(ValueFromPipeline = $true)]$data = $null
)

$proc = ($data.ProcessItem.GetEnumerator() | Select-Object -first 1).Key
Write-Host $proc

# remove
$data.Procedures.Remove($proc) | Out-Null

# vratim data
$data