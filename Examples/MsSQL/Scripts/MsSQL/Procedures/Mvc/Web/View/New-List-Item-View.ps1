 param (
    [Parameter(ValueFromPipeline = $true)]$data
 )

# inicializace builderu
Initialize-Builder

# generated
Get-GenerateLine $data

# usingy
Add-Line('@model IEnumerable<{0}.Controllers.{1}.{2}{3}{3}{4}ItemModel>' -f $data.Metadata.AppNamespace, $data.Metadata.Modules, $data.Metadata.PluralName, (('.'+$data.Metadata.Prefix),'')[$data.Metadata.OperationType -eq 'BLANK'], $data.Metadata.Name)

#table

Add-Line('')
Add-Line('<table class="table table-hover table-bordered data-table responsive" width="100%">')
Add-Line('    <thead>')
Add-Line('    <tr>')

##table-header
$columns = $data.OutputColumns.GetEnumerator()
$counter = 0
foreach ($column in $columns)
{  
    if ($column.Value.Name -in ('ID_Login', 'IsActive')) {
        continue;
    }

    if ($column.Value.Name.StartsWith('ID', "CurrentCultureIgnoreCase")) { 
        continue;
    }

    Add-Line('            <th>')
    Add-Line('                @Html.DisplayNameFor(model => model.{0})' -f $column.Value.Name)
    Add-Line('            </th>')

    $counter=$counter+1
}
Add-Line('        </tr>')
Add-Line('    </thead>')

##columns
Add-Line('    <tbody>')
Add-Line('        @foreach (var item in Model)')
Add-Line('        {')
Add-Line('             <tr>')


$columns = $data.OutputColumns.GetEnumerator()
foreach ($column in $columns)
{  
    if ($column.Value.Name -in ('ID_Login', 'IsActive')) {
        continue;
    }

    if ($column.Value.Name.StartsWith('ID', "CurrentCultureIgnoreCase")) { 
        continue;
    }

    if ($column.Value.Name -eq 'DisplayName') {
        Add-Line('                <td>')
        Add-Line('                    @Html.ActionLink(item.{0}, "Detail", new {{ id = item.Id }})' -f $column.Value.Name)
        Add-Line('                </td>')

    } else {
        Add-Line('                <td>')
        Add-Line('                    @Html.DisplayFor(modelItem => item.{0})' -f $column.Value.Name)
        Add-Line('                </td>')
    }
}

#end-table-body
Add-Line('            </tr>')
Add-Line('        }')
Add-Line('    </tbody>')
Add-Line('</table>')

# vypisu builder do hostu
Out-Builder
