USE [SHIPBI_ETL]
GO

/****** Object:  StoredProcedure [dbo].[ProcLoadDimLeadImportVendor]    Script Date: 8/6/2018 9:48:18 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[ProcLoadDimLeadImportVendor] (@AuditKey INT, @InsertRows INT OUTPUT, @UpdateRows INT OUTPUT, @DeleteRows INT OUTPUT, @NoChangeRows INT OUTPUT)
AS 

-- ========================================================================================
-- Author:       SPRAYTECH\mmiller 
-- Create date: 3/21/2017 2:56 PM
-- Description:  Load DimLeadImportVendor
-- Modification: 
-- ========================================================================================

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET NOCOUNT ON

-- ========================================================================================

BEGIN TRY

-- ========================================================================================
	-- For tesing 
	--DECLARE 
	--	@AuditKey INT = 1 
	--	,@InsertRows INT
	--	,@UpdateRows INT
	--	,@DeleteRows INT
	--	,@NoChangeRows INT

	-- 
	--  Table variable to hold actions (insert/delete) for output count
	--
	DECLARE	@MergeAction TABLE (ActionType CHAR(1))

	
	
	TRUNCATE TABLE Stage.DimLeadImportVendor
	--
	-- Stage data
	--
	INSERT INTO Stage.DimLeadImportVendor
	(
	    LeadImportVendorID
		,LeadImportVendorName
		,LeadImportVendorIsActive
		,LeadImportVendorAllowWebLeads
		,LeadImportVendorExperianIsEnabled
		,RowHash
	)
    SELECT
        siv.LeadImportVendorID
       ,siv.LeadImportVendorName
       ,siv.LeadImportVendorIsActive
       ,siv.LeadImportVendorAllowWebLeads
       ,siv.LeadImportVendorExperianIsEnabled
	   ,BINARY_CHECKSUM( siv.LeadImportVendorID
                       ,siv.LeadImportVendorName
                       ,siv.LeadImportVendorIsActive
                       ,siv.LeadImportVendorAllowWebLeads
                       ,siv.LeadImportVendorExperianIsEnabled)
    FROM
        (
          SELECT
            ImportVendorID AS LeadImportVendorID
           ,Description AS LeadImportVendorName
           ,Active AS LeadImportVendorIsActive
           ,COALESCE(AllowWebLeads, 0) AS LeadImportVendorAllowWebLeads
           ,COALESCE(ExperianEnabled, 0) AS LeadImportVendorExperianIsEnabled
          FROM
            SQLSERVER.leads.dbo.ImportVendor
        ) siv


	--
	--   Initial row count of table.  Used to mathematically determine unchanged rowcount.  
	--
	DECLARE @StagedRowCount AS INT = (SELECT COUNT(*) AS StageRowCount FROM Stage.DimLeadImportVendor)
		
	--
	--  Load DimLeadImportVendor
	--	
	MERGE SHIPBI.dbo.DimLeadImportVendor AS tgt
	USING Stage.DimLeadImportVendor AS src
	ON tgt.LeadImportVendorID = src.LeadImportVendorID
	WHEN MATCHED AND tgt.rowhash <> src.rowhash THEN 
		UPDATE SET 			 
			 tgt.LeadImportVendorName				= src.LeadImportVendorName			
			,tgt.LeadImportVendorIsActive			= src.LeadImportVendorIsActive			
			,tgt.LeadImportVendorAllowWebLeads		= src.LeadImportVendorAllowWebLeads	
			,tgt.LeadImportVendorExperianIsEnabled	= src.LeadImportVendorExperianIsEnabled
			,tgt.RowHash							= src.RowHash						
			,tgt.AuditKey							= @AuditKey
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT
		(
			 LeadImportVendorID					
			,LeadImportVendorName				
			,LeadImportVendorIsActive				
			,LeadImportVendorAllowWebLeads		
			,LeadImportVendorExperianIsEnabled	
			,RowHash							
			,AuditKey
		)
		VALUES 
		(
			 src.LeadImportVendorID				
			,src.LeadImportVendorName			
			,src.LeadImportVendorIsActive			
			,src.LeadImportVendorAllowWebLeads	
			,src.LeadImportVendorExperianIsEnabled
			,src.RowHash						
			,@AuditKey

		)
	OUTPUT 
		LEFT($action,1)
	INTO 
		@MergeAction (ActionType);
	
	SELECT
		 @InsertRows = COALESCE(SUM(CASE WHEN ma.ActionType = 'I' THEN 1 ELSE 0 END),0)
		,@UpdateRows = COALESCE(SUM(CASE WHEN ma.ActionType = 'U' THEN 1 ELSE 0 END),0)
	FROM
		@MergeAction ma

	SELECT 
	    @DeleteRows = 0
		,@NoChangeRows = (@StagedRowCount - (@InsertRows + @UpdateRows))
		
	-- For testing values in output variables
	--SELECT
	--	@InsertRows
	--	,@UpdateRows
	--    ,@DeleteRows
	--	,@NoChangeRows
-- ========================================================================================

END TRY

-- ========================================================================================

BEGIN CATCH

-- ========================================================================================

DECLARE
                @ErrorMessage NVARCHAR(4000),
                @ErrorNumber INT,
                @ErrorSeverity INT,
                @ErrorState INT,
                @ErrorLine INT,
                @ErrorProcedure NVARCHAR(200)

SET @ErrorNumber = ERROR_NUMBER()
SET @ErrorSeverity = ERROR_SEVERITY()
SET @ErrorState = ERROR_STATE()
SET @ErrorLine = ERROR_LINE()
SET @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-')
SET @ErrorMessage = N'Error %d, Level %d, State %d, Procedure %s, Line %d ' + 
                'Message: ' + ERROR_MESSAGE()

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


GO


