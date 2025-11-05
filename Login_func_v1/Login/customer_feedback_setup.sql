-- Customer Feedback System Database Setup
-- Run this script to create the customer_feedback table and related components

USE pizza_demo_DB_Merged;
GO

-- 1. Create customer_feedback table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='customer_feedback' AND xtype='U')
BEGIN
    CREATE TABLE customer_feedback (
        feedback_id INT PRIMARY KEY IDENTITY(1,1),
        customer_id VARCHAR(50) NOT NULL,
        customer_name NVARCHAR(100) NOT NULL,
        order_id INT NOT NULL,
        order_date DATE NOT NULL,
        order_time TIME NOT NULL,
        rating INT CHECK (rating >= 1 AND rating <= 5) NOT NULL,
        comment NVARCHAR(1000),
        feedback_date DATE NOT NULL,
        pizza_ordered NVARCHAR(200),
        response NVARCHAR(1000),
        has_response BIT DEFAULT 0,
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE()
    );
    PRINT '✅ customer_feedback table created successfully';
END
ELSE
BEGIN
    PRINT '✅ customer_feedback table already exists';
END

-- 2. Create indexes for better performance
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_customer_feedback_customer_id')
BEGIN
    CREATE INDEX IX_customer_feedback_customer_id ON customer_feedback(customer_id);
    PRINT '✅ Index on customer_id created';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_customer_feedback_order_id')
BEGIN
    CREATE INDEX IX_customer_feedback_order_id ON customer_feedback(order_id);
    PRINT '✅ Index on order_id created';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_customer_feedback_rating')
BEGIN
    CREATE INDEX IX_customer_feedback_rating ON customer_feedback(rating);
    PRINT '✅ Index on rating created';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_customer_feedback_has_response')
BEGIN
    CREATE INDEX IX_customer_feedback_has_response ON customer_feedback(has_response);
    PRINT '✅ Index on has_response created';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_customer_feedback_feedback_date')
BEGIN
    CREATE INDEX IX_customer_feedback_feedback_date ON customer_feedback(feedback_date);
    PRINT '✅ Index on feedback_date created';
END

-- 3. Insert sample data for testing
IF NOT EXISTS (SELECT * FROM customer_feedback)
BEGIN
    INSERT INTO customer_feedback (
        customer_id, customer_name, order_id, order_date, order_time, 
        rating, comment, feedback_date, pizza_ordered, response, has_response
    ) VALUES 
    -- Positive feedback with responses
    ('CUST001', N'Nguyễn Văn An', 1001, '2024-11-01', '12:30:00', 5, 
     N'Pizza rất ngon, dịch vụ tuyệt vời! Tôi sẽ quay lại.', '2024-11-01', 
     N'Margherita Pizza (Large), Pepperoni Pizza (Medium)', 
     N'Cảm ơn bạn đã đánh giá tích cực! Chúng tôi rất vui khi bạn hài lòng với dịch vụ.', 1),
    
    ('CUST002', N'Trần Thị Bình', 1002, '2024-11-01', '18:45:00', 4, 
     N'Pizza ngon, nhưng thời gian chờ hơi lâu. Nhân viên thân thiện.', '2024-11-01', 
     N'Hawaiian Pizza (Large), Coca Cola (2)', 
     N'Cảm ơn phản hồi của bạn. Chúng tôi sẽ cải thiện thời gian phục vụ.', 1),
    
    -- Pending responses
    ('CUST003', N'Lê Văn Cường', 1003, '2024-11-02', '19:20:00', 3, 
     N'Pizza ổn nhưng không đặc biệt. Giá hơi cao so với chất lượng.', '2024-11-02', 
     N'BBQ Chicken Pizza (Medium), French Fries', NULL, 0),
    
    ('CUST004', N'Phạm Thị Dung', 1004, '2024-11-02', '20:15:00', 2, 
     N'Pizza bị cháy một chút, nước uống không đủ lạnh. Cần cải thiện.', '2024-11-02', 
     N'Veggie Supreme (Large), Sprite (2)', NULL, 0),
    
    -- More positive feedback
    ('CUST005', N'Hoàng Văn Em', 1005, '2024-11-03', '13:00:00', 5, 
     N'Tuyệt vời! Pizza Four Cheese rất đậm đà, nhân viên phục vụ chu đáo.', '2024-11-03', 
     N'Four Cheese Pizza (Large), Garlic Bread', 
     N'Rất cảm ơn! Chúng tôi luôn cố gắng mang đến trải nghiệm tốt nhất.', 1),
    
    ('CUST006', N'Võ Thị Phương', 1006, '2024-11-03', '14:30:00', 4, 
     N'Pizza ngon, không gian thoải mái. Sẽ giới thiệu cho bạn bè.', '2024-11-03', 
     N'Meat Lovers Pizza (Medium), Orange Juice', 
     N'Cảm ơn bạn! Chúng tôi rất mong được phục vụ bạn và bạn bè trong tương lai.', 1),
    
    -- Recent feedback needing attention
    ('CUST007', N'Đặng Văn Giang', 1007, '2024-11-04', '19:45:00', 1, 
     N'Rất thất vọng! Pizza lạnh, dịch vụ chậm, nhân viên không thân thiện.', '2024-11-04', 
     N'Seafood Special Pizza (Large), Iced Tea', NULL, 0),
    
    ('CUST008', N'Bùi Thị Hoa', 1008, '2024-11-04', '21:00:00', 5, 
     N'Xuất sắc! Mọi thứ đều hoàn hảo. Đây là lần thứ 3 tôi đến và luôn hài lòng.', '2024-11-04', 
     N'Margherita Pizza (Medium), Tiramisu, Coffee', NULL, 0),
    
    -- Mixed ratings
    ('CUST009', N'Ngô Văn Inh', 1009, '2024-11-05', '12:15:00', 3, 
     N'Pizza ổn, nhưng không gian hơi ồn. Giá cả hợp lý.', '2024-11-05', 
     N'Pepperoni Pizza (Small), Chicken Wings', NULL, 0),
    
    ('CUST010', N'Lý Thị Kim', 1010, '2024-11-05', '13:45:00', 4, 
     N'Dịch vụ tốt, pizza ngon. Chỉ mong có thêm nhiều lựa chọn topping.', '2024-11-05', 
     N'Hawaiian Pizza (Medium), Caesar Salad, Pepsi', NULL, 0);

    PRINT '✅ Sample feedback data inserted successfully';
    PRINT '   - Total records: 10';
    PRINT '   - Responded: 4 records';
    PRINT '   - Pending response: 6 records';
    PRINT '   - Rating distribution: 1★(1), 2★(1), 3★(2), 4★(3), 5★(3)';
END
ELSE
BEGIN
    PRINT '✅ Sample data already exists';
END

-- 4. Display summary statistics
DECLARE @TotalFeedback INT = (SELECT COUNT(*) FROM customer_feedback);
DECLARE @AvgRating DECIMAL(3,1) = (SELECT ROUND(AVG(CAST(rating AS FLOAT)), 1) FROM customer_feedback);
DECLARE @PendingCount INT = (SELECT COUNT(*) FROM customer_feedback WHERE has_response = 0);
DECLARE @PositiveCount INT = (SELECT COUNT(*) FROM customer_feedback WHERE rating >= 4);
DECLARE @PositiveRate INT = CASE WHEN @TotalFeedback > 0 THEN (@PositiveCount * 100 / @TotalFeedback) ELSE 0 END;

PRINT '';
PRINT '📊 Customer Feedback System Statistics:';
PRINT '   Total Feedback: ' + CAST(@TotalFeedback AS VARCHAR(10));
PRINT '   Average Rating: ' + CAST(@AvgRating AS VARCHAR(10)) + '/5.0';
PRINT '   Positive Rate: ' + CAST(@PositiveRate AS VARCHAR(10)) + '% (4-5 stars)';
PRINT '   Pending Responses: ' + CAST(@PendingCount AS VARCHAR(10));
PRINT '';
PRINT '🎉 Customer Feedback System database setup completed successfully!';