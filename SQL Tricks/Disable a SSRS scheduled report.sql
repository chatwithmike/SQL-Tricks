
--
--  Find the job you want to disable 
--
SELECT  cl.ItemID
       ,cl.Path
       ,cl.Name
       ,rs.ScheduleID
FROM    ReportServerR2.dbo.Catalog cl
        INNER JOIN ReportServerR2.dbo.ReportSchedule rs ON cl.ItemID = rs.ReportID
		AND cl.Name LIKE '%stack%'

--
--  Now disable that job
--     by default, the jobname is equal to the scheduleID.
--
Use msdb
go
--exec sp_update_job @job_name = 'D2C7F3A7-A3E9-44EF-AEDB-E90070275541',@enabled = 0  

