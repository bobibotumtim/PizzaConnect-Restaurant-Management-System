-- ===============================
-- 🔍 KIỂM TRA TẤT CẢ USERS VÀ ROLES
-- ===============================

USE pizza_demo_DB_FinalModel;
GO

-- Xem tất cả users với role details
SELECT 
    u.UserID,
    u.Name,
    u.Email,
    u.Phone,
    CASE u.Role 
        WHEN 1 THEN 'Admin'
        WHEN 2 THEN 'Employee'
        WHEN 3 THEN 'Customer'
        ELSE 'Unknown'
    END as UserRole,
    e.EmployeeID,
    e.Role as JobRole,
    e.Specialization,
    CASE 
        WHEN e.Role = 'Manager' THEN '👔 Manager Dashboard'
        WHEN e.Specialization IS NOT NULL AND e.Specialization != '' THEN '🍳 Chef Monitor'
        WHEN e.Role IS NOT NULL THEN '👨‍💼 Waiter Dashboard'
        WHEN u.Role = 1 THEN '🎛️ Admin Dashboard'
        WHEN u.Role = 3 THEN '🏠 Customer Home'
        ELSE '❓ Unknown'
    END as RedirectTo
FROM [User] u
LEFT JOIN Employee e ON u.UserID = e.UserID
WHERE u.IsActive = 1
ORDER BY u.Role, e.Role;
GO

-- Đếm số lượng theo role
SELECT 
    'Total Users' as Category,
    COUNT(*) as Count
FROM [User]
WHERE IsActive = 1

UNION ALL

SELECT 
    'Admins' as Category,
    COUNT(*) as Count
FROM [User]
WHERE Role = 1 AND IsActive = 1

UNION ALL

SELECT 
    'Employees' as Category,
    COUNT(*) as Count
FROM [User]
WHERE Role = 2 AND IsActive = 1

UNION ALL

SELECT 
    'Customers' as Category,
    COUNT(*) as Count
FROM [User]
WHERE Role = 3 AND IsActive = 1

UNION ALL

SELECT 
    'Managers' as Category,
    COUNT(*) as Count
FROM Employee
WHERE Role = 'Manager'

UNION ALL

SELECT 
    'Chefs' as Category,
    COUNT(*) as Count
FROM Employee
WHERE Specialization IS NOT NULL AND Specialization != ''

UNION ALL

SELECT 
    'Waiters' as Category,
    COUNT(*) as Count
FROM Employee
WHERE Role = 'Waiter';
GO
