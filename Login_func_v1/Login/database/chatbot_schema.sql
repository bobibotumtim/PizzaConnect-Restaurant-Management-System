-- =============================================
-- Chatbot Database Schema
-- PizzaConnect Restaurant Management System
-- =============================================

USE pizza_demo_DB2;
GO

-- =============================================
-- Drop existing table if exists (for development)
-- =============================================
IF OBJECT_ID('dbo.ChatConversation', 'U') IS NOT NULL
    DROP TABLE dbo.ChatConversation;
GO

-- =============================================
-- Create ChatConversation Table
-- Stores all chat messages between customers and the AI assistant
-- =============================================
CREATE TABLE dbo.ChatConversation (
    ConversationID INT IDENTITY(1,1) PRIMARY KEY,
    SessionID NVARCHAR(100) NOT NULL,
    UserID INT NULL,  -- NULL if customer is not logged in (guest)
    MessageText NVARCHAR(MAX) NOT NULL,
    IsUserMessage BIT NOT NULL,  -- 1 = message from user, 0 = message from assistant
    Intent NVARCHAR(50) NULL,  -- Detected intent (menu_inquiry, order_status, etc.)
    Language NVARCHAR(10) DEFAULT 'vi',  -- Message language (vi = Vietnamese, en = English)
    CreatedAt DATETIME DEFAULT GETDATE(),
    
    -- Foreign key constraint to User table
    CONSTRAINT FK_ChatConversation_User FOREIGN KEY (UserID) 
        REFERENCES [User](UserID) ON DELETE SET NULL
);
GO

-- =============================================
-- Create Indexes for Performance
-- =============================================

-- Index on SessionID for fast conversation history retrieval
CREATE NONCLUSTERED INDEX IX_ChatConversation_SessionID 
ON dbo.ChatConversation(SessionID)
INCLUDE (MessageText, IsUserMessage, CreatedAt);
GO

-- Index on UserID for user-specific analytics
CREATE NONCLUSTERED INDEX IX_ChatConversation_UserID 
ON dbo.ChatConversation(UserID)
WHERE UserID IS NOT NULL;
GO

-- Index on CreatedAt for time-based queries and cleanup
CREATE NONCLUSTERED INDEX IX_ChatConversation_CreatedAt 
ON dbo.ChatConversation(CreatedAt DESC);
GO

-- Composite index for session-based queries with time ordering
CREATE NONCLUSTERED INDEX IX_ChatConversation_Session_Time 
ON dbo.ChatConversation(SessionID, CreatedAt DESC);
GO

-- Index on Intent for analytics
CREATE NONCLUSTERED INDEX IX_ChatConversation_Intent 
ON dbo.ChatConversation(Intent)
WHERE Intent IS NOT NULL;
GO

-- =============================================
-- Verify Table Creation
-- =============================================
IF OBJECT_ID('dbo.ChatConversation', 'U') IS NOT NULL
    PRINT 'ChatConversation table created successfully';
ELSE
    PRINT 'ERROR: ChatConversation table creation failed';
GO

-- =============================================
-- Display Table Structure
-- =============================================
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ChatConversation'
ORDER BY ORDINAL_POSITION;
GO

-- =============================================
-- Display Indexes
-- =============================================
SELECT 
    i.name AS IndexName,
    i.type_desc AS IndexType,
    COL_NAME(ic.object_id, ic.column_id) AS ColumnName
FROM sys.indexes i
INNER JOIN sys.index_columns ic 
    ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE i.object_id = OBJECT_ID('dbo.ChatConversation')
ORDER BY i.name, ic.key_ordinal;
GO

-- =============================================
-- Insert Sample Data for Testing (Optional)
-- =============================================
-- Uncomment to insert test data

/*
-- Sample conversation for testing
DECLARE @TestSessionID NVARCHAR(100) = 'test-session-' + CONVERT(NVARCHAR(50), NEWID());

INSERT INTO dbo.ChatConversation (SessionID, UserID, MessageText, IsUserMessage, Intent, Language)
VALUES 
    (@TestSessionID, NULL, N'Xin chào', 1, 'greeting', 'vi'),
    (@TestSessionID, NULL, N'Xin chào! Tôi là trợ lý ảo của PizzaConnect. Tôi có thể giúp gì cho bạn?', 0, 'greeting', 'vi'),
    (@TestSessionID, NULL, N'Cho tôi xem menu', 1, 'menu_inquiry', 'vi'),
    (@TestSessionID, NULL, N'Dạ, đây là menu của chúng tôi...', 0, 'menu_inquiry', 'vi');

PRINT 'Sample data inserted with SessionID: ' + @TestSessionID;

-- Verify sample data
SELECT * FROM dbo.ChatConversation WHERE SessionID = @TestSessionID;
*/

-- =============================================
-- Cleanup Procedure (Optional)
-- Delete conversations older than 90 days
-- =============================================
CREATE OR ALTER PROCEDURE dbo.CleanupOldConversations
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @DeletedRows INT;
    DECLARE @CutoffDate DATETIME = DATEADD(DAY, -90, GETDATE());
    
    DELETE FROM dbo.ChatConversation
    WHERE CreatedAt < @CutoffDate;
    
    SET @DeletedRows = @@ROWCOUNT;
    
    PRINT 'Deleted ' + CAST(@DeletedRows AS NVARCHAR(10)) + ' old conversation records';
END;
GO

PRINT 'Chatbot schema setup completed successfully!';
GO
