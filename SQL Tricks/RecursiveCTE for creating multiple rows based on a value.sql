

/*
	RecursiveCTE for creating multiple rows based on a value
*/

create table #abc
(SeqNo smallint
,Date_Field smalldatetime
,Month_Count tinyint
,Payment decimal(10,2))
--go

--Populate the source table, dbo.abc
insert into #abc (SeqNo, Date_Field, Month_Count, Payment)
values (1, '20090101', 10, 100)
      ,(2, '20100101', 7, 200)
      ,(3, '20110101', 5, 300)

SELECT * FROM #abc AS a
SELECT SeqNo, Date_Field, Month_Count, Payment, Date_Field, dateadd(mm, Month_Count-1, Date_Field), 1 from dbo.abc

;with CTE_Base (SeqNo, Date_Field, Month_Count, Payment, Begin_Date, End_Date, Frequency)
as
(
	SELECT SeqNo, Date_Field, Month_Count, Payment, Date_Field, dateadd(mm, Month_Count-1, Date_Field), 1 from dbo.abc
	union all
	select SeqNo, dateadd(mm, Frequency, Date_Field), Month_Count, Payment, Begin_Date, End_Date, Frequency
	from CTE_Base
	where dateadd(mm, Frequency, Date_Field) between Begin_Date and End_Date
)

--insert into dbo.def (SeqNo, Date_Field, Payment)
select SeqNo, Date_Field, Payment, Begin_Date, End_Date
from CTE_Base
where Date_Field between Begin_Date and End_Date
order by SeqNo, Date_Field

DROP TABLE #abc
