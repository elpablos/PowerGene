param (
    [Parameter(ValueFromPipeline = $true)]$data = $null
)

Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = Get-Location # [Environment]::GetFolderPath('Desktop') 
    Filter = 'PowerGene (*.pwgen)|*.pwgen'
    Title = 'Select file to open'
}
if ($FileBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) 
{
    $filePath = $FileBrowser.FileName
    $data = Read-JsonFile -path $filePath
}

$data