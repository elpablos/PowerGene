param (
    [Parameter(ValueFromPipeline = $true)]$data = $null
)

If (!(Get-module Powergene)) {
    Import-Module .\Scripts\modules\Powergene\Powergene.psm1
}


$id = ($data.ProcessItem.GetEnumerator() | select -first 1).Value["Id"]
Get-Process -Id $id | Out-GridView


$data