-- ===============================
-- 👔 CẬP NHẬT USER THÀNH MANAGER
-- ===============================

USE pizza_demo_DB_FinalModel;
GO

-- Cập nhật Employee của "Quách Thành Thông" thành Manager
UPDATE Employee 
SET Role = 'Manager', 
    Specialization = NULL
WHERE UserID = (SELECT UserID FROM [User] WHERE Name = N'Quách Thành Thông');
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
WHERE u.Name = N'Quách Thành Thông';
GO

PRINT '✅ Đã cập nhật user "Quách Thành Thông" thành Manager!';
PRINT '📱 Bây giờ bạn có thể login và sẽ được redirect đến Manager Dashboard';
GO
