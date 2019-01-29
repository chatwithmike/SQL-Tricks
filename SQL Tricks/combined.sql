--
--  OUTER APPLY
--
OUTER APPLY 
(				
			SELECT [Event] = PE.SPORTINGEVENTID
			FROM #EventTable
				INNER JOIN MicrosoftDynamicsAX_ODS.dbo.FBFPRODUCTEVENT PE
					ON #EventTable.[Event] = PE.SPORTINGEVENTID
					AND C.FBFProductID = PE.PRODUCTID    	
			ORDER BY FBFProductID
			OFFSET 0 ROWS FETCH FIRST 1 ROWS ONLY
) tblEvents


--
--  CROSS APPLY
--
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

--
--  ROLLING SUMMARY
--
select 
ProductID
,ITEMID
,ProductName
,OrderedUnits
,SUM(OrderedUnits) OVER( PARTITION BY ProductID
					ORDER BY ProductID,ITEMID 
					ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as RunningTotal
from FanaticsCentral.[Reporting].[DAX_On_Order_Daily] (nolock)
where ProductID = 141337