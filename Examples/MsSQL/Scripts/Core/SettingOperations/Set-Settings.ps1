param (
    [Parameter(ValueFromPipeline = $true)]$data = $null
)

$TempFile = New-TemporaryFile
$TempFile = [io.path]::ChangeExtension($TempFile, ".json") 

$data | Out-JsonFile -path $TempFile
Start-Process -FilePath "code" -ArgumentList $TempFile -NoNewWindow -Wait

$data = Read-JsonFile $TempFile

$data