--create an populate a sample employee table
--with salary values

DECLARE
       @Employee TABLE
(
                       Salary INT NOT NULL
);

INSERT INTO @Employee
VALUES
(1),
(1),
(
       2
),
(
       3
),
(
       3
),
(
       4
),
(
       5
),
(
       5
),
(
       6
),
(
       7
),
(
       8
),
(
       9
),
(
       9
),
(
       10
),
(
       11
),
(
       12
);

--set the value of n

DECLARE
       @N INT;

SET @N = 10;

/*
Approach:
1.  Identify all Salary values that are the Nth highest by comparing the dense_rank() of the Salary
to variable @N.  Basically, if a Salary is the Nth highest then return its value; return null otherwise.
2.  Now that we have identified all salaries that are the Nth highest we return the first non-null value
using top with order by.
*/

SELECT TOP 1
       CASE
           WHEN DENSE_RANK() OVER(ORDER BY Salary) = @N
           THEN Salary
           ELSE NULL
       END AS NthHighestSalary
FROM
     @Employee
ORDER BY
         NthHighestSalary DESC;