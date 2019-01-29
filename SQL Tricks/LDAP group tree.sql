USE [SHIPBI]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[GetLdapUserGroups]
(
	@LdapUsername NVARCHAR(max)
)
AS
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON

-- ========================================================================================
-- Author:      SPRAYTECH\mmiller , and the interwebs
-- Create date: 1/7/2016 12:01 PM
-- Description:  Recursive retrieval of all AD group memberships of a user for a given sAMAccountName

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
-- Modification: 
-- ========================================================================================

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET NOCOUNT ON

-- ========================================================================================

BEGIN TRY

-- ========================================================================================

-- Run data

	DECLARE @Query NVARCHAR(max), @Path NVARCHAR(max)

	--
	--  Get the distinguishedName for the given sAMAccountName.  
	--		Query using TSQL syntax
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

	--
	-- Recursively loop through the groups until you catch em all! 
	--
	--		Query using LDAP syntax
	--
	  SET @Query = '
		SELECT cn AS [LdapGroup]
		FROM OPENQUERY (ADSI, ''<LDAP://SEARSSIDING.COM>;
		(&(objectClass=group)(member:1.2.840.113556.1.4.1941:= ' + @Path + '));
		cn, adspath;subtree'')
		ORDER BY cn;
	'

	EXEC SP_EXECUTESQL @Query

                
-- ========================================================================================

END TRY

-- ========================================================================================

BEGIN CATCH

-- ========================================================================================

DECLARE
                @ErrorMessage nvarchar(4000),
                @ErrorNumber int,
                @ErrorSeverity int,
                @ErrorState int,
                @ErrorLine int,
                @ErrorProcedure nvarchar(200)

SET @ErrorNumber = Error_Number()
SET @ErrorSeverity = Error_Severity()
SET @ErrorState = Error_State()
SET @ErrorLine = Error_Line()
SET @ErrorProcedure = IsNull(Error_Procedure(), '-')
SET @ErrorMessage = N'Error %d, Level %d, State %d, Procedure %s, Line %d ' + 
                'Message: ' + Error_Message()

-- Raise the Error

RAISERROR
                (
                @ErrorMessage,
                @ErrorSeverity,
                1,
                @ErrorNumber,
                @ErrorSeverity,
                @ErrorState,
                @ErrorProcedure,
                @ErrorLine
                )

-- ========================================================================================

END CATCH

-- ========================================================================================
