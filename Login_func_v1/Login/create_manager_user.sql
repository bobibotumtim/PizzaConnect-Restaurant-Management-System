-- ===============================
-- 👔 TẠO USER MANAGER
-- ===============================

USE pizza_demo_DB_FinalModel;
GO

-- Tạo User với Role = 2 (Employee)
INSERT INTO [User] (Name, Password, Role, Email, Phone, DateOfBirth, Gender, IsActive)
VALUES 
('Quách Thành Thông', '$2a$10$YourHashedPasswordHere', 2, 'manager@pizzaconnect.com', '0901234567', '1990-01-01', 'Male', 1);
GO

-- Lấy UserID vừa tạo và tạo Employee với Role = 'Manager'
DECLARE @ManagerUserID INT = (SELECT UserID FROM [User] WHERE Email = 'manager@pizzaconnect.com');

INSERT INTO Employee (UserID, Role, Specialization)
VALUES 
(@ManagerUserID, 'Manager', NULL);
GO

-- Kiểm tra kết quả
SELECT 
    u.UserID,
    u.Name,
    u.Email,
    u.Phone,
    u.Role as UserRole,
    e.EmployeeID,
    e.Role as JobRole,
    e.Specialization
FROM [User] u
LEFT JOIN Employee e ON u.UserID = e.UserID
WHERE u.Email = 'manager@pizzaconnect.com';
GO

-- ===============================
-- 📝 HƯỚNG DẪN SỬ DỤNG
-- ===============================
-- 1. Chạy script này trong SQL Server Management Studio
-- 2. Thay đổi password hash nếu cần (hoặc dùng password mặc định)
-- 3. Login với:
--    - Phone: 0901234567
--    - Password: (password tương ứng với hash)
-- 4. Sau khi login, sẽ tự động redirect đến Manager Dashboard
