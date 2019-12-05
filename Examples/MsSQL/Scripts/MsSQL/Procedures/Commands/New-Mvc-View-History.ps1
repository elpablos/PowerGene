param (
    [Parameter(ValueFromPipeline = $true)]$data = $null
)

.\Scripts\MsSQL\Procedures\Generator\New-Data-Generator.ps1 $data

$path = $data.Metadata.Path
if ($path -eq $null){
    $path = $env:temp
} else {
    New-Item -ItemType Directory -Force -Path $path | Out-Null
}

$obj = $data.TempData[$data.TempData.Keys[0]]
$obj.Metadata.ProjectName = $data.Metadata.ProjectName
$obj.Metadata.AppNamespace = $data.Metadata.AppNamespace
$obj.Metadata.CoreNamespace = $data.Metadata.CoreNamespace
$obj.Metadata.ContextNamespace = $data.Metadata.ContextNamespace
$obj.Metadata.UseGenerated = $data.Metadata.UseGenerated

# Views directory
$path = Join-Path -Path $path -ChildPath $('{0}/Views/{1}' -f  $data.Metadata.AppNamespace, $obj.Metadata.Name)
New-Item -ItemType Directory -Force -Path $path | Out-Null

# history
$filepath = Join-Path -Path $path -ChildPath $('History.cshtml' -f $obj.Metadata.Prefix)
.\Scripts\MsSQL\Procedures\Mvc\Web\View\New-History-View.ps1 $obj | Out-File $filepath

# and run
Start-EditorProcess $filepath

# PartialMenu
$filepath = Join-Path -Path $path -ChildPath $('_PartialMenu{0}.cshtml' -f $obj.Metadata.Name)
.\Scripts\MsSQL\Procedures\Mvc\Web\View\New-PartialMenu-View.ps1 $obj | Out-File $filepath

# and run
Start-EditorProcess $filepath

$data
