/*
recursive CTE (common table expression) example:
1.  query is a union of two select statements
2.  the first is the anchor statement
3.  the second references the first
4.  the where clause limits the number of recursions

The following builds a set of values from 1 to 10.
*/
;
WITH    i AS (
              SELECT
                1 AS i,
				10 AS j
              UNION ALL
              SELECT
                i+1 AS i,
				(i+1)*10
              FROM
                i
              WHERE
                i < 10
             )
    SELECT
        i,
        lag(j, 1) OVER (ORDER BY i) AS PreviousValue,--given the current row's value of i go to the row with the next highest value of i and retrieve j
        lead(j, 1) OVER (ORDER BY i) AS NextValue--given the current row's value of i go to the row with the next lowest value of i and retrieve j
    FROM
        i

--non-recursive cte example
--with grouping sets
;WITH a AS (
SELECT
	1 AS RegionID,
	1 AS DistrictID,
	10 AS SaleAmount
UNION ALL
SELECT
	1 AS RegionID,
	1 AS DistrictID,
	20 AS SaleAmount
UNION ALL
SELECT
	1 AS RegionID,
	2 AS DistrictID,
	30 AS SaleAmount
UNION ALL
SELECT
	2 AS RegionID,
	3 AS DistrictID,
	40 AS SaleAmount
UNION ALL
SELECT
	2 AS RegionID,
	3 AS DistrictID,
	50 AS SaleAmount
),
--let's summarize the previous CTE
b AS (
SELECT
	CASE
		WHEN a.RegionID IS NULL AND a.DistrictID IS NULL THEN 'Company'
		WHEN a.DistrictID IS NULL THEN 'Region'
		ELSE 'District'
	END AS GroupedBy,
	a.RegionID,
	a.DistrictID,
	SUM(a.SaleAmount) AS SaleAmount,
	MIN(a.SaleAmount) AS MinSaleAmount,
	MAX(a.SaleAmount) AS MaxSaleAmount
FROM
	a
GROUP BY
--this basically says that I want the results grouped by regionid, regionid and districtid, and the entire set (to get a grand total)
GROUPING SETS ((a.RegionID),(a.RegionID,a.DistrictID),())
)
SELECT
	*
FROM
	b
ORDER BY
	b.GroupedBy,
	b.RegionID,
	b.DistrictID
