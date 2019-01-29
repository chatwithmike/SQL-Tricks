SELECT  ThisTable.ID
       ,[A].query('/Somefield').value('/', 'varchar(max)') AS [SomeField_Combined]
       ,[A].query('/Somefield2').value('/', 'varchar(max)') AS [SomeField2_Combined]
       ,[A].query('/Somefield3').value('/', 'varchar(max)') AS [SomeField3_Combined]
FROM    ThisTable
        OUTER APPLY (
                     SELECT (
                             SELECT SomeField + ' ' AS [SomeField]
                                   ,SomeField2 + ' ' AS [SomeField2]
                                   ,SomeField3 + ' ' AS [SomeField3]
                             FROM   SomeTable
                             WHERE  SomeTable.ID = ThisTable.ID
                            FOR
                             XML PATH('')
                                ,TYPE
                            ) AS [A]
                    ) [A]