--John.Boyer


	--DECLARE @ColumnValue VARCHAR(50) = '''John.Boyer%'''
	DECLARE @ColumnValue VARCHAR(50) = '''John.Boyer@searshomepro.com'''
	DECLARE @ColumnName  VARCHAR(50) = '%MAIL%'
	
	IF object_id('tempdb..#DBToSearch') IS NOT NULL  DROP TABLE #DBToSearch
			SELECT 
			ROW_NUMBER() OVER(ORDER BY d.name) row
			,'
				SELECT 					
					c.TABLE_CATALOG
					,c.TABLE_SCHEMA
					,c.TABLE_NAME
					,c.COLUMN_NAME 
					,c.TABLE_CATALOG + ''.'' + c.TABLE_SCHEMA + ''.'' + c.TABLE_NAME AS src
				FROM ' + d.name + '.INFORMATION_SCHEMA.COLUMNS c
				WHERE 
					C.COLUMN_NAME LIKE '''+ @ColumnName + '''
					AND c.TABLE_NAME NOT LIKE ''xxx%''
					AND c.DATA_TYPE IN (''char'', ''varchar'', ''nvarchar'', ''text'')
			' AS ColumnNameSearch
			INTO #DBToSearch
			FROM 
				sys.databases  d
			WHERE 
				state = 0 -- assume you only want online databases
				AND database_id > 4 -- assume you don't want system dbs

	DECLARE @counter INT = 1
	DECLARE @LoopLimit INT = (SELECT MAX(row) FROM #DBToSearch)
	DECLARE @sql NVARCHAR(4000) 
	
		
	IF OBJECT_ID('tempdb..#TableToSearch') IS NOT NULL DROP TABLE #TableToSearch
	CREATE TABLE #TableToSearch(DB VARCHAR(200), scma VARCHAR(200), tbl VARCHAR(200), col VARCHAR(200), src VARCHAR(200))
	WHILE @counter <= @LoopLimit
	BEGIN
		SET @sql = (SELECT ColumnNameSearch FROM #DBToSearch WHERE row = @counter )
		INSERT INTO #TableToSearch(DB, scma, tbl, col, SRC)
		exec sp_executesql @sql 
		set @counter += 1
    END 
	
	IF OBJECT_ID('tempdb..#TableToSearchWithNowNumbers') IS NOT NULL DROP TABLE #TableToSearchWithNowNumbers
	SELECT 
		ROW_NUMBER() OVER(ORDER BY DB) row
		,*
	INTO #TableToSearchWithNowNumbers
	FROM #TableToSearch
	

	IF OBJECT_ID('tempdb..#Results') IS NOT NULL DROP TABLE #Results
	CREATE TABLE #Results(DataSource VARCHAR(1000), Clmn VARCHAR(1000))
	SET @counter = 1
	SET @LoopLimit = (SELECT MAX(row) FROM #TableToSearchWithNowNumbers)
	WHILE @counter <= @LoopLimit
	BEGIN
		
		--SET @sql = (SELECT 'SELECT ''' + SRC + ''' AS DataSource, ' + col + ' FROM '  + src + ' WITH (NOLOCK) WHERE ' + col + ' LIKE ' + @ColumnValue FROM #TableToSearchWithNowNumbers WHERE row = @counter)					
		SET @sql = (SELECT 'SELECT ''' + SRC + ''' AS DataSource, ' + col + ' FROM '  + src + ' WITH (NOLOCK) WHERE ' + col + ' = ' + @ColumnValue FROM #TableToSearchWithNowNumbers WHERE row = @counter)							
		--SELECT @sql
		INSERT INTO #Results(DataSource, Clmn)		
		EXEC sp_executesql @sql 
		set @counter += 1
    END 
	
	SELECT * FROM #Results

--	SHIPBI.dbo.ViewDimUserUserNameUnique	John.Boyer@searshomepro.com
--SHIPBI.dbo.DimUser	John.Boyer@searshomepro.com
--SHIPBI.dbo.StageSPUsers	John.Boyer@searshomepro.com