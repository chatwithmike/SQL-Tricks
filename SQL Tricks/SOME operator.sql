DECLARE @OrderID		INT	= 49080
DECLARE @NumberOfDays	INT	= 1
DECLARE @text			NVARCHAR(100)
	
    SELECT DaysToManufacture
	FROM Sales.SalesOrderDetail
		INNER JOIN Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID 
    WHERE SalesOrderID = @OrderID

IF 
@NumberOfDays < SOME -- vs ANY
   (
    SELECT DaysToManufacture
	FROM Sales.SalesOrderDetail
		INNER JOIN Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID 
    WHERE SalesOrderID = @OrderID
   )
SET  @text = 'At least one item for this order cannot be manufactured in specified number of days.'
ELSE 
SET  @text = 'All items for this order can be manufactured in the specified number of days or less.' ;

SELECT @text Result