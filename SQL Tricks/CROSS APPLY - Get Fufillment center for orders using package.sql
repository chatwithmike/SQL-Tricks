SELECT 
	o.Order_Id, #FulfillmentCenter.FulfillmentCenter
FROM 
	dbo.Orders o
		CROSS APPLY (
						SELECT p.DistributionCenterID
						FROM football2003_ODS.dbo.Package p 
						WHERE o.Order_Id = p.OrderId
						ORDER BY p.PackageId ASC
						OFFSET 0 ROWS FETCH FIRST 1 ROWS ONLY
					) p2
		INNER JOIN #FulfillmentCenter
			ON p2.DistributionCenterID = #FulfillmentCenter.fb2k3_DistributionCenterID 
WHERE
	(
		o.Order_Date >= @StartDate
		AND 
		o.Order_Date < @EndDate
	)
	AND
	o.ischarged > 1