-- Đổi role của user Hieu thành admin (role = 1)
UPDATE [User]
SET Role = 1
WHERE Name = 'Hieu';