# Clear Tomcat Cache - Fix JSP Compilation Error

## Vấn đề

Lỗi: `ClassNotFoundException: org.apache.jsp.view.FeedbackForm_jsp`

## Nguyên nhân

Tomcat đã cache phiên bản JSP cũ và không thể compile phiên bản mới.

## Giải pháp

### Cách 1: Xóa work directory trong NetBeans

1. Stop Tomcat server
2. Trong NetBeans, mở tab "Services"
3. Expand "Servers" → Right-click "Apache Tomcat"
4. Chọn "Clean Work Directory"
5. Start lại Tomcat

### Cách 2: Xóa thủ công

1. Stop Tomcat server
2. Xóa thư mục: `C:\Users\[YourUsername]\AppData\Local\Temp\[TomcatWorkDir]\`
   Hoặc tìm trong: `[Tomcat Installation]\work\Catalina\localhost\Login\`
3. Xóa thư mục `org` bên trong
4. Start lại Tomcat

### Cách 3: Clean and Build project

1. Trong NetBeans, right-click vào project "Login"
2. Chọn "Clean and Build"
3. Restart Tomcat

### Cách 4: Redeploy project

1. Stop Tomcat
2. Trong NetBeans, right-click project
3. Chọn "Clean"
4. Chọn "Build"
5. Start Tomcat
6. Right-click project → "Run"

## Sau khi clear cache

Test lại bằng cách:

1. Vào Order History
2. Click "Provide Feedback"
3. Form sẽ hiển thị đúng với Order ID

## Nếu vẫn lỗi

Thử truy cập trực tiếp JSP:

```
http://localhost:8080/Login/view/FeedbackForm.jsp?orderId=2
```

Nếu URL này cũng lỗi, có vấn đề với JSP syntax.
Nếu URL này OK, có vấn đề với servlet forward.
