
--
--  This returns a list of columns the tables have in common
--
select 
	ColumnName 
from 
(
	SELECT distinct name ColumnName, OBJECT_NAME(c.object_ID) AS TableName 
	FROM sys.columns c
	WHERE name IN
	(
	SELECT name FROM sys.columns
	GROUP BY name having count(name) > 1
	) 
	--
	--  Put list of tables here 
	--
	and OBJECT_NAME(c.object_ID) in ('WMS_Orders','WMS_Package')
)x
group by ColumnName
having count(ColumnName)>1

--select top 10 * from RETAILTRANSACTIONSALESTRANS.Price = how much an item actually sold for (via Nicholas Larson)

