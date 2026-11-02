-- EXPERIMENT 2 | FACT TABLE & DIMENSION TABLE IMPLEMENTATION
-- Extracted exactly from the pgAdmin screenshots in 10605_KOMAL_DWM_EXP2.pdf
-- NOTE: Case Study 1 and Case Study 2 both use DimCustomer and DimDate, so run
--       each case study in a separate database/schema (or drop the tables between).
-- Lines marked [NOT VISIBLE IN PDF] were cut off / missing in the screenshots and are
-- reconstructed from the visible output columns. Compare them with your own file.


-- ##########################################################
-- CASE STUDY 1: ONLINE BANKING DATA WAREHOUSE (STAR SCHEMA)
-- ##########################################################

-- ============ 1. DIMENSION TABLES ============

-- 1. Customer Dimension
CREATE TABLE DimCustomer (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    Gender VARCHAR(10),
    City VARCHAR(50),
    State VARCHAR(50)
);

INSERT INTO DimCustomer VALUES
(1,'Rahul Sharma','M','Mumbai','Maharashtra'),
(2,'Priya Patel','F','Ahmedabad','Gujarat'),
(3,'Amit Verma','M','Delhi','Delhi'),
(4,'Sneha Joshi','F','Pune','Maharashtra'),
(5,'Rohan Mehta','M','Surat','Gujarat');

-- 2. Account Dimension
CREATE TABLE DimAccount (
    AccountID INT PRIMARY KEY,
    AccountNumber VARCHAR(20),
    AccountType VARCHAR(20),
    AccountStatus VARCHAR(20)
);

INSERT INTO DimAccount VALUES
(1,'ACC1001','Savings','Active'),
(2,'ACC1002','Current','Active'),
(3,'ACC1003','Savings','Inactive'),
(4,'ACC1004','Current','Active'),
(5,'ACC1005','Savings','Active');

-- 3. Branch Dimension
CREATE TABLE DimBranch (
    BranchID INT PRIMARY KEY,
    BranchName VARCHAR(100),
    City VARCHAR(50),
    State VARCHAR(50)
);

INSERT INTO DimBranch VALUES
(1,'Mumbai Main','Mumbai','Maharashtra'),
(2,'Ahmedabad Central','Ahmedabad','Gujarat'),
(3,'Delhi Branch','Delhi','Delhi');

-- 4. Transaction Type Dimension
CREATE TABLE DimTransactionType (
    TransactionTypeID INT PRIMARY KEY,
    TransactionType VARCHAR(30)
);

INSERT INTO DimTransactionType VALUES
(1,'Deposit'),
(2,'Withdrawal'),
(3,'Transfer'),
(4,'Bill Payment');

-- 5. Date Dimension   [NOT VISIBLE IN PDF - reconstructed, needed by queries 1 and 14]
CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,
    FullDate DATE,
    Day INT,
    Month INT,
    Quarter INT,
    Year INT
);

INSERT INTO DimDate VALUES
(20260701,'2026-07-01',1,7,3,2026),
(20260702,'2026-07-02',2,7,3,2026),
(20260703,'2026-07-03',3,7,3,2026),
(20260704,'2026-07-04',4,7,3,2026),
(20260705,'2026-07-05',5,7,3,2026);

-- (Time Dimension - screenshot shown under "Date Dimension" heading)
CREATE TABLE DimTime (
    TimeKey INT PRIMARY KEY,
    TimeSlot VARCHAR(30)
);

INSERT INTO DimTime VALUES
(1,'09:00-10:00'),
(2,'10:00-11:00'),
(3,'11:00-12:00'),
(4,'12:00-01:00'),
(5,'02:00-03:00');

-- ============ 2. FACT TABLE ============
-- 7. Fact Table   [top of CREATE TABLE NOT VISIBLE IN PDF - reconstructed from column headers + visible FKs]
CREATE TABLE FactTransaction (
    TransactionID INT PRIMARY KEY,
    CustomerID INT,
    AccountID INT,
    BranchID INT,
    DateKey INT,
    TimeKey INT,
    TransactionTypeID INT,
    Amount NUMERIC(10,2),
    BalanceAfterTransaction NUMERIC(10,2),
    TransactionFee NUMERIC(10,2),

    FOREIGN KEY(CustomerID) REFERENCES DimCustomer(CustomerID),

    FOREIGN KEY(AccountID) REFERENCES DimAccount(AccountID),

    FOREIGN KEY(BranchID) REFERENCES DimBranch(BranchID),

    FOREIGN KEY(DateKey) REFERENCES DimDate(DateKey),

    FOREIGN KEY(TimeKey) REFERENCES DimTime(TimeKey),

    FOREIGN KEY(TransactionTypeID) REFERENCES DimTransactionType(TransactionTypeID)

);

SELECT * FROM FactTransaction

INSERT INTO FactTransaction VALUES
(1,1,1,1,20260701,1,1,5000,25000,0),
(2,2,2,2,20260701,2,2,2000,18000,10),
(3,3,3,3,20260702,3,3,7000,32000,20),
(4,4,4,1,20260703,4,1,10000,45000,0),
(5,5,5,2,20260704,5,4,1500,12000,15),
(6,1,1,1,20260705,2,2,3000,22000,10);

SELECT * FROM FactTransaction

-- ============ 3. THE 15 ANALYTICAL QUERIES ============

-- 1. Total transaction amount by year
SELECT d.Year,
SUM(f.Amount) AS TotalAmount
FROM FactTransaction f
JOIN DimDate d ON f.DateKey=d.DateKey
GROUP BY d.Year;

-- 2. Total transaction amount by branch
SELECT b.BranchName,
SUM(f.Amount) AS TotalAmount
FROM FactTransaction f
JOIN DimBranch b ON f.BranchID=b.BranchID
GROUP BY b.BranchName;

-- 3. Total amount transacted by customer
SELECT c.CustomerName,
SUM(f.Amount) AS TotalAmount
FROM FactTransaction f
JOIN DimCustomer c ON f.CustomerID=c.CustomerID
GROUP BY c.CustomerName;

-- 4. Average transaction amount by account type
SELECT a.AccountType,
AVG(f.Amount) AS AvgAmount
FROM FactTransaction f
JOIN DimAccount a ON f.AccountID=a.AccountID
GROUP BY a.AccountType;

-- 5. Total amount by transaction type
SELECT t.TransactionType,
SUM(f.Amount) AS TotalAmount
FROM FactTransaction f
JOIN DimTransactionType t
ON f.TransactionTypeID=t.TransactionTypeID
GROUP BY t.TransactionType;

-- 6. Previous transaction amount (LAG)
SELECT CustomerID,
Amount,
LAG(Amount) OVER
(PARTITION BY CustomerID ORDER BY DateKey) AS PreviousAmount
FROM FactTransaction;

-- 7. Next transaction amount (LEAD)
SELECT CustomerID,
Amount,
LEAD(Amount) OVER
(PARTITION BY CustomerID ORDER BY DateKey) AS NextAmount
FROM FactTransaction;

-- 8. Rank customers by transaction amount
SELECT CustomerID,
SUM(Amount) AS TotalAmount,
RANK() OVER
(ORDER BY SUM(Amount) DESC) AS Ranking
FROM FactTransaction
GROUP BY CustomerID;

-- 9. Dense Rank
SELECT CustomerID,
SUM(Amount) AS TotalAmount,
DENSE_RANK() OVER
(ORDER BY SUM(Amount) DESC) AS Ranking
FROM FactTransaction
GROUP BY CustomerID;

-- 10. Running total
SELECT DateKey,
Amount,
SUM(Amount) OVER
(ORDER BY DateKey) AS RunningTotal
FROM FactTransaction;

-- 11. Top transaction group (NTILE)
SELECT TransactionID,
Amount,
NTILE(3) OVER
(ORDER BY Amount DESC) AS Tier
FROM FactTransaction;

-- 12. First transaction of every customer
SELECT CustomerID,
FIRST_VALUE(Amount) OVER
(PARTITION BY CustomerID ORDER BY DateKey) AS FirstTransaction
FROM FactTransaction;

-- 13. Last transaction of every customer
SELECT CustomerID,
LAST_VALUE(Amount) OVER(
PARTITION BY CustomerID
ORDER BY DateKey
ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
) AS LastTransaction
FROM FactTransaction;

-- 14. Monthly transaction summary
SELECT d.Month,
SUM(f.Amount) AS TotalAmount
FROM FactTransaction f
JOIN DimDate d
ON f.DateKey=d.DateKey
GROUP BY d.Month;

-- 15. Top 5 highest transactions
SELECT *
FROM FactTransaction
ORDER BY Amount DESC
LIMIT 5;



