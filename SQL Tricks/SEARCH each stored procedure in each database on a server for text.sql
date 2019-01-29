
--
--  Search each stored procedure in each database on a server for text
--
 exec sp_msforeachdb 'use [?]; SELECT TheDB=''?'',  Name FROM sys.procedures WHERE OBJECT_DEFINITION(OBJECT_ID) LIKE ''%StageSPCAppointmentTarget%'''