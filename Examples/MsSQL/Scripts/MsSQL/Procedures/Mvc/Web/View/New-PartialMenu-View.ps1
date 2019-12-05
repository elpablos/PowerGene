param (
    [Parameter(ValueFromPipeline = $true)]$data
)

# inicializace builderu
Initialize-Builder

# generated
Get-GenerateLine $data

# usingy
Add-Line('@model {0}.Modules.{1}.{2}{3}{3}{4}Model' -f $data.Metadata.AppNamespace, $data.Metadata.Modules, $data.Metadata.PluralName, '.DetailHeader', $data.Metadata.Name)

Add-Line('<nav class="navbar">')
Add-Line('  <div class="container">')
Add-Line('    <ul class="nav nav-tabs" role="tablist">')
Add-Line('')
Add-Line('      @if (Html.HasAction("{0}_EDIT"))' -f $table)
Add-Line('      {')
Add-Line('        <li>')
Add-Line('          @Html.ActionLink(Model.DisplayName, "Edit", new {{ id = Model.Id }}, htmlAttributes: new {{ @class = "nav-link " + Html.IsSelected("{0}", "Edit") }})' -f $data.Metadata.Name)
Add-Line('        </li>')
Add-Line('      }')
Add-Line('')
Add-Line('      @if (Html.HasAction("CR_EntityLog_ALL_{0}_{1}"))' -f $data.Metadata.Name, $tablePrefix)
Add-Line('      {')
Add-Line('        <li>')
Add-Line('          @Html.ActionLink({1}.Resources.Dictionary.Global_History, "History", new {{ id = Model.Id }}, htmlAttributes: new {{ @class = "nav-link " + Html.IsSelected("{0}", "History") }})' -f $data.Metadata.Name, $data.Metadata.AppNamespace)
Add-Line('        </li>')
Add-Line('      }')
Add-Line('')
Add-Line('    </ul>')
Add-Line('  </div>')
Add-Line('</nav>')

# vypisu builder do hostu
Out-Builder