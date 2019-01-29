
SET NOCOUNT ON  

--
--  User modified values
--
DECLARE @SearchText VARCHAR(200) = 'Bryan.Gieger@searshomepro.com'
DECLARE @ReplacementText VARCHAR(200) = 'Tim.Hays@searshomepro.com'

--
--  Internal values
--
DECLARE @sql AS VARCHAR(MAX) -- Variable to hold stored procedure code for dynamic execution 
DECLARE @counter AS INT = 1 -- Counter to cycle through and alter all objects
DECLARE @LastObject AS INT -- Holds number of last object to be modified

SET @sql = 
	'
		USE [?]; 
		SELECT 
			''?'' AS Databse
			, type_desc AS ObjType
			, Name AS ObjName
			, OBJECT_DEFINITION(OBJECT_ID) AS ObjText 
			, CASE 
				WHEN type_desc = ''SQL_STORED_PROCEDURE''
					THEN REPLACE
						( 
							REPLACE(OBJECT_DEFINITION(OBJECT_ID),''' + @SearchText + ''',''' + @ReplacementText + ''')
							,''CREATE PROCEDURE'', ''ALTER PROCEDURE''
						)

				WHEN type_desc = ''VIEW''
					THEN REPLACE
						( 
							REPLACE(OBJECT_DEFINITION(OBJECT_ID),''' + @SearchText + ''',''' + @ReplacementText + ''')
							,''CREATE VIEW'', ''ALTER VIEW''
						)

				WHEN type_desc IN (''SQL_SCALAR_FUNCTION'',''SQL_INLINE_TABLE_VALUED_FUNCTION'',''SQL_TABLE_VALUED_FUNCTION'')
					THEN REPLACE
						( 
							REPLACE(OBJECT_DEFINITION(OBJECT_ID),''' + @SearchText + ''',''' + @ReplacementText + ''')
							,''CREATE FUNCTION'', ''ALTER FUNCTION''
						)
				END AS ObjTextCorrection
		FROM sys.objects WITH (NOLOCK) WHERE OBJECT_DEFINITION(OBJECT_ID) LIKE ''%' + @SearchText +'%''
	'

IF OBJECT_ID('tempdb..#DimTimeObjects') IS NOT NULL DROP TABLE #DimTimeObjects
-- Table to hold object and their modifications
CREATE TABLE #DimTimeObjects
(
	dtoKey	 INT PRIMARY KEY IDENTITY(1,1)
	,Databse VARCHAR(50)
	,ObjType VARCHAR(50)
	,ObjName VARCHAR(400)
	,ObjText VARCHAR(MAX)
	,ObjTextCorrection VARCHAR(MAX)
);

-- Load objects by cycling through all databases
INSERT INTO #DimTimeObjects
( 
	Databse
    ,ObjType
    ,ObjName
    ,ObjText
	,ObjTextCorrection
)
EXEC sp_msforeachdb @sql

-- Get upper limit for execution 
SET @LastObject = (SELECT MAX(dtoKey) AS dtoKey FROM #DimTimeObjects)

-- Loop through all procs and exectue
WHILE @counter <= @LastObject
	BEGIN 
		-- Uncomment to run 
		--EXEC (SELECT ObjTextCorrection FROM #DimTimeObjects WHERE dtoKey = @counter)

		-- Used for testing
		SELECT (SELECT ObjTextCorrection FROM #DimTimeObjects WHERE dtoKey = @counter)

		-- Increment coutnter
		SET @counter +=1
	END 


	