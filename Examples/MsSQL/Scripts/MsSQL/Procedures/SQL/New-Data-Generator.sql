-- (CR_Action.ID_TableRelation=CR_Table.ID or CR_Action.ID_Table=CR_Table.ID)
-- declare @table DN = 'CR_Invitation', @action DN = 'CR_Invitation_NEW'
select top 1 * from
(
select CR_Table.ID, CR_Table.DisplayName as TableName, CR_Action.DisplayName as ActionName, CR_Table.ID_Module as Module, CR_Action.ID_TableRelation, 1 as [Priority]
from CR_Table
left join CR_Action on CR_Action.ID_Table=CR_Table.ID and @action is not null
left join CR_Table as CR_TableRelation on CR_TableRelation.ID=CR_Action.ID_TableRelation
where -- CR_Table.ID = @table and
	 CR_Action.ID=@action
union
select CR_Table.ID, CR_Table.DisplayName as TableName, CR_Action.DisplayName as ActionName, CR_Table.ID_Module as Module, CR_Action.ID_TableRelation, 2 as [Priority]
from CR_Table
left join CR_Action on (CR_Action.ID_TableRelation=CR_Table.ID or CR_Action.ID_Table=CR_Table.ID) and @action is not null
where CR_Table.ID = @table and
	 CR_Action.ID=@action
union 
select CR_Table.ID, CR_Table.DisplayName as TableName, null as ActionName, CR_Table.ID_Module as Module, CR_Table.ID_TableParent, 3 as [Priority]
from CR_Table
where CR_Table.ID = @table
) x
order by [Priority]