
SELECT SCHEMA_NAME(SCHEMA_ID) AS [Schema], 
SO.name AS [ObjectName],
SO.Type_Desc AS [ObjectType (UDF/SP)],
P.parameter_id AS [ParameterID],
P.name AS [ParameterName],
TYPE_NAME(P.user_type_id) AS [ParameterDataType],
P.max_length AS [ParameterMaxBytes],
P.is_output AS [IsOutPutParameter]
FROM sys.objects AS SO
INNER JOIN sys.parameters AS P 
ON SO.OBJECT_ID = P.OBJECT_ID
WHERE SO.OBJECT_ID IN ( SELECT OBJECT_ID 
FROM sys.objects
WHERE TYPE IN ('P','FN'))
AND SO.type_desc = 'SQL_STORED_PROCEDURE'
AND SO.name LIKE 'RPT%'
--AND P.name LIKE '%FULFILL%'
ORDER BY [Schema], SO.name, P.parameter_id
GO
