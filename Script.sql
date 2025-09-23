CREATE DATABASE pizza_demo_DB;
GO

USE pizza_demo_DB;
GO

-- Bảng User: quản lý đăng nhập và thông tin chung
CREATE TABLE [User] (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) UNIQUE NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    Password NVARCHAR(255) NOT NULL,
    Phone NVARCHAR(20) UNIQUE,
    Role INT NOT NULL -- 1=Admin, 2=Employee, 3=Customer
);

-- Bảng Employee: chỉ lưu thông tin riêng của nhân viên
CREATE TABLE Employee (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    Name NVARCHAR(100) NOT NULL,
    Position NVARCHAR(50) NOT NULL, -- thay vì Role trùng với User
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);

-- Bảng Customer: chỉ lưu thông tin riêng của khách hàng
CREATE TABLE Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    Name NVARCHAR(100) NOT NULL,
    LoyaltyPoint INT DEFAULT 0,
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);

-- Admin
INSERT INTO [User] (Username, Email, Password, Phone, Role)
VALUES ('admin01', 'admin01@pizzastore.com', 'admin123', '0909000001', 1);

-- Employee
INSERT INTO [User] (Username, Email, Password, Phone, Role)
VALUES 
('emp01', 'employee01@pizzastore.com', 'emp123', '0909000002', 2),
('emp02', 'employee02@pizzastore.com', 'emp456', '0909000003', 2);

-- Customer
INSERT INTO [User] (Username, Email, Password, Phone, Role)
VALUES 
('cust01', 'customer01@gmail.com', 'cust123', '0909000004', 3),
('cust02', 'customer02@gmail.com', 'cust456', '0909000005', 3),
('cust03', 'customer03@gmail.com', 'cust789', '0909000006', 3);

INSERT INTO Employee (UserID, Name, Position)
VALUES
(2, 'Nguyen Van A', 'Cashier'),
(3, 'Tran Thi B', 'Waiter');

INSERT INTO Customer (UserID, Name, LoyaltyPoint)
VALUES
(4, 'Le Van C', 10),
(5, 'Pham Thi D', 20),
(6, 'Hoang Van E', 5);
