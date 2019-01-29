-- sample table with data
declare @t table(UserID int, StartDate datetime, EndDate datetime)
insert @t select
NULL,  NULL     , '21000101' union all select
NULL, '20010101',  NULL      union all select
NULL, '20120101', '20140101' union all select
NULL, '20110101', '20130101' union all select
NULL, '20090101', '20100101'

-- your query starts below

select UserID, Min(NewStartDate) StartDate, MAX(enddate) EndDate
from
(
    select *,
        NewStartDate = t.startdate+v.number,
        NewStartDateGroup =
            dateadd(d,
                    1- DENSE_RANK() over (partition by UserID order by t.startdate+v.number),
                    t.startdate+v.number)
    from @t t
    inner join master..spt_values v
      on v.type='P' and v.number <= DATEDIFF(d, startdate, EndDate)
) X
group by UserID, NewStartDateGroup
order by UserID, StartDate

select count(*) from  master.dbo.spt_values v where v.type ='p'