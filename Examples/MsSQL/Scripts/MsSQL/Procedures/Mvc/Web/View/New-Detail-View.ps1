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
Add-Line('  ViewBag.Title = $"{{Model.DisplayName}}";' -f $data.Metadata.Modules, $data.Metadata.PluralName,$data.Metadata.Prefix, $data.Metadata.Name, $data.Metadata.ProcedureDescription, $data.Metadata.AppNamespace)
Add-Line('}');
Add-Line('')

# navbar
Add-Line('<div class="app-title">')
Add-Line('  <div>')
Add-Line('    <h1><i class="fa fa-money"></i> Detail záznamu</h1>')
Add-Line('    <p>Všechny podrobnosti o daném záznamu</p>')
Add-Line('  </div>')
Add-Line('  <ul class="app-breadcrumb breadcrumb">')
Add-Line('    <li class="breadcrumb-item"><a href="@Url.Action("Index", "Home")"><i class="fa fa-home fa-lg"></i></a></li>')
Add-Line('    <li class="breadcrumb-item">@Html.ActionLink("Přehled", "Index")</li>')
Add-Line('    <li class="breadcrumb-item"><a href="@Url.Action()">Detail záznamu</a></li>')
Add-Line('  </ul>')
Add-Line('</div>')

Add-Line('')
Add-Line('@Html.ValidationSummary(true, "", new { @class = "text-danger" })')
Add-Line('')
# form


## header


## content

### tile BasicInfo

Add-Line('<div class="row">')
Add-Line('  <div class="col-md-12">')

## navigace

Add-Line('    <ul class="nav nav-tabs">')
Add-Line('      @if (Html.HasAction("{0}"))' -f $data.Metadata.ProcedureName)
Add-Line('      {')
Add-Line('          <li class="nav-item">')
Add-Line('            @Html.ActionLink("Detail", "Detail", new { id = Url.RequestContext.RouteData.Values["id"] }, htmlAttributes: new { @class = "nav-link active" })')
Add-Line('          </li>')
Add-Line('      }')
Add-Line('      @if (Html.HasAction("CR_EntityLog_ALL_{0}_{1}"))' -f $data.Metadata.Table, $data.Metadata.ProcedureName.SubString(0,2))  # CR_EntityLog_ALL_Currency_CB"))
Add-Line('      {')
Add-Line('          <li class="nav-item">')
Add-Line('            @Html.ActionLink("Historie", "History", new { id = Url.RequestContext.RouteData.Values["id"] }, htmlAttributes: new { @class = "nav-link" })')
Add-Line('          </li>')
Add-Line('      }')
Add-Line('    </ul>')

## end-navigace

Add-Line('    @using (Html.BeginForm())')
Add-Line('    {')
Add-Line('      <div class="tile">')

### tile-header

Add-Line('        <div class="tile-title line-head">')
Add-Line('          <h3>@ViewBag.Title</h3>')
Add-Line('        </div>')

### end-tile-header

### tile-body

Add-Line('        <div class="tile-body">')
Add-Line('')

### tile-content

Add-Line('          @Html.AntiForgeryToken()')
Add-Line('          @Html.HiddenFor(model => model.Id)')
Add-Line('          <div class="row">')
Add-Line('')

#sloupce
$columns = $data.OutputColumns.GetEnumerator()
foreach ($column in $columns)
{  
    $reqClass = ('',' is-required is-required--u')[$column.Value.IsRequired] 

    if ($column.Value.Name -in ('ID_Login', 'IsActive')) {
        continue;
    }

    if ($column.Value.Name.StartsWith('ID', "CurrentCultureIgnoreCase")) { 
        continue;
    }
    
    if ($columns.Value.Type -eq 'bool') {
        # checkbox
        Add-Line('            <div class="form-group row col-md-6{0}">' -f $reqClass)
        Add-Line('              <div class="offset-4 col-md-8 animated-checkbox">')
        Add-Line('                @Html.CheckBoxFor(model => model.{0}, htmlAttributes: new {{ }})' -f $column.Value.Name)
        Add-Line('                @Html.LabelFor(model => model.{0}, htmlAttributes: new {{ @class = "label-text" }})' -f $column.Value.Name)
        Add-Line('              </div>')
        Add-Line('            </div>')
}
    else {
        # editor
        Add-Line('            <div class="form-group row col-md-6{0}">' -f $reqClass)
        Add-Line('              @Html.LabelFor(model => model.{0}, htmlAttributes: new {{ @class = "col-form-label col-md-4" }})' -f $column.Value.Name)
        Add-Line('              <div class="col-md-8">')
        Add-Line('                @Html.EditorFor(model => model.{0}, new {{ htmlAttributes = new {{ @class = "form-control-plaintext font-weight-bold", @readonly = "" }} }})' -f $column.Value.Name)
        Add-Line('                @Html.ValidationMessageFor(model => model.{0}, "", new {{ @class = "" }})' -f $column.Value.Name)
        Add-Line('              </div>')
        Add-Line('            </div>')
        Add-Line('')
    }
    
}

### end-tile-content

Add-Line('')
Add-Line('          </div>')
Add-Line('        </div>')

Add-Line('')
### end-tile-body

## end-content

## tile-footer

Add-Line('')


Add-Line('        <div class="tile-footer">')

Add-Line('        @if (Html.HasAction("{0}"))' -f $data.Metadata.ProcedureName.Replace($data.Metadata.OperationType, "EDIT"))
Add-Line('        {')
Add-Line('          @Html.ActionLink({0}.Resources.Dictionary.Global_Button_Edit, "Edit", routeValues: new {{ id = Model.Id }}, htmlAttributes: new {{ @class = "btn btn-primary" }})'-f $data.Metadata.AppNamespace)
Add-Line('        }')
Add-Line('        @if (Html.HasAction("{0}"))' -f $data.Metadata.ProcedureName.Replace($data.Metadata.OperationType, "DEL"))
Add-Line('        {')
Add-Line('          @Html.ActionLink({0}.Resources.Dictionary.Global_Button_Delete, "Delete", routeValues: new {{ id = Model.Id }}, htmlAttributes: new {{ @class = "btn btn-danger" }})' -f $data.Metadata.AppNamespace)
Add-Line('        }')

Add-Line('          <a class="btn btn-secondary" href="@Url.Action("Index")"><i class="fa fa-fw fa-lg fa-times-circle"></i>Zpět</a>')
Add-Line('        </div>')


## end-tile-footer

Add-Line('      </div>')

Add-Line('    }')
Add-Line('  </div>')
Add-Line('</div>')

# vypisu builder do hostu
Out-Builder