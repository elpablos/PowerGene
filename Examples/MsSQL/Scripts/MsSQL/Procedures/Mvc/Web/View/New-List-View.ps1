param (
    [Parameter(ValueFromPipeline = $true)]$data
)

# inicializace builderu
Initialize-Builder

# generated
Get-GenerateLine $data


# usingy
Add-Line('@model {0}.Modules.{1}.{2}{3}{3}{4}Model' -f $data.Metadata.AppNamespace, $data.Metadata.Modules, $data.Metadata.PluralName, (('.'+$data.Metadata.Prefix),'')[$data.Metadata.OperationType -eq 'BLANK'], $data.Metadata.Name)
Add-Line('@{')
Add-Line('  ViewBag.Title = {5}.Resources.Dictionary.{0}_{1}; // {4}' -f $data.Metadata.Modules, $data.Metadata.PluralName,$data.Metadata.Prefix, $data.Metadata.Name, $data.Metadata.ProcedureDescription, $data.Metadata.AppNamespace)
Add-Line('}');
Add-Line('')

# navbar
Add-Line('<nav class="navbar">')
Add-Line('  <div class="container">')
Add-Line('    @if (Html.HasAction("{0}"))' -f $data.Metadata.ProcedureName)
Add-Line('    {')
Add-Line('      <p class="navbar__btn-icon">')
Add-Line('        <a href="@Url.Action("Create")" class="btn-icon btn-icon--lg p-0">')
Add-Line('          <span class="icon-svg icon-svg--plus-circle ">')
Add-Line('            <svg class="icon-svg__svg" xmlns:xlink="http://www.w3.org/1999/xlink">')
Add-Line('              <use xlink:href="@Url.Content("~/img/bg/icons-svg.svg#icon-plus-circle")" x="0" y="0" width="100%" height="100%"></use>')
Add-Line('            </svg>')
Add-Line('          </span>')
Add-Line('')
Add-Line('          <span class="sr-only">@{0}.Resources.Dictionary.Global_Button_Add</span>' -f $data.Metadata.AppNamespace)
Add-Line('        </a>')
Add-Line('      </p>')
Add-Line('    }')
Add-Line('')
Add-Line('    <ul class="nav nav-tabs" role="tablist">')
Add-Line('      <li>')
Add-Line('        @Html.ActionLink({4}.Resources.Dictionary.{0}_{1}, "{3}", "{2}", null, htmlAttributes: new {{ @class = "nav-link active" }})' -f $data.Metadata.Modules, $data.Metadata.PluralName, $data.Metadata.Name, $data.Metadata.PrefixExtend, $data.Metadata.AppNamespace)
Add-Line('      </li>')
Add-Line('    </ul>')
Add-Line('  </div>')
Add-Line('</nav>')

# container
Add-Line('  <div class="container">')
Add-Line('    <div class="tab-content">')
Add-Line('      <div class="tab-pane active" id="detail" role="tabpanel">')
Add-Line('')

## data-table

Add-Line('      <div class="dataTables" @Html.DataTableColumnSetup("{1}{0}")>' -f $data.Metadata.Name, $data.Metadata.Prefix)
Add-Line('        <div class="row align-items-center">')
Add-Line('          <div class="col-12 col-md-6">')
Add-Line('            <h1 class="h2 mb-2 mb-md-0">@{2}.Resources.Dictionary.{0}_{1}</h1>' -f $data.Metadata.Modules, $data.Metadata.PluralName, $data.Metadata.AppNamespace)
Add-Line('          </div>')
Add-Line('          <div class="col-12 col-md-6 d-none d-md-block">')
Add-Line('            @Html.Partial("_DataTableExport")')
Add-Line('          </div>')
Add-Line('        </div>')
Add-Line('')
Add-Line('        @using (Html.BeginForm("{1}", "{0}", FormMethod.Post, htmlAttributes: new {{ @class = "alphabet-form" }}))' -f $data.Metadata.Name, $data.Metadata.PrefixExtend)
Add-Line('        {')
Add-Line('          @Html.Partial("~/Views/Shared/_AlphabetContext.cshtml", Model.Filter.Alphabet.Items)')
Add-Line('        }')
Add-Line('')
Add-Line('        <form class="dataTables_prefered">')
Add-Line('          <div class="row align-items-center">')
Add-Line('            <div class="col-12 col-md-12">')
Add-Line('              @Html.Partial("_{0}Filter", Model.Filter)' -f $data.Metadata.PrefixExtend)
Add-Line('            </div>')
Add-Line('')
Add-Line('          </div>')
Add-Line('          @Html.Partial("_{0}Items", Model.Items)' -f $data.Metadata.PrefixExtend)
Add-Line('        </form>')
Add-Line('      </div>')

## end-data-table

Add-Line('      </div>')
Add-Line('    </div>')
Add-Line('  </div>')

# vypisu builder do hostu
Out-Builder