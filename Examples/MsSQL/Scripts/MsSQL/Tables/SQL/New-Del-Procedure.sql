--declare @ID_Table nvarchar(255) = 'User'
--declare @Name nvarchar(255) = 'User_DEL'
--declare @Command nvarchar(255) = 'CREATE'
--declare @CreateCommand bit = 0
----
-- synchronizace kodu se SF: 28.7.2014
-- upraveno: 28.05.2015

declare @SQL varchar(8000)
declare @IsIsActive bit

-- zda tabulka obsahuje sloupec IsActive
set @IsIsActive=case when exists(select * from syscolumns
where
  syscolumns.id=OBJECT_ID(N'[dbo].[' + @ID_Table + ']')
  and syscolumns.name='IsActive') then 1 else 0 end

-- informace o nadrizene tabulce
declare @ID_TableParent IDVC, @ColumnTableParent varchar(255), @IsAction bit, @IsActionParentTable bit, @Name nvarchar(255)
select
	@ID_TableParent=ID_TableParent,
    @ColumnTableParent='ID_' + right(ID_TableParent, len(ID_TableParent)-3),
    @Name=[CR_Table].ID + '_DEL'+IsNull('_'+right(ID_TableParent, len(ID_TableParent)-3), ''),
	@IsActionParentTable=[CR_Table].IsActionParent
from [CR_Table]
where ID=@ID_Table

-- primary key
declare @Type varchar(255), @Length varchar(255)
select @Type=systypes.name, @Length=syscolumns.length
from
  syscolumns
  inner join systypes on systypes.xtype=syscolumns.xtype
where
  syscolumns.id=OBJECT_ID(N'[dbo].[' + @ID_Table + ']')
  and syscolumns.name='ID'  
  
set @SQL = '/* Smazání záznamu v tabulce ' + @ID_Table + ' */
' + @Command + ' PROCEDURE ' + @Name + '
@ID_Login GUID,
@ID ' + @Type + case when @Type in ('nvarchar', 'varchar') then ' ('+@Length+')' else '' end + '
AS
BEGIN

/* Generated */

begin tran

declare @Error int, @Message Note
set @Message = ''Při smazání objektu '+@ID_Table+' nastala chyba''
'

-- action
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
'
end

if @IsIsActive=1
begin	
	set @SQL = @SQL + '
-- zneplatnění záznamu
update ' + quotename(@ID_Table) + ' set IsActive=0 where ID=@ID
'
end else begin
	-- Tabulka neobsahuje sloupec IsActive
  
	-- delete rows from child tables
    declare @ID_TableChild varchar(255)
	declare tbl cursor local forward_only static
	for select [CR_Table].ID
	from [CR_Table]
	where [CR_Table].ID_TableParent=@ID_Table

	open tbl
	fetch next from tbl into @ID_TableChild
	while (@@fetch_status=0)
	begin
		set @SQL = @SQL + '
-- smažu podřízený záznam
delete from '+quotename(@ID_TableChild)+' where ID_'+@ID_Table+'=@ID
if @@error <> 0
	goto FAILED
'
		fetch next from tbl into @ID_TableChild
	end
	close tbl
	deallocate tbl 
  
  set @SQL = @SQL + '
-- smažu záznam
delete from ' + quotename(@ID_Table) + ' where ID=@ID
'
end

set @SQL = @SQL + 'if @@error <> 0
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