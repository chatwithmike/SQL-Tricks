--
--  Populate a day table
--
DECLARE 
	 @StartDate DATETIME = GETDATE()-1
	,@EndDate	DATETIME = GETDATE()
	
	DECLARE @Days TABLE
	(
		[Day] DATE
	);
	
	WHILE ( @StartDate <= @EndDate )
	BEGIN;
		INSERT @Days( [Day] ) VALUES( @StartDate );
		SET @StartDate = DATEADD(DAY,1,@StartDate);
	END;

SELECT 
	[Day]
FROM @Days