--Filename: findColumnWithinInstance.sql
--This script will find column of a specific name in any database in a given instance.

declare @db varchar(250)
declare @sch varchar(250)
declare @tbl varchar(250)
declare @col varchar(250)
declare @sqlStmt varchar(700)
declare @colNameSample varchar(250)
set @colNameSample = '%emp%' --Note that any wild cards must be in this string. 

--Recreate a temp table to accumulate results
if OBJECT_ID(N'tempdb..#tblList') is not null
drop table #tblList

create table #tblList(
[dbName] [varchar](250), 
[schName] [varchar](250),
[tblName] [varchar](250), 
[colName] [varchar](250) 
) ON [PRIMARY]

--Create a cursor containing a list of all of the databases
declare dbs cursor for
select [name] as dbName
from sys.databases d
where d.[name] not in ('master','model','msdb','tempdb','ssisdb','ReportServer','ReportServerTempDB')
order by d.name
--Loop through the list of databases to see if any of them contains a column matching @colNameSample 
open dbs
fetch next from dbs into @db
while @@FETCH_STATUS = 0
begin
	set @sqlStmt = 'use '+@db +'; '
	set @sqlStmt = @sqlStmt +'insert into #tblList '
	set @sqlStmt = @sqlStmt +'select '''+@db+''', s.name, t.name, c.name '
	set @sqlStmt = @sqlStmt +'from sys.tables AS t '
	set @sqlStmt = @sqlStmt +'inner join sys.columns c on t.OBJECT_ID = c.OBJECT_ID '
	set @sqlStmt = @sqlStmt +'inner join sys.schemas s on s.schema_id = t.schema_id '
	set @sqlStmt = @sqlStmt +'where c.[name] like '''+@colNameSample+''' ' 
	begin try
		EXEC (@sqlStmt)
	end try
	begin catch
		print(@sqlStmt)
	end catch
	fetch next from dbs into @db
end
close dbs
deallocate dbs
--Now show the results we've collected in the temp table
select * from #tblList



