-- Upgrade Manager users to Admin role (Role = 1)
-- This gives Managers full admin access including User Management

USE pizza_demo_DB_FinalModel;
GO

-- First, check current Managers
SELECT 
    u.UserID,
    u.Name,
    u.Email,
    u.Role as CurrentRole,
    e.JobRole
FROM [User] u
INNER JOIN Employee e ON u.UserID = e.UserID
WHERE e.JobRole = 'Manager';
GO

-- Upgrade Managers to Admin role (Role = 1)
UPDATE u
SET u.Role = 1  -- Admin role
FROM [User] u
INNER JOIN Employee e ON u.UserID = e.UserID
WHERE e.JobRole = 'Manager';
GO

-- Verify the change
SELECT 
    u.UserID,
    u.Name,
    u.Email,
    u.Role as NewRole,
    e.JobRole
FROM [User] u
INNER JOIN Employee e ON u.UserID = e.UserID
WHERE e.JobRole = 'Manager';
GO

PRINT 'Done! All Managers now have Admin role (Role = 1)';
PRINT 'They can now access User Management and all admin features.';
