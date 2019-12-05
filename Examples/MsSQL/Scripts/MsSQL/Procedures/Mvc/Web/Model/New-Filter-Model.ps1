param (
    [Parameter(ValueFromPipeline = $true)]$data
)

# inicializace builderu
Initialize-Builder

# generated
Get-GenerateLine $data

# usingy
Add-Line('using {0}.Modules.Shared.Alphabet;' -f $data.Metadata.AppNamespace)
Add-Line('using System;')
Add-Line('using System.ComponentModel;');
Add-Line('using System.ComponentModel.DataAnnotations;');

Add-Line('')

# hlavicka
Add-Line('namespace {0}.Modules.{1}.{2}{3}' -f $data.Metadata.AppNamespace, $data.Metadata.Modules, $data.Metadata.PluralName, (('.'+$data.Metadata.Prefix),'')[$data.Metadata.OperationType -eq 'BLANK'])

Add-Line('{')
Add-Line('    /// <summary>')
Add-Line('    /// {0}' -f $data.Metadata.ProcedureDescription)
Add-Line('    /// Vstupní model entity - {0}' -f $data.Metadata.Description)
Add-Line('    /// </summary>')
Add-Line('    public class {1}{0}FilterModel ' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
Add-Line('    {')

#sloupce
$alpha = $false
foreach ($column in $data.InputColumns.GetEnumerator())
{  
    if ($column.Value.Name -in ('ID_Login', 'IsContext')) {
        continue;
    }

    if ($column.Value.Name -eq 'AlphabetString') {

        Add-Line('        /// <summary>')
        Add-Line('        /// Abeceda')
        Add-Line('        /// </summary>')
        Add-Line('        public AlphabetSharedModel Alphabet { get; set; }')
        $alpha = $true
    } else {

        #$type = '{0}{1}' -f $column.Value.Type, ('','?')[$column.Value.IsNullable -eq $true]
        $type = '{0}{1}' -f $column.Value.Type, ('?','')[$column.Value.Type -in ('Guid', 'string')]
        $name = If ($column.Value.Name.StartsWith('ID_')) {$column.Value.Name.SubString(3)} else {$column.Value.Name}

        Add-Line('        /// <summary>')
        Add-Line('        /// {0}' -f $column.Value.Description)
        Add-Line('        /// </summary>')

        # properta
        Add-Line('        [DisplayName("{0}")]' -f $column.Value.Description)
        Add-Line('        //[Display(Name = nameof(Resources.Dictionary.{0}_{1}_{2}), ResourceType = typeof(Resources.Dictionary))]' -f $data.Metadata.Modules, $data.Metadata.PluralName, $name)
        Add-Line('        public {0} {1} {{ get; set; }}' -f $type, ($column.Value.Name, 'Id')[$column.Value.Name -eq 'ID'])
    }

    Add-Line('')
}

if ($alpha -and $true) {
Add-Line('        public {1}{0}FilterModel()'-f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
Add-Line('        {')
Add-Line('            Alphabet = new AlphabetSharedModel("abcdefghijklmnopqrstuvwxyz");')
Add-Line('        }')

}


# ukonceni tridy 
Add-Line('    }')
Add-Line('}')

# vypisu builder do hostu
Out-Builder