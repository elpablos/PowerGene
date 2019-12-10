 param (
    [Parameter(ValueFromPipeline = $true)]$data
 )

# inicializace builderu
Initialize-Builder

# generated
Get-GenerateLine $data


# usingy
Add-Line('@model {0}.Controllers.{1}.{2}{3}{3}{4}Model' -f $data.Metadata.AppNamespace, $data.Metadata.Modules, $data.Metadata.PluralName, (('.'+$data.Metadata.Prefix),'')[$data.Metadata.OperationType -eq 'BLANK'], $data.Metadata.Name)
Add-Line('@{')
Add-Line('  ViewBag.Title = {5}.Resources.Dictionary.{0}_{1}_Title; // {4}' -f $data.Metadata.Modules, $data.Metadata.PluralName,$data.Metadata.Prefix, $data.Metadata.Name, $data.Metadata.ProcedureDescription, $data.Metadata.AppNamespace)
Add-Line('}');
Add-Line('')

# navbar
Add-Line('<div class="app-title">')
Add-Line('  <div>')
Add-Line('    <h1><i class="fa fa-money"></i> @ViewBag.Title</h1>')
Add-Line('    <p></p>')
Add-Line('  </div>')
Add-Line('  <ul class="app-breadcrumb breadcrumb">')
Add-Line('    <li class="breadcrumb-item"><a href="@Url.Action("Index", "Home")"><i class="fa fa-home fa-lg"></i></a></li>')
Add-Line('    <li class="breadcrumb-item"><a href="@Url.Action()">@ViewBag.Title</a></li>')
Add-Line('  </ul>')
Add-Line('</div>')
Add-Line('')


# container
Add-Line('<div class="row">')
Add-Line('  <div class="col-md-12">')
Add-Line('    <div class="tile">')
Add-Line('')

## data-table - title
Add-Line('        <div class="tile-title line-head">')
Add-Line('          <h3>@ViewBag.Title</h3>')
Add-Line('        </div>')
Add-Line('')

## datatable
Add-Line('        <div class="tile-body">')
Add-Line('')
Add-Line('          <form class="dataTables_prefered">')
Add-Line('            <div class="row align-items-center">')
Add-Line('              <div class="col-12 col-md-6">')
Add-Line('                @Html.Partial("_IndexFilter", Model.Filter)')
Add-Line('              </div>')
Add-Line('            </div>')
Add-Line('            @Html.Partial("_IndexItems", Model.Items)')
Add-Line('          </form>')
Add-Line('')
Add-Line('        </div>')


## data-table - footer
Add-Line('        <div class="tile-footer">')
Add-Line('          @if (Html.HasAction("{0}"))' -f $data.Metadata.ProcedureName.Replace('ALL','NEW'))
Add-Line('          {')
Add-Line('            @Html.ActionLink({0}.Resources.Dictionary.Global_Button_Create, "Create", null, htmlAttributes: new {{ @class = "btn btn-primary" }})' -f $data.Metadata.AppNamespace)
Add-Line('          }')
Add-Line('        </div>')

# end-container
Add-Line('    </div>')
Add-Line('  </div>')
Add-Line('</div>')

#styles
Add-Line('@section styles {')
Add-Line('  @Styles.Render("~/Content/datatables")')
Add-Line('}')
Add-Line('')
Add-Line('@section scripts {')
Add-Line('  @Scripts.Render("~/bundles/datatables")')
Add-Line('}')

# vypisu builder do hostu
Out-Builder