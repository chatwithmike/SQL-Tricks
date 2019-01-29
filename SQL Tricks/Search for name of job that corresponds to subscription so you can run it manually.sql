/*
	Search for name of job that corresponds to subscription so you can run it manually
*/

SELECT
     S.ScheduleID AS SQLAgent_Job_Name
     ,SUB.Description AS Sub_Desc
     ,SUB.DeliveryExtension AS Sub_Del_Extension
     ,C.Name AS ReportName
     ,C.Path AS ReportPath
FROM ReportSchedule RS
     INNER JOIN Schedule S ON (RS.ScheduleID = S.ScheduleID)
     INNER JOIN Subscriptions SUB ON (RS.SubscriptionID = SUB.SubscriptionID)
     INNER JOIN [Catalog] C ON (RS.ReportID = C.ItemID AND SUB.Report_OID = C.ItemID)
WHERE
     C.Name LIKE '%GCR%'

5. Connect to MSDB Database on the Report Server.
6. Insert the SQLAgent_Job_Name in the following and execute.

/*Connect to Database MSDB on the Reporting Server*/
/*Enter SQLAgent_Job_Name to execute the subscription based on Job ID*/
USE msdb
EXEC sp_start_job @job_name = '4F634FFC-9709-41F7-B1AC-665AD6197820'