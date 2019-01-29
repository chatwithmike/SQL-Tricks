
/*
	Active Directory Service Interfaces, also known as ADSI, is a set of COM interfaces used to access the directory services to retrieve data. 

	In order to query data from Active Directory, you need to know the Organizational Units, containers and domain controllers. All the 
	three are not mandatory to retrieve information. You could query ADSI just by using the domain name and domain container.

	CN is containers that are usually defined as users, contacts, groups
	OU is organizational units that usually contain objects such users, contacts, groups and other OUs
	DC is domain containers that are created by separating the full internal domain name 
*/



SELECT TOP 100 objectGUID, displayName, Mail, Title, physicalDeliveryOfficeName,  telephoneNumber, Manager, name, sAMAccountName

  FROM OPENQUERY(ADSI, 
	'
		SELECT 
			objectGUID, displayName, Mail, Title, physicalDeliveryOfficeName,  telephoneNumber, Manager, name, sAMAccountName
		FROM ''LDAP://searssiding.com''
		WHERE
			objectClass = ''user''	
		order by 	objectGUID
	')
	

--SELECT * FROM OpenQuery(ADSI, 'SELECT EmployeeID, sAMAccountName FROM ''LDAP://searssiding.com''
--where objectCategory = ''Person''
--AND objectClass = ''user''
--and EmployeeID = 62001



/* FROM ''LDAP://srvlwddc05/DC=SEARSSIDING,DC=COM'' */


SELECT  au.SAMAccount
       ,ag.GroupName
       ,au.Path
       ,au.Title
       ,au.Description
       ,srpfaag.ADGroup
		,ag.GroupName
FROM    SQLSERVER.leads.dbo.ADUser AS au WITH ( NOLOCK )
        INNER JOIN SQLSERVER.leads.dbo.ADUserGroupJoin AS augj WITH ( NOLOCK ) ON augj.ADUserID = au.ADUserID
        INNER JOIN SQLSERVER.leads.dbo.ADGroup AS ag WITH ( NOLOCK ) ON ag.ADGroupID = augj.ADGroupID
        LEFT OUTER JOIN SHIPREPORTSsql.SHIPBI_ETL.dbo.SubRptPermissionsFullAccessADGroups AS srpfaag  WITH ( NOLOCK ) ON ag.GroupName = srpfaag.ADGroup
WHERE   au.SAMAccount = 'mmiller'
WHERE ag.ADGroupID = 10997
--WHERE ag.GroupName = 'bi apc'
--ORDER BY ag.groupname
SELECT * FROM SQLSERVER.leads.dbo.ADUser AS au WITH ( NOLOCK )
SELECT * FROM SQLSERVER.leads.dbo.ADUserGroupJoin AS augj WITH ( NOLOCK )
WHERE augj.ADGroupID = 10997
SELECT * FROM SQLSERVER.leads.dbo.ADGroup AS ag WITH ( NOLOCK )
WHERE ag.ADGroupID = 10997


SELECT *
FROM    SQLSERVER.leads.dbo.ADUser AS au WITH ( NOLOCK )
        INNER JOIN SQLSERVER.leads.dbo.ADUserGroupJoin AS augj WITH ( NOLOCK ) ON augj.ADUserID = au.ADUserID
        INNER JOIN SQLSERVER.leads.dbo.ADGroup AS ag WITH ( NOLOCK ) ON ag.ADGroupID = augj.ADGroupID
WHERE 
	--au.SAMAccount = 'mmiller'
	au.ADUserID=37978
	SELECT * FROM SQLSERVER.leads.dbo.ADUser AS au WHERE au.ADUserID IN (SELECT j.ADUserID FROM SQLSERVER.leads.dbo.ADUserGroupJoin j WHERE j.ADGroupID IN (12116))



SELECT * FROM OpenQuery(ADSI, 'SELECT EmployeeID, sAMAccountName FROM ''LDAP://searssiding.com''
where objectCategory = ''Person''
AND objectClass = ''user''
and EmployeeID = 62001
') ad 

--LDAP://shipdc01/DC=SEARSSIDING,DC=COM




--
--  All groups where group like . . . 
--
SELECT sAMAccountName as Login, CN as Name, GivenName as FirstName,SN as LastName, DisplayName as FullName, UserAccountControl 
FROM OPENQUERY( ADSI, 
'SELECT sAMAccountname,givenname,sn,displayname,useraccountcontrol,CN 
FROM ''LDAP://DC=searssiding,DC=COM'' 
WHERE objectCategory=''group'' AND CN=''*BI*'' 
ORDER BY CN')


--
--  ADsPath for all users
/*
	‘Select *’ in a query against AD does not return all fields as you might expect that it would. Instead, it returns the ADsPath of the object. There is no way to return all fields.
*/
SELECT * FROM OpenQuery(ADSI, 'SELECT EmployeeID FROM ''LDAP://searssiding.com''
WHERE objectCategory = ''Person''
AND objectClass = ''user''
AND sAMAccountname=''mmiller''
')



/*
	Active Directory Service Interfaces, also known as ADSI, is a set of COM interfaces used to access the directory services to retrieve data. 

	In order to query data from Active Directory, you need to know the Organizational Units, containers and domain controllers. All the 
	three are not mandatory to retrieve information. You could query ADSI just by using the domain name and domain container.

	CN is containers that are usually defined as users, contacts, groups
	OU is organizational units that usually contain objects such users, contacts, groups and other OUs
	DC is domain containers that are created by separating the full internal domain name 

*************
LDAP Dialect
**************
	Syntax:
		This "]--" is part of comments.
		
		SELECT 
			--
			--  Order and alias the fileds here.  The query against Active Directory won't return fields in the order specified
			--
		FROM OPENQUERY(LINKED_SERVER_NAME,  ]-- Name of the linked server setup to access Active Directory
		'<LDAP://Domainname.company.com/DC=DomainName,DC=Company,DC=Com>; ]-- Domain to query, can start at the root of the domain or at an ou
		(&(xxxxxxxxxxxxxx=xxxxxxxxxxxxxxx); ]-- Search conditions, case and white space sensitive
		xxxxxxx, xxxxx, xxxx,xxxxxx;        ]-- Active Directory fields to select 
		xxxxx')								]-- Scope of search
*/
SELECT 
	name
	,displayName
	,givenname
	,distinguishedName
	,sAMAccountName
FROM OpenQuery(ADSI,
'<LDAP://searssiding.com>;
(&(sAMAccountName=mmiller));
sAMAccountName,name, displayName,givenname,distinguishedName,;
subtree')




SELECT 
	name
	,displayName
	,givenname
	,distinguishedName
	,sAMAccountName
FROM OpenQuery(ADSI,
'<LDAP://searssiding.com>;
(member:1.2.840.113556.1.4.1941:=cn=Michael Miller,dc=searssiding,dc=com);
*;
')



    


member:1.2.840.113556.1.4.1941: "<ldap://"

SELECT samAccountName,distinguishedName
    FROM OPENQUERY (ADSI, '<LDAP://domain/DC=...,DC=....,DC=....>;
    (&(objectCategory=user)(member:1.2.840.113556.1.4.1941:=CN=..,OU=..,DC=...,DC=....,DC=....));samAccountName, distinguishedName;subtree');

SELECT samAccountName,distinguishedName
    FROM OPENQUERY (ADSI, '<LDAP://searssiding.com>;
    (&(objectCategory=user)(member:1.2.840.113556.1.4.1941:=CN=searssiding.com));
	samAccountName, distinguishedName;
	subtree');




















SELECT 	name
	,displayName
	,givenname
	,distinguishedName
	,sAMAccountName
	 FROM OpenQuery(ADSI, 'SELECT sAMAccountName,name, displayName,givenname,distinguishedName FROM ''LDAP://searssiding.com''
WHERE sAMAccountName=''mmiller''
')


SELECT 	*
	 FROM OpenQuery(ADSI, 'SELECT msRADIUSServiceType
 FROM ''LDAP://searssiding.com''
WHERE sAMAccountName=''mmiller''
')

--
--  Users with accounts that do expire
--
SELECT * FROM OpenQuery(ADSI, 'SELECT * FROM ''LDAP://searssiding.com''
WHERE objectCategory=''person''
and objectClass=''user'' 
and accountExpires>=''1''
')




	--cn 
	--,department
	--,displayName
	--,givenName [first name]
	--,l AS [city ("locality")]
	--,mail
	--,manager
	--,postalCode
	--,sAMAccountName
	--,sn [last name ("surname")]
	--,st
	--,streetAddress
	--,telephoneNumber
	--,title
	--,accountExpires
DECLARE @sql AS VARCHAR(500) = 'SELECT * FROM OpenQuery(ADSI, ''SELECT company FROM ''''LDAP://searssiding.com'''' WHERE sAMAccountName=''''mmiller'''''')'
EXEC (@sql)

DROP TABLE #AttrLDAP
CREATE TABLE #AttrLDAP(id INT PRIMARY KEY IDENTITY, Name VARCHAR(200))
INSERT INTO #AttrLDAP(Name)
VALUES 
 ('accountExpires')

DECLARE @counter INT=99
DECLARE @loopexit INT = (SELECT COUNT(*) FROM #AttrLDAP AS al)
DECLARE @sql AS VARCHAR(500) 
DECLARE @tbl TABLE(name VARCHAR(200), val VARCHAR(2000))
WHILE (@counter <= @loopexit)
BEGIN
    BEGIN TRY    
		--DECLARE @sql AS VARCHAR(500) = 'SELECT * FROM OpenQuery(ADSI, ''SELECT ' + (SELECT name FROM #AttrLDAP AS al WHERE id = @counter) + 'FROM ''''LDAP://searssiding.com'''' WHERE sAMAccountName=''''mmiller'''''')'
		SET @sql = 'SELECT (SELECT name FROM #AttrLDAP AS al WHERE id = ' + CAST(@counter AS VARCHAR(3)) + ') as Name, * FROM OpenQuery(ADSI, ''SELECT ' + (SELECT name FROM #AttrLDAP AS al WHERE id = @counter) + ' FROM ''''LDAP://searssiding.com'''' WHERE sAMAccountName=''''mmiller'''''')'		
		INSERT INTO @tbl(name,val) 
		EXEC (@sql)		
		set @counter += 1		
    END TRY
    BEGIN CATCH 
		set @counter += 1
    END CATCH;
END; 
SELECT * FROM @tbl

msRADIUSServiceType






and sAMAccountName=''czebut''
and member:1.2.840.113556.1.4.1941:=''*''


and member:1.2.840.113556.1.4.1941:=CN=User1,OU=X,DC=searssiding,DC=com)

xp_cmdshell 'PowerShell.exe -noprofile Get-Service'

/*
--GET ALL MEMBERS OF A GROUP
select cn,AdsPath
from openquery (ADSI, '<LDAP: dc="corp,dc=mycorp,dc=com">;
(&(objectCategory=person)
(memberOf:1.2.840.113556.1.4.1941:=CN=Administrators,CN=Builtin,DC=corp,DC=mycorp,DC=com));
cn, adspath;subtree')
order BY cn;
 
--GET ALL GROUPS A USER IS A MEMBER OF
select cn,AdsPath
from openquery (ADSI, '<LDAP: dc="corp,dc=mycorp,dc=com">;
(&(objectClass=group)(member:1.2.840.113556.1.4.1941:=CN=John Doe,OU=Developers,OU=Staff,DC=corp,DC=mycorp,DC=com));
cn, adspath;subtree')
order BY cn;
*/

"(&(objectCategory=person)(objectClass=user)(!(cn=andy)))"




--REATE PROCEDURE dbo.GetLdapUserGroups
--(
--    @LdapUsername NVARCHAR(256)
--)
--AS
--BEGIN
SELECT * FROM SQLSERVER.leads.dbo.SHPSolarInfo AS ssi WHERE ssi.LName = 'czebuth'

	DECLARE @LdapUsername NVARCHAR(256)='czebut'
    DECLARE @Query2 NVARCHAR(1024), @Path NVARCHAR(1024)

    SET @Query2 = '
        SELECT @Path = distinguishedName
        FROM OPENQUERY(ADSI, ''
            SELECT distinguishedName 
            FROM ''''LDAP://DC=searssiding,DC=com''''
            WHERE 
                objectClass = ''''user'''' AND
                sAMAccountName = ''''' + @LdapUsername + '''''
        '')
    '
    EXEC SP_EXECUTESQL @Query2, N'@Path NVARCHAR(1024) OUTPUT', @Path = @Path OUTPUT 
	
    SET @Query2 = '
        SELECT name AS LdapGroup 
        FROM OPENQUERY(ADSI,''
            SELECT name 
            FROM ''''LDAP://DC=searssiding,DC=com''''
            WHERE 
                objectClass=''''group'''' AND
                member=''''' + @Path + '''''
        '')
        ORDER BY name
    '
	SELECT @Query2
    EXEC SP_EXECUTESQL @Query2

	
	DECLARE @LdapUsername NVARCHAR(max), @Query NVARCHAR(max), @Path NVARCHAR(max)

SET @LdapUsername = 'czebut'
SET @Query = '
    SELECT @Path = distinguishedName
    FROM OPENQUERY(ADSI, ''
        SELECT distinguishedName 
        FROM ''''LDAP://DC=DOMAIN,DC=COM''''
        WHERE 
            objectClass = ''''user'''' AND
            sAMAccountName = ''''' + @LdapUsername + '''''
    '')
'

EXEC SP_EXECUTESQL @Query, N'@Path NVARCHAR(max) OUTPUT', @Path = @Path OUTPUT 

  SET @Query = '
    SELECT cn AS [LdapGroup]
    FROM OPENQUERY (ADSI, ''<LDAP://DOMAIN.COM>;
    (&(objectClass=group)(member:1.2.840.113556.1.4.1941:= ' + @Path + '));
    cn, adspath;subtree'')
    ORDER BY cn;
'

EXEC SP_EXECUTESQL @Query
    
	Ron Stricklin
	SELECT * FROM SQLSERVER.LEADS.dbo.SHPSolarInfo AS ssi WHERE ssi.UserName='mmiller'
	SELECT * FROM SQLSERVER.LEADS.dbo.SHPSolarInfo AS ssi WHERE ssi.UserName='rstric'
	SELECT * FROM SQLSERVER.LEADS.dbo.SHPSolarInfo AS ssi WHERE ssi.LName='Stricklin Jr.'
	rstric

EXEC dbo.[GetLdapUserGroups] 'rstric'

--
--
--
CREATE PROCEDURE [dbo].[GetLdapUserGroups]
    (
    @LdapUsername NVARCHAR(max)
    )
AS
BEGIN
DECLARE @Query NVARCHAR(max), @Path NVARCHAR(max)

SET @Query = '
    SELECT @Path = distinguishedName
    FROM OPENQUERY(ADSI, ''
        SELECT distinguishedName 
        FROM ''''LDAP://DC=SEARSSIDING,DC=COM''''
        WHERE 
            objectClass = ''''user'''' AND
            sAMAccountName = ''''' + @LdapUsername + '''''
    '')
'

EXEC SP_EXECUTESQL @Query, N'@Path NVARCHAR(max) OUTPUT', @Path = @Path OUTPUT 

  SET @Query = '
    SELECT cn AS [LdapGroup]
    FROM OPENQUERY (ADSI, ''<LDAP://SEARSSIDING.COM>;
    (&(objectClass=group)(member:1.2.840.113556.1.4.1941:= ' + @Path + '));
    cn, adspath;subtree'')
    ORDER BY cn;
'

EXEC SP_EXECUTESQL @Query
END




DECLARE @UserGroup table (LdapGroup nvarchar(max))
INSERT INTO @UserGroup exec dbo.GetLdapUserGroups 'ssarel'

exec SHIPBI.dbo.GetLdapUserGroups 'czebut'



SELECT * FROM sqlserver.leads.dbo.shpsolarinfo WHERE FName ='scott' AND LName LIKE'sa%'

