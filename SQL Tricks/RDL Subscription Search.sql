exec ReportServerR2.dbo.AddEvent @EventType='TimedSubscription', @EventData='xxxx-xxxx-xxxx...'

SELECT 
      c.Name AS ReportName
      , rs.ScheduleID AS JOB_NAME
      , s.[Description]
      , s.LastStatus
      , s.LastRunTime
FROM 
      ReportServerR2..[Catalog] c 
      JOIN ReportServerR2..Subscriptions s ON c.ItemID = s.Report_OID 
      JOIN ReportServerR2..ReportSchedule rs ON c.ItemID = rs.ReportID
      AND rs.SubscriptionID = s.SubscriptionID
WHERE s.LastStatus LIKE '%failure%'
