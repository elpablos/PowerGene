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
Add-Line('using System.Web.Mvc;')
Add-Line('using System.ComponentModel;');
Add-Line('using System.ComponentModel.DataAnnotations;');

Add-Line('')

# hlavicka
Add-Line('namespace {0}.Controllers.{1}.{2}{3}' -f $data.Metadata.AppNamespace, $data.Metadata.Modules, $data.Metadata.PluralName, (('.'+$data.Metadata.TableRelation),'')[$data.Metadata.OperationType -eq 'BLANK'])

Add-Line('{')
Add-Line('    /// <summary>')
Add-Line('    /// {0}' -f $data.Metadata.ProcedureDescription)
Add-Line('    /// Model builderu pro entitu - {0}' -f $data.Metadata.Description)
Add-Line('    /// </summary>')
Add-Line('    public class {1}{0}Model ' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
Add-Line('    {')

if ($data.Metadata.OperationType -ne 'ALL') {
    Add-Line('        /// <summary>')
    Add-Line('        /// Položky' -f $data.Metadata.ProcedureDescription)
    Add-Line('        /// </summary>')
    Add-Line('        public ICollection<List{2}{0}ItemModel> Items {{ get; set; }}' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata.TableRelation)
    Add-Line('')
}

# filtr
Add-Line('        /// <summary>')
Add-Line('        /// Filtr - {0}' -f $data.Metadata.ProcedureDescription)
Add-Line('        /// </summary>')
Add-Line('        public List{2}{0}FilterModel Filter {{ get; set; }}' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata.TableRelation)
Add-Line('')

Add-Line('        /// <summary>')
Add-Line('        /// Konstruktor - {0}' -f $data.Metadata.ProcedureDescription)
Add-Line('        /// Model builderu pro entitu - {0}' -f $data.Metadata.Description)
Add-Line('        /// </summary>')
Add-Line('        public {1}{0}Model()' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
Add-Line('        {')

# lists
 if ($data.Metadata.OperationType -ne 'ALL') {
    Add-Line('            Items = new List<List{2}{0}ItemModel>();' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata.TableRelation)
 } 

# filter
Add-Line('            Filter = new List{2}{0}FilterModel();' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata.TableRelation)

Add-Line('        }')

# ukonceni tridy 
Add-Line('    }')
Add-Line('}')

# vypisu builder do hostu
Out-Builder
