#Filename: findTableInInstanceList.ps1

Clear-Host
Write-Host “Searching SQL Servers….”

#Set up the variables
$tblName = “emp" #Put some or all of table table name you want here 
$serverList = "Pelagic" #continue with a comma delimited list of servers
$SQLServer = “”
$SQLDBName = “”
$uid =””
$pwd = “”
$db = “”
$tbl = “”
$connectionString = “”

foreach($SQLServer in $serverList)
{
    #create a connection to the database
    $connectionString = “Server=$SQLServer;Database = Master;Integrated Security=SSPI;”

    #open the connection
    $dbConn = New-Object System.Data.SqlClient.SqlConnection
    $dbConn.ConnectionString = $connectionString
    $dbConn.Open()

    Write-Host “Server: ” $SQLServer

    #Compose a SQL statement to find every database
    $qry = @”
select d.[name] as dbName
from sys.databases d
where d.[name] not in ('master','tempdb','model','msdb','ReportServerTempDB','ReportServer', 'SSISDB')
“@

    #Add the query to the connection
    $dbCmd = $dbConn.CreateCommand()
    $dbCmd.CommandText = $qry

    #Execute the query
    $dbList = $dbCmd.ExecuteReader()

    #Format and display the results
    $dbs = new-object “System.Data.DataTable”
    $dbs.Load($dbList)

    #Check each database for desired table
    foreach($db in $dbs)
    {
        $dbName = $db[0]
        #Write-Host “Checking database: ” $dbName

        #open the connection
        $tblConn = New-Object System.Data.SqlClient.SqlConnection
        $tblConn.ConnectionString = $connectionString
        $tblConn.Open()

        #Compose a SQL statement to find every table
        $qry = @”
select s.[name] as schemaName
, tbl.[name] as TableName
from $dbName.sys.tables tbl
left outer join $dbName.sys.schemas s
on s.[schema_id] = tbl.[schema_id]
“@

        #Add the query to the connection
        $tblCmd = $tblConn.CreateCommand()
        $tblCmd.CommandText = $qry
        #Write-Host “Query: ” $tblCmd.CommandText “`n”

        #Execute the query
        try 
        {
            $tblList = $tblCmd.ExecuteReader()
        }
        catch
        {
            Write-Host ” -Error accessing database” $dbName
        }
        $tbls = new-object “System.Data.DataTable”
        $tbls.Load($tblList)
        #Write-Host ($tbls | Format-Table | Out-String)
        foreach($tbl in $tbls)
        {
            $tblUpperCase = $tbl[1].ToUpper()
            $searchStrUpperCase = $tblName.ToUpper()
            if($tblUpperCase.Contains($searchStrUpperCase))
           {
                Write-Host “Found table in ” $dbName, $tbl[0], $tbl[1]
           }
        }

    }

}