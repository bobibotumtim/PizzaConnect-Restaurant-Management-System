# Fix: Feedback không hiển thị trong view

## Vấn đề

Hệ thống báo "Feedback submitted successfully" nhưng feedback không hiển thị trong Customer Feedback view và không có trong database.

## Nguyên nhân

- Code insert vào bảng `Feedback`
- Code đọc từ bảng `customer_feedback` (không tồn tại)
- Bảng `Feedback` thiếu cột `Comment` để lưu nội dung feedback

## Giải pháp

### Bước 1: Thêm cột Comment vào bảng Feedback

Chạy script SQL:

```bash
# Trong SQL Server Management Studio hoặc Azure Data Studio
# Mở và chạy file: add_comment_to_feedback.sql
```

Script sẽ:

- Thêm cột `Comment NVARCHAR(1000) NULL` vào bảng `Feedback`
- Kiểm tra xem cột đã tồn tại chưa trước khi thêm

### Bước 2: Tạo VIEW customer_feedback

Chạy script SQL:

```bash
# Mở và chạy file: create_customer_feedback_view.sql
```

Script sẽ:

- Tạo VIEW `customer_feedback` từ bảng `Feedback`
- Map các cột từ `Feedback` sang format mà code đang dùng
- JOIN với bảng `Customer` và `Order` để lấy thông tin đầy đủ

### Bước 3: Rebuild và Deploy

```bash
# Clean và rebuild project
1. Clean and Build trong NetBeans
2. Deploy lại application lên Tomcat
3. Restart Tomcat server
```

### Bước 4: Test

1. Vào Order History
2. Click "Đánh giá" cho một order
3. Chọn rating và nhập comment
4. Submit feedback
5. Vào Customer Feedback view để kiểm tra

## Các file đã được cập nhật

### 1. CustomerFeedbackDAO.java

- ✅ `hasFeedbackForOrder()` - Kiểm tra từ bảng `Feedback`
- ✅ `insertPostPaymentFeedback()` - Insert vào `Feedback`
- ✅ `insertPostPaymentFeedbackWithComment()` - Insert vào `Feedback` với Comment
- ✅ `getFeedbackByOrderId()` - Đọc từ bảng `Feedback`

### 2. PostPaymentFeedbackServlet.java

- ✅ Gọi `insertPostPaymentFeedbackWithComment()` để lưu cả comment

### 3. Database Scripts

- ✅ `add_comment_to_feedback.sql` - Thêm cột Comment
- ✅ `create_customer_feedback_view.sql` - Tạo VIEW

## Kiểm tra sau khi fix

### Kiểm tra cấu trúc bảng

```sql
-- Kiểm tra cột Comment đã được thêm
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Feedback'
ORDER BY ORDINAL_POSITION;
```

### Kiểm tra VIEW

```sql
-- Kiểm tra VIEW customer_feedback
SELECT * FROM customer_feedback ORDER BY feedback_date DESC;
```

### Kiểm tra dữ liệu

```sql
-- Kiểm tra feedback mới nhất
SELECT TOP 5
    FeedbackID, CustomerID, OrderID, Rating, Comment, FeedbackDate
FROM Feedback
ORDER BY FeedbackDate DESC;
```

## Lưu ý

- VIEW `customer_feedback` sẽ tự động cập nhật khi có dữ liệu mới trong bảng `Feedback`
- Không cần sửa code Java nữa vì VIEW đã map đúng format
- Nếu cần thêm cột mới, chỉ cần update VIEW

## Troubleshooting

### Nếu vẫn không hiển thị

1. Kiểm tra VIEW đã được tạo: `SELECT * FROM customer_feedback`
2. Kiểm tra dữ liệu trong bảng Feedback: `SELECT * FROM Feedback`
3. Clear Tomcat cache và restart
4. Check console log để xem có lỗi SQL không

### Nếu lỗi "Invalid column name 'Comment'"

- Chạy lại script `add_comment_to_feedback.sql`
- Kiểm tra cột đã được thêm vào bảng Feedback

### Nếu lỗi "Invalid object name 'customer_feedback'"

- Chạy lại script `create_customer_feedback_view.sql`
- Kiểm tra VIEW đã được tạo: `SELECT * FROM sys.views WHERE name = 'customer_feedback'`
