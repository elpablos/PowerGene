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

$path = Join-Path -Path $path -ChildPath $('{0}/Modules/{1}/{2}/{3}' -f  $data.Metadata.AppNamespace, $obj.Metadata.Modules, $obj.Metadata.PluralName, $obj.Metadata.Prefix)
New-Item -ItemType Directory -Force -Path $path | Out-Null

# Write-Host $obj.Metadata.OperationType

## Controller
$filepath = Join-Path -Path $path -ChildPath $('{1}{0}Controller.cs' -f $obj.Metadata.Name, $obj.Metadata.Prefix, $obj.Metadata)
.\Scripts\MsSQL\Procedures\Mvc\Web\Controller\New-Controller.ps1 $obj | Out-File $filepath


# and run
Start-EditorProcess $filepath

## Models
if ($obj.Metadata.OperationType -eq 'ALL') {
    # filter
    $filepath = Join-Path -Path $path -ChildPath $('{1}{0}FilterModel.cs' -f $obj.Metadata.Name, $obj.Metadata.Prefix, $obj.Metadata)
    .\Scripts\MsSQL\Procedures\Mvc\Web\Model\New-Filter-Model.ps1 $obj | Out-File $filepath

    # and run
    Start-EditorProcess $filepath

    #Model
    $filepath = Join-Path -Path $path -ChildPath $('{1}{0}Model.cs' -f $obj.Metadata.Name, $obj.Metadata.Prefix, $obj.Metadata)
    .\Scripts\MsSQL\Procedures\Mvc\Web\Model\New-List-Model.ps1 $obj | Out-File $filepath

    # and run
    Start-EditorProcess $filepath

    #itemModel
    $filepath = Join-Path -Path $path -ChildPath $('{1}{0}ItemModel.cs' -f $obj.Metadata.Name, $obj.Metadata.Prefix, $obj.Metadata)
    .\Scripts\MsSQL\Procedures\Mvc\Web\Model\New-List-Item-Model.ps1 $obj | Out-File $filepath
} else {
    #Model
    $filepath = Join-Path -Path $path -ChildPath $('{1}{0}Model.cs' -f $obj.Metadata.Name, $obj.Metadata.Prefix, $obj.Metadata)
   .\Scripts\MsSQL\Procedures\Mvc\Web\Model\New-Model.ps1 $obj | Out-File $filepath
}

# and run
Start-EditorProcess $filepath

## Builder
$filepath = Join-Path -Path $path -ChildPath $('{1}{0}Builder.cs' -f $obj.Metadata.Name, $obj.Metadata.Prefix, $obj.Metadata)
if ($obj.Metadata.OperationType -in ('NEW')) {
    .\Scripts\MsSQL\Procedures\Mvc\Web\Builder\New-Create-Builder.ps1 $obj | Out-File $filepath
} elseif ($obj.Metadata.OperationType -in ('EDIT','DETAIL')) {
    .\Scripts\MsSQL\Procedures\Mvc\Web\Builder\New-Edit-Builder.ps1 $obj | Out-File $filepath
} elseif ($obj.Metadata.OperationType -in ('ALL')) {
    .\Scripts\MsSQL\Procedures\Mvc\Web\Builder\New-List-Builder.ps1 $obj | Out-File $filepath
}

# and run
Start-EditorProcess $filepath

$data
