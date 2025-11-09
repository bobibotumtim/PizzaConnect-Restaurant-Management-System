-- ===============================
-- 📝 SAMPLE ORDERS WITH TOPPINGS
-- Database: pizza_demo_DB_FinalModel
-- ===============================

USE pizza_demo_DB_FinalModel;
GO

-- Không xóa dữ liệu cũ, chỉ thêm mới
-- DELETE FROM OrderDetailTopping;
-- DELETE FROM OrderDetail;
-- DELETE FROM [Order];

-- ===============================
-- 🛒 TẠO ORDERS MỚI (Sử dụng IDENTITY)
-- ===============================

DECLARE @Order1 INT, @Order2 INT, @Order3 INT, @Order4 INT, @Order5 INT, @Order6 INT;
DECLARE @OD1 INT, @OD2 INT, @OD3 INT, @OD4 INT, @OD5 INT, @OD6 INT, @OD7 INT;

-- Order 1: Pizza S (Waiting)
INSERT INTO [Order] (CustomerID, EmployeeID, TableID, [Status], PaymentStatus, TotalPrice, Note)
VALUES (1, 1, 5, 0, 'Unpaid', 120000, N'Order 1: Pizza S - No topping');
SET @Order1 = SCOPE_IDENTITY();

-- Order 2: Coffee + Tea (Waiting)
INSERT INTO [Order] (CustomerID, EmployeeID, TableID, [Status], PaymentStatus, TotalPrice, Note)
VALUES (1, 2, 3, 0, 'Unpaid', 55000, N'Order 2: Coffee + Tea');
SET @Order2 = SCOPE_IDENTITY();

-- Order 3: Pizza S + Extra Cheese Topping (Preparing)
INSERT INTO [Order] (CustomerID, EmployeeID, TableID, [Status], PaymentStatus, TotalPrice, Note)
VALUES (2, 2, 2, 1, 'Unpaid', 135000, N'Order 3: Pizza S + Extra Cheese');
SET @Order3 = SCOPE_IDENTITY();

-- Order 4: Pizza M + Extra Cheese + Sausage (Waiting)
INSERT INTO [Order] (CustomerID, EmployeeID, TableID, [Status], PaymentStatus, TotalPrice, Note)
VALUES (2, 1, 7, 0, 'Unpaid', 195000, N'Order 4: Pizza M + 2 toppings');
SET @Order4 = SCOPE_IDENTITY();

-- Order 5: 2x Pizza L + Sausage (Waiting)
INSERT INTO [Order] (CustomerID, EmployeeID, TableID, [Status], PaymentStatus, TotalPrice, Note)
VALUES (3, 2, 9, 0, 'Unpaid', 420000, N'Order 5: 2 Pizza L + Sausage');
SET @Order5 = SCOPE_IDENTITY();

-- Order 6: Pizza S + Extra Cheese (Ready)
INSERT INTO [Order] (CustomerID, EmployeeID, TableID, [Status], PaymentStatus, TotalPrice, Note)
VALUES (1, 1, 4, 2, 'Unpaid', 135000, N'Order 6: Pizza S + Cheese - Ready');
SET @Order6 = SCOPE_IDENTITY();

PRINT '✅ Created Orders: ' + CAST(@Order1 AS VARCHAR) + ', ' + CAST(@Order2 AS VARCHAR) + ', ' + 
      CAST(@Order3 AS VARCHAR) + ', ' + CAST(@Order4 AS VARCHAR) + ', ' + 
      CAST(@Order5 AS VARCHAR) + ', ' + CAST(@Order6 AS VARCHAR);

-- ===============================
-- 🍕 TẠO ORDER DETAILS
-- ===============================

-- Order 1: Pizza S (Waiting)
INSERT INTO OrderDetail (OrderID, ProductSizeID, Quantity, TotalPrice, SpecialInstructions, EmployeeID, [Status], StartTime, EndTime)
VALUES (@Order1, 1, 1, 120000, NULL, NULL, 'Waiting', NULL, NULL);
SET @OD1 = SCOPE_IDENTITY();

-- Order 2: Coffee + Tea (Waiting)
INSERT INTO OrderDetail (OrderID, ProductSizeID, Quantity, TotalPrice, SpecialInstructions, EmployeeID, [Status], StartTime, EndTime)
VALUES (@Order2, 4, 1, 25000, N'Ít đá', NULL, 'Waiting', NULL, NULL);
SET @OD2 = SCOPE_IDENTITY();

INSERT INTO OrderDetail (OrderID, ProductSizeID, Quantity, TotalPrice, SpecialInstructions, EmployeeID, [Status], StartTime, EndTime)
VALUES (@Order2, 5, 1, 30000, N'Không đường', NULL, 'Waiting', NULL, NULL);
SET @OD3 = SCOPE_IDENTITY();

-- Order 3: Pizza S (Preparing) - Có topping
INSERT INTO OrderDetail (OrderID, ProductSizeID, Quantity, TotalPrice, SpecialInstructions, EmployeeID, [Status], StartTime, EndTime)
VALUES (@Order3, 1, 1, 135000, N'Nướng giòn', 3, 'Preparing', DATEADD(MINUTE, -10, GETDATE()), NULL);
SET @OD4 = SCOPE_IDENTITY();

-- Order 4: Pizza M (Waiting) - Có 2 toppings
INSERT INTO OrderDetail (OrderID, ProductSizeID, Quantity, TotalPrice, SpecialInstructions, EmployeeID, [Status], StartTime, EndTime)
VALUES (@Order4, 2, 1, 195000, N'Thêm nhiều phô mai', NULL, 'Waiting', NULL, NULL);
SET @OD5 = SCOPE_IDENTITY();

-- Order 5: 2x Pizza L (Waiting) - Có topping
INSERT INTO OrderDetail (OrderID, ProductSizeID, Quantity, TotalPrice, SpecialInstructions, EmployeeID, [Status], StartTime, EndTime)
VALUES (@Order5, 3, 2, 420000, N'Cắt thành 8 miếng', NULL, 'Waiting', NULL, NULL);
SET @OD6 = SCOPE_IDENTITY();

-- Order 6: Pizza S (Ready) - Có topping
INSERT INTO OrderDetail (OrderID, ProductSizeID, Quantity, TotalPrice, SpecialInstructions, EmployeeID, [Status], StartTime, EndTime)
VALUES (@Order6, 1, 1, 135000, N'Không hành', 3, 'Ready', DATEADD(MINUTE, -30, GETDATE()), DATEADD(MINUTE, -5, GETDATE()));
SET @OD7 = SCOPE_IDENTITY();

PRINT '✅ Created OrderDetails: ' + CAST(@OD1 AS VARCHAR) + ', ' + CAST(@OD2 AS VARCHAR) + ', ' + 
      CAST(@OD3 AS VARCHAR) + ', ' + CAST(@OD4 AS VARCHAR) + ', ' + 
      CAST(@OD5 AS VARCHAR) + ', ' + CAST(@OD6 AS VARCHAR) + ', ' + CAST(@OD7 AS VARCHAR);

-- ===============================
-- 🧀 TẠO ORDER DETAIL TOPPINGS
-- ===============================

-- Order 3: Pizza S + Extra Cheese
-- ProductSizeID 6 = Extra Cheese Topping (Fixed size, Price = 15000)
INSERT INTO OrderDetailTopping (OrderDetailID, ProductSizeID, ProductPrice)
VALUES (@OD4, 6, 15000);

-- Order 4: Pizza M + Extra Cheese + Sausage
-- ProductSizeID 6 = Extra Cheese (15000)
-- ProductSizeID 7 = Sausage (20000)
INSERT INTO OrderDetailTopping (OrderDetailID, ProductSizeID, ProductPrice)
VALUES 
(@OD5, 6, 15000),
(@OD5, 7, 20000);

-- Order 5: 2x Pizza L + Sausage
-- ProductSizeID 7 = Sausage (20000)
INSERT INTO OrderDetailTopping (OrderDetailID, ProductSizeID, ProductPrice)
VALUES (@OD6, 7, 20000);

-- Order 6: Pizza S + Extra Cheese
-- ProductSizeID 6 = Extra Cheese (15000)
INSERT INTO OrderDetailTopping (OrderDetailID, ProductSizeID, ProductPrice)
VALUES (@OD7, 6, 15000);

PRINT '✅ Created OrderDetailToppings for orders with toppings';

GO

-- ===============================
-- ✅ VERIFY DATA
-- ===============================

PRINT '========================================';
PRINT '📊 VERIFICATION RESULTS';
PRINT '========================================';

SELECT 
    o.OrderID,
    o.Note,
    od.OrderDetailID,
    p.ProductName,
    ps.SizeName,
    od.Quantity,
    od.TotalPrice,
    od.SpecialInstructions,
    od.Status,
    (SELECT COUNT(*) FROM OrderDetailTopping WHERE OrderDetailID = od.OrderDetailID) AS ToppingCount
FROM [Order] o
JOIN OrderDetail od ON o.OrderID = od.OrderID
JOIN ProductSize ps ON od.ProductSizeID = ps.ProductSizeID
JOIN Product p ON ps.ProductID = p.ProductID
ORDER BY o.OrderID, od.OrderDetailID;

PRINT '';
PRINT '🧀 Topping Details:';

SELECT 
    odt.OrderDetailToppingID,
    odt.OrderDetailID,
    od.OrderID,
    p.ProductName AS MainProduct,
    pt.ProductName AS ToppingName,
    pst.SizeName AS ToppingSize,
    odt.ProductPrice
FROM OrderDetailTopping odt
JOIN OrderDetail od ON odt.OrderDetailID = od.OrderDetailID
JOIN ProductSize ps ON od.ProductSizeID = ps.ProductSizeID
JOIN Product p ON ps.ProductID = p.ProductID
JOIN ProductSize pst ON odt.ProductSizeID = pst.ProductSizeID
JOIN Product pt ON pst.ProductID = pt.ProductID
ORDER BY odt.OrderDetailID;

PRINT '';
PRINT '✅ Sample orders with toppings created successfully!';
GO
