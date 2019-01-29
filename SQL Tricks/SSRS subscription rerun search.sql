
/*********************/
DECLARE @SearchTerm VARCHAR(100) = '%apc app%'
/*********************/
SELECT
    S.SubscriptionID
    ,C.Name  AS ReportName
	,S.Description AS SubscriptionName	
	,j.name AS JobName
	,rs.ReportAction
	,sc.EventType  --Indicates whether it is part of a single subscription or a shared subscription.  
	,
		CASE 
			WHEN j.name IS NULL 
				THEN 'exec [ReportServerR2].dbo.AddEvent @EventType=''TimedSubscription'', @EventData=''' + CAST(s.SubscriptionID AS VARCHAR(40)) + ''''
			ELSE 'exec msdb.dbo.sp_start_job @job_name = ''' + CAST(j.name AS VARCHAR(40)) + '''' 
		END AS ScriptToRerunJob	 --Use "TimedSubscription" to run a single subscription or "SharedSchedule" to run 
								 --all reports on that schedule.  I still have to research what GUID to use for that
FROM ReportServerR2.dbo.Subscriptions S
	INNER JOIN ReportServerR2.dbo.Catalog C ON S.Report_OID = C.ItemID
	LEFT JOIN  msdb.dbo.sysjobsteps js ON js.command LIKE '%' + CAST(s.SubscriptionID AS VARCHAR(40)) + '%'
	LEFT JOIN msdb.dbo.sysjobs j ON j.job_id = js.job_id
	LEFT JOIN ReportServerR2.dbo.ReportSchedule rs ON rs.SubscriptionID = S.SubscriptionID
	LEFT JOIN ReportServerR2.dbo.Schedule sc ON sc.ScheduleID = rs.ScheduleID
WHERE 
	c.name LIKE @SearchTerm
	OR s.Description LIKE @SearchTerm

