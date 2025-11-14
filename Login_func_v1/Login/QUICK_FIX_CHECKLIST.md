# Quick Fix Checklist - Deployment Issues

## ✅ Đã hoàn thành tự động:

- [x] Xóa `build/` directory
- [x] Xóa `dist/` directory
- [x] Xóa `nbproject/private/` directory
- [x] Verify Jakarta Servlet API JAR tồn tại
- [x] Verify project.properties có đúng path

## 📋 Bạn cần làm trong NetBeans:

### 1. Close NetBeans hoàn toàn

- File → Exit
- Đảm bảo NetBeans đã tắt hẳn

### 2. Mở lại NetBeans

- Khởi động NetBeans
- File → Open Project
- Chọn `Login_func_v1/Login`

### 3. Resolve Libraries (nếu cần)

- Expand node "Libraries" trong project tree
- Nếu thấy icon đỏ hoặc cảnh báo:
  - Right-click "Libraries" → "Resolve Problems"
  - Chọn "Fix" hoặc "Resolve"

### 4. Clean and Build

- Right-click project "Login"
- Chọn "Clean and Build"
- **Đợi build hoàn tất**
- Kiểm tra Output window:
  - ✅ Phải thấy "BUILD SUCCESSFUL"
  - ❌ Nếu có lỗi, đọc lỗi và báo lại

### 5. Run/Deploy

- Right-click project "Login"
- Chọn "Run"
- Đợi deployment hoàn tất

## 🎯 Test sau khi deploy:

- [ ] `http://localhost:8080/Login/` - Home page
- [ ] `http://localhost:8080/Login/Login` - Login page
- [ ] Login với Manager account
- [ ] `http://localhost:8080/Login/manager-dashboard` - Manager Dashboard
- [ ] `http://localhost:8080/Login/inventory-monitor` - Inventory Monitor

## ⚠️ Nếu vẫn lỗi:

### Option A: Xóa NetBeans cache toàn bộ

```powershell
Remove-Item -Recurse -Force "$env:USERPROFILE\AppData\Local\NetBeans\Cache"
```

Sau đó restart NetBeans và làm lại từ bước 2

### Option B: Re-add JAR manually

1. Right-click project → Properties
2. Libraries → Add JAR/Folder
3. Browse: `Login_func_v1\Login\lib\jakarta.servlet-api-6.0.0.jar`
4. Add → OK
5. Clean and Build lại

### Option C: Kiểm tra Tomcat

- Stop Tomcat server
- Right-click Tomcat → Clean and Undeploy
- Chọn "Login" application
- Start Tomcat lại
- Deploy project

## 📝 Ghi chú:

- Vấn đề chính: NetBeans cache không được refresh sau khi clone branch
- Giải pháp: Clean cache + Restart NetBeans + Clean Build
- Nếu làm đúng các bước, project sẽ deploy thành công 100%
