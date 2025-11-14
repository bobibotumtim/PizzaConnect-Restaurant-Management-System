# Hướng dẫn: Xóa dữ liệu cũ và test feedback mới

## Vấn đề hiện tại

1. ✅ Comment không hiển thị rõ ràng → **ĐÃ SỬA**
2. ⚠️ Có dữ liệu feedback cũ/test trong database

## Giải pháp

### Bước 1: Kiểm tra dữ liệu hiện tại

Chạy script để xem feedback hiện có:

```sql
-- File: check_feedback_data.sql
```

Script này sẽ cho bạn biết:

- Tổng số feedback
- Bao nhiêu feedback có comment
- Bao nhiêu feedback không có comment (dữ liệu test)

### Bước 2: Xóa dữ liệu cũ (TÙY CHỌN)

**⚠️ CẢNH BÁO: Thao tác này sẽ XÓA dữ liệu!**

Có 3 options trong file `clean_old_feedback_data.sql`:

**Option 1: Xóa TẤT CẢ feedback** (bắt đầu từ đầu)

```sql
DELETE FROM Feedback;
```

**Option 2: Chỉ xóa feedback không có comment** (khuyến nghị)

```sql
DELETE FROM Feedback
WHERE Comment IS NULL OR Comment = '' OR Comment = '...';
```

**Option 3: Xóa feedback trước một ngày cụ thể**

```sql
DELETE FROM Feedback WHERE FeedbackDate < '2025-01-13';
```

Mở file `clean_old_feedback_data.sql`, uncomment option bạn muốn, và chạy.

### Bước 3: Rebuild và test

1. **Clean and Build** project trong NetBeans
2. **Deploy** lại application
3. **Restart** Tomcat server

### Bước 4: Test feedback flow hoàn chỉnh

#### Test 1: Gửi feedback với comment

1. Login với tài khoản customer
2. Vào **Order History**
3. Click **"Đánh giá"** cho một order
4. Chọn rating: **5 sao**
5. Nhập comment: **"Pizza rất ngon, giao hàng nhanh!"**
6. Click **"Gửi đánh giá"**
7. Kiểm tra thông báo thành công

#### Test 2: Gửi feedback không có comment

1. Click **"Đánh giá"** cho order khác
2. Chọn rating: **3 sao**
3. **Không nhập** comment
4. Click **"Gửi đánh giá"**
5. Kiểm tra thông báo thành công

#### Test 3: Xem feedback trong Manager view

1. Login với tài khoản Manager/Admin
2. Vào **Customer Feedback**
3. Kiểm tra:
   - ✅ Feedback có comment hiển thị đầy đủ trong box "Nhận xét"
   - ✅ Feedback không có comment hiển thị "Không có nhận xét"
   - ✅ Rating (số sao) hiển thị đúng
   - ✅ Order ID hiển thị đúng
   - ✅ Feedback date hiển thị đúng

### Bước 5: Kiểm tra database

```sql
-- Xem feedback mới nhất
SELECT TOP 5
    FeedbackID,
    CustomerID,
    OrderID,
    Rating,
    Comment,
    FeedbackDate
FROM Feedback
ORDER BY FeedbackDate DESC;

-- Kiểm tra VIEW
SELECT TOP 5 * FROM customer_feedback ORDER BY feedback_date DESC;
```

## Các thay đổi đã thực hiện

### 1. CustomerFeedbackSimple.jsp

- ✅ Comment hiển thị trong box riêng với border
- ✅ Có label "Nhận xét:" rõ ràng
- ✅ Xử lý trường hợp không có comment → hiển thị "Không có nhận xét"
- ✅ Xử lý comment = "..." (dữ liệu test cũ)

### 2. Database Scripts

- ✅ `check_feedback_data.sql` - Kiểm tra dữ liệu
- ✅ `clean_old_feedback_data.sql` - Xóa dữ liệu cũ

## Giao diện mới

### Feedback CÓ comment:

```
┌─────────────────────────────────┐
│ Guest Customer                  │
│ ID: C001                        │
│                                 │
│ ⭐⭐⭐⭐⭐                        │
│ Rất hài lòng                    │
│                                 │
│ Order #2                        │
│ Order #2                        │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ Nhận xét:                   │ │
│ │ "Pizza rất ngon, giao hàng  │ │
│ │  nhanh!"                    │ │
│ └─────────────────────────────┘ │
│                                 │
│ 2025-01-13        ⏱ Pending    │
└─────────────────────────────────┘
```

### Feedback KHÔNG có comment:

```
┌─────────────────────────────────┐
│ Guest Customer                  │
│ ID: C002                        │
│                                 │
│ ⭐⭐⭐                           │
│ Bình thường                     │
│                                 │
│ Order #3                        │
│ Order #3                        │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ Nhận xét:                   │ │
│ │ Không có nhận xét           │ │
│ └─────────────────────────────┘ │
│                                 │
│ 2025-01-13        ⏱ Pending    │
└─────────────────────────────────┘
```

## Troubleshooting

### Comment vẫn hiển thị "..."

- Dữ liệu cũ trong database có comment = "..."
- Chạy `clean_old_feedback_data.sql` Option 2 để xóa

### Không thấy feedback mới

- Check console log
- Kiểm tra VIEW: `SELECT * FROM customer_feedback`
- Restart Tomcat

### Lỗi khi xóa dữ liệu

- Kiểm tra có foreign key constraint không
- Backup database trước khi xóa
