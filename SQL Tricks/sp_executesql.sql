USE [SHIPBI]
GO

/****** Object:  StoredProcedure [dbo].[RptMACMarketingSourceChanged]    Script Date: 8/6/2018 1:12:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[RptMACMarketingSourceChanged] 
(
	@pStartDate DATETIME 
	,@pEndDate	DATETIME  
)
AS 
/*
    -- ========================================================================================
    -- Author:       SPRAYTECH\mmiller 
    -- Create date: 6/11/2018 2:58 PM
    -- Description:		
			Show all lead source types within the specified date range.  This is to ensure that 
			the correct marketing source is being used when new leads are created.  via SR173717
    -- Modification: 
    -- ========================================================================================
*/
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    SET NOCOUNT ON;

    BEGIN TRY

		--
		--  Testing
		--
		--DECLARE @pStartDate DATETIME = '2018/01/01'
		--DECLARE @pEndDate	DATETIME = GETDATE()
		
		
		--
		-- Get all lead source type changes
		--		
		DECLARE @parameters NVARCHAR(200) = 
		'
			@pStartDate DATETIME
			,@pEndDate	DATETIME		
		'
		DECLARE @sql NVARCHAR(MAX) = 
		'
			SELECT
				LeadID
				,UpdatedOn
				,LeadSourceTypeID
				,LeadSourceTypeIDOld
				,UpdatedBy
			FROM 
				dbo.MarketingValidationCodeTransaction 
			WHERE 
				UpdatedOn BETWEEN @pStartDate AND @pEndDate 
				AND LeadSourceTypeID <> LeadSourceTypeIDOld
		'
		IF OBJECT_ID('tempdb..#data') IS NOT NULL DROP TABLE #data
		CREATE TABLE #data
		(
			LeadID					INT 
			,UpdatedOn				DATETIME
			,LeadSourceTypeID		INT 
			,LeadSourceTypeIDOld	INT 
			,UpdatedBy				VARCHAR(50)
		)
		INSERT INTO #data
		(
			LeadID					
			,UpdatedOn				
			,LeadSourceTypeID		
			,LeadSourceTypeIDOld	
			,UpdatedBy				
		)
		EXEC SQLSERVER.leads.dbo.sp_executesql @sql, @parameters, @pStartDate, @pEndDate

		--
		--  Output
		--
		SELECT 
			d.LeadID  
			,d.UpdatedOn
			,new.LeadSourceType  NewLeadSourceType
			,old.LeadSourceType  OriginalLeadSourceType
			,du.FirstName + ' ' + du.LastName ChangedBy
			,fl.LeadCreationDate			
			,val.LOB
			,val.Team
		FROM 
			#data d
			LEFT JOIN dbo.DimLeadSourceType new ON new.LeadSourceTypeID = d.LeadSourceTypeID
			LEFT JOIN dbo.DimLeadSourceType old ON old.LeadSourceTypeID = d.LeadSourceTypeIDOld
			LEFT JOIN dbo.DimUser du ON du.UserName = d.UpdatedBy
			LEFT JOIN dbo.FactLead fl ON fl.LeadID = d.LeadID
			LEFT JOIN dbo.ViewApcAgentListing val 
				ON val.UserName = d.UpdatedBy
				AND d.UpdatedOn BETWEEN val.EffectiveStartDate AND val.EffectiveEndDate
    END TRY
    BEGIN CATCH

        THROW;

    END CATCH;
GO


