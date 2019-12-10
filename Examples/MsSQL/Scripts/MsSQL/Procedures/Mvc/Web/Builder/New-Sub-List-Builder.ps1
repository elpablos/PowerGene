param (
    [Parameter(ValueFromPipeline = $true)]$data
)

# inicializace builderu
Initialize-Builder

# generated
Get-GenerateLine $data

$local:uq = ''
#sloupce - output
$columns = ($data.OutputColumns.GetEnumerator(), $data.InputColumns.GetEnumerator())[$data.Metadata.OperationType -in ('NEW', 'DEL', 'EDIT')]
foreach ($column in $columns)
{  
    if ($obj.Metadata.TableRelation.endswith($column.Value.TableName)) {
        $local:uq = $column.Value.Name
    }
}


# usingy
Add-Line('using {0}.Domains.Services.{1}.{2};' -f $data.Metadata.CoreNamespace, $data.Metadata.Modules, $data.Metadata.PluralName)
Add-Line('using {0}.Mvc.LoggedUsers;' -f $data.Metadata.AppNamespace)
Add-Line('using {0}.Mvc.Results;' -f $data.Metadata.AppNamespace)
Add-Line('using System;')
Add-Line('using System.Linq;')

Add-Line('')

# hlavicka
Add-Line('namespace {0}.Controllers.{1}.{2}{3}' -f $data.Metadata.AppNamespace, $data.Metadata.Modules, $data.Metadata.PluralName, (('.'+$data.Metadata.TableRelation),'')[$data.Metadata.OperationType -eq 'BLANK'])

Add-Line('{')
Add-Line('    /// <summary>')
Add-Line('    /// {0}' -f $data.Metadata.ProcedureDescription)
Add-Line('    /// Builder pro entitu - {0}' -f $data.Metadata.Description)
Add-Line('    /// </summary>')
Add-Line('    public class {1}{0}Builder : IModelBuilder<{1}{0}Model, {1}{0}FilterModel>' -f $data.Metadata.Name, $data.Metadata.Prefix)
Add-Line('    {')
Add-Line('        private readonly ILoggedUser _loggedUser;')
Add-Line('        private readonly I{0}Service _{0}Service;'  -f  $data.Metadata.Name)
Add-Line('        // private readonly I{0}Service _{0}Service;'  -f  $local:uq)
Add-Line('')

# ctor
Add-Line('        public {1}{0}Builder(ILoggedUser loggedUser, I{0}Service {0}Service /*, I{2}Service {2}Service */)'  -f  $data.Metadata.Name, $data.Metadata.Prefix, $local:uq)
Add-Line('        {')
Add-Line('            _loggedUser = loggedUser;')
Add-Line('            _{0}Service = {0}Service;'  -f  $data.Metadata.Name)
Add-Line('            //_{0}Service = {0}Service;'  -f  $local:uq)
Add-Line('        }')

# build
Add-Line('')
Add-Line('        public ModelBuilderResult<{1}{0}Model> Build({1}{0}FilterModel filter)' -f  $data.Metadata.Name, $data.Metadata.Prefix)
Add-Line('        {')
Add-Line('            var data = new {1}{0}Model();' -f  $data.Metadata.Name, $data.Metadata.Prefix)

Add-Line('            data.ActionName = "{0}";' -f  $data.Metadata.TableRelation)
Add-Line('            data.ControllerName = "{0}";' -f  $data.Metadata.Name)
Add-Line('            data.ID_PopupToggle = 1;')
Add-Line('            var count = 0; // TODO! dodelat pocet!')
Add-Line('')

# Items
Add-Line('            var result = _{0}Service.{1}(new {1}{0}InputModel' -f  $data.Metadata.Name, $data.Metadata.Prefix)
Add-Line('            {')
Add-Line('                ID_Login = _loggedUser.ID_Login,')

#sloupce - input
$columns = $data.InputColumns.GetEnumerator()
foreach ($column in $columns)
{  
    if ($column.Value.Name -eq 'ID_Login' -or $column.Value.Name -eq 'ID') {
        # id je vygenerovany
    } elseif ($column.Value.TableName -eq $obj.Metadata.Table) {
        # pouziju Filter.ID_Parent
        Add-Line('                {0} = filter.ID_Parent.Value,' -f $column.Value.Name)
    } elseif ($obj.Metadata.TableRelation.endswith($column.Value.TableName) -and $column.Value.TableName -ne '') {
        # pouzije se Id
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

Add-Line('            count = data.Items.Count;')

# UnlinkItems 
Add-Line('            data.UnlinkItems = _{0}Service.{1}(new {1}{0}InputModel' -f  $data.Metadata.Name, $data.Metadata.Prefix)
Add-Line('            {')
Add-Line('                ID_Login = _loggedUser.ID_Login,')

#sloupce - input
$columns = $data.InputColumns.GetEnumerator()
foreach ($column in $columns)
{  
    if ($column.Value.Name -eq 'ID_Login' -or $column.Value.Name -eq 'ID') {
        # id je vygenerovany
    } elseif ($column.Value.TableName -eq $obj.Metadata.Table) {
        # pouziju Filter.ID_Parent
        Add-Line('                {0} = filter.ID_Parent.Value,' -f $column.Value.Name)
    } elseif ($obj.Metadata.TableRelation.endswith($column.Value.TableName) -and $column.Value.TableName -ne '') {
        # pouzije se Id
    } else {
        if ($column.Value.Name -eq 'DisplayName') {
            Add-Line('                {1} = filter.Unlink{0},' -f ($column.Value.Name, 'Id')[$column.Value.Name -eq 'ID'], $column.Value.Name)
        } else {
            Add-Line('                {1} = filter.{0},' -f ($column.Value.Name, 'Id')[$column.Value.Name -eq 'ID'], $column.Value.Name)
        }
    }
}
Add-Line('            }}).Data.Select(x => new {1}{0}ItemModel' -f  $data.Metadata.Name, $data.Metadata.Prefix)
Add-Line('            {')

#sloupce - output
$columns = ($data.OutputColumns.GetEnumerator(), $data.InputColumns.GetEnumerator())[$data.Metadata.OperationType -in ('NEW', 'DEL', 'EDIT')]
foreach ($column in $columns)
{  
    if ($obj.Metadata.TableRelation.endswith($column.Value.TableName)) {
    }
    Add-Line('                {0} = x.{1},' -f ($column.Value.Name, 'Id')[$column.Value.Name -eq 'ID'], $column.Value.Name)
}
Add-Line('            }).ToList();')
Add-Line('')

# LinkItems
if ($local:uq -ne '') {

    Add-Line('            /*')
    Add-Line('            data.LinkItems = _{2}Service.List(new List{2}InputModel' -f  $data.Metadata.Name, $data.Metadata.Prefix, $local:uq)
    Add-Line('            {')
    Add-Line('                ID_Login = _loggedUser.ID_Login,')
    Add-Line('                Codebook_IsActive = true,')
    Add-Line('                NotOwned = true,')

    #sloupce - input
    $columns = $data.InputColumns.GetEnumerator()
    foreach ($column in $columns)
    {  
        
        if ($column.Value.Name -eq 'ID_Login' -or $column.Value.Name -eq 'ID') {
            # id je vygenerovany
        } elseif ($column.Value.TableName -eq $obj.Metadata.Table) {
            # pouziju Filter.ID_Parent
            Add-Line('                {0} = filter.ID_Parent.Value,' -f $column.Value.Name)
        } elseif ($obj.Metadata.TableRelation.endswith($column.Value.TableName) -and $column.Value.TableName -ne '') {
            # pouzije se Id
        } else {
            Add-Line('                {1} = filter.{0},' -f ($column.Value.Name, 'Id')[$column.Value.Name -eq 'ID'], $column.Value.Name)
        }
    }
    Add-Line('            }}).Data.Select(x => new {1}{0}ItemModel' -f  $data.Metadata.Name, $data.Metadata.Prefix)
    Add-Line('            {')
    #sloupce - output
    $columns = ($data.OutputColumns.GetEnumerator(), $data.InputColumns.GetEnumerator())[$data.Metadata.OperationType -in ('NEW', 'DEL', 'EDIT')]
    foreach ($column in $columns)
    {  
        if ($column.Value.Name -eq 'DisplayName') {
            Add-Line('                {0} = x.{1},' -f $uniqueFkName, $column.Value.Name)
        } else {
            Add-Line('                {0} = x.{1},' -f ($column.Value.Name, 'Id')[$column.Value.Name -eq 'ID'], $column.Value.Name)
        }
    }
    Add-Line('            }).ToList();')
    Add-Line('            */')
    Add-Line('')
}

Add-Line('            data.TotalRows = count;')
Add-Line('            filter.Step = (data.TotalRows - data.Items.Count) >= filter.Step ? filter.Step : (data.TotalRows - data.Items.Count);')
Add-Line('            data.Filter = filter;')

Add-Line('')
Add-Line('            return this.Success(data);')
Add-Line('        }')


# ukonceni tridy 
Add-Line('    }')
Add-Line('}')

# vypisu builder do hostu
Out-Builder
