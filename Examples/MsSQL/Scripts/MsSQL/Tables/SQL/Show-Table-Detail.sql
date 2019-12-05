-- declare @name DN = 'CR_User'
declare @Message nvarchar(max) = '' 
DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10)
select @Message = @Message + QUOTENAME(sys.tables.name) +'.'+ QUOTENAME(sys.columns.name) + ', ' +@NewLineChar

from 
    sys.columns 
    inner join sys.tables on sys.tables.object_id=sys.columns.object_id 
where 
    sys.tables.name=@name 

select 'select' + @NewLineChar +LEFT(@Message, LEN(@Message) - 2 - len(@NewLineChar)) + @NewLineChar+ 'from '+ QUOTENAME(@name) as definition 