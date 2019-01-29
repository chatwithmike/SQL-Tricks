/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [AdminStoredProcedureExecutions]
      ,[ProcName]
      ,[DB]
      ,[create_date]
      ,[modify_date]
      ,[last_execution_time]
      ,[execution_count]
  FROM [SHIPBI_ETL].[dbo].[AdminStoredProcedureExecutions]
  WHERE ProcName='RptOnHoldJobs_v2'