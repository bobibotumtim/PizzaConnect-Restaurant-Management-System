USE pizza_demo_DB_FinalModel;
GO

-- 1️⃣ Thêm Category Dessert (nếu chưa có)
INSERT INTO Category (CategoryName, Description, IsDeleted)
VALUES (N'Dessert', N'All desserts and sweets', 0);
GO

-- 2️⃣ Thêm 6 món Dessert mẫu
INSERT INTO Product (ProductName, Description, CategoryID, ImageURL, IsAvailable)
VALUES
(N'Chocolate Lava Cake', N'Warm chocolate cake with molten center', 5, N'chocoLavaCake.jpg', 1),
(N'Tiramisu', N'Classic Italian coffee-flavored dessert', 5, N'tiramisu.jpg', 1),
(N'Cheesecake', N'Creamy cheesecake with biscuit base', 5, N'cheesecake.jpg', 1),
(N'Ice Cream Cup', N'Assorted ice cream flavors', 5, N'iceCream.jpg', 1),
(N'Brownie', N'Rich chocolate brownie square', 5, N'brownie.jpg', 1),
(N'Fruit Salad', N'Fresh mixed seasonal fruits', 5, N'fruitSalad.jpg', 1);
GO
