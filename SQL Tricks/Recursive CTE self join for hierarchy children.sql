		WITH cte_subs (SubReportItemID, ParentReportItemID, Level )
		AS
        (
			SELECT DISTINCT 
				rim.ItemID AS SubReportItemID
				,CAST(NULL AS UNIQUEIDENTIFIER) AS ParentReportItemID
				,0 AS Level
			FROM SHIPBI_META.dbo.ReportsInfoMeta rim

			UNION ALL 

			SELECT 
				s.SubReportItemID AS SubReportItemID
				,s.ParentReportItemID AS ParentReportItemID
				,Level + 1
			FROM SHIPBI_META.dbo.ReportsInfoMetaSubReports s 
				INNER JOIN cte_subs cs ON cs.SubReportItemID = s.ParentReportItemID
		)
		SELECT * FROM cte_subs WHERE Level >=2


SELECT * FROM ReportServerR2.dbo.Catalog c WHERE c.ItemID IN ('EDD3D107-1F39-4463-B45A-CE2AA28ED025'
,'6005BD89-7C0A-4AA7-8289-1680A5088AC5'
,'612a92e4-d0a3-44a0-af55-b3d9c181e968')
--		-- Create an Employee table.
--CREATE TABLE #MyEmployees
--(
--	EmployeeID smallint NOT NULL,
--	FirstName nvarchar(30)  NOT NULL,
--	LastName  nvarchar(40) NOT NULL,
--	Title nvarchar(50) NOT NULL,
--	DeptID smallint NOT NULL,
--	ManagerID int NULL,
-- CONSTRAINT PK_EmployeeID PRIMARY KEY CLUSTERED (EmployeeID ASC) 
--);
---- Populate the table with values.
--INSERT INTO #MyEmployees VALUES 
-- (1, N'Ken', N'Sánchez', N'Chief Executive Officer',16,NULL)
--,(273, N'Brian', N'Welcker', N'Vice President of Sales',3,1)
--,(274, N'Stephen', N'Jiang', N'North American Sales Manager',3,273)
--,(275, N'Michael', N'Blythe', N'Sales Representative',3,274)
--,(276, N'Linda', N'Mitchell', N'Sales Representative',3,274)
--,(285, N'Syed', N'Abbas', N'Pacific Sales Manager',3,273)
--,(286, N'Lynn', N'Tsoflias', N'Sales Representative',3,285)
--,(16,  N'David',N'Bradley', N'Marketing Manager', 4, 273)
--,(23,  N'Mary', N'Gibson', N'Marketing Specialist', 4, 16);


--WITH DirectReports (ManagerID, EmployeeID, Title, DeptID, Level)
--AS
--(
---- Anchor member definition
--    SELECT e.ManagerID, e.EmployeeID, e.Title, edh.DepartmentID, 
--        0 AS Level
--    FROM #MyEmployees AS e
--    INNER JOIN HumanResources.EmployeeDepartmentHistory AS edh
--        ON e.EmployeeID = edh.BusinessEntityID AND edh.EndDate IS NULL
--    WHERE ManagerID IS NULL
--    UNION ALL
---- Recursive member definition
--    SELECT e.ManagerID, e.EmployeeID, e.Title, edh.DepartmentID,
--        Level + 1
--    FROM #MyEmployees AS e
--    INNER JOIN HumanResources.EmployeeDepartmentHistory AS edh
--        ON e.EmployeeID = edh.BusinessEntityID AND edh.EndDate IS NULL
--    INNER JOIN DirectReports AS d
--        ON e.ManagerID = d.EmployeeID
--)
---- Statement that executes the CTE
--SELECT ManagerID, EmployeeID, Title, DeptID, Level
--FROM DirectReports
--INNER JOIN HumanResources.Department AS dp
--    ON DirectReports.DeptID = dp.DepartmentID
--WHERE dp.GroupName = N'Sales and Marketing' OR Level = 0;
--GO
