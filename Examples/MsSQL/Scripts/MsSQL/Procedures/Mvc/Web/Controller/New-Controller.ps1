param (
    [Parameter(ValueFromPipeline = $true)]$data
)

# inicializace builderu
Initialize-Builder

# generated
Get-GenerateLine $data

# usingy
Add-Line('using {0}.Controllers.Common;'-f $data.Metadata.AppNamespace, $data.Metadata.Modules, $data.Metadata.PluralName)
Add-Line('using {0}.Controllers.{1}.{2}{3};' -f $data.Metadata.AppNamespace, $data.Metadata.Modules, $data.Metadata.PluralName, (('.'+$data.Metadata.Prefix),'')[$data.Metadata.OperationType -eq 'BLANK'])
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
    if ($data.Metadata.OperationType -eq 'ALL') {

        Add-Line('        /// <summary>')
        Add-Line('        /// {0}' -f $data.Metadata.ProcedureDescription)
        Add-Line('        /// </summary>')
        Add-Line('        /// <param name="model">filtr</param>')
        Add-Line('        /// <returns>View</returns>')
        Add-Line('        public ActionResult {2}({1}{0}FilterModel model)' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata.PrefixExtend)
        Add-Line('        {')
        Add-Line('            return AsView(Handler.Get<{1}{0}Builder>().Build(model));' -f $data.Metadata.Name, $data.Metadata.Prefix)
        Add-Line('        }')
    }
    elseif ($data.Metadata.OperationType -eq 'NEW') {
        Add-Line('        /// <summary>')
        Add-Line('        /// {0}' -f $data.Metadata.ProcedureDescription)
        Add-Line('        /// </summary>')
        Add-Line('        /// <returns>View</returns>')
        Add-Line('        public ActionResult {1}()' -f $data.Metadata.Name, $data.Metadata.Prefix)
        Add-Line('        {')
        Add-Line('            return AsView(Handler.Get<{1}{0}Builder>().Build());' -f $data.Metadata.Name, $data.Metadata.Prefix)
        Add-Line('        }')
        Add-Line('')
    }
    elseif  ($data.Metadata.OperationType -in ('EDIT','DETAIL')) {
        Add-Line('        /// <summary>')
        Add-Line('        /// {0}' -f $data.Metadata.ProcedureDescription)
        Add-Line('        /// </summary>')
        Add-Line('        /// <param name="id">Id</param>')
        Add-Line('        /// <returns>View</returns>')
        Add-Line('        public ActionResult {1}(int id)' -f $data.Metadata.Name, $data.Metadata.Prefix)
        Add-Line('        {')
        Add-Line('            return AsView(Handler.Get<{1}{0}Builder>().Build(id));' -f $data.Metadata.Name, $data.Metadata.Prefix)
        Add-Line('        }')
        Add-Line('')
    }

    if ($data.Metadata.OperationType -in ('DETAIL') -and $data.Metadata.Prefix -eq 'DetailHeader') {
        Add-Line('        /// <summary>')
        Add-Line('        /// {0}' -f $data.Metadata.ProcedureDescription)
        Add-Line('        /// </summary>')
        Add-Line('        /// <param name="id">Id</param>')
        Add-Line('        /// <returns>View</returns>')
        Add-Line('        public ActionResult PartialMenu(int id)' -f $data.Metadata.Name, $data.Metadata.Prefix)
        Add-Line('        {')
        Add-Line('            return AsPartialView(Handler.Get<{1}{0}Builder>().Build(id), "_PartialMenu{0}");' -f $data.Metadata.Name, $data.Metadata.Prefix)
        Add-Line('        }')
        Add-Line('')
    }

    # validate buildery
    if  ($data.Metadata.OperationType -in ('NEW')) {
        Add-Line('        /// <summary>')
        Add-Line('        /// {0}' -f $data.Metadata.ProcedureDescription)
        Add-Line('        /// Pomocné volání kvůli validacím')
        Add-Line('        /// </summary>')
        Add-Line('        /// <param name="id">Id</param>')
        Add-Line('        /// <returns>View</returns>')
        Add-Line('        protected ActionResult {1}Model({1}{0}Model model)' -f $data.Metadata.Name, $data.Metadata.Prefix)
        Add-Line('        {')
        Add-Line('            return AsView(Handler.Get<{1}{0}Builder>().Build(model));' -f $data.Metadata.Name, $data.Metadata.Prefix)
        Add-Line('        }')
        Add-Line('')
    }

    # Handlery
    if ($data.Metadata.OperationType -eq 'DEL') {
        Add-Line('        /// <summary>')
        Add-Line('        /// {0}' -f $data.Metadata.ProcedureDescription)
        Add-Line('        /// </summary>')
        Add-Line('        /// <returns>View</returns>')
        Add-Line('        public ActionResult {1}(int id)' -f $data.Metadata.Name, $data.Metadata.Prefix)
        Add-Line('        {')
        Add-Line('            return AsView(Handler.Get<{1}{0}Handler>().Handle(id), RedirectToAction("Index", "{0}"));' -f $data.Metadata.Name, $data.Metadata.Prefix)
        Add-Line('        }')
        Add-Line('')
    }
    elseif  ($data.Metadata.OperationType -in ('NEW')) {
        Add-Line('        /// <summary>')
        Add-Line('        /// {0}' -f $data.Metadata.ProcedureDescription)
        Add-Line('        /// </summary>')
        Add-Line('        /// <returns>View</returns>')
        Add-Line('        [HttpPost]')
        Add-Line('        [ValidateAntiForgeryToken]')
        Add-Line('        public ActionResult {1}({1}{0}Model model)' -f $data.Metadata.Name, $data.Metadata.Prefix)
        Add-Line('        {')
        Add-Line('            return AsView(Handler.Get<{1}{0}Handler>().Handle(model), RedirectToAction("Index", "{0}"), {1}Model(model));' -f $data.Metadata.Name, $data.Metadata.Prefix)
        Add-Line('        }')
        Add-Line('')
    }
    elseif  ($data.Metadata.OperationType -in ('EDIT')) {
        Add-Line('        /// <summary>')
        Add-Line('        /// {0}' -f $data.Metadata.ProcedureDescription)
        Add-Line('        /// </summary>')
        Add-Line('        /// <returns>View</returns>')
        Add-Line('        [HttpPost]')
        Add-Line('        [ValidateAntiForgeryToken]')
        Add-Line('        public ActionResult {1}({1}{0}Model model)' -f $data.Metadata.Name, $data.Metadata.Prefix)
        Add-Line('        {')
        Add-Line('            return AsView(Handler.Get<{1}{0}Handler>().Handle(model), RedirectToAction("Edit", "{0}", new {{ id = model.Id }}));' -f $data.Metadata.Name, $data.Metadata.Prefix)
        Add-Line('        }')
        Add-Line('')
    }
}

# ukonceni tridy 
Add-Line('    }')
Add-Line('}')

# vypisu builder do hostu
Out-Builder