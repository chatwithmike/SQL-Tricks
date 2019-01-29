		DECLARE @pClasses VARCHAR(MAX) = 
		(
			SELECT 
				',' + CAST(c.UpdatedClassID AS NVARCHAR(11))
			FROM 
				(
					SELECT DISTINCT							
						CASE 
							WHEN c.status = 0 THEN -1
							WHEN c.class_id IS NULL THEN -2 -- = User Record Plan, class_Id never null 
							ELSE c.class_id
						 END AS UpdatedClassID
					FROM
						SRVLWDAUTSQL01.Qfiniti_platform.dbo.classifications c WITH ( NOLOCK )
				)c FOR XML PATH('')
		)


		DECLARE @Split char(1) = ','
		DECLARE @X XML = CONVERT(xml,' <root> <s>' + REPLACE(@pClasses,@Split,'</s> <s>') + '</s>   </root> ')

		CREATE TABLE #ClassFilter (class INT PRIMARY KEY)
		INSERT INTO #ClassFilter (class)
		SELECT 
			T.c.value('.','varchar(11)') AS Value
		FROM 
			@X.nodes('/root/s') T(c)
		WHERE 
			T.c.value('.','varchar(11)') <> ''