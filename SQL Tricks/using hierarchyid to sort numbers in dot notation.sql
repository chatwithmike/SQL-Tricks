--dictionary sort...not what we want
;WITH v AS (
SELECT
	'1' AS VersionNumber
UNION ALL
SELECT
	'1.1' AS VersionNumber
UNION ALL
SELECT
	'1.1.2' AS VersionNumber
UNION ALL
SELECT
	'1.1.10' AS VersionNumber
UNION ALL
SELECT
	'1.2' AS VersionNumber
UNION ALL
SELECT
	'1.11' AS VersionNumber
UNION ALL
SELECT
	'2.10' AS VersionNumber
UNION ALL
SELECT
	'11.1' AS VersionNumber
)
SELECT
	*
FROM
	v
ORDER BY
	VersionNumber

--hierarchical sort...correct
;WITH v AS (
SELECT
	'1' AS VersionNumber
UNION ALL
SELECT
	'1.1' AS VersionNumber
UNION ALL
SELECT
	'1.1.2' AS VersionNumber
UNION ALL
SELECT
	'1.1.10' AS VersionNumber
UNION ALL
SELECT
	'1.2' AS VersionNumber
UNION ALL
SELECT
	'1.11' AS VersionNumber
UNION ALL
SELECT
	'2.10' AS VersionNumber
UNION ALL
SELECT
	'11.1' AS VersionNumber
)
SELECT
	CAST('/' + VersionNumber+'/' AS HIERARCHYID) AS NodePath,
	*
FROM
	v
ORDER BY
	CAST('/' + VersionNumber+'/' AS HIERARCHYID)

--CAST('/' + VersionNumber+'/' AS HIERARCHYID) is causing the a node path to be computed and those node path values (binary/hex)
--are computed as we would expect and are suitable for sorting

--The main purpose of hierarchyid is to manage hierarchical data.  This use of the data type is a hack but a darn good one.
