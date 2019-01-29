--
--  Goals by product
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


--
--  Goals over all products
--
		SELECT 								
			fg.FiscalYearMonth
			,fg.Goal AS GoalGCRByMonth		
		FROM SHIPBI_Batch.dbo.FactGoal fg WITH (NOLOCK) 
			INNER JOIN SHIPBI_Batch.dbo.DimGoalType dgt WITH (NOLOCK) ON dgt.DimGoalTypeKey = fg.DimGoalTypeKey
		WHERE 		
			fg.FiscalYearMonth = '2015-01' --@FiscalYearMonth
			AND dgt.DimGoalTypeKey = 2 --GCR
			AND fg.DimProductKey = -1
			AND fg.BusinessDivisionKey = 1