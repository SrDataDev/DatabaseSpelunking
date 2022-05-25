USE AdventureWorks2012
GO
declare @tbl varchar(50)
declare @col varchar(50)
declare @sqlStmt varchar(700)
declare @val varchar(100)
declare @fkTables varchar(200)
set @val = ''
set @fkTables = ''
--Recreate the profile table
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbRelationships]') AND type in (N'U'))
	DROP TABLE [dbo].[dbRelationships]

CREATE TABLE [dbo].[dbRelationships](
[TableName] [varchar](50) NOT NULL,
[ColumnName] [varchar](max) NOT NULL,
[RelatedTables] [varchar](max) NULL
) ON [PRIMARY]

declare relations cursor for
select t.name as table_name,
c.name as column_name
from sys.tables as t
inner join sys.columns c on t.OBJECT_ID = c.OBJECT_ID
order by table_name

open relations
fetch next from relations into @tbl, @col
while @@FETCH_STATUS = 0
begin
	set @sqlStmt = 'declare fkList cursor for '
	set @sqlStmt = @sqlStmt + ' select distinct t.name AS table_name' 
	set @sqlStmt = @sqlStmt + ' from sys.tables AS t'
	set @sqlStmt = @sqlStmt + ' inner join sys.columns c ON t.OBJECT_ID = c.OBJECT_ID'
	set @sqlStmt = @sqlStmt + ' where c.name = ''' + @col + ''''
	set @sqlStmt = @sqlStmt + ' and t.name <> ''' + @tbl + ''''
	set @sqlStmt = @sqlStmt + ' order by t.name' 
	EXEC (@sqlStmt)
	set @fkTables = ''

	open fkList
	fetch next from fkList into @val
	while @@FETCH_STATUS = 0
	begin
		set @fkTables = @fkTables + rtrim(ltrim(@val)) + ', '
		fetch next from fkList into @val
	end
	close fkList
	deallocate fkList
	insert into dbRelationships (TableName, ColumnName, RelatedTables) values (@tbl, @col, @fkTables)
	fetch next from relations into @tbl, @col
end
close relations
deallocate relations
select * from dbRelationships
