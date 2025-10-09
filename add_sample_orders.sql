-- Thêm 5 đơn hàng mẫu vào database pizza_demo_DB
USE pizza_demo_DB;
GO

-- Thêm 5 đơn hàng mẫu
INSERT INTO Orders (StaffID, TableNumber, Status, TotalMoney, PaymentStatus, CustomerName, CustomerPhone, Notes) VALUES
(2, 'T05', 2, 67.95, 'Paid', 'Nguyen Van A', '0901234567', 'Extra cheese on all pizzas'),
(2, 'T06', 1, 45.98, 'Unpaid', 'Tran Thi B', '0901234568', 'No onions on pizza'),
(3, 'T07', 0, 89.97, 'Unpaid', 'Le Van C', '0901234569', 'Well done pizza'),
(2, 'T08', 2, 34.99, 'Paid', 'Pham Thi D', '0901234570', ''),
(3, 'T09', 1, 78.96, 'Unpaid', 'Hoang Van E', '0901234571', 'Extra spicy sauce');

-- Thêm chi tiết đơn hàng cho Order 1 (OrderID = 1)
INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice, TotalPrice, SpecialInstructions) VALUES
(1, 1, 2, 15.99, 31.98, 'Extra cheese'),
(1, 2, 1, 18.99, 18.99, 'Well done'),
(1, 6, 3, 3.99, 11.97, 'No ice'),
(1, 8, 1, 5.99, 5.99, 'Extra crispy');

-- Thêm chi tiết đơn hàng cho Order 2 (OrderID = 2)
INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice, TotalPrice, SpecialInstructions) VALUES
(2, 3, 1, 21.99, 21.99, 'Light sauce'),
(2, 7, 2, 3.99, 7.98, ''),
(2, 9, 1, 4.99, 4.99, 'Extra garlic'),
(2, 10, 1, 8.99, 8.99, 'Dressing on side'),
(2, 1, 1, 15.99, 15.99, 'No onions');

-- Thêm chi tiết đơn hàng cho Order 3 (OrderID = 3)
INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice, TotalPrice, SpecialInstructions) VALUES
(3, 4, 2, 17.99, 35.98, 'No mushrooms'),
(3, 5, 1, 24.99, 24.99, 'Extra pepperoni'),
(3, 6, 2, 3.99, 7.98, 'No ice'),
(3, 8, 2, 5.99, 11.99, 'Extra crispy'),
(3, 9, 1, 4.99, 4.99, 'Extra garlic'),
(3, 10, 1, 8.99, 8.99, 'Dressing on side');

-- Thêm chi tiết đơn hàng cho Order 4 (OrderID = 4)
INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice, TotalPrice, SpecialInstructions) VALUES
(4, 1, 1, 15.99, 15.99, ''),
(4, 6, 1, 3.99, 3.99, 'No ice'),
(4, 8, 1, 5.99, 5.99, ''),
(4, 9, 1, 4.99, 4.99, ''),
(4, 10, 1, 8.99, 8.99, 'Dressing on side');

-- Thêm chi tiết đơn hàng cho Order 5 (OrderID = 5)
INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice, TotalPrice, SpecialInstructions) VALUES
(5, 2, 2, 18.99, 37.98, 'Extra spicy'),
(5, 3, 1, 21.99, 21.99, 'Extra spicy sauce'),
(5, 7, 2, 3.99, 7.98, ''),
(5, 8, 1, 5.99, 5.99, 'Extra crispy'),
(5, 9, 1, 4.99, 4.99, 'Extra garlic');

-- Cập nhật tổng tiền cho các đơn hàng
UPDATE Orders SET TotalMoney = 67.95 WHERE OrderID = 1;
UPDATE Orders SET TotalMoney = 45.98 WHERE OrderID = 2;
UPDATE Orders SET TotalMoney = 89.97 WHERE OrderID = 3;
UPDATE Orders SET TotalMoney = 34.99 WHERE OrderID = 4;
UPDATE Orders SET TotalMoney = 78.96 WHERE OrderID = 5;

PRINT 'Successfully added 5 sample orders with details!';

