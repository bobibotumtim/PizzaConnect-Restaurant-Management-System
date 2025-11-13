-- Kiểm tra cấu trúc các bảng liên quan

-- Kiểm tra bảng Customer
SELECT 'Customer table columns:' as info;
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Customer'
ORDER BY ORDINAL_POSITION;

-- Kiểm tra bảng Order
SELECT 'Order table columns:' as info;
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Order'
ORDER BY ORDINAL_POSITION;

-- Kiểm tra bảng Feedback
SELECT 'Feedback table columns:' as info;
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Feedback'
ORDER BY ORDINAL_POSITION;

-- Xem dữ liệu mẫu
SELECT TOP 2 * FROM Customer;
SELECT TOP 2 * FROM [Order];
SELECT TOP 2 * FROM Feedback;
