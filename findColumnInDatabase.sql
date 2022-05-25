select t.name, c.name 
from sys.columns c 
inner join sys.tables t
  on t.object_id = c.object_id
where c.[name] like '%Reseller%' 
