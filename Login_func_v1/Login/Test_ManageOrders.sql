-- Test script for ManageOrders functionality
-- Run this in SQL Server Management Studio to verify database connection

USE pizza_demo_DB2;
GO

-- 1. Check if Order table exists and has data
PRINT '=== Checking Order table ===';
SELECT COUNT(*) AS TotalOrders FROM [Order];
SELECT TOP 5 * FROM [Order] ORDER BY OrderDate DESC;

-- 2. Check if OrderDetail table exists and has data
PRINT '=== Checking OrderDetail table ===';
SELECT COUNT(*) AS TotalOrderDetails FROM OrderDetail;
SELECT TOP 5 * FROM OrderDetail;

-- 3. Test pagination query (first page, 10 items)
PRINT '=== Testing pagination query (Page 1) ===';
SELECT * FROM [Order] 
ORDER BY OrderDate DESC 
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- 4. Test filter by status with pagination
PRINT '=== Testing filter by status (Status=0, Page 1) ===';
SELECT * FROM [Order] 
WHERE Status = 0
ORDER BY OrderDate DESC 
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- 5. Test count by status
PRINT '=== Testing count by status ===';
SELECT Status, COUNT(*) AS Count 
FROM [Order] 
GROUP BY Status;

-- 6. Test update order status
PRINT '=== Testing update order status ===';
-- Find a test order
DECLARE @TestOrderID INT = (SELECT TOP 1 OrderID FROM [Order] WHERE Status = 0);
IF @TestOrderID IS NOT NULL
BEGIN
    PRINT 'Test Order ID: ' + CAST(@TestOrderID AS VARCHAR);
    PRINT 'Before update:';
    SELECT OrderID, Status, PaymentStatus FROM [Order] WHERE OrderID = @TestOrderID;
    
    -- Update status (don't commit, just test)
    -- UPDATE [Order] SET Status = 1 WHERE OrderID = @TestOrderID;
    -- PRINT 'After update:';
    -- SELECT OrderID, Status, PaymentStatus FROM [Order] WHERE OrderID = @TestOrderID;
    -- ROLLBACK; -- Rollback to keep data unchanged
END
ELSE
BEGIN
    PRINT 'No orders with Status=0 found for testing';
END

-- 7. Check Product table for order details
PRINT '=== Checking Product table ===';
SELECT COUNT(*) AS TotalProducts FROM Product;
SELECT TOP 5 ProductID, ProductName, Price FROM Product;

-- 8. Test join query (Order with OrderDetails and Products)
PRINT '=== Testing Order with Details ===';
SELECT TOP 1
    o.OrderID,
    o.Status,
    o.PaymentStatus,
    o.TotalPrice,
    od.OrderDetailID,
    od.ProductID,
    p.ProductName,
    od.Quantity,
    od.TotalPrice AS DetailPrice
FROM [Order] o
LEFT JOIN OrderDetail od ON o.OrderID = od.OrderID
LEFT JOIN Product p ON od.ProductID = p.ProductID
ORDER BY o.OrderDate DESC;

PRINT '=== Test completed ===';
