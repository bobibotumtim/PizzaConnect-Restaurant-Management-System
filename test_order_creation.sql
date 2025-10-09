-- Test script để kiểm tra tạo đơn hàng
USE pizza_demo_DB;
GO

-- Kiểm tra dữ liệu hiện có
SELECT 'Products' as TableName, COUNT(*) as Count FROM Products
UNION ALL
SELECT 'Orders' as TableName, COUNT(*) as Count FROM Orders
UNION ALL
SELECT 'OrderDetails' as TableName, COUNT(*) as Count FROM OrderDetails;

-- Xem 5 đơn hàng mẫu
SELECT 
    o.OrderID,
    o.TableNumber,
    o.CustomerName,
    o.TotalMoney,
    o.Status,
    o.PaymentStatus,
    COUNT(od.OrderDetailID) as ItemCount
FROM Orders o
LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY o.OrderID, o.TableNumber, o.CustomerName, o.TotalMoney, o.Status, o.PaymentStatus
ORDER BY o.OrderID;

-- Xem chi tiết đơn hàng đầu tiên
SELECT 
    od.OrderDetailID,
    p.ProductName,
    od.Quantity,
    od.UnitPrice,
    od.TotalPrice,
    od.SpecialInstructions
FROM OrderDetails od
JOIN Products p ON od.ProductID = p.ProductID
WHERE od.OrderID = 1;

PRINT 'Database check completed successfully!';

