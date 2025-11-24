-- ===============================
-- SAMPLE PRODUCT INGREDIENTS DATA
-- ===============================
-- Script này thêm công thức nguyên liệu mẫu cho các sản phẩm
-- Bạn cần điều chỉnh theo ProductSizeID và InventoryID thực tế trong database của bạn

-- Kiểm tra dữ liệu hiện tại
SELECT 'Current ProductSize count' AS Info, COUNT(*) AS Count FROM ProductSize;
SELECT 'Current Inventory count' AS Info, COUNT(*) AS Count FROM Inventory;
SELECT 'Current ProductIngredient count' AS Info, COUNT(*) AS Count FROM ProductIngredient;

-- Xem danh sách ProductSize
SELECT ps.ProductSizeID, p.ProductName, ps.SizeCode, ps.SizeName, c.CategoryName
FROM ProductSize ps
JOIN Product p ON ps.ProductID = p.ProductID
JOIN Category c ON p.CategoryID = c.CategoryID
ORDER BY c.CategoryName, p.ProductName, ps.SizeCode;

-- Xem danh sách Inventory
SELECT InventoryID, ItemName, Quantity, Unit, Status
FROM Inventory
ORDER BY ItemName;

-- ===============================
-- SAMPLE DATA - ĐIỀU CHỈNH THEO DATABASE CỦA BẠN
-- ===============================

-- Ví dụ: Pizza Hawaiian (giả sử ProductSizeID = 1, 2, 3 cho S, M, L)
-- Bạn cần thay đổi các ID này theo database thực tế

/*
-- Pizza Hawaiian - Small (ProductSizeID = 1)
INSERT INTO ProductIngredient (ProductSizeID, InventoryID, QuantityNeeded)
VALUES
(1, 1, 0.2),  -- Bột mì: 200g
(1, 2, 0.1),  -- Phô mai: 100g
(1, 3, 0.05), -- Sốt cà chua: 50g
(1, 4, 0.05), -- Thịt nguội: 50g
(1, 5, 0.03); -- Dứa: 30g

-- Pizza Hawaiian - Medium (ProductSizeID = 2)
INSERT INTO ProductIngredient (ProductSizeID, InventoryID, QuantityNeeded)
VALUES
(2, 1, 0.3),  -- Bột mì: 300g
(2, 2, 0.15), -- Phô mai: 150g
(2, 3, 0.08), -- Sốt cà chua: 80g
(2, 4, 0.08), -- Thịt nguội: 80g
(2, 5, 0.05); -- Dứa: 50g

-- Pizza Hawaiian - Large (ProductSizeID = 3)
INSERT INTO ProductIngredient (ProductSizeID, InventoryID, QuantityNeeded)
VALUES
(3, 1, 0.4),  -- Bột mì: 400g
(3, 2, 0.2),  -- Phô mai: 200g
(3, 3, 0.1),  -- Sốt cà chua: 100g
(3, 4, 0.1),  -- Thịt nguội: 100g
(3, 5, 0.07); -- Dứa: 70g

-- Drink - Iced Milk Coffee (ProductSizeID = 10, Fixed size)
INSERT INTO ProductIngredient (ProductSizeID, InventoryID, QuantityNeeded)
VALUES
(10, 6, 0.03),  -- Cà phê: 30g
(10, 7, 0.2),   -- Sữa: 200ml
(10, 8, 0.1);   -- Đá: 100g
*/

-- ===============================
-- HƯỚNG DẪN SỬ DỤNG
-- ===============================
-- 1. Chạy các SELECT query ở trên để xem ProductSizeID và InventoryID
-- 2. Uncomment và điều chỉnh các INSERT statement theo dữ liệu thực tế
-- 3. QuantityNeeded là số lượng nguyên liệu cần cho 1 món (đơn vị theo Inventory.Unit)
-- 4. Sau khi INSERT, view v_ProductSizeAvailable sẽ tự động tính toán số món có thể làm

-- Kiểm tra kết quả sau khi INSERT
-- SELECT * FROM v_ProductSizeAvailable ORDER BY CategoryName, ProductName, SizeCode;
