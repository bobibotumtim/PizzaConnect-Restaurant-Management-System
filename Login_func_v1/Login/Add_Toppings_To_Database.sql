-- ===============================
-- 🍕 ADD TOPPINGS TO DATABASE
-- Database: pizza_demo_DB_FinalModel
-- ===============================

USE pizza_demo_DB_FinalModel;
GO

PRINT '🍕 Starting Topping Setup...';
GO

-- ===============================
-- 1. CHECK/CREATE TOPPING CATEGORY
-- ===============================

DECLARE @ToppingCategoryID INT;

-- Check if Topping category exists
SELECT @ToppingCategoryID = CategoryID 
FROM Category 
WHERE CategoryName = 'Topping';

IF @ToppingCategoryID IS NULL
BEGIN
    -- Create Topping category
    INSERT INTO Category (CategoryName, IsDeleted) 
    VALUES ('Topping', 0);
    
    SELECT @ToppingCategoryID = SCOPE_IDENTITY();
    PRINT '✅ Created Topping category with ID: ' + CAST(@ToppingCategoryID AS VARCHAR);
END
ELSE
BEGIN
    PRINT '✅ Topping category already exists with ID: ' + CAST(@ToppingCategoryID AS VARCHAR);
END

-- ===============================
-- 2. ADD TOPPING PRODUCTS
-- ===============================

-- Check if toppings already exist
IF NOT EXISTS (
    SELECT 1 FROM Product p
    INNER JOIN Category c ON p.CategoryID = c.CategoryID
    WHERE c.CategoryName = 'Topping'
)
BEGIN
    PRINT '📝 Adding topping products...';
    
    -- Insert topping products
    INSERT INTO Product (ProductName, Description, CategoryID, ImageURL, IsAvailable) VALUES
    ('Extra Cheese', 'Topping - Extra Cheese', @ToppingCategoryID, 'extra_cheese.jpg', 1),
    ('Mushrooms', 'Topping - Mushrooms', @ToppingCategoryID, 'mushrooms.jpg', 1),
    ('Black Olives', 'Topping - Black Olives', @ToppingCategoryID, 'black_olives.jpg', 1),
    ('Green Peppers', 'Topping - Green Peppers', @ToppingCategoryID, 'green_peppers.jpg', 1),
    ('Onions', 'Topping - Onions', @ToppingCategoryID, 'onions.jpg', 1),
    ('Pepperoni', 'Topping - Pepperoni', @ToppingCategoryID, 'pepperoni.jpg', 1),
    ('Italian Sausage', 'Topping - Italian Sausage', @ToppingCategoryID, 'italian_sausage.jpg', 1),
    ('Bacon', 'Topping - Bacon', @ToppingCategoryID, 'bacon.jpg', 1),
    ('Ham', 'Topping - Ham', @ToppingCategoryID, 'ham.jpg', 1),
    ('Pineapple', 'Topping - Pineapple', @ToppingCategoryID, 'pineapple.jpg', 1),
    ('Tomatoes', 'Topping - Tomatoes', @ToppingCategoryID, 'tomatoes.jpg', 1),
    ('Jalapeños', 'Topping - Jalapeños', @ToppingCategoryID, 'jalapenos.jpg', 1),
    ('Spinach', 'Topping - Spinach', @ToppingCategoryID, 'spinach.jpg', 1),
    ('Garlic', 'Topping - Garlic', @ToppingCategoryID, 'garlic.jpg', 1),
    ('Basil', 'Topping - Basil', @ToppingCategoryID, 'basil.jpg', 1);
    
    PRINT '✅ Added 15 topping products';
END
ELSE
BEGIN
    PRINT '⚠️ Topping products already exist';
END

-- ===============================
-- 3. ADD PRODUCT SIZES FOR TOPPINGS
-- ===============================

PRINT '📝 Adding ProductSize for toppings...';

-- Add Fixed size for each topping (if not exists)
INSERT INTO ProductSize (ProductID, SizeCode, SizeName, Price, IsDeleted)
SELECT 
    p.ProductID, 
    'F', 
    'Fixed', 
    CASE p.ProductName
        WHEN 'Extra Cheese' THEN 15000
        WHEN 'Mushrooms' THEN 10000
        WHEN 'Black Olives' THEN 10000
        WHEN 'Green Peppers' THEN 8000
        WHEN 'Onions' THEN 8000
        WHEN 'Pepperoni' THEN 20000
        WHEN 'Italian Sausage' THEN 20000
        WHEN 'Bacon' THEN 25000
        WHEN 'Ham' THEN 18000
        WHEN 'Pineapple' THEN 12000
        WHEN 'Tomatoes' THEN 8000
        WHEN 'Jalapeños' THEN 10000
        WHEN 'Spinach' THEN 10000
        WHEN 'Garlic' THEN 8000
        WHEN 'Basil' THEN 8000
        ELSE 10000
    END,
    0
FROM Product p
INNER JOIN Category c ON p.CategoryID = c.CategoryID
WHERE c.CategoryName = 'Topping' 
AND NOT EXISTS (
    SELECT 1 FROM ProductSize ps 
    WHERE ps.ProductID = p.ProductID AND ps.SizeCode = 'F'
);

PRINT '✅ ProductSize added for toppings';

-- ===============================
-- 4. VERIFY SETUP
-- ===============================

PRINT '';
PRINT '========================================';
PRINT '📊 VERIFICATION RESULTS';
PRINT '========================================';

DECLARE @ToppingCount INT;
SELECT @ToppingCount = COUNT(*)
FROM Product p
INNER JOIN Category c ON p.CategoryID = c.CategoryID
WHERE c.CategoryName = 'Topping';

PRINT 'Total Topping Products: ' + CAST(@ToppingCount AS VARCHAR);

DECLARE @ToppingSizeCount INT;
SELECT @ToppingSizeCount = COUNT(*)
FROM Product p
INNER JOIN ProductSize ps ON p.ProductID = ps.ProductID
INNER JOIN Category c ON p.CategoryID = c.CategoryID
WHERE c.CategoryName = 'Topping' AND ps.SizeCode = 'F';

PRINT 'Total Topping ProductSizes: ' + CAST(@ToppingSizeCount AS VARCHAR);

PRINT '';
PRINT '📋 Available Toppings:';
SELECT 
    ps.ProductSizeID AS ToppingID,
    p.ProductName AS ToppingName,
    ps.Price,
    p.IsAvailable
FROM Product p
INNER JOIN ProductSize ps ON p.ProductID = ps.ProductID
INNER JOIN Category c ON p.CategoryID = c.CategoryID
WHERE c.CategoryName = 'Topping' AND ps.SizeCode = 'F'
ORDER BY p.ProductName;

PRINT '';
PRINT '✅ Topping setup completed successfully!';
PRINT '';
PRINT '📝 Next Steps:';
PRINT '1. Restart your Tomcat server';
PRINT '2. Open POS: http://localhost:8080/Login/pos';
PRINT '3. Select a table and click on a pizza';
PRINT '4. You should see toppings available for selection';
GO

