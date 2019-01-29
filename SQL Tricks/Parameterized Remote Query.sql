	
--Qfiniti Data	
		DECLARE @SQLString NVARCHAR(MAX); 
		DECLARE @ParmDefinition NVARCHAR(500) = 
		'
			@pStartDate SMALLDATETIME
			,@pEndDate SMALLDATETIME
		'

		
        SET @SQLString = 
		'
			SELECT  
				blah
			FROM    
				remotedatabase.dbo.remotetable r
			WHERE   
				r.SomeColumnDate BETWEEN @pStartDate AND @pEndDate
		'

        CREATE TABLE #BlahData
		(
			blah INT
		)
        INSERT  INTO #BlahData
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

