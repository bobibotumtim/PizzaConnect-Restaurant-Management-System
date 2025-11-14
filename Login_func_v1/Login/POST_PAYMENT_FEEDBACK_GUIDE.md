# Hướng Dẫn Sử Dụng Post-Payment Feedback Methods

## Tổng Quan

Task 1 đã hoàn thành việc thêm 4 phương thức mới vào `CustomerFeedbackDAO` để hỗ trợ tính năng feedback sau thanh toán.

## Các Phương Thức Mới

### 1. `hasFeedbackForOrder(int orderId)`

Kiểm tra xem một order đã có feedback chưa.

**Tham số:**

- `orderId`: ID của order cần kiểm tra

**Trả về:**

- `true`: Order đã có feedback
- `false`: Order chưa có feedback

**Ví dụ sử dụng:**

```java
CustomerFeedbackDAO dao = new CustomerFeedbackDAO();
int orderId = 123;

if (dao.hasFeedbackForOrder(orderId)) {
    System.out.println("Order này đã có feedback rồi!");
} else {
    System.out.println("Order này chưa có feedback.");
}
```

---

### 2. `getFeedbackByOrderId(int orderId)`

Lấy thông tin feedback của một order.

**Tham số:**

- `orderId`: ID của order

**Trả về:**

- `CustomerFeedback` object nếu tìm thấy
- `null` nếu không tìm thấy

**Ví dụ sử dụng:**

```java
CustomerFeedbackDAO dao = new CustomerFeedbackDAO();
int orderId = 123;

CustomerFeedback feedback = dao.getFeedbackByOrderId(orderId);
if (feedback != null) {
    System.out.println("Rating: " + feedback.getRating() + " stars");
    System.out.println("Feedback Date: " + feedback.getFeedbackDate());
} else {
    System.out.println("Không tìm thấy feedback cho order này.");
}
```

---

### 3. `insertPostPaymentFeedback(String customerId, int orderId, int productId, int rating)`

Thêm feedback mới sau khi khách hàng thanh toán.

**Tham số:**

- `customerId`: ID của khách hàng
- `orderId`: ID của order
- `productId`: ID của sản phẩm
- `rating`: Đánh giá từ 1-5 sao

**Trả về:**

- `true`: Thêm feedback thành công
- `false`: Thất bại (order đã có feedback hoặc rating không hợp lệ)

**Validation:**

- Kiểm tra order đã có feedback chưa (không cho phép duplicate)
- Kiểm tra rating phải từ 1-5

**Ví dụ sử dụng:**

```java
CustomerFeedbackDAO dao = new CustomerFeedbackDAO();

String customerId = "CUST001";
int orderId = 123;
int productId = 1;
int rating = 5;

boolean success = dao.insertPostPaymentFeedback(customerId, orderId, productId, rating);
if (success) {
    System.out.println("Feedback đã được lưu thành công!");
} else {
    System.out.println("Không thể lưu feedback. Order có thể đã có feedback rồi.");
}
```

---

### 4. `canUpdateFeedback(int feedbackId, Timestamp submittedAt)`

Kiểm tra xem feedback có thể được cập nhật không (trong vòng 24 giờ).

**Tham số:**

- `feedbackId`: ID của feedback
- `submittedAt`: Thời gian submit feedback

**Trả về:**

- `true`: Có thể cập nhật (trong vòng 24 giờ)
- `false`: Không thể cập nhật (đã quá 24 giờ hoặc timestamp null)

**Ví dụ sử dụng:**

```java
CustomerFeedbackDAO dao = new CustomerFeedbackDAO();

int feedbackId = 1;
Timestamp submittedAt = feedback.getCreatedAt(); // hoặc getFeedbackDate()

if (dao.canUpdateFeedback(feedbackId, submittedAt)) {
    System.out.println("Feedback có thể được cập nhật.");
    // Cho phép user cập nhật feedback
} else {
    System.out.println("Feedback không thể cập nhật (đã quá 24 giờ).");
    // Hiển thị thông báo cho user
}
```

---

## Database Migration

Chạy file SQL để tối ưu hóa performance:

```bash
sqlcmd -S your_server -d your_database -i add_source_column_to_feedback.sql
```

File này sẽ tạo các index trên:

- `OrderID` - Tăng tốc độ kiểm tra feedback theo order
- `CustomerID` - Tăng tốc độ truy vấn theo khách hàng
- `FeedbackDate` - Tăng tốc độ truy vấn theo ngày

---

## Testing

Để test các phương thức mới, truy cập:

```
http://localhost:8080/your-app/test-post-payment-feedback.jsp
```

---

## Use Case: Tích Hợp Vào Payment Flow

```java
// Trong PaymentServlet hoặc sau khi thanh toán thành công
public void handleSuccessfulPayment(HttpServletRequest request, HttpServletResponse response) {
    // ... xử lý thanh toán ...

    int orderId = Integer.parseInt(request.getParameter("orderId"));
    String customerId = (String) session.getAttribute("customerId");

    // Redirect đến trang feedback
    response.sendRedirect("feedback-form.jsp?orderId=" + orderId);
}

// Trong FeedbackServlet khi user submit feedback
public void doPost(HttpServletRequest request, HttpServletResponse response) {
    CustomerFeedbackDAO dao = new CustomerFeedbackDAO();

    String customerId = (String) session.getAttribute("customerId");
    int orderId = Integer.parseInt(request.getParameter("orderId"));
    int productId = Integer.parseInt(request.getParameter("productId"));
    int rating = Integer.parseInt(request.getParameter("rating"));

    // Kiểm tra xem đã có feedback chưa
    if (dao.hasFeedbackForOrder(orderId)) {
        request.setAttribute("error", "Bạn đã gửi feedback cho đơn hàng này rồi!");
        request.getRequestDispatcher("feedback-form.jsp").forward(request, response);
        return;
    }

    // Thêm feedback mới
    boolean success = dao.insertPostPaymentFeedback(customerId, orderId, productId, rating);

    if (success) {
        request.setAttribute("message", "Cảm ơn bạn đã gửi feedback!");
        response.sendRedirect("order-success.jsp");
    } else {
        request.setAttribute("error", "Có lỗi xảy ra. Vui lòng thử lại!");
        request.getRequestDispatcher("feedback-form.jsp").forward(request, response);
    }
}
```

---

## Requirements Đã Đáp Ứng

✅ **Requirement 3.1**: Kiểm tra duplicate feedback với `hasFeedbackForOrder()`  
✅ **Requirement 3.2**: Lấy feedback theo order với `getFeedbackByOrderId()`  
✅ **Requirement 7.1**: Thêm feedback sau thanh toán với `insertPostPaymentFeedback()`  
✅ **Requirement 7.4**: Kiểm tra thời gian cập nhật với `canUpdateFeedback()`

---

## Lưu Ý

1. **Duplicate Prevention**: Phương thức `insertPostPaymentFeedback()` tự động kiểm tra duplicate
2. **Rating Validation**: Rating phải từ 1-5, nếu không sẽ trả về false
3. **24-Hour Rule**: Feedback chỉ có thể cập nhật trong vòng 24 giờ sau khi submit
4. **Database Indexes**: Nhớ chạy migration script để tối ưu performance

---

## Next Steps

Các task tiếp theo sẽ xây dựng:

- UI form để khách hàng nhập feedback
- Servlet xử lý submit feedback
- Tích hợp vào payment flow
- Tính năng cập nhật feedback trong 24 giờ
