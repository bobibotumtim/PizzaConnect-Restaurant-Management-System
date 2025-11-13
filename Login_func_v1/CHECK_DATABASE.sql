-- ===============================
-- 🔍 SCRIPT KIỂM TRA DATABASE
-- ===============================

USE pizza_demo_DB_FinalModel_Combined;
GO

-- 1. Kiểm tra số lượng orders
SELECT COUNT(*) as TotalOrders FROM [Order];
GO

-- 2. Kiểm tra orders của từng customer
SELECT 
    c.CustomerID,
    u.Name as CustomerName,
    u.Email,
    COUNT(o.OrderID) as OrderCount
FROM Customer c
LEFT JOIN [User] u ON c.UserID = u.UserID
LEFT JOIN [Order] o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, u.Name, u.Email
ORDER BY c.CustomerID;
GO

-- 3. Kiểm tra chi tiết orders của Customer 1 (Le Van C)
SELECT 
    o.OrderID,
    o.OrderDate,
    o.Status,
    o.PaymentStatus,
    o.TotalPrice,
    COUNT(od.OrderDetailID) as ItemCount
FROM [Order] o
LEFT JOIN OrderDetail od ON o.OrderID = od.OrderID
WHERE o.CustomerID = 1
GROUP BY o.OrderID, o.OrderDate, o.Status, o.PaymentStatus, o.TotalPrice
ORDER BY o.OrderDate DESC;
GO

-- 4. Kiểm tra UserID và CustomerID mapping
SELECT 
    u.UserID,
    u.Name,
    u.Email,
    u.Role,
    c.CustomerID,
    c.LoyaltyPoint
FROM [User] u
LEFT JOIN Customer c ON u.UserID = c.UserID
WHERE u.Role = 3
ORDER BY u.UserID;
GO

-- 5. Kiểm tra OrderDetails có ProductName không
SELECT TOP 5
    od.OrderDetailID,
    od.OrderID,
    od.ProductSizeID,
    p.ProductName,
    ps.SizeName,
    od.Quantity,
    od.TotalPrice
FROM OrderDetail od
LEFT JOIN ProductSize ps ON od.ProductSizeID = ps.ProductSizeID
LEFT JOIN Product p ON ps.ProductID = p.ProductID
ORDER BY od.OrderDetailID DESC;
GO
