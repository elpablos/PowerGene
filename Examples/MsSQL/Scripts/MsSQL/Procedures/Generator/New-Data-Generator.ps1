param (
    [Parameter(ValueFromPipeline = $true)]$data = $null
)

# connString
$conn = new-object System.Data.SqlClient.SqlConnection $data.Metadata.ConnectionString
$conn.Open()

$proc = ($data.ProcessItem.GetEnumerator() | Select-Object -first 1).Value["Name"]

$table = $proc.Substring(0, $proc.IndexOf('_',3)) # "CR_CompanyContact"
$tablename = $proc.Substring(3, $proc.IndexOf('_',3)-3)
$defaultLogin = ' @ID_Login="10000000-0000-0000-0000-000000000001"'
$pluralName = Get-Pluralize $tablename
$description = ''
$tablerelationid = ''
$tableid = $tablename
$modules = 'Core'
$postfix = ''

# $pluralName = 'Companies'

## query & cmd
$q = (Get-Content .\Scripts\MsSQL\Procedures\SQL\New-Data-Generator.sql -Encoding UTF8) -join "`n"
$cmd = new-object System.Data.SqlClient.SqlCommand($q, $conn)

$cmd.Parameters.AddWithValue('@table', $table) | Out-Null
$cmd.Parameters.AddWithValue('@action', $proc) | Out-Null

$reader = $cmd.ExecuteReader() 
$alterprefix = $false
$alterTable = $tablename

if ($reader.Read()) {
    
    $description = $reader['TableName']
    $procedureDescription = $reader['ActionName']
    $modules = $reader['Module']

    if ($reader['ID'] -ne $table) {
        $alterprefix = $true
    }

    if (!([DBNull]::Value).Equals($reader['ID_TableRelation'])) {
        $tablerelationid = $reader['ID_TableRelation'].ToString()
        $tablerelationname = $tablerelationid.Substring(3)
    }

    # meh?
    $table = $reader['ID']
    $tablename = $table.Substring(3)
    $pluralName = Get-Pluralize $tablename
    $tableid = $tablename
}

$reader.Close()

# local variables

$prefix = ''
$prefixType = ''
$operationType = ''

if ($proc.Contains('ALL')) {
    $prefix = 'List'
    $operationType = 'ALL'
} elseif ($proc.Contains('DETAIL')) {
    $prefix = 'Detail'
    $operationType = 'DETAIL'
} elseif ($proc.Contains('NEW')) {
    $prefix = 'Create'
    $operationType = 'NEW'
} elseif ($proc.Contains('EDIT')) {
    $prefix = 'Edit'
    $operationType = 'EDIT'
} elseif ($proc.Contains('DEL')) {
    $prefix = 'Delete'
    $operationType = 'DEL'
} elseif ($proc.Contains('ACTION')) {
    $prefix = 'Action'
    $operationType = 'ACTION'
} elseif ($proc.Contains('VALIDATE')) {
    $prefix = 'Validate'
    $operationType = 'VALIDATE'
}

$prefixType = $prefix
if ($alterprefix) {
    $prefix = $prefix + ($alterTable) + $postfix
} else {
    $prefixStart =  $proc.IndexOf($operationType) + $operationType.Length + 1
    if ($proc.Length -gt $prefixStart) {
        $prefix = $prefix +($proc.Substring($prefixStart))
    }
}

<#-- 
$prefix = 'Create'
$table = 'CR_Company'
$tablename = 'Company'
$pluralName = 'Companies'
--#>

if ($tablerelationid -ne '') {
    $table = $tablerelationid
}

$operationItem = [ordered]@{ }
$operationItem.Metadata = [ordered]@{
    Modules = $modules # Core atd
    Name = $tablename # napr. User
    Table = $tableid # ?? zjistit
    TableRelation = $tablerelationname # nic nebo dle vazeb
    PluralName = $pluralName # napr. Users
    Description = $description # popis modulu
    Prefix = $prefix # List | Detail | Create | Edit | Delete
    PrefixExtend = ($prefix.Replace('List',''), 'Index')[$prefix -eq "List"] # Nahrada za index u listu
    PrefixType = $prefixType # List | Detail | Create | Edit | Delete!
    OperationType = $operationType # ALL | DETAIL | NEW | EDIT | DEL | BLANK
    ProcedureName = $proc
    ProcedureDescription = $procedureDescription # popis procedury
}

$sb = New-Object System.Text.StringBuilder
function Append([string]$txt) {
    $sb.Append($txt) | Out-Null
}

# params
$inputParams = @()
$outputParams = @()
$names = @()
$fks = @()
$nullables = @()

## names
$q = "select 
	c.name,
	'description' = convert(nvarchar(max), ex.value)
from 
	sys.columns c left join sys.extended_properties ex ON  ex.major_id = c.object_id and c.column_id=ex.minor_id
where OBJECT_NAME(c.object_id) = @TableName"

$cmd = new-object System.Data.SqlClient.SqlCommand($q, $conn)
$cmd.Parameters.AddWithValue('@TableName', $table) | Out-Null
$reader = $cmd.ExecuteReader()

while ($reader.Read()){
    $item = New-Object System.Object 

    $item | Add-Member -MemberType NoteProperty -Name "Name" -Value $reader['name']
    $item | Add-Member -MemberType NoteProperty -Name "Description" -Value $reader['description']

    $names+=($item) # pridam do kolekce
}
$reader.Close()


## FKs
$q = "SELECT
        ConstraintName = a.CONSTRAINT_NAME,
        FromTable = c.TABLE_NAME,
        FromColumn = c.COLUMN_NAME,
        ToTable = d.TABLE_NAME,
        ToColumn = d.COLUMN_NAME
        FROM
        INFORMATION_SCHEMA.TABLE_CONSTRAINTS a,
        INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS b,
        INFORMATION_SCHEMA.KEY_COLUMN_USAGE c,
        INFORMATION_SCHEMA.KEY_COLUMN_USAGE d
        WHERE c.TABLE_NAME = @TableName
        and a.CONSTRAINT_NAME = b.CONSTRAINT_NAME
        and a.CONSTRAINT_NAME = c.CONSTRAINT_NAME
        and b.UNIQUE_CONSTRAINT_NAME = d.CONSTRAINT_NAME
        and c.ORDINAL_POSITION = d.ORDINAL_POSITION
        ORDER BY a.CONSTRAINT_NAME, c.ORDINAL_POSITION"

$cmd = new-object System.Data.SqlClient.SqlCommand($q, $conn)
$cmd.Parameters.AddWithValue('@TableName', $table) | Out-Null
$reader = $cmd.ExecuteReader()

while ($reader.Read()){
    $item = New-Object System.Object 

    $item | Add-Member -MemberType NoteProperty -Name "ConstraintName" -Value $reader['ConstraintName']
    $item | Add-Member -MemberType NoteProperty -Name "FromTable" -Value $reader['FromTable']
    $item | Add-Member -MemberType NoteProperty -Name "FromColumn" -Value $reader['FromColumn']
    $item | Add-Member -MemberType NoteProperty -Name "ToTable" -Value $reader['ToTable']
    $item | Add-Member -MemberType NoteProperty -Name "ToColumn" -Value $reader['ToColumn']

    $fks+=($item) # pridam do kolekce
}
$reader.Close()

## nullables
$q = "SELECT COLUMN_NAME, IS_NULLABLE FROM INFORMATION_SCHEMA.Columns where TABLE_NAME = @TableName"

$cmd = new-object System.Data.SqlClient.SqlCommand($q, $conn)
$cmd.Parameters.AddWithValue('@TableName', $table) | Out-Null
$reader = $cmd.ExecuteReader()

while ($reader.Read()){
    $item = New-Object System.Object 

    $item | Add-Member -MemberType NoteProperty -Name "Name" -Value $reader['COLUMN_NAME']
    $item | Add-Member -MemberType NoteProperty -Name "IsNullable" -Value $reader['IS_NULLABLE']

    $nullables+=($item) # pridam do kolekce
}
$reader.Close()

## inputParams
$q = "SELECT PARAMETER_NAME, DATA_TYPE, PARAMETER_MODE, CHARACTER_MAXIMUM_LENGTH
                        FROM INFORMATION_SCHEMA.PARAMETERS
                        where SPECIFIC_NAME=@ProcName
                        order by ORDINAL_POSITION"

$cmd = new-object System.Data.SqlClient.SqlCommand($q, $conn)
$cmd.Parameters.AddWithValue('@ProcName', $proc) | Out-Null
$reader = $cmd.ExecuteReader() 

while ($reader.Read()){
    $item = New-Object System.Object 

    $item | Add-Member -MemberType NoteProperty -Name "Name" -Value $reader['PARAMETER_NAME']
    $item | Add-Member -MemberType NoteProperty -Name "Type" -Value $reader['DATA_TYPE']
    $item | Add-Member -MemberType NoteProperty -Name "Mode" -Value $reader['PARAMETER_MODE']
    $item | Add-Member -MemberType NoteProperty -Name "Length" -Value $reader['CHARACTER_MAXIMUM_LENGTH']

    $inputParams+=($item) # pridam do kolekce

    if ($item.Name.StartsWith('@id', "CurrentCultureIgnoreCase") -and $item.Name -notlike('@ID_Login')) {
        Append($item.Name)
        Append('=0,')
    }
}
$reader.Close()

## outputParams
$q = $proc +' '+ $sb.ToString() + $defaultLogin
$outputParams = @{}

if ($operationType -in ('ALL','DETAIL')) {
    $cmd = new-object System.Data.SqlClient.SqlCommand($q, $conn)
    $reader = $cmd.ExecuteReader() 
    $outputParams = $reader.GetSchemaTable() | Select-Object ColumnName, ColumnOrdinal, AllowDBNull, DataType, DataTypeName, ColumnSize
}

$conn.Close() 

#
# --- DATA ---
#
$data.TempData = [ordered]@{}
$data.TempData.Add($tablename+$prefix, $operationItem)

$operationItem.InputColumns = [ordered]@{}
$operationItem.OutputColumns = [ordered]@{}

foreach ($i in $inputParams) {
    $name = $i.Name.SubString(1)
    $description = $name
    $isIk = $false
    $isNullable = $false
    $isRequired = $false
    $type = $i.Type
    $dbtype = $i.Type
    $listName = ''
    $fktablename = ''

    switch($type) {
        'nvarchar' 
        { 
            $type='string'
            $dbtype='String' 
        }
        'uniqueidentifier'
        { 
            $type='Guid'
            $dbtype='Guid' 
        }
        'int'
        { 
            $type='int'
            $dbtype='Int32' 
        }
        'bigint'
        { 
            $type='int'
            $dbtype='Int64' 
        }
        'bit'
        {
            $type='bool'
            $dbtype='Boolean' 
        }
        'date'
        {
            $type='DateTime'
            $dbtype='DateTime' 
        } 
        'datetime'
        {
            $type='DateTime'
            $dbtype='DateTime' 
        } 
        'time'
        {
            $type='TimeSpan'
            $dbtype='Time' 
        }
        'float'
        {
            $type='float'
            $dbtype='Double' 
        }   
        'decimal'
        {
            $type = 'decimal'
            $dbtype = 'Decimal'
        }
        'varchar' 
        { 
            $type='string'
            $dbtype='String' 
        }
    }

    foreach ($n in $names) {
        if ($name -like $n.Name) {
            $description = $n.Description
            break;
        }
    }

    foreach ($f in $fks) {
        if ($f.FromColumn -like $name) {
            $isIk = $true
            $fktablename = $f.ToTable.Substring(3)
            $listName = Get-Pluralize $fktablename
            break;
        }
    }

    foreach ($n in $nullables) {
        if ($n.Name -like $name) {
            if ($i.Type -ne 'nvarchar' -and $n.IsNullable -like 'YES') {
                $isNullable = $true
            }
            if ($n.IsNullable -like 'NO') {
                $isRequired = $true
            }
            break;
        }
    }

    # top & id
    if ((($name -ilike 'id' -or $name -ilike 'top') -and $type -eq 'int') -and $operationType -eq 'ALL')  {
        $isNullable = $true
    }

    $operationItem.InputColumns.Add($name, [ordered]@{
        Type = $type
        DbType = $dbtype
        IsOutput = $i.Mode.Contains('INOUT')
        IsRequired = $isRequired # povinna polozka [Required]
        IsNullable = $isNullable # nullable - vyuzije se u ?
        IsPK = $name -like 'id'
        IsFk = $isIk
        Description = $description
        Name = $name
        TableName = $fktablename
        ListName = $listName
    })

    if ($i.Mode.Contains('INOUT')) {
        $operationItem.OutputColumns.Add($name, [ordered]@{
            DbType = $dbtype
            Type = $type
            IsOutput = $true
            IsRequired = $true
            IsNullable = $false # nullable - vyuzije se u ?
            IsPK = $name -like 'id'
            IsFk = $isIk
            Description = $description
            Name = $name
            TableName = $fktablename
            ListName = $listName
        })
    }
}

foreach ($o in $outputParams) {
    if ($outputParams.Count -eq 0) {
        break;
    }

    # ColumnName, ColumnOrdinal, AllowDBNull, DataType, DataTypeName, ColumnSize
    $name = $o.ColumnName

    $description = $name
    $isIk = $false
    $listName = ''
    $fktablename = ''

    foreach ($n in $names) {
        if ($name -like $n.Name) {
            $description = $n.Description
            break;
        }
    }

    foreach ($f in $fks) {
        if ($f.FromColumn -like $name) {
            $isIk = $true
            $fktablename = $f.ToTable.Substring(3)
            $listName = Get-Pluralize $fktablename
            break;
        }
    }

    $type = $o.DataTypeName
    $dbtype = $o.Type

    switch($type) {
        'nvarchar' 
        { 
            $type='string'
            $dbtype='String' 
        }
        'uniqueidentifier'
        { 
            $type='Guid'
            $dbtype='Guid' 
        }
        'int'
        { 
            $type='int'
            $dbtype='Int32' 
        }
        'bigint'
        { 
            $type='int'
            $dbtype='Int64' 
        }
        'float'
        {
            $type='float'
            $dbtype='Double' 
        }  
        'bit'
        {
            $type='bool'
            $dbtype='Boolean' 
        } 
        'date'
        {
            $type='DateTime'
            $dbtype='DateTime' 
        } 
        'datetime'
        {
            $type='DateTime'
            $dbtype='DateTime' 
        } 
        'time'
        {
            $type='TimeSpan'
            $dbtype='Time' 
        }
        'float'
        {
            $type='float'
            $dbtype='Double' 
        }
        'decimal'
        {
            $type = 'decimal'
            $dbtype = 'Decimal'
        }
        'varchar' 
        { 
            $type='string'
            $dbtype='String' 
        }
    }

    $operationItem.OutputColumns.Add($name, [ordered]@{
        DbType = $o.DataType.Name
        Type = $type
        IsRequired = ($o.AllowDBNull -eq $false) # povinna polozka [Required]
        IsNullable = $false # nullable - vyuzije se u ?
        IsPK = $name -like 'id'
        IsFk = $isIk
        Description = $description
        Name = $name
        TableName = $fktablename
        ListName = $listName
    })
}

# prekopirovani popisky od FK k jejich DisplayNames (napr. od ID_Invoice do Invoice)
$columns = $operationItem.OutputColumns.GetEnumerator()
$innerColumns = $operationItem.OutputColumns.GetEnumerator()

foreach ($oColumn in $columns) {
    if ($oColumn.Value.Name.StartsWith('ID_')) {
        $innerName = $oColumn.Value.Name.Replace('ID_','')
        
        foreach ($oColumnInner in $innerColumns) {
            if ($oColumnInner.Value.Name -like $innerName) {
                $oColumnInner.Value.Description = $oColumn.Value.Description
                break
            }
        }
    }
}

$columns = $operationItem.InputColumns.GetEnumerator()
$innerColumns = $operationItem.InputColumns.GetEnumerator()

foreach ($oColumn in $columns) {
    if ($oColumn.Value.Name.StartsWith('ID_')) {
        $innerName = $oColumn.Value.Name.Replace('ID_','')
        
        foreach ($oColumnInner in $innerColumns) {
            if ($oColumnInner.Value.Name -like $innerName) {
                $oColumnInner.Value.Description = $oColumn.Value.Description
                break
            }
        }
    }
}

$data