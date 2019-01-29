SELECT 
	c.[Name]
	,s.Description
	,s.LastStatus
	,s.EventType
	,s.DeliveryExtension
	,s.LastRunTime
FROM  [ReportServerR2].[dbo].[Subscriptions] s 
	INNER JOIN [ReportServerR2].[dbo].[Catalog] c ON c.ItemID = s.Report_OID
ORDER BY 5,1
