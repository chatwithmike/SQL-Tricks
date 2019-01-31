
SELECT CONVERT(VARCHAR(MAX), content) as my_source_code 
FROM sys.assembly_files WHERE name = 'CLR_Split.cs'

