param (
    [Parameter(ValueFromPipeline = $true)]$data
)

# inicializace builderu
Initialize-Builder

# generated
Get-GenerateLine $data

# usingy
Add-Line('using System.Collections.Generic;')
Add-Line('using {0}.Utils.Results;' -f $data.Metadata.CoreNamespace)
Add-Line('')

# hlavicka
Add-Line('namespace {0}.Domains.Services.{1}.{2}' -f $data.Metadata.CoreNamespace, $data.Metadata.Modules, $data.Metadata.PluralName)

Add-Line('{')
Add-Line('    /// <summary>')
Add-Line('    /// Rozhraní služby pro entitu {0}' -f $data.Metadata.Description)
Add-Line('    /// </summary>')
Add-Line('    public partial interface I{0}Service' -f $data.Metadata.Name)
Add-Line('    {')

if ($data.Metadata.OperationType -eq 'ALL') {
    Add-Line('        /// <summary>')
    Add-Line('        /// {0}' -f $data.Metadata.ProcedureDescription)
    Add-Line('        /// </summary>')
    Add-Line('        /// <param name="input">vstupní objekt</param>')
    Add-Line('        /// <returns>kolekce výstupních objektů</returns>')
    Add-Line('        ModelCoreResult<ICollection<{1}{0}OutputModel>> {1}({1}{0}InputModel input);' -f $data.Metadata.Name, $data.Metadata.Prefix)
}
elseif ($data.Metadata.OperationType -eq 'BLANK') {
    # nic
}
else {
    Add-Line('        /// <summary>')
    Add-Line('        /// {0}' -f $data.Metadata.ProcedureDescription)
    Add-Line('        /// </summary>')
    Add-Line('        /// <param name="input">vstupní objekt</param>')
    Add-Line('        /// <returns>výstupní objekt</returns>')
    Add-Line('        ModelCoreResult<{1}{0}OutputModel> {1}({1}{0}InputModel input);' -f $data.Metadata.Name, $data.Metadata.Prefix)
}

# ukonceni tridy 
Add-Line('    }')
Add-Line('}')

# vypisu builder do hostu
Out-Builder