
SELECT 
	--'select count(BaseManagedEntityId),''' + TABLE_NAME + ''' FROM ' + TABLE_NAME + ' where BaseManagedEntityId = ''5337F70B-2042-3F50-1751-0216BCFBA53C'' UNION ALL '
	'select * FROM ' + TABLE_NAME + ' where EntityChangeLogId in (17368178,17368223,17368237,17405466,17406526,17415112,17415174,17415459,17415462,17415465,17415482,17417080,17418793,17460152,17786365,17786794,17786928)'
FROM information_schema.COLUMNS 
WHERE 
	COLUMN_NAME LIKE 'changetype' 
	--AND TABLE_NAME LIKE '%work%'


	