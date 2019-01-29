
SELECT *
FROM
	 (VALUES
	 (1, 1, 10, 100, 100)
	,(5, 1, 10, 100, 200)
	,(10, 1, 10, 200, 250)
	,(15, 1, 10, 200, 350)
	,(20, 2, 20, 300, 400)
	,(25, 2, 20, 300, 500)
	) Sales (TransactionID, RegionID, CountyIDm, OfficeID, SaleAmount)



SELECT
	*
	--aggregates at multiple levels
	,SUM(Sales.SaleAmount) OVER () AS TotalSaleAmount
	,SUM(Sales.SaleAmount) OVER (PARTITION BY RegionID) AS RegionTotalSaleAmount
	,SUM(Sales.SaleAmount) OVER (PARTITION BY CountyID) AS CountryTotalSaleAmount
	,SUM(Sales.SaleAmount) OVER (PARTITION BY OfficeID) AS OfficeTotalSaleAmount
	--percentages
	,100.0*Sales.SaleAmount/(SUM(Sales.SaleAmount) OVER ()) AS TransactionPercentOfTotalSaleAmount
	,100.0*Sales.SaleAmount/(SUM(Sales.SaleAmount) OVER (PARTITION BY RegionID)) AS TransactionPercentOfRegionTotalSaleAmount
	,100.0*Sales.SaleAmount/(SUM(Sales.SaleAmount) OVER (PARTITION BY CountyID)) AS TransactionPercentOfCountryTotalSaleAmount
	,100.0*Sales.SaleAmount/(SUM(Sales.SaleAmount) OVER (PARTITION BY OfficeID)) AS TransactionPercentOfOfficeTotalSaleAmount
	--min and max
	,MIN(Sales.SaleAmount) OVER () AS MinSaleAmount
	,MAX(Sales.SaleAmount) OVER () AS MaxSaleAmount
	,MIN(Sales.SaleAmount) OVER (PARTITION BY RegionID) AS RegionMinSaleAmount
	,MAX(Sales.SaleAmount) OVER (PARTITION BY RegionID) AS RegionMaxSaleAmount
	,MIN(Sales.SaleAmount) OVER (PARTITION BY CountyID) AS CountryMinSaleAmount
	,MAX(Sales.SaleAmount) OVER (PARTITION BY CountyID) AS CountryMaxSaleAmount
	,MIN(Sales.SaleAmount) OVER (PARTITION BY OfficeID) AS OfficeMinSaleAmount
	,MAX(Sales.SaleAmount) OVER (PARTITION BY OfficeID) AS OfficeMaxSaleAmount
	--running total
	,SUM(Sales.SaleAmount) OVER (ORDER BY TransactionID RANGE BETWEEN unbounded preceding AND CURRENT ROW) AS RunningTotal
	,SUM(Sales.SaleAmount) OVER (PARTITION BY RegionID ORDER BY TransactionID RANGE BETWEEN unbounded preceding AND CURRENT ROW) AS RegionRunningTotal
	,SUM(Sales.SaleAmount) OVER (PARTITION BY CountyID ORDER BY TransactionID RANGE BETWEEN unbounded preceding AND CURRENT ROW) AS CountryRunningTotal
	,SUM(Sales.SaleAmount) OVER (PARTITION BY OfficeID ORDER BY TransactionID RANGE BETWEEN unbounded preceding AND CURRENT ROW) AS OfficeRunningTotal
	,SUM(Sales.SaleAmount) OVER (ORDER BY TransactionID) AS RunningTotal
	,SUM(Sales.SaleAmount) OVER (PARTITION BY RegionID ORDER BY TransactionID) AS RegionRunningTotal
	,SUM(Sales.SaleAmount) OVER (PARTITION BY CountyID ORDER BY TransactionID) AS CountryRunningTotal
	,SUM(Sales.SaleAmount) OVER (PARTITION BY OfficeID ORDER BY TransactionID) AS OfficeRunningTotal
	--row numbers
	,ROW_NUMBER() OVER (ORDER BY TransactionID) AS RowNumber
	,ROW_NUMBER() OVER (PARTITION BY RegionID ORDER BY TransactionID) AS RegionRowNumber
	,ROW_NUMBER() OVER (PARTITION BY CountyID ORDER BY TransactionID) AS CountryRowNumber
	,ROW_NUMBER() OVER (PARTITION BY OfficeID ORDER BY TransactionID) AS OfficeRowNumber
FROM
	 (VALUES
	 (1, 1, 10, 100, 100)
	,(5, 1, 10, 100, 200)
	,(10, 1, 10, 200, 250)
	,(15, 1, 10, 200, 350)
	,(20, 2, 20, 300, 400)
	,(25, 2, 20, 300, 500)
	) Sales (TransactionID, RegionID, CountyID, OfficeID, SaleAmount)


SELECT
	    dta.GCR,
	    dta.SalesRep,
	    dta.DistrictID,
		DENSE_RANK() OVER (ORDER BY GCR DESC) AS DenseRankByGCR,
		RANK() OVER (ORDER BY GCR DESC) AS RankByGCR,
		ROW_NUMBER() OVER (ORDER BY GCR DESC) AS RowNumberByGCR,
		NTILE(4) OVER (ORDER BY GCR DESC) AS QuartileByGCR,
		NTILE(5) OVER (ORDER BY GCR DESC) AS QuintileByGCR,
		DENSE_RANK() OVER (PARTITION BY DistrictID ORDER BY GCR DESC) AS DenseRankByDistrictAndGCR,
		RANK() OVER (PARTITION BY DistrictID ORDER BY GCR DESC) AS RankByDistrictAndGCR,
		ROW_NUMBER() OVER (PARTITION BY DistrictID ORDER BY GCR DESC) AS RowNumberByDistrictAndGCR,
		NTILE(4) OVER (PARTITION BY DistrictID ORDER BY GCR DESC) AS QuartileByDistrictAndGCR,
		NTILE(5) OVER (PARTITION BY DistrictID ORDER BY GCR DESC) AS QuintileByDistrictAndGCR
FROM
	(VALUES 
		 (23.0,'Bob',1)
		,(23.5,'John',2)
		,(24.0,'Jim',2)
		,(24.5,'Jane',2)
		,(25.0,'Tim',1)
		,(25.0,'Tom',1)
		,(24.5,'Jeff',1)
		,(24.0,'Dave',2)
		,(23.0,'Michael',2)
	) dta (GCR, SalesRep, DistrictID)
