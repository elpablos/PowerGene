--declare @ID_Table nvarchar(255) = 'Report'
--declare @Name nvarchar(255) = 'Report_VALIDATE'
--declare @Command nvarchar(255) = 'CREATE'
--declare @CreateCommand bit = 0
--------
-- synchronizace kodu se SF: 28.7.2014

declare @SQL varchar(max)
declare @IsVCID bit

declare @ID_TableParent varchar(50), @ColumnTableParent varchar(50)
select
	@ID_TableParent=ID_TableParent,
	@ColumnTableParent='ID_' + right(ID_TableParent, len(ID_TableParent)-3)
from [CR_Table] where ID=@ID_Table

set @SQL = '/* Validace zadaných údajů záznamu v tabulce ' + @ID_Table + ' */
' + @Command + ' PROCEDURE ' + @Name + '
@ID_Login GUID,
@ID_Action IDVC'

declare @Column varchar(255), @IsNullable int, @Type varchar(255), @Length varchar(255), @Precision int, @Scale int

-- input parameters
declare tbl cursor local forward_only static
for select col.name, col.is_nullable, types.name, col.max_length, col.precision, col.scale
from
  sys.tables as tables
  inner join sys.columns as col on tables.object_id=col.object_id
  inner join sys.types as types on col.system_type_id=types.system_type_id and col.user_type_id=types.user_type_id
where
  tables.name=@ID_Table
  and col.is_computed=0
  and col.name<>'IsActive'
  and col.name<>'ID_Entity'
order by col.column_id

open tbl
fetch next from tbl into @Column, @IsNullable, @Type, @Length, @Precision, @Scale
while (@@fetch_status=0)
begin
	if @Type='geography'
	begin
		-- GPS pozice
		set @SQL = @SQL + ',
@'+@Column+'Latitude float = null,
@'+@Column+'Longitude float = null'
	end else begin
		-- Ostatni typy
		set @SQL = @SQL + ',
@' + @Column + ' ' + dbo.Install_FullType(@Type, @Length, @Precision, @Scale)
		set @SQL = @SQL + ' = null'
  end
  fetch next from tbl into @Column, @IsNullable, @Type, @Length, @Precision, @Scale
end
close tbl
deallocate tbl

-- body
set @SQL = @SQL +'
AS
BEGIN

/* Generated */

declare @Messages ValidateMessages

'

-- zjistim, zda je alespon jeden sloupec povinny
if not exists(select col.name
	from
		sys.tables as tables
		inner join sys.columns as col on tables.object_id=col.object_id
		left join sys.default_constraints def on col.object_id=def.parent_object_id and def.parent_column_id=col.column_id
	where
		tables.name=@ID_Table
		and col.is_computed=0
		and col.name not in ('ID', 'IsActive', 'ID_Entity')
		and col.is_nullable=0
		and def.name is null)
begin
	set @SQL = @SQL + '--' -- zakomentuju vlozeni do tabulky @Messages
end

set @SQL = @SQL + 'insert into @Messages (Property, DisplayName, Args)
'

declare @IsFirst bit, @HasDefault bit
set @IsFirst = 1

declare @Description varchar(255)
declare tbl cursor local forward_only static
for
select
	col.name,
	col.is_nullable,
	types.name,
	col.max_length,
	'description' = isnull(convert(varchar(255), ex.value), col.name),
	'HasDefault'=case when sys.default_constraints.name is not null then 1 else 0 end
from
	sys.tables as tables
	inner join sys.columns as col on tables.object_id=col.object_id
	inner join sys.types as types on col.system_type_id=types.system_type_id and col.user_type_id=types.user_type_id
	left join sys.extended_properties ex on  ex.major_id = col.object_id and col.column_id=ex.minor_id
	left join sys.default_constraints on col.object_id=sys.default_constraints.parent_object_id and sys.default_constraints.parent_column_id=col.column_id
where
	tables.name=@ID_Table
	and col.name<>'ID'
	and col.is_computed=0
	and col.name<>'IsActive'
	and col.name<>'ID_Entity'
order by col.column_id

open tbl
fetch next from tbl into @Column, @IsNullable, @Type, @Length, @Description, @HasDefault
while (@@fetch_status=0)
begin
	declare @Comment varchar(255) = ''

	if @IsNullable=1 or @HasDefault=1
	begin
		-- sloupce, ktere povoluji NULL nebo maji zadanou vychozi hodnotu, nejsou povinne
		set @Comment = '--'
	end
	
	if @IsFirst=0
	begin
		set @SQL = @SQL + @Comment + 'union
'
	end
  
  if @Comment=''
		set @IsFirst = 0
  
	set @SQL = @SQL + '
/* ' + @Column + ' */
' + @Comment + 'select ''Property''=''' + @Column + ''', ''DisplayName''=''Pole "' + @Description + '" musí být zadáno'', ''Args''=''''
'

	if @Type in ('varchar', 'IDVC', 'DN', 'Note') and left(@Column,3)<>'ID_'
	begin
		set @SQL = @SQL + @Comment + 'where isnull(@' + @Column + ', '''')=''''
'
	end else if @Type='geography' begin
		set @SQL = @SQL +  @Comment + 'where @' + @Column + 'Latitude is null or @' + @Column + 'Longitude is null
'
	end else begin
		set @SQL = @SQL +  @Comment + 'where '  + case when @ColumnTableParent=@Column then '@ID is null and ' else '' end + '@' + @Column + ' is null
'
	end

  fetch next from tbl into @Column, @IsNullable, @Type, @Length, @Description, @HasDefault
end
close tbl
deallocate tbl

set @sql=@sql+'
select * from @Messages

END
'

select 'SQL'=@SQL