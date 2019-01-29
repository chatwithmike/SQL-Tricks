
DECLARE @OrderID		INT	= 49080
DECLARE @NumberOfDays	INT	= 1
DECLARE @text			NVARCHAR(100)
	
    SELECT DaysToManufacture
	FROM Sales.SalesOrderDetail
		INNER JOIN Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID 
    WHERE SalesOrderID = @OrderID


IF 
@NumberOfDays >= ALL
   (
    SELECT DaysToManufacture
    FROM Sales.SalesOrderDetail
		INNER JOIN Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID 
    WHERE SalesOrderID = @OrderID
   )
SET  @text = 'All items for this order can be manufactured in specified number of days or less.'
ELSE 
SET  @text = 'Some items for this order cannot be manufactured in specified number of days or less.' ;

SELECT @text Result