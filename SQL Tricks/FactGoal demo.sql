SELECT * FROM SHIPBI_Batch.dbo.DimGoalType dgt







SELECT * FROM SHIPBI_Batch.dbo.FactGoal fg WITH (NOLOCK) 
--
--  By product and month
--







SELECT * FROM SHIPBI_Batch.dbo.FactGoal fg WITH (NOLOCK) 
WHERE fg.DimProductKey = -1
--
--  By all products
--






SELECT * FROM SHIPBI_Batch.dbo.FactGoal fg WITH (NOLOCK) 
WHERE fg.FiscalYearMonth = '-1'
--
--  By Year and Product
--







SELECT * FROM SHIPBI_Batch.dbo.FactGoal fg WITH (NOLOCK) 
WHERE fg.FiscalYearMonth = '-1' AND fg.DimProductKey = -1
--
-- By year & goal & all products
--





		SELECT fg.DimProductKey
			, fg.FiscalYearMonth
			, MAX(CASE WHEN dgt.DimGoalTypeKey =  1 THEN fg.Goal END) GoalContractToCompletion
			, MAX(CASE WHEN dgt.DimGoalTypeKey =  2 THEN fg.Goal END) GoalGCR
			, MAX(CASE WHEN dgt.DimGoalTypeKey =  3 THEN fg.Goal END) GoalNPS
			, MAX(CASE WHEN dgt.DimGoalTypeKey =  4 THEN fg.Goal END) GoalCancelRate
			, MAX(CASE WHEN dgt.DimGoalTypeKey =  5 THEN fg.Goal END) GoalProductMarginRate
			, MAX(CASE WHEN dgt.DimGoalTypeKey = 11 THEN fg.Goal END) GoalRTPtoMeasure
			, MAX(CASE WHEN dgt.DimGoalTypeKey = 14 THEN fg.Goal END) GoalRTPtoStart
            , MAX(CASE WHEN dgt.DimGoalTypeKey = 15 THEN fg.Goal END) GoalRTPToCompletion
            , MAX(CASE WHEN dgt.DimGoalTypeKey = 27 THEN fg.Goal END) GoalServicesAgedRatio
		FROM SHIPBI_Batch.dbo.FactGoal fg WITH (NOLOCK) 
		INNER JOIN SHIPBI_Batch.dbo.DimGoalType dgt WITH (NOLOCK) ON dgt.DimGoalTypeKey = fg.DimGoalTypeKey
		WHERE 
			fg.FiscalYearMonth = '2016-01' --@FiscalYearMonth
			AND fg.DimProductKey <> -1
			AND fg.BusinessDivisionKey = 1
		GROUP BY 
			fg.DimProductKey	
			,fg.FiscalYearMonth