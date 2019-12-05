param (
    [Parameter(ValueFromPipeline = $true)]$data
)

# inicializace builderu
Initialize-Builder

# generated
Get-GenerateLine $data

# usingy
Add-Line('@model {0}.Modules.{1}.{2}{3}{3}{4}FilterModel' -f $data.Metadata.AppNamespace, $data.Metadata.Modules, $data.Metadata.PluralName, (('.'+$data.Metadata.Prefix),'')[$data.Metadata.OperationType -eq 'BLANK'], $data.Metadata.Name)

Add-Line('<div class="dataTables_filter">')
Add-Line('  <div class="row align-items-center">')
Add-Line('    <div class="col-12 col-md-auto order-1 order-md-0 mr-md-2 dataTables_filter-search">')
Add-Line('      <div class="form-group btn-group">')
Add-Line('        <label for="filter-search" class="sr-only">@{0}.Resources.Dictionary.Global_Filter_Search</label>' -f $data.Metadata.AppNamespace)
Add-Line('        <input type="text" class="form-control js-tooltip" id="filter-search" placeholder="@{0}.Resources.Dictionary.Global_Filter_Search" ' -f $data.Metadata.AppNamespace)
Add-Line('               data-html="true" data-close-btn="true" title="@{0}.Resources.Dictionary.Global_Filter_Search_Tooltip">' -f $data.Metadata.AppNamespace)
Add-Line('        <span class="ml-2px">')
Add-Line('          <button class="btn btn-primary">')
Add-Line('            <span class="icon-svg icon-svg--search ">')
Add-Line('              <svg class="icon-svg__svg" xmlns:xlink="http://www.w3.org/1999/xlink">')
Add-Line('                <use xlink:href="@Url.Content("~/img/bg/icons-svg.svg#icon-search")" x="0" y="0" width="100%" height="100%"></use>')
Add-Line('              </svg>')
Add-Line('            </span>')
Add-Line('')
Add-Line('            <span class="sr-only">@{0}.Resources.Dictionary.Global_Filter_Search</span>' -f $data.Metadata.AppNamespace)
Add-Line('          </button>')
Add-Line('        </span>')
Add-Line('      </div>')
Add-Line('    </div>')

# TODO sloupce

Add-Line('')
Add-Line('  </div>')
Add-Line('</div>')

# vypisu builder do hostu
Out-Builder