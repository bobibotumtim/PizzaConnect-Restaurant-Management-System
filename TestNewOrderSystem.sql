-- ===============================
-- SCRIPT TEST HỆ THỐNG ORDER MỚI
-- ===============================

USE pizza_demo_DB_Merged;
GO

-- ===============================
-- 1. KIỂM TRA CẤU TRÚC DATABASE
-- ===============================

PRINT '=== KIỂM TRA CẤU TRÚC DATABASE ===';

-- Kiểm tra các bảng chính
SELECT 'Product' as TableName, COUNT(*) as RecordCount FROM Product
UNION ALL
SELECT 'ProductSize', COUNT(*) FROM ProductSize
UNION ALL
SELECT 'Category', COUNT(*) FROM Category
UNION ALL
SELECT '[Order]', COUNT(*) FROM [Order]
UNION ALL
SELECT 'OrderDetail', COUNT(*) FROM OrderDetail
UNION ALL
SELECT 'Customer', COUNT(*) FROM Customer
UNION ALL
SELECT 'Employee', COUNT(*) FROM Employee;

-- ===============================
-- 2. TẠO DỮ LIỆU TEST
-- ===============================

PRINT '=== TẠO DỮ LIỆU TEST ===';

-- Tạo order test với ProductSize
DECLARE @TestOrderID INT;

BEGIN TRANSACTION;

-- Tạo order mới
INSERT INTO [Order] (CustomerID, EmployeeID, TableID, OrderDate, Status, PaymentStatus, TotalPrice, Note)
VALUES (1, 1, 1, GETDATE(), 0, 'Unpaid', 0, 'Test order với ProductSize mới');

SET @TestOrderID = SCOPE_IDENTITY();

-- Thêm OrderDetail với ProductSizeID
INSERT INTO OrderDetail (OrderID, ProductSizeID, Quantity, TotalPrice, SpecialInstructions, Status)
VALUES 
(@TestOrderID, 1, 2, 240000, 'Test Hawaiian Small x2', 'Waiting'),
(@TestOrderID, 2, 1, 160000, 'Test Hawaiian Medium x1', 'Waiting'),
(@TestOrderID, 4, 1, 25000, 'Test Coffee x1', 'Waiting');

-- Cập nhật tổng tiền
UPDATE [Order] 
SET TotalPrice = (SELECT SUM(TotalPrice) FROM OrderDetail WHERE OrderID = @TestOrderID)
WHERE OrderID = @TestOrderID;

COMMIT TRANSACTION;

PRINT 'Tạo test order ID: ' + CAST(@TestOrderID AS NVARCHAR(10));

-- ===============================
-- 3. KIỂM TRA DỮ LIỆU
-- ===============================

PRINT '=== KIỂM TRA DỮ LIỆU ORDER MỚI ===';

-- Hiển thị order vừa tạo
SELECT 
    o.OrderID,
    o.CustomerID,
    o.TableID,
    o.Status,
    o.TotalPrice,
    o.Note
FROM [Order] o
WHERE o.OrderID = @TestOrderID;

-- Hiển thị chi tiết order với thông tin ProductSize
SELECT 
    od.OrderDetailID,
    od.OrderID,
    od.ProductSizeID,
    p.ProductName,
    ps.SizeName,
    ps.SizeCode,
    ps.Price as UnitPrice,
    od.Quantity,
    od.TotalPrice,
    od.SpecialInstructions,
    od.Status
FROM OrderDetail od
LEFT JOIN ProductSize ps ON od.ProductSizeID = ps.ProductSizeID
LEFT JOIN Product p ON ps.ProductID = p.ProductID
WHERE od.OrderID = @TestOrderID;

-- ===============================
-- 4. TEST CHEF MONITOR QUERIES
-- ===============================

PRINT '=== TEST CHEF MONITOR QUERIES ===';

-- Query cho Waiting dishes
SELECT 'WAITING DISHES' as Section;
SELECT 
    od.OrderDetailID,
    od.OrderID,
    od.ProductSizeID,
    p.ProductName,
    ps.SizeName,
    ps.SizeCode,
    od.Quantity,
    od.TotalPrice,
    od.SpecialInstructions,
    od.Status
FROM OrderDetail od
LEFT JOIN ProductSize ps ON od.ProductSizeID = ps.ProductSizeID
LEFT JOIN Product p ON ps.ProductID = p.ProductID
WHERE od.Status = 'Waiting'
ORDER BY od.OrderDetailID;

-- Test cập nhật status
UPDATE OrderDetail 
SET Status = 'In Progress', 
    EmployeeID = 3,  -- Chef
    StartTime = GETDATE()
WHERE OrderDetailID = (SELECT TOP 1 OrderDetailID FROM OrderDetail WHERE OrderID = @TestOrderID);

-- Query cho In Progress dishes
SELECT 'IN PROGRESS DISHES' as Section;
SELECT 
    od.OrderDetailID,
    od.OrderID,
    od.ProductSizeID,
    p.ProductName,
    ps.SizeName,
    ps.SizeCode,
    od.Quantity,
    od.TotalPrice,
    od.SpecialInstructions,
    od.Status,
    od.StartTime
FROM OrderDetail od
LEFT JOIN ProductSize ps ON od.ProductSizeID = ps.ProductSizeID
LEFT JOIN Product p ON ps.ProductID = p.ProductID
WHERE od.Status = 'In Progress'
ORDER BY od.OrderDetailID;

-- ===============================
-- 5. TEST VIEW
-- ===============================

PRINT '=== TEST VIEW v_ProductSizeAvailable ===';

SELECT TOP 5 * FROM v_ProductSizeAvailable;

PRINT '=== HOÀN THÀNH TEST ===';