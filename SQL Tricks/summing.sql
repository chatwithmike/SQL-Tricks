--select case when null <> 0 then 1 end

--select top 10 * from fanaticscentral.[Reporting].[Dax_Items_Info]
--select
--	fbfproductid
--	,ItemName
--	,RetailPrice
--	,RunningTotal = sum(RetailPrice) OVER(PARTITION BY fbfproductid
--	                       ORDER BY fbfproductid,SortOrder
--						   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
--	,ProductTotal = sum(RetailPrice) OVER(PARTITION BY fbfproductid)
--	,GrandTotal	  = sum(RetailPrice) OVER()
--from fanaticscentral.[Reporting].[Dax_Items_Info]
--where Dept = 'TEE' AND Color = 'Red' and ExpirationDate < '1/1/2009'
--group by fbfproductid,ProductName,ItemName,SortOrder,RetailPrice
--order by ProductName,SortOrder

--select top 10 * from fanaticscentral.reporting.DAX_Sales_By_Day where sale_date = '2012-04-03'

select
	ProductID
	--,sum(cost)
	--,GrandTotal = sum(Cost) over()
	--,ProductTotal = sum(cost) over(partition by Productid)
	--,PercentOfGrandTotal = (sum(cost) over(partition by Productid)) / (sum(Cost) over())
from fanaticscentral.reporting.DAX_Sales_By_Day 
where sale_date = '2012-04-03'
group by 
	ProductID
	--,cost
--order by ProductID
order by (sum(cost) over(partition by Productid)) / (sum(Cost) over()) desc