param (
    [Parameter(ValueFromPipeline = $true)]$data
)

# inicializace builderu
Initialize-Builder

# generated
Get-GenerateLine $data

# usingy
Add-Line('using Dapper;' -f $data.Metadata.CoreNamespace, $data.Metadata.Modules)
Add-Line('using {0}.Domains.Services.Common;' -f $data.Metadata.CoreNamespace)
Add-Line('using {0}.Utils.Results;' -f $data.Metadata.CoreNamespace)
Add-Line('using System;')
Add-Line('using System.Collections.Generic;')
Add-Line('using System.Data.SqlClient;')
Add-Line('using System.Linq;')

Add-Line('')

# hlavicka
Add-Line('namespace {0}.Domains.Services.{1}.{2}' -f $data.Metadata.CoreNamespace, $data.Metadata.Modules, $data.Metadata.PluralName)

Add-Line('{')
Add-Line('    /// <summary>')
Add-Line('    /// Implementace služby pro entitu - {0}' -f $data.Metadata.Description)
Add-Line('    /// </summary>')
Add-Line('    public partial class {0}Service : BaseService, I{0}Service' -f $data.Metadata.Name)
Add-Line('    {')

if ($data.Metadata.OperationType -ne 'BLANK') {

if ($data.Metadata.OperationType -eq 'ALL') {
    Add-Line('        /// <summary>')
    Add-Line('        /// {0}' -f $data.Metadata.ProcedureDescription)
    Add-Line('        /// </summary>')
    Add-Line('        /// <param name="input">vstupní objekt</param>')
    Add-Line('        /// <returns>kolekce výstupních objektů</returns>')
    Add-Line('        public ModelCoreResult<ICollection<{1}{0}OutputModel>> {1}({1}{0}InputModel input)' -f $data.Metadata.Name, $data.Metadata.Prefix)
    Add-Line('        {')
    Add-Line('            // zalozim result')
    Add-Line('            var result = new ModelCoreResult<ICollection<{1}{0}OutputModel>>();' -f $data.Metadata.Name, $data.Metadata.Prefix)
}
else {
    Add-Line('        /// <summary>')
    Add-Line('        /// {0}' -f $data.Metadata.ProcedureDescription)
    Add-Line('        /// </summary>')
    Add-Line('        /// <param name="input">vstupní objekt</param>')
    Add-Line('        /// <returns>výstupní objekt</returns>')
    Add-Line('        public ModelCoreResult<{1}{0}OutputModel> {1}({1}{0}InputModel input)' -f $data.Metadata.Name, $data.Metadata.Prefix)
    Add-Line('        {')
    Add-Line('            // zalozim result')
    Add-Line('            var result = new ModelCoreResult<{1}{0}OutputModel>();' -f $data.Metadata.Name, $data.Metadata.Prefix)
}

Add-Line('')
Add-Line('            using (var conn = GetConnection())')
Add-Line('            {')

if ($data.Metadata.OperationType -eq 'NEW') {
Add-Line('                // parametry')
Add-Line('                var param = new DynamicParameters();')

    #sloupce
    foreach ($column in $data.InputColumns.GetEnumerator())
    {  
     if ($column.Value.IsOutput -eq $true) {
            Add-Line('                param.Add("{0}", input.{0}, dbType: System.Data.DbType.{1}, direction: System.Data.ParameterDirection.Output);' -f $column.Value.Name, $column.Value.DbType)
        }
        else {
            Add-Line('                param.Add("{0}", input.{0}, dbType: System.Data.DbType.{1});'  -f $column.Value.Name, $column.Value.DbType)
        }
        
    }
}

Add-Line('                try')
Add-Line('                {')
Add-Line('                    // volani stored proc')
Add-Line('                    string proc = "{0}";' -f $data.Metadata.ProcedureName)
if ($data.Metadata.OperationType -ne 'NEW') {
    Add-Line('                    var param = new DynamicParameters(input);')
}
Add-Line('                    LogQuery(proc, input);')

if ($data.Metadata.OperationType -eq 'NEW') {
    Add-Line('                    conn.Query<{1}{0}OutputModel>(proc, param: param, commandType: System.Data.CommandType.StoredProcedure).FirstOrDefault();' -f $data.Metadata.Name, $data.Metadata.Prefix)
}
elseif ($data.Metadata.OperationType -eq 'ALL') {
    Add-Line('                    result.Data = conn.Query<{1}{0}OutputModel>(proc, param: param, commandType: System.Data.CommandType.StoredProcedure).ToList();' -f $data.Metadata.Name, $data.Metadata.Prefix)
}
else {
    Add-Line('                    result.Data = conn.Query<{1}{0}OutputModel>(proc, param: param, commandType: System.Data.CommandType.StoredProcedure).FirstOrDefault();' -f $data.Metadata.Name, $data.Metadata.Prefix)
}

if ($data.Metadata.OperationType -eq 'NEW') {
Add-Line('                    // vytazeni output parametru')
Add-Line('                    result.Data = new {1}{0}OutputModel' -f $data.Metadata.Name, $data.Metadata.Prefix)
Add-Line('                    {')

    #sloupce - output
    foreach ($column in $data.OutputColumns.GetEnumerator())
    {  
        if ($column.Value.IsOutput -eq $true) {
            Add-Line('                        {0} = param.Get<{1}>("{0}"),' -f $column.Value.Name, $column.Value.Type)
        }
    }
Add-Line('                    };')
}

Add-Line('                }')
Add-Line('                // kontrola validaci')
Add-Line('                catch (SqlException e)')
Add-Line('                {')
Add-Line('                    TryValidation(e, result);')
Add-Line('                }')
Add-Line('            }')
Add-Line('            ')
Add-Line('            return result;')
Add-Line('        }')
Add-Line('')

}

# ukonceni tridy 
Add-Line('    }')
Add-Line('}')

# vypisu builder do hostu
Out-Builder
