-- Update all Waiter users to Role 2
BEGIN TRANSACTION;

-- Update User.Role = 2 for all Waiters
UPDATE [User] 
SET Role = 2 
WHERE UserID IN (
    SELECT UserID FROM Employee WHERE Role = 'Waiter'
);

-- Verify changes
SELECT u.UserID, u.Name, u.Role as UserRole, e.Role as EmployeeRole
FROM [User] u
LEFT JOIN Employee e ON u.UserID = e.UserID
WHERE e.Role = 'Waiter';

COMMIT;

-- Role 2 (Waiter) permissions:
-- ✅ POS System
-- ✅ Order Management
-- ❌ Dashboard (Admin only)
-- ❌ Inventory (Admin only)
-- ❌ Manage Products (Admin only)
-- ❌ Manage Users (Admin only)
-- ❌ Discount (Admin only)
