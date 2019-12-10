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
Add-Line('  ViewBag.Title = $"Editace #{{Model.Id}}";' -f $data.Metadata.Modules, $data.Metadata.PluralName,$data.Metadata.Prefix, $data.Metadata.Name, $data.Metadata.ProcedureDescription, $data.Metadata.AppNamespace)
Add-Line('}');
Add-Line('')

# navbar
Add-Line('<div class="app-title">')
Add-Line('  <div>')
Add-Line('    <h1><i class="fa fa-money"></i> �prava z�znamu</h1>')
Add-Line('    <p>V�echny podrobnosti o dan�n z�znamu</p>')
Add-Line('  </div>')
Add-Line('  <ul class="app-breadcrumb breadcrumb">')
Add-Line('    <li class="breadcrumb-item"><a href="@Url.Action("Index", "Home")"><i class="fa fa-home fa-lg"></i></a></li>')
Add-Line('    <li class="breadcrumb-item">@Html.ActionLink("P�ehled", "Index")</li>')
Add-Line('    <li class="breadcrumb-item"><a href="@Url.Action()">�prava z�znamu</a></li>')
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
Add-Line('            @Html.ActionLink({0}.Resources.Dictionary.Global_Button_Edit, "Edit", new {{ id = Url.RequestContext.RouteData.Values["id"] }}, htmlAttributes: new {{ @class = "nav-link active" }})' -f $data.Metadata.AppNamespace)
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
$columns = $data.InputColumns.GetEnumerator()
foreach ($column in $columns)
{  
    $reqClass = ('',' is-required is-required--u')[$column.Value.IsRequired] 

    if ($column.Value.Name -in ('ID_Login', 'ID')) {
        continue;
    }

    if ($column.Value.IsFk -eq $true) {
        # dropdownlist
        Add-Line('            <div class="form-group row col-md-6{0}">'-f $reqClass)
        Add-Line('              @Html.LabelFor(model => model.{0}, htmlAttributes: new {{ @class = "col-form-label col-md-4" }})' -f $column.Value.Name)
        Add-Line('              <div class="col-md-8">')
        Add-Line('                @Html.DropDownListFor(model => model.{0}, Model.{1}, {2}.Resources.Dictionary.Global_Filter_NotUsed, htmlAttributes: new {{ @class = "form-control" }})' -f $column.Value.Name, $column.Value.ListName, $data.Metadata.AppNamespace)
        Add-Line('                @Html.ValidationMessageFor(model => model.{0}, "", new {{ @class = "" }})' -f $column.Value.Name)

        Add-Line('              </div>')
        Add-Line('            </div>')
        Add-Line('')
    } elseif ($columns.Value.Name -eq 'Description') {
        # textboxarea
        Add-Line('            <div class="form-group row col-md-6{0}">' -f $reqClass)
        Add-Line('              @Html.LabelFor(model => model.{0}, htmlAttributes: new {{ @class = "col-form-label col-md-4" }})' -f $column.Value.Name)
        Add-Line('              <div class="col-md-8">')
        Add-Line('                @Html.TextAreaFor(model => model.{0}, htmlAttributes: new {{ @class = "form-control" }})' -f $column.Value.Name)
        Add-Line('                @Html.ValidationMessageFor(model => model.{0}, "", new {{ @class = "" }})' -f $column.Value.Name)
        Add-Line('              </div>')
        Add-Line('            </div>')
        Add-Line('')
    } elseif ($columns.Value.Type -eq 'DateTime') {
        # editor
        Add-Line('            <div class="form-group row col-md-6{0}">' -f $reqClass)
        Add-Line('              @Html.LabelFor(model => model.{0}, htmlAttributes: new {{ @class = "col-form-label col-md-4" }})' -f $column.Value.Name)
        Add-Line('              <div class="col-md-8">')
        Add-Line('                <div class="input-group date">')
        Add-Line('                  @Html.EditorFor(model => model.{0}, new {{ htmlAttributes = new {{ @class = "form-control js-datepicker" }} }})' -f $column.Value.Name)
        Add-Line('                  <div class="input-group-addon"><span class="glyphicon glyphicon-th"></span></div>')
        Add-Line('                  <div class="input-group-append"><span class="input-group-text"><i class="fa fa-calendar" aria-hidden="true"></i></span></div>')
        Add-Line('                </div>')
        Add-Line('                @Html.ValidationMessageFor(model => model.{0}, "", new {{ @class = "" }})' -f $column.Value.Name)
        Add-Line('              </div>')
        Add-Line('            </div>')
        Add-Line('')
    } else {
        # editor
        Add-Line('            <div class="form-group row col-md-6{0}">' -f $reqClass)
        Add-Line('              @Html.LabelFor(model => model.{0}, htmlAttributes: new {{ @class = "col-form-label col-md-4" }})' -f $column.Value.Name)
        Add-Line('              <div class="col-md-8">')
        Add-Line('                @Html.EditorFor(model => model.{0}, new {{ htmlAttributes = new {{ @class = "form-control" }} }})' -f $column.Value.Name)
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
Add-Line('          @if (Html.HasAction("{0}"))' -f $data.Metadata.ProcedureName)
Add-Line('          {')
Add-Line('            <input type="submit" value="@{0}.Resources.Dictionary.Global_Button_Save" class="btn btn-default" />' -f $data.Metadata.AppNamespace)
Add-Line('          }')
Add-Line('          <a class="btn btn-secondary" href="@Url.Action("Detail", routeValues: new { id = Model.Id })"><i class="fa fa-fw fa-lg fa-times-circle"></i>Zp�t</a>')
Add-Line('        </div>')


## end-tile-footer

Add-Line('      </div>')

Add-Line('    }')
Add-Line('  </div>')
Add-Line('</div>')

# vypisu builder do hostu
Out-Builder