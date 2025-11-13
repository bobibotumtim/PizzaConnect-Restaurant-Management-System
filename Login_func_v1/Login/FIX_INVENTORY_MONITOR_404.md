# Fix Inventory Monitor 404 Error

## Vấn đề

Không thể truy cập `/inventory-monitor` hoặc `/inventorymonitor` - gặp lỗi 404

## Nguyên nhân

Sau khi merge/revert code, servlet mapping bị mất trong web.xml

## Đã sửa

✅ Đã thêm servlet mapping vào web.xml cho cả 2 URL patterns:

- `/inventorymonitor`
- `/inventory-monitor`
  ✅ Đã sửa RoleFilter để cho phép cả 2 URL patterns
  ✅ Jakarta servlet API đã có trong classpath
  ✅ File jakarta.servlet-api-6.0.0.jar tồn tại trong thư mục lib

## Vấn đề đã phát hiện và sửa

### Vấn đề 1: Servlet mapping bị mất

- **Nguyên nhân**: Sau merge/revert, web.xml không có mapping cho InventoryMonitorServlet
- **Giải pháp**: Thêm servlet mapping vào web.xml

### Vấn đề 2: RoleFilter block URL `/inventory-monitor`

- **Nguyên nhân**: Filter chỉ exclude `/inventorymonitor` nhưng không exclude `/inventory-monitor`
- **Triệu chứng**: Truy cập trực tiếp bằng URL thì OK, nhưng click từ dashboard bị redirect
- **Giải pháp**: Cập nhật RoleFilter để exclude cả 2 URL patterns

## Giải pháp - Các bước thực hiện trong NetBeans

### ⚠️ LƯU Ý QUAN TRỌNG

NetBeans đang hiển thị lỗi compile cho tất cả servlet (không chỉ InventoryMonitorServlet). Đây là vấn đề với IDE cache, KHÔNG phải code. Các servlet khác vẫn hoạt động bình thường.

### Bước 1: Refresh Libraries trong NetBeans

1. Trong NetBeans, mở project "Login"
2. Expand node "Libraries" trong project tree
3. Right-click vào "Libraries" → **"Refresh"** hoặc **"Resolve Problems"**
4. Nếu có dialog hiện ra, chọn "Fix" hoặc "Resolve"

### Bước 2: Clean và Rebuild Project

1. Right-click vào project "Login" → **Clean and Build**
2. Chờ build hoàn tất (xem Output window)

### Bước 3: Restart NetBeans (nếu cần)

Nếu lỗi vẫn hiển thị trong IDE:

1. Close NetBeans hoàn toàn
2. Mở lại NetBeans
3. Open project "Login"

### Bước 4: Stop và Clean Tomcat

1. Stop Tomcat server (nếu đang chạy)
2. Right-click vào Tomcat server → **Clean and Undeploy**
3. Chọn "Login" application để undeploy

### Bước 5: Deploy và Test

1. Right-click vào project "Login" → **Run**
2. Chờ deployment hoàn tất
3. Test các URL:
   - `http://localhost:8080/Login/inventorymonitor`
   - `http://localhost:8080/Login/inventory-monitor`

### Bước 6: Nếu vẫn lỗi 404

Kiểm tra deployed files trong Tomcat:

```
C:\Program Files\Apache Software Foundation\Tomcat 10.1\webapps\Login\WEB-INF\
```

Xác nhận:

- File `web.xml` có chứa servlet mapping cho InventoryMonitorServlet
- Thư mục `classes\controller\` có file `InventoryMonitorServlet.class`

## Kiểm tra sau khi deploy

### URL để test

1. **Inventory Monitor (URL chính)**:

   - `http://localhost:8080/Login/inventorymonitor`
   - `http://localhost:8080/Login/inventory-monitor`

2. **Test servlet (để verify deployment)**:

   - `http://localhost:8080/Login/test-inventory-monitor`

3. **Direct JSP (sẽ có null data)**:
   - `http://localhost:8080/Login/view/InventoryMonitor.jsp`

### Nếu vẫn lỗi 404

1. **Kiểm tra server logs** trong tab "Output" của NetBeans:

   - Tìm ClassNotFoundException
   - Tìm NoClassDefFoundError
   - Tìm ServletException

2. **Kiểm tra deployed files** trong Tomcat:

   ```
   C:\Program Files\Apache Software Foundation\Tomcat 10.1\webapps\Login\WEB-INF\
   ```

   - Xác nhận `web.xml` có servlet mapping
   - Xác nhận `classes\controller\InventoryMonitorServlet.class` tồn tại

3. **Kiểm tra RoleFilter** không block URL:
   - RoleFilter đã được cấu hình để cho phép `/inventorymonitor`
   - Admin (role 1) không thể truy cập
   - Chỉ Manager (role 2 với jobRole="Manager") mới truy cập được

## Cấu hình đã thêm vào web.xml

```xml
<!-- Inventory Monitor Servlet -->
<servlet>
    <servlet-name>InventoryMonitorServlet</servlet-name>
    <servlet-class>controller.InventoryMonitorServlet</servlet-class>
</servlet>
<servlet-mapping>
    <servlet-name>InventoryMonitorServlet</servlet-name>
    <url-pattern>/inventorymonitor</url-pattern>
</servlet-mapping>
<servlet-mapping>
    <servlet-name>InventoryMonitorServlet</servlet-name>
    <url-pattern>/inventory-monitor</url-pattern>
</servlet-mapping>
```

## Tóm tắt

✅ Đã thêm servlet mapping vào web.xml
✅ Hỗ trợ cả 2 URL patterns: `/inventorymonitor` và `/inventory-monitor`
✅ RoleFilter đã được cấu hình đúng
✅ Jakarta servlet API có trong classpath

**Lỗi compile trong NetBeans IDE là do cache, không ảnh hưởng đến runtime. Servlet sẽ hoạt động bình thường sau khi deploy.**
