# Final Fix: Order ID Error

## Vấn đề

Form gửi orderId=11 nhưng servlet báo "Order ID không được để trống"

## Nguyên nhân có thể

1. Browser cache error response cũ
2. Tomcat cache JSP cũ
3. Filter đang chặn request

## Giải pháp cuối cùng

### Bước 1: Clear tất cả cache

```
1. Stop Tomcat
2. Xóa: C:\Program Files\Apache Software Foundation\Tomcat 10.1_Tomcat10.1\work\Catalina\localhost\Login
3. Clear browser cache: Ctrl + Shift + Delete
4. Clean and Build project
5. Start Tomcat
```

### Bước 2: Test với Incognito window

- Mở Incognito: Ctrl + Shift + N
- Truy cập: http://localhost:8080/Login/view/SimpleFeedbackForm.jsp?orderId=11
- Chọn rating và nhập comment
- Click "Gửi đánh giá"
- Mở Console (F12) và check:
  - Form data có orderId không?
  - Network tab có request đến /submit-feedback không?
  - Response là gì?

### Bước 3: Check NetBeans console

Sau khi submit, check NetBeans console xem có log này không:

```
DEBUG PostPaymentFeedbackServlet - orderIdParam: '11'
DEBUG PostPaymentFeedbackServlet - ratingParam: '4'
```

Nếu KHÔNG có log này → Request không đến servlet
Nếu CÓ log nhưng vẫn lỗi → Validation logic sai

### Bước 4: Nếu vẫn lỗi

Có thể là do RoleFilter. Hãy tạm thời disable filter:

1. Mở web.xml
2. Comment out RoleFilter mapping cho /submit-feedback
3. Rebuild và test lại

Hoặc thử URL trực tiếp không qua form:

```
POST http://localhost:8080/Login/submit-feedback
Body: orderId=11&rating=4&productId=1&comment=test
```

Dùng Postman hoặc curl để test.
