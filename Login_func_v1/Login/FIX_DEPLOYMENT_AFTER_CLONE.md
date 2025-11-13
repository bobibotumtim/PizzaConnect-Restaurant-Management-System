# Fix Deployment After Clone Branch

## Vấn đề

Sau khi clone branch mới, project không deploy được với lỗi "context failed to start"

## Nguyên nhân

NetBeans cache chưa được refresh sau khi clone, khiến IDE không nhận diện Jakarta Servlet API trong classpath

## Giải pháp - Làm theo thứ tự

### Bước 1: Verify file JAR tồn tại

```
Login_func_v1\Login\lib\jakarta.servlet-api-6.0.0.jar
```

✅ File đã tồn tại

### Bước 2: Verify project.properties đúng

✅ Path đã đúng: `lib\\jakarta.servlet-api-6.0.0.jar`
✅ Đã có trong javac.classpath

### Bước 3: Clean NetBeans cache và project

**Trong Command Prompt hoặc PowerShell:**

```powershell
# Xóa build cache
Remove-Item -Recurse -Force "Login_func_v1\Login\build" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "Login_func_v1\Login\dist" -ErrorAction SilentlyContinue

# Xóa NetBeans cache (chọn 1 trong 2 cách)

# Cách 1: Xóa cache của project cụ thể
Remove-Item -Recurse -Force "Login_func_v1\Login\nbproject\private" -ErrorAction SilentlyContinue

# Cách 2: Xóa toàn bộ NetBeans cache (nếu cách 1 không hiệu quả)
Remove-Item -Recurse -Force "$env:USERPROFILE\AppData\Local\NetBeans\Cache" -ErrorAction SilentlyContinue
```

### Bước 4: Trong NetBeans

1. **Close NetBeans hoàn toàn** (File → Exit)

2. **Mở lại NetBeans**

3. **Open project "Login"**

   - File → Open Project
   - Chọn `Login_func_v1/Login`

4. **Resolve Libraries** (nếu có cảnh báo)

   - Expand node "Libraries" trong project tree
   - Right-click vào "Libraries" → "Resolve Problems" hoặc "Refresh"
   - Nếu có dialog, chọn "Fix" hoặc "Resolve"

5. **Clean and Build**

   - Right-click vào project "Login"
   - Chọn "Clean and Build"
   - Đợi build hoàn tất (xem Output window)
   - **Quan trọng:** Kiểm tra Output window không có lỗi compile

6. **Deploy**
   - Right-click vào project "Login"
   - Chọn "Run"

### Bước 5: Nếu vẫn lỗi - Xóa Tomcat work directory

```powershell
# Stop Tomcat trước
# Sau đó xóa work directory
Remove-Item -Recurse -Force "C:\Program Files\Apache Software Foundation\Tomcat 10.1\work\Catalina\localhost\Login" -ErrorAction SilentlyContinue
```

### Bước 6: Nếu vẫn lỗi - Re-add JAR file

Trong NetBeans:

1. Right-click vào project "Login" → Properties
2. Chọn "Libraries" ở bên trái
3. Click "Add JAR/Folder"
4. Browse đến `Login_func_v1\Login\lib\jakarta.servlet-api-6.0.0.jar`
5. Click "Add JAR/Folder"
6. Click "OK"
7. Clean and Build lại

## Kiểm tra

### Sau khi build thành công, verify:

1. **Check compiled classes:**

```powershell
dir "Login_func_v1\Login\build\web\WEB-INF\classes\controller\*.class"
```

Phải thấy các file .class bao gồm:

- LoginServlet.class
- InventoryMonitorServlet.class
- AdminServlet.class
- etc.

2. **Check deployed JAR:**

```powershell
dir "Login_func_v1\Login\build\web\WEB-INF\lib\jakarta.servlet-api-6.0.0.jar"
```

### Test URLs sau khi deploy thành công:

- Home: `http://localhost:8080/Login/`
- Login: `http://localhost:8080/Login/Login`
- Manager Dashboard: `http://localhost:8080/Login/manager-dashboard`
- Inventory Monitor: `http://localhost:8080/Login/inventory-monitor`

## Tóm tắt

Vấn đề chính sau khi clone branch mới là NetBeans cache chưa được refresh. Giải pháp:

1. ✅ Xóa build cache
2. ✅ Xóa NetBeans cache
3. ✅ Restart NetBeans
4. ✅ Clean and Build
5. ✅ Deploy

**Nếu làm đầy đủ các bước trên, project sẽ deploy thành công!**
