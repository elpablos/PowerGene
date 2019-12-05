--declare @ID_Table nvarchar(255) = 'User'
--declare @Name nvarchar(255) = 'User_EDIT'
--declare @Command nvarchar(255) = 'CREATE'
--declare @CreateCommand bit = 0
------------------
-- synchronizace kodu se SF: 28.7.2014
-- upraveno: 28.05.2015


declare @SQL Note
  
declare @Column varchar(255), @Type varchar(255), @Length varchar(255), @Precision int, @Scale int, @Nullable bit, @Name nvarchar(255)

-- informace o nadrizene tabulce
declare @ID_TableParent IDVC, @ColumnTableParent varchar(255), @IsActionParentTable bit
select
	@ID_TableParent=ID_TableParent,
    @ColumnTableParent='ID_' + right(ID_TableParent, len(ID_TableParent)-3),
    @Name=[CR_Table].ID + '_EDIT'+IsNull('_'+right(ID_TableParent, len(ID_TableParent)-3), ''),
	@IsActionParentTable=[CR_Table].IsActionParent
from [CR_Table]
where ID=@ID_Table

set @SQL = '/* Editace záznamu v tabulce ' + @ID_Table + ' */
' + @Command + ' PROCEDURE ' + @Name + '
@ID_Login GUID'

-- input parameters
declare tbl cursor local forward_only static
for select col.name, types.name, col.max_length, col.precision, col.scale, col.is_nullable
from
  sys.tables as tables
  inner join sys.columns as col on tables.object_id=col.object_id
  inner join sys.types as types on col.system_type_id=types.system_type_id and col.user_type_id=types.user_type_id
where
	tables.name=@ID_Table
	and col.is_computed=0
	and col.name<>'IsActive'
	and (col.name<>@ColumnTableParent or @ColumnTableParent is null)
order by col.column_id

open tbl
fetch next from tbl into @Column, @Type, @Length, @Precision, @Scale, @Nullable
while (@@fetch_status=0)
begin
	if @Type='geography'
	begin
		-- GPS pozice
		set @SQL = @SQL + ',
@'+@Column+'Latitude float,
@'+@Column+'Longitude float'
	end else begin
		-- Ostatni typy
		set @SQL = @SQL + ',
@' + @Column + ' ' + dbo.Install_FullType(@Type, @Length, @Precision, @Scale)
	end

	-- Nepovinny sloupec
	if @Nullable=1
	begin
		set @SQL = @SQL + ' = null'
	end

	fetch next from tbl into @Column, @Type, @Length, @Precision, @Scale, @Nullable
end
close tbl
deallocate tbl

-- body
set @SQL = @SQL +'
AS
BEGIN

/* Generated */

begin tran

declare @Error int, @Message Note
set @Message = ''Při editaci objektu '+@ID_Table+' nastala chyba''
'

-- action + validate
if exists(select * from [CR_Table] where ID=@ID_Table)
begin
	set @SQL = @SQL + '
-- oprávnění k akci
'
	if @ColumnTableParent is null or @IsActionParentTable=0
	begin
		set @SQL = @SQL + 'exec @Error='+@ID_Table+'_ACTION @ID_Login=@ID_Login, @ID=@ID, @ID_Action='''+@Name+''''
	end else begin
		set @SQL = @SQL + 'declare @'+@ColumnTableParent+' ID = (select '+@ColumnTableParent+' from '+@ID_Table+' where ID=@ID)
exec @Error='+@ID_TableParent+'_ACTION @ID_Login=@ID_Login, @ID=@'+@ColumnTableParent+', @ID_Action='''+@Name+''''
	end

	set @SQL = @SQL + '
if @Error<>0
	goto FAILED

-- validace dat
declare @Messages ValidateMessages
insert into @Messages
exec ' + @ID_Table + '_VALIDATE
	@ID_Login=@ID_Login,
	@ID_Action=''' + @Name + ''''

	-- input parameters
	declare tbl cursor local forward_only static
	for select
		col.name, types.name
	from
		sys.tables as tables
		inner join sys.columns as col on tables.object_id=col.object_id
		inner join sys.types as types on col.system_type_id=types.system_type_id and col.user_type_id=types.user_type_id
	where
		tables.name=@ID_Table
		and col.is_computed=0
		and col.name<>'IsActive'
		and (col.name<>@ColumnTableParent or @ColumnTableParent is null)
	order by col.column_id

	open tbl
	fetch next from tbl into @Column, @Type
	while (@@fetch_status=0)
	begin
		if @Type='geography'
		begin
			-- GPS pozice
			set @SQL = @SQL + ',
	@'+@Column+'Latitude=@'+@Column+'Latitude,
	@'+@Column+'Longitude=@'+@Column+'Longitude'
		end else begin
			-- Ostatni typy
			set @SQL = @SQL + ',
	@' + @Column + '=@' + @Column
		end
		fetch next from tbl into @Column, @Type
	end
	close tbl
	deallocate tbl

	set @SQL = @SQL + '
if @@error<>0
	goto FAILED

if exists(select * from @Messages)
begin
	set @Message = dbo.FN_GetValidationXml(@Messages)
	goto FAILED
end
'
end

set @SQL = @SQL +'
-- editace záznamu
'

-- GPS position
declare tbl cursor local forward_only static
for select col.name
from
	sys.tables as tables
	inner join sys.columns as col on tables.object_id=col.object_id
	inner join sys.types as types on col.system_type_id=types.system_type_id and col.user_type_id=types.user_type_id
where
	tables.name=@ID_Table
	and types.name='geography'
	and col.is_computed=0 -- sloupec neni pocitany
order by col.column_id

open tbl
fetch next from tbl into @Column
while (@@fetch_status=0)
begin
  set @SQL = @SQL + 'declare @'+@Column+' geography
if @'+@Column+'Latitude is not null and @'+@Column+'Longitude is not null
begin
	set @'+@Column+' = geography::Point(@'+@Column+'Latitude, @'+@Column+'Longitude, 4326)
end

'
	fetch next from tbl into @Column
end
close tbl
deallocate tbl

set @SQL = @SQL + 'update ' + quotename(@ID_Table) + '
set	'

declare tbl cursor local forward_only static
for select col.name
from
  sys.tables as tables
  inner join sys.columns as col on tables.object_id=col.object_id
where
	tables.name=@ID_Table
	and col.is_computed=0
	and col.name<>'ID'
	and col.name<>'IsActive'
	and (col.name<>@ColumnTableParent or @ColumnTableParent is null)
order by col.column_id

open tbl
fetch next from tbl into @Column
while (@@fetch_status=0)
begin
	set @SQL = @SQL + '[' + @Column + ']=@' + @Column + ',
	'
	Fetch next from tbl into @Column
end
close tbl
deallocate tbl

set @SQL = left(@SQL, len(@SQL)-3)

set @sql=@sql+'
where ID=@ID

if @@error <> 0
	goto FAILED

commit tran
return 0

FAILED:
rollback tran
raiserror (@Message, 16, 1)
return 1

END
'

select 'SQL'=@SQL