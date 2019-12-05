param (
    [Parameter(ValueFromPipeline = $true)]$data
)

# inicializace builderu
Initialize-Builder

# generated
Get-GenerateLine $data

# usingy
Add-Line('@model {0}.Modules.Shared.History.HistorySharedModel' -f $data.Metadata.AppNamespace)
Add-Line('@{')
Add-Line('  ViewBag.Title = $"{{{0}.Resources.Dictionary.Global_History}}";' -f $data.Metadata.AppNamespace)
Add-Line('}');

Add-Line('')

# partialMenu
Add-Line('@Html.Action("PartialMenu", new { id = Url.RequestContext.RouteData.Values["id"] })')

Add-Line('<div class="container">')
Add-Line('  <div class="tab-content">')
Add-Line('    <div class="tab-pane active" id="detail" role="tabpanel">')
Add-Line('      @using (Html.BeginForm("History", "{0}", FormMethod.Post, htmlAttributes: new {{ @class = "dataTables" }}))' -f $obj.Metadata.Name)
Add-Line('      {')
Add-Line('        <div class="row align-items-center">')
Add-Line('          <div class="col-12 col-md-6 mb-20px">')
Add-Line('            <h1 class="h2 mb-0">')
Add-Line('              <a href="@Url.Action("Index", "{0}")" class="no-underline" title="@{1}.Resources.Dictionary.Global_Button_Back">' -f $obj.Metadata.Name, $data.Metadata.AppNamespace)
Add-Line('                <span class="icon-svg icon-svg--angle-l text-primary">')
Add-Line('                  <svg class="icon-svg__svg" xmlns:xlink="http://www.w3.org/1999/xlink">')
Add-Line('                    <use xlink:href="@Url.Content("~/img/bg/icons-svg.svg#icon-angle-l")" x="0" y="0" width="100%" height="100%"></use>')
Add-Line('                  </svg>')
Add-Line('                </span>')
Add-Line('              </a>')
Add-Line('              @{ Model.DocumentPhoto.CssClass = "avatar avatar--rounded"; }')
Add-Line('              @Html.Partial("_DocumentPhoto", Model.DocumentPhoto)')
Add-Line('              <span class="h2">@ViewBag.Title</span>')
Add-Line('            </h1>')
Add-Line('')
Add-Line('          </div>')
Add-Line('          <div class="col-12 col-md-6 d-none d-md-block">')
Add-Line('')
Add-Line('            @Html.Partial("_DataTableExport")')
Add-Line('          </div>')
Add-Line('        </div>')
Add-Line('        @Html.Partial("~/Views/Shared/_HistoryFilter.cshtml", Model.Filter)')
Add-Line('')
Add-Line('        @Html.Partial("~/Views/Shared/_HistoryItems.cshtml", Model.Items)')
Add-Line('      }')
Add-Line('    </div>')
Add-Line('  </div>')
Add-Line('</div>')

# vypisu builder do hostu
Out-Builder