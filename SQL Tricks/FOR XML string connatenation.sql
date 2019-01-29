

  
	--INNER JOIN SHIPBI.dbo.DimUserOUEmailAddress m ON 1=1
	--CROSS APPLY 
	--	(
	--		SELECT 
	--			',' + CAST(r.DimDistrictGroupKey AS VARCHAR(10))
	--		FROM SHIPBI.dbo.DimUserOUEmailAddress r	
	--		WHERE 
	--			r.SamAccount = m.SamAccount
	--			AND r.OUDescription = m.OUDescription			
	--		FOR XML PATH('') 
	--	) x (DistrictList)

