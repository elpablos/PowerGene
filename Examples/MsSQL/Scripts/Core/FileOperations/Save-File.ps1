param (
    [Parameter(ValueFromPipeline = $true)]$data = $null
)

if ($data.Path -ne $null) 
{
    $data | Out-JsonFile -path $data.Path
} else {
    .\Core\FileOperations\Save-As-File.ps1 -data $data
}

$data