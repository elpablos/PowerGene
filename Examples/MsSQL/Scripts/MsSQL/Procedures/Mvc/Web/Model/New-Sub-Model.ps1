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

 if ($data.Metadata.OperationType -eq 'ALL') {
    # lists
    Add-Line('        /// <summary>')
    Add-Line('        /// Položky' -f $data.Metadata.ProcedureDescription)
    Add-Line('        /// </summary>')
    Add-Line('        public ICollection<{1}{0}ItemModel> Items {{ get; set; }}' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
    Add-Line('')

    Add-Line('        /// <summary>')
    Add-Line('        /// Položky pro přidání - nevlastněné položky' -f $data.Metadata.ProcedureDescription)
    Add-Line('        /// </summary>')
    Add-Line('        public ICollection<{1}{0}ItemModel> LinkItems {{ get; set; }}' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
    Add-Line('')

    Add-Line('        /// <summary>')
    Add-Line('        /// Položky pro odebrání - vlastněné položky' -f $data.Metadata.ProcedureDescription)
    Add-Line('        /// </summary>')
    Add-Line('        public ICollection<{1}{0}ItemModel> UnlinkItems {{ get; set; }}' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
    Add-Line('')

    Add-Line('        /// <summary>')
    Add-Line('        /// Action' -f $data.Metadata.ProcedureDescription)
    Add-Line('        /// </summary>')
    Add-Line('        public string ActionName {{ get; set; }}' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
    Add-Line('')

    Add-Line('        /// <summary>')
    Add-Line('        /// Controller' -f $data.Metadata.ProcedureDescription)
    Add-Line('        /// </summary>')
    Add-Line('        public string ControllerName {{ get; set; }}' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
    Add-Line('')

    Add-Line('        /// <summary>')
    Add-Line('        /// Celkem záznamů' -f $data.Metadata.ProcedureDescription)
    Add-Line('        /// </summary>')
    Add-Line('        public int TotalRows {{ get; set; }}' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
    Add-Line('')

    Add-Line('        /// <summary>')
    Add-Line('        /// ID vyjížděcího formuláře' -f $data.Metadata.ProcedureDescription)
    Add-Line('        /// </summary>')
    Add-Line('        public int ID_PopupToggle {{ get; set; }}' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
    Add-Line('')


 } else {
    # id
    Add-Line('        /// <summary>')
    Add-Line('        /// Id - {0}' -f $data.Metadata.ProcedureDescription)
    Add-Line('        /// </summary>')
    Add-Line('        public int Id {{ get; set; }}' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
    Add-Line('')

    #sloupce
    $columns = ($data.OutputColumns.GetEnumerator(), $data.InputColumns.GetEnumerator())[$data.Metadata.OperationType -in ('NEW', 'DEL', 'EDIT')]
    foreach ($column in $columns)
    {  
        if ($column.Value.Name -eq 'ID_Login') {
            continue;
        }

        #$type = '{0}{1}' -f $column.Value.Type, ('','?')[$column.Value.IsNullable -eq $true]
        $type = '{0}{1}' -f $column.Value.Type, ('?','')[$column.Value.Type -in ('Guid', 'string')]
        $name = If ($column.Value.Name.StartsWith('ID_')) {$column.Value.Name.SubString(3)} else {$column.Value.Name}


        if ($column.Value.Name -eq 'ID_Login' -or $column.Value.Name -eq 'ID') {
            # id je vygenerovany
        } elseif ($column.Value.TableName -eq $obj.Metadata.Table) {
             # pouziju Filter.ID_Parent
        } elseif ($obj.Metadata.TableRelation.endswith($column.Value.TableName)) {
            # pouzije se Id
        } else {
            Add-Line('        /// <summary>')
            Add-Line('        /// {0}' -f $column.Value.Description)
            Add-Line('        /// </summary>')

            # properta
            Add-Line('        [DisplayName("{0}")]' -f $column.Value.Description)
            Add-Line('        //[Display(Name = nameof(Resources.Dictionary.{0}_{1}_{2}), ResourceType = typeof(Resources.Dictionary))]' -f $data.Metadata.Modules, $data.Metadata.PluralName, $name)
            Add-Line('        public {0} {1} {{ get; set; }}' -f $type, ($column.Value.Name, 'Id')[$column.Value.Name -eq 'ID'])
            Add-Line('')

            if ($column.Value.IsFk -eq $true -and $data.Metadata.OperationType -in ('NEW', 'DEL', 'EDIT')) {
                Add-Line('        /// <summary>')
                Add-Line('        /// Seznam - {0}' -f $column.Value.Description)
                Add-Line('        /// </summary>')

                # properta
                Add-Line('        public ICollection<SelectListItem> {0} {{ get; set; }}' -f $column.Value.ListName)
                Add-Line('')
            }
        }

    }
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
 if ($data.Metadata.OperationType -eq 'ALL') {
    Add-Line('            Items = new List<{1}{0}ItemModel>();' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
    Add-Line('            LinkItems = new List<{1}{0}ItemModel>();' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
    Add-Line('            UnlinkItems = new List<{1}{0}ItemModel>();' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata)
 } else {

    if ($column.Value.Name -eq 'ID_Login' -or $column.Value.Name -eq 'ID') {
        # id je vygenerovany
    } elseif ($column.Value.TableName -eq $obj.Metadata.Table) {
            # pouziju Filter.ID_Parent
    } elseif ($obj.Metadata.TableRelation.endswith($column.Value.TableName)) {
        # pouzije se Id
    } else {

        $columns = $data.InputColumns.GetEnumerator()
        foreach ($column in $columns)
        {
            if ($column.Value.IsFk -eq $true) {
                Add-Line('            {0} = new List<SelectListItem>();' -f $column.Value.ListName)
            }
        }
    }
 }

# filter
Add-Line('            Filter = new List{2}{0}FilterModel();' -f $data.Metadata.Name, $data.Metadata.Prefix, $data.Metadata.TableRelation)

Add-Line('        }')

# ukonceni tridy 
Add-Line('    }')
Add-Line('}')

# vypisu builder do hostu
Out-Builder
