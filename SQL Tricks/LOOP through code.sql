
SET NOCOUNT ON  


--  Internal values
--
DECLARE @sql AS NVARCHAR(MAX) -- Variable to hold stored procedure code for dynamic execution 
DECLARE @counter AS INT = 1 -- Counter to cycle through and alter all objects
DECLARE @LastObject AS INT -- Holds number of last object to be modified
--DECLARE	@results INT 
DECLARE	@results TABLE (results INT)
DECLARE @DistrictID NVARCHAR(12)  
IF OBJECT_ID('tempdb..#DistrictList') IS NOT NULL DROP TABLE #DistrictList 
SELECT 
	ROW_NUMBER()OVER(ORDER BY dd.DimDistrictKey)x
	,dd.DimDistrictKey 
	,NULL AS cnt
INTO #DistrictList
FROM SHIPREPORTSSQL.SHIPBI.dbo.DimDistrict AS dd WHERE MasterListActive = 1

-- Get upper limit for execution 
SET @LastObject = (SELECT MAX(x)x FROM #DistrictList AS dl)

-- Loop through all procs and exectue
WHILE @counter <= @LastObject
	BEGIN 
		SET @DistrictID = (SELECT CAST(dl.DimDistrictKey AS NVARCHAR(12)) FROM #DistrictList dl WHERE dl.x = @counter)
		SET @sql = 
			'
					SELECT COUNT(*)cnt
					FROM    shipreports.shipbi.dbo.dimdistrict dk ( NOLOCK )
							INNER JOIN shipreports.shipbi_etl.dbo.subrptpermissions p ( NOLOCK ) ON p.dimdistrictkey = dk.dimdistrictkey
							INNER JOIN dbo.aduser au ( NOLOCK ) ON au.samaccount = REPLACE(p.username,
																		  ''SPRAYTECH\'', '''')
					WHERE   dk.districtid = dbo.fn_CurrentDistrictByOfficeProduct(' + @DistrictID + ',NULL)
							AND au.description IN ( ''DSM'', ''FSM'', ''AGM'', ''DSM - Exterior'',
													''DSM - Interior'', ''FST'', ''Sales Rep'',
													''SPC'', ''GSM'', ''SM'', ''STM'',''DGM'' )
			'

		
		--EXEC SP_EXECUTESQL @sql, N'@results int OUTPUT', @results OUTPUT
		--EXEC (@sql)

		INSERT INTO @results ( results )
		EXEC (@sql)	

		UPDATE dl
			--SET cnt = @results
			SET cnt = (SELECT TOP 1 results FROM @results)
		FROM #DistrictList dl 
		WHERE 
			dl.x = @counter

		DELETE FROM @results
		-- Increment coutnter
		SET @counter +=1
	END 

	SELECT * FROM #DistrictList
-- Garbage collection
DROP TABLE #DistrictList
