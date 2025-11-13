-- =============================================
-- Check Manager Account Configuration
-- =============================================

PRINT '========================================';
PRINT 'Checking Manager Account Configuration';
PRINT '========================================';
PRINT '';

-- Check all users with their roles
PRINT '--- All Users with Roles ---';
SELECT 
    u.UserID,
    u.Name,
    u.Email,
    u.Role,
    CASE u.Role
        WHEN 1 THEN 'Admin'
        WHEN 2 THEN 'Employee'
        WHEN 3 THEN 'Customer'
        ELSE 'Unknown'
    END AS RoleName,
    e.EmployeeID,
    e.JobRole,
    e.Specialization
FROM [User] u
LEFT JOIN Employee e ON u.UserID = e.UserID
ORDER BY u.Role, u.Name;
PRINT '';

-- Check specifically for Manager role
PRINT '--- Users with Manager JobRole ---';
SELECT 
    u.UserID,
    u.Name,
    u.Email,
    u.Role,
    e.EmployeeID,
    e.JobRole,
    e.Specialization
FROM [User] u
INNER JOIN Employee e ON u.UserID = e.UserID
WHERE e.JobRole = 'Manager'
ORDER BY u.Name;
PRINT '';

-- Check if there are any users with Role = 2 but no Employee record
PRINT '--- Users with Role=2 (Employee) but NO Employee Record ---';
SELECT 
    u.UserID,
    u.Name,
    u.Email,
    u.Role
FROM [User] u
WHERE u.Role = 2
AND NOT EXISTS (SELECT 1 FROM Employee e WHERE e.UserID = u.UserID);
PRINT '';

-- Check Employee table structure
PRINT '--- All Employees ---';
SELECT 
    e.EmployeeID,
    e.UserID,
    u.Name AS UserName,
    e.JobRole,
    e.Specialization,
    e.HireDate
FROM Employee e
LEFT JOIN [User] u ON e.UserID = u.UserID
ORDER BY e.JobRole, u.Name;
PRINT '';

PRINT '========================================';
PRINT 'Check Complete';
PRINT '========================================';
