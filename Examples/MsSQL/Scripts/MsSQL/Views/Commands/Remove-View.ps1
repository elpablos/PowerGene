param (
    [Parameter(ValueFromPipeline = $true)]$data = $null
)

$view = ($data.ProcessItem.GetEnumerator() | Select-Object -first 1).Key
Write-Host $view

# remove
$data.Views.Remove($view) | Out-Null

# vratim data
$data