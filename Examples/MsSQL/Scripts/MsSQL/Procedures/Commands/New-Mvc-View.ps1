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


## Specific View

if ($obj.Metadata.OperationType -eq 'NEW') {
    # create
    $filepath = Join-Path -Path $path -ChildPath $('{0}.cshtml' -f $obj.Metadata.Prefix)
    .\Scripts\MsSQL\Procedures\Mvc\Web\View\New-Create-View.ps1 $obj | Out-File $filepath
    

} elseif ($obj.Metadata.OperationType -eq 'EDIT') {
    # edit
    $filepath = Join-Path -Path $path -ChildPath $('{0}.cshtml' -f $obj.Metadata.Prefix)
    .\Scripts\MsSQL\Procedures\Mvc\Web\View\New-Edit-View.ps1 $obj | Out-File $filepath
} elseif ($obj.Metadata.OperationType -eq 'DETAIL') {
    # detail
    $filepath = Join-Path -Path $path -ChildPath $('{0}.cshtml' -f $obj.Metadata.Prefix)
    .\Scripts\MsSQL\Procedures\Mvc\Web\View\New-Detail-View.ps1 $obj | Out-File $filepath
} elseif ($obj.Metadata.OperationType -eq 'ALL') {
    # list
    $filepath = Join-Path -Path $path -ChildPath $('{0}.cshtml' -f $obj.Metadata.PrefixExtend)
    .\Scripts\MsSQL\Procedures\Mvc\Web\View\New-List-View.ps1 $obj | Out-File $filepath

    # and run
    Start-Process -filepath "code" -ArgumentList $filepath -Verb runas -WindowStyle Hidden

    # list-filter
    $filepath = Join-Path -Path $path -ChildPath $('_{0}Filter.cshtml' -f $obj.Metadata.PrefixExtend)
    .\Scripts\MsSQL\Procedures\Mvc\Web\View\New-List-Filter-View.ps1 $obj | Out-File $filepath

    # and run
    Start-Process -filepath "code" -ArgumentList $filepath -Verb runas -WindowStyle Hidden
    
    # list-item
    $filepath = Join-Path -Path $path -ChildPath $('_{0}Items.cshtml' -f $obj.Metadata.PrefixExtend)
    .\Scripts\MsSQL\Procedures\Mvc\Web\View\New-List-Item-View.ps1 $obj | Out-File $filepath
}

# and run
Start-EditorProcess $filepath

$data
