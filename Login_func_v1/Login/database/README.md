# Database Setup for Chatbot

## Hướng dẫn cài đặt Database Schema cho Chatbot

### Yêu cầu
- SQL Server đã được cài đặt và đang chạy
- Database `pizza_demo_DB2` đã tồn tại
- Quyền truy cập để tạo bảng và index

### Cách chạy SQL Script

#### Option 1: Sử dụng SQL Server Management Studio (SSMS)

1. Mở SQL Server Management Studio
2. Kết nối đến server: `localhost:1433`
3. Mở file `chatbot_schema.sql`
4. Đảm bảo database `pizza_demo_DB2` được chọn
5. Click "Execute" hoặc nhấn F5
6. Kiểm tra kết quả trong Messages tab

#### Option 2: Sử dụng sqlcmd (Command Line)

```cmd
sqlcmd -S localhost -U duongbui -P 123 -d pizza_demo_DB2 -i chatbot_schema.sql
```

#### Option 3: Sử dụng Azure Data Studio

1. Mở Azure Data Studio
2. Kết nối đến server
3. Mở file `chatbot_schema.sql`
4. Click "Run" hoặc nhấn F5

### Kiểm tra cài đặt thành công

Sau khi chạy script, bạn có thể kiểm tra bằng các query sau:

```sql
-- Kiểm tra bảng đã được tạo
SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'ChatConversation';

-- Kiểm tra cấu trúc bảng
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ChatConversation';

-- Kiểm tra indexes
SELECT name, type_desc 
FROM sys.indexes 
WHERE object_id = OBJECT_ID('ChatConversation');

-- Kiểm tra foreign key
SELECT 
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS TableName,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS ColumnName,
    OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc 
    ON fk.object_id = fkc.constraint_object_id
WHERE fk.parent_object_id = OBJECT_ID('ChatConversation');
```

### Cấu trúc bảng ChatConversation

| Column | Type | Description |
|--------|------|-------------|
| ConversationID | INT (PK) | ID tự động tăng cho mỗi tin nhắn |
| SessionID | NVARCHAR(100) | ID phiên chat (để nhóm các tin nhắn) |
| UserID | INT (FK, nullable) | ID người dùng (NULL nếu là khách) |
| MessageText | NVARCHAR(MAX) | Nội dung tin nhắn |
| IsUserMessage | BIT | 1 = tin nhắn từ user, 0 = từ bot |
| Intent | NVARCHAR(50) | Ý định được phát hiện |
| Language | NVARCHAR(10) | Ngôn ngữ (vi/en) |
| CreatedAt | DATETIME | Thời gian tạo |

### Indexes được tạo

1. **IX_ChatConversation_SessionID** - Tìm kiếm nhanh theo session
2. **IX_ChatConversation_UserID** - Tìm kiếm theo user
3. **IX_ChatConversation_CreatedAt** - Sắp xếp theo thời gian
4. **IX_ChatConversation_Session_Time** - Composite index cho queries phức tạp
5. **IX_ChatConversation_Intent** - Phân tích intent

### Stored Procedures

#### CleanupOldConversations
Xóa các cuộc hội thoại cũ hơn 90 ngày để tiết kiệm dung lượng.

```sql
-- Chạy cleanup thủ công
EXEC dbo.CleanupOldConversations;

-- Hoặc tạo SQL Server Agent Job để chạy tự động hàng tuần
```

### Test Data (Optional)

Để insert dữ liệu test, uncomment phần "Insert Sample Data" trong file SQL và chạy lại.

### Rollback (Xóa bảng)

Nếu cần xóa bảng và bắt đầu lại:

```sql
DROP TABLE IF EXISTS dbo.ChatConversation;
```

### Troubleshooting

**Lỗi: "Database 'pizza_demo_DB2' does not exist"**
- Kiểm tra tên database trong DBContext.java
- Tạo database nếu chưa có

**Lỗi: "Foreign key constraint failed"**
- Đảm bảo bảng User đã tồn tại
- Kiểm tra column UserID trong bảng User

**Lỗi: "Permission denied"**
- Đảm bảo user có quyền CREATE TABLE
- Chạy với quyền admin nếu cần

### Maintenance

**Backup dữ liệu chat:**
```sql
SELECT * INTO ChatConversation_Backup_20250101
FROM ChatConversation;
```

**Xem thống kê:**
```sql
-- Tổng số tin nhắn
SELECT COUNT(*) AS TotalMessages FROM ChatConversation;

-- Số session
SELECT COUNT(DISTINCT SessionID) AS TotalSessions FROM ChatConversation;

-- Tin nhắn theo ngày
SELECT 
    CAST(CreatedAt AS DATE) AS Date,
    COUNT(*) AS MessageCount
FROM ChatConversation
GROUP BY CAST(CreatedAt AS DATE)
ORDER BY Date DESC;

-- Intent phổ biến nhất
SELECT 
    Intent,
    COUNT(*) AS Count
FROM ChatConversation
WHERE Intent IS NOT NULL
GROUP BY Intent
ORDER BY Count DESC;
```

## Liên hệ

Nếu gặp vấn đề, vui lòng kiểm tra:
1. Connection string trong DBContext.java
2. SQL Server đang chạy
3. Credentials đúng (user: duongbui, password: 123)
