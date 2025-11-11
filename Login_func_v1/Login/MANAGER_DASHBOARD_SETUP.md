# 👔 Manager Dashboard - Setup Complete

## ✅ Đã hoàn thành

### 1. **Files đã tạo/cập nhật:**

#### Servlets:

- ✅ `ManagerDashboardServlet.java` - Dashboard riêng cho Manager
- ✅ `LoginServlet.java` - Thêm logic redirect Manager
- ✅ `SalesReportServlet.java` - Cho phép Manager truy cập
- ✅ `AdminServlet.java` - Cho phép Manager quản lý users

#### Views:

- ✅ `ManagerDashboard.jsp` - Giao diện dashboard đẹp với 2 cards

#### SQL Scripts:

- ✅ `update_user_to_manager.sql` - Cập nhật user thành Manager
- ✅ `check_all_users_roles.sql` - Kiểm tra roles
- ✅ `create_manager_user.sql` - Tạo user Manager mới (backup)

---

## 🎯 Chức năng Manager Dashboard

Manager có quyền truy cập:

### 1. **Sales Reports** (`/sales-reports`)

- Xem báo cáo doanh thu
- Lọc theo thời gian (Today, Week, Month, Year)
- Xem top sản phẩm bán chạy
- Xem doanh thu theo ngày
- Export báo cáo (CSV, Excel, PDF)

### 2. **User Management** (`/admin`)

- Xem danh sách users
- Thêm user mới
- Chỉnh sửa thông tin user
- Quản lý roles và permissions

---

## 🚀 Cách sử dụng

### Bước 1: Cập nhật Database

```sql
-- Chạy file: update_user_to_manager.sql
-- Hoặc chạy lệnh sau:
UPDATE Employee
SET Role = 'Manager', Specialization = NULL
WHERE UserID = (SELECT UserID FROM [User] WHERE Name = N'Quách Thành Thông');
```

### Bước 2: Kiểm tra

```sql
-- Chạy file: check_all_users_roles.sql
-- Xem user có JobRole = 'Manager' chưa
```

### Bước 3: Login

1. Logout (nếu đang login)
2. Login với user "Quách Thành Thông"
3. Tự động redirect đến: `http://localhost:8080/Login/manager-dashboard`

---

## 📋 URL Mappings

| Chức năng         | URL                                   | Servlet                 |
| ----------------- | ------------------------------------- | ----------------------- |
| Manager Dashboard | `/manager-dashboard`                  | ManagerDashboardServlet |
| Sales Reports     | `/sales-reports` hoặc `/salesreports` | SalesReportServlet      |
| User Management   | `/admin`                              | AdminServlet            |
| Add User          | `/adduser`                            | AddUserServlet          |
| Edit User         | `/edituser`                           | EditUserServlet         |

---

## 🔐 Access Control

### Manager (Role = 2, JobRole = 'Manager'):

- ✅ Manager Dashboard
- ✅ Sales Reports
- ✅ User Management (Add/Edit Users)
- ❌ Admin Dashboard (chỉ Admin)
- ❌ POS, Orders, Inventory (chỉ Admin)

### Admin (Role = 1):

- ✅ Tất cả chức năng
- ✅ Admin Dashboard
- ✅ Sales Reports
- ✅ User Management
- ✅ POS, Orders, Inventory, etc.

### Employee (Role = 2, JobRole = 'Waiter'/'Chef'):

- ✅ Waiter Dashboard hoặc Chef Monitor
- ❌ Manager Dashboard
- ❌ Sales Reports
- ❌ User Management

---

## 🧪 Testing

### Test 1: Login as Manager

```
1. Login với user có JobRole = 'Manager'
2. Kiểm tra redirect đến /manager-dashboard
3. Xem 2 cards: Sales Reports và User Management
```

### Test 2: Access Sales Reports

```
1. Click vào card "Sales Reports"
2. Kiểm tra redirect đến /sales-reports
3. Xem báo cáo hiển thị đúng
4. Test filter: Today, Week, Month, Year
5. Test export: CSV, Excel, PDF
```

### Test 3: Access User Management

```
1. Click vào card "User Management"
2. Kiểm tra redirect đến /admin
3. Xem danh sách users
4. Test Add User
5. Test Edit User
```

---

## 🐛 Troubleshooting

### Vấn đề: Vẫn redirect đến Waiter Dashboard

**Giải pháp:**

1. Kiểm tra database: `SELECT * FROM Employee WHERE UserID = ?`
2. Đảm bảo `Role = 'Manager'` (không phải 'Waiter')
3. Logout và login lại để refresh session

### Vấn đề: Không truy cập được Sales Reports

**Giải pháp:**

1. Kiểm tra session có `employee` object không
2. Kiểm tra `employee.getJobRole()` = 'Manager'
3. Clear browser cache và cookies

### Vấn đề: 404 Not Found

**Giải pháp:**

1. Clean and Build project
2. Restart Tomcat server
3. Kiểm tra URL mapping trong web.xml

---

## 📝 Notes

- Manager Dashboard được thiết kế đẹp với Tailwind CSS
- Responsive design cho mobile
- Icons sử dụng Lucide Icons
- Gradient background đẹp mắt
- Sidebar navigation đơn giản

---

## 🎨 Customization

Để thay đổi màu sắc hoặc style:

- Edit file: `ManagerDashboard.jsp`
- Thay đổi gradient colors trong `<style>` section
- Thay đổi icon trong Lucide Icons library

---

**✅ Setup hoàn tất! Manager Dashboard đã sẵn sàng sử dụng!** 🎉
