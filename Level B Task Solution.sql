-- Stored Procedures

Use AdventureWorks2019
/*
Create a procedure InsertOrderDetails that takes OrderID, ProductID, UnitPrice, Quantiy, Discount as input parameters and inserts that order information in the Order Details table. 
After each order inserted, check the @@rowcount value to make sure that order was inserted properly. If for any reason the order was not inserted, print the message: Failed to place the order. 
Please try again. Also your procedure should have these functionalities.
Make the UnitPrice and Discount parameters optional
If no UnitPrice is given, then use the UnitPrice value from the product table.
If no Discount is given, then use a discount of (0).
Adjust the quantity in stock (UnitsInStock) for the product by subtracting the quantity sold from inventory.
However, if there is not enough of a product in stock, then abort the stored procedure.
without making any changes to the database. Print a message if the quantity in stock of a product drops below its Reorder Level as a result of the update.

*/


CREATE PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT,
    @Discount DECIMAL(5, 2) = 0.0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ActualUnitPrice MONEY;
    DECLARE @CurrentStock INT;
    DECLARE @ReorderLevel INT;

    -- Get the UnitPrice from the Product table if not provided
    IF @UnitPrice IS NULL
    BEGIN
        SELECT @ActualUnitPrice = ListPrice
        FROM Production.Product
        WHERE ProductID = @ProductID;
    END
    ELSE
    BEGIN
        SET @ActualUnitPrice = @UnitPrice;
    END

    -- Check the current stock level for the product
    SELECT @CurrentStock = Quantity
    FROM Production.ProductInventory
    WHERE ProductID = @ProductID;

    -- Set reorder level if not defined in the ProductInventory
    SELECT @ReorderLevel = 50 -- Example fixed value, adapt based on your business rules
    WHERE @ReorderLevel IS NULL;

    -- Check if there is enough stock
    IF @CurrentStock < @Quantity
    BEGIN
        PRINT 'Failed to place the order. Not enough stock available.';
        RETURN;
    END

    -- Insert the order details
    INSERT INTO Sales.SalesOrderDetail (SalesOrderID, ProductID, UnitPrice, OrderQty, UnitPriceDiscount)
    VALUES (@OrderID, @ProductID, @ActualUnitPrice, @Quantity, @Discount);

    -- Check if the insert was successful
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to place the order. Please try again.';
        RETURN;
    END

    -- Update the stock level for the product
    UPDATE Production.ProductInventory
    SET Quantity = Quantity - @Quantity
    WHERE ProductID = @ProductID;

    -- Check the new stock level
    SELECT @CurrentStock = Quantity
    FROM Production.ProductInventory
    WHERE ProductID = @ProductID;

    -- Print a message if the stock level drops below the reorder level
    IF @CurrentStock < @ReorderLevel
    BEGIN
        PRINT 'Warning: The quantity in stock of the product has dropped below the reorder level.';
    END
END;
GO


--For Drop the Existing Procedure
IF OBJECT_ID('dbo.InsertOrderDetails', 'P') IS NOT NULL
DROP PROCEDURE dbo.InsertOrderDetails;
GO



/*
Create a procedure UpdateOrderDetails that takes OrderID, ProductID, UnitPrice, Quantity, and discount, and updates these values for that ProductID in that Order. 
All the parameters except the OrderID and ProductID should be optional so that if the user wants to only update Quantity s/he should be able to do so without providing the rest of the values. 
You need to also make sure that if any of the values are being passed in as NULL, then you want to retain the original value instead of overwriting it with NULL. 
To accomplish this, look for the ISNULL() function in google or sql server books online. Adjust the UnitsInStock value in products table accordingly.

*/

CREATE PROCEDURE UpdateOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT = NULL,
    @Discount DECIMAL(5, 2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentUnitPrice MONEY;
    DECLARE @CurrentQuantity INT;
    DECLARE @CurrentDiscount DECIMAL(5, 2);
    DECLARE @NewUnitPrice MONEY;
    DECLARE @NewQuantity INT;
    DECLARE @NewDiscount DECIMAL(5, 2);
    DECLARE @OriginalQuantity INT;
    DECLARE @QuantityDifference INT;

    -- Retrieve current values
    SELECT @CurrentUnitPrice = UnitPrice,
           @CurrentQuantity = OrderQty,
           @CurrentDiscount = UnitPriceDiscount
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    -- Use the ISNULL function to retain original values if parameters are NULL
    SET @NewUnitPrice = ISNULL(@UnitPrice, @CurrentUnitPrice);
    SET @NewQuantity = ISNULL(@Quantity, @CurrentQuantity);
    SET @NewDiscount = ISNULL(@Discount, @CurrentDiscount);

    -- Calculate the difference in quantity
    SET @QuantityDifference = @NewQuantity - @CurrentQuantity;

    -- Update the SalesOrderDetail table
    UPDATE Sales.SalesOrderDetail
    SET UnitPrice = @NewUnitPrice,
        OrderQty = @NewQuantity,
        UnitPriceDiscount = @NewDiscount
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    -- Update the UnitsInStock in ProductInventory
    UPDATE Production.ProductInventory
    SET Quantity = Quantity - @QuantityDifference
    WHERE ProductID = @ProductID;

    -- Check the new stock level
    DECLARE @CurrentStock INT;
    DECLARE @ReorderLevel INT;
    
    SELECT @CurrentStock = Quantity
    FROM Production.ProductInventory
    WHERE ProductID = @ProductID;
    
    -- Assuming a fixed reorder level for simplicity; adjust as needed
    SET @ReorderLevel = 50;

    -- Print a message if the stock level drops below the reorder level
    IF @CurrentStock < @ReorderLevel
    BEGIN
        PRINT 'Warning: The quantity in stock of the product has dropped below the reorder level.';
    END
END;
GO



--To drop the existing procedure named UpdateOrderDetails, you can use the DROP PROCEDURE statement.
DROP PROCEDURE IF EXISTS UpdateOrderDetails;



/*
Create a procedure GetOrderDetails that takes OrderID as input parameter and returns all the records for that OrderID. 
If no records are found in Order Details table, then it should print the line: "The OrderID XXXX does not exits", 
where XXX should be the OrderID entered by user and the procedure should RETURN the value 1

*/

CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if any records exist for the given OrderID
    IF NOT EXISTS (SELECT 1 FROM Sales.SalesOrderDetail WHERE SalesOrderID = @OrderID)
    BEGIN
        -- Print message and return value 1 if no records are found
        PRINT 'The OrderID ' + CAST(@OrderID AS VARCHAR(10)) + ' does not exist.';
        RETURN 1;
    END

    -- Retrieve all records for the given OrderID
    SELECT *
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID;
END;


--You can execute this procedure by providing the OrderID parameter value
EXEC GetOrderDetails @OrderID = 123; -- Replace 123 with the actual OrderID you want to retrieve


--To drop the existing GetOrderDetails procedure, you can use the DROP PROCEDURE statement. 
DROP PROCEDURE IF EXISTS GetOrderDetails;



/*
Create a procedure DeleteOrderDetails that takes OrderID and ProductID and deletes that from Order Details table. 
Your procedure should validate parameters. It should return an error code (-1) and print a message if the parameters are invalid. 
Parameters are valid if the given order ID appears in the table and if the given product ID appears in that order

*/

CREATE PROCEDURE DeleteOrderDetails @OrderID INT, @ProductID INT
AS
BEGIN
    DECLARE @ErrorCode INT

    -- Check if OrderID exists in the OrderDetails table
    IF NOT EXISTS (SELECT 1 FROM OrderDetails WHERE OrderID = @OrderID)
    BEGIN
        SET @ErrorCode = -1
        PRINT 'Error: Invalid OrderID. OrderID does not exist in the OrderDetails table.'
        RETURN @ErrorCode
    END

    -- Check if ProductID exists in the given OrderID
    IF NOT EXISTS (SELECT 1 FROM OrderDetails WHERE OrderID = @OrderID AND ProductID = @ProductID)
    BEGIN
        SET @ErrorCode = -1
        PRINT 'Error: Invalid ProductID. ProductID does not exist for the given OrderID.'
        RETURN @ErrorCode
    END

    -- If both parameters are valid, delete the order details
    DELETE FROM OrderDetails WHERE OrderID = @OrderID AND ProductID = @ProductID

    -- Return success code
    SET @ErrorCode = 0
    RETURN @ErrorCode
END


DROP PROCEDURE IF EXISTS DeleteOrderDetails;


-- Functions

/*
Create a function that takes an input parameter type datetime and returns the date in the format MM/DD/YYYY. 
For example if I pass in '2006-11-21 23:34:05.920', the output of the functions should be 11/21/2006
*/

CREATE FUNCTION FormatDate (@InputDate DATETIME)
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @FormattedDate VARCHAR(10)
    SET @FormattedDate = CONVERT(VARCHAR(10), @InputDate, 101)
    RETURN @FormattedDate
END

-- You can use this function by passing a datetime value as an argument, and it will return the date in the MM/DD/YYYY format.
SELECT dbo.FormatDate('2006-11-21 23:34:05.920') AS FormattedDate


/*
Create a function that takes an input parameter type datetime and returns the date in the format YYYYMMDD
*/

CREATE FUNCTION FormatDateYYYYMMDD (@InputDate DATETIME)
RETURNS VARCHAR(8)
AS
BEGIN
    DECLARE @FormattedDate VARCHAR(8)
    SET @FormattedDate = CONVERT(VARCHAR(8), @InputDate, 112)
    RETURN @FormattedDate
END

-- You can use this function by passing a datetime value as an argument, and it will return the date in the YYYYMMDD format.
SELECT dbo.FormatDateYYYYMMDD('2006-11-21 23:34:05.920') AS FormattedDate


-- Views

/*
Create a view vwCustomerOrders which returns Company Name, OrderID, OrderDate, ProductID,Product Name, 
Quantity, UnitPrice, Quantity od. UnitPrice
*/

CREATE VIEW vwCustomerOrders AS
SELECT 
    C.CompanyName,
    O.SalesOrderID AS OrderID,
    O.OrderDate,
    OD.ProductID,
    P.Name AS ProductName,
    OD.OrderQty AS Quantity,
    OD.UnitPrice,
    OD.OrderQty * OD.UnitPrice AS TotalPrice
FROM 
    Sales.Customer AS C
INNER JOIN 
    Sales.SalesOrderHeader AS O ON C.CustomerID = O.CustomerID
INNER JOIN 
    Sales.SalesOrderDetail AS OD ON O.SalesOrderID = OD.SalesOrderID
INNER JOIN 
    Production.Product AS P ON OD.ProductID = P.ProductID;



/*
Create a copy of the above view and modify it so that it only returns the above 
information for orders that were placed yesterday
*/

CREATE VIEW vwCustomerOrdersYesterday AS
SELECT 
    C.CompanyName,
    O.SalesOrderID AS OrderID,
    O.OrderDate,
    OD.ProductID,
    P.Name AS ProductName,
    OD.OrderQty AS Quantity,
    OD.UnitPrice,
    OD.OrderQty * OD.UnitPrice AS TotalPrice
FROM 
    Sales.Customer AS C
INNER JOIN 
    Sales.SalesOrderHeader AS O ON C.CustomerID = O.CustomerID
INNER JOIN 
    Sales.SalesOrderDetail AS OD ON O.SalesOrderID = OD.SalesOrderID
INNER JOIN 
    Production.Product AS P ON OD.ProductID = P.ProductID
WHERE
    O.OrderDate >= DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) - 1, 0) -- Start of yesterday
    AND O.OrderDate < DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0); -- Start of today



/*
Use a CREATE VIEW statement to create a view called MyProducts. Your view should contain the ProductID, ProductName, QuantityPerUnit 
and Unit Price columns from the Products table. It should also contain the Company Name column from the Suppliers table and 
the CategoryName column from the Categories table. Your view should only contain products that are not discontinued.
*/
	CREATE VIEW MyProducts AS
SELECT 
    P.ProductID,
    P.ProductName,
    P.QuantityPerUnit,
    P.UnitPrice,
    S.CompanyName AS SupplierCompanyName,
    C.CategoryName
FROM 
    Products AS P
INNER JOIN 
    Suppliers AS S ON P.SupplierID = S.SupplierID
INNER JOIN 
    Categories AS C ON P.CategoryID = C.CategoryID
WHERE 
    P.Discontinued = 0;




-- Triggers

/*
If someone cancels an order in northwind database, then you want to delete that order from the Orders table. 
But you will not be able to delete that Order before deleting the records from Order Details table for that particular order duc to 
referential integrity constraints. Create an Instead of Delete trigger on Orders table so that if some one tries to delete an Order that 
trigger gets fired and that trigger should first delete everything in order details table and then delete that order from the Orders table
*/

CREATE TRIGGER tr_InsteadOfDeleteOrder
ON [Orders]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Delete records from Order Details table first
    DELETE FROM [Order Details] 
    WHERE OrderID IN (SELECT deleted.OrderID FROM deleted);

    -- Now delete the order from the Orders table
    DELETE FROM [Orders] 
    WHERE OrderID IN (SELECT deleted.OrderID FROM deleted);
END;




/*
When an order is placed for X units of product Y, we must first check the Products table to ensure that there is sufficient stock to fill the order. 
This trigger will operate on the Order Details table. If sufficient stock exists, then fill the order and decrement X units from the UnitsInStock 
column in Products. If insufficient stock exists, then refuse the order (ie. do not insert it) and notify the user that the order could not be filled 
because of insufficient stock.
*/

CREATE TRIGGER tr_CheckStockOnOrder
ON [Order Details]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if there is sufficient stock for each product in the inserted orders
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Products p ON i.ProductID = p.ProductID
        WHERE p.UnitsInStock < i.Quantity
    )
    BEGIN
        -- Notify the user that the order could not be filled due to insufficient stock
        RAISERROR('The order could not be filled due to insufficient stock.', 16, 1);
    END
    ELSE
    BEGIN
        -- If there is sufficient stock, fill the order and decrement UnitsInStock
        DECLARE @ProductID INT, @Quantity INT;
        DECLARE cur CURSOR FOR
        SELECT ProductID, Quantity FROM inserted;

        OPEN cur;
        FETCH NEXT FROM cur INTO @ProductID, @Quantity;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Decrement UnitsInStock for the product
            UPDATE Products
            SET UnitsInStock = UnitsInStock - @Quantity
            WHERE ProductID = @ProductID;

            FETCH NEXT FROM cur INTO @ProductID, @Quantity;
        END;

        CLOSE cur;
        DEALLOCATE cur;

        -- Insert the orders into Order Details table
        INSERT INTO [Order Details] (OrderID, ProductID, UnitPrice, Quantity, Discount)
        SELECT OrderID, ProductID, UnitPrice, Quantity, Discount
        FROM inserted;
    END;
END;



