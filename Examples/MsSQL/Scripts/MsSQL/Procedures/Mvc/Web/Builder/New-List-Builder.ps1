param (
    [Parameter(ValueFromPipeline = $true)]$data
)

# inicializace builderu
Initialize-Builder

# generated
Get-GenerateLine $data

# usingy
Add-Line('using {0}.Domains.Services.{1}.{2};' -f $data.Metadata.CoreNamespace, $data.Metadata.Modules, $data.Metadata.PluralName)
Add-Line('using {0}.Mvc.Extensions;' -f $data.Metadata.AppNamespace)
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
Add-Line('    public class {1}{0}Builder : IModelBuilder<{1}{0}Model, {1}{0}FilterModel>' -f $data.Metadata.Name, $data.Metadata.Prefix)
Add-Line('    {')
Add-Line('        private readonly ILoggedUser _loggedUser;')
Add-Line('        private readonly I{0}Service _{0}Service;'  -f  $data.Metadata.Name)
Add-Line('')

# ctor
Add-Line('        public {1}{0}Builder(ILoggedUser loggedUser, I{0}Service {0}Service)'  -f  $data.Metadata.Name, $data.Metadata.Prefix)
Add-Line('        {')
Add-Line('            _loggedUser = loggedUser;')
Add-Line('            _{0}Service = {0}Service;'  -f  $data.Metadata.Name)
Add-Line('        }')

# build
Add-Line('')
Add-Line('        public ModelBuilderResult<{1}{0}Model> Build({1}{0}FilterModel filter)' -f  $data.Metadata.Name, $data.Metadata.Prefix)
Add-Line('        {')
Add-Line('            var data = new {1}{0}Model();' -f  $data.Metadata.Name, $data.Metadata.Prefix)

Add-Line('            var result = _{0}Service.{1}(new {1}{0}InputModel' -f  $data.Metadata.Name, $data.Metadata.Prefix)
Add-Line('            {')
Add-Line('                ID_Login = _loggedUser.ID_Login,')

#sloupce - input
foreach ($column in $data.InputColumns.GetEnumerator())
{  
    if ($column.Value.Name -in ('ID_Login', 'IsContext')) {
        continue;
    }

    if ($column.Value.Name -eq 'AlphabetString') {
        Add-Line('                AlphabetString = Alphabet.Join(filter.Alphabet.Items),')
    } else {
        Add-Line('                {1} = filter.{0},' -f ($column.Value.Name, 'Id')[$column.Value.Name -eq 'ID'], $column.Value.Name)
    }
}
Add-Line('            });')

Add-Line('            data.Items = result.Data.Select(x => new {1}{0}ItemModel' -f  $data.Metadata.Name, $data.Metadata.Prefix)
Add-Line('            {')
#sloupce - output
$columns = ($data.OutputColumns.GetEnumerator(), $data.InputColumns.GetEnumerator())[$data.Metadata.OperationType -in ('NEW', 'DEL', 'EDIT')]
foreach ($column in $columns)
{  
    Add-Line('                {0} = x.{1},' -f ($column.Value.Name, 'Id')[$column.Value.Name -eq 'ID'], $column.Value.Name)
}
Add-Line('            }).ToList();')
Add-Line('')
Add-Line('            return this.Success(data);')
Add-Line('        }')


# ukonceni tridy 
Add-Line('    }')
Add-Line('}')

# vypisu builder do hostu
Out-Builder
