param (
    [Parameter(ValueFromPipeline = $true)]$data
)

# inicializace builderu
Initialize-Builder

# generated
Get-GenerateLine $data

# usingy
Add-Line('using {0}.Controllers.Common;'-f $data.Metadata.AppNamespace, $data.Metadata.Modules, $data.Metadata.PluralName)
Add-Line('using {0}.Modules.{1}.{2}{3};' -f $data.Metadata.AppNamespace, $data.Metadata.Modules, $data.Metadata.PluralName, (('.'+$data.Metadata.TableRelation),'')[$data.Metadata.OperationType -eq 'BLANK'])
Add-Line('using {0}.Mvc.Common;'-f $data.Metadata.AppNamespace, $data.Metadata.Modules, $data.Metadata.PluralName)
Add-Line('using System.Web.Mvc;')

Add-Line('')

# hlavicka
Add-Line('namespace {0}.Modules.{1}.{2}' -f $data.Metadata.AppNamespace, $data.Metadata.Modules, $data.Metadata.PluralName)

Add-Line('{')
Add-Line('    /// <summary>')
Add-Line('    /// Implementace kontroleru pro entitu - {0}' -f $data.Metadata.Description)
Add-Line('    /// </summary>')
Add-Line('    public partial class {0}Controller : BaseController' -f $data.Metadata.Name)
Add-Line('    {')

if ($data.Metadata.OperationType -ne 'BLANK') {

    # Buildery
    if ($data.Metadata.OperationType -eq 'ALL') {

        Add-Line('        /// <summary>')
        Add-Line('        /// {0}' -f $data.Metadata.ProcedureDescription)
        Add-Line('        /// </summary>')
        Add-Line('        /// <param name="model">filtr</param>')
        Add-Line('        /// <returns>View</returns>')
        Add-Line('        public ActionResult {1}({1}{0}FilterModel model)' -f $data.Metadata.Name, $data.Metadata.Prefix)
        Add-Line('        {')
        Add-Line('            CustomId = "ID_Parent";')
        Add-Line('            return AsView(Handler.Get<{1}{0}Builder>().Build(model));' -f $data.Metadata.Name, $data.Metadata.Prefix)
        Add-Line('        }')

        Add-Line('        /// <summary>')
        Add-Line('        /// {0} - partial' -f $data.Metadata.ProcedureDescription)
        Add-Line('        /// </summary>')
        Add-Line('        /// <param name="model">filtr</param>')
        Add-Line('        /// <returns>View</returns>')
        Add-Line('        public PartialViewResult {1}Partial({1}{0}FilterModel model)' -f $data.Metadata.Name, $data.Metadata.Prefix)
        Add-Line('        {')
        Add-Line('            CustomId = "ID_Parent";')
        Add-Line('            return AsPartialView(Handler.Get<{1}{0}Builder>().Build(model), "_Partial{2}");' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata.TableRelation)
        Add-Line('        }')
    } else {
        Add-Line('        /// <summary>')
        Add-Line('        /// {0}' -f $data.Metadata.ProcedureDescription)
        Add-Line('        /// </summary>')
        Add-Line('        /// <returns>View</returns>')
        Add-Line('        public ActionResult {1}({1}{0}Model model)' -f $data.Metadata.Name, $data.Metadata.Prefix)
        Add-Line('        {')
        Add-Line('            CustomId = "ID_Parent";')
        Add-Line('            ModelState.Clear();')
        Add-Line('            return AsPartialView(Handler.Get<{1}{0}Handler>().Handle(model), Handler.Get<List{2}{0}Builder>().Build(model.Filter), "_Partial{2}");' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata.TableRelation)
        Add-Line('        }')
        Add-Line('')
    }
}

# ukonceni tridy 
Add-Line('    }')
Add-Line('}')

# vypisu builder do hostu
Out-Builder
