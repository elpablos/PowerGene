param (
    [Parameter(ValueFromPipeline = $true)]$data
)

# inicializace builderu
Initialize-Builder

# generated
Get-GenerateLine $data

# usingy
Add-Line('using System;')
Add-Line('using System.ComponentModel;');
Add-Line('using System.ComponentModel.DataAnnotations;');

Add-Line('')

# hlavicka
Add-Line('namespace {0}.Modules.{1}.{2}{3}' -f $data.Metadata.AppNamespace, $data.Metadata.Modules, $data.Metadata.PluralName, (('.'+$data.Metadata.TableRelation),'')[$data.Metadata.OperationType -eq 'BLANK'])

Add-Line('{')
Add-Line('    /// <summary>')
Add-Line('    /// {0}' -f $data.Metadata.ProcedureDescription)
Add-Line('    /// Filter model entity - {0}' -f $data.Metadata.Description)
Add-Line('    /// </summary>')
Add-Line('    public class {1}{0}FilterModel ' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
Add-Line('    {')

Add-Line('        /// <summary>')
Add-Line('        /// Zda je otevřen panel "Připojit"' -f $data.Metadata.ProcedureDescription)
Add-Line('        /// </summary>')
Add-Line('        public bool IsListOpen {{ get; set; }}' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
Add-Line('')

Add-Line('        /// <summary>')
Add-Line('        /// Zda je otevřen panel "Odpojit"' -f $data.Metadata.ProcedureDescription)
Add-Line('        /// </summary>')
Add-Line('        public bool IsUnlinkOpen {{ get; set; }}' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
Add-Line('')

Add-Line('        /// <summary>')
Add-Line('        /// Krok - po kolika zobrazovat' -f $data.Metadata.ProcedureDescription)
Add-Line('        /// </summary>')
Add-Line('        public int Step {{ get; set; }}' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
    Add-Line('')

#sloupce
foreach ($column in $data.InputColumns.GetEnumerator())
{  
    if ($column.Value.Name -eq 'ID_Login') {
        continue;
    }

    #$type = '{0}{1}' -f $column.Value.Type, ('','?')[$column.Value.IsNullable -eq $true]
    $type = '{0}{1}' -f $column.Value.Type, ('?','')[$column.Value.Type -in ('Guid', 'string')]
    $name = If ($column.Value.Name.StartsWith('ID_')) {$column.Value.Name.SubString(3)} else {$column.Value.Name}

    if ($column.Value.TableName -eq $obj.Metadata.Table) {
        Add-Line('        /// <summary>')
        Add-Line('        /// Nadřazený člen' -f $column.Value.Description)
        Add-Line('        /// {0}' -f $column.Value.Description)
        Add-Line('        /// </summary>')

        # properta
        Add-Line('        [DisplayName("{0}")]' -f $column.Value.Description)
        Add-Line('        //[Display(Name = nameof(Resources.Dictionary.{0}_{1}_{2}), ResourceType = typeof(Resources.Dictionary))]' -f $data.Metadata.Modules, $data.Metadata.PluralName, $name)
        Add-Line('        public {0} ID_Parent {{ get; set; }}' -f $type, ($column.Value.Name, 'Id')[$column.Value.Name -eq 'ID'])
        Add-Line('')
    } else {

        Add-Line('        /// <summary>')
        Add-Line('        /// {0}' -f $column.Value.Description)
        Add-Line('        /// </summary>')

        # properta
        Add-Line('        [DisplayName("{0}")]' -f $column.Value.Description)
        Add-Line('        //[Display(Name = nameof(Resources.Dictionary.{0}_{1}_{2}), ResourceType = typeof(Resources.Dictionary))]' -f $data.Metadata.Modules, $data.Metadata.PluralName, $name)
        Add-Line('        public {0} {1} {{ get; set; }}' -f $type, ($column.Value.Name, 'Id')[$column.Value.Name -eq 'ID'])
        Add-Line('')
    }

    if ($column.Value.Name -eq 'DisplayName') {
        Add-Line('        /// <summary>')
        Add-Line('        /// {0} - odpojovací' -f $column.Value.Description)
        Add-Line('        /// </summary>')

        # properta
        Add-Line('        [DisplayName("{0}")]' -f $column.Value.Description)
        Add-Line('        //[Display(Name = nameof(Resources.Dictionary.{0}_{1}_Unlink{2}), ResourceType = typeof(Resources.Dictionary))]' -f $data.Metadata.Modules, $data.Metadata.PluralName, $name)
        Add-Line('        public {0} Unlink{1} {{ get; set; }}' -f $type, ($column.Value.Name, 'Id')[$column.Value.Name -eq 'ID'])
        Add-Line('')
    }
}

Add-Line('        /// <summary>')
Add-Line('        /// Konstruktor - {0}' -f $data.Metadata.ProcedureDescription)
Add-Line('        /// Filter model builderu pro entitu - {0}' -f $data.Metadata.Description)
Add-Line('        /// </summary>')
Add-Line('        public {1}{0}FilterModel()' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
Add-Line('        {')

Add-Line('            IsListOpen = false;')
Add-Line('            IsUnlinkOpen = false;')
Add-Line('            Top = 5;')
Add-Line('            Step = 5;')


Add-Line('        }')

# ukonceni tridy 
Add-Line('    }')
Add-Line('}')

# vypisu builder do hostu
Out-Builder
