USE pizza_demo_DB_FinalModel;
GO

-- 1️⃣ Thêm Category mới: Side Dish
INSERT INTO Category (CategoryName, Description, IsDeleted)
VALUES (N'Side Dish', N'All side dishes', 0);
GO

-- 2️⃣ Thêm 12 món Side Dish (CategoryID = 4)
INSERT INTO Product (ProductName, Description, CategoryID, ImageURL, IsAvailable)
VALUES
(N'Garlic Bread', N'Toasted garlic bread slices', 4, N'garlicBread.jpg', 1),
(N'French Fries', N'Crispy potato fries', 4, N'frenchFries.jpg', 1),
(N'Mozzarella Sticks', N'Fried mozzarella cheese sticks', 4, N'mozzarellaSticks.jpg', 1),
(N'Onion Rings', N'Crispy onion rings', 4, N'onionRings.jpg', 1),
(N'Chicken Wings', N'Spicy fried chicken wings', 4, N'chickenWings.jpg', 1),
(N'Cheesy Bread', N'Warm bread with melted cheese', 4, N'cheesyBread.jpg', 1),
(N'Potato Wedges', N'Seasoned potato wedges', 4, N'potatoWedges.jpg', 1),
(N'Coleslaw', N'Fresh cabbage salad with dressing', 4, N'coleslaw.jpg', 1),
(N'Garlic Knots', N'Knotted bread with garlic butter', 4, N'garlicKnots.jpg', 1),
(N'Caesar Salad', N'Crisp lettuce with Caesar dressing', 4, N'caesarSalad.jpg', 1),
(N'Mashed Potatoes', N'Creamy mashed potatoes with gravy', 4, N'mashedPotatoes.jpg', 1),
(N'Corn on the Cob', N'Grilled sweet corn with butter', 4, N'cornOnTheCob.jpg', 1);
GO
