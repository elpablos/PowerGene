param (
    [Parameter(ValueFromPipeline = $true)]$data = $null
)

$path = $data.Metadata.Path
New-Item -ItemType Directory -Force -Path $path

Start-Process -FilePath $path