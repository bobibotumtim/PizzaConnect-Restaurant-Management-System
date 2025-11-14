-- Kiểm tra cấu trúc 2 bảng feedback

-- Bảng 1: Feedback (bảng đang được insert vào)
SELECT 'Feedback table structure' as info;
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Feedback'
ORDER BY ORDINAL_POSITION;

-- Bảng 2: customer_feedback (bảng đang được đọc từ view)
SELECT 'customer_feedback table structure' as info;
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'customer_feedback'
ORDER BY ORDINAL_POSITION;

-- Kiểm tra dữ liệu trong bảng Feedback
SELECT 'Data in Feedback table' as info;
SELECT TOP 5 * FROM Feedback ORDER BY FeedbackDate DESC;

-- Kiểm tra dữ liệu trong bảng customer_feedback
SELECT 'Data in customer_feedback table' as info;
SELECT TOP 5 * FROM customer_feedback ORDER BY feedback_date DESC;
