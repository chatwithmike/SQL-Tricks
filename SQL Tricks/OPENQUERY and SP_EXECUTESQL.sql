USE [SHIPBI]
GO

/****** Object:  StoredProcedure [dbo].[RptServiceCSRPerformanceSummary]    Script Date: 8/6/2018 3:10:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[RptServiceCSRPerformanceSummary]
    (
     @pStartDate SMALLDATETIME
    ,@pEndDate SMALLDATETIME
    ,@pDimDistrictKey VARCHAR(MAX)
    ,@pDimProductKey VARCHAR(MAX)
    )
AS /*
-- ========================================================================================
-- Author:       thays 
-- Create date: 4/26/2013 10:41 AM
-- Description: Generates a dataset for the Service CSR Performance report 
-- Modification: 
-- 08/20/2014 Thays: Edited New Values into the 2014 Score Card.
-- 03/05/2015 Rramus: Edited New Values into the 2015 Scorecard per WO 554562  3 pts per $100 in
--   sales needed to be altered
-- 06/08/2015 Thays: Added the @AgedServiceWeight because Jim Wanted to Heavily Penalize people when they have old services.
-- Also Added @AgedPercent
-- 05/06/2016 mmiller: SR24803 - added code to "Inspections" section
-- 07/28/2016 dwehme: SR43776 - removed restriction that only allowed the 1st inspection in a calendar month to be counted
--								applied during the inspection insert into #CompleteList

	09/07/2016 mmiller: SR47130 
		* Only deduct for aged services assigned to "Service Responsibility" aka, Responsible Party - Service 
		* Add filters for product and district
		* Opimized using OPENQUERY and SP_EXECUTESQL			
		* Approval given on 10/26/2016
	
	2017/07/31	SMILFS	SR118292
		Set the aged service deductions to only trigger if more than 10 services total were found, otherwise set the deduction to 0 in the final step
-- ========================================================================================
*/
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    SET NOCOUNT ON;

-- ========================================================================================

    BEGIN TRY

-- ========================================================================================


-- Test Parameters.
--DECLARE 
--	@pStartDate SMALLDATETIME = '2016/09/01'
--    ,@pEndDate SMALLDATETIME = '2016/09/07'
--	,@pDimDistrictKey VARCHAR(MAX) = (SELECT ',' + CAST(dd.DimDistrictKey AS CHAR(10)) FROM SHIPBI.dbo.DimDistrict dd WITH (NOLOCK) WHERE dd.MasterListActive = 1 FOR XML PATH(''))
--	,@pDimProductKey VARCHAR(MAX) = (SELECT ',' + CAST(dp.DimProductKey AS CHAR(12)) FROM SHIPBI.dbo.DimProduct dp WITH (NOLOCK) FOR XML PATH(''))
	
	--
	-- Prep parameters for filtering
	--
        SET @pDimDistrictKey = dbo.FormatCharIndexFilterList(@pDimDistrictKey);
        SET @pDimProductKey = dbo.FormatCharIndexFilterList(@pDimProductKey);
	
	--
	--  Internal Parameters
	--
        DECLARE @AgedServiceWeight INT = 5;
        DECLARE @AgedPercent DECIMAL(3, 2) = .08;

        DECLARE @SQLString NVARCHAR(MAX); 
        DECLARE @ParmDefinition NVARCHAR(500) = '
			@pStartDate SMALLDATETIME
			,@pEndDate SMALLDATETIME
			,@pDimDistrictKey VARCHAR(MAX) 
			,@pDimProductKey VARCHAR(MAX) 
		';

		--
		-- Spins up the Open Services for the Point Deductions.
		--
        IF OBJECT_ID('tempdb..#OpenServices') IS NOT NULL
            DROP TABLE #OpenServices; 
        SELECT
            fj.DimDistrictKey
           ,COUNT(fj.ApptKey) AS TotalServiceCount
           ,SUM(CASE WHEN DATEDIFF(dd, fj.ComplaintDate, GETDATE()) >= 60 THEN 1
                     ELSE 0
                END) AS GreaterThan60
           ,CONVERT (DECIMAL(4, 3), SHIPBI.dbo.FunDivision(SUM(CASE WHEN DATEDIFF(dd, fj.ComplaintDate, GETDATE()) >= 60
                                                                    THEN 1
                                                                    ELSE 0
                                                               END), COUNT(fj.ApptKey))) AS GreaterThan60Perc
           ,ROUND(( CASE WHEN CONVERT (DECIMAL(4, 3), SHIPBI.dbo.FunDivision(SUM(CASE WHEN DATEDIFF(dd, fj.ComplaintDate,
                                                                                                    GETDATE()) >= 60
                                                                                      THEN 1
                                                                                      ELSE 0
                                                                                 END), COUNT(fj.ApptKey)) - @AgedPercent) < 0.000
                         THEN 0.000
                         ELSE CONVERT (DECIMAL(4, 3), SHIPBI.dbo.FunDivision(SUM(CASE WHEN DATEDIFF(dd, fj.ComplaintDate,
                                                                                                    GETDATE()) >= 60
                                                                                      THEN 1
                                                                                      ELSE 0
                                                                                 END), COUNT(fj.ApptKey)) - @AgedPercent)
                              * ( 100 * @AgedServiceWeight )
                    END ), 0, 1) AS AgedService
        INTO
            #OpenServices
        FROM
            SHIPBI.dbo.FactJob fj WITH ( NOLOCK )
            INNER JOIN SHIPBI.dbo.DimJobType AS djt WITH ( NOLOCK ) ON fj.DimJobTypeKey = djt.DimJobTypeKey
            INNER JOIN SHIPBI.dbo.DimDistrict AS dd WITH ( NOLOCK ) ON dd.DimDistrictKey = fj.DimDistrictKey
            INNER JOIN SHIPBI.dbo.DimProduct AS dp WITH ( NOLOCK ) ON dp.DimProductKey = fj.DimProductKey
            INNER JOIN OPENQUERY(SQLSERVER, '			
							SELECT 
								s.JobID
								,s.ApptDate
								,s.ProductID
							FROM SQLSERVER.leads.dbo.Service s 
							WHERE s.DeptCode = 3 --Responsible Party type "Service"
						') AS s -- Filter the Open Services to only those who have a Repsponsible Party of type "Service"
            ON fj.LeadID = s.JobID
               AND fj.ApptDate = s.ApptDate
               AND fj.DimProductKey = s.ProductID
        WHERE
            djt.CountAsServiceFlag != 0
            AND fj.CompletionDate IS NULL
            AND CHARINDEX(',' + CAST(dd.DimDistrictKey AS VARCHAR(10)) + ',', @pDimDistrictKey) > 0
            AND CHARINDEX(',' + CAST(dp.DimProductKey AS VARCHAR(10)) + ',', @pDimProductKey) > 0
        GROUP BY
            fj.DimDistrictKey; 

        CREATE INDEX XI_#OpenServices_DimDistrictKey ON #OpenServices(DimDistrictKey);

		
		--
		--  Get Inspections
		--				

        SET @SQLString = '
			SELECT  J.AppointmentID ,
					sc.JobID ,
					sc.ApptDate ,
					sc.ProductID ,
					j.OfficeID ,
					sc.VisitDate ,
					sc.ServiceTripTypeID ,
					NULL AS CompletionDate ,
					subc.SubContractorID ,
					ROW_NUMBER() OVER ( PARTITION BY j.AppointmentID,
										subc.SubContractorID,
										DATEPART(m, sc.VisitDate) ORDER BY J.AppointmentID ) AS RowNum ,
					sc.Completed AS Completed ,
					NULL AS FISaleAmount ,
					sc.OfficeStaffName
			FROM    sqlserver.leads.dbo.ServiceCost sc WITH ( NOLOCK )
					INNER JOIN sqlserver.leads.dbo.Job J WITH ( NOLOCK ) ON sc.JobID = J.JobID
																  AND sc.ProductID = J.ProductID
																  AND sc.ApptDate = J.ApptDate				
					LEFT JOIN sqlserver.leads.dbo.SubContractor AS subc WITH ( NOLOCK ) ON ISNULL(sc.ServiceTechID,25730) = subc.SubContractorID
					LEFT JOIN SQLSERVER.leads.dbo.Office AS o ON o.OfficeID = J.OfficeID
			WHERE   sc.VisitDate BETWEEN @pStartDate AND @pEndDate
					AND sc.ServiceTripTypeID = 2
					AND subc.Employee != 0
					AND subc.SubcontractorID != 25730 -- Office Staff Inspections.
					AND j.JobTypeID IN ( 1, 7 ) -- Can Only Be Frontline Jobs that are being Inspected.
					AND ( j.CompletionDate IS NULL --The Job Must be In Progress
														OR sc.VisitDate BETWEEN j.CompletionDate AND DATEADD(m,-6,j.CompletionDate) -- Inspection Occurred 6 months Prior To Completion
										  OR sc.VisitDate BETWEEN j.CompletionDate AND DATEADD(d, +30, j.CompletionDate) -- Inspection Occurred Thirty Days After Completion
										)
	';

        IF OBJECT_ID('tempdb..#Inspections') IS NOT NULL
            DROP TABLE #Inspections; 
        CREATE TABLE #Inspections
            (
             AppointmentID INT
            ,JobID INT
            ,ApptDate SMALLDATETIME
            ,ProductID INT
            ,OfficeID INT
            ,VisitDate SMALLDATETIME
            ,ServiceTripTypeID INT
            ,CompletionDate SMALLDATETIME
            ,SubContractorID INT
            ,RowNum INT
            ,Completed INT
            ,FISaleAmount SMALLMONEY
            ,OfficeStaffName VARCHAR(60)
            );
        INSERT  INTO #Inspections
                (
                 AppointmentID
                ,JobID
                ,ApptDate
                ,ProductID
                ,OfficeID
                ,VisitDate
                ,ServiceTripTypeID
                ,CompletionDate
                ,SubContractorID
                ,RowNum
                ,Completed
                ,FISaleAmount
                ,OfficeStaffName
	            )
                EXEC SQLSERVER.master.dbo.SP_EXECUTESQL
                    @SQLString
                   ,@ParmDefinition
                   ,@pStartDate
                   ,@pEndDate
                   ,@pDimDistrictKey
                   ,@pDimProductKey;


		--
		--  Remove records based on filters
		--      This has to be done here rather than the SP_EXECUTESQL because some of the records are listed in 
		--      production (SQLSERVER) are under districts that are not active, therefore, they have to be rolled 
		--      up to the active one using DimOfficeProduct (SHIPREPORTSQL)
		--
        DELETE
            s
        FROM
            #Inspections s
            INNER JOIN SHIPBI.dbo.DimOfficeProduct AS dop ON s.OfficeID = dop.DimOfficeKey
                                                             AND COALESCE(s.ProductID, -1) = dop.DimProductKey
        WHERE
            NOT CHARINDEX(',' + CAST(dop.DimDistrictKey AS VARCHAR(10)) + ',', @pDimDistrictKey) > 0
            AND CHARINDEX(',' + CAST(s.ProductID AS VARCHAR(10)) + ',', @pDimProductKey) > 0;


        CREATE INDEX XI_#Inspections_AppointmentID ON #Inspections(AppointmentID);

	--
	-- Get Service Trips and Count as Services.
	--
        SET @SQLString = '
	    SELECT  J.AppointmentID ,
                sc.JobID ,
                sc.ApptDate ,
                sc.ProductID ,
                j.OfficeID ,
                sc.VisitDate ,
                sc.ServiceTripTypeID ,
                NULL AS CompletionDate ,
                subc.SubContractorID ,
                NULL AS RowNum ,
                sc.Completed AS Completed ,
                s.FISaleAmount AS FISaleAmount ,
                NULL AS OfficeStaffName
        FROM    sqlserver.leads.dbo.ServiceCost sc WITH ( NOLOCK )
                INNER JOIN sqlserver.leads.dbo.Job J WITH ( NOLOCK ) ON sc.JobID = J.JobID
                                                              AND sc.ProductID = J.ProductID
                                                              AND sc.ApptDate = J.ApptDate
                LEFT JOIN sqlserver.Leads.dbo.Service s WITH ( NOLOCK ) ON J.JobID = s.JobID
                                                              AND J.ApptDate = s.ApptDate
                                                              AND J.ProductID = s.ProductID
                LEFT JOIN sqlserver.leads.dbo.SubContractor AS subc WITH ( NOLOCK ) ON ISNULL(sc.ServiceTechID,
                                                              25730) = subc.SubContractorID
				LEFT JOIN SQLSERVER.leads.dbo.Office AS o ON o.OfficeID = J.OfficeID
        WHERE   sc.VisitDate BETWEEN @pStartDate AND @pEndDate
                AND subc.SubcontractorID != 25730 -- Office Staff
                AND sc.ServiceTripTypeID IN ( 1, 3 )
                AND subc.Employee != 0


	';
        IF OBJECT_ID('tempdb..#ServicesRun') IS NOT NULL
            DROP TABLE #ServicesRun; 
        CREATE TABLE #ServicesRun
            (
             AppointmentID INT
            ,JobID INT
            ,ApptDate SMALLDATETIME
            ,ProductID INT
            ,OfficeID INT
            ,VisitDate SMALLDATETIME
            ,ServiceTripTypeID INT
            ,CompletionDate SMALLDATETIME
            ,SubContractorID INT
            ,RowNum INT
            ,Completed INT
            ,FISaleAmount SMALLMONEY
            ,OfficeStaffName VARCHAR(60)
            );
        INSERT  INTO #ServicesRun
                (
                 AppointmentID
                ,JobID
                ,ApptDate
                ,ProductID
                ,OfficeID
                ,VisitDate
                ,ServiceTripTypeID
                ,CompletionDate
                ,SubContractorID
                ,RowNum
                ,Completed
                ,FISaleAmount
                ,OfficeStaffName
	            )
                EXEC SQLSERVER.master.dbo.SP_EXECUTESQL
                    @SQLString
                   ,@ParmDefinition
                   ,@pStartDate
                   ,@pEndDate
                   ,@pDimDistrictKey
                   ,@pDimProductKey;
	
		--
		--  Remove records based on filters
		--      This has to be done here rather than the SP_EXECUTESQL because some of the records are listed in 
		--      production (SQLSERVER) are under districts that are not active, therefore, they have to be rolled 
		--      up to the active one using DimOfficeProduct (SHIPREPORTSQL)
		--
        DELETE
            s
        FROM
            #ServicesRun s
            INNER JOIN SHIPBI.dbo.DimOfficeProduct AS dop ON s.OfficeID = dop.DimOfficeKey
                                                             AND COALESCE(s.ProductID, -1) = dop.DimProductKey
        WHERE
            NOT CHARINDEX(',' + CAST(dop.DimDistrictKey AS VARCHAR(10)) + ',', @pDimDistrictKey) > 0
            AND CHARINDEX(',' + CAST(s.ProductID AS VARCHAR(10)) + ',', @pDimProductKey) > 0;

        CREATE INDEX XI_#ServicesRun_AppointmentID ON #ServicesRun(AppointmentID);
	--
	-- Completed Services and SFI Monies.
	--
        SET @SQLString = '
        SELECT  J.AppointmentID ,
                J.JobID ,
                J.ApptDate ,
                J.ProductID ,
                j.OfficeID ,
                NULL AS VisitDate ,
                1 AS ServiceTripTypeID ,
                j.CompletionDate ,
                sc.SubContractorID ,
                NULL AS RowNum ,
                IIF(j.CompletionDate IS NOT NULL, 1, 0) AS Completed ,
                s.FISaleAmount AS FISaleAmount ,
                NULL AS OfficeStaffName
        INTO    #CompletedServices
        FROM    sqlserver.leads.dbo.Job j WITH ( NOLOCK )
                INNER JOIN sqlserver.leads.dbo.Service S WITH ( NOLOCK ) ON j.JobID = S.JobID
                                                              AND j.ApptDate = S.ApptDate
                                                              AND j.ProductID = S.ProductID
                INNER JOIN sqlserver.leads.dbo.JobMisc AS jm WITH ( NOLOCK ) ON j.JobID = jm.JobID
                                                              AND j.ApptDate = jm.ApptDate
                                                              AND j.ProductID = jm.ProductID
                INNER JOIN sqlserver.leads.dbo.SubContractor sc WITH ( NOLOCK ) ON jm.DefaultSubID = sc.SubContractorID
				LEFT JOIN SQLSERVER.leads.dbo.Office AS o ON o.OfficeID = J.OfficeID
        WHERE   j.CompletionDate BETWEEN @pStartDate  AND     @pEndDate
                AND sc.Employee != 0
		';
        IF OBJECT_ID('tempdb..#CompletedServices') IS NOT NULL
            DROP TABLE #CompletedServices; 
        CREATE TABLE #CompletedServices
            (
             AppointmentID INT
            ,JobID INT
            ,ApptDate SMALLDATETIME
            ,ProductID INT
            ,OfficeID INT
            ,VisitDate SMALLDATETIME
            ,ServiceTripTypeID INT
            ,CompletionDate SMALLDATETIME
            ,SubContractorID INT
            ,RowNum INT
            ,Completed INT
            ,FISaleAmount SMALLMONEY
            ,OfficeStaffName VARCHAR(60)
            );
        INSERT  INTO #CompletedServices
                (
                 AppointmentID
                ,JobID
                ,ApptDate
                ,ProductID
                ,OfficeID
                ,VisitDate
                ,ServiceTripTypeID
                ,CompletionDate
                ,SubContractorID
                ,RowNum
                ,Completed
                ,FISaleAmount
                ,OfficeStaffName
		        )
                EXEC SQLSERVER.master.dbo.SP_EXECUTESQL
                    @SQLString
                   ,@ParmDefinition
                   ,@pStartDate
                   ,@pEndDate
                   ,@pDimDistrictKey
                   ,@pDimProductKey;
		
		--
		--  Remove records based on filters
		--      This has to be done here rather than the SP_EXECUTESQL because some of the records are listed in 
		--      production (SQLSERVER) are under districts that are not active, therefore, they have to be rolled 
		--      up to the active one using DimOfficeProduct (SHIPREPORTSQL)
		--
        DELETE
            s
        FROM
            #CompletedServices s
            INNER JOIN SHIPBI.dbo.DimOfficeProduct AS dop ON s.OfficeID = dop.DimOfficeKey
                                                             AND COALESCE(s.ProductID, -1) = dop.DimProductKey
        WHERE
            NOT CHARINDEX(',' + CAST(dop.DimDistrictKey AS VARCHAR(10)) + ',', @pDimDistrictKey) > 0
            AND CHARINDEX(',' + CAST(s.ProductID AS VARCHAR(10)) + ',', @pDimProductKey) > 0;


        CREATE INDEX XI_#CompletedServices_AppointmentID ON #CompletedServices(AppointmentID);
 	
-- Creates the Complete List Table begining with the Services that were run according to the Service Cost Table.	
        IF OBJECT_ID('tempdb..#CompleteList') IS NOT NULL
            DROP TABLE #CompleteList; 
        SELECT
            sr.AppointmentID
           ,sr.JobID
           ,sr.ApptDate
           ,sr.ProductID
           ,sr.OfficeID
           ,sr.VisitDate
           ,sr.ServiceTripTypeID
           ,CONVERT (SMALLDATETIME, sr.CompletionDate) AS CompletionDate
           ,sr.SubContractorID
           ,sr.RowNum
           ,sr.Completed
           ,sr.FISaleAmount
           ,CONVERT(VARCHAR(100), sr.OfficeStaffName) AS OfficeStaffName
        INTO
            #CompleteList
        FROM
            #ServicesRun AS sr;

        CREATE INDEX XI_#CompleteList_AppointmentID_JobID_ApptDate_ProductID_OfficeID_VisitDate_SubContractorID ON #CompletedServices(AppointmentID,JobID,ApptDate,ProductID,OfficeID,VisitDate,SubContractorID);

-- Adds the inspections to the Complete List. Only the First Inspection for a job by Sub is given Credit During the Month.
 
        INSERT  INTO #CompleteList
                (
                 AppointmentID
                ,JobID
                ,ApptDate
                ,ProductID
                ,OfficeID
                ,VisitDate
                ,ServiceTripTypeID
                ,CompletionDate
                ,SubContractorID
                ,RowNum
                ,Completed
                ,FISaleAmount
                ,OfficeStaffName
                )
        SELECT
            i.AppointmentID
           ,i.JobID
           ,i.ApptDate
           ,i.ProductID
           ,i.OfficeID
           ,i.VisitDate
           ,i.ServiceTripTypeID
           ,i.CompletionDate
           ,i.SubContractorID
           ,i.RowNum
           ,i.Completed
           ,i.FISaleAmount
           ,i.OfficeStaffName
        FROM
            #Inspections AS i;
                --WHERE   RowNum = 1   --Removed per SR43776.  Give credit for all inspections

--Adds the Completed Services and the FISaleAmounts to the Complete List of Jobs.

        INSERT  INTO #CompleteList
                (
                 AppointmentID
                ,JobID
                ,ApptDate
                ,ProductID
                ,OfficeID
                ,VisitDate
                ,ServiceTripTypeID
                ,CompletionDate
                ,SubContractorID
                ,RowNum
                ,Completed
                ,FISaleAmount
                ,OfficeStaffName
                )
        SELECT
            cs.AppointmentID
           ,cs.JobID
           ,cs.ApptDate
           ,cs.ProductID
           ,cs.OfficeID
           ,cs.VisitDate
           ,cs.ServiceTripTypeID
           ,cs.CompletionDate
           ,cs.SubContractorID
           ,cs.RowNum
           ,cs.Completed
           ,cs.FISaleAmount
           ,cs.OfficeStaffName
        FROM
            #CompletedServices AS cs;	

-- Tells whether two subs were sent out. If there were two... then they split the FISale Amount.
        IF OBJECT_ID('tempdb..#RepCount') IS NOT NULL
            DROP TABLE #RepCount; 
        SELECT
            cl.AppointmentID
           ,COUNT(DISTINCT ( cl.SubContractorID )) AS RepCount
        INTO
            #RepCount
        FROM
            #CompleteList AS cl
        WHERE
            cl.FISaleAmount >= 0
        GROUP BY
            cl.AppointmentID;
        CREATE INDEX XI_#RepCount_AppointmentID ON #RepCount(AppointmentID);

-- Brings the information together and determines the 1 and 0 and the FI Sales Dollars.
        IF OBJECT_ID('tempdb..#FinalResults') IS NOT NULL
            DROP TABLE #FinalResults; 
        SELECT
            cl.AppointmentID
           ,cl.JobID
           ,cl.ApptDate
           ,cl.ProductID
           ,cl.OfficeID
           ,cl.VisitDate
           ,cl.ServiceTripTypeID
           ,dp.ProductName
           ,cl.CompletionDate
           ,cl.SubContractorID
           ,cl.RowNum
           ,cl.Completed
           ,dd2.DimDistrictKey
           ,dd2.DistrictName
           ,dd2.RegionName
           ,dsc.DimSubContractorKey AS ServiceTechID
           ,CONCAT(dsc.SubLastName, ', ', dsc.SubFirstName) AS SubName
           ,SHIPBI.dbo.FunDivision(cl.FISaleAmount, rc.RepCount) AS FlSalesAmount
           ,CASE WHEN cl.ServiceTripTypeID = 1
                      AND cl.CompletionDate IS NOT NULL THEN 1
                 WHEN cl.ServiceTripTypeID IN ( 1, 3 )
                      AND cl.Completed != 0 THEN 1
                 ELSE 0
            END AS CompletedService
           ,CASE WHEN cl.ServiceTripTypeID IN ( 1, 3 )
                      AND ISNULL(cl.Completed, 0) != 1 THEN 1
                 ELSE 0
            END AS ServiceRun
           ,CASE WHEN cl.ServiceTripTypeID = 2 THEN 1
                 ELSE 0
            END AS Inspection
           ,cl.OfficeStaffName
        INTO
            #FinalResults
        FROM
            #CompleteList AS cl
            INNER JOIN SHIPBI.dbo.DimSubContractor AS dsc WITH ( NOLOCK ) ON cl.SubContractorID = dsc.SubContractorID
            INNER JOIN SHIPBI.dbo.DimOfficeProduct AS dop WITH ( NOLOCK ) ON cl.OfficeID = dop.DimOfficeKey
                                                                             AND cl.ProductID = dop.DimProductKey
            INNER JOIN SHIPBI.dbo.DimProduct AS dp WITH ( NOLOCK ) ON cl.ProductID = dp.DimProductKey
            INNER JOIN SHIPBI.dbo.DimDistrict AS dd WITH ( NOLOCK ) ON dop.DimDistrictKey = dd.DimDistrictKey
            INNER JOIN SHIPBI.dbo.DimDistrict AS dd2 WITH ( NOLOCK ) ON dsc.DimDistrictKey = dd2.DimDistrictKey
            LEFT JOIN #RepCount AS rc ON cl.AppointmentID = rc.AppointmentID
        ORDER BY
            rc.AppointmentID;

-- Spins out the Distinct Days of Work.
        IF OBJECT_ID('tempdb..#DisDays') IS NOT NULL
            DROP TABLE #DisDays; 
        SELECT
            fr.SubContractorID
           ,fr.VisitDate AS DayWorked
        INTO
            #DisDays
        FROM
            #FinalResults AS fr
        GROUP BY
            fr.SubContractorID
           ,fr.VisitDate
        UNION ALL
        SELECT
            fr1.SubContractorID
           ,fr1.CompletionDate
        FROM
            #FinalResults AS fr1
        GROUP BY
            fr1.SubContractorID
           ,fr1.CompletionDate;

        IF OBJECT_ID('tempdb..#FinalDistDay') IS NOT NULL
            DROP TABLE #FinalDistDay; 
        SELECT
            dd.SubContractorID
           ,COUNT(DISTINCT ( dd.DayWorked )) AS DayWorked
        INTO
            #FinalDistDay
        FROM
            #DisDays AS dd
        GROUP BY
            dd.SubContractorID;


-- Final Select Statement For the report!

        SELECT
            fr.AppointmentID
           ,fr.JobID
           ,fr.ApptDate
           ,fr.ProductID
           ,fr.OfficeID
           ,fr.VisitDate
           ,fr.ServiceTripTypeID
           ,fr.CompletionDate
           ,fr.SubContractorID
           ,fr.RowNum
           ,fr.Completed
           ,fr.DimDistrictKey
           ,fr.DistrictName
           ,fr.RegionName
           ,fr.ProductName
           ,CASE WHEN fr.ServiceTripTypeID = 2 THEN 'Inspection'
                 ELSE 'Service'
            END AS ServiceType
           ,fr.ServiceTechID
           ,fr.SubName
           ,ROUND(fr.FlSalesAmount, 0) AS FlSalesAmount
           ,CONVERT(INT, fr.CompletedService) AS CompletedService
           ,fr.ServiceRun
           ,fr.Inspection
           ,fr.Inspection * 5 AS InspectionPoints
           ,fr.CompletedService * 12 AS CompletionPoints
           ,ROUND(( fr.FlSalesAmount * .0300000 ), 2) AS FISalesPoints
           ,ISNULL(fr.OfficeStaffName, 'Not Given') AS OfficeStaffName
           ,IIF(os.TotalServiceCount >= 10, os.AgedService, 0) AS AgedServiceDeduction                
			--,os.AgedService AS AgedServiceDeduction 
           ,CASE WHEN ROW_NUMBER() OVER ( PARTITION BY fr.SubContractorID ORDER BY fr.SubContractorID ) = 1
                 THEN fdd.DayWorked
                 ELSE 0
            END AS DaysWorked
        FROM
            #FinalResults AS fr
            LEFT JOIN #OpenServices os WITH ( NOLOCK ) ON fr.DimDistrictKey = os.DimDistrictKey
            LEFT JOIN #FinalDistDay fdd ON fr.SubContractorID = fdd.SubContractorID;
	 --WHERE fr.SubContractorID!= 25730 -- No Office Staff.
-- Clean Up Temp Tables

        DROP TABLE #FinalResults;
        DROP TABLE #ServicesRun;
        DROP TABLE #Inspections;
        DROP TABLE #CompletedServices;
        DROP TABLE #CompleteList;
        DROP TABLE #RepCount;
        DROP TABLE #OpenServices;
        DROP TABLE #FinalDistDay;
        DROP TABLE #DisDays;	
-- ========================================================================================

    END TRY

-- ========================================================================================

    BEGIN CATCH

-- ========================================================================================

        DECLARE
            @ErrorMessage NVARCHAR(4000)
           ,@ErrorNumber INT
           ,@ErrorSeverity INT
           ,@ErrorState INT
           ,@ErrorLine INT
           ,@ErrorProcedure NVARCHAR(200);

        SET @ErrorNumber = ERROR_NUMBER();
        SET @ErrorSeverity = ERROR_SEVERITY();
        SET @ErrorState = ERROR_STATE();
        SET @ErrorLine = ERROR_LINE();
        SET @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-');
        SET @ErrorMessage = N'Error %d, Level %d, State %d, Procedure %s, Line %d ' + 'Message: ' + ERROR_MESSAGE();

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
	);

-- ========================================================================================

    END CATCH;

-- ========================================================================================





GO


