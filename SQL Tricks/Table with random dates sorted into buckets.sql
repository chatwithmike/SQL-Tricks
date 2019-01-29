IF OBJECT_ID('tempdb..#dte') IS NOT NULL DROP TABLE #dte
CREATE TABLE #dte(UserID int, StartDate datetime, EndDate datetime) 
INSERT INTO #dte
SELECT 
	CAST(RAND(CHECKSUM(NEWID())) * 100 AS INT) rndID
	,DATEADD(ss, cast(abs(checksum(newid())) AS INT), '19000101') AS rndStartDate
	,DATEADD(ss, cast(abs(checksum(newid())) AS INT), '19000101') AS rndEndDate
FROM dbo.DynamicNumberTable(1,1000000,1)


DECLARE @bkts TABLE (bucket CHAR(1), bktStartDate DATETIME, bktEndDate DATETIME)
INSERT INTO @bkts
(
    bucket
   ,bktStartDate
   ,bktEndDate
)
VALUES

 ('A','1900-01-01',DATEADD(MILLISECOND,-3,'1910-01-01'))
,('B','1910-01-01',DATEADD(MILLISECOND,-3,'1920-01-01'))
,('C','1920-01-01',DATEADD(MILLISECOND,-3,'1930-01-01'))
,('D','1930-01-01',DATEADD(MILLISECOND,-3,'1940-01-01'))
,('E','1940-01-01',DATEADD(MILLISECOND,-3,'1950-01-01'))
,('G','1950-01-01',DATEADD(MILLISECOND,-3,'1960-01-01'))
,('H','1960-01-01',DATEADD(MILLISECOND,-3,'1970-01-01'))
,('I','1970-01-01',DATEADD(MILLISECOND,-3,'1980-01-01'))
,('J','1980-01-01',DATEADD(MILLISECOND,-3,'1990-01-01'))
,('K','1990-01-01',DATEADD(MILLISECOND,-3,'2000-01-01'))
,('L','2000-01-01',DATEADD(MILLISECOND,-3,'2010-01-01'))
,('M','2010-01-01',DATEADD(MILLISECOND,-3,'2020-01-01'))
,('N','2020-01-01',DATEADD(MILLISECOND,-3,'2030-01-01'))


--SELECT * FROM @bkts
SELECT * FROM @dte

;WITH cte_output AS 
(
SELECT 
	d.UserID
	,b.bucket
	,CASE 
		--Catch inverted ranges
		WHEN d.StartDate > d.EndDate THEN 0
		--Date range falls within bucket
		WHEN d.StartDate BETWEEN b.bktStartDate AND b.bktEndDate
			AND d.EndDate BETWEEN b.bktStartDate AND b.bktEndDate
			THEN DATEDIFF(YEAR,d.StartDate,d.EndDate) 
		--Date range starts outside bucket and ends witin bucket
		WHEN d.StartDate < b.bktStartDate 
			AND d.EndDate BETWEEN b.bktStartDate AND b.bktEndDate
			THEN DATEDIFF(YEAR,b.bktStartDate,d.EndDate) 
		--Date range starts inside bucket and ends outside bucket
		WHEN d.StartDate BETWEEN b.bktStartDate AND b.bktEndDate
			AND d.EndDate > b.bktEndDate
			THEN DATEDIFF(YEAR,d.StartDate,b.bktEndDate) 
		--Date range starts outside bucket and ends outside bucket
		WHEN d.StartDate < b.bktStartDate 
			AND d.EndDate > b.bktEndDate
			THEN DATEDIFF(YEAR,b.bktStartDate,b.bktEndDate) 
	END AS time 
FROM 
	@dte d
	OUTER APPLY @bkts b

)
SELECT 
	o.UserID
	,SUM(CASE WHEN o.bucket = 'A' THEN o.time END) AS 'A'
	,SUM(CASE WHEN o.bucket = 'B' THEN o.time END) AS 'B'
	,SUM(CASE WHEN o.bucket = 'C' THEN o.time END) AS 'C'
	,SUM(CASE WHEN o.bucket = 'D' THEN o.time END) AS 'D'
	,SUM(CASE WHEN o.bucket = 'E' THEN o.time END) AS 'E'
	,SUM(CASE WHEN o.bucket = 'G' THEN o.time END) AS 'G'
	,SUM(CASE WHEN o.bucket = 'H' THEN o.time END) AS 'H'
	,SUM(CASE WHEN o.bucket = 'I' THEN o.time END) AS 'I'
	,SUM(CASE WHEN o.bucket = 'J' THEN o.time END) AS 'J'
	,SUM(CASE WHEN o.bucket = 'K' THEN o.time END) AS 'K'
	,SUM(CASE WHEN o.bucket = 'L' THEN o.time END) AS 'L'
	,SUM(CASE WHEN o.bucket = 'M' THEN o.time END) AS 'M'
	,SUM(CASE WHEN o.bucket = 'N' THEN o.time END) AS 'N'
FROM cte_output o
GROUP BY o.UserID