--declare @ID_Table nvarchar(255) = 'CR_User'
--declare @Name nvarchar(255) = 'CR_User_ACTION'
--declare @Command nvarchar(255) = 'ACTION'
--declare @CreateCommand bit = 0
------------
-- upraveno: 15.10.2017

declare @SQL varchar(8000)

declare @ID varchar(50), @DisplayName varchar(255)
declare @Column varchar(255), @Type varchar(255), @Length varchar(255)

set @SQL = '/* Zjištění oprávnění uživatele proti záznamům v tabulce ' + @ID_Table + ' */
' + @Command + ' PROCEDURE ' + @Name + '
@ID_Login GUID'

-- parametr ID
select
	@Column=col.name, @Type=types.name, @Length=col.max_length
from
  sys.tables as tables
  inner join sys.columns as col on tables.object_id=col.object_id
  inner join sys.types as types on col.system_type_id=types.system_type_id and col.user_type_id=types.user_type_id
where
  tables.name=@ID_Table and col.name='ID'

set @SQL = @SQL + ',
@' + @Column + ' ' + @Type
--if @Type='IDVC' set @SQL = @SQL +'('+@Length+')'

set @SQL = @SQL + ',
@ID_Action IDVC,
@IsRaiseError bit = 1
AS
BEGIN

/* Generated */

declare @Error int, @Message Note
set @Message = ''Při zjištění akcí objektu '+@ID_Table+' nastala chyba''

exec @Error=CR_Login_VERIFY @ID=@ID_Login, @ID_Action=@ID_Action
if @Error<>0
begin
  goto FAILED
end

declare @Actions table (ID IDVC, DisplayName DN)

-- načtu seznam možných akcí
if @ID is null
begin
	-- akce nad tabulkou
	insert into @Actions
	select distinct [CR_Action].ID, [CR_Action].DisplayName
	from
		[dbo].[CR_Action_ALL_Tab](@ID_Login, @ID_Action, '''+@ID_Table+''', 0) [CR_Action]
		-- left join [dbo].[CR_Permission_ALL_Login](@ID_Login) [CR_Permission] on 1=1
'

if exists(select * from [CR_Action] where ID_Table=@ID_Table and RequiredRecord=0)
begin
	set @SQL = @SQL + '	where
'
	declare tbl cursor local forward_only static
	for select ID, DisplayName from [CR_Action] where ID_Table=@ID_Table and RequiredRecord=0 order by ID
	
	open tbl
	fetch next from tbl into @ID, @DisplayName
	while (@@fetch_status=0)
	begin
		set @SQL = @SQL + '		-- '+@ID+': '+@DisplayName+'
		([CR_Action].ID='''+@ID+''')

		or

'
		fetch next from tbl into @ID, @DisplayName
	end
	close tbl
	deallocate tbl

	-- oriznu posledni OR
	set @SQL = left(@SQL, len(@SQL)-6)
end

set @SQL = @SQL + 'end else begin
	-- akce nad záznamem
	
	-- ladící volání při generování stránek (taskid#6094)
	if @ID=0
	begin
		insert into @Actions
		select distinct [CR_Action].ID, [CR_Action].DisplayName
		from [dbo].[CR_Action_ALL_Tab](@ID_Login, @ID_Action, '''+@ID_Table+''', 1) [CR_Action]
	end
	
	-- vyhodnocení akcí pro zadaný záznam
	insert into @Actions
	select distinct [CR_Action].ID, [CR_Action].DisplayName
	from
		[dbo].[CR_Action_ALL_Tab](@ID_Login, @ID_Action, '''+@ID_Table+''', 1) [CR_Action]
		cross join '+quotename(@ID_Table)+'
		-- left join [dbo].[CR_Permission_ALL_Login](@ID_Login) [CR_Permission] on 1=1
	where
		'+quotename(@ID_Table)+'.ID=@ID
'

if exists(select * from sys.tables as tables inner join sys.columns as col on tables.object_id=col.object_id
          where tables.name=@ID_Table and col.name='IsActive')
begin
	set @SQL = @SQL + '		and ' + quotename(@ID_Table) + '.IsActive=1
'
end

if exists(select * from [CR_Action] where ID_Table=@ID_Table and RequiredRecord=1)
begin
	set @SQL = @SQL + '		and (

'
	declare tbl cursor local forward_only static
	for select ID, DisplayName from [CR_Action] where ID_Table=@ID_Table and RequiredRecord=1 order by ID
	
	open tbl
	fetch next from tbl into @ID, @DisplayName
	while (@@fetch_status=0)
	begin
		set @SQL = @SQL + '		-- '+@ID+': '+@DisplayName+'
		([CR_Action].ID='''+@ID+''')
		
		or

'
		fetch next from tbl into @ID, @DisplayName
	end
	close tbl
	deallocate tbl

	-- oriznu posledni OR
	set @SQL = left(@SQL, len(@SQL)-9)
	
	set @SQL = @SQL + '		)
'
end

set @SQL = @SQL + 'end

if @IsRaiseError=1
begin
	if not exists(select * from @Actions where ID=@ID_Action)
	begin
		set @Message = ''Nemáte oprávnění k akci '' + @ID_Action + '' nad záznamem ID='' + ISNULL(convert(varchar, @ID), ''NULL'') + ''!''
		goto FAILED
	end
end else begin
	select ID, DisplayName from @Actions order by DisplayName
end

return 0

FAILED:
raiserror (@Message, 16, 1)
return 1

END
'

select 'SQL'=@SQL