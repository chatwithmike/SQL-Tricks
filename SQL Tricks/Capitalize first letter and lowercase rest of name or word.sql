SELECT
    EmpID
   ,EmployeeID
   ,UserName
   ,UPPER(LEFT(EmployeeFirstName,1))+LOWER(SUBSTRING(EmployeeFirstName,2,LEN(EmployeeFirstName))) AS EmployeeFirstName
   ,EmployeeMiddleName
   ,UPPER(LEFT(EmployeeLastName,1))+LOWER(SUBSTRING(EmployeeLastName,2,LEN(EmployeeLastName))) AS EmployeeLastName
FROM dbo.DimEmployee
WHERE Manager LIKE 'tim ha%'
      AND IsCurrentRecord = 1
      AND InActiveDate IS NULL;