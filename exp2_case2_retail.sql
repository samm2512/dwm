-- ##########################################################
-- CASE STUDY 2: RETAIL SALES DATA WAREHOUSE (STAR SCHEMA)
-- ##########################################################

-- ============ 1. DIMENSION TABLES ============

-- 1. Create Customer Dimension
CREATE TABLE DimCustomer (
    CustomerID INT PRIMARY KEY,
    CustomerAltID VARCHAR(10) NOT NULL,
    CustomerName VARCHAR(50),
    Gender VARCHAR(10)
);

INSERT INTO DimCustomer(CustomerID, CustomerAltID, CustomerName, Gender)   -- [column list cut off in PDF]
VALUES
(1,'IMI-001','Varad Joshi','M'),
(2,'IMI-002','Parth Salankar','M'),
(3,'IMI-003','Anushka Kedare','F'),
(4,'IMI-004','Kenrich Dontknow','M'),
(5,'IMI-005','Shravani Dbritto','F');

-- 2. Product Dimension
CREATE TABLE DimProduct (
    ProductID INT PRIMARY KEY,
    ProductKey VARCHAR(10),
    ProductName VARCHAR(100),
    ProductActualCost DECIMAL(10,2),
    ProductSalesCost DECIMAL(10,2)
);

INSERT INTO DimProduct VALUES
(1,'PRD-001','Laptop',45000,50000),
(2,'PRD-002','Wireless Mouse',500,700),
(3,'PRD-003','Mechanical Keyboard',1800,2500),
(4,'PRD-004','USB Pendrive 64GB',600,900),
(5,'PRD-005','Bluetooth Headphones',2200,3000);

-- 3. Store Dimension
CREATE TABLE DimStores (
    StoreID INT PRIMARY KEY,
    StoreAltID VARCHAR(10),
    StoreName VARCHAR(100),
    StoreLocation VARCHAR(100),
    City VARCHAR(50),
    State VARCHAR(50),
    Country VARCHAR(50)
);

-- [rows cut off at right edge in PDF - Country value reconstructed as 'India']
INSERT INTO DimStores VALUES
(1,'ST-001','TechWorld','Andheri','Mumbai','Maharashtra','India'),
(2,'ST-002','Digital Hub','Shivaji Nagar','Pune','Maharashtra','India'),
(3,'ST-003','Gadget Store','Bandra','Mumbai','Maharashtra','India');

-- 4. SalesPerson Dimension   [first 2 lines of CREATE cut off in PDF - reconstructed]
CREATE TABLE DimSalesPerson (
    SalesPersonID INT PRIMARY KEY,
    SalesPersonAltID VARCHAR(10),
    SalesPersonName VARCHAR(50),
    StoreID INT,
    City VARCHAR(50),
    State VARCHAR(50),
    Country VARCHAR(50)
);

INSERT INTO DimSalesPerson VALUES
(1,'SP001','Rahul',1,'Mumbai','Maharashtra','India'),
(2,'SP002','Priya',1,'Mumbai','Maharashtra','India'),
(3,'SP003','Amit',2,'Pune','Maharashtra','India'),
(4,'SP004','Sneha',2,'Pune','Maharashtra','India'),
(5,'SP005','Rohan',3,'Mumbai','Maharashtra','India'),
(6,'SP006','Neha',3,'Mumbai','Maharashtra','India');

-- 5. Date Dimension
CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,
    FullDate DATE,
    Day INT,
    Month INT,
    Quarter INT,
    Year INT
);

INSERT INTO DimDate VALUES
(20260801,'2026-08-01',1,8,3,2026),
(20260802,'2026-08-02',2,8,3,2026),
(20260803,'2026-08-03',3,8,3,2026),
(20260804,'2026-08-04',4,8,3,2026),
(20260805,'2026-08-05',5,8,3,2026);

-- 6. Time Dimension
CREATE TABLE DimTime (
    TimeKey INT PRIMARY KEY,
    TimeAltKey INT,
    TimeSlot VARCHAR(30)
);

INSERT INTO DimTime VALUES
(101,900,'09:00 AM - 10:00 AM'),
(102,1030,'10:30 AM - 11:30 AM'),
(103,1200,'12:00 PM - 01:00 PM'),
(104,1400,'02:00 PM - 03:00 PM'),
(105,1600,'04:00 PM - 05:00 PM');

-- ============ 2. FACT TABLE ============
-- 7. Fact Table   [top of CREATE TABLE + last 3 column names NOT VISIBLE IN PDF - reconstructed]
CREATE TABLE FactProductSales (
    TransactionID INT PRIMARY KEY,
    SalesInvoiceNumber INT,
    SalesDateKey INT,
    SalesTimeKey INT,
    SalesTimeAltKey INT,
    StoreID INT,
    CustomerID INT,
    ProductID INT,
    SalesPersonID INT,
    Quantity DOUBLE PRECISION,
    ProductActualCost DECIMAL(10,2),
    SalesTotalCost DECIMAL(10,2),
    Profit DECIMAL(10,2),

    FOREIGN KEY (StoreID) REFERENCES DimStores(StoreID),

    FOREIGN KEY (CustomerID) REFERENCES DimCustomer(CustomerID),

    FOREIGN KEY (ProductID) REFERENCES DimProduct(ProductID),

    FOREIGN KEY (SalesPersonID) REFERENCES DimSalesPerson(SalesPersonID),

    FOREIGN KEY (SalesDateKey) REFERENCES DimDate(DateKey),

    FOREIGN KEY (SalesTimeKey) REFERENCES DimTime(TimeKey)

);

INSERT INTO FactProductSales VALUES
(1,1001,20260801,101,900,1,1,1,1,1,45000,50000,5000),
(2,1002,20260801,102,1030,1,2,2,2,2,500,1400,400),
(3,1003,20260802,103,1200,2,3,3,3,1,1800,2500,700),
(4,1004,20260803,104,1400,2,4,4,4,3,600,2700,900),
(5,1005,20260804,105,1600,3,5,5,5,2,2200,6000,1600),
(6,1006,20260805,101,900,3,1,2,6,4,500,2800,800);

SELECT * FROM FactProductSales

-- ============ 3. THE 15 ANALYTICAL QUERIES ============

-- 1. Total Sales by Year
SELECT D.Year,
SUM(F.SalesTotalCost) AS TotalSales
FROM FactProductSales F
JOIN DimDate D
ON F.SalesDateKey = D.DateKey
GROUP BY D.Year;

-- 2. Total Sales by Store
SELECT S.StoreName,
SUM(F.SalesTotalCost) AS TotalSales
FROM FactProductSales F
JOIN DimStores S
ON F.StoreID = S.StoreID
GROUP BY S.StoreName;

-- 3. Total Sales by Customer
SELECT C.CustomerName,
SUM(F.SalesTotalCost) AS TotalSales
FROM FactProductSales F
JOIN DimCustomer C
ON F.CustomerID = C.CustomerID
GROUP BY C.CustomerName;

-- 4. Average Sales by Product
SELECT P.ProductName,
AVG(F.SalesTotalCost) AS AverageSales
FROM FactProductSales F
JOIN DimProduct P
ON F.ProductID = P.ProductID
GROUP BY P.ProductName;

-- 5. Total Sales by Product
SELECT P.ProductName,
SUM(F.SalesTotalCost) AS TotalSales
FROM FactProductSales F
JOIN DimProduct P
ON F.ProductID = P.ProductID
GROUP BY P.ProductName;

-- 6. Previous Sales using LAG()
SELECT CustomerID,
SalesTotalCost,
LAG(SalesTotalCost) OVER
(PARTITION BY CustomerID ORDER BY SalesDateKey) AS PreviousSales
FROM FactProductSales;

-- 7. Next Sales using LEAD()
SELECT CustomerID,
SalesTotalCost,
LEAD(SalesTotalCost) OVER
(PARTITION BY CustomerID ORDER BY SalesDateKey) AS NextSales
FROM FactProductSales;

-- 8. Rank Products by Revenue
SELECT ProductID,
SUM(SalesTotalCost) AS TotalRevenue,
RANK() OVER
(ORDER BY SUM(SalesTotalCost) DESC) AS Ranking
FROM FactProductSales
GROUP BY ProductID;

-- 9. Dense Rank Products
SELECT ProductID,
SUM(SalesTotalCost) AS TotalRevenue,
DENSE_RANK() OVER
(ORDER BY SUM(SalesTotalCost) DESC) AS Ranking
FROM FactProductSales
GROUP BY ProductID;

-- 10. Running Total of Sales
SELECT SalesDateKey,
SalesTotalCost,
SUM(SalesTotalCost) OVER
(ORDER BY SalesDateKey) AS RunningTotal
FROM FactProductSales;

-- 11. Sales Tiers using NTILE()
SELECT TransactionId,
SalesTotalCost,
NTILE(3) OVER
(ORDER BY SalesTotalCost DESC) AS SalesTier
FROM FactProductSales;

-- 12. First Product Sold to Each Customer
SELECT C.CustomerName,
FIRST_VALUE(P.ProductName) OVER
(PARTITION BY C.CustomerID ORDER BY D.FullDate) AS FirstProduct
FROM FactProductSales F
JOIN DimCustomer C
ON F.CustomerID = C.CustomerID
JOIN DimProduct P
ON F.ProductID = P.ProductID
JOIN DimDate D
ON F.SalesDateKey = D.DateKey;

-- 13. Last Sales Value of Each Customer
SELECT CustomerID,
LAST_VALUE(SalesTotalCost) OVER(
PARTITION BY CustomerID
ORDER BY SalesDateKey
ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
) AS LastSale
FROM FactProductSales;

-- 14. Monthly Sales Summary
SELECT D.Month,
SUM(F.SalesTotalCost) AS MonthlySales
FROM FactProductSales F
JOIN DimDate D
ON F.SalesDateKey = D.DateKey
GROUP BY D.Month;

-- 15. Top 5 Highest Sales
SELECT *
FROM FactProductSales
ORDER BY SalesTotalCost DESC
LIMIT 5;