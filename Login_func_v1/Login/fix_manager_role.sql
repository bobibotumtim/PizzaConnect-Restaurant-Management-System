-- ===============================
-- 🔧 SỬA ROLE CỦA USER THÀNH MANAGER
-- ===============================

USE pizza_demo_DB_FinalModel;
GO

-- Kiểm tra user hiện tại (UserID = 8, EmployeeID = 4)
SELECT 
    u.UserID,
    u.Name,
    u.Email,
    u.Role as UserRole,
    e.EmployeeID,
    e.Role as JobRole,
    e.Specialization
FROM [User] u
INNER JOIN Employee e ON u.UserID = e.UserID
WHERE u.UserID = 8;
GO

-- Cập nhật Employee của UserID = 8 thành Manager
UPDATE Employee 
SET Role = 'Manager', 
    Specialization = NULL
WHERE UserID = 8;
GO

-- Kiểm tra lại sau khi update
SELECT 
    u.UserID,
    u.Name,
    u.Email,
    u.Role as UserRole,
    e.EmployeeID,
    e.Role as JobRole,
    e.Specialization
FROM [User] u
INNER JOIN Employee e ON u.UserID = e.UserID
WHERE u.UserID = 8;
GO

PRINT '✅ Đã cập nhật UserID=8 (Quách Thành Thông) thành Manager!';
PRINT '🔄 Vui lòng LOGOUT và LOGIN lại để refresh session!';
GO
