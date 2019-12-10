param (
    [Parameter(ValueFromPipeline = $true)]$data
)

# inicializace builderu
Initialize-Builder

# generated
Get-GenerateLine $data

$table = $data.Metadata.ProcedureName.Substring(0, $data.Metadata.ProcedureName.IndexOf('_',3)).ToLower()

# usingy
Add-Line('using {0}.Controllers.Common;'-f $data.Metadata.AppNamespace, $data.Metadata.Modules, $data.Metadata.PluralName)
Add-Line('using {0}.Controllers.Shared.History;'-f $data.Metadata.AppNamespace, $data.Metadata.Modules, $data.Metadata.PluralName)
#Add-Line('using {0}.Controllers.{1}.{2}{3};' -f $data.Metadata.AppNamespace, $data.Metadata.Modules, $data.Metadata.PluralName, (('.'+$data.Metadata.Prefix),'')[$data.Metadata.OperationType -eq 'BLANK'])
Add-Line('using {0}.Mvc.Common;'-f $data.Metadata.AppNamespace, $data.Metadata.Modules, $data.Metadata.PluralName)
Add-Line('using System.Web.Mvc;')

Add-Line('')

# hlavicka
Add-Line('namespace {0}.Controllers.{1}.{2}' -f $data.Metadata.AppNamespace, $data.Metadata.Modules, $data.Metadata.PluralName)

Add-Line('{')
Add-Line('    /// <summary>')
Add-Line('    /// Implementace kontroleru pro entitu - {0}' -f $data.Metadata.Description)
Add-Line('    /// </summary>')
Add-Line('    public partial class {0}Controller : BaseController' -f $data.Metadata.Name)
Add-Line('    {')

if ($data.Metadata.OperationType -ne 'BLANK') {

    # Buildery
    Add-Line('        /// <summary>')
    Add-Line('        /// Historie změn')
    Add-Line('        /// </summary>')
    Add-Line('        /// <param name="id">id</param>')
    Add-Line('        /// <returns>View</returns>')
    Add-Line('        public ActionResult History(int id)' -f $data.Metadata.Name, $data.Metadata.Prefix)
    Add-Line('        {')
    Add-Line('            return AsView(Handler.Get<HistorySharedBuilder>().Build(new HistorySharedFilterModel {{ ID_Object = id, ID_EntityType = "{2}" }}));' -f $data.Metadata.Name, $data.Metadata.Prefix, $table)
    Add-Line('        }')
}

# ukonceni tridy 
Add-Line('    }')
Add-Line('}')

# vypisu builder do hostu
Out-Builder
