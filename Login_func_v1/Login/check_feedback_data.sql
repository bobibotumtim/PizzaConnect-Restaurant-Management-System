-- Kiểm tra dữ liệu feedback hiện tại

-- 1. Xem tất cả feedback với comment
SELECT 
    FeedbackID,
    CustomerID,
    OrderID,
    Rating,
    Comment,
    FeedbackDate
FROM Feedback
ORDER BY FeedbackDate DESC;

-- 2. Đếm feedback có comment và không có comment
SELECT 
    COUNT(*) as total_feedback,
    SUM(CASE WHEN Comment IS NULL OR Comment = '' THEN 1 ELSE 0 END) as empty_comment,
    SUM(CASE WHEN Comment IS NOT NULL AND Comment != '' THEN 1 ELSE 0 END) as has_comment
FROM Feedback;

-- 3. Xem VIEW customer_feedback
SELECT TOP 10 
    feedback_id,
    customer_id,
    order_id,
    rating,
    comment,
    feedback_date
FROM customer_feedback
ORDER BY feedback_date DESC;
