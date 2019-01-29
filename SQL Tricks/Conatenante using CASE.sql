SELECT DATEPART(SECOND,GETDATE())
WAITFOR DELAY '00:00:01'
GO 5

-------------------



    DECLARE @EmailsTogether VARCHAR(250)
    SET @EmailsTogether = '' ;
	
	
	SELECT @EmailsTogether
    SELECT  @EmailsTogether = @EmailsTogether
            + ( CASE WHEN LEN(@EmailsTogether) > 0 THEN ','
                     ELSE ''
                END ) + CAST(dk.DimDistrictKey AS NVARCHAR(12))
    FROM    shipreports.shipbi.dbo.dimdistrict dk ( NOLOCK )


