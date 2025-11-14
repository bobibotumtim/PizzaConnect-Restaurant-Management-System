-- Script để xóa dữ liệu feedback cũ/test

-- CẢNH BÁO: Script này sẽ XÓA TẤT CẢ feedback hiện có
-- Chỉ chạy nếu bạn chắc chắn muốn xóa dữ liệu cũ

-- Option 1: Xóa TẤT CẢ feedback (nếu muốn bắt đầu từ đầu)
-- DELETE FROM Feedback;
-- PRINT 'All feedback deleted';

-- Option 2: Chỉ xóa feedback không có comment (dữ liệu test/cũ)
DELETE FROM Feedback 
WHERE Comment IS NULL OR Comment = '' OR Comment = '...';
PRINT 'Old feedback without comments deleted';

-- Option 3: Chỉ xóa feedback từ trước một ngày cụ thể
-- DELETE FROM Feedback WHERE FeedbackDate < '2025-01-13';
-- PRINT 'Old feedback before 2025-01-13 deleted';

-- Kiểm tra kết quả
SELECT 
    COUNT(*) as remaining_feedback,
    MIN(FeedbackDate) as oldest_feedback,
    MAX(FeedbackDate) as newest_feedback
FROM Feedback;

-- Xem feedback còn lại
SELECT * FROM Feedback ORDER BY FeedbackDate DESC;
