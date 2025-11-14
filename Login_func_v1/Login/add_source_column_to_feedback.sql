-- Migration script for Feedback table to support post-payment feedback feature
-- This adds index on OrderID for faster lookups

-- Add index on OrderID for faster lookups when checking if feedback exists for an order
IF NOT EXISTS (
    SELECT * FROM sys.indexes 
    WHERE name = 'IX_Feedback_OrderID' 
    AND object_id = OBJECT_ID('Feedback')
)
BEGIN
    CREATE INDEX IX_Feedback_OrderID 
    ON Feedback(OrderID);
    
    PRINT 'Index on OrderID created successfully';
END
ELSE
BEGIN
    PRINT 'Index on OrderID already exists';
END
GO

-- Add index on CustomerID for faster customer-related queries
IF NOT EXISTS (
    SELECT * FROM sys.indexes 
    WHERE name = 'IX_Feedback_CustomerID' 
    AND object_id = OBJECT_ID('Feedback')
)
BEGIN
    CREATE INDEX IX_Feedback_CustomerID 
    ON Feedback(CustomerID);
    
    PRINT 'Index on CustomerID created successfully';
END
ELSE
BEGIN
    PRINT 'Index on CustomerID already exists';
END
GO

-- Add index on FeedbackDate for faster date-based queries
IF NOT EXISTS (
    SELECT * FROM sys.indexes 
    WHERE name = 'IX_Feedback_FeedbackDate' 
    AND object_id = OBJECT_ID('Feedback')
)
BEGIN
    CREATE INDEX IX_Feedback_FeedbackDate 
    ON Feedback(FeedbackDate);
    
    PRINT 'Index on FeedbackDate created successfully';
END
ELSE
BEGIN
    PRINT 'Index on FeedbackDate already exists';
END
GO

PRINT 'Migration completed successfully - Feedback table is ready for post-payment feedback feature';
