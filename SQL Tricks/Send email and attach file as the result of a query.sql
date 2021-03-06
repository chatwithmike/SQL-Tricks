USE [SHIPBI_ETL]
GO
/****** Object:  StoredProcedure [dbo].[SalesRepDataDumpEmail]    Script Date: 2/13/2017 1:11:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[SalesRepDataDumpEmail] 

AS 

-- ========================================================================================
-- Author:       SPRAYTECH\mmiller 
-- Create date: 3/24/2016 4:26 PM
-- Description: Generates an email of a data dump for DimSalesRepRollup and DimSalesRep
-- Modification: 
-- 02/13/2017 mmiller IR26336: Replace DimTime with DimDate
-- ========================================================================================

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET NOCOUNT ON

-- ========================================================================================

BEGIN TRY

-- ========================================================================================


DECLARE @dte  AS DATETIME   = GETDATE()
DECLARE @mnth AS CHAR(7)    = CONVERT(CHAR(7), @dte, 121)  -- This formats the date as YYYY-MM-DD but returns YYYY-MM because we are getting only the first 7 characters

/*
	Only send out on the First work day of the month
*/
IF @dte = 
(
	SELECT 	
		MIN(dt.CalendarDate)	
	FROM SHIPBI.dbo.DimDate AS dt WITH (NOLOCK) 
	WHERE 
		dt.WorkDayFlag = 1
		AND dt.CalendarMonth = @mnth
)
BEGIN 
	--
	--  Internal parameters
	--
	DECLARE @recipients					AS NVARCHAR(300) = 'Steven.Feldman@searshomepro.com;Larry.Spencer@searshomepro.com;Reports@searshomepro.com'
	DECLARE @period						AS NVARCHAR(14)  = DATENAME(month ,@dte) + ' ' + DATENAME(YEAR ,@dte)
	DECLARE @TableName					AS NVARCHAR(20)	 = 'DimSalesRepRollup'
	DECLARE @Subject					AS NVARCHAR(100) = @TableName + ' - Export - ' + @period
	DECLARE @query_result_separator		AS NVARCHAR(10)  = CHAR(9)  --Tab delimited
	DECLARE @body						AS NVARCHAR(100) = 'Attached are the contents of ' + @TableName + ' for ' + @period
	DECLARE @fileformat					AS CHAR(3)		 = '.txt'
	DECLARE @query_attachment_filename	AS NVARCHAR(100) = @TableName + @fileformat
	

	--
	--  Send out DimSalesRepRollup
	--
	EXEC msdb.dbo.sp_send_dbmail 
	   @recipients                  = @recipients, 
	   @subject                     = @Subject,
	   @body                        = @body,
	   @query                       = 'SET NOCOUNT ON; SELECT * FROM shipbi.dbo.DimSalesRepRollUp WITH (NOLOCK);',
	   @execute_query_database      = 'SHIPBI',  
	   @attach_query_result_as_file = 1,
	   @query_attachment_filename   = @query_attachment_filename,
	   @query_result_separator      = @query_result_separator,
	   @query_result_no_padding     = 1

	--
	--  DimSalesRep
	--
	--		Prep parameters
	SET @TableName				   = 'DimSalesRep'
	SET @Subject				   = @TableName + ' - Export - ' + @period
	SET @body					   = 'Attached are the contents of ' + @TableName + ' for ' + @period
	SET @query_attachment_filename = @TableName + @fileformat

	--		Send out mail
	EXEC msdb.dbo.sp_send_dbmail 
	   @recipients                  = @recipients, 
	   @subject                     = @Subject,
	   @body                        = @body,
	   @query                       = 'SET NOCOUNT ON; SELECT  SalesRepID, EmployeeID, FirstName, LastName FROM shipbi.dbo.DimSalesRep WITH (NOLOCK);',
	   @execute_query_database      = 'SHIPBI',  
	   @attach_query_result_as_file = 1,
	   @query_attachment_filename   = @query_attachment_filename,
	   @query_result_separator      = @query_result_separator,
	   @query_result_no_padding     = 1
END 
   
                
-- ========================================================================================

END TRY

-- ========================================================================================

BEGIN CATCH

-- ========================================================================================

DECLARE
                @ErrorMessage nvarchar(4000),
                @ErrorNumber int,
                @ErrorSeverity int,
                @ErrorState int,
                @ErrorLine int,
                @ErrorProcedure nvarchar(200)

SET @ErrorNumber = Error_Number()
SET @ErrorSeverity = Error_Severity()
SET @ErrorState = Error_State()
SET @ErrorLine = Error_Line()
SET @ErrorProcedure = IsNull(Error_Procedure(), '-')
SET @ErrorMessage = N'Error %d, Level %d, State %d, Procedure %s, Line %d ' + 
                'Message: ' + Error_Message()

-- Raise the Error

RAISERROR
                (
                @ErrorMessage,
                @ErrorSeverity,
                1,
                @ErrorNumber,
                @ErrorSeverity,
                @ErrorState,
                @ErrorProcedure,
                @ErrorLine
                )

-- ========================================================================================

END CATCH

-- ========================================================================================
