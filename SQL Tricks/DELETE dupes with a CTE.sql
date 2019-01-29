;WITH cte AS
(
SELECT 
	#x.DimCompanyKey
	,#x.DimStoreKey	
	,ROW_NUMBER() OVER (PARTITION BY  #x.DimCompanyKey,#x.DimStoreKey ORDER BY #x.DimCompanyKey,#x.DimStoreKey) AS RowNum
FROM #x
)
DELETE FROM cte WHERE cte.RowNum > 1