USE AdventureWorks2019;

--Q1 List of all Customers
SELECT 
    c.CustomerID,
	p.FirstName,
    p.MiddleName,
    p.LastName
FROM 
    Sales.Customer c
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
ORDER BY 
    p.LastName, p.FirstName;



--Q2 List of all customers where company name ending in N
SELECT 
    s.Name AS CompanyName,
	c.CustomerID,
    p.FirstName, 
	p.MiddleName,
    p.LastName
FROM 
    Sales.Customer c
JOIN 
    Sales.Store s ON c.StoreID = s.BusinessEntityID
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE 
    s.Name LIKE '%N';



--Q3 List of all customers who live in Berlin or London
SELECT 
    c.CustomerID,
    p.FirstName,
    p.MiddleName,
    p.LastName,
    a.City
FROM 
    Sales.Customer c
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN 
    Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
JOIN 
    Person.Address a ON bea.AddressID = a.AddressID
WHERE 
    a.City IN ('Berlin', 'London')
ORDER BY 
    a.City, p.LastName, p.FirstName;



--Q4 List of all customers who live in UK or USA
USE AdventureWorks2019;  -- Replace with your database version if different

SELECT 
    c.CustomerID,
    p.FirstName,
    p.MiddleName,
    p.LastName,
    a.City,
    sp.CountryRegionCode
FROM 
    Sales.Customer c
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN 
    Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
JOIN 
    Person.Address a ON bea.AddressID = a.AddressID
JOIN 
    Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN 
    Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE 
    cr.Name IN ('United Kingdom', 'United States')
ORDER BY 
    cr.Name, a.City, p.LastName, p.FirstName;



--Q5 List of all products sorted by product name
SELECT 
    ProductID,
    Name AS ProductName,
    ProductNumber
FROM 
    Production.Product
ORDER BY 
    Name;



--Q6 List of all products where product name starts with an A
SELECT 
    ProductID,
    Name AS ProductName,
    ProductNumber
FROM 
    Production.Product
WHERE 
    Name LIKE 'A%'
ORDER BY 
    Name;



--Q7 List of customers who ever placed an order
SELECT DISTINCT
    c.CustomerID,
    p.FirstName,
    p.MiddleName,
    p.LastName
FROM 
    Sales.Customer c
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN 
    Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
ORDER BY 
    p.LastName, p.FirstName;




--Q8 List of Customers who live in London and have bought chai
SELECT DISTINCT
    c.CustomerID,
    p.FirstName,
    p.MiddleName,
    p.LastName,
    a.City,
    pr.Name AS ProductName
FROM 
    Sales.Customer c
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN 
    Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN 
    Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN 
    Production.Product pr ON sod.ProductID = pr.ProductID
JOIN 
    Person.BusinessEntityAddress bea ON c.PersonID = bea.BusinessEntityID
JOIN 
    Person.Address a ON bea.AddressID = a.AddressID
WHERE 
    a.City = 'London'
    AND pr.Name = 'Chai'
ORDER BY 
    p.LastName, p.FirstName;



--Q9 List of customers who never place an order
SELECT 
    c.CustomerID,
    p.FirstName,
    p.MiddleName,
    p.LastName
FROM 
    Sales.Customer c
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN 
    Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
WHERE 
    soh.SalesOrderID IS NULL
ORDER BY 
    p.LastName, p.FirstName;



--Q10 List of customers who ordered Tofu
SELECT DISTINCT
    c.CustomerID,
    p.FirstName,
    p.MiddleName,
    p.LastName
FROM 
    Sales.Customer c
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN 
    Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN 
    Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN 
    Production.Product pr ON sod.ProductID = pr.ProductID
WHERE 
    pr.Name = 'Tofu'
ORDER BY 
    p.LastName, p.FirstName;



--Q11 Details of first order of the system
SELECT TOP 1
    soh.SalesOrderID,
    soh.OrderDate,
    soh.CustomerID,
    soh.TotalDue,
    p.FirstName,
    p.MiddleName,
    p.LastName,
    a.AddressLine1,
    a.City,
    sp.Name AS StateProvince,
    cr.Name AS CountryRegion
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN 
    Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN 
    Person.BusinessEntityAddress bea ON c.PersonID = bea.BusinessEntityID
JOIN 
    Person.Address a ON bea.AddressID = a.AddressID
JOIN 
    Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN 
    Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
ORDER BY 
    soh.OrderDate ASC;



--Q12 Find the details of most expensive order date
SELECT TOP 1
    soh.SalesOrderID,
    soh.OrderDate,
    soh.CustomerID,
    soh.TotalDue,
    p.FirstName,
    p.MiddleName,
    p.LastName,
    a.AddressLine1,
    a.City,
    sp.Name AS StateProvince,
    cr.Name AS CountryRegion
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN 
    Person.BusinessEntityAddress bea ON c.PersonID = bea.BusinessEntityID
JOIN 
    Person.Address a ON bea.AddressID = a.AddressID
JOIN 
    Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN 
    Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
ORDER BY 
    soh.TotalDue DESC;



--Q13 For each order get the OrderID and Average quantity of items in that order
USE AdventureWorks2019; -- Replace with your database version if different

SELECT
    SalesOrderID,
    AVG(OrderQty) AS AverageQuantity
FROM 
    Sales.SalesOrderDetail
GROUP BY 
    SalesOrderID
ORDER BY 
    SalesOrderID;



--Q14 For each order get the orderID, minimum quantity and maximum quantity for that order
SELECT
    SalesOrderID,
    MIN(OrderQty) AS MinimumQuantity,
    MAX(OrderQty) AS MaximumQuantity
FROM 
    Sales.SalesOrderDetail
GROUP BY 
    SalesOrderID
ORDER BY 
    SalesOrderID;



--Q15 Get a list of all managers and total number of employees who report to them.
WITH EmployeeHierarchy AS (
    SELECT 
        e.BusinessEntityID,
        e.OrganizationNode,
        e.OrganizationLevel,
        e.JobTitle,
        p.FirstName,
        p.MiddleName,
        p.LastName
    FROM 
        HumanResources.Employee e
    JOIN 
        Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
),
Managers AS (
    SELECT 
        eh1.BusinessEntityID AS ManagerID,
        eh1.FirstName AS ManagerFirstName,
        eh1.MiddleName AS ManagerMiddleName,
        eh1.LastName AS ManagerLastName,
        COUNT(eh2.BusinessEntityID) AS TotalEmployees
    FROM 
        EmployeeHierarchy eh1
    LEFT JOIN 
        EmployeeHierarchy eh2 ON eh2.OrganizationNode.IsDescendantOf(eh1.OrganizationNode) = 1
    WHERE 
        eh1.JobTitle LIKE '%Manager%'
    GROUP BY 
        eh1.BusinessEntityID, eh1.FirstName, eh1.MiddleName, eh1.LastName
)
SELECT 
    ManagerID,
    ManagerFirstName,
    ManagerMiddleName,
    ManagerLastName,
    TotalEmployees
FROM 
    Managers
ORDER BY 
    TotalEmployees DESC, ManagerLastName, ManagerFirstName;



--Q16 Get the OrderID and the total quantity for each order that has a total quantity of greater than 300
SELECT
    SalesOrderID,
    SUM(OrderQty) AS TotalQuantity
FROM 
    Sales.SalesOrderDetail
GROUP BY 
    SalesOrderID
HAVING 
    SUM(OrderQty) > 300;



--Q17 List of all orders placed on or after 1996/12/31
SELECT
    SalesOrderID,
    OrderDate
FROM 
    Sales.SalesOrderHeader
WHERE 
    OrderDate >= '1996-12-31';



--Q18 List of all orders shipped to Canada
SELECT
    soh.SalesOrderID,
    soh.OrderDate,
    a.AddressLine1,
    a.City,
    sp.Name AS StateProvince,
    cr.Name AS CountryRegion
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN 
    Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN 
    Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE 
    cr.Name = 'Canada';



--Q19 List of all orders with order total > 200
SELECT
    SalesOrderID,
    OrderDate,
    TotalDue
FROM 
    Sales.SalesOrderHeader
WHERE 
    TotalDue > 200.00;



--Q20 List of countries and sales made in each country
SELECT
    cr.Name AS Country,
    SUM(soh.TotalDue) AS TotalSales
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN 
    Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN 
    Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY 
    cr.Name
ORDER BY 
    TotalSales DESC;



--Q21 List of Customer ContactName and number of orders they placed
SELECT
    p.FirstName + ' ' + ISNULL(p.MiddleName + ' ', '') + p.LastName AS ContactName,
    COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM 
    Sales.Customer c
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN 
    Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY 
    p.FirstName, p.MiddleName, p.LastName
ORDER BY 
    NumberOfOrders DESC, ContactName;



--Q22 List of customer contactnames who have placed more than 3 orders
SELECT
    p.FirstName + ' ' + ISNULL(p.MiddleName + ' ', '') + p.LastName AS ContactName,
    COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM 
    Sales.Customer c
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN 
    Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY 
    p.FirstName, p.MiddleName, p.LastName
HAVING 
    COUNT(soh.SalesOrderID) > 3
ORDER BY 
    NumberOfOrders DESC, ContactName;



--Q23 List of discontinued products which ordered between 1/1/1997 and 1/1/1998
SELECT DISTINCT
    p.ProductID,
    p.Name AS ProductName,
    p.DiscontinuedDate,
    soh.OrderDate
FROM 
    Production.Product p
JOIN 
    Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
JOIN 
    Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE 
    p.DiscontinuedDate IS NOT NULL
    AND soh.OrderDate >= '1997-01-01' 
    AND soh.OrderDate < '1998-01-01';



--Q24 List of employee firsname, lastName, superviser FirstName, LastName
SELECT e.BusinessEntityID AS EmployeeID,
       ep.FirstName AS EmployeeFirstName,
       ep.LastName AS EmployeeLastName,
       s.BusinessEntityID AS SupervisorID,
       sp.FirstName AS SupervisorFirstName,
       sp.LastName AS SupervisorLastName
FROM HumanResources.Employee AS e
LEFT JOIN HumanResources.Employee AS s ON e.OrganizationNode.GetAncestor(1) = s.OrganizationNode
JOIN Person.Person AS ep ON e.BusinessEntityID = ep.BusinessEntityID
LEFT JOIN Person.Person AS sp ON s.BusinessEntityID = sp.BusinessEntityID;



--Q25 List of Employees id and total sale condcuted by employee
SELECT
    sp.BusinessEntityID AS EmployeeID,
    p.FirstName + ' ' + ISNULL(p.MiddleName + ' ', '') + p.LastName AS EmployeeName,
    SUM(soh.TotalDue) AS TotalSales
FROM 
    Sales.SalesPerson sp
JOIN 
    Person.Person p ON sp.BusinessEntityID = p.BusinessEntityID
JOIN 
    Sales.SalesOrderHeader soh ON sp.BusinessEntityID = soh.SalesPersonID
GROUP BY 
    sp.BusinessEntityID, p.FirstName, p.MiddleName, p.LastName
ORDER BY 
    TotalSales DESC, EmployeeName;


--Q26 List of employees whose FirstName contains character a
SELECT
    BusinessEntityID,
    FirstName,
    LastName
FROM 
    Person.Person
WHERE 
    FirstName LIKE '%a%';



--Q27 List of managers who have more than four people reporting to them.
SELECT 
    s.BusinessEntityID AS ManagerID,
    ps.FirstName AS ManagerFirstName,
    ps.LastName AS ManagerLastName,
    COUNT(e.BusinessEntityID) AS NumReports
FROM HumanResources.Employee AS e
JOIN HumanResources.Employee AS s ON e.OrganizationNode.GetAncestor(1) = s.OrganizationNode
JOIN Person.Person AS ps ON s.BusinessEntityID = ps.BusinessEntityID
GROUP BY s.BusinessEntityID, ps.FirstName, ps.LastName
HAVING COUNT(e.BusinessEntityID) > 4;



--Q28 List of Orders and ProductNames
SELECT 
    soh.SalesOrderID,
    p.Name AS ProductName
FROM 
    Sales.SalesOrderHeader AS soh
JOIN 
    Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN 
    Production.Product AS p ON sod.ProductID = p.ProductID;


--Q29 List of orders place by the best customer
WITH BestCustomer AS (
    SELECT TOP 1
        c.CustomerID
    FROM 
        Sales.Customer c
    JOIN 
        Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
    GROUP BY 
        c.CustomerID
    ORDER BY 
        SUM(soh.TotalDue) DESC
)

SELECT 
    soh.SalesOrderID,
    soh.OrderDate,
    soh.TotalDue
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    BestCustomer bc ON soh.CustomerID = bc.CustomerID;



--Q30 List of orders placed by customers who do not have a Fax number
SELECT so.SalesOrderID,
       so.OrderDate,
       c.CustomerID,
       p.FirstName,
       p.LastName
FROM Sales.SalesOrderHeader AS so
JOIN Sales.Customer AS c ON so.CustomerID = c.CustomerID
LEFT JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Person.PersonPhone AS pp ON p.BusinessEntityID = pp.BusinessEntityID
LEFT JOIN Person.PersonPhone AS pf ON p.BusinessEntityID = pf.BusinessEntityID AND pf.PhoneNumberTypeID = 3 -- Assuming PhoneNumberTypeID = 3 is for Fax
WHERE pf.BusinessEntityID IS NULL;



--Q31 List of Postal codes where the product Tofu was shipped
SELECT DISTINCT
    Address.PostalCode
FROM 
    Sales.SalesOrderHeader AS OrderHeader
JOIN 
    Sales.SalesOrderDetail AS OrderDetail ON OrderHeader.SalesOrderID = OrderDetail.SalesOrderID
JOIN 
    Production.Product AS Product ON OrderDetail.ProductID = Product.ProductID
JOIN 
    Person.Address AS Address ON OrderHeader.ShipToAddressID = Address.AddressID
WHERE 
    Product.Name = 'Tofu';



--Q32 List of product Names that were shipped to France 
SELECT DISTINCT
    Product.Name AS ProductName
FROM 
    Sales.SalesOrderHeader AS OrderHeader
JOIN 
    Sales.SalesOrderDetail AS OrderDetail ON OrderHeader.SalesOrderID = OrderDetail.SalesOrderID
JOIN 
    Production.Product AS Product ON OrderDetail.ProductID = Product.ProductID
JOIN 
    Person.Address AS Address ON OrderHeader.ShipToAddressID = Address.AddressID
JOIN 
    Person.StateProvince AS StateProv ON Address.StateProvinceID = StateProv.StateProvinceID
JOIN 
    Person.CountryRegion AS Country ON StateProv.CountryRegionCode = Country.CountryRegionCode
WHERE 
    Country.Name = 'France';



--Q33 List of ProductNames and Categories for the supplier 'Specialty Biscuits, Ltd.
SELECT 
    Product.Name AS ProductName,
    Category.Name AS CategoryName
FROM 
    Production.Product AS Product
JOIN 
    Production.ProductSubcategory AS Subcategory ON Product.ProductSubcategoryID = Subcategory.ProductSubcategoryID
JOIN 
    Production.ProductCategory AS Category ON Subcategory.ProductCategoryID = Category.ProductCategoryID
JOIN 
    Purchasing.ProductVendor AS Vendor ON Product.ProductID = Vendor.ProductID
JOIN 
    Purchasing.Vendor AS Supplier ON Vendor.BusinessEntityID = Supplier.BusinessEntityID
WHERE 
    Supplier.Name = 'Specialty Biscuits, Ltd.';



--Q34 List of products that were never ordered
SELECT 
    p.Name AS ProductName
FROM 
    Production.Product p
LEFT JOIN 
    Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
WHERE 
    sod.ProductID IS NULL;



--Q35 List of products where units in stock is less than 10 and units on order are 0.
SELECT ProductID, Name
FROM Production.Product
WHERE SafetyStockLevel < 10 AND ReorderPoint = 0;



--Q36 List of top 10 countries by sales
SELECT TOP 10
    sp.CountryRegionCode AS Country,
    SUM(soh.TotalDue) AS TotalSales
FROM 
    Sales.SalesOrderHeader AS soh
JOIN 
    Sales.Customer AS c ON soh.CustomerID = c.CustomerID
JOIN 
    Person.Address AS a ON c.CustomerID = a.AddressID
JOIN 
    Person.StateProvince AS sp ON a.StateProvinceID = sp.StateProvinceID
GROUP BY 
    sp.CountryRegionCode
ORDER BY 
    TotalSales DESC;



--Q37 Number of orders each employee has taken for customers with CustomerIDs between A and AO
SELECT e.BusinessEntityID AS EmployeeID, 
       p.FirstName, 
       p.LastName, 
       COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM HumanResources.Employee AS e
JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader AS soh ON e.BusinessEntityID = soh.SalesPersonID
JOIN Sales.Customer AS c ON soh.CustomerID = c.CustomerID
WHERE CAST(c.CustomerID AS INT) BETWEEN 1 AND 40  -- Assuming 'A' to 'AO' corresponds to CustomerID range 1 to 40
GROUP BY e.BusinessEntityID, p.FirstName, p.LastName;



--Q38 Orderdate of most expensive order
SELECT 
    soh.OrderDate
FROM 
    Sales.SalesOrderHeader AS soh
JOIN 
    (SELECT TOP 1
         SalesOrderID
     FROM 
         Sales.SalesOrderHeader
     ORDER BY 
         TotalDue DESC) AS max_order ON soh.SalesOrderID = max_order.SalesOrderID;



--Q39 Product name and total revenue from that product
SELECT 
    p.Name AS ProductName,
    SUM(sod.UnitPrice * sod.OrderQty) AS TotalRevenue
FROM 
    Sales.SalesOrderDetail sod
JOIN 
    Production.Product p ON sod.ProductID = p.ProductID
GROUP BY 
    p.Name
ORDER BY 
    TotalRevenue DESC;



--Q40 Supplierid and number of products offered
SELECT 
    BusinessEntityID AS SupplierID,
    COUNT(ProductID) AS NumberOfProductsOffered
FROM 
    Purchasing.ProductVendor
GROUP BY 
    BusinessEntityID
ORDER BY 
    NumberOfProductsOffered DESC;



--Q41 Top ten customers based on their business
SELECT TOP 10
    c.CustomerID,
    p.FirstName,
    p.LastName,
    SUM(soh.TotalDue) AS TotalSalesAmount
FROM 
    Sales.Customer AS c
JOIN 
    Person.Person AS p ON c.PersonID = p.BusinessEntityID
JOIN 
    Sales.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
GROUP BY 
    c.CustomerID, p.FirstName, p.LastName
ORDER BY 
    TotalSalesAmount DESC;



--Q42 What is the total revenue of the company.
SELECT 
    SUM(TotalDue) AS TotalRevenue
FROM 
    Sales.SalesOrderHeader;


