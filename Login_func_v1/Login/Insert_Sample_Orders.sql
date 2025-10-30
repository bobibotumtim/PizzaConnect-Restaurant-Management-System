-- Insert Sample Orders for Testing Dashboard
-- Run this to create test data for Best Dishes

-- Ensure we have products first
IF NOT EXISTS (SELECT * FROM Product WHERE ProductID = 1)
BEGIN
    PRINT '❌ No products found! Run POS_Database_Setup_Complete.sql first';
END
ELSE
BEGIN
    -- Insert sample orders (today's date)
    DECLARE @OrderID1 INT, @OrderID2 INT, @OrderID3 INT, @OrderID4 INT, @OrderID5 INT;
    
    -- Order 1
    INSERT INTO [Order] (CustomerID, EmployeeID, TableID, OrderDate, Status, PaymentStatus, TotalPrice, Note)
    VALUES (1, 1, 1, GETDATE(), 2, 'Paid', 0, 'Sample order 1');
    SET @OrderID1 = SCOPE_IDENTITY();
    
    -- Order 2
    INSERT INTO [Order] (CustomerID, EmployeeID, TableID, OrderDate, Status, PaymentStatus, TotalPrice, Note)
    VALUES (1, 1, 2, GETDATE(), 2, 'Paid', 0, 'Sample order 2');
    SET @OrderID2 = SCOPE_IDENTITY();
    
    -- Order 3
    INSERT INTO [Order] (CustomerID, EmployeeID, TableID, OrderDate, Status, PaymentStatus, TotalPrice, Note)
    VALUES (2, 1, 3, GETDATE(), 2, 'Paid', 0, 'Sample order 3');
    SET @OrderID3 = SCOPE_IDENTITY();
    
    -- Order 4
    INSERT INTO [Order] (CustomerID, EmployeeID, TableID, OrderDate, Status, PaymentStatus, TotalPrice, Note)
    VALUES (2, 1, 4, GETDATE(), 1, 'Unpaid', 0, 'Sample order 4');
    SET @OrderID4 = SCOPE_IDENTITY();
    
    -- Order 5
    INSERT INTO [Order] (CustomerID, EmployeeID, TableID, OrderDate, Status, PaymentStatus, TotalPrice, Note)
    VALUES (3, 1, 5, GETDATE(), 0, 'Unpaid', 0, 'Sample order 5');
    SET @OrderID5 = SCOPE_IDENTITY();
    
    -- Insert OrderDetails for Order 1 (Pepperoni x3, Hawaiian x2)
    INSERT INTO OrderDetail (OrderID, ProductID, Quantity, TotalPrice, SpecialInstructions)
    VALUES 
        (@OrderID1, 2, 3, 450000, 'Extra cheese'),
        (@OrderID1, 3, 2, 360000, 'No pineapple');
    
    UPDATE [Order] SET TotalPrice = 810000 WHERE OrderID = @OrderID1;
    
    -- Insert OrderDetails for Order 2 (Margherita x5, BBQ Chicken x1)
    INSERT INTO OrderDetail (OrderID, ProductID, Quantity, TotalPrice, SpecialInstructions)
    VALUES 
        (@OrderID2, 1, 5, 600000, 'Well done'),
        (@OrderID2, 4, 1, 160000, 'Extra BBQ sauce');
    
    UPDATE [Order] SET TotalPrice = 760000 WHERE OrderID = @OrderID2;
    
    -- Insert OrderDetails for Order 3 (Pepperoni x2, Veggie x3, Coca Cola x4)
    INSERT INTO OrderDetail (OrderID, ProductID, Quantity, TotalPrice, SpecialInstructions)
    VALUES 
        (@OrderID3, 2, 2, 300000, NULL),
        (@OrderID3, 5, 3, 435000, 'Extra veggies'),
        (@OrderID3, 9, 4, 60000, 'With ice');
    
    UPDATE [Order] SET TotalPrice = 795000 WHERE OrderID = @OrderID3;
    
    -- Insert OrderDetails for Order 4 (Meat Lovers x4, Chicken Wings x2)
    INSERT INTO OrderDetail (OrderID, ProductID, Quantity, TotalPrice, SpecialInstructions)
    VALUES 
        (@OrderID4, 6, 4, 760000, 'Extra meat'),
        (@OrderID4, 16, 2, 160000, 'Spicy');
    
    UPDATE [Order] SET TotalPrice = 920000 WHERE OrderID = @OrderID4;
    
    -- Insert OrderDetails for Order 5 (Hawaiian x1, Four Cheese x2, Tiramisu x3)
    INSERT INTO OrderDetail (OrderID, ProductID, Quantity, TotalPrice, SpecialInstructions)
    VALUES 
        (@OrderID5, 3, 1, 180000, NULL),
        (@OrderID5, 7, 2, 330000, 'Extra cheese'),
        (@OrderID5, 21, 3, 150000, NULL);
    
    UPDATE [Order] SET TotalPrice = 660000 WHERE OrderID = @OrderID5;
    
    PRINT '✅ Sample orders inserted successfully!';
    PRINT '';
    PRINT 'Expected Best Dishes:';
    PRINT '1. Margherita Pizza: 5';
    PRINT '2. Meat Lovers: 4';
    PRINT '3. Pepperoni Pizza: 5 (3+2)';
    PRINT '4. Veggie Supreme: 3';
    PRINT '5. Tiramisu: 3';
END

-- Show summary
SELECT 
    p.ProductName,
    SUM(od.Quantity) as TotalQuantity
FROM OrderDetail od
JOIN Product p ON od.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY TotalQuantity DESC;
