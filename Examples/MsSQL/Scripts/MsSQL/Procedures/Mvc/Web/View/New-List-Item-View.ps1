param (
    [Parameter(ValueFromPipeline = $true)]$data
)

# inicializace builderu
Initialize-Builder

# generated
Get-GenerateLine $data


# usingy
Add-Line('@model IEnumerable<{0}.Modules.{1}.{2}{3}{3}{4}ItemModel>' -f $data.Metadata.AppNamespace, $data.Metadata.Modules, $data.Metadata.PluralName, (('.'+$data.Metadata.Prefix),'')[$data.Metadata.OperationType -eq 'BLANK'], $data.Metadata.Name)

#table

Add-Line('<table class="table table-striped js-datatable" id="{0}_overview">' -f ($data.Metadata.PrefixExtend.ToLower(), $data.Metadata.PluralName.ToLower())[$data.Metadata.PrefixExtend -eq 'Index'])
Add-Line('  <thead>')
Add-Line('    <tr>')
Add-Line('      <th class="pl-1 pr-0 no-sort"></th>')


#table-header

#sloupce
$columns = $data.OutputColumns.GetEnumerator()
$counter = 0
foreach ($column in $columns)
{  
    if ($column.Value.Name.StartsWith('ID', "CurrentCultureIgnoreCase")) { 
        continue;
    }

    Add-Line('      <th{0}>' -f ('', ' class="border-0 sorting"')[$counter -eq 0])
    Add-Line('        @Html.DisplayNameFor(model => model.{0})' -f $column.Value.Name)
    Add-Line('      </th>')

    $counter=$counter+1
}

## toogle columns

Add-Line('      <th class="text-right text-nowrap pr-1 border-0 no-sort no-export sorting-disabled">')
Add-Line('        <div class="dropdown">')
Add-Line('          <button class="dropdown-toggle dropdown-toggle--icon" type="button" id="toggle-columns" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">')
Add-Line('            <span class="dropdown-label">')
Add-Line('              <span class="btn-icon p-0 text-gray-dimmed">')
Add-Line('                <span class="icon-svg icon-svg--plus-circle ">')
Add-Line('                  <svg class="icon-svg__svg" xmlns:xlink="http://www.w3.org/1999/xlink">')
Add-Line('                    <use xlink:href="@Url.Content("~/img/bg/icons-svg.svg#icon-plus-circle")" x="0" y="0" width="100%" height="100%"></use>')
Add-Line('                  </svg>')
Add-Line('                </span>')
Add-Line('')
Add-Line('              </span>')
Add-Line('              <span class="sr-only">@{0}.Resources.Dictionary.Core_Columns</span>' -f $data.Metadata.AppNamespace)
Add-Line('            </span>')
Add-Line('          </button>')
Add-Line('          <div class="dropdown-menu dropdown-menu--detached" aria-labelledby="toggle-columns">')
Add-Line('            <div class="dropdown-label" data-close="toggle-columns">')
Add-Line('              @{0}.Resources.Dictionary.Core_Columns' -f $data.Metadata.AppNamespace)
Add-Line('            </div>')
Add-Line('')

$columns = $data.OutputColumns.GetEnumerator()
$counter = 1
foreach ($column in $columns)
{  
    if ($column.Value.Name.StartsWith('ID', "CurrentCultureIgnoreCase")) { 
        continue;
    }

    Add-Line('            <a class="dropdown-item dropdown-item--icon-r" href="#" @Html.DataTableToggleColumn({0})>' -f $counter)
    Add-Line('              @{3}.Resources.Dictionary.{0}_{1}_{2}' -f $data.Metadata.Modules, $data.Metadata.PluralName, $columns.Value.Name, $data.Metadata.AppNamespace)
    Add-Line('              <span class="btn-icon btn-icon--visibility p-0">')
    Add-Line('                <span class="icon-svg icon-svg--visibility-on ">')
    Add-Line('                  <svg class="icon-svg__svg" xmlns:xlink="http://www.w3.org/1999/xlink">')
    Add-Line('                    <use xlink:href="@Url.Content("~/img/bg/icons-svg.svg#icon-visibility-on")" x="0" y="0" width="100%" height="100%"></use>')
    Add-Line('                  </svg>')
    Add-Line('                </span>')
    Add-Line('                <span class="icon-svg icon-svg--visibility-off ">')
    Add-Line('                  <svg class="icon-svg__svg" xmlns:xlink="http://www.w3.org/1999/xlink">')
    Add-Line('                    <use xlink:href="@Url.Content("~/img/bg/icons-svg.svg#icon-visibility-off")" x="0" y="0" width="100%" height="100%"></use>')
    Add-Line('                  </svg>')
    Add-Line('                </span>')
    Add-Line('              </span>')
    Add-Line('            </a>')
    Add-Line('')

    $counter=$counter+1

}
Add-Line('')
Add-Line('          </div>')
Add-Line('        </div>')
Add-Line('      </th>')

## end-toogle-columns

#end-table-header

Add-Line('    </tr>')
Add-Line('  </thead>')
Add-Line('  <tbody>')
Add-Line('    @foreach (var item in Model)')
Add-Line('    {')
Add-Line('    <tr>')
Add-Line('      <td class="pl-1 pr-0">')
Add-Line('        @*<div class="form-check form-check--standalone">')
Add-Line('          <input type="checkbox" class="form-check-input" id="check-01-1">')
Add-Line('          <label class="form-check-label" for="check-01-1">')
Add-Line('              <span class="sr-only">@{0}.Resources.Dictionary.Global_Filter_Select</span>' -f $data.Metadata.AppNamespace)
Add-Line('          </label>')
Add-Line('      </div>*@')
Add-Line('      </td>')

#table-body

#sloupce
$columns = $data.OutputColumns.GetEnumerator()
foreach ($column in $columns)
{  
    if ($column.Value.Name.StartsWith('ID', "CurrentCultureIgnoreCase")) { 
        continue;
    }

    if ($column.Value.Name -eq 'DisplayName') {
        Add-Line('      <td  class="text-nowrap">')
        Add-Line('        <span class="align-middle">@Html.ActionLink(item.{0}, "Edit", new {{ id = item.Id }}, htmlAttributes: new {{ }})</span>' -f $column.Value.Name)
        Add-Line('      </td>')

    } else {
        Add-Line('      <td>')
        Add-Line('        @Html.DisplayFor(modelItem => item.{0})' -f $column.Value.Name)
        Add-Line('      </td>')
    }
}

#end-table-body

Add-Line('      <td></td>')
Add-Line('    </tr>')
Add-Line('    }')
Add-Line('  </tbody>')
Add-Line('</table>')

# vypisu builder do hostu
Out-Builder