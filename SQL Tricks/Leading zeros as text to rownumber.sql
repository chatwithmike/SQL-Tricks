SELECT 
	REPLICATE('0',3-LEN(ROW_NUMBER()OVER(ORDER BY dd.DimDistrictKey))) AS zeros
	,ROW_NUMBER()OVER(ORDER BY dd.DimDistrictKey) AS num
	,REPLICATE('0',3-LEN(ROW_NUMBER()OVER(ORDER BY dd.DimDistrictKey))) + CAST(ROW_NUMBER()OVER(ORDER BY dd.DimDistrictKey) AS NVARCHAR(11)) x
	,*
FROM shipbi.dbo.DimDistrict AS dd