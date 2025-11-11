-- ===============================
-- CREATE DATABASE
-- ===============================
CREATE DATABASE pizza_demo_DB_Merged;
GO

USE pizza_demo_DB_Merged;
GO

-- ===============================
-- USER SYSTEM 
-- ===============================

CREATE TABLE [User] (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Password NVARCHAR(60) NOT NULL,
    Role INT NOT NULL CHECK (Role IN (1, 2, 3)),  -- 1=Admin, 2=Employee, 3=Customer
    Email NVARCHAR(100) UNIQUE,
    Phone NVARCHAR(20) UNIQUE,
    [DateOfBirth] DATE NULL,
    Gender NVARCHAR(10) CHECK (Gender IN ('Male', 'Female', 'Other')),
    IsActive BIT DEFAULT 1
);
GO

CREATE TABLE Employee (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    Role NVARCHAR(50) NOT NULL CHECK (Role IN ('Manager', 'Cashier', 'Waiter', 'Chef')),
    Specialization NVARCHAR(50) NULL CHECK (Specialization IN ('Pizza', 'Drinks', 'SideDishes', NULL)),
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);
GO

CREATE TABLE Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);
GO

-- ===============================
-- CATEGORY + PRODUCT STRUCTURE
-- ===============================

CREATE TABLE Category (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255),
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO

CREATE TABLE Product (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255),
    CategoryID INT NOT NULL,
    ImageURL NVARCHAR(255),
    IsAvailable BIT DEFAULT 1,
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID)
);
GO

CREATE TABLE ProductSize (
    ProductSizeID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    SizeCode CHAR(1) CHECK (SizeCode IN ('S','M','L','F')), -- S=Small, M=Medium, L=Large, F=Fixed
    SizeName NVARCHAR(50),
    Price DECIMAL(10,2) NOT NULL,
	IsDeleted BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);
GO

CREATE TABLE Inventory (
    InventoryID INT IDENTITY(1,1) PRIMARY KEY,
    ItemName NVARCHAR(100) NOT NULL,
    Quantity DECIMAL(10,2) DEFAULT 0,
    Unit NVARCHAR(50),
    LastUpdated DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE ProductIngredient (
    ProductSizeID INT NOT NULL,
    InventoryID INT NOT NULL,
    QuantityNeeded DECIMAL(10,2) NOT NULL,
    Unit NVARCHAR(50),
    PRIMARY KEY (ProductSizeID, InventoryID),
    FOREIGN KEY (ProductSizeID) REFERENCES ProductSize(ProductSizeID),
    FOREIGN KEY (InventoryID) REFERENCES Inventory(InventoryID)
);
GO

-- ===============================
-- TABLE SYSTEM 
-- ===============================
CREATE TABLE [Table] (
    TableID INT IDENTITY(1,1) PRIMARY KEY,
    TableNumber NVARCHAR(10) NOT NULL UNIQUE,
    Capacity INT NOT NULL CHECK (Capacity > 0),
    [Status] NVARCHAR(20) DEFAULT 'available' CHECK ([Status] IN ('available', 'unavailable')),
    IsActive BIT DEFAULT 1
);
GO

-- ===============================
-- ORDER SYSTEM 
-- ===============================

CREATE TABLE [Order] (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customer(CustomerID),
    EmployeeID INT FOREIGN KEY REFERENCES Employee(EmployeeID),
    TableID INT NULL FOREIGN KEY REFERENCES [Table](TableID),
    OrderDate DATETIME DEFAULT GETDATE(),
    [Status] INT DEFAULT 0 CHECK ([Status] IN (0,1,2,3,4)),  -- 0=Pending,1=Preparing,2=Served,3=Completed,4=Cancelled
    PaymentStatus NVARCHAR(50) DEFAULT 'Unpaid' CHECK (PaymentStatus IN ('Unpaid', 'Paid')),
    TotalPrice DECIMAL(10,2) DEFAULT 0,
    Note NVARCHAR(255)
);
GO

CREATE TABLE OrderDetail (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT FOREIGN KEY REFERENCES [Order](OrderID),
    ProductSizeID INT FOREIGN KEY REFERENCES ProductSize(ProductSizeID), 
    Quantity INT NOT NULL,
    TotalPrice DECIMAL(10,2),
    SpecialInstructions NVARCHAR(255),
    EmployeeID INT NULL,
    [Status] NVARCHAR(50) DEFAULT 'Waiting', -- Waiting, In Progress, Done
    StartTime DATETIME NULL,
    EndTime DATETIME NULL,
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);
GO

CREATE TABLE OrderDetailTopping (
	OrderDetailToppingID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	OrderDetailID INT NOT NULL FOREIGN KEY REFERENCES OrderDetail(OrderDetailID) ON DELETE CASCADE,
	ProductPrice DECIMAL(10, 2) NOT NULL,
	ProductSizeID INT NOT NULL, -- ProductSizeID of Topping type Product
	CONSTRAINT FK_OrderDetailTopping_ProductSize_Topping FOREIGN KEY (ProductSizeID)
	REFERENCES ProductSize(ProductSizeID)
);
GO


-- ===============================
-- DISCOUNT SYSTEM
-- ===============================

CREATE TABLE Discount (
    DiscountID INT IDENTITY(1,1) PRIMARY KEY,
    Description NVARCHAR(255),
    DiscountType NVARCHAR(50) CHECK (DiscountType IN ('Percentage', 'Fixed', 'Loyalty')),
    Value DECIMAL(10,2),
    MaxDiscount DECIMAL(10,2),
    MinOrderTotal DECIMAL(10,2) DEFAULT 0,
    StartDate DATE,
    EndDate DATE,
    CustomerOnly BIT DEFAULT 0,
    IsActive BIT DEFAULT 1
);
GO

CREATE TABLE CustomerDiscount (
    CustomerDiscountID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL FOREIGN KEY REFERENCES Customer(CustomerID),
    DiscountID INT NOT NULL FOREIGN KEY REFERENCES Discount(DiscountID),
    Quantity INT DEFAULT 0,
    ExpiryDate DATE,
    IsUsed BIT DEFAULT 0,
    LastEarnedDate DATETIME NULL,
    UsedDate DATETIME NULL,
    CONSTRAINT UK_CustomerDiscount UNIQUE (CustomerID, DiscountID)
);
GO

CREATE TABLE OrderDiscount (
    OrderID INT FOREIGN KEY REFERENCES [Order](OrderID),
    DiscountID INT FOREIGN KEY REFERENCES Discount(DiscountID),
    Amount DECIMAL(10,2) NOT NULL,
    AppliedDate DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (OrderID, DiscountID)
);
GO

-- ===============================
-- PAYMENT SYSTEM 
-- ===============================

CREATE TABLE Payment (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    PaymentMethod NVARCHAR(50) NOT NULL CHECK (PaymentMethod IN ('Cash', 'QR Code')),
    Amount DECIMAL(10,2) NOT NULL,
    PaymentStatus NVARCHAR(50) DEFAULT 'Pending' CHECK (PaymentStatus IN ('Pending', 'Completed', 'Failed')),
    PaymentDate DATETIME DEFAULT GETDATE(),
    TransactionID NVARCHAR(100) NULL,
    QRCodeURL NVARCHAR(500) NULL,
    FOREIGN KEY (OrderID) REFERENCES [Order](OrderID) ON DELETE CASCADE
);
GO

-- ===============================
-- Feedback System
-- ===============================

CREATE TABLE Feedback (
    FeedbackID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL FOREIGN KEY REFERENCES Customer(CustomerID),
    OrderID INT NOT NULL FOREIGN KEY REFERENCES [Order](OrderID),
    ProductID INT NOT NULL FOREIGN KEY REFERENCES Product(ProductID),
    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    FeedbackDate DATETIME DEFAULT GETDATE()
);
GO

-- ===============================
-- PASSWORD TOKENS
-- ===============================

CREATE TABLE PasswordTokens (
    Token NVARCHAR(20) PRIMARY KEY, 
    UserID INT NOT NULL,
    NewPasswordHash NVARCHAR(255) NOT NULL,
    ExpiresAt DATETIME2 NOT NULL DEFAULT DATEADD(MINUTE, 5, SYSDATETIME()),
    Used BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_PasswordTokens_User FOREIGN KEY (UserID)
        REFERENCES [User](UserID)
        ON DELETE CASCADE
);
GO

-- ===============================
-- QUEUE TABLES
-- ===============================

CREATE TABLE DeletionQueue (
    QueueID INT IDENTITY(1,1) PRIMARY KEY,
    EntityType NVARCHAR(20) NOT NULL,  -- 'Table', 'Product', etc.
    EntityID INT NOT NULL,
    ScheduledDeletion DATETIME NOT NULL DEFAULT DATEADD(DAY, 1, CAST(GETDATE() AS DATE)),
    
    -- Unique constraint to prevent duplicate scheduling
    CONSTRAINT UK_DeletionQueue_Entity UNIQUE (EntityType, EntityID)
);
GO

-- ===============================
-- SAMPLE DATA (Merged)
-- ===============================

-- Users 
INSERT INTO [User] (Name, Password, Role, Email, Phone, [DateOfBirth], Gender, IsActive)
VALUES 
('Admin 01', '$2a$10$wA1.VHtxxp1i0a.SY2SFO.f45v.G/syMrruqnfJHGIEYCjiFTUSgW', 1, 'admin01@pizzastore.com', '0909000001', '1990-01-01', 'Male', 1),
('Nguyen Van A', '$2a$10$bJskj.kelsRTuCHDBHkQJu2z0NQSUzivBArkjVNmiybd7ab4IxEC2', 2, 'employee01@pizzastore.com', '0909000002', '1995-03-15', 'Male', 1),
('Tran Thi B', '$2a$10$bxDhNBnj3nQoTq2vNVhBUeKXQovbEGigBGtNdm2LLZNSQ5VYMrdbG', 2, 'employee02@pizzastore.com', '0909000003', '1995-03-15', 'Female', 1),
('Le Van C', '$2a$10$8T7NzU1acsG44ojiWCaMyuc1/hj690KUvnnBLLSHYRfrK5.dqw3MG', 3, 'customer01@gmail.com', '0909000004', '2000-02-02', 'Male', 1),
('Pham Thi D', '$2a$10$/a5l7E7hEMhx1Wm.I/GDxuySxSqz8Sud.ZcwMNBT02VJB9XNL5h7i', 3, 'customer02@gmail.com', '0909000005', '2001-05-12', 'Female', 1),
('Hoang Van E', '$2a$10$H/hz51dfW781VMlzSO4nROCjjvadpx4qHbi/GAnjKcvgUct4Mvc1q', 3, 'customer03@gmail.com', '0909000006', '1999-09-09', 'Male', 1),
('Chef Nguyen', '$2a$10$wA1.VHtxxp1i0a.SY2SFO.f45v.G/syMrruqnfJHGIEYCjiFTUSgW', 2, 'chef01@pizzastore.com', '0909000007', '1992-07-20', 'Male', 1);
GO

-- Employees 
INSERT INTO Employee (UserID, Role)
VALUES 
(2, 'Cashier'),
(3, 'Waiter'),
(7, 'Chef');
GO

-- Customers 
INSERT INTO Customer (UserID)
VALUES 
(4),
(5),
(6);
GO

-- Categories 
INSERT INTO Category (CategoryName, Description)
VALUES 
(N'Pizza', N'All pizza products'),
(N'Drink', N'All beverages'),
(N'Topping', N'Extra toppings');
GO

-- Products 
INSERT INTO Product (ProductName, Description, CategoryID, ImageURL, IsAvailable)
VALUES 
(N'Hawaiian Pizza', N'Pizza with ham and pineapple', 1, N'hawaiian.jpg', 1),
(N'Iced Milk Coffee', N'Coffee with condensed milk', 2, N'icedMilkCoffee.jpg', 1),
(N'Peach Orange Tea', N'Peach tea with orange flavor', 2, N'peachOrangeTea.jpg', 1);
GO

-- Product sizes & prices 
INSERT INTO ProductSize (ProductID, SizeCode, SizeName, Price)
VALUES
(1, 'S', 'Small', 120000),
(1, 'M', 'Medium', 160000),
(1, 'L', 'Large', 200000),
(2, 'F', 'Fixed', 25000),
(3, 'F', 'Fixed', 30000);
GO

-- Inventory 
INSERT INTO Inventory (ItemName, Quantity, Unit)
VALUES 
(N'Dough', 10, N'kg'),
(N'Cheese', 5, N'kg'),
(N'Ham', 3, N'kg'),
(N'Pineapple', 2, N'kg'),
(N'Ground Coffee', 10, N'kg'),
(N'Condensed Milk', 5, N'liter'),
(N'Sliced Peach', 2, N'kg'),
(N'Dried Tea', 3, N'kg');
GO

-- Ingredients by size 
INSERT INTO ProductIngredient (ProductSizeID, InventoryID, QuantityNeeded, Unit)
VALUES
(1, 1, 0.25, 'kg'),
(1, 2, 0.10, 'kg'),
(1, 3, 0.08, 'kg'),
(1, 4, 0.05, 'kg'),
(2, 5, 0.05, 'kg'),
(2, 6, 0.02, 'liter'),
(3, 7, 0.05, 'kg'),
(3, 8, 0.02, 'kg');
GO

-- Table data 
INSERT INTO [Table] (TableNumber, Capacity) VALUES
('T01', 2),
('T02', 2),
('T03', 4),
('T04', 4),
('T05', 4),
('T06', 6),
('T07', 6),
('T08', 6),
('T09', 8),
('T10', 8),
('T11', 10),
('T12', 10);
GO

-- Orders 
INSERT INTO [Order] (CustomerID, EmployeeID, TableID, [Status], PaymentStatus, TotalPrice, Note)
VALUES 
(1, 1, 5, 0, 'Unpaid', 55000, N'Customer wants less sugar'),
(1, 2, 3, 1, 'Paid', 120000, N'Regular customer'),
(2, 2, 2, 3, 'Paid', 60000, N'Delivery completed'),
(1, 1, 4, 3, 'Paid', 180000, 'Order for family dinner'),
(2, 2, 6, 3, 'Paid', 220000, 'Business meeting'),
(3, 1, 2, 3, 'Paid', 90000, 'Quick lunch'),
(1, 2, NULL, 3, 'Paid', 120000, 'Takeaway order');
GO

-- Order details 
INSERT INTO OrderDetail (OrderID, ProductSizeID, Quantity, TotalPrice, SpecialInstructions, EmployeeID, [Status], StartTime, EndTime)
VALUES
(1, 4, 1, 25000, N'Less ice', NULL, 'In Progress', GETDATE(), NULL),
(1, 5, 1, 30000, N'No sugar', NULL, 'Waiting', NULL, NULL),
(2, 1, 1, 120000, NULL, 3, 'Done', DATEADD(MINUTE, -30, GETDATE()), GETDATE()), -- Gán cho Chef (EmployeeID 3, UserID 7)
(4, 2, 1, 160000, 'Extra cheese', 3, 'Done', DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, -2, DATEADD(MINUTE, 25, GETDATE()))),
(4, 4, 2, 50000, 'Less sugar', NULL, 'Done', DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, -2, DATEADD(MINUTE, 10, GETDATE()))),
(5, 3, 1, 200000, 'Well done', 3, 'Done', DATEADD(DAY, -5, GETDATE()), DATEADD(DAY, -5, DATEADD(MINUTE, 30, GETDATE()))),
(5, 5, 2, 60000, 'Extra peach', NULL, 'Done', DATEADD(DAY, -5, GETDATE()), DATEADD(DAY, -5, DATEADD(MINUTE, 5, GETDATE()))),
(6, 1, 1, 120000, 'No pineapple', 3, 'Done', DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, DATEADD(MINUTE, 20, GETDATE()))),
(7, 4, 3, 75000, 'Takeaway', NULL, 'Done', DATEADD(DAY, -10, GETDATE()), DATEADD(DAY, -10, DATEADD(MINUTE, 8, GETDATE()))),
(7, 5, 1, 30000, 'Takeaway', NULL, 'Done', DATEADD(DAY, -10, GETDATE()), DATEADD(DAY, -10, DATEADD(MINUTE, 5, GETDATE())));
GO

-- Discounts 
INSERT INTO Discount (Description, DiscountType, Value, MaxDiscount, MinOrderTotal, StartDate, EndDate, IsActive)
VALUES
(N'10% off drinks', 'Percentage', 10, NULL, 0, '2025-10-01', '2025-10-31', 1),
(N'Fixed 20K off over 200K', 'Fixed', 20000, NULL, 200000, '2025-10-15', '2025-11-15', 1),
(N'Loyalty points', 'Loyalty', 100, NULL, 0, '2025-10-01', NULL, 1),
('Weekend Special 15%', 'Percentage', 15, 50000, 150000, '2025-10-01', '2025-12-31', 1),
('Birthday Discount 20%', 'Percentage', 20, 100000, 200000, '2025-01-01', '2025-12-31', 1),
('Free Drink Combo', 'Fixed', 30000, 30000, 250000, '2025-10-15', '2025-11-15', 1),
('Student Discount 10%', 'Percentage', 10, 25000, 100000, '2025-09-01', '2025-12-31', 1),
('Family Meal 25%', 'Percentage', 25, 75000, 350000, '2025-10-01', '2025-10-31', 1);
GO

-- CustomerDiscount
INSERT INTO CustomerDiscount (CustomerID, DiscountID, Quantity, ExpiryDate, IsUsed, LastEarnedDate)
VALUES 
(1, 2, 1, '2025-11-30', 0, '2025-10-20 14:30:00'),  -- Customer 1 has 1 voucher 20K off
(1, 3, 500, NULL, 0, '2025-10-21 14:30:00'),        -- Customer 1 has 500 loyalty points
(2, 3, 310, NULL, 0, '2025-10-18 10:15:00'),        -- Customer 2 has 310 loyalty points
(3, 2, 2, '2025-11-15', 0, '2025-10-18 10:25:00'),  -- Customer 3 has 2 voucher 20K off
(1, 5, 1, '2025-12-31', 0, '2025-10-18 10:25:00'),  -- Birthday Discount
(3, 7, 1, '2025-10-30', 0, '2025-10-18 10:25:00');  -- Student Discount expire soon
GO


-- Payment
INSERT INTO Payment (OrderID, PaymentMethod, Amount, PaymentStatus, PaymentDate, TransactionID, QRCodeURL)
VALUES 
(1, 'Cash', 55000, 'Completed', '2025-10-20 14:30:00', NULL, NULL),
(2, 'QR Code', 120000, 'Completed', '2025-10-20 15:00:00', 'TXN001234', 'https://img.vietqr.io/image/vietinbank-113366668888-compact2.jpg?amount=120000&addInfo=Order2&accountName=Pizza Store'),
(3, 'Cash', 60000, 'Completed', '2025-10-19 12:30:00', NULL, NULL),
(4, 'Cash', 180000, 'Completed', '2025-10-18 19:45:00', NULL, NULL),
(5, 'QR Code', 220000, 'Completed', '2025-10-15 14:00:00', 'TXN001236', 'https://img.vietqr.io/image/vietinbank-113366668888-compact2.jpg?amount=220000&addInfo=Order5&accountName=Pizza Store'),
(6, 'QR Code', 90000, 'Completed', '2025-10-13 12:30:00', 'TXN001237', 'https://img.vietqr.io/image/vietinbank-113366668888-compact2.jpg?amount=90000&addInfo=Order6&accountName=Pizza Store'),
(7, 'Cash', 120000, 'Completed', '2025-10-10 16:30:00', NULL, NULL);
GO

-- Feedback
INSERT INTO Feedback (CustomerID, OrderID, ProductID, Rating, FeedbackDate)
VALUES 
(1, 2, 1, 5, '2025-10-20 15:30:00'),
(1, 2, 2, 4, '2025-10-20 15:32:00'),
(2, 3, 1, 3, '2025-10-19 12:15:00'),
(2, 3, 3, 5, '2025-10-19 12:20:00'),
(1, 4, 1, 4, '2025-10-18 19:30:00'),
(1, 4, 2, 5, '2025-10-18 19:32:00'),
(2, 5, 1, 5, '2025-10-15 13:45:00'),
(3, 6, 1, 4, '2025-10-13 12:20:00'),
(1, 7, 2, 3, '2025-10-10 16:15:00');
GO

-- ===============================
-- VIEW
-- ===============================

-- Product size available
CREATE VIEW v_ProductSizeAvailable
AS
WITH SizeAvailability AS (
    SELECT
        pi.ProductSizeID,
        MIN(i.Quantity / NULLIF(pi.QuantityNeeded, 0)) AS CalculatedQuantity
    FROM 
        ProductIngredient pi
    JOIN 
        Inventory i ON pi.InventoryID = i.InventoryID
    WHERE
        pi.QuantityNeeded > 0
    GROUP BY
        pi.ProductSizeID
)
SELECT
    p.ProductID,
    ps.ProductSizeID,
    p.ProductName,
    ps.SizeCode,
    ps.SizeName,
    ps.Price,
    c.CategoryName,
    p.ImageURL,
    p.IsAvailable,
    CAST(COALESCE(sa.CalculatedQuantity, 0) AS DECIMAL(10,2)) AS AvailableQuantity
FROM
    ProductSize ps
JOIN
    Product p ON ps.ProductID = p.ProductID
JOIN
    Category c ON p.CategoryID = c.CategoryID
LEFT JOIN
    SizeAvailability sa ON ps.ProductSizeID = sa.ProductSizeID
WHERE
    p.IsAvailable = 1
    AND ps.IsDeleted = 0
    AND c.IsDeleted = 0;
GO 
   
-- ===========================
-- PROCEDURES
-- ===========================
CREATE PROCEDURE ScheduleDeletion
    @EntityType NVARCHAR(20),
    @EntityID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ScheduledTime DATETIME = DATEADD(DAY, 1, CAST(GETDATE() AS DATE)); -- 00:00 tomorrow
    
    -- Check if entity already exists in queue
    IF NOT EXISTS (SELECT 1 FROM DeletionQueue WHERE EntityType = @EntityType AND EntityID = @EntityID)
    BEGIN
        INSERT INTO DeletionQueue (EntityType, EntityID, ScheduledDeletion)
        VALUES (@EntityType, @EntityID, @ScheduledTime);
    END
END
GO

-- ===========================
CREATE PROCEDURE ProcessDeletionQueue
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Safety check - only run on this database
    IF DB_NAME() != 'pizza_demo_DB_Merged'
    BEGIN
        PRINT 'This procedure is designed for pizza_demo_DB_Merged only. Current database: ' + DB_NAME();
        RETURN;
    END
    
    DECLARE @QueueID INT, @EntityType NVARCHAR(20), @EntityID INT;
    DECLARE @ProcessedCount INT = 0;
    
    WHILE (1 = 1)
    BEGIN
        -- Get the first item from queue
        SELECT TOP 1 @QueueID = QueueID, @EntityType = EntityType, @EntityID = EntityID
        FROM DeletionQueue
        WHERE ScheduledDeletion <= GETDATE()
        ORDER BY ScheduledDeletion;
        
        -- Break if no more items
        IF @QueueID IS NULL
            BREAK;
        
        BEGIN TRY
            BEGIN TRANSACTION;
            
            -- Process based on entity type
            IF @EntityType = 'Table'
            BEGIN
                UPDATE [Table] SET IsActive = 0 WHERE TableID = @EntityID;
            END
            ELSE IF @EntityType = 'Discount'
            BEGIN
                UPDATE Discount SET IsActive = 0 WHERE DiscountID = @EntityID;
            END
            -- Add more entity types here as needed
            
            -- Remove from queue after successful processing
            DELETE FROM DeletionQueue WHERE QueueID = @QueueID;
            
            SET @ProcessedCount = @ProcessedCount + 1;
            
            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION;
            -- Log error and continue with next item
            PRINT 'Error processing QueueID ' + CAST(@QueueID AS NVARCHAR) + ': ' + ERROR_MESSAGE();
            
            -- Break on error to avoid infinite loop
            BREAK;
        END CATCH
        
        -- Reset variables for next iteration
        SET @QueueID = NULL;
        SET @EntityType = NULL;
        SET @EntityID = NULL;
    END
    
    PRINT 'Processed ' + CAST(@ProcessedCount AS NVARCHAR) + ' items from deletion queue.';
END
GO
