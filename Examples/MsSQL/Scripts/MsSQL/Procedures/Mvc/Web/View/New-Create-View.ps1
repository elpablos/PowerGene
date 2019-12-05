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
Add-Line('  ViewBag.Title = {5}.Resources.Dictionary.{0}_{1}_{2}{3}; // {4}' -f $data.Metadata.Modules, $data.Metadata.PluralName,$data.Metadata.Prefix, $data.Metadata.Name, $data.Metadata.ProcedureDescription, $data.Metadata.AppNamespace)
Add-Line('}');
Add-Line('')

# navbar
Add-Line('<nav class="navbar">')
Add-Line('  <div class="container">')
Add-Line('    <ul class="nav nav-tabs" role="tablist"></ul>')
Add-Line('  </div>')
Add-Line('</nav>')

# form
Add-Line('@using (Html.BeginForm())')
Add-Line('{')

Add-Line('  <div class="container">')
Add-Line('')
Add-Line('    @Html.AntiForgeryToken()')
Add-Line('    @Html.HiddenFor(model => model.Id)')
Add-Line('')

Add-Line('    <div class="tab-content">')
Add-Line('      <div class="tab-pane active" id="detail" role="tabpanel">')
Add-Line('')

## header

Add-Line('        <div class="row align-items-center">')
Add-Line('          <div class="col-12 col-md-6 mb-20px">')
Add-Line('            <h1 class="h2 mb-0">')
Add-Line('              <a href="@Url.Action("Index", "{0}")" class="no-underline" title="@{1}.Resources.Dictionary.Global_Button_Storno">' -f $data.Metadata.Name, $data.Metadata.AppNamespace)
Add-Line('                <span class="icon-svg icon-svg--angle-l text-primary">')
Add-Line('                  <svg class="icon-svg__svg" xmlns:xlink="http://www.w3.org/1999/xlink">')
Add-Line('                    <use xlink:href="@Url.Content("~/img/bg/icons-svg.svg#icon-angle-l")" x="0" y="0" width="100%" height="100%"></use>')
Add-Line('                  </svg>')
Add-Line('                </span>')
Add-Line('              </a>')
Add-Line('              <span class="h2">@ViewBag.Title</span>')
Add-Line('            </h1>')
Add-Line('          </div>')
Add-Line('          <div class="col-12 col-md-6 mb-20px">')
Add-Line('            <div class="row justify-content-md-end">')
Add-Line('              <div class="col-auto">')
Add-Line('                @Html.ActionLink({1}.Resources.Dictionary.Global_Button_Back, "Index", "{0}", null, new {{ @class = "btn btn-outline-secondary" }})' -f $data.Metadata.Name, $data.Metadata.AppNamespace)
Add-Line('              </div>')
Add-Line('              @if (Html.HasAction("{0}"))' -f $data.Metadata.ProcedureName)
Add-Line('              {')
Add-Line('                <div class="col-auto">')
Add-Line('                  <button class="btn btn-primary" type="submit">@{0}.Resources.Dictionary.Global_Button_Save</button>' -f $data.Metadata.AppNamespace)
Add-Line('                </div>')
Add-Line('              }')
Add-Line('            </div>')
Add-Line('          </div>')
Add-Line('        </div>')
Add-Line('')

## end-header

## content

### tile BasicInfo

Add-Line('        <div class="b-common b-common--p-sm b-common--toggle mb-30px is-toggled" data-toggle>')
Add-Line('          <fieldset class="form-group mb-0">')
Add-Line('')

### tile-header

Add-Line('            <div class="legend" data-toggle-trigger="#basic-info">')
Add-Line('              <span class="row align-items-center">')
Add-Line('                <span class="col-9">@{0}.Resources.Dictionary.Core_BasicInformation</span>' -f $data.Metadata.AppNamespace)
Add-Line('                <span class="col-3 text-right">')
Add-Line('                  <span data-toggle-label="@{0}.Resources.Dictionary.Global_Show">@{0}.Resources.Dictionary.Global_Hide</span>' -f $data.Metadata.AppNamespace)
Add-Line('                </span>')
Add-Line('              </span>')
Add-Line('            </div>')
Add-Line('')

### end-tile-header

### tile-body

Add-Line('            <div class="b-common__toggle" id="basic-info" data-toggle-content>')
Add-Line('              <div class="b-common__toggle-inner">')
Add-Line('')

### tile-content

Add-Line('                @Html.Partial("_ValidationSummary")')
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
        Add-Line('                <div class="form-group row{0}">'-f $reqClass)
        Add-Line('                  @Html.LabelFor(model => model.{0}, htmlAttributes: new {{ @class = "col-md-3 col-lg-2 col-form-label" }})' -f $column.Value.Name)
        Add-Line('                  <div class="col-md-5 col-lg-3">')
        Add-Line('                    @Html.DropDownListFor(model => model.{0}, Model.{1}, {2}.Resources.Dictionary.Core_EmptyItem, htmlAttributes: new {{ @class = "form-control" }})' -f $column.Value.Name, $column.Value.ListName, $data.Metadata.AppNamespace)
        Add-Line('                    @Html.ValidationMessageFor(model => model.{0}, "", new {{ @class = "text-danger" }})' -f $column.Value.Name)
        if ($columns.Value.IsRequired) {
            Add-Line('                      <span class="form-text text-muted text-uppercase text-10">')
            Add-Line('                        @{0}.Resources.Dictionary.Core_Required' -f $data.Metadata.AppNamespace)
            Add-Line('                      </span>')
        }
        Add-Line('                  </div>')
        Add-Line('                </div>')
        Add-Line('')
    } elseif ($columns.Value.Type -eq 'bool') {
        # checkbox
        Add-Line('                  <div class="form-group row">')
        Add-Line('                    @Html.LabelFor(model => model.{0}, htmlAttributes: new {{ @class = "col-md-3 col-lg-2 col-form-label" }})' -f $column.Value.Name)
        Add-Line('                    <div class="col-md-5 col-lg-3">')
        Add-Line('                      <div class="row align-items-center">')
        Add-Line('                        <div class="col-auto">')
        Add-Line('                          <label class="switch">')
        Add-Line('                            @Html.EditorFor(model => model.{0}, new {{ htmlAttributes = new {{ @class = "switch__control", @aria_describedby = "IsActive" }} }})' -f $column.Value.Name)
        Add-Line('                            <span class="switch__labels" data-on="@{0}.Resources.Dictionary.Core_Yes" data-off="@{0}.Resources.Dictionary.Core_No">' -f $data.Metadata.AppNamespace)
        Add-Line('                            </span>') 
        Add-Line('                            <span class="switch__slider"></span>')
        Add-Line('                          </label>')
        Add-Line('                        </div>')
        Add-Line('                      </div>')
        Add-Line('                      @Html.ValidationMessageFor(model => model.{0}, "", new {{ @class = "text-danger" }})' -f $column.Value.Name)
        Add-Line('                    </div>')
        Add-Line('                  </div>')
        Add-Line('')

    } elseif ($columns.Value.Name -eq 'Description') {
        # textboxarea
        Add-Line('                <div class="form-group row{0}">' -f $reqClass)
        Add-Line('                  @Html.LabelFor(model => model.{0}, htmlAttributes: new {{ @class = "col-md-3 col-lg-2 col-form-label" }})' -f $column.Value.Name)
        Add-Line('                  <div class="col-md-5 col-lg-3">')
        Add-Line('                    @Html.TextAreaFor(model => model.{0}, htmlAttributes: new {{ @class = "form-control" }})' -f $column.Value.Name)
        Add-Line('                    @Html.ValidationMessageFor(model => model.{0}, "", new {{ @class = "text-danger" }})' -f $column.Value.Name)
        if ($columns.Value.IsRequired) {
            Add-Line('                      <span class="form-text text-muted text-uppercase text-10">')
            Add-Line('                        @{0}.Resources.Dictionary.Core_Required')
            Add-Line('                      </span>')
        }
        Add-Line('                  </div>')
        Add-Line('                </div>')
        Add-Line('')
    } elseif ($columns.Value.Type -eq 'DateTime') {
        # editor
        Add-Line('                <div class="form-group row{0}">' -f $reqClass)
        Add-Line('                  @Html.LabelFor(model => model.{0}, htmlAttributes: new {{ @class = "col-md-3 col-lg-2 col-form-label" }})' -f $column.Value.Name)
        Add-Line('                  <div class="col-md-5 col-lg-3">')
        Add-Line('                    <div class="input-group">')
        Add-Line('                      @Html.EditorFor(model => model.{0}, new {{ htmlAttributes = new {{ @class = "form-control text-gray-text js-datepicker" }} }})' -f $column.Value.Name)
        Add-Line('                      <div class="input-group-append">')
        Add-Line('                        <span class="input-group-text">')
        Add-Line('                          <span class="icon-svg icon-svg--calendar ">')
        Add-Line('                            <svg class="icon-svg__svg" xmlns:xlink="http://www.w3.org/1999/xlink">')
        Add-Line('                              <use xlink:href="@Url.Content("~/img/bg/icons-svg.svg#icon-calendar")" x="0" y="0" width="100%" height="100%"></use>')
        Add-Line('                            </svg>')
        Add-Line('                          </span>')
        Add-Line('                        </span>')
        Add-Line('                      </div>')
        Add-Line('                    </div>')
        Add-Line('                    @Html.ValidationMessageFor(model => model.{0}, "", new {{ @class = "text-danger" }})' -f $column.Value.Name)
        if ($columns.Value.IsRequired) {
            Add-Line('                      <span class="form-text text-muted text-uppercase text-10">')
            Add-Line('                        @{0}.Resources.Dictionary.Core_Required' -f $data.Metadata.AppNamespace)
            Add-Line('                      </span>')
        }
        Add-Line('                  </div>')
        Add-Line('                </div>')
        Add-Line('')
    } else {
        # editor
        Add-Line('                <div class="form-group row{0}">' -f $reqClass)
        Add-Line('                  @Html.LabelFor(model => model.{0}, htmlAttributes: new {{ @class = "col-md-3 col-lg-2 col-form-label" }})' -f $column.Value.Name)
        Add-Line('                  <div class="col-md-5 col-lg-3">')
        Add-Line('                    @Html.EditorFor(model => model.{0}, new {{ htmlAttributes = new {{ @class = "form-control" }} }})' -f $column.Value.Name)
        Add-Line('                    @Html.ValidationMessageFor(model => model.{0}, "", new {{ @class = "text-danger" }})' -f $column.Value.Name)
        if ($columns.Value.IsRequired) {
            Add-Line('                      <span class="form-text text-muted text-uppercase text-10">')
            Add-Line('                        @{0}.Resources.Dictionary.Core_Required' -f $data.Metadata.AppNamespace)
            Add-Line('                      </span>')
        }
        Add-Line('                  </div>')
        Add-Line('                </div>')
        Add-Line('')
    }
}

Add-Line('              </div>')
Add-Line('            </div>')

### end-tile-body

Add-Line('')
Add-Line('          </fieldset>')
Add-Line('        </div>')

Add-Line('')
### end-tile BasicInfo


## end-content

## buttons

Add-Line('')
Add-Line('        <div class="row justify-content-center mb-20px">')
Add-Line('          <div class="col-auto">')
Add-Line('            @Html.ActionLink({1}.Resources.Dictionary.Global_Button_Storno, "Index", "{0}", null, new {{ @class = "btn btn-lg btn-outline-secondary" }})' -f $data.Metadata.Name, $data.Metadata.AppNamespace)
Add-Line('          </div>')
Add-Line('          @if (Html.HasAction("{0}"))' -f $data.Metadata.ProcedureName)
Add-Line('          {')
Add-Line('            <div class="col-auto">')
Add-Line('              <button class="btn btn-lg btn-primary" type="submit">@{0}.Resources.Dictionary.Global_Button_Save</button>' -f $data.Metadata.AppNamespace)
Add-Line('            </div>')
Add-Line('          }')
Add-Line('        </div>')
Add-Line('')

## end-buttons

Add-Line('      </div>')
Add-Line('    </div>')
Add-Line('  </div>')

Add-Line('}')

# vypisu builder do hostu
Out-Builder