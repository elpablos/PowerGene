param (
    [Parameter(ValueFromPipeline = $true)]$data = $null
)

.\Scripts\MsSQL\Procedures\Generator\New-Data-Generator.ps1 $data

$path = $data.Metadata.Path
if ($path -eq $null){
    $path = $env:temp
} else {
    New-Item -ItemType Directory -Force -Path $path
}

$obj = $data.TempData[$data.TempData.Keys[0]]
$obj.Metadata.ProjectName = $data.Metadata.ProjectName
$obj.Metadata.AppNamespace = $data.Metadata.AppNamespace
$obj.Metadata.CoreNamespace = $data.Metadata.CoreNamespace
$obj.Metadata.ContextNamespace = $data.Metadata.ContextNamespace$obj.Metadata.UseGenerated = $data.Metadata.UseGenerated

$path = Join-Path -Path $path -ChildPath $('{0}/Domains/Services/{1}/{2}/{3}' -f  $data.Metadata.CoreNamespace, $obj.Metadata.Modules, $obj.Metadata.PluralName, $obj.Metadata.Prefix)
New-Item -ItemType Directory -Force -Path $path

## input model
$filepath = Join-Path -Path $path -ChildPath $('{1}{0}InputModel.cs' -f $obj.Metadata.Name, $obj.Metadata.Prefix, $obj.Metadata)
.\Scripts\MsSQL\Procedures\Mvc\Core\Common\New-Input-Model.ps1 $obj | Out-File $filepath


# and run
Start-EditorProcess $filepath

## output model
$filepath = Join-Path -Path $path -ChildPath $('{1}{0}OutputModel.cs' -f $obj.Metadata.Name, $obj.Metadata.Prefix, $obj.Metadata)
.\Scripts\MsSQL\Procedures\Mvc\Core\Common\New-Output-Model.ps1 $obj | Out-File $filepath

# and run
Start-EditorProcess $filepath

## IService
$filepath = Join-Path -Path $path -ChildPath $('I{1}{0}Service.cs' -f $obj.Metadata.Name, $obj.Metadata.Prefix, $obj.Metadata)
.\Scripts\MsSQL\Procedures\Mvc\Core\Services\New-Service-Interface.ps1 $obj | Out-File $filepath


# and run 
Start-EditorProcess $filepath

## Service
$filepath = Join-Path -Path $path -ChildPath $('{1}{0}Service.cs' -f $obj.Metadata.Name, $obj.Metadata.Prefix, $obj.Metadata)
.\Scripts\MsSQL\Procedures\Mvc\Core\Services\New-Service.ps1 $obj | Out-File $filepath

# and run
Start-EditorProcess $filepath

$data
