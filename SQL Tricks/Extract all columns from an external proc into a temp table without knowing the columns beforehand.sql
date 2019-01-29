-- Only works from one server to another 
-- In this example, we are on SHIPREPORTSSQL and are quering SQLSERVER 
SELECT *
INTO  #T
FROM OPENQUERY(SQLSERVER, 
               'SET FMTONLY OFF;
               EXEC SP_Who')
			   		   

SELECT
    *
INTO
    #Appointment
FROM
    OPENROWSET('SQLNCLI11', 'Server=shipreportssql;Trusted_Connection=yes;', 'EXEC SQLSERVER.SHIPBI_DW.dbo.SSISFactAppointmentExtract')
