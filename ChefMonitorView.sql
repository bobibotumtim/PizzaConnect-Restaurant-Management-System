-- ===============================
-- VIEW HỖ TRỢ CHO CHEF MONITOR
-- ===============================

USE pizza_demo_DB_Merged;
GO

-- Tạo View để hiển thị thông tin đầy đủ cho Chef Monitor
CREATE OR ALTER VIEW v_ChefMonitorOrderDetails AS
SELECT 
    od.OrderDetailID,
    od.OrderID,
    od.ProductSizeID,
    od.Quantity,
    od.TotalPrice,
    od.SpecialInstructions,
    od.EmployeeID,
    od.[Status],
    od.StartTime,
    od.EndTime,
    
    -- Thông tin Product
    p.ProductID,
    p.ProductName,
    p.Description as ProductDescription,
    
    -- Thông tin Size
    ps.SizeCode,
    ps.SizeName,
    ps.Price as UnitPrice,
    
    -- Thông tin Category
    c.CategoryName,
    
    -- Thông tin Order
    o.TableID,
    o.OrderDate,
    o.Note as OrderNote,
    
    -- Thông tin Table
    t.TableNumber,
    
    -- Thông tin Employee (Chef)
    e.EmployeeID as ChefEmployeeID,
    u.Name as ChefName
    
FROM OrderDetail od
LEFT JOIN ProductSize ps ON od.ProductSizeID = ps.ProductSizeID
LEFT JOIN Product p ON ps.ProductID = p.ProductID
LEFT JOIN Category c ON p.CategoryID = c.CategoryID
LEFT JOIN [Order] o ON od.OrderID = o.OrderID
LEFT JOIN [Table] t ON o.TableID = t.TableID
LEFT JOIN Employee e ON od.EmployeeID = e.EmployeeID
LEFT JOIN [User] u ON e.UserID = u.UserID
WHERE p.IsAvailable = 1 
  AND ps.IsDeleted = 0 
  AND c.IsDeleted = 0;

GO

PRINT '✅ Tạo View v_ChefMonitorOrderDetails thành công';