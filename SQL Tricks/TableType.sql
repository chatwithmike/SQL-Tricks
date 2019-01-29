if exists (select * from sys.types where name = 'TestTableType')
    drop type TestTableType

create type TestTableType as table (id int)
go
declare @t TableType.INT	
insert @t VALUES (1),(2)


USE [SHIPBI]
GO 
CREATE SCHEMA TableType
CREATE TYPE [TableType].[FloatTable] AS TABLE(FloatValue FLOAT NOT NULL PRIMARY KEY)
CREATE TYPE [TableType].[IntTable] AS TABLE(IntValue INT NOT NULL PRIMARY KEY)
CREATE TYPE [TableType].[VarcharTable] AS TABLE(VarcharValue VARCHAR(500) NOT NULL PRIMARY KEY)

USE [SHIPBI]
GO

CREATE TYPE TableType.FloatTable AS TABLE 



declare @t TableType.Int
insert @t VALUES(1),(2),(NULL) 
SELECT * FROM @t AS t
exec sp_executesql N'select * from @var', N'@var TestTableType readonly', @t

USE [SHIPBI]
GO



--shipbi_etl
/*
change int to IntValue
change TableType.Int to TableType.IntTable
*/
exec sp_executesql N'select * from @var', N'@var TestTableType readonly', @t

DECLARE @tbl TABLE(x INT)
INSERT INTO @tbl(x)VALUES(46)

DECLARE @sql nVARCHAR(100) = 'select * from @tbl'
DECLARE @ParmDefinition nvarchar(500) =
	'
		@tbl 
	';


EXEC SHIPREPORTSSQL.SHIPBI.dbo.SP_EXECUTESQL @sql, @ParmDefinition, @tbl