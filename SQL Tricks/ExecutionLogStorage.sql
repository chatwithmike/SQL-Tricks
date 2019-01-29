SELECT COUNT(*)cnt 
  FROM [ReportServerR2].[dbo].[ExecutionLogStorage] s
  INNER JOIN ReportServerR2.dbo.catalog c ON c.ItemID = s.ReportID
  WHERE 
	c.name = 'Subcontractor Efficiency.rdl'
	AND s.TimeStart >= '12/30/2014'
  SELECT TOP (10) * FROM ReportServerR2.dbo.catalog 