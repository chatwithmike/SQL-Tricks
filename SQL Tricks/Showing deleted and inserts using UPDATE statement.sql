CREATE TABLE deleteme
(
	x int
)
INSERT INTO dbo.deleteme
        ( x )
VALUES  (1),(2),(3),(4),(5)

UPDATE dbo.deleteme
SET x = x*2
OUTPUT
	--Inserted.name
	--,
	Deleted.x AS  'old'
	,inserted.x AS  'NEW'
WHERE 1=1

