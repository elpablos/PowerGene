param (
    [Parameter(ValueFromPipeline = $true)]$data = $null
)

$projectName = $data.Metadata.ProjectName
$appNamespace = $data.Metadata.AppNamespace

$path = (get-item (Get-Location)).parent.fullname

$installFolderPath = Join-Path "c:\Instalace\" -ChildPath $projectName
$installFolderPath = Join-Path $installFolderPath -ChildPath (Get-Date).tostring(“yyyy-MM-dd”) 

function EditPublishFile($profileXmlFile, $profileInstallDir) {
    [xml]$profileXml = Get-Content $profileXmlFile
    $profileXml.Project.PropertyGroup.publishUrl = $profileInstallDir.ToString()
    $profileXml.Save($profileXmlFile)
}

# import modulu pro MsBuild
If (!(Get-module Invoke-MsBuild)) {
    Import-Module .\Scripts\modules\Invoke-MsBuild\Invoke-MsBuild.psm1
}

# promenne
$csprojFile = $null # cesty k csproj souboru
$profileFile = $null # cesty k profilu
$buildParams = $null # parametry
$publishFolder = $null # cesta k publish slozce

# CLEAR
if (Test-Path -path $installFolderPath) {
    Remove-Item –path $installFolderPath -Recurse -Force
}

## WEB
$part = "Web"
# editace publish XML a zalozeni publish slozky
$publishFolder = (Join-Path -Path $installFolderPath -ChildPath $part)
New-Item -ItemType Directory -Force -Path $publishFolder
$profileFile = Join-Path -Path $path -ChildPath ("{0}\Properties\PublishProfiles\{1}{2}.pubxml" -f $appNamespace, $projectName, $part)
EditPublishFile $profileFile $publishFolder

# cesta k csproj
$csprojFile = Join-Path -Path $path -ChildPath ("{0}\{0}.csproj" -f $appNamespace)
# sestaveni parametru pro build
$buildParams = "/p:DeployOnBuild=true /p:PublishProfile=""{0}"" /property:Configuration=Release" -f $profileFile

$build = (Invoke-MsBuild -Path $csprojFile -MsBuildParameters "$buildParams" -ShowBuildOutputInCurrentWindow -KeepBuildLogOnSuccessfulBuilds -AutoLaunchBuildErrorsLogOnFailure)
if ($build.BuildSucceeded -eq $true) {
    Write-Output "Build webu proběhl v pořádku."
}

# upravit koncovky u configu na *.clear
Get-ChildItem -Path $publishFolder -Filter *.config | Rename-Item -NewName { $_.name -Replace '\.config$','.config.clear' } -Force

## end - WEB

## DB

$publishFolder = (Join-Path -Path $installFolderPath -ChildPath "Db")
New-Item -ItemType Directory -Force -Path $publishFolder

## TODO call DB generator!

Copy-Item -Path "$path\Db\*.sql" -Destination "$publishFolder"

## end - DB

## ZIP

$zipFile = "{0}\{1}.zip" -f $installFolderPath, ((Get-Item $installFolderPath).Name)
Compress-Archive -Path "$installFolderPath*" -DestinationPath "$zipFile"

## end - ZIP

## Open
Invoke-Item $installFolderPath