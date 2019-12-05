param (
    [Parameter(ValueFromPipeline = $true)]$data
)

# inicializace builderu
Initialize-Builder

# generated
Get-GenerateLine $data

# usingy
Add-Line('using {0}.Domains.Services.{1}.{2};' -f $data.Metadata.CoreNamespace, $data.Metadata.Modules, $data.Metadata.PluralName)
Add-Line('using {0}.Mvc.LoggedUsers;' -f $data.Metadata.AppNamespace)
Add-Line('using {0}.Mvc.Results;' -f $data.Metadata.AppNamespace)
Add-Line('using System;')
Add-Line('using System.Linq;')

Add-Line('')

# hlavicka
Add-Line('namespace {0}.Modules.{1}.{2}{3}' -f $data.Metadata.AppNamespace, $data.Metadata.Modules, $data.Metadata.PluralName, (('.'+$data.Metadata.Prefix),'')[$data.Metadata.OperationType -eq 'BLANK'])

Add-Line('{')
Add-Line('    /// <summary>')
Add-Line('    /// {0}' -f $data.Metadata.ProcedureDescription)
Add-Line('    /// Builder pro entitu - {0}' -f $data.Metadata.Description)
Add-Line('    /// </summary>')
Add-Line('    public class {1}{0}Builder : IModelBuilder<{1}{0}Model>, IModelBuilder<{1}{0}Model, {1}{0}Model>' -f $data.Metadata.Name, $data.Metadata.Prefix)
Add-Line('    {')
Add-Line('        private readonly ILoggedUser _loggedUser;')
Add-Line('        private readonly I{0}Service _{0}Service;'  -f  $data.Metadata.Name)

Add-Line('        /*')
$columns = $data.InputColumns.GetEnumerator()
foreach ($column in $columns)
{    
    if ($column.Value.IsFk -eq $true) {
        Add-Line('        private readonly I{0}Service _{0}Service;'  -f  $column.Value.TableName)
    }
}
Add-Line('        */')

Add-Line('')

# ctor
Add-Line('        public {1}{0}Builder(ILoggedUser loggedUser, I{0}Service {0}Service)'  -f  $data.Metadata.Name, $data.Metadata.Prefix)
Add-Line('        /*')
$columns = $data.InputColumns.GetEnumerator()
foreach ($column in $columns)
{    
    if ($column.Value.IsFk -eq $true) {
        Add-Line('            I{0}Service {0}Service,'  -f  $column.Value.TableName)
    }
}
Add-Line('        */')

Add-Line('        {')
Add-Line('            _loggedUser = loggedUser;')
Add-Line('            _{0}Service = {0}Service;'  -f  $data.Metadata.Name)
Add-Line('            /*')
$columns = $data.InputColumns.GetEnumerator()
foreach ($column in $columns)
{    
    if ($column.Value.IsFk -eq $true) {
        Add-Line('            _{0}Service = {0}Service;'  -f  $column.Value.TableName)
    }
}
Add-Line('            */')
Add-Line('        }')

# build
Add-Line('')
Add-Line('        public ModelBuilderResult<{1}{0}Model> Build()' -f  $data.Metadata.Name, $data.Metadata.Prefix)
Add-Line('        {')
Add-Line('            var data = new {1}{0}Model();' -f  $data.Metadata.Name, $data.Metadata.Prefix)
Add-Line('')
Add-Line('            return this.Build(data);')
Add-Line('        }')
 
# pomocny build
Add-Line('')
Add-Line('        public ModelBuilderResult<{1}{0}Model> Build({1}{0}Model model)' -f  $data.Metadata.Name, $data.Metadata.Prefix)
Add-Line('        {')
Add-Line('            /*')
Add-Line('')

$columns = $data.InputColumns.GetEnumerator()
foreach ($column in $columns)
{    
    if ($column.Value.IsFk -eq $true) {
        Add-Line('            model.{1} = _{0}Service.List(new List{0}InputModel' -f $columns.Value.TableName, $column.Value.ListName)
        Add-Line('            {')
        Add-Line('                ID_Login = _loggedUser.ID_Login,')
        Add-Line('            }).Data.Select(x => new System.Web.Mvc.SelectListItem')
        Add-Line('            {')
        Add-Line('                Value = x.ID.ToString(),')
        Add-Line('                Text = x.DisplayName')
        Add-Line('            }).ToList();')
        Add-Line('')

    }
}

Add-Line('            */')
Add-Line('            return this.Success(model);')
Add-Line('        }')

# ukonceni tridy 
Add-Line('    }')
Add-Line('}')

# vypisu builder do hostu
Out-Builder
