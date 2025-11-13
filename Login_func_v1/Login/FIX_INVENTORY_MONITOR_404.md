# Fix Inventory Monitor 404 Error

## Vấn đề

Không thể truy cập `/inventory-monitor` - gặp lỗi 404

## Nguyên nhân đã kiểm tra

✅ Servlet mapping đã được cấu hình đúng trong web.xml
✅ InventoryMonitorServlet.java không có lỗi compile
✅ InventoryMonitorServlet.class đã được build
✅ InventoryMonitorDAO.class đã được build
✅ InventoryMonitorItem.class đã được build
✅ Login.war file đã được tạo

## Giải pháp

### Bước 1: Stop Tomcat Server

- Trong NetBeans: Click Stop button hoặc right-click server → Stop

### Bước 2: Clean Project

- Right-click vào project "Login" → Clean

### Bước 3: Build Project

- Right-click vào project "Login" → Build

### Bước 4: Undeploy (nếu cần)

- Right-click vào server → Undeploy → Chọn "Login"

### Bước 5: Start Server

- Right-click vào server → Start

### Bước 6: Deploy lại

- Right-click vào project "Login" → Run
- Hoặc: Right-click vào server → Deploy → Chọn Login.war

### Bước 7: Test

Truy cập: `http://localhost:8080/Login/inventory-monitor`

## Nếu vẫn lỗi 404

### Kiểm tra server logs

Xem trong tab "Output" của NetBeans, tìm các lỗi liên quan đến:

- ClassNotFoundException
- NoClassDefFoundError
- ServletException

### Kiểm tra deployed files

Vào thư mục Tomcat webapps:

```
C:\Program Files\Apache Software Foundation\Tomcat 10.1\webapps\Login\WEB-INF\classes\controller\
```

Kiểm tra xem có file `InventoryMonitorServlet.class` không

### Kiểm tra web.xml trong deployed app

```
C:\Program Files\Apache Software Foundation\Tomcat 10.1\webapps\Login\WEB-INF\web.xml
```

Tìm xem có mapping cho InventoryMonitorServlet không

## URL để test

- Test servlet: `http://localhost:8080/Login/test-inventory-monitor` (should work)
- Inventory Monitor: `http://localhost:8080/Login/inventory-monitor` (target URL)
- Direct JSP: `http://localhost:8080/Login/view/InventoryMonitor.jsp` (will have null data)

## Servlet Configuration trong web.xml

```xml
<servlet>
    <servlet-name>InventoryMonitorServlet</servlet-name>
    <servlet-class>controller.InventoryMonitorServlet</servlet-class>
</servlet>
<servlet-mapping>
    <servlet-name>InventoryMonitorServlet</servlet-name>
    <url-pattern>/inventory-monitor</url-pattern>
</servlet-mapping>
```
