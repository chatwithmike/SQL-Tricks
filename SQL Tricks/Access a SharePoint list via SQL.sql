;
WITH ListItems AS 
( 
	SELECT clrprocedures.dbo.GetListItems
	(
		'http://sharepoint.searshomepro.com/Marketing/TTL/'
		, '{DF7F5A09-7378-4CC4-9A52-5562E8167DA1}', NULL
	) AllListItems
)
                                  
SELECT DISTINCT *
FROM    
(
	SELECT    
		Item.value('@ows_Email_x0020_Address', 'varchar(200)') AS EmailAddress
		,Item.value('@ows_Unit_x0023_', 'varchar(100)') AS Unit
		,Item.value('@ows_SourceID_x0023_', 'varchar(100)') AS SourceID
		,Item.value('@ows_Location', 'varchar(100)') AS Location	
	FROM ListItems
       CROSS APPLY ListItems.AllListItems.nodes('/*/*') Items ( Item )
	WHERE Item.value('@ows_ID', 'varchar(200)') = '1304'
) AS l
