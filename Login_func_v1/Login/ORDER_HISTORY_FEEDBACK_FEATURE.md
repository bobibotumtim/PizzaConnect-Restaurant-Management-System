# Order History Feedback Feature

## 📋 Tổng quan

Feature này cho phép khách hàng có thể gửi feedback cho các đơn hàng đã hoàn thành từ trang Order History của họ.

## ✨ Tính năng

### 1. **Feedback Button trong Order History**

- Hiển thị button "Provide Feedback" cho các đơn hàng đã hoàn thành (status = 3) và đã thanh toán
- Chỉ hiển thị nếu order chưa có feedback
- Nếu đã có feedback, hiển thị "Feedback Submitted" với button "View Feedback"

### 2. **Feedback Form**

- Cho phép customer đánh giá từ 1-5 sao
- Có thể thêm comment (tùy chọn, tối đa 500 ký tự)
- Hiển thị thông báo đặc biệt cho rating thấp (≤3 sao)
- Submit feedback qua AJAX

### 3. **View Feedback**

- Khách hàng có thể xem lại feedback đã gửi
- Hiển thị rating và ngày gửi feedback
- Không cho phép chỉnh sửa sau khi đã gửi

## 🔧 Files đã thay đổi

### 1. **OrderHistory.jsp**

```
Login_func_v1/Login/web/view/OrderHistory.jsp
```

**Thay đổi:**

- Thêm import `dao.CustomerFeedbackDAO`
- Thêm section "Feedback" vào mỗi order card
- Kiểm tra xem order đã có feedback chưa bằng `hasFeedbackForOrder()`
- Hiển thị button "Provide Feedback" hoặc "View Feedback" tùy trạng thái

### 2. **FeedbackFormServlet.java**

```
Login_func_v1/Login/src/java/controller/FeedbackFormServlet.java
```

**Thay đổi:**

- Thêm `CustomerFeedbackDAO` và `OrderDAO`
- Kiểm tra xem order đã có feedback chưa
- Nếu có feedback → set `viewMode = true` và load existing feedback
- Nếu chưa có → set `viewMode = false` để hiển thị form
- Load thông tin order để hiển thị

### 3. **FeedbackForm.jsp**

```
Login_func_v1/Login/web/view/FeedbackForm.jsp
```

**Thay đổi:**

- Hỗ trợ 2 modes: View Mode và Submit Mode
- **View Mode**: Hiển thị feedback đã submit (read-only)
- **Submit Mode**: Hiển thị form để gửi feedback mới
- Sử dụng JSP scriptlet để kiểm tra mode

## 🎯 User Flow

### Flow 1: Gửi Feedback mới

```
Order History → Click "Provide Feedback"
→ Feedback Form (Submit Mode)
→ Chọn rating & nhập comment
→ Submit
→ Feedback Confirmation
→ Back to Order History
```

### Flow 2: Xem Feedback đã gửi

```
Order History → Click "View Feedback"
→ Feedback Form (View Mode)
→ Hiển thị rating đã gửi
→ Back to Order History
```

## 🔍 Logic kiểm tra Feedback

### Trong OrderHistory.jsp:

```java
dao.CustomerFeedbackDAO feedbackDAO = new dao.CustomerFeedbackDAO();
boolean hasFeedback = feedbackDAO.hasFeedbackForOrder(order.getOrderID());

if (!hasFeedback) {
    // Hiển thị button "Provide Feedback"
} else {
    // Hiển thị "Feedback Submitted" + button "View Feedback"
}
```

### Trong FeedbackFormServlet:

```java
boolean hasFeedback = feedbackDAO.hasFeedbackForOrder(orderId);

if (hasFeedback) {
    CustomerFeedback existingFeedback = feedbackDAO.getFeedbackByOrderId(orderId);
    request.setAttribute("existingFeedback", existingFeedback);
    request.setAttribute("viewMode", true);
} else {
    request.setAttribute("viewMode", false);
}
```

## 🎨 UI/UX

### Feedback Button (Chưa có feedback)

- Background: Gradient vàng-cam
- Icon: ⭐ sao
- Text: "How was your experience?" + "Provide Feedback"
- Hover effect: Shadow tăng lên

### Feedback Submitted (Đã có feedback)

- Background: Gradient xanh lá
- Icon: ✅ checkmark
- Text: "Feedback Submitted" + "View Feedback"
- Button màu xanh lá

### View Mode

- Hiển thị rating dưới dạng sao (read-only)
- Hiển thị text mô tả rating
- Hiển thị ngày gửi feedback
- Button "Quay lại lịch sử đơn hàng"

## 📱 Responsive Design

- Mobile-friendly với Tailwind CSS
- Touch-friendly buttons (min 44x44px)
- Responsive layout cho các màn hình nhỏ
- Icons và text rõ ràng

## 🔐 Security & Validation

### Server-side:

- Kiểm tra order tồn tại
- Kiểm tra order thuộc về customer đang login
- Validate rating (1-5)
- Validate comment length (max 500 chars)
- Prevent duplicate feedback

### Client-side:

- Required rating selection
- Character counter cho comment
- AJAX submission với error handling

## 🚀 Testing

### Test Cases:

1. **Test hiển thị button trong Order History**

   - ✅ Order đã hoàn thành + paid → hiển thị "Provide Feedback"
   - ✅ Order đã có feedback → hiển thị "View Feedback"
   - ✅ Order chưa hoàn thành → không hiển thị button

2. **Test Feedback Form**

   - ✅ Click "Provide Feedback" → mở form submit mode
   - ✅ Click "View Feedback" → mở form view mode
   - ✅ Submit feedback thành công
   - ✅ Không cho submit duplicate feedback

3. **Test View Mode**
   - ✅ Hiển thị đúng rating đã gửi
   - ✅ Hiển thị ngày gửi feedback
   - ✅ Button "Quay lại" hoạt động

## 📊 Database

### Sử dụng bảng `Feedback`:

```sql
- FeedbackID (PK)
- CustomerID
- OrderID
- ProductID
- Rating (1-5)
- FeedbackDate
```

### Methods sử dụng:

- `hasFeedbackForOrder(int orderId)` - Kiểm tra order đã có feedback
- `getFeedbackByOrderId(int orderId)` - Lấy feedback theo order ID
- `insertPostPaymentFeedback(...)` - Insert feedback mới

## 🎉 Benefits

1. **Cho Customer:**

   - Dễ dàng gửi feedback từ order history
   - Có thể xem lại feedback đã gửi
   - Không cần phải gửi feedback ngay sau thanh toán

2. **Cho Business:**
   - Tăng tỷ lệ feedback từ customers
   - Dữ liệu feedback liên kết với order cụ thể
   - Dễ dàng theo dõi và phản hồi feedback

## 🔄 Integration với Post-Payment Feedback

Feature này hoạt động song song với post-payment feedback:

- **Post-payment**: Feedback ngay sau thanh toán (optional)
- **Order History**: Feedback bất cứ lúc nào từ order history

Cả 2 đều sử dụng:

- Cùng database table (Feedback)
- Cùng DAO methods
- Cùng validation logic
- Cùng UI components (FeedbackForm.jsp)

## 📝 Notes

- Feature này không thay thế post-payment feedback, mà bổ sung thêm cách thức gửi feedback
- Customer có thể chọn gửi feedback ngay sau thanh toán hoặc sau đó từ order history
- Mỗi order chỉ có thể có 1 feedback duy nhất (duplicate prevention)
- Feedback không thể chỉnh sửa sau khi đã gửi (có thể thêm feature này sau)

## ✅ Status

**COMPLETED** - Feature đã được implement và sẵn sàng để test.

---

**Created:** 2024
**Last Updated:** 2024
**Author:** Kiro AI Assistant
