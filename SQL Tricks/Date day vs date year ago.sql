
declare @Dater datetime = '6/27/2013'
declare @Date datetime = '6/27/2013'

 
select 
	@Date
  ,CASE (DATEPART(dw, @Date) + @@DATEFIRST) % 7
     WHEN 1 THEN 'Sunday'
     WHEN 2 THEN 'Monday'
     WHEN 3 THEN 'Tuesday'
     WHEN 4 THEN 'Wednesday'
     WHEN 5 THEN 'Thursday'
     WHEN 6 THEN 'Friday'
     WHEN 0 THEN 'Saturday'
   END


set @date=dateadd(week,-52,@Date)
select 
	@Date
  ,CASE (DATEPART(dw, @Date) + @@DATEFIRST) % 7
     WHEN 1 THEN 'Sunday'
     WHEN 2 THEN 'Monday'
     WHEN 3 THEN 'Tuesday'
     WHEN 4 THEN 'Wednesday'
     WHEN 5 THEN 'Thursday'
     WHEN 6 THEN 'Friday'
     WHEN 0 THEN 'Saturday'
   END


set @date=dateadd(year,-1,@Dater)
select 
	@Date
  ,CASE (DATEPART(dw, @Date) + @@DATEFIRST) % 7
     WHEN 1 THEN 'Sunday'
     WHEN 2 THEN 'Monday'
     WHEN 3 THEN 'Tuesday'
     WHEN 4 THEN 'Wednesday'
     WHEN 5 THEN 'Thursday'
     WHEN 6 THEN 'Friday'
     WHEN 0 THEN 'Saturday'
   END
