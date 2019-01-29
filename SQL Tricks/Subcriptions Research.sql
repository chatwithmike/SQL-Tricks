USE ReportServerR2

SELECT 
	s.[SubscriptionID] -- Subscription ID
	,s.[OwnerID] -- Report Owner
	,u.username AS SubscriptionOwner
	,s.[Report_OID] -- Report ID
	,c.Path AS ReportPath-- Report Path
	,c.name AS ReportName
	,jobs.name AS JobName
	,s.[Description] -- Description of the report subscription
	,s.[LastStatus] -- Status of last subscription execution.
	,s.[EventType] -- Subsc
	,s.[LastRunTime] -- Last time subscription executed
	,s.[Parameters] -- Parameters used for subscription
	,s.[DeliveryExtension] -- How to deliver the subscription	
FROM dbo.ReportSchedule RS
    JOIN msdb.dbo.sysjobs jobs
        ON CONVERT(VARCHAR(36), RS.ScheduleID) = jobs.name
    INNER JOIN dbo.Subscriptions S
        ON RS.SubscriptionID = S.SubscriptionID
    INNER JOIN dbo.Catalog C
        ON S.report_oid = C.itemid
    INNER JOIN dbo.users u
        ON S.ownerid = u.userid
WHERE
	C.Name LIKE '%mac%'
	--C.Name = 'Non Funded( Non- Billed) Jobs.rdl'

SELECT TOP 10 * FROM  dbo.ExecutionLog el 
INNER JOIN dbo.Catalog c ON c.ItemID = el.ReportID
WHERE 
	c.Name LIKE 'MAC Universal Bonus Lead Details.rdl'
	AND TimeStart >= '07/06/2018' 
	AND UserName = 'SPRAYTECH\mmiller'
pReportName=mac%20universal%20bonus%20lead%20details&pPassThruEmpID=-1&pUserName=SPRAYTECH%5Ccbyrd2&pAssociateBonus=41024530854&pBonusType=1&pBatchKey=1133
 
DECLARE @count INT
 
SELECT
   	Cat.[Name],
   	Rep.[ScheduleId],
   	Own.UserName,
   	ISNULL(REPLACE(Sub.[Description],'send e-mail to ',''),' ') AS Recipients,
   	Sub.[LastStatus],
   	Cat.[Path],
   	Sub.[LastRunTime]
INTO
   	#tFailedSubs
FROM
   	dbo.[Subscriptions] Sub with (NOLOCK)
INNER JOIN
   	dbo.[Catalog] Cat with (NOLOCK) on Sub.[Report_OID] = Cat.[ItemID]
INNER JOIN
   	dbo.[ReportSchedule] Rep with (NOLOCK) ON (cat.[ItemID] = Rep.[ReportID] and Sub.[SubscriptionID] =Rep.[SubscriptionID])
INNER JOIN
   	dbo.[Users] Own with (NOLOCK) on Sub.[OwnerID] = Own.[UserID]
WHERE
Sub.[LastStatus] NOT LIKE '%was written%' --File Share subscription
AND Sub.[LastStatus] NOT LIKE '%pending%' --Subscription in progress. No result yet
AND Sub.[LastStatus] NOT LIKE '%mail sent%' --Mail sent successfully.
AND Sub.[LastStatus] NOT LIKE '%New Subscription%' --New Sub. Not been executed yet
AND Sub.[LastStatus] NOT LIKE '%been saved%' --File Share subscription
AND Sub.[LastStatus] NOT LIKE '% 0 errors.' --Data Driven subscription
AND Sub.[LastStatus] NOT LIKE '%succeeded%' --Success! Used in cache refreshes
AND Sub.[LastStatus] NOT LIKE '%successfully saved%' --File Share subscription
AND Sub.[LastStatus] NOT LIKE '%New Cache%' --New cache refresh plan
-- AND Sub.[LastRunTime] > GETDATE()-1
 SELECT * FROM #tFailedSubs
-- If any failed subscriptions found, proceed to build HTML & send mail.
SELECT @count = COUNT(*) FROM #tFailedSubs