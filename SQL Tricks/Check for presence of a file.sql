
IF OBJECT_ID('tempdb..#DirectoryTree') IS NOT NULL
      DROP TABLE #DirectoryTree;
CREATE TABLE #DirectoryTree (
       id int IDENTITY(1,1)
      ,subdirectory nvarchar(512)
      ,depth int
      ,isfile bit);

INSERT INTO #DirectoryTree (subdirectory,depth,isfile)
--The first paramater is the path to search.  The second is how many levels to go down.  0 pulls everything.  The third is to include or exclude files.  0 to exclude, 1 to include. 
EXEC master.dbo.xp_dirtree '\\homepro1\share01\HRDataAnalysis\Hours for APC MC Bonus\', 0, 1

SELECT * FROM #DirectoryTree 
WHERE subdirectory = 'MC_COMMISSION_HRS.xls'
--WHERE isfile = 1 AND RIGHT(subdirectory,4) = '.xls'
;

GO
