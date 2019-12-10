 param (
    [Parameter(ValueFromPipeline = $true)]$data
 )

# inicializace builderu
Initialize-Builder

# generated
Get-GenerateLine $data


# usingy
Add-Line('@model {0}.Controllers.{1}.{2}{3}{3}{4}FilterModel' -f $data.Metadata.AppNamespace, $data.Metadata.Modules, $data.Metadata.PluralName, (('.'+$data.Metadata.Prefix),'')[$data.Metadata.OperationType -eq 'BLANK'], $data.Metadata.Name)

# TODO sloupce

# vypisu builder do hostu
Out-Builder
