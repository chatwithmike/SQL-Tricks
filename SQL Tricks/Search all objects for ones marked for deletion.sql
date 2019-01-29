/*
	
	Objective:  Search all objects for ones marked for deletion that are at least a year old.  Include 
				the number of dependencies that object has.
*/

IF object_id ('tempdb..##temp') IS NOT NULL DROP TABLE ##temp 
CREATE TABLE ##temp 
(
	tableKey INT IDENTITY (1,1)
	,ObjectName	nvarchar(128)
	,SchemaName	nvarchar(128)
	,DatabaseName	nvarchar(128)
	,create_date	datetime
	,modify_date	datetime
	,type_desc	nvarchar(60)
	,Dependencies INT DEFAULT 0
)
INSERT INTO ##temp
(
   ObjectName
   ,SchemaName
   ,DatabaseName
   ,create_date
   ,modify_date
   ,type_desc
)
EXECUTE sp_msforeachdb 
'
	USE [?]; 
	DECLARE @dte DATE = GETDATE()-365
	SELECT  
		o.name as ObjectName
		,s.name AS SchemaName	
		,(SELECT top 1 DB_NAME() FROM sys.columns) as DatabaseName
		,o.create_date
		,o.modify_date
		,o.type_desc
	FROM    
		sys.objects o
		INNER JOIN sys.schemas s ON s.schema_id = o.schema_id
	WHERE
		o.name LIKE ''%xxx%''
		AND o.modify_date < @dte
'

/*
	For each item (object) in the temp table check each database in the server for dependencies
*/
DECLARE @Counter INT = 1 
DECLARE @ExitLoopAfter INT = (SELECT MAX(tableKey) FROM ##temp)
WHILE @Counter <= @ExitLoopAfter
BEGIN 
	DECLARE @sql NVARCHAR(2000) = 
		'
		USE [?]; 
		BEGIN TRY 
			DECLARE @nme NVARCHAR(200) = (SELECT ObjectName FROM ##temp WHERE tableKey = ' + CAST(@Counter AS NVARCHAR(10)) + ')

			DECLARE @depends TABLE 
			(
				_name VARCHAR(200)
				,_type VARCHAR(200)
			)
			INSERT INTO @depends
			(
				_name
			   ,_type
			)
			EXEC sp_depends @objname = @nme	
			UPDATE t
				SET t.Dependencies = 
					(SELECT COUNT(*) FROM @depends) + (SELECT t.Dependencies FROM ##temp t WHERE t.tableKey = ' + CAST(@Counter AS NVARCHAR(10)) + ')
			FROM 
				##temp t
			WHERE 
				t.tableKey = ' + CAST(@Counter AS NVARCHAR(10)) + '
		END TRY 
		BEGIN CATCH	
				
		END CATCH 
	'
	EXECUTE sp_MSForEachDB @sql
	
	SET @Counter += 1
END 

--
-- Output
--
SELECT 
	DatabaseName
	,SchemaName
	,type_desc
	,ObjectName
	,modify_date
FROM 
	##temp 
ORDER BY 
	DatabaseName
	,SchemaName
	,type_desc
	,ObjectName

/*
	Use this to visually inspect indivialual dependencies


	DECLARE @sql2 NVARCHAR(2000) = 
		'
		USE [?]; 
		BEGIN TRY 
			DECLARE @depends TABLE 
			(
				_name VARCHAR(200)
				,_type VARCHAR(200)
			)
			INSERT INTO @depends
			(
				_name
			   ,_type
			)
			EXEC sp_depends @objname = ''xxxDimServiceCustomer''	
			select DB_NAME() as DatabaseName , * from @depends				
		END TRY 
		BEGIN CATCH					
		END CATCH 
	'
	EXECUTE sp_MSForEachDB @sql2
	
*/
