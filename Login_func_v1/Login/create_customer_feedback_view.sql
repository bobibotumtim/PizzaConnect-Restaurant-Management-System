-- Tạo VIEW customer_feedback từ bảng Feedback
-- VIEW này giúp map dữ liệu từ bảng Feedback sang format mà code hiện tại đang dùng

-- Drop view nếu đã tồn tại
IF OBJECT_ID('customer_feedback', 'V') IS NOT NULL
    DROP VIEW customer_feedback;
GO

-- Tạo VIEW đơn giản không JOIN (để tránh lỗi tên cột)
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
    '' as response,
    0 as has_response,
    FeedbackDate as created_at,
    FeedbackDate as updated_at
FROM Feedback;
GO

-- Kiểm tra VIEW
SELECT TOP 5 * FROM customer_feedback ORDER BY feedback_date DESC;
GO

PRINT 'customer_feedback VIEW created successfully';
