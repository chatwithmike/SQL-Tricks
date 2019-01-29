select 
	id
	,SUM(N1)	
FROM 
(
	VALUES 
		('a',1,2)
		,('a',3,4)
		,('b',5,6)
		,('b',7,8)
		,('b',NULL,10)
		,('c',11,12)
		,('c',13,14)
) tblNumbers(id,n1,n2)
GROUP BY id 

--SELECT 1 / 2
--SELECT 1 / 3.
--SELECT 
--	id
--	,tblNumbers.n1
--	,DENSE_RANK() OVER (ORDER BY n1 DESC)DenseRank
--	,RANK() OVER (ORDER BY n1 DESC)Rnk
--FROM 
--(
--	VALUES 

--('Columbus'					,0)
--,('Minneapolis'				,0)
--,('Chicago Interior'		,1)
--,('New Orleans'				,1)
--,('Chicago Exterior'		,1)
--,('Cleveland'				,1)
--,('New York City'			,1)
--,('Milwaukee'				,1)
--,('Pittsburgh'				,2)
--,('Hartford'				,2)
--,('Detroit'					,2)
--,('San Antonio'				,4)
--,('New Jersey North'		,4)
--,('Houston'					,5)
--,('Long Island'				,8)
--) tblNumbers(id,n1)
--ORDER BY 
--	2 DESC 




