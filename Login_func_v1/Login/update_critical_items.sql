-- ===========================
-- CẬP NHẬT CRITICAL ITEMS CHO DỮ LIỆU THỰC TẾ
-- ===========================

USE pizza_demo_DB2;
GO

-- Xóa dữ liệu cũ nếu có
DELETE FROM CriticalItems;
GO

-- Chèn critical items dựa trên dữ liệu inventory thực tế
INSERT INTO CriticalItems (InventoryID, Priority, Category, IsActive)
SELECT 
    I.InventoryID,
    CASE 
        WHEN I.ItemName LIKE N'%Bột%' OR I.ItemName LIKE N'%Dở Bánh%' THEN 1  -- Ưu tiên cao cho bột làm bánh
        WHEN I.ItemName LIKE N'%Phô Mai%' OR I.ItemName LIKE N'%Cheese%' THEN 1  -- Ưu tiên cao cho phô mai
        WHEN I.ItemName LIKE N'%Sốt%' OR I.ItemName LIKE N'%Sauce%' THEN 1  -- Ưu tiên cao cho sốt
        WHEN I.ItemName LIKE N'%Xúc Xích%' OR I.ItemName LIKE N'%Thịt%' THEN 2  -- Ưu tiên trung bình cho topping thịt
        ELSE 3  -- Ưu tiên thấp cho các nguyên liệu khác
    END AS Priority,
    CASE 
        WHEN I.ItemName LIKE N'%Bột%' OR I.ItemName LIKE N'%Dở Bánh%' THEN 'DOUGH'
        WHEN I.ItemName LIKE N'%Phô Mai%' THEN 'CHEESE'
        WHEN I.ItemName LIKE N'%Sốt%' THEN 'SAUCE'
        WHEN I.ItemName LIKE N'%Xúc Xích%' OR I.ItemName LIKE N'%Thịt%' THEN 'TOPPING'
        ELSE 'OTHER'
    END AS Category,
    1 AS IsActive
FROM Inventory I;
GO

-- Kiểm tra kết quả
SELECT 
    CI.CriticalItemID,
    I.ItemName,
    CI.Priority,
    CI.Category,
    CI.IsActive
FROM CriticalItems CI
JOIN Inventory I ON CI.InventoryID = I.InventoryID
ORDER BY CI.Priority, I.ItemName;
GO

PRINT 'Đã cập nhật Critical Items thành công!';
GO