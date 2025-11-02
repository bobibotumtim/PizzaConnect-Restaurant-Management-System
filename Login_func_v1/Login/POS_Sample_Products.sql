-- Insert sample products for POS system
-- Run this script to add products that match the frontend

-- Check if Product table exists, if not create it
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Product' AND xtype='U')
BEGIN
    CREATE TABLE Product (
        ProductID INT IDENTITY(1,1) PRIMARY KEY,
        ProductName NVARCHAR(100) NOT NULL,
        Price DECIMAL(10,2) NOT NULL,
        Category NVARCHAR(50) NOT NULL,
        IsAvailable BIT DEFAULT 1
    );
END

-- Clear existing products (optional)
-- DELETE FROM Product;

-- Insert Pizza products (IDs 1-8)
INSERT INTO Product (ProductName, Price, Category, IsAvailable) VALUES
('Margherita Pizza', 120000, 'PIZZA', 1),
('Pepperoni Pizza', 150000, 'PIZZA', 1),
('Hawaiian Pizza', 180000, 'PIZZA', 1),
('BBQ Chicken Pizza', 160000, 'PIZZA', 1),
('Veggie Supreme', 145000, 'PIZZA', 1),
('Meat Lovers', 190000, 'PIZZA', 1),
('Four Cheese', 165000, 'PIZZA', 1),
('Seafood Special', 200000, 'PIZZA', 1);

-- Insert Beverages (IDs 11-16)
SET IDENTITY_INSERT Product ON;
INSERT INTO Product (ProductID, ProductName, Price, Category, IsAvailable) VALUES
(11, 'Coca Cola', 15000, 'BEVERAGES', 1),
(12, 'Pepsi', 15000, 'BEVERAGES', 1),
(13, 'Sprite', 15000, 'BEVERAGES', 1),
(14, 'Orange Juice', 25000, 'BEVERAGES', 1),
(15, 'Iced Tea', 20000, 'BEVERAGES', 1),
(16, 'Coffee', 30000, 'BEVERAGES', 1);
SET IDENTITY_INSERT Product OFF;

-- Insert Sides (IDs 21-26)
SET IDENTITY_INSERT Product ON;
INSERT INTO Product (ProductID, ProductName, Price, Category, IsAvailable) VALUES
(21, 'French Fries', 35000, 'SIDES', 1),
(22, 'Chicken Wings', 80000, 'SIDES', 1),
(23, 'Garlic Bread', 40000, 'SIDES', 1),
(24, 'Onion Rings', 30000, 'SIDES', 1),
(25, 'Caesar Salad', 45000, 'SIDES', 1),
(26, 'Mozzarella Sticks', 55000, 'SIDES', 1);
SET IDENTITY_INSERT Product OFF;

-- Insert Desserts (IDs 31-34)
SET IDENTITY_INSERT Product ON;
INSERT INTO Product (ProductID, ProductName, Price, Category, IsAvailable) VALUES
(31, 'Tiramisu', 50000, 'DESSERTS', 1),
(32, 'Chocolate Cake', 45000, 'DESSERTS', 1),
(33, 'Vanilla Ice Cream', 35000, 'DESSERTS', 1),
(34, 'Chocolate Brownie', 40000, 'DESSERTS', 1);
SET IDENTITY_INSERT Product OFF;

PRINT '✅ Sample products inserted successfully!';
PRINT 'Pizza: 8 products (IDs 1-8)';
PRINT 'Beverages: 6 products (IDs 11-16)';
PRINT 'Sides: 6 products (IDs 21-26)';
PRINT 'Desserts: 4 products (IDs 31-34)';
PRINT '';
PRINT 'Total products: ' + CAST((SELECT COUNT(*) FROM Product) AS VARCHAR(10));