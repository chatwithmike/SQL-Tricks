IF OBJECT_ID ('tempdb..#tmp') IS NOT NULL DROP TABLE #tmp
CREATE TABLE #tmp (qry VARCHAR(1000))
INSERT INTO #tmp (qry)
 exec sp_msforeachdb 
 '
	use [?]; 
	SELECT 	
		''SELECT * FROM '' + ''?'' + ''.'' + TABLE_SCHEMA + ''.'' + TABLE_NAME + '' WHERE '' + COLUMN_NAME + '' = ''''40001''''''
	FROM information_schema.COLUMNS 
	WHERE 
		COLUMN_NAME LIKE ''%phone%'';
'
SELECT * FROM #tmp
