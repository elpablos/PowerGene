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

Add-Line('            var result = _{0}Service.{1}(new {1}{0}InputModel' -f  $data.Metadata.Name, $data.Metadata.Prefix)
Add-Line('            {')
Add-Line('                ID_Login = _loggedUser.ID_Login,')

#sloupce - input
foreach ($column in $data.InputColumns.GetEnumerator()) {  

    if ($data.Metadata.OperationType -eq 'DEL' -and $column.Value.Name -eq 'ID') {
        Add-Line('                {1} = input.{0},' -f ($column.Value.Name, 'Id')[$column.Value.Name -eq 'ID'], $column.Value.Name)
    } else {
        #Add-Line('                {0} - {1}' -f $obj.Metadata.TableRelation, $column.Value.TableName)
        if ($column.Value.Name -eq 'ID_Login' -or $column.Value.Name -eq 'ID') {
            # nic
        } elseif ($column.Value.TableName -eq $obj.Metadata.Table) {
            Add-Line('                {1} = input.Filter.ID_Parent.Value,' -f ($column.Value.Name, 'Id')[$column.Value.Name -eq 'ID'], $column.Value.Name)
        } elseif ($obj.Metadata.TableRelation.endswith($column.Value.TableName)) {
            Add-Line('                {1} = input.Id,' -f ($column.Value.Name, 'Id')[$column.Value.Name -eq 'ID'], $column.Value.Name)
        } else {
            Add-Line('                {1} = input.{0},' -f ($column.Value.Name, 'Id')[$column.Value.Name -eq 'ID'], $column.Value.Name)
        }
    }
}
Add-Line('            });')
Add-Line('')

# return model
Add-Line('            return new ModelHandlerResult()')
Add-Line('            {')

Add-Line('                Message = result.IsSuccess ? Resources.Dictionary.Global_{0}_SuccessNotification : null,' -f $obj.Metadata.PrefixType)
Add-Line('                Data = result.Data,')
Add-Line('                Exception = result.Exception,')
Add-Line('                ValidationMessages = result.ValidationMessages')

Add-Line('            };')
Add-Line('        }')


# ukonceni tridy 
Add-Line('    }')
Add-Line('}')

# vypisu builder do hostu
Out-Builder
