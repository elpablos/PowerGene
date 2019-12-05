param (
    [Parameter(ValueFromPipeline = $true)]$data
)

# inicializace builderu
Initialize-Builder

# generated
Get-GenerateLine $data

# usingy
Add-Line('using System;')

Add-Line('')

# hlavicka
Add-Line('namespace {0}.Domains.Services.{1}.{2}' -f $data.Metadata.CoreNamespace, $data.Metadata.Modules, $data.Metadata.PluralName)

Add-Line('{')
Add-Line('    /// <summary>')
Add-Line('    /// {0}' -f $data.Metadata.ProcedureDescription)
Add-Line('    /// Vstupní model entity - {0}' -f $data.Metadata.Description)
Add-Line('    /// </summary>')
Add-Line('    public class {1}{0}InputModel ' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
Add-Line('    {')

#sloupce
foreach ($column in $data.InputColumns.GetEnumerator())
{  
    if ($column.Value.Name -in ('IsContext')) {
        continue;
    }

    #$type = '{0}{1}' -f $column.Value.Type, ('','?')[$column.Value.IsNullable -eq $true]
    $type = '{0}{1}' -f $column.Value.Type, ('?','')[$column.Value.Type -in ('Guid', 'string')]

    Add-Line('        /// <summary>')
    Add-Line('        /// {0}' -f $column.Value.Description)
    Add-Line('        /// </summary>')

    # properta
    # Add-Line('        [Display("{0}")]' -f $column.Value.Description)
    Add-Line('        public {0} {1} {{ get; set; }}' -f $type, $column.Value.Name)
    Add-Line('')
}

# ukonceni tridy 
Add-Line('    }')
Add-Line('}')

# vypisu builder do hostu
Out-Builder