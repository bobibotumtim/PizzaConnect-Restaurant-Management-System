# Feedback Fix Summary

## Vấn đề

- Hệ thống báo thành công nhưng feedback không hiển thị trong view
- Nguyên nhân: Code đang insert vào bảng `Feedback` nhưng view đọc từ bảng `customer_feedback` (không tồn tại)

## Giải pháp

### 1. Thêm cột Comment vào bảng Feedback

Chạy script: `add_comment_to_feedback.sql`

```sql
ALTER TABLE Feedback ADD Comment NVARCHAR(1000) NULL;
```

### 2. Cập nhật CustomerFeedbackDAO

- ✅ `hasFeedbackForOrder()` - Đổi từ `customer_feedback` sang `Feedback`
- ✅ `insertPostPaymentFeedback()` - Insert vào bảng `Feedback`
- ✅ `insertPostPaymentFeedbackWithComment()` - Insert vào `Feedback` với Comment
- ✅ `getFeedbackByOrderId()` - Đọc từ bảng `Feedback`
- ⚠️ CẦN SỬA: Các method khác vẫn đang đọc từ `customer_feedback`

### 3. Cập nhật PostPaymentFeedbackServlet

- ✅ Gọi `insertPostPaymentFeedbackWithComment()` thay vì `insertPostPaymentFeedback()`

### 4. CẦN LÀM TIẾP

Có 2 lựa chọn:

**Option A: Tạo VIEW customer_feedback từ bảng Feedback** (Khuyến nghị)

- Tạo VIEW để map từ Feedback sang customer_feedback
- Không cần sửa code DAO nhiều
- Dễ maintain

**Option B: Sửa toàn bộ DAO**

- Sửa tất cả method trong CustomerFeedbackDAO
- Sửa CustomerFeedback model để map với bảng Feedback
- Tốn nhiều công sửa code

## Khuyến nghị

Chọn Option A - Tạo VIEW để giữ nguyên code hiện tại và dễ maintain.
