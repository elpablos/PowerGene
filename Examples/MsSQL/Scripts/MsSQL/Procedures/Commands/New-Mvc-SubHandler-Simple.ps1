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

$path = Join-Path -Path $path -ChildPath $('{0}/Modules/{1}/{2}/{3}/{4}' -f  $data.Metadata.AppNamespace, $obj.Metadata.Modules, $obj.Metadata.PluralName, $obj.Metadata.TableRelation, $obj.Metadata.PrefixType)
New-Item -ItemType Directory -Force -Path $path | Out-Null

## Controller
$filepath = Join-Path -Path $path -ChildPath $('{1}{0}Controller.cs' -f $obj.Metadata.Name, $obj.Metadata.Prefix, $obj.Metadata)
.\Scripts\MsSQL\Procedures\Mvc\Web\Controller\New-Sub-Controller.ps1 $obj | Out-File $filepath

# and run
Start-EditorProcess $filepath

# Model
$filepath = Join-Path -Path $path -ChildPath $('{1}{0}Model.cs' -f $obj.Metadata.Name, $obj.Metadata.Prefix, $obj.Metadata)
.\Scripts\MsSQL\Procedures\Mvc\Web\Model\New-Sub-Model.ps1 $obj | Out-File $filepath

# and run
Start-EditorProcess $filepath

# Handler
$filepath = Join-Path -Path $path -ChildPath $('{1}{0}Handler.cs' -f $obj.Metadata.Name, $obj.Metadata.Prefix, $obj.Metadata)
.\Scripts\MsSQL\Procedures\Mvc\Web\Handler\New-Sub-Handler-Simple.ps1 $obj | Out-File $filepath

# and run
Start-EditorProcess $filepath

$data
