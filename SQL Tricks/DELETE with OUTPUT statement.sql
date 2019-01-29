create table #bob (x int primary key)
create table #y (x int)
create table #z (x int)

insert into #bob(x)
select 1 union all 
select 2 union all 
select 3

select * from #bob

delete from #bob
output deleted.x into #y(x)
output deleted.x 
where #bob.x=1; 

select * from #y

insert into #bob(x)
select x from #y

select * from #bob

drop table #bob, #y