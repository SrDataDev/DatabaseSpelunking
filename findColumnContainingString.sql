--Filename: findColumnContainingString.sql

USE [AdventureWorksDW2012]
GO

--This script will find which table and column contains a known value within the current database. 
--This can be used to find which table and column contains a value that you can see in a front application.
--The @colNameSample is used to narrow the search for performance.

declare @sch varchar(250)
declare @tbl varchar(250)
declare @col varchar(250)
declare @sqlStmt varchar(700)
declare @fldValueSample varchar(200)
declare @colNameSample varchar(100)
set @fldValueSample = 'Yang' --Note that you can't use wild cards here ('=' is used instead of 'like' for performance reasons)
set @colNameSample = '%name%' --Note that any wild cards must be in this string. Use '%%' if you want to query every column.

--Recreate a temp table
if OBJECT_ID(N'tempdb..#colList') is not null
drop table #colList

create table #colList(
[SchemaName] [varchar](250),
[TableName] [varchar](250),
[ColumnName] [varchar](250),
) ON [PRIMARY]

--Create a cursor containing a list of all of the tables and columns where the contents of @colNameSample appears in the column name
declare dbSchema cursor for
select s.name as schemaName,
t.name AS tableName,
c.name AS columnName
from sys.tables AS t
inner join sys.columns c ON t.OBJECT_ID = c.OBJECT_ID
inner join sys.schemas s on s.schema_id = t.schema_id 
where c.name like @colNameSample
order by s.name, t.name
--Loop through the list of columns to see if any of them contains a row with the @fldValueSample 
open dbSchema
fetch next from dbSchema into @sch, @tbl, @col
while @@FETCH_STATUS = 0
begin
	set @sqlStmt = 'insert into #colList '
	set @sqlStmt = @sqlStmt +'select distinct ''' +@sch+''' as SchemaName, '''+@tbl+''' as TableName ,'''+@col+''' as ColumnName '
	set @sqlStmt = @sqlStmt +' from '+@sch+'.'+ @tbl+' '
	set @sqlStmt = @sqlStmt +'where '+ @col+' = '''+@fldValueSample+''' ' 
	print(@sqlStmt)
	begin try
		EXEC (@sqlStmt)
	end try
	begin catch
		print(@sqlStmt)
	end catch
	fetch next from dbSchema into @sch, @tbl, @col
end
close dbSchema
deallocate dbSchema
--Now show the results we've collected in the temp table
select * from #colList

insert into #colList select distinct 'HumanResources' as SchemaName, 'Department' as TableName ,'Name' as ColumnName  from Department where Name = 'Yang' 
