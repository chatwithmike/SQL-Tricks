SELECT * FROM SQLSERVER.leads.dbo.SHPSolarInfo AS ssi WHERE ssi.LName = 'thendr1'

	DECLARE @LdapUsername NVARCHAR(256)='thendr1'
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
	--SELECT @Query2
    EXEC SP_EXECUTESQL @Query2


	SELECT * FROM SQLSERVER.leads.dbo.SHPSolarInfo AS ssi WHERE ssi.FName = 'tracey' AND ssi.LName like 'Hend%'