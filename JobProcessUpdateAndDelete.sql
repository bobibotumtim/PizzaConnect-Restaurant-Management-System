-- ===============================
-- SCRIPT CẬP NHẬT DATABASE TỪ CŨ SANG MỚI
-- Cập nhật từ pizza_demo_DB2_3_1 sang pizza_demo_DB_Merged
-- ===============================

USE pizza_demo_DB_Merged;
GO

-- ===============================
-- 1. BACKUP DỮ LIỆU CŨ (nếu cần)
-- ===============================

-- Tạo bảng backup OrderDetail cũ
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OrderDetail_Backup')
BEGIN
    SELECT * INTO OrderDetail_Backup FROM OrderDetail WHERE 1=0; -- Tạo cấu trúc trống
    PRINT '✅ Tạo bảng backup OrderDetail_Backup';
END

-- ===============================
-- 2. CẬP NHẬT CẤU TRÚC BẢNG ORDERDETAIL
-- ===============================

-- Kiểm tra và thêm cột ProductSizeID nếu chưa có
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('OrderDetail') AND name = 'ProductSizeID')
BEGIN
    ALTER TABLE OrderDetail ADD ProductSizeID INT NULL;
    PRINT '✅ Thêm cột ProductSizeID vào OrderDetail';
END

-- Kiểm tra và thêm cột EmployeeID nếu chưa có
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('OrderDetail') AND name = 'EmployeeID')
BEGIN
    ALTER TABLE OrderDetail ADD EmployeeID INT NULL;
    PRINT '✅ Thêm cột EmployeeID vào OrderDetail';
END

-- Kiểm tra và thêm cột Status nếu chưa có
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('OrderDetail') AND name = 'Status')
BEGIN
    ALTER TABLE OrderDetail ADD [Status] NVARCHAR(50) DEFAULT 'Waiting';
    PRINT '✅ Thêm cột Status vào OrderDetail';
END

-- Kiểm tra và thêm cột StartTime nếu chưa có
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('OrderDetail') AND name = 'StartTime')
BEGIN
    ALTER TABLE OrderDetail ADD StartTime DATETIME NULL;
    PRINT '✅ Thêm cột StartTime vào OrderDetail';
END

-- Kiểm tra và thêm cột EndTime nếu chưa có
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('OrderDetail') AND name = 'EndTime')
BEGIN
    ALTER TABLE OrderDetail ADD EndTime DATETIME NULL;
    PRINT '✅ Thêm cột EndTime vào OrderDetail';
END

-- ===============================
-- 3. MIGRATE DỮ LIỆU TỪ PRODUCTID SANG PRODUCTSIZEID
-- ===============================

-- Cập nhật ProductSizeID dựa trên ProductID cũ
-- Giả sử mỗi Product cũ sẽ map với ProductSize đầu tiên (Fixed size hoặc Small)
UPDATE od
SET ProductSizeID = (
    SELECT TOP 1 ps.ProductSizeID 
    FROM ProductSize ps 
    WHERE ps.ProductID = od.ProductID 
    ORDER BY 
        CASE ps.SizeCode 
            WHEN 'F' THEN 1  -- Fixed size ưu tiên
            WHEN 'S' THEN 2  -- Small
            WHEN 'M' THEN 3  -- Medium  
            WHEN 'L' THEN 4  -- Large
            ELSE 5
        END
)
FROM OrderDetail od
WHERE od.ProductSizeID IS NULL 
  AND od.ProductID IS NOT NULL
  AND EXISTS (SELECT 1 FROM ProductSize ps WHERE ps.ProductID = od.ProductID);

PRINT '✅ Cập nhật ProductSizeID cho OrderDetail hiện có';

-- Cập nhật Status mặc định cho các record cũ
UPDATE OrderDetail 
SET [Status] = 'Waiting' 
WHERE [Status] IS NULL;

PRINT '✅ Cập nhật Status mặc định cho OrderDetail';

-- ===============================
-- 4. TẠO FOREIGN KEY CONSTRAINTS
-- ===============================

-- Thêm FK cho ProductSizeID
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_OrderDetail_ProductSize')
BEGIN
    ALTER TABLE OrderDetail 
    ADD CONSTRAINT FK_OrderDetail_ProductSize 
    FOREIGN KEY (ProductSizeID) REFERENCES ProductSize(ProductSizeID);
    PRINT '✅ Tạo Foreign Key OrderDetail -> ProductSize';
END

-- Thêm FK cho EmployeeID
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_OrderDetail_Employee')
BEGIN
    ALTER TABLE OrderDetail 
    ADD CONSTRAINT FK_OrderDetail_Employee 
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID);
    PRINT '✅ Tạo Foreign Key OrderDetail -> Employee';
END

-- ===============================
-- 5. CẬP NHẬT DỮ LIỆU MẪU
-- ===============================

-- Cập nhật lại TotalPrice dựa trên ProductSize mới
UPDATE od
SET TotalPrice = od.Quantity * ps.Price
FROM OrderDetail od
JOIN ProductSize ps ON od.ProductSizeID = ps.ProductSizeID
WHERE od.ProductSizeID IS NOT NULL;

PRINT '✅ Cập nhật lại TotalPrice dựa trên ProductSize';

-- Cập nhật lại TotalPrice của Order
UPDATE o
SET TotalPrice = (
    SELECT ISNULL(SUM(od.TotalPrice), 0)
    FROM OrderDetail od
    WHERE od.OrderID = o.OrderID
)
FROM [Order] o;

PRINT '✅ Cập nhật lại TotalPrice của Order';

-- ===============================
-- 6. KIỂM TRA DỮ LIỆU SAU MIGRATION
-- ===============================

PRINT '===============================';
PRINT 'KIỂM TRA DỮ LIỆU SAU MIGRATION:';
PRINT '===============================';

-- Kiểm tra OrderDetail có ProductSizeID NULL
DECLARE @NullProductSizeCount INT = (SELECT COUNT(*) FROM OrderDetail WHERE ProductSizeID IS NULL);
PRINT 'OrderDetail có ProductSizeID NULL: ' + CAST(@NullProductSizeCount AS NVARCHAR(10));

-- Kiểm tra tổng số OrderDetail
DECLARE @TotalOrderDetails INT = (SELECT COUNT(*) FROM OrderDetail);
PRINT 'Tổng số OrderDetail: ' + CAST(@TotalOrderDetails AS NVARCHAR(10));

-- Hiển thị một số record mẫu
PRINT 'Một số OrderDetail mẫu sau migration:';
SELECT TOP 5 
    od.OrderDetailID,
    od.OrderID,
    od.ProductSizeID,
    p.ProductName,
    ps.SizeName,
    ps.Price,
    od.Quantity,
    od.TotalPrice,
    od.[Status]
FROM OrderDetail od
LEFT JOIN ProductSize ps ON od.ProductSizeID = ps.ProductSizeID
LEFT JOIN Product p ON ps.ProductID = p.ProductID
ORDER BY od.OrderDetailID;

-- ===============================
-- 7. OPTIONAL: XÓA CỘT PRODUCTID CŨ (THẬN TRỌNG!)
-- ===============================

-- UNCOMMENT dòng dưới nếu bạn chắc chắn muốn xóa cột ProductID cũ
-- ALTER TABLE OrderDetail DROP COLUMN ProductID;
-- PRINT '⚠️ Đã xóa cột ProductID cũ từ OrderDetail';

PRINT '===============================';
PRINT '✅ HOÀN THÀNH MIGRATION DATABASE';
PRINT '===============================';