	--  Number of report executions threshold.  Query will only return reports that have been run less than or equal to this number, including NULL
	DECLARE @ReportRuns INT = 5;
	
	-- Date to start looking back from for start times of report executions. Any execution that occurs on or before this date will be returned.
	--   Set value to NULL if you would like to ignore this parameter 	 
	DECLARE @LookBackStartDate AS DATE;

	--
	--  Return reports with limited to no exections along with the UserNames of those that ran them
	--
	WITH cte_MinimallyUsedReports
	AS 
	(
		SELECT
			c.Name
		   ,REPLACE(c.Path,'/{6aee708e-4f9b-4c46-8165-338ed5ab828d}/reports','')Path
		   ,c.ItemID
		   ,COUNT(el.TimeStart) AS cnt
		   ,MAX(el.TimeStart)MostRecentRun
		FROM
			dbo.Catalog c
			LEFT JOIN dbo.ExecutionLog AS el ON el.ReportID = c.ItemID
		WHERE
			c.Type = 2
			/*
				1 = path is a folder
				2 = Report
				3 = Resource
				4 = Linked Report
				5 = Data Source
			*/
			AND c.Hidden = 0
		GROUP BY
			c.Name
		   ,c.Path
		   ,c.ItemID
		HAVING
			COUNT(el.TimeStart)<=@ReportRuns
			AND 
			(
				MAX(el.TimeStart) IS NULL 
				OR @LookBackStartDate IS NULL 
				OR MAX(el.TimeStart) <= @LookBackStartDate
			)
			
	)
	SELECT 
		mur.Name
	   ,mur.Path
	   ,mur.cnt
	   ,lg.usrs
	   ,mur.MostRecentRun
	FROM cte_MinimallyUsedReports mur
	OUTER APPLY(
		SELECT
			CLRProcedures.dbo.CLR_ConcatenateWithDelimiter(REPLACE(el.UserName,'SPRAYTECH\',''), ',') usrs 
		FROM dbo.ExecutionLog el 
		WHERE 
			el.ReportID = mur.ItemID
	)lg
	ORDER BY 
		mur.MostRecentRun
		, mur.Name;
