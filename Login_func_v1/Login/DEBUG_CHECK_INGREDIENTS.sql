-- ===============================
-- DEBUG: Kiểm tra ProductIngredient
-- ===============================

-- 1. Kiểm tra Hawaiian Pizza có bao nhiêu size
SELECT 
    ps.ProductSizeID,
    p.ProductName,
    ps.SizeCode,
    ps.SizeName,
    ps.Price
FROM ProductSize ps
JOIN Product p ON ps.ProductID = p.ProductID
WHERE p.ProductName LIKE '%Hawaiian%'
ORDER BY ps.SizeCode;

-- 2. Kiểm tra từng size có ingredients không
SELECT 
    ps.ProductSizeID,
    p.ProductName,
    ps.SizeCode,
    ps.SizeName,
    COUNT(pi.ProductIngredientID) AS IngredientCount
FROM ProductSize ps
JOIN Product p ON ps.ProductID = p.ProductID
LEFT JOIN ProductIngredient pi ON ps.ProductSizeID = pi.ProductSizeID
WHERE p.ProductName LIKE '%Hawaiian%'
GROUP BY ps.ProductSizeID, p.ProductName, ps.SizeCode, ps.SizeName
ORDER BY ps.SizeCode;

-- 3. Xem chi tiết ingredients của từng size
SELECT 
    ps.ProductSizeID,
    p.ProductName,
    ps.SizeCode,
    ps.SizeName,
    i.ItemName,
    pi.QuantityNeeded,
    i.Quantity AS InventoryQty,
    i.Unit,
    (i.Quantity / NULLIF(pi.QuantityNeeded, 0)) AS CanMake
FROM ProductSize ps
JOIN Product p ON ps.ProductID = p.ProductID
LEFT JOIN ProductIngredient pi ON ps.ProductSizeID = pi.ProductSizeID
LEFT JOIN Inventory i ON pi.InventoryID = i.InventoryID
WHERE p.ProductName LIKE '%Hawaiian%'
ORDER BY ps.SizeCode, i.ItemName;

-- 4. Kiểm tra view v_ProductSizeAvailable
SELECT 
    ProductSizeID,
    ProductName,
    SizeCode,
    SizeName,
    AvailableQuantity
FROM v_ProductSizeAvailable
WHERE ProductName LIKE '%Hawaiian%'
ORDER BY SizeCode;

-- 5. Kiểm tra tất cả ProductIngredient
SELECT 
    pi.ProductIngredientID,
    ps.ProductSizeID,
    p.ProductName,
    ps.SizeCode,
    i.ItemName,
    pi.QuantityNeeded,
    i.Quantity AS InventoryQty
FROM ProductIngredient pi
JOIN ProductSize ps ON pi.ProductSizeID = ps.ProductSizeID
JOIN Product p ON ps.ProductID = p.ProductID
JOIN Inventory i ON pi.InventoryID = i.InventoryID
WHERE p.ProductName LIKE '%Hawaiian%'
ORDER BY ps.SizeCode, i.ItemName;
