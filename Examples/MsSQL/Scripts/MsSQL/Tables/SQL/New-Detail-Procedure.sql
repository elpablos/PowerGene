--declare @ID_Table nvarchar(255) = 'User'
--declare @Name nvarchar(255) = 'User_DETAIL'
--declare @Command nvarchar(255) = 'CREATE'
--declare @CreateCommand bit = 0
--------------------
-- synchronizace kodu se SF: 28.7.2014
-- upraveno: 28.05.2015

declare @SQL varchar(8000)

-- informace o nadrizene tabulce
declare @ID_TableParent IDVC, @ColumnTableParent varchar(255), @IsActionParentTable bit, @Name nvarchar(255)
select
	@ID_TableParent=ID_TableParent,
    @ColumnTableParent='ID_' + right(ID_TableParent, len(ID_TableParent)-3),
    @Name=[CR_Table].ID + '_DETAIL'+IsNull('_'+right(ID_TableParent, len(ID_TableParent)-3), ''),
	@IsActionParentTable=[CR_Table].IsActionParent
from [CR_Table]
where ID=@ID_Table

set @SQL = '/* Načtení detailních informací o záznamu v tabulce ' + @ID_Table + ' */
' + @Command + ' PROCEDURE ' + @Name + '
@ID_Login GUID'

-- parametr ID
declare @Column varchar(255), @Type varchar(255), @Length varchar(255), @RefAlias varchar(255)
select @Column=syscolumns.name, @Type=systypes.name, @Length=syscolumns.length
from
  syscolumns
  inner join systypes on systypes.xtype=syscolumns.xtype
where syscolumns.id=OBJECT_ID(N'[dbo].[' + @ID_Table + ']')
	  and syscolumns.name='ID'
set @SQL = @SQL + ',
@' + @Column + ' ' + @Type
if @Type in ('nvarchar','varchar') set @SQL = @SQL +'('+@Length+')'
set @SQL = @SQL + '
AS
BEGIN

/* Generated */

declare @Error int, @Message Note
set @Message = ''Při načtení objektu '+@ID_Table+' nastala chyba''
'

-- action
if exists(select * from [CR_Table] where ID=@ID_Table)
begin
	set @SQL = @SQL + '
-- oprávnění k akci
exec @Error='+@ID_Table+'_ACTION @ID_Login=@ID_Login, @ID=@ID, @ID_Action='''+@Name+'''
if @Error<>0
	goto FAILED
'
end

set @SQL = @SQL + '
-- načtu informace o záznamu
select
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
where
	sys.tables.name=@ID_Table
	and COL_NAME(fc.parent_object_id, fc.parent_column_id)<>'ID') -- Vynecham PK, ktere jsou zaroven FK (napriklad: WG_WebServiceFunctionWebService.ID)
	
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
declare @FK varchar(255), @RefTable varchar(255), @RefColumn varchar(255), @IsNullable bit
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
	and COL_NAME(fc.parent_object_id, fc.parent_column_id)<>'ID' -- Vynecham PK, ktere jsou zaroven FK (napriklad: WG_WebServiceFunctionWebService.ID)

open tbl
fetch next from tbl into @Column, @RefTable, @RefColumn, @IsNullable
while (@@fetch_status=0)
  begin
    set @RefAlias = right(@Column, len(@Column)-3)
	set @SQL = @SQL + '
	' + case when @IsNullable=0 then 'inner' else 'left' end + ' join '+ quotename(@RefTable) +
	case when (@RefTable<>@RefAlias) then ' as '+@RefAlias else '' end + ' on '+ quotename(@ID_Table)+'.'+@Column+'='+quotename(@RefAlias)+'.'+@RefColumn+''
    fetch next from tbl into @Column, @RefTable, @RefColumn, @IsNullable
  end
close tbl
deallocate tbl

set @SQL = @SQL+'
where ' 

if exists(select * from sys.tables as tables inner join sys.columns as col on tables.object_id=col.object_id
          where tables.name=@ID_Table and col.name='IsActive')
begin
	set @SQL = @SQL + quotename(@ID_Table) + '.IsActive=1 and '
end

set @SQL = @SQL + quotename(@ID_Table) + '.ID=@ID

return 0
FAILED:
raiserror (@Message, 16, 1)
return 1

END
'

select 'SQL'=@SQL