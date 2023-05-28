-- create sales  table
CREATE TABLE Sales (
    SalesPersonID INT,
    ProductID INT,
    SaleDate DATE,
    SaleAmount DECIMAL(10, 2)
);


Select * FROM Sales;

-- let's insert some sample data: 
INSERT INTO Sales (SalesPersonID, ProductID, SaleDate, SaleAmount)
VALUES
  (1, 101, '2023-05-07', 1300),
  (1, 102, '2023-05-08', 1400),
  (1, 103, '2023-05-09', 1500),
  (2, 101, '2023-05-07', 1600),
  (2, 102, '2023-05-08', 1700),
  (2, 103, '2023-05-09', 1800),
  (3, 101, '2023-05-07', 1900),
  (3, 102, '2023-05-08', 2000),
  (3, 103, '2023-05-09', 2100),
  (4, 101, '2023-05-10', 2200),
  (4, 102, '2023-05-11', 2300),
  (4, 103, '2023-05-12', 2400),
  (5, 101, '2023-05-10', 2500),
  (5, 102, '2023-05-11', 2600),
  (5, 103, '2023-05-12', 2700),
  (7, 101, '2023-05-10', 2800),
  (6, 102, '2023-05-11', 2900),
  (6, 103, '2023-05-12', 3000),
  (6, 101, '2023-05-13', 3100),
  (7, 102, '2023-05-14', 3200),
  (1, 103, '2023-05-15', 3300);

  --delete  function if it exists
  IF OBJECT_ID('dbo.TotalSales', 'FN') IS NOT NULL
    DROP FUNCTION dbo.TotalSales;
GO

-- create a function to calculate the total sales for a specific salesperson:
CREATE FUNCTION TotalSales(@SalesPersonID INT)
RETURNS DECIMAL(10, 2) AS
BEGIN
    DECLARE @TotalSales DECIMAL(10, 2);

    SELECT @TotalSales = SUM(SaleAmount)
    FROM Sales
    WHERE SalesPersonID = @SalesPersonID;

    RETURN @TotalSales;
END;

GO  -- Ends the batch containing the CREATE FUNCTION statement

-- Call the function and retrieve the result
SELECT dbo.TotalSales(6) AS TotalSales;  -- Replace 1 with the desired SalesPersonID



IF OBJECT_ID('dbo.AverageProductSales', 'P') IS NOT NULL
    DROP PROCEDURE dbo.AverageProductSales;
GO


-- create a stored procedure to calculate the average sales amount per product:
CREATE PROCEDURE AverageProductSales AS
BEGIN
    SELECT ProductID, ROUND(AVG(SaleAmount), 2) AS AverageSale
    FROM Sales
    GROUP BY ProductID;
END;

EXECUTE AverageProductSales;

GO

--calculate the running total of sales for each salesperson, sorted by date
SELECT SalesPersonID, 
       ProductID, 
       SaleDate, 
       SaleAmount,
       SUM(SaleAmount) OVER (PARTITION BY SalesPersonID ORDER BY SaleDate) AS RunningTotal
FROM Sales;

GO

select * FROM Sales;


-- ROW_NUMBER(): Returns the number of a given row, with respect to the window partition
SELECT SalesPersonID, 
       ProductID, 
       SaleDate, 
       SaleAmount,
       ROW_NUMBER() OVER (PARTITION BY SalesPersonID ORDER BY SaleDate) AS RowNumber
FROM Sales;


-- RANK(): Provides the ranking of a row in a window, with the same rank given to equal values.

SELECT SalesPersonID, 
       ProductID, 
       SaleDate, 
       SaleAmount,
       RANK() OVER (PARTITION BY SalesPersonID ORDER BY SaleAmount DESC) AS SalesRank
FROM Sales;

Go

--create a function to get the maximum sale amount for a given product:
CREATE FUNCTION MaxProductSale(@ProductID INT)
RETURNS DECIMAL(10, 2) AS
BEGIN
    DECLARE @MaxSale DECIMAL(10, 2);

    SELECT @MaxSale = MAX(SaleAmount)
    FROM Sales
    WHERE ProductID = @ProductID;

    RETURN @MaxSale;
END;

Go

SELECT dbo.MaxProductSale(102) AS MaxSale; -- SELECT dbo.MaxProductSale(5) AS MaxSale;


-- window function to rank salespeople based on their total sales:
SELECT SalesPersonID,
       SUM(SaleAmount) AS TotalSales,
       RANK() OVER (ORDER BY SUM(SaleAmount) DESC) AS SalesRank
FROM Sales
GROUP BY SalesPersonID;
