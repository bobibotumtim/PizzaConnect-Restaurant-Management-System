-- ===============================
-- TEST POS VỚI SIZE SELECTION
-- ===============================

USE pizza_demo_DB_Merged;
GO

-- ===============================
-- 1. KIỂM TRA DỮ LIỆU CẦN THIẾT
-- ===============================

PRINT '=== KIỂM TRA DỮ LIỆU CHO POS ===';

-- Kiểm tra Products và ProductSizes
SELECT 
    p.ProductID,
    p.ProductName,
    c.CategoryName,
    ps.ProductSizeID,
    ps.SizeCode,
    ps.SizeName,
    ps.Price,
    ps.IsDeleted
FROM Product p
JOIN Category c ON p.CategoryID = c.CategoryID
JOIN ProductSize ps ON p.ProductID = ps.ProductID
WHERE p.IsAvailable = 1 
  AND ps.IsDeleted = 0
  AND c.IsDeleted = 0
ORDER BY c.CategoryName, p.ProductName, ps.SizeCode;

-- ===============================
-- 2. TEST API PRODUCTS RESPONSE
-- ===============================

PRINT '=== SIMULATE API PRODUCTS RESPONSE ===';

-- Tạo JSON response giống như ProductAPIServlet sẽ trả về
DECLARE @JsonResponse NVARCHAR(MAX) = '{"success": true, "categories": {';

-- Pizza category
SET @JsonResponse = @JsonResponse + '"Pizza": [';
SET @JsonResponse = @JsonResponse + 
    '{"id": 1, "name": "Hawaiian Pizza", "description": "Pizza with ham and pineapple", "category": "Pizza", "imageUrl": "hawaiian.jpg", "sizes": [' +
    '{"sizeId": 1, "sizeCode": "S", "sizeName": "Small", "price": 120000},' +
    '{"sizeId": 2, "sizeCode": "M", "sizeName": "Medium", "price": 160000},' +
    '{"sizeId": 3, "sizeCode": "L", "sizeName": "Large", "price": 200000}' +
    ']}';
SET @JsonResponse = @JsonResponse + '],';

-- Drink category  
SET @JsonResponse = @JsonResponse + '"Drink": [';
SET @JsonResponse = @JsonResponse + 
    '{"id": 2, "name": "Iced Milk Coffee", "description": "Coffee with condensed milk", "category": "Drink", "imageUrl": "icedMilkCoffee.jpg", "sizes": [' +
    '{"sizeId": 4, "sizeCode": "F", "sizeName": "Fixed", "price": 25000}' +
    ']},' +
    '{"id": 3, "name": "Peach Orange Tea", "description": "Peach tea with orange flavor", "category": "Drink", "imageUrl": "peachOrangeTea.jpg", "sizes": [' +
    '{"sizeId": 5, "sizeCode": "F", "sizeName": "Fixed", "price": 30000}' +
    ']}';
SET @JsonResponse = @JsonResponse + ']';

SET @JsonResponse = @JsonResponse + '}}';

PRINT 'Expected API Response:';
PRINT @JsonResponse;

-- ===============================
-- 3. TEST ORDER CREATION VỚI PRODUCTSIZEID
-- ===============================

PRINT '=== TEST ORDER CREATION WITH PRODUCTSIZEID ===';

-- Tạo test order với ProductSizeID
DECLARE @TestOrderID INT;

BEGIN TRANSACTION;

-- Tạo order
INSERT INTO [Order] (CustomerID, EmployeeID, TableID, OrderDate, Status, PaymentStatus, TotalPrice, Note)
VALUES (1, 1, 1, GETDATE(), 0, 'Unpaid', 0, 'POS Test Order with ProductSizeID');

SET @TestOrderID = SCOPE_IDENTITY();

-- Thêm OrderDetail với ProductSizeID (giống như POS sẽ gửi)
INSERT INTO OrderDetail (OrderID, ProductSizeID, Quantity, TotalPrice, SpecialInstructions, Status)
VALUES 
(@TestOrderID, 2, 1, 160000, 'Hawaiian Pizza (Medium) + Extra Cheese', 'Waiting'),
(@TestOrderID, 4, 2, 50000, 'Iced Milk Coffee (Fixed) x2', 'Waiting');

-- Cập nhật tổng tiền
UPDATE [Order] 
SET TotalPrice = (SELECT SUM(TotalPrice) FROM OrderDetail WHERE OrderID = @TestOrderID)
WHERE OrderID = @TestOrderID;

COMMIT TRANSACTION;

PRINT 'Created test order ID: ' + CAST(@TestOrderID AS NVARCHAR(10));

-- Hiển thị order vừa tạo
SELECT 
    o.OrderID,
    o.TotalPrice,
    o.Note,
    od.OrderDetailID,
    od.ProductSizeID,
    p.ProductName,
    ps.SizeName,
    ps.Price as UnitPrice,
    od.Quantity,
    od.TotalPrice as LineTotal,
    od.SpecialInstructions,
    od.Status
FROM [Order] o
JOIN OrderDetail od ON o.OrderID = od.OrderID
JOIN ProductSize ps ON od.ProductSizeID = ps.ProductSizeID
JOIN Product p ON ps.ProductID = p.ProductID
WHERE o.OrderID = @TestOrderID;

-- ===============================
-- 4. TEST CHEF MONITOR VỚI ORDER MỚI
-- ===============================

PRINT '=== TEST CHEF MONITOR WITH NEW ORDER ===';

-- Query giống như ChefMonitorServlet sẽ dùng
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
    o.TableID
FROM OrderDetail od
LEFT JOIN ProductSize ps ON od.ProductSizeID = ps.ProductSizeID
LEFT JOIN Product p ON ps.ProductID = p.ProductID
LEFT JOIN [Order] o ON od.OrderID = o.OrderID
WHERE od.Status = 'Waiting'
ORDER BY od.OrderDetailID;

-- ===============================
-- 5. SIMULATE POS JSON REQUEST
-- ===============================

PRINT '=== SIMULATE POS JSON REQUEST ===';

-- JSON mà POS sẽ gửi khi tạo order
DECLARE @POSRequest NVARCHAR(MAX) = '{
    "customerName": "Test Customer",
    "items": [
        {
            "id": 1,
            "sizeId": 2,
            "name": "Hawaiian Pizza",
            "sizeName": "Medium",
            "price": 160000,
            "quantity": 1,
            "toppings": ["Extra Cheese", "Mushrooms"]
        },
        {
            "id": 2,
            "sizeId": 4,
            "name": "Iced Milk Coffee", 
            "sizeName": "Fixed",
            "price": 25000,
            "quantity": 2,
            "toppings": []
        }
    ],
    "subtotal": 210000,
    "discount": 5,
    "discountAmount": 10500,
    "total": 199500
}';

PRINT 'POS Request JSON:';
PRINT @POSRequest;

PRINT '=== HOÀN THÀNH TEST POS ===';