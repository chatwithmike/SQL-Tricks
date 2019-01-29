SET XACT_ABORT ON 
SET NOCOUNT ON  
--  User modified values
--
DECLARE @SearchText VARCHAR(200) = 'IR26336: Replace DimTime with DimDate'
DECLARE @ReplacementText VARCHAR(200) = 'IR26336: Replace Dim_Time with DimDate'

--
--  Internal values
--
DECLARE @sql AS VARCHAR(MAX) -- Variable to hold stored procedure code for dynamic execution 
DECLARE @EXECsql AS VARCHAR(MAX) -- Used to hold code executed through cycling process
DECLARE @counter INT -- Counter to cycle through and alter all objects
DECLARE @FirstObject AS INT -- Holds number of last object to be modified
DECLARE @LastObject AS INT -- Holds number of last object to be modified
DECLARE @dte AS VARCHAR(25) = CONVERT(VARCHAR(25), GETDATE(), 121) 
DECLARE @SetID AS VARCHAR(100) = (SELECT COALESCE(MAX(SetID)+1,1) AS SetID FROM SHIPBI_BATCH.dbo.tblObjectSearchAndReplace)

	SELECT @SetID
SET @sql = 
	'
		USE [?]; 
		SELECT '			
			+ @SetID + ' AS SetID'
			+ ',''' + @SearchText + ''' AS SearchText'
			+ ',''' + @ReplacementText + ''' AS ReplacementText'
			+ ',''' + @@SERVERNAME + ''' AS Srvr
			,''?'' AS Databse
			, type_desc AS ObjType
			, Name AS ObjName
			,''USE [?];'' + CHAR(13) + CHAR(10) + ''GO'' + OBJECT_DEFINITION(OBJECT_ID) AS ObjText 
			,''USE [?];'' + CHAR(13) + CHAR(10) + ''GO'' + CASE 
				WHEN type_desc = ''SQL_STORED_PROCEDURE''
					THEN REPLACE
						( 
							REPLACE(OBJECT_DEFINITION(OBJECT_ID),''' + @SearchText + ''',''' + @ReplacementText + ''')
							,''CREATE PROCEDURE'', ''ALTER PROCEDURE''
						)+''GO''

				WHEN type_desc = ''VIEW''
					THEN REPLACE
						( 
							REPLACE(OBJECT_DEFINITION(OBJECT_ID),''' + @SearchText + ''',''' + @ReplacementText + ''')
							,''CREATE VIEW'', ''ALTER VIEW''
						)+''GO''

				WHEN type_desc IN (''SQL_SCALAR_FUNCTION'',''SQL_INLINE_TABLE_VALUED_FUNCTION'',''SQL_TABLE_VALUED_FUNCTION'')
					THEN REPLACE
						( 
							REPLACE(OBJECT_DEFINITION(OBJECT_ID),''' + @SearchText + ''',''' + @ReplacementText + ''')
							,''CREATE FUNCTION'', ''ALTER FUNCTION''
						)+''GO''
				END AS ObjTextCorrection
			,''USE [?];'' + CHAR(13) + CHAR(10) + ''GO'' + CASE 
				WHEN type_desc = ''SQL_STORED_PROCEDURE''
					THEN REPLACE
						( 
							OBJECT_DEFINITION(OBJECT_ID),''CREATE PROCEDURE'', ''ALTER PROCEDURE''
						)

				WHEN type_desc = ''VIEW''
					THEN REPLACE
						( 
							OBJECT_DEFINITION(OBJECT_ID),''CREATE VIEW'', ''ALTER VIEW''
						)

				WHEN type_desc IN (''SQL_SCALAR_FUNCTION'',''SQL_INLINE_TABLE_VALUED_FUNCTION'',''SQL_TABLE_VALUED_FUNCTION'')
					THEN REPLACE
						( 
							OBJECT_DEFINITION(OBJECT_ID),''CREATE FUNCTION'', ''ALTER FUNCTION''
						)
				END AS ObjRollback'
			+ ',''' + @dte + ''' AS DateCreated
		FROM sys.objects 
		WHERE 
			OBJECT_DEFINITION(OBJECT_ID) LIKE ''%' + @SearchText +'%''					
	'
-- Table to hold object and their modifications
--CREATE TABLE #Objects

--CREATE TABLE SHIPBI_BATCH.dbo.tblObjectSearchAndReplace
--(
--	osrKey				INT PRIMARY KEY IDENTITY(1,1)	
--	,SetID				INT 
--	,SearchText			VARCHAR(1000)
--	,ReplacementText	VARCHAR(1000)
--	,Srvr				VARCHAR(100)
--	,Databse			VARCHAR(100)
--	,ObjType			VARCHAR(50)
--	,ObjName			VARCHAR(400)
--	,ObjText			VARCHAR(MAX)
--	,ObjTextCorrection	VARCHAR(MAX)
--	,ObjRollback		VARCHAR(MAX)
--	,DateCreated		DATETIME
--);

-- Load objects by cycling through all databases
--INSERT INTO #Objects
INSERT INTO SHIPBI_BATCH.dbo.tblObjectSearchAndReplace
( 			
	 SetID			
	,SearchText			
	,ReplacementText	
	,Srvr				
	,Databse			
	,ObjType			
	,ObjName			
	,ObjText			
	,ObjTextCorrection	
	,ObjRollback		
	,DateCreated				
)
EXEC sp_msforeachdb @sql


--SELECT * FROM SHIPBI_BATCH.dbo.tblObjectSearchAndReplace osar WHERE osar.SetID =@SetID


---- Get limits for execution 
SELECT 
	@FirstObject = MIN(osrKey)
	,@LastObject = MAX(osrKey)
FROM SHIPBI_BATCH.dbo.tblObjectSearchAndReplace AS osr WHERE osr.SetID = @SetID

----SELECT @FirstObject, @LastObject

SET @counter = @FirstObject

------testing
----SELECT ObjTextCorrection FROM SHIPBI_BATCH.dbo.tblObjectSearchAndReplace WHERE SetID = @counter
----SELECT @counter AS Counter, (1 + (@LastObject - @FirstObject)) AS  TheSequence, @FirstObject AS FirstObject, @LastObject AS LastObject
---- Loop through all procs and exectue
WHILE @counter <= @LastObject
	BEGIN 
		
		-- Uncomment to run 
		SET @EXECsql = (SELECT ObjTextCorrection FROM SHIPBI_BATCH.dbo.tblObjectSearchAndReplace WHERE osrKey = @counter)
		EXEC @EXECsql

		-- Used for testing
		--SELECT ObjTextCorrection, SetID, @SetID FROM SHIPBI_BATCH.dbo.tblObjectSearchAndReplace WHERE osrKey = @counter
		--SELECT @counter AS Counter, (1 + (@LastObject - @FirstObject)) AS  TheSequence

		-- Increment coutnter
		SET @counter +=1
	END 
SELECT * FROM SHIPBI_BATCH.dbo.tblObjectSearchAndReplace WHERE SetID = 2
	

	/*
	RptSubscriptionBackup
	*/