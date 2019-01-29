
SELECT  js.database_name as DatabaseName,
                 jobs.Name as JobName,
                 js.step_id as StepID,
                 js.step_name as StepName, 
                 js.command as StepCommand				 
FROM     msdb.dbo.sysjobs as jobs
                INNER JOIN msdb.dbo.sysjobsteps as js ON jobs.job_id = js.job_id
WHERE  jobs.[enabled] = 1 
AND js.command LIKE  '%tracker_%'
ORDER BY jobs.Name,js.step_id
