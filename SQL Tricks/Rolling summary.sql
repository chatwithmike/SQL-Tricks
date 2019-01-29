select 
ProductID
,ITEMID
,ProductName
,OrderedUnits
,SUM(OrderedUnits) OVER( PARTITION BY ProductID
					ORDER BY ProductID,ITEMID 
					ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as RunningTotal
,SUM(OrderedUnits) OVER( PARTITION BY ProductID)
from FanaticsCentral.[Reporting].[DAX_On_Order_Daily] (nolock)
where ProductID = 141337