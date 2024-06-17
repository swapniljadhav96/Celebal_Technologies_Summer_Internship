
-- Step 1: Create the Sales table
CREATE TABLE Sales (
    ProductCategory NVARCHAR(50),
    ProductName NVARCHAR(50),
    SaleAmount DECIMAL(10, 2)
);

-- Step 2: Insert sample data into the Sales table
INSERT INTO Sales (ProductCategory, ProductName, SaleAmount) VALUES
('Electronics', 'Laptop', 1000.00),
('Electronics', 'Phone', 800.00),
('Electronics', 'Tablet', 500.00),
('Clothing', 'Shirt', 300.00),
('Clothing', 'Pants', 400.00),
('Furniture', 'Sofa', 1200.00),
('Furniture', 'Bed', 900.00);

-- Step 3: Generate the sales report using ROLLUP
SELECT
    ProductCategory,
    CASE
        WHEN GROUPING(ProductName) = 1 THEN 'Total'
        ELSE ProductName
    END AS ProductName,
    SUM(SaleAmount) AS TotalSales
FROM Sales
GROUP BY
    ROLLUP(ProductCategory, ProductName)
ORDER BY
    ProductCategory,
    GROUPING(ProductName),
    ProductName;
