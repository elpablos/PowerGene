--declare @ID_Table nvarchar(255) = 'EM_EmployeeWork'
--declare @Command nvarchar(255) = 'CREATE'
--declare @CreateCommand bit = 0

------
-- synchronizace kodu se SF: 28.7.2014
-- upraveno: 28.5.2015

declare @SQL varchar(8000)

-- informace o tabulce
declare @ID_TableParent varchar(50), @ColumnTableParent varchar(50), @Name nvarchar(255)
select
  @ID_TableParent=ID_TableParent,
  @ColumnTableParent='ID_' + right(ID_TableParent, len(ID_TableParent)-3),
  @Name=[CR_Table].ID + '_ALL'+IsNull('_'+right(ID_TableParent, len(ID_TableParent)-3), '')
from [CR_Table] where ID=@ID_Table

set @SQL = '/* Načtení seznamu záznamů v tabulce ' + @ID_Table + ' */
' + @Command + ' PROCEDURE ' + @Name + '
@ID_Login GUID,
@Top int = 500'

-- filtry
declare @Column varchar(255), @Type varchar(255), @Length varchar(255), @Precision int, @Scale int, @RefAlias varchar(255), @RefTable varchar(255)

declare tbl cursor local forward_only static
for select
	col.name, types.name,
	-- pocitane sloupce maji zadanou velikost -1, pouzije se pro ne max.velikost datoveho typu
	'max_length'=case when col.max_length=-1 then types.max_length else col.max_length end,
	col.precision, col.scale
from
	sys.tables as tables
	inner join sys.columns as col on tables.object_id=col.object_id
	inner join sys.types as types on col.system_type_id=types.system_type_id and col.user_type_id=types.user_type_id
	-- foreign keys
	left join sys.foreign_key_columns AS fc ON COL_NAME(fc.parent_object_id, fc.parent_column_id)=col.name and col.name<>'ID'
	left join sys.foreign_keys AS f ON f.object_id = fc.constraint_object_id and OBJECT_NAME(f.parent_object_id)=tables.name
where
	tables.name=@ID_Table
	-- sloupec je FK nebo nektery z podporovanych sloupcu
	and ((f.parent_object_id is not null and fc.parent_object_id is not null) or col.name in ('ID', 'DisplayName'))
order by col.column_id
open tbl
fetch next from tbl into @Column, @Type, @Length, @Precision, @Scale
while (@@fetch_status=0)
begin
	set @SQL = @SQL + ',
@' + @Column + ' ' + dbo.Install_FullType(@Type, @Length, @Precision, @Scale) + ' = null'
	fetch next from tbl into @Column, @Type, @Length, @Precision, @Scale
end
close tbl
deallocate tbl

set @SQL = @SQL + '
AS
BEGIN

/* Generated */

declare @Error int, @Message Note
set @Message = ''Při načtení objektů '+@ID_Table+' nastala chyba''
select @top=500 where @Top is null
'

-- action + validate
if exists(select * from [CR_Table] where ID=@ID_Table)
begin
	set @SQL = @SQL + '
-- oprávnění k akci
'
	if @ColumnTableParent is null
	begin	
		set @SQL = @SQL + 'exec @Error='+@ID_Table+'_ACTION @ID_Login=@ID_Login, @ID=null, @ID_Action='''+@Name+''''
	end else begin
		set @SQL = @SQL + 'exec @Error='+@ID_TableParent+'_ACTION @ID_Login=@ID_Login, @ID=@'+@ColumnTableParent+', @ID_Action='''+@Name+''''
	end

	set @SQL = @SQL + '
if @Error<>0
  goto FAILED
'
end

set @SQL = @SQL + '
-- vrátim záznamy podle zadaných filtrů
select top (@Top)
	' + quotename(@ID_Table) + '.ID'

-- DisplayName from foreign keys
declare @TableFK table (ColumnName varchar(255), ReferencedDisplayName varchar(255))
insert into @TableFK (ColumnName, ReferencedDisplayName)
(SELECT
	COL_NAME(fc.parent_object_id, fc.parent_column_id) AS ColumnName,
	quotename(right(OBJECT_NAME (f.referenced_object_id), len(OBJECT_NAME (f.referenced_object_id))-3))-- + right(COL_NAME(fc.parent_object_id, fc.parent_column_id), len(COL_NAME(fc.parent_object_id, fc.parent_column_id))-3)
	+ '.' + quotename(sys.columns.name)
FROM
  sys.foreign_keys AS f
  inner join sys.foreign_key_columns AS fc ON f.object_id = fc.constraint_object_id
  inner join sys.tables on sys.tables.object_id=f.parent_object_id
  inner join sys.columns on sys.columns.object_id=f.referenced_object_id and sys.columns.name='DisplayName'
where sys.tables.name=@ID_Table)

-- columns
declare tbl cursor local forward_only static
for select col.name, types.name
from
  sys.tables as tables
  inner join sys.columns as col on tables.object_id=col.object_id
  inner join sys.types as types on col.system_type_id=types.system_type_id and col.user_type_id=types.user_type_id
where
	tables.name=@ID_Table
	and col.name<>'ID'
open tbl
fetch next from tbl into @Column, @Type
while (@@fetch_status=0)
begin
	if @Type='geography'
	begin
		-- GPS pozice
		set @SQL = @SQL + ',
	'''+@Column+'Latitude''='+quotename(@ID_Table)+'.[' + @Column + '].Lat,
	'''+@Column+'Longitude''='+quotename(@ID_Table)+'.[' + @Column + '].Long'
	end else begin
		-- Ostatni typy
		set @SQL = @SQL + ',
	' + quotename(@ID_Table) + '.[' + @Column + ']'

		if exists(select * from @TableFK where ColumnName=@Column)
		begin
			set @SQL = @SQL + ',
	''' + right(@Column, len(@Column)-3) + '''=' + (select ReferencedDisplayName from @TableFK where ColumnName=@Column)
		end
	end
	
	fetch next from tbl into @Column, @Type
end
close tbl
deallocate tbl

set @SQL = @SQL+'
from
	' + quotename(@ID_Table)

-- foreign keys
declare @FK varchar(255), @RefColumn varchar(255), @IsNullable bit
declare tbl cursor local forward_only static for
SELECT
	COL_NAME(fc.parent_object_id, fc.parent_column_id) AS ColumnName,
	OBJECT_NAME (f.referenced_object_id) AS ReferenceTableName,
	COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS ReferenceColumnName,
	sys.columns.is_nullable
FROM
  sys.foreign_keys AS f
  inner join sys.foreign_key_columns AS fc ON f.object_id = fc.constraint_object_id
  inner join sys.tables on sys.tables.object_id=f.parent_object_id
  inner join sys.columns on sys.columns.object_id=fc.parent_object_id and sys.columns.name=COL_NAME(fc.parent_object_id, fc.parent_column_id)
where
  sys.tables.name=@ID_Table

open tbl
fetch next from tbl into @Column, @RefTable, @RefColumn, @IsNullable
while (@@fetch_status=0)
  begin
	print @RefTable + '-' + @Column
    set @RefAlias = IsNull(right(@Column, len(@Column)-3), 'TEST')
	set @SQL = @SQL + '
	' + case when @IsNullable=0 then 'inner' else 'left' end + ' join '+quotename(@RefTable)+
	case when (@RefTable<>@RefAlias) then ' as '+quotename(@RefAlias) else '' end + ' on '+quotename(@ID_Table)+'.'+@Column+'='+quotename(@RefAlias)+'.'+@RefColumn+''
    fetch next from tbl into @Column, @RefTable, @RefColumn, @IsNullable
  end
close tbl
deallocate tbl

set @SQL = @SQL+'
where
	(' + quotename(@ID_Table) + '.ID=@ID or @ID is null)'

-- filtry
declare tbl cursor local forward_only static
for select col.name, types.name, col.max_length
from
	sys.tables as tables
	inner join sys.columns as col on tables.object_id=col.object_id
	inner join sys.types as types on col.system_type_id=types.system_type_id and col.user_type_id=types.user_type_id
	-- foreign keys
	left join sys.foreign_key_columns AS fc ON COL_NAME(fc.parent_object_id, fc.parent_column_id)=col.name and col.name<>'ID'
	left join sys.foreign_keys AS f ON f.object_id = fc.constraint_object_id and OBJECT_NAME(f.parent_object_id)=tables.name
where
	tables.name=@ID_Table
	-- sloupec je FK nebo nektery z podporovanych sloupcu
	and ((f.parent_object_id is not null and fc.parent_object_id is not null) or col.name in ('DisplayName', 'IsActive'))
order by col.column_id
open tbl
fetch next from tbl into @Column, @Type, @Length
while (@@fetch_status=0)
begin
	set @SQL = @SQL + '
	and '
	if @Column='DisplayName'
	begin
		set @SQL = @SQL + '(' + quotename(@ID_Table) + '.' + @Column + ' like ''%''+@' + @Column + '+''%'' or @' + @Column + ' is null)'
	end else begin
		if @Column='IsActive'
		begin
			set @SQL = @SQL + quotename(@ID_Table) + '.' + @Column + '=1'
		end else begin
			-- FK
			set @SQL = @SQL + '(' + quotename(@ID_Table) + '.' + @Column + '=@' + @Column + ' or @' + @Column + ' is null)'
		end
	end
	fetch next from tbl into @Column, @Type, @Length
end
close tbl
deallocate tbl

-- razeni
if exists(select * from syscolumns where syscolumns.id=OBJECT_ID(N'[dbo].' + quotename(@ID_Table)) and syscolumns.name in ('DisplayName', 'Order'))
begin
  set @SQL = @SQL + '
order by '
  declare @IsDisplayName int, @IsOrder int
  set @IsOrder=case when exists(select * from syscolumns where syscolumns.id=OBJECT_ID(N'[dbo].' + quotename(@ID_Table)) and syscolumns.name='Order') then 1 else 0 end
  set @IsDisplayName=case when exists(select * from syscolumns where syscolumns.id=OBJECT_ID(N'[dbo].' + quotename(@ID_Table)) and syscolumns.name='DisplayName') then 1 else 0 end
  
  if @IsOrder=1
	set @SQL = @SQL + quotename(@ID_Table) + '.[Order]'
  if (@IsOrder=1 and @IsDisplayName=1)
	set @SQL = @SQL + ', '
  if @IsDisplayName=1
	set @SQL = @SQL + quotename(@ID_Table) + '.DisplayName'
end

set @SQL = @SQL+'

return 0
FAILED:
raiserror (@Message, 16, 1)
return 1

END
'

select 'SQL'=@SQL
--print @SQL