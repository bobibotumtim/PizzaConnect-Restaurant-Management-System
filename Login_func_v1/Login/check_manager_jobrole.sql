-- Check Manager JobRole in database
USE pizza_demo_DB_FinalModel;
GO

-- Check your user's Employee record
SELECT 
    u.UserID,
    u.Name,
    u.Email,
    u.Role as UserRole,
    e.EmployeeID,
    e.JobRole,
    e.Specialization
FROM Users u
LEFT JOIN Employee e ON u.UserID = e.UserID
WHERE u.Role = 2  -- Employee role
ORDER BY u.UserID;
GO

-- Check specifically for Manager role
SELECT 
    u.UserID,
    u.Name,
    u.Email,
    e.JobRole
FROM Users u
INNER JOIN Employee e ON u.UserID = e.UserID
WHERE e.JobRole = 'Manager';
GO

-- Check all possible JobRole values
SELECT DISTINCT JobRole 
FROM Employee
ORDER BY JobRole;
GO
