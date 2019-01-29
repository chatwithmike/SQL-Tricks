SELECT DISTINCT 
	--','''+ad.Email+''''
	ad.Email
FROM SQLSERVER.leads.dbo.aduser ad WITH (NOLOCK) 
WHERE SAMAccount IN 
	(
		SELECT DISTINCT
		--SELECT TOP 10 
			REPLACE(e.UserName,'SPRAYTECH\','') COLLATE SQL_Latin1_General_CP1_CI_AS AS UserName
		from ReportServerR2.dbo.Executionlog e
			INNER join ReportServerR2.dbo.Catalog c on (e.ReportID=c.ItemID)
		--WHERE c.Name LIKE 'Completed%jobs%without%'	
		--WHERE c.Name = 'Salesman Performance by Prime-Plus.rdl'	
		WHERE c.Name = 'Salesman Performance vs Par.rdl'	
		--WHERE c.Name = 'Salesman Training And Advances.rdl'	--3!
		
		
	)
ORDER BY 1


