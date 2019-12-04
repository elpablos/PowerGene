param (
    [Parameter(ValueFromPipeline = $true)]$data = $null
)

If (!(Get-module Powergene)) {
    Import-Module .\Scripts\modules\Powergene\Powergene.psm1
}

$hash = $null
$hash = @{}

$proc = get-process | Sort-Object -Property name -Unique

foreach($p in $proc)
{
    $hash.add($p.name,[ordered]@{
        Handles = $p.Handles
        DisplayName = $p.Name
        NPM = $p.NPM
        PM = $p.PM
        SI = $p.SI
        Id = $p.Id
    })
}

$data.Items = $hash

#$data | ConvertTo-Json -Depth 5 -Compress # | $dataString #  > "data.json"
$data