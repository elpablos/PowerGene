param (
    [Parameter(ValueFromPipeline = $true)]$data = $null
)

Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.SaveFileDialog -Property @{ 
    InitialDirectory = Get-Location # [Environment]::GetFolderPath('Desktop') 
    Filter = 'PowerGene (*.pwgen)|*.pwgen'
    Title = 'Pick file to save'
}
if ($FileBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) 
{
    $filePath = $FileBrowser.FileName
    $data | Out-JsonFile -path $filePath 
}

$data