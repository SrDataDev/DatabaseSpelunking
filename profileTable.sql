--Filename: ProfileTable.sql

USE [AdventureWorks2012]
GO

declare @tbl varchar(50)
declare @col varchar(50)
declare @sqlStmt varchar(700)
declare @val varchar(100)
declare @fldSample varchar(200)
declare @schemaName varchar(100)
declare @tblName varchar(100)
set @val = ''
set @fldSample = ''

--set up the selections
set @schemaName = 'sales'
set @tblName = 'SalesOrderHeader'

--Recreate the profile table
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbProfile]') AND type in (N'U'))
DROP TABLE [dbo].[dbProfile]
 CREATE TABLE [dbo].[dbProfile](
 [TableName] [varchar](50) NOT NULL,
 [ColumnName] [varchar](50) NOT NULL,
 [recordCnt] [int] NULL,
 [distinctCnt] [int] NULL,
 [nonNullCnt] [int] NULL,
 [NullCnt] [int] NULL,
 [fldSample] varchar(300)
 ) ON [PRIMARY]

 
declare dbSchema cursor for
 SELECT t.name AS table_name,
 c.name AS column_name
 FROM sys.tables AS t
 INNER JOIN sys.columns c ON t.OBJECT_ID = c.OBJECT_ID
 where t.Name = @tblName
 ORDER BY t.name

open dbSchema
 fetch next from dbSchema into @tbl, @col
 while @@FETCH_STATUS = 0
 begin

set @sqlStmt = 'declare fldList cursor for select distinct ' + @col + ' from ' + @schemaName + '.'  + @tbl + ' where ' + @col + ' is not null'
print @sqlStmt
 EXEC (@sqlStmt)
 set @fldSample = ''
open fldList

fetch next from fldList into @val

while @@FETCH_STATUS = 0
 begin
   set @fldSample = @fldSample + rtrim(ltrim(isnull(@val, ''))) + ', '
   fetch next from fldList into @val
 end

close fldList
deallocate fldList

set @fldSample = REPLACE(@fldSample, '''', '')

set @sqlStmt = 'insert into dbProfile (TableName, ColumnName, recordCnt, distinctCnt, nonNullCnt, nullCnt, fldSample) '
set @sqlStmt = @sqlStmt +'select '''+@tbl+''' as TableName ,'''+@col+''' as ColumnName, '
set @sqlStmt = @sqlStmt +'count(*) as recordCnt, '
set @sqlStmt = @sqlStmt +'count(distinct ['+@col+']) as distinctCnt, '
set @sqlStmt = @sqlStmt +'sum(case len(rtrim(['+@col+'])) when 0 then 0 else 1 end) as nonNullCnt, '
set @sqlStmt = @sqlStmt +'sum(case len(rtrim(['+@col+'])) when 0 then 1 else 0 end) as NullCnt, '
set @sqlStmt = @sqlStmt +  '''' + left(isnull(@fldSample, ' '),200) + ''''
set @sqlStmt = @sqlStmt +' from '+ @schemaName + '.'   + @tbl + ' with (nolock)'
--select @sqlStmt
 begin try
 EXEC (@sqlStmt)
 end try
 begin catch
 print(@sqlStmt)
 end catch

 fetch next from dbSchema into @tbl, @col
 end
 close dbSchema
 deallocate dbSchema
 select * from dbProfile