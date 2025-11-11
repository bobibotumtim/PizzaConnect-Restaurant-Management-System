# 🧪 Test Manager Access - Quick Guide

## 🎯 Mục đích

Kiểm tra xem Manager có thể truy cập User Management không.

---

## 📋 Các bước test

### Bước 1: Kiểm tra Session

Truy cập: `http://localhost:8080/Login/test_manager_access.jsp`

**Kiểm tra:**

- ✅ User in session: Yes
- ✅ Employee in session: Yes
- ✅ Job Role: Manager
- ✅ Can access Admin page: Yes

**Nếu có vấn đề:**

- Employee in session: No → Logout và login lại
- Job Role không phải Manager → Chạy lại `update_user_to_manager.sql`

---

### Bước 2: Test User Management

Truy cập: `http://localhost:8080/Login/admin`

**Kết quả mong đợi:**

- ✅ Hiển thị trang Admin với danh sách users
- ✅ Có thể xem danh sách users
- ✅ Có thể search và filter users
- ✅ Có nút "Add User" và "Edit"

**Nếu gặp lỗi:**

- **403 Forbidden** → Session không có employee object
  - Giải pháp: Logout và login lại
- **404 Not Found** → URL sai
  - Giải pháp: Kiểm tra web.xml có mapping `/admin` chưa
- **Redirect về Home** → Không có quyền
  - Giải pháp: Kiểm tra JobRole trong database

---

### Bước 3: Test Add User

1. Click nút "Add User"
2. Điền thông tin user mới
3. Click "Save"

**Kết quả mong đợi:**

- ✅ User được tạo thành công
- ✅ Hiển thị message "User added successfully"
- ✅ Redirect về trang Admin

---

### Bước 4: Test Edit User

1. Click nút "Edit" ở một user
2. Thay đổi thông tin
3. Click "Save"

**Kết quả mong đợi:**

- ✅ User được cập nhật thành công
- ✅ Hiển thị message "User updated successfully"
- ✅ Redirect về trang Admin

---

## 🔧 Troubleshooting

### Vấn đề 1: "Access denied. Admin or Manager role required."

**Nguyên nhân:** Session không có employee object hoặc JobRole không phải Manager

**Giải pháp:**

```sql
-- 1. Kiểm tra database
SELECT u.Name, u.Role, e.Role as JobRole
FROM [User] u
LEFT JOIN Employee e ON u.UserID = e.UserID
WHERE u.Name = N'Quách Thành Thông';

-- 2. Nếu JobRole không phải Manager, update:
UPDATE Employee
SET Role = 'Manager'
WHERE UserID = (SELECT UserID FROM [User] WHERE Name = N'Quách Thành Thông');

-- 3. Logout và login lại
```

---

### Vấn đề 2: Employee in session = No

**Nguyên nhân:** LoginServlet không set employee vào session

**Giải pháp:**

1. Logout
2. Clear browser cookies
3. Login lại
4. Kiểm tra console log có message "✅ Employee set to session" không

---

### Vấn đề 3: Redirect về Waiter Dashboard khi login

**Nguyên nhân:** JobRole trong database không phải "Manager"

**Giải pháp:**

```sql
-- Kiểm tra và update
SELECT * FROM Employee WHERE UserID = (SELECT UserID FROM [User] WHERE Name = N'Quách Thành Thông');

UPDATE Employee
SET Role = 'Manager', Specialization = NULL
WHERE UserID = (SELECT UserID FROM [User] WHERE Name = N'Quách Thành Thông');
```

---

## ✅ Checklist

Trước khi test, đảm bảo:

- [ ] Database đã update JobRole = 'Manager'
- [ ] Đã logout và login lại
- [ ] Session có cả user và employee object
- [ ] Clean and Build project
- [ ] Restart Tomcat server

---

## 📞 Debug Commands

### Kiểm tra database:

```sql
-- Xem tất cả users và roles
SELECT
    u.UserID, u.Name, u.Email, u.Role as UserRole,
    e.Role as JobRole, e.Specialization
FROM [User] u
LEFT JOIN Employee e ON u.UserID = e.UserID
WHERE u.IsActive = 1;
```

### Kiểm tra session:

Truy cập: `http://localhost:8080/Login/test_manager_access.jsp`

### Xem console log:

Mở browser DevTools → Console → Xem có error không

---

**✅ Sau khi fix, Manager sẽ có thể:**

- Truy cập Manager Dashboard
- Xem Sales Reports
- Quản lý Users (Add/Edit)

🎉 Good luck!
