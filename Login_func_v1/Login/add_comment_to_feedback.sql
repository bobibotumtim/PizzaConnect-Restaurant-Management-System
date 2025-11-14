-- Thêm cột Comment vào bảng Feedback để lưu nội dung feedback từ khách hàng

-- Kiểm tra xem cột Comment đã tồn tại chưa
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'Feedback' AND COLUMN_NAME = 'Comment'
)
BEGIN
    -- Thêm cột Comment (NVARCHAR để hỗ trợ tiếng Việt, max 1000 ký tự)
    ALTER TABLE Feedback
    ADD Comment NVARCHAR(1000) NULL;
    
    PRINT 'Added Comment column to Feedback table successfully';
END
ELSE
BEGIN
    PRINT 'Comment column already exists in Feedback table';
END
GO

-- Kiểm tra kết quả
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Feedback'
ORDER BY ORDINAL_POSITION;
