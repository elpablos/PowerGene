--declare @ID_Table nvarchar(255) = 'EM_EmployeeWork'
--declare @Name nvarchar(255) = 'EM_EmployeeWork_NEW'
--declare @Command nvarchar(255) = 'CREATE'
--declare @CreateCommand bit = 0
----------
-- synchronizace kodu se SF: 28.7.2014
-- upraveno: 28.5.2015

declare @SQL varchar(max)
declare @IsVCID bit

-- informace o tabulce
declare @ID_TableParent varchar(50), @ColumnTableParent varchar(50), @Name nvarchar(255)
select
  @ID_TableParent=ID_TableParent,
  @ColumnTableParent='ID_' + right(ID_TableParent, len(ID_TableParent)-3),
  @Name=[CR_Table].ID + '_NEW'+IsNull('_'+right(ID_TableParent, len(ID_TableParent)-3), '')
from [CR_Table] where ID=@ID_Table

set @SQL = '/* Založení záznamu v tabulce ' + @ID_Table + ' */
' + @Command + ' PROCEDURE ' + @Name + '
@ID_Login GUID'

declare @Column varchar(255), @Type varchar(255), @Length varchar(255), @Precision int, @Scale int, @Nullable bit, @OrderGroup int

-- input parameters
declare tbl cursor local forward_only static
for select
	col.name, types.name, col.max_length, col.precision, col.scale, col.is_nullable,
	-- poradi sloupcu v procedure: 1) ID nadrizene tabulky 2) Ostatni 3) ID tabulky 
	'ordergroup'=case
		when col.name=@ColumnTableParent then 1
		when col.name='ID' then 3
		else 2
	end
from
  sys.tables as tables
  inner join sys.columns as col on tables.object_id=col.object_id
  inner join sys.types as types on col.system_type_id=types.system_type_id and col.user_type_id=types.user_type_id
  left join sys.default_constraints on col.object_id=sys.default_constraints.parent_object_id and sys.default_constraints.parent_column_id=col.column_id
where
	tables.name=@ID_Table
	and col.is_computed=0
	and col.name<>'IsActive'
	and sys.default_constraints.name is null -- sloupec s defaultem do new procedury nedavame
order by ordergroup, col.column_id

open tbl
fetch next from tbl into @Column, @Type, @Length, @Precision, @Scale, @Nullable, @OrderGroup
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

		-- Nepovinny sloupec
		if @Nullable=1
		begin
			set @SQL = @SQL + ' = null'
		end
		
		-- Ciselne ID nastavim jako vystupni parametr
		if @Column='ID'
		begin
			if @Type in ('int', 'ID')
			begin
				set @IsVCID=0
				set @SQL = @SQL + ' = null out'
			end else begin
				set @IsVCID=1
			end
		end
	end
	fetch next from tbl into @Column, @Type, @Length, @Precision, @Scale, @Nullable, @OrderGroup
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
set @Message = ''Při založení objektu '+@ID_Table+' nastala chyba''
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

-- validace dat
declare @Messages ValidateMessages
insert into @Messages
exec ' + @ID_Table + '_VALIDATE
	@ID_Login=@ID_Login,
	@ID_Action=''' + @Name + ''''

	-- input parameters
	declare tbl cursor local forward_only static
	for select
		col.name,
		'ordergroup'=case when col.name=@ColumnTableParent then 1 else 2 end,
		types.name
	from
		sys.tables as tables
		inner join sys.columns as col on tables.object_id=col.object_id
		inner join sys.types as types on col.system_type_id=types.system_type_id and col.user_type_id=types.user_type_id
		left join sys.default_constraints on col.object_id=sys.default_constraints.parent_object_id and sys.default_constraints.parent_column_id=col.column_id
	where
		tables.name=@ID_Table
		and col.is_computed=0
		and col.name<>'IsActive'
		and sys.default_constraints.name is null -- sloupec nema default
	order by ordergroup, col.column_id

	open tbl
	fetch next from tbl into @Column, @OrderGroup, @Type
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
		fetch next from tbl into @Column, @OrderGroup, @Type
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
end'
end

set @SQL += '

-- vložení záznamu do tabulky
'

-- GPS position
declare tbl cursor local forward_only static
for select col.name
from
	sys.tables as tables
	inner join sys.columns as col on tables.object_id=col.object_id
	inner join sys.types as types on col.system_type_id=types.system_type_id and col.user_type_id=types.user_type_id
	left join sys.default_constraints on col.object_id=sys.default_constraints.parent_object_id and sys.default_constraints.parent_column_id=col.column_id
where
	tables.name=@ID_Table
	and types.name='geography'
	and col.is_computed=0 -- sloupec neni pocitany
	and sys.default_constraints.name is null -- sloupec nema default
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

set @SQL = @SQL + 'insert into ' + quotename(@ID_Table) + ' ('

declare @SQLValues varchar(8000)
set  @SQLValues=''

declare tbl cursor local forward_only static
for select col.name
from
  sys.tables as tables
  inner join sys.columns as col on tables.object_id=col.object_id
  left join sys.default_constraints on col.object_id=sys.default_constraints.parent_object_id and sys.default_constraints.parent_column_id=col.column_id
where
	tables.name=@ID_Table
	and col.is_computed=0
	and col.name<>'IsActive'
	and (col.name<>'ID' or @IsVCID=1)
	and sys.default_constraints.name is null -- sloupec nema default

open tbl
fetch next from tbl into @Column
while (@@fetch_status=0)
begin
	set @SQL = @SQL + '[' + @Column + '], '
	set  @SQLValues =  @SQLValues + '@' + @Column + ', '
	Fetch next from tbl into @Column
end
close tbl
deallocate tbl

-- uriznu posledni carky
set @SQL = left(@SQL, len(@SQL)-1)
set @SQLValues = left(@SQLValues, len(@SQLValues)-1)

set @SQL = @SQL + ')
values (' + @SQLValues + ')

if @@error <> 0
	goto FAILED
'

if @IsVCID=0
begin
	set @SQL = @SQL + '
set @ID=@@IDENTITY
'
end

set @SQL = @SQL + '
commit tran
return 0

FAILED:
rollback tran
raiserror (@Message, 16, 1)
return 1

END
'

select 'SQL'=@SQL
-- print @SQL