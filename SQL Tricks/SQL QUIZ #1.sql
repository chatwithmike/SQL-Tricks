
--
--     Fanatics SQL QUIZ #1
--  
--  Select the top 10 most recent orders and the second item (when ordering by item id)
--  for orders that have excactly three items in the order
--

select top 10 
	o.order_id
	,o.Order_Date
	,oi2.RPROItemNumber
	,CNT
FROM football2003_ODS.dbo.Orders o with (NOLOCK) 
	CROSS APPLY
	(
		SELECT 
			oi.RPROItemNumber			
			,COUNT(oi.RPROItemNumber) OVER(PARTITION BY oi.Order_Id ORDER BY oi.Order_Id) CNT
		FROM Football2003_ODS.dbo.Ordered_Items as oi with (NOLOCK) 
		WHERE o.Order_Id = oi.Order_Id
			AND oi.RPROItemNumber IS NOT NULL			
		ORDER BY oi.RPROItemNumber
		OFFSET 1 ROWS FETCH FIRST 1 ROWS ONLY
	)oi2
WHERE oi2.CNT = 3
ORDER BY o.Order_Date DESC
