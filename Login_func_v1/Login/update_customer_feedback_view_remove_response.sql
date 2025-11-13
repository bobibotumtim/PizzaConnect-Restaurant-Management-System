-- Cập nhật VIEW customer_feedback - Xóa cột response và has_response
-- Vì không có role nào sử dụng chức năng phản hồi feedback

-- Drop view nếu đã tồn tại
IF OBJECT_ID('customer_feedback', 'V') IS NOT NULL
    DROP VIEW customer_feedback;
GO

-- Tạo lại VIEW không có cột response và has_response
CREATE VIEW customer_feedback AS
SELECT 
    FeedbackID as feedback_id,
    CustomerID as customer_id,
    'Guest Customer' as customer_name,
    OrderID as order_id,
    FeedbackDate as order_date,
    CAST(FeedbackDate AS TIME) as order_time,
    Rating as rating,
    COALESCE(Comment, '') as comment,
    FeedbackDate as feedback_date,
    'Order #' + CAST(OrderID AS VARCHAR) as pizza_ordered,
    FeedbackDate as created_at,
    FeedbackDate as updated_at
FROM Feedback;
GO

-- Kiểm tra VIEW
SELECT TOP 5 * FROM customer_feedback ORDER BY feedback_date DESC;
GO

PRINT 'customer_feedback VIEW updated successfully - removed response and has_response columns';

