--List databases with an instance
select * from sys.databases

--Doesn't exist in INFORMATION_SCHEMA!
select * from INFORMATION_SCHEMA.DATABASES 

--Find a table using INFORMATION_SCHEMA
use AdventureWorksDW2012
select * from INFORMATION_SCHEMA.tables where TABLE_NAME like '%log%'

--Find a column in a database by name
select t.name, c.name 
from sys.columns c 
inner join sys.tables t
  on t.object_id = c.object_id
where c.[name] like '%Reseller%' 

--Find a procedure containing a string
use AdventureWorks2012
select distinct OBJECT_NAME(id)
from syscomments
where OBJECTPROPERTY(id, 'IsProcedure') = 1
and [text] like '%emp%'
order by OBJECT_NAME(id)

--Find a view containing a string
use AdventureWorks2012
select distinct OBJECT_NAME(id)
from syscomments
where OBJECTPROPERTY(id, 'isView') = 1
and [text] like '%emp%'
order by OBJECT_NAME(id)
