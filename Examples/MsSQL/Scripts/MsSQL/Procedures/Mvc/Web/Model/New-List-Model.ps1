param (
    [Parameter(ValueFromPipeline = $true)]$data
)

# inicializace builderu
Initialize-Builder

# generated
Get-GenerateLine $data

# usingy
Add-Line('using System;')
Add-Line('using System.Collections.Generic;')
Add-Line('using System.ComponentModel;');
Add-Line('using System.ComponentModel.DataAnnotations;');

Add-Line('')

# hlavicka
Add-Line('namespace {0}.Modules.{1}.{2}{3}' -f $data.Metadata.AppNamespace, $data.Metadata.Modules, $data.Metadata.PluralName, (('.'+$data.Metadata.Prefix),'')[$data.Metadata.OperationType -eq 'BLANK'])

Add-Line('{')
Add-Line('    /// <summary>')
Add-Line('    /// {0}' -f $data.Metadata.ProcedureDescription)
Add-Line('    /// Model builderu pro entitu - {0}' -f $data.Metadata.Description)
Add-Line('    /// </summary>')
Add-Line('    public class {1}{0}Model ' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
Add-Line('    {')
Add-Line('        /// <summary>')
Add-Line('        /// Položky')
Add-Line('        /// </summary>')
Add-Line('        public virtual ICollection<{1}{0}ItemModel> Items {{ get; set; }}' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
Add-Line('')
Add-Line('        /// <summary>')
Add-Line('        /// Filtry')
Add-Line('        /// </summary>')
Add-Line('        public {1}{0}FilterModel Filter {{ get; set; }}' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
Add-Line('')
Add-Line('        public {1}{0}Model()'  -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
Add-Line('        {')
Add-Line('            Filter = new {1}{0}FilterModel();'  -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
Add-Line('            Items = new List<{1}{0}ItemModel>();' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
Add-Line('        }')

# ukonceni tridy 
Add-Line('    }')
Add-Line('}')

# vypisu builder do hostu
Out-Builder
