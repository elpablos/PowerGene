param (
    [Parameter(ValueFromPipeline = $true)]$data
)

# inicializace builderu
Initialize-Builder

# generated
Get-GenerateLine $data

# usingy
Add-Line('using {0}.Domains.Services.{1}.{2};' -f $data.Metadata.CoreNamespace, $data.Metadata.Modules, $data.Metadata.PluralName)
Add-Line('using {0}.Mvc.Common;' -f $data.Metadata.AppNamespace)
Add-Line('using {0}.Mvc.LoggedUsers;' -f $data.Metadata.AppNamespace)
Add-Line('using {0}.Mvc.Results;' -f $data.Metadata.AppNamespace)
Add-Line('using System;')
Add-Line('using System.Collections.Generic;')

Add-Line('')

# hlavicka
Add-Line('namespace {0}.Controllers.{1}.{2}{3}' -f $data.Metadata.AppNamespace, $data.Metadata.Modules, $data.Metadata.PluralName, (('.'+$data.Metadata.TableRelation),'')[$data.Metadata.OperationType -eq 'BLANK'])

Add-Line('{')
Add-Line('    /// <summary>')
Add-Line('    /// {0}' -f $data.Metadata.ProcedureDescription)
Add-Line('    /// Builder pro entitu - {0}' -f $data.Metadata.Description)
Add-Line('    /// </summary>')
Add-Line('    public class {1}{0}Handler : IModelHandler<{1}{0}Model>' -f $data.Metadata.Name, $data.Metadata.Prefix)
Add-Line('    {')
Add-Line('        private readonly ILoggedUser _loggedUser;')
Add-Line('        private readonly I{0}Service _{0}Service;'  -f  $data.Metadata.Name)
Add-Line('')

# ctor
Add-Line('        public {1}{0}Handler(ILoggedUser loggedUser, I{0}Service {0}Service)'  -f  $data.Metadata.Name, $data.Metadata.Prefix)
Add-Line('        {')
Add-Line('            _loggedUser = loggedUser;')
Add-Line('            _{0}Service = {0}Service;'  -f  $data.Metadata.Name)
Add-Line('        }')

# build
Add-Line('')
Add-Line('        public ModelHandlerResult Handle({1}{0}Model input)' -f  $data.Metadata.Name, $data.Metadata.Prefix)
Add-Line('        {')
Add-Line('            var validation = new List<{0}.Utils.Validations.ValidateMessage>();' -f $data.Metadata.CoreNamespace)
Add-Line('')

Add-Line('            foreach (var item in input.Items)' -f  $data.Metadata.Name, $data.Metadata.Prefix)
Add-Line('            {')

Add-Line('                var result = Handler.Get<{1}{0}Handler>().Handle(new {1}{0}Model' -f $data.Metadata.Name, $data.Metadata.PrefixOriginal)
Add-Line('                {')
Add-Line('                    Filter = input.Filter,')

#sloupce - input
foreach ($column in $data.InputColumns.GetEnumerator())
{  
    if ($column.Value.Name -eq 'ID')
    {
        Add-Line('                    {0} = item.{0}.Value,' -f ($column.Value.Name, 'Id')[$column.Value.Name -eq 'ID']) 
    }
}

Add-Line('                });')

Add-Line('')

Add-Line('                if (!result.IsSuccess)')
Add-Line('                {')
Add-Line('                    validation.AddRange(result.ValidationMessages);')
Add-Line('                };')
Add-Line('            }')
Add-Line('')

# return model
Add-Line('            return new ModelHandlerResult()')
Add-Line('            {')

Add-Line('                Message = validation.Count > 0  ? Resources.Dictionary.Global_{0}_SuccessNotification : null,' -f $obj.Metadata.PrefixType)
Add-Line('                Data = input,')
Add-Line('                Exception = null,')
Add-Line('                ValidationMessages = validation')

Add-Line('            };')
Add-Line('        }')


# ukonceni tridy 
Add-Line('    }')
Add-Line('}')

# vypisu builder do hostu
Out-Builder