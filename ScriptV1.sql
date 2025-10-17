CREATE DATABASE pizza_demo_DB1;
GO

USE pizza_demo_DB1;
GO

-- B?ng User: th�ng tin chung c?a t?t c? ng??i d�ng (Admin, Employee, Customer)
CREATE TABLE [User] (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Password NVARCHAR(255) NOT NULL,
    Role INT NOT NULL, -- 1=Admin, 2=Employee, 3=Customer
    Email NVARCHAR(100) UNIQUE,
    Phone NVARCHAR(20) UNIQUE,
    [DateOfBirth] DATE NULL,
    Gender NVARCHAR(10) CHECK (Gender IN ('Male', 'Female', 'Other')),
    IsActive BIT DEFAULT 1
);

-- B?ng Employee: l?u th�ng tin ri�ng c?a nh�n vi�n
CREATE TABLE Employee (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    Role NVARCHAR(50) NOT NULL, -- vai tr� c�ng vi?c (VD: Cashier, Waiter)
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);

-- B?ng Customer: l?u th�ng tin ri�ng c?a kh�ch h�ng
CREATE TABLE Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    LoyaltyPoint INT DEFAULT 0,
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);

-- ==========================
-- D? LI?U M?U
-- ==========================

-- Admin
INSERT INTO [User] (Name, Password, Role, Email, Phone, [DateOfBirth], Gender, IsActive)
VALUES 
('Admin 01', '$2a$10$wA1.VHtxxp1i0a.SY2SFO.f45v.G/syMrruqnfJHGIEYCjiFTUSgW', 1, 'admin01@pizzastore.com', '0909000001', '1990-01-01', 'Male', 1);

-- Employee
INSERT INTO [User] (Name, Password, Role, Email, Phone, [DateOfBirth], Gender, IsActive)
VALUES
('Nguyen Van A', '$2a$10$bJskj.kelsRTuCHDBHkQJu2z0NQSUzivBArkjVNmiybd7ab4IxEC2', 2, 'employee01@pizzastore.com', '0909000002', '1995-03-15', 'Male', 1),
('Tran Thi B', '$2a$10$bxDhNBnj3nQoTq2vNVhBUeKXQovbEGigBGtNdm2LLZNSQ5VYMrdbG', 2, 'employee02@pizzastore.com', '0909000003', '1998-08-20', 'Female', 1);

-- Customer
INSERT INTO [User] (Name, Password, Role, Email, Phone, [DateOfBirth], Gender, IsActive)
VALUES
('Le Van C', '$2a$10$8T7NzU1acsG44ojiWCaMyuc1/hj690KUvnnBLLSHYRfrK5.dqw3MG', 3, 'customer01@gmail.com', '0909000004', '2000-02-02', 'Male', 1),
('Pham Thi D', '$2a$10$/a5l7E7hEMhx1Wm.I/GDxuySxSqz8Sud.ZcwMNBT02VJB9XNL5h7i', 3, 'customer02@gmail.com', '0909000005', '2001-05-12', 'Female', 1),
('Hoang Van E', '$2a$10$H/hz51dfW781VMlzSO4nROCjjvadpx4qHbi/GAnjKcvgUct4Mvc1q', 3, 'customer03@gmail.com', '0909000006', '1999-09-09', 'Male', 1);

-- Th�m d? li?u Employee
INSERT INTO Employee (UserID, Role)
VALUES
(2, 'Cashier'),
(3, 'Waiter');

-- Th�m d? li?u Customer
INSERT INTO Customer (UserID, LoyaltyPoint)
VALUES
(4, 10),
(5, 20),
(6, 5);
