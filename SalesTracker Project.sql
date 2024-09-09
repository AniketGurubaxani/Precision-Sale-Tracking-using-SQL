/* Topic
 Precision Sales Tracking
*/

-- DATABASE CREATION

DROP DATABASE IF EXISTS SalesTracker;
CREATE DATABASE IF NOT EXISTS SalesTracker;
USE SalesTracker;
-- CREATEION OF TABLES

-- Category
DROP TABLE IF EXISTS Category;
CREATE TABLE IF NOT EXISTS Category(
    Category_Id INT PRIMARY KEY,
    Category_Name VARCHAR(50) NOT NULL UNIQUE
);

-- Products
DROP TABLE IF EXISTS Products;
CREATE TABLE IF NOT EXISTS Products (
    Product_Id INT PRIMARY KEY,
    Product_Name VARCHAR(150) NOT NULL,
    Category_Id INT,
    Category_Name VARCHAR(50),
    Price DECIMAL(10 , 2 ) CHECK (Price > 0),
    FOREIGN KEY (Category_Id) REFERENCES Category(Category_Id)
);

-- Customers
DROP TABLE IF EXISTS Customers;
CREATE TABLE IF NOT EXISTS Customers (
    Customer_Id INT PRIMARY KEY,
    Customer_Name VARCHAR(100) NOT NULL,
    City VARCHAR(30),
    State VARCHAR(20),
    Pin_Code INT NOT NULL
);

-- Sales Person
DROP TABLE IF EXISTS Sales_Person;
CREATE TABLE IF NOT EXISTS Sales_Person (
    SalesPerson_Id INT PRIMARY KEY,
    Name VARCHAR(100)
);

-- Sales
DROP TABLE IF EXISTS Sales;
CREATE TABLE IF NOT EXISTS Sales (
    Sale_Id INT PRIMARY KEY AUTO_INCREMENT,
    Product_Id INT NOT NULL,
    Customer_Id INT NOT NULL,
    Sale_Date DATE NOT NULL,
    Quantity INT NOT NULL,
    Total_Price DECIMAL(10 , 2 ) CHECK (Total_Price > 0),
    Sales_Region VARCHAR(50),
    SalesPerson_Id INT,
    FOREIGN KEY (Product_Id)
        REFERENCES Products (Product_Id),
    FOREIGN KEY (Customer_Id)
        REFERENCES Customers (Customer_Id),
    FOREIGN KEY (SalesPerson_Id)
        REFERENCES Sales_Person (SalesPerson_Id)
);

-- Trigger for calculating total Price for each row

DELIMITER //

CREATE TRIGGER CalculateTotalPrice
BEFORE INSERT ON Sales
FOR EACH ROW
BEGIN
    DECLARE prod_price DECIMAL(10, 2);
SELECT 
    Price
INTO prod_price FROM
    Products
WHERE
    Product_Id = NEW.Product_Id;
    SET NEW.Total_Price = NEW.Quantity * prod_price;
END //

DELIMITER ;

-- Indexes for optimizing performances
-- for products table
CREATE INDEX idx_product_id ON Sales (Product_Id);

-- for customers table
CREATE INDEX idx_customer_id ON Sales (Customer_Id);

-- Views for Summarizing reports on Sales

-- Daily Sales
CREATE VIEW DailySales AS
    SELECT 
        sale_date,
        SUM(Quantity) AS Total_Quantity,
        SUM(Total_Price) AS Total_Sales
    FROM
        Sales
    GROUP BY sale_date;

-- Weekly Sales

CREATE VIEW WeeklySales AS
    SELECT 
        YEARWEEK(Sale_Date, 1) AS Year_Week,
        SUM(Quantity) AS Total_Quantity,
        SUM(Total_Price) AS Total_Sales
    FROM
        Sales
    GROUP BY YEARWEEK(Sale_Date, 1);
    
-- Monthly Sales

CREATE VIEW MonthlySales AS
    SELECT 
        YEAR(Sale_Date) AS Year,
        MONTH(Sale_Date) AS Month,
        SUM(Quantity) AS Total_Quantity,
        SUM(Total_Price) AS Total_Sales
    FROM
        Sales
    GROUP BY YEAR(Sale_Date) , MONTH(Sale_Date);

-- Stored Procedure for data insertion

DELIMITER //
CREATE PROCEDURE AddSale(
    IN p_Product_Id INT,
    IN p_Customer_Id INT,
    IN p_Quantity INT,
    IN p_SalesPerson_Id INT,
    IN p_SalesRegion VARCHAR(50),
    IN p_Sale_Date DATE
)
BEGIN
    DECLARE p_Price DECIMAL(10, 2);
    
    SELECT Price INTO p_Price FROM Products WHERE Product_Id = p_Product_Id;

    INSERT INTO Sales (Product_Id, Customer_Id, Sale_Date, Quantity, Total_Price, Sales_Region, SalesPerson_Id)
    VALUES (p_Product_Id, p_Customer_Id, p_Sale_Date, p_Quantity, p_Quantity * p_Price, p_SalesRegion, p_SalesPerson_Id);
END//

DELIMITER ;