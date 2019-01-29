SELECT TOP 10 
	o.order_id
	,o.Order_Date
	,RPROItemNumber = 
		STUFF
		(
			(
				SELECT ', ' + CAST(oi.RPROItemNumber AS VARCHAR) 
				FROM Football2003_ODS.dbo.Ordered_Items AS oi WITH (NOLOCK) 
				WHERE o.Order_Id = oi.Order_Id
				ORDER BY oi.RPROItemNumber DESC
				FOR XML PATH('')
			), 1, 2, '' 
		)
FROM football2003_ODS.dbo.Orders o WITH (NOLOCK) 
ORDER BY o.Order_Date DESC
