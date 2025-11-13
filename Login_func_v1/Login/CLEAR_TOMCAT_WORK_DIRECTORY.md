# Clear Tomcat Work Directory

## Vấn đề

JSP bị cache, thay đổi code không có hiệu lực.

## Giải pháp

### Cách 1: Xóa work directory thủ công

1. Stop Tomcat server
2. Đi đến thư mục Tomcat work directory:
   ```
   C:\Program Files\Apache Software Foundation\Tomcat 10.1_Tomcat10.1\work\Catalina\localhost\Login
   ```
3. Xóa toàn bộ thư mục `Login`
4. Start Tomcat server lại
5. Test lại

### Cách 2: Xóa qua NetBeans

1. Stop Tomcat server
2. Trong NetBeans, click chuột phải vào project `Login`
3. Chọn **Clean**
4. Sau đó chọn **Clean and Build**
5. Deploy lại
6. Start Tomcat server
7. Test lại

### Cách 3: Restart Tomcat và force reload

1. Stop Tomcat
2. Trong NetBeans Services tab:
   - Click chuột phải vào Tomcat server
   - Chọn **Clean Work Directory**
3. Start Tomcat
4. Undeploy application
5. Deploy lại
6. Test

## Sau khi clear cache

Test lại với URL:

```
http://localhost:8080/Login/view/SimpleFeedbackFormV2.jsp?orderId=2
```

Nếu vẫn lỗi, có thể là vấn đề với code. Hãy check console log trong NetBeans.
