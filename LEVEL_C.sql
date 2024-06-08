
--Q.Task 1

-- Step 1: Define the table for testing purposes

CREATE TABLE Projects (
    Task_ID INT,
    Start_Date DATE,
    End_Date DATE
);

-- Step 2: Insert sample data into the Projects table

INSERT INTO Projects (Task_ID, Start_Date, End_Date) VALUES
(1, '2015-10-01', '2015-10-02'),
(2, '2015-10-02', '2015-10-03'),
(3, '2015-10-03', '2015-10-04'),
(4, '2015-10-13', '2015-10-14'),
(5, '2015-10-14', '2015-10-15'),
(6, '2015-10-28', '2015-10-29'),
(7, '2015-10-30', '2015-10-31');

-- Step 3: Write the query to find the projects
WITH ProjectGroups AS (
    SELECT 
        Task_ID,
        Start_Date,
        End_Date,
        ROW_NUMBER() OVER (ORDER BY Start_Date) - ROW_NUMBER() OVER (ORDER BY End_Date) AS ProjectGroup
    FROM 
        Projects
),
ProjectBoundaries AS (
    SELECT 
        MIN(Start_Date) AS Start_Date,
        MAX(End_Date) AS End_Date,
        COUNT(*) AS Duration
    FROM 
        ProjectGroups
    GROUP BY 
        ProjectGroup
)
SELECT 
    Start_Date,
    End_Date
FROM 
    ProjectBoundaries
ORDER BY 
    Duration ASC, Start_Date ASC;


----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

--Q.Task 2

-- Step 1: Define the tables for testing purposes

CREATE TABLE Students (
    ID INT,
    Name VARCHAR(50)
);

CREATE TABLE Friends (
    ID INT,
    Friend_ID INT
);

CREATE TABLE Packages (
    ID INT,
    Salary FLOAT
);

-- Step 2: Insert sample data into the tables

INSERT INTO Students (ID, Name) VALUES
(1, 'Ashley'),
(2, 'Samantha'),
(3, 'Julia'),
(4, 'Scarlet');

INSERT INTO Friends (ID, Friend_ID) VALUES
(1, 2),
(2, 3),
(3, 4),
(4, 1);

INSERT INTO Packages (ID, Salary) VALUES
(1, 15.20),
(2, 10.06),
(3, 11.55),
(4, 12.12);

-- Step 3: Write the query to find the students whose best friends got a higher salary
SELECT
    S1.Name
FROM
    Students S1
JOIN
    Friends F ON S1.ID = F.ID
JOIN
    Packages P1 ON S1.ID = P1.ID
JOIN
    Packages P2 ON F.Friend_ID = P2.ID
WHERE
    P2.Salary > P1.Salary
ORDER BY
    P2.Salary;

----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

--Q.Task 3

-- Step 1: Create the Functions table

CREATE TABLE Functions (
    X INT,
    Y INT
);

-- Step 2: Insert sample data into the Functions table

INSERT INTO Functions (X, Y) VALUES
(20, 20),
(20, 23),
(22, 21),
(20, 20),
(21, 22),
(23, 20);

-- Step 3: Write the query to find symmetric pairs
SELECT DISTINCT
    f1.X, f1.Y
FROM
    Functions f1
JOIN
    Functions f2
ON
    f1.X = f2.Y AND f1.Y = f2.X
WHERE
    f1.X <= f1.Y
ORDER BY
    f1.X ASC, f1.Y ASC;


----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

--Q.Task 4

-- Step 1: Create the necessary tables
CREATE TABLE Contests (
    contest_id INT,
    hacker_id INT,
    name VARCHAR(50)
);

CREATE TABLE Colleges (
    college_id INT,
    contest_id INT
);

CREATE TABLE Challenges (
    challenge_id INT,
    college_id INT
);

CREATE TABLE View_Stats (
    challenge_id INT,
    total_views INT,
    total_unique_views INT
);

CREATE TABLE Submission_Stats (
    challenge_id INT,
    total_submissions INT,
    total_accepted_submissions INT
);

-- Step 2: Insert sample data into the tables
INSERT INTO Contests (contest_id, hacker_id, name) VALUES
(66406, 17973, 'Rose'),
(66556, 79153, 'Angela'),
(94828, 80275, 'Frank');

INSERT INTO Colleges (college_id, contest_id) VALUES
(11219, 66406),
(32473, 66556),
(56685, 94828);

INSERT INTO Challenges (challenge_id, college_id) VALUES
(18765, 11219),
(47127, 11219),
(60292, 32473),
(72974, 56685),
(75516, 56685);

INSERT INTO View_Stats (challenge_id, total_views, total_unique_views) VALUES
(47127, 26, 19),
(47127, 15, 14),
(18765, 43, 10),
(18765, 72, 13),
(75516, 35, 17),
(60292, 11, 10),
(72974, 41, 15),
(75516, 75, 11);

INSERT INTO Submission_Stats (challenge_id, total_submissions, total_accepted_submissions) VALUES
(75516, 34, 12),
(47127, 27, 10),
(47127, 56, 18),
(75516, 74, 12),
(75516, 83, 8),
(72974, 68, 24),
(72974, 82, 14),
(47127, 28, 11);

-- Step 3: Write the query to find the desired results
WITH ChallengeStats AS (
    SELECT 
        c.contest_id,
        COALESCE(SUM(v.total_views), 0) AS total_views,
        COALESCE(SUM(v.total_unique_views), 0) AS total_unique_views,
        COALESCE(SUM(s.total_submissions), 0) AS total_submissions,
        COALESCE(SUM(s.total_accepted_submissions), 0) AS total_accepted_submissions
    FROM 
        Challenges ch
    LEFT JOIN 
        View_Stats v ON ch.challenge_id = v.challenge_id
    LEFT JOIN 
        Submission_Stats s ON ch.challenge_id = s.challenge_id
    JOIN 
        Colleges c ON ch.college_id = c.college_id
    GROUP BY 
        c.contest_id
),
FilteredChallengeStats AS (
    SELECT 
        contest_id,
        total_views,
        total_unique_views,
        total_submissions,
        total_accepted_submissions
    FROM 
        ChallengeStats
    WHERE 
        total_views != 0 
        OR total_unique_views != 0 
        OR total_submissions != 0 
        OR total_accepted_submissions != 0
)
SELECT 
    ct.contest_id,
    ct.hacker_id,
    ct.name,
    COALESCE(cs.total_submissions, 0) AS total_submissions,
    COALESCE(cs.total_accepted_submissions, 0) AS total_accepted_submissions,
    COALESCE(cs.total_views, 0) AS total_views,
    COALESCE(cs.total_unique_views, 0) AS total_unique_views
FROM 
    Contests ct
LEFT JOIN 
    FilteredChallengeStats cs ON ct.contest_id = cs.contest_id
ORDER BY 
    ct.contest_id;


----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

--Q.Task 5

-- Step 1: Create the necessary tables
CREATE TABLE Hackers (
    hacker_id INT,
    name VARCHAR(50)
);

CREATE TABLE Submissions (
    submission_date DATE,
    submission_id INT,
    hacker_id INT,
    score INT
);

-- Step 2: Insert sample data into the tables
INSERT INTO Hackers (hacker_id, name) VALUES
(15758, 'Angela'),
(20703, 'Frank'),
(36396, 'Patrick'),
(38289, 'Lisa'),
(44065, 'Rose'),
(53473, 'Kimberly'),
(62529, 'Bonnie'),
(79722, 'Michael');

INSERT INTO Submissions (submission_date, submission_id, hacker_id, score) VALUES
('2016-03-01', 8494, 20703, 0),
('2016-03-01', 22403, 53473, 15),
('2016-03-01', 23965, 79722, 60),
('2016-03-01', 30173, 36396, 70),
('2016-03-02', 34928, 20703, 0),
('2016-03-02', 38740, 15758, 60),
('2016-03-02', 42769, 79722, 25),
('2016-03-02', 44364, 79722, 60),
('2016-03-03', 45440, 20703, 0),
('2016-03-03', 49050, 36396, 70),
('2016-03-03', 50273, 79722, 5),
('2016-03-04', 50344, 20703, 0),
('2016-03-04', 51360, 44065, 90),
('2016-03-04', 54404, 53473, 65),
('2016-03-04', 61533, 79722, 45),
('2016-03-05', 72852, 20703, 0),
('2016-03-05', 74546, 38289, 0),
('2016-03-05', 76487, 62529, 0),
('2016-03-05', 82439, 36396, 10),
('2016-03-05', 90006, 36396, 40),
('2016-03-06', 90404, 20703, 0);


-- Step 3: Write the query to find the desired results
WITH DailySubmissions AS (
    SELECT 
        submission_date, 
        hacker_id, 
        COUNT(*) AS submissions_count
    FROM Submissions
    GROUP BY submission_date, hacker_id
),
MaxSubmissionsPerDay AS (
    SELECT 
        submission_date,
        MAX(submissions_count) AS max_submissions
    FROM DailySubmissions
    GROUP BY submission_date
),
HackersWithMaxSubmissions AS (
    SELECT 
        d.submission_date,
        d.hacker_id,
        d.submissions_count
    FROM DailySubmissions d
    JOIN MaxSubmissionsPerDay m
    ON d.submission_date = m.submission_date
    AND d.submissions_count = m.max_submissions
),
UniqueHackersPerDay AS (
    SELECT 
        submission_date,
        COUNT(DISTINCT hacker_id) AS unique_hackers
    FROM Submissions
    GROUP BY submission_date
)
SELECT 
    u.submission_date,
    u.unique_hackers,
    h.hacker_id,
    k.name
FROM 
    UniqueHackersPerDay u
JOIN 
    HackersWithMaxSubmissions h ON u.submission_date = h.submission_date
JOIN 
    Hackers k ON h.hacker_id = k.hacker_id
ORDER BY 
    u.submission_date, 
    h.hacker_id;


------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
--Q.Task 6

--Create the STATION Table

CREATE TABLE STATION (
    ID INT PRIMARY KEY,
    CITY VARCHAR(21),
    STATE CHAR(2),
    LAT_N FLOAT,
    LONG_W FLOAT
);


-- Insert Sample Data into the STATION Table

INSERT INTO STATION (ID, CITY, STATE, LAT_N, LONG_W) VALUES
(1, 'CityA', 'CA', 34.05, -118.25),
(2, 'CityB', 'TX', 29.76, -95.36),
(3, 'CityC', 'FL', 25.76, -80.19),
(4, 'CityD', 'NY', 40.71, -74.00),
(5, 'CityE', 'IL', 41.88, -87.63);


SELECT * FROM STATION;

-- Calculate the Manhattan Distance
WITH MinMaxValues AS (
    SELECT 
        MIN(LAT_N) AS min_lat_n,
        MIN(LONG_W) AS min_long_w,
        MAX(LAT_N) AS max_lat_n,
        MAX(LONG_W) AS max_long_w
    FROM 
        STATION
)
SELECT 
    ROUND(ABS(min_lat_n - max_lat_n) + ABS(min_long_w - max_long_w), 4) AS manhattan_distance
FROM 
    MinMaxValues;


------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------

--Q. Task 7

WITH Numbers AS (
    SELECT n = ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM (VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10)) a(n)
    CROSS JOIN (VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10)) b(n)
    CROSS JOIN (VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10)) c(n)
),
PrimeNumbers AS (
    SELECT n
    FROM Numbers
    WHERE n > 1 AND NOT EXISTS (
        SELECT 1
        FROM Numbers AS Divisors
        WHERE Divisors.n <= SQRT(Numbers.n) AND Numbers.n % Divisors.n = 0
    )
)
SELECT STRING_AGG(CAST(n AS VARCHAR), '&') AS Primes
FROM PrimeNumbers
WHERE n <= 1000;


---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------

-- Q.Task 8

-- Create the table:
CREATE TABLE OCCUPATIONS (
    Name VARCHAR(50),
    Occupation VARCHAR(50)
);


-- Insert sample data into the table:
INSERT INTO OCCUPATIONS (Name, Occupation) VALUES
('Samantha', 'Doctor'),
('Julia', 'Actor'),
('Maria', 'Actor'),
('Meera', 'Singer'),
('Ashley', 'Professor'),
('Ketty', 'Professor'),
('Christeen', 'Professor'),
('Jane', 'Actor'),
('Jenny', 'Doctor'),
('Priya', 'Singer');


-- Run the query to pivot the data:
SELECT
    MAX(CASE WHEN Occupation = 'Doctor' THEN Name ELSE NULL END) AS Doctor,
    MAX(CASE WHEN Occupation = 'Professor' THEN Name ELSE NULL END) AS Professor,
    MAX(CASE WHEN Occupation = 'Singer' THEN Name ELSE NULL END) AS Singer,
    MAX(CASE WHEN Occupation = 'Actor' THEN Name ELSE NULL END) AS Actor
FROM (
    SELECT
        Name,
        Occupation,
        ROW_NUMBER() OVER (PARTITION BY Occupation ORDER BY Name) AS RowNum
    FROM
        OCCUPATIONS
) AS OrderedOccupations
GROUP BY RowNum
ORDER BY RowNum;


------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------

-- Q.Task 9

CREATE TABLE BST (
    N INT,
    P INT
);


INSERT INTO BST (N, P) VALUES
(1, 2),
(3, 2),
(6, 8),
(9, 8),
(2, 5),
(8, 5),
(5, null);



WITH NodeTypes AS (
SELECT
N,
 CASE
 WHEN P IS NULL THEN 'Root'
 WHEN N NOT IN (SELECT DISTINCT P FROM BST WHERE P IS NOT NULL) THEN 'Leaf'
 ELSE 'Inner'
 END AS NodeType
 FROM
      BST
)
SELECT
    N,
    NodeType
FROM
    NodeTypes
ORDER BY
    N;


--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--Q.Task 10

-- Create the Company table
CREATE TABLE Company (
    company_code VARCHAR(10) PRIMARY KEY,
    founder VARCHAR(100)
);

-- Create the Lead_Manager table
CREATE TABLE Lead_Manager (
    lead_manager_code VARCHAR(10) PRIMARY KEY,
    company_code VARCHAR(10),
    FOREIGN KEY (company_code) REFERENCES Company(company_code)
);

-- Create the Senior_Manager table
CREATE TABLE Senior_Manager (
    senior_manager_code VARCHAR(10) PRIMARY KEY,
    lead_manager_code VARCHAR(10),
    company_code VARCHAR(10),
    FOREIGN KEY (lead_manager_code) REFERENCES Lead_Manager(lead_manager_code),
    FOREIGN KEY (company_code) REFERENCES Company(company_code)
);

-- Create the Manager table
CREATE TABLE Manager (
    manager_code VARCHAR(10) PRIMARY KEY,
    senior_manager_code VARCHAR(10),
    lead_manager_code VARCHAR(10),
    company_code VARCHAR(10),
    FOREIGN KEY (senior_manager_code) REFERENCES Senior_Manager(senior_manager_code),
    FOREIGN KEY (lead_manager_code) REFERENCES Lead_Manager(lead_manager_code),
    FOREIGN KEY (company_code) REFERENCES Company(company_code)
);

-- Create the Employee table
CREATE TABLE Employee (
    employee_code VARCHAR(10) PRIMARY KEY,
    manager_code VARCHAR(10),
    senior_manager_code VARCHAR(10),
    lead_manager_code VARCHAR(10),
    company_code VARCHAR(10),
    FOREIGN KEY (manager_code) REFERENCES Manager(manager_code),
    FOREIGN KEY (senior_manager_code) REFERENCES Senior_Manager(senior_manager_code),
    FOREIGN KEY (lead_manager_code) REFERENCES Lead_Manager(lead_manager_code),
    FOREIGN KEY (company_code) REFERENCES Company(company_code)
);



-- Insert data into Company table
INSERT INTO Company (company_code, founder) VALUES ('C1', 'Monika');
INSERT INTO Company (company_code, founder) VALUES ('C2', 'Samantha');

-- Insert data into Lead_Manager table
INSERT INTO Lead_Manager (lead_manager_code, company_code) VALUES ('LM1', 'C1');
INSERT INTO Lead_Manager (lead_manager_code, company_code) VALUES ('LM2', 'C2');

-- Insert data into Senior_Manager table
INSERT INTO Senior_Manager (senior_manager_code, lead_manager_code, company_code) VALUES ('SM1', 'LM1', 'C1');
INSERT INTO Senior_Manager (senior_manager_code, lead_manager_code, company_code) VALUES ('SM2', 'LM1', 'C1');
INSERT INTO Senior_Manager (senior_manager_code, lead_manager_code, company_code) VALUES ('SM3', 'LM2', 'C2');

-- Insert data into Manager table
INSERT INTO Manager (manager_code, senior_manager_code, lead_manager_code, company_code) VALUES ('M1', 'SM1', 'LM1', 'C1');
INSERT INTO Manager (manager_code, senior_manager_code, lead_manager_code, company_code) VALUES ('M2', 'SM3', 'LM2', 'C2');
INSERT INTO Manager (manager_code, senior_manager_code, lead_manager_code, company_code) VALUES ('M3', 'SM3', 'LM2', 'C2');

-- Insert data into Employee table
INSERT INTO Employee (employee_code, manager_code, senior_manager_code, lead_manager_code, company_code) VALUES ('E1', 'M1', 'SM1', 'LM1', 'C1');
INSERT INTO Employee (employee_code, manager_code, senior_manager_code, lead_manager_code, company_code) VALUES ('E2', 'M1', 'SM1', 'LM1', 'C1');
INSERT INTO Employee (employee_code, manager_code, senior_manager_code, lead_manager_code, company_code) VALUES ('E3', 'M2', 'SM3', 'LM2', 'C2');
INSERT INTO Employee (employee_code, manager_code, senior_manager_code, lead_manager_code, company_code) VALUES ('E4', 'M3', 'SM3', 'LM2', 'C2');




SELECT
    c.company_code,
    c.founder,
    COALESCE(lm.lead_manager_count, 0) AS lead_manager_count,
    COALESCE(sm.senior_manager_count, 0) AS senior_manager_count,
    COALESCE(m.manager_count, 0) AS manager_count,
    COALESCE(e.employee_count, 0) AS employee_count
FROM
    Company c
LEFT JOIN
    (SELECT
         company_code,
         COUNT(DISTINCT lead_manager_code) AS lead_manager_count
     FROM
         Lead_Manager
     GROUP BY
         company_code) lm ON c.company_code = lm.company_code
LEFT JOIN
    (SELECT
         company_code,
         COUNT(DISTINCT senior_manager_code) AS senior_manager_count
     FROM
         Senior_Manager
     GROUP BY
         company_code) sm ON c.company_code = sm.company_code
LEFT JOIN
    (SELECT
         company_code,
         COUNT(DISTINCT manager_code) AS manager_count
     FROM
         Manager
     GROUP BY
         company_code) m ON c.company_code = m.company_code
LEFT JOIN
    (SELECT
         company_code,
         COUNT(DISTINCT employee_code) AS employee_count
     FROM
         Employee
     GROUP BY
         company_code) e ON c.company_code = e.company_code
ORDER BY
    c.company_code;



------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

--Q.Task 11


-- Drop the existing tables if they exist
DROP TABLE IF EXISTS Students;
DROP TABLE IF EXISTS Friends;
DROP TABLE IF EXISTS Packages;


-- Creating the Tables
-- Create the Students table
CREATE TABLE Students (
    ID INTEGER PRIMARY KEY,
    Name VARCHAR(100)
);

-- Create the Friends table
CREATE TABLE Friends (
    ID INTEGER,
    Friend_ID INTEGER,
    PRIMARY KEY (ID, Friend_ID)
);

-- Create the Packages table
CREATE TABLE Packages (
    ID INTEGER PRIMARY KEY,
    Salary FLOAT
);


-- Inserting the Sample Data
-- Insert data into Students table
INSERT INTO Students (ID, Name) VALUES (1, 'Ashley');
INSERT INTO Students (ID, Name) VALUES (2, 'Samantha');
INSERT INTO Students (ID, Name) VALUES (3, 'Julia');
INSERT INTO Students (ID, Name) VALUES (4, 'Scarlet');

-- Insert data into Friends table
INSERT INTO Friends (ID, Friend_ID) VALUES (1, 2);
INSERT INTO Friends (ID, Friend_ID) VALUES (2, 3);
INSERT INTO Friends (ID, Friend_ID) VALUES (3, 4);
INSERT INTO Friends (ID, Friend_ID) VALUES (4, 1);

-- Insert data into Packages table
INSERT INTO Packages (ID, Salary) VALUES (1, 15.20);
INSERT INTO Packages (ID, Salary) VALUES (2, 10.06);
INSERT INTO Packages (ID, Salary) VALUES (3, 11.55);
INSERT INTO Packages (ID, Salary) VALUES (4, 12.12);

-- Query to Get Desired Output
SELECT s.Name
FROM Students s
JOIN Friends f ON s.ID = f.ID
JOIN Packages p1 ON s.ID = p1.ID
JOIN Packages p2 ON f.Friend_ID = p2.ID
WHERE p2.Salary > p1.Salary
ORDER BY p2.Salary;



-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

--Q.Task 12 Display ratio of cost of job family in percentage by India and international (refer simulation data).


-- Sample Data
CREATE TABLE Jobs (
    job_id INTEGER PRIMARY KEY,
    job_family VARCHAR(100),
    region VARCHAR(20),
    cost FLOAT
);

-- Insert sample data into Jobs table
INSERT INTO Jobs (job_id, job_family, region, cost) VALUES (1, 'Engineering', 'India', 5000);
INSERT INTO Jobs (job_id, job_family, region, cost) VALUES (2, 'Engineering', 'International', 7000);
INSERT INTO Jobs (job_id, job_family, region, cost) VALUES (3, 'Marketing', 'India', 3000);
INSERT INTO Jobs (job_id, job_family, region, cost) VALUES (4, 'Marketing', 'International', 5000);
INSERT INTO Jobs (job_id, job_family, region, cost) VALUES (5, 'HR', 'India', 2000);
INSERT INTO Jobs (job_id, job_family, region, cost) VALUES (6, 'HR', 'International', 3000);


-- SQL Query
WITH CostByRegion AS (
    SELECT 
        job_family,
        region,
        SUM(cost) AS total_cost
    FROM 
        Jobs
    GROUP BY 
        job_family, region
),
TotalCost AS (
    SELECT
        job_family,
        SUM(total_cost) AS total_cost
    FROM
        CostByRegion
    GROUP BY
        job_family
)
SELECT
    cbr.job_family,
    cbr.region,
    (cbr.total_cost / tc.total_cost) * 100 AS cost_percentage
FROM
    CostByRegion cbr
JOIN
    TotalCost tc ON cbr.job_family = tc.job_family
ORDER BY
    cbr.job_family, cbr.region;



-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-- Q.Task 13 Find ratio of cost and revenue of a BU month on month.


-- Creating the Tables
CREATE TABLE Cost (
    bu_id INTEGER,
    month DATE,
    cost FLOAT,
    PRIMARY KEY (bu_id, month)
);

CREATE TABLE Revenue (
    bu_id INTEGER,
    month DATE,
    revenue FLOAT,
    PRIMARY KEY (bu_id, month)
);


-- Inserting Sample Data
-- Insert sample data into Cost table
INSERT INTO Cost (bu_id, month, cost) VALUES (1, '2023-01-01', 5000);
INSERT INTO Cost (bu_id, month, cost) VALUES (1, '2023-02-01', 6000);
INSERT INTO Cost (bu_id, month, cost) VALUES (2, '2023-01-01', 4000);
INSERT INTO Cost (bu_id, month, cost) VALUES (2, '2023-02-01', 4500);

-- Insert sample data into Revenue table
INSERT INTO Revenue (bu_id, month, revenue) VALUES (1, '2023-01-01', 10000);
INSERT INTO Revenue (bu_id, month, revenue) VALUES (1, '2023-02-01', 12000);
INSERT INTO Revenue (bu_id, month, revenue) VALUES (2, '2023-01-01', 8000);
INSERT INTO Revenue (bu_id, month, revenue) VALUES (2, '2023-02-01', 9000);


-- Query to Calculate Ratio of Cost to Revenue Month on Month
SELECT
    c.bu_id,
    c.month,
    c.cost,
    r.revenue,
    (c.cost / r.revenue) * 100 AS cost_revenue_ratio
FROM
    Cost c
JOIN
    Revenue r ON c.bu_id = r.bu_id AND c.month = r.month
ORDER BY
    c.bu_id,
    c.month;



-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-- Q.Task 14 Show headcounts of sub band and percentage of headcount (without join, subquery and inner query).


-- Drop the existing tables if they exist
DROP TABLE IF EXISTS employees;


-- Create the Table
CREATE TABLE employees (
    id INT PRIMARY KEY,
    sub_band VARCHAR(50)
);


-- Insert Values
INSERT INTO employees (id, sub_band) VALUES
(1, 'A'),
(2, 'A'),
(3, 'B'),
(4, 'B'),
(5, 'B'),
(6, 'C'),
(7, 'A'),
(8, 'C'),
(9, 'B'),
(10, 'A');


-- Query to Get Headcounts and Percentages
SELECT 
    sub_band, 
    COUNT(id) AS headcount,
    COUNT(id) * 100.0 / SUM(COUNT(id)) OVER () AS percentage_headcount
FROM 
    employees
GROUP BY 
    sub_band;




-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-- Q.Task 15  Find top 5 employees according to salary (without order by).


-- Sample Table Structure and Data
CREATE TABLE Employees (
    employee_id INTEGER PRIMARY KEY,
    name VARCHAR(100),
    salary FLOAT
);

-- Insert sample data into Employees table
INSERT INTO Employees (employee_id, name, salary) VALUES (1, 'Alice', 90000);
INSERT INTO Employees (employee_id, name, salary) VALUES (2, 'Bob', 120000);
INSERT INTO Employees (employee_id, name, salary) VALUES (3, 'Charlie', 110000);
INSERT INTO Employees (employee_id, name, salary) VALUES (4, 'David', 105000);
INSERT INTO Employees (employee_id, name, salary) VALUES (5, 'Eve', 115000);
INSERT INTO Employees (employee_id, name, salary) VALUES (6, 'Frank', 95000);
INSERT INTO Employees (employee_id, name, salary) VALUES (7, 'Grace', 125000);
INSERT INTO Employees (employee_id, name, salary) VALUES (8, 'Hank', 130000);
INSERT INTO Employees (employee_id, name, salary) VALUES (9, 'Ivy', 85000);
INSERT INTO Employees (employee_id, name, salary) VALUES (10, 'John', 99000);


-- Query to Find Top 5 Employees by Salary
WITH RankedEmployees AS (
    SELECT
        employee_id,
        name,
        salary,
        ROW_NUMBER() OVER (PARTITION BY 1 ORDER BY salary DESC) AS rank
    FROM
        Employees
)
SELECT
    employee_id,
    name,
    salary
FROM
    RankedEmployees
WHERE
    rank <= 5;



----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

-- Q.Task 16 Swap value of two columns in a table without using third variable or a table.


-- Table Creation and Insertion
CREATE TABLE example_table (
    id INT PRIMARY KEY,
    column1 INT,
    column2 INT
);

INSERT INTO example_table (id, column1, column2) VALUES
(1, 10, 20),
(2, 30, 40),
(3, 50, 60);


-- Swapping Values Using a CTE
WITH SwapValues AS (
    SELECT
        id,
        column1 + column2 AS new_column1,
        column1 AS temp_column1,
        column2 AS temp_column2
    FROM
        example_table
)
UPDATE example_table
SET 
    column1 = new_column1 - column2,
    column2 = new_column1 - temp_column1
FROM
    example_table
JOIN
    SwapValues ON example_table.id = SwapValues.id;


SELECT * FROM example_table;



----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

-- Q.Task 17  Create a user, create a login for that user provide permissions of DB_owner to the user


-- Step 1: Create a Database
CREATE DATABASE YourDatabase;

-- Step 2: Create a Login
CREATE LOGIN new_login WITH PASSWORD = 'StrongPassword123';

-- Step 3: Create a User in the Specific Database
USE YourDatabase;
CREATE USER new_user FOR LOGIN new_login;

-- Step 4: Grant DB_OWNER Permissions to the User
EXEC sp_addrolemember 'db_owner', 'new_user';



----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

-- Q.Task 18 Find Weighted average cost of employees month on month in a BU.


-- Create the Table and Insert Sample Data
CREATE TABLE employee_costs (
    employee_id INT,
    bu VARCHAR(50),
    month DATE,
    cost DECIMAL(10, 2),
    weight DECIMAL(10, 2)
);

INSERT INTO employee_costs (employee_id, bu, month, cost, weight) VALUES
(1, 'BU1', '2024-01-01', 5000, 1.0),
(2, 'BU1', '2024-01-01', 6000, 0.8),
(3, 'BU1', '2024-01-01', 5500, 1.2),
(4, 'BU1', '2024-02-01', 5200, 1.0),
(5, 'BU1', '2024-02-01', 6100, 0.9),
(6, 'BU2', '2024-01-01', 4800, 1.1),
(7, 'BU2', '2024-02-01', 4900, 1.2),
(8, 'BU2', '2024-02-01', 5000, 1.0);


-- Calculate the Weighted Average Cost
SELECT 
    bu,
    month,
    SUM(cost * weight) / SUM(weight) AS weighted_avg_cost
FROM 
    employee_costs
GROUP BY 
    bu, 
    month
ORDER BY 
    bu, 
    month;




----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
/*
 Q.Task 19 Samantha as tasked with calculating the average monthly salaries for all employees in the EMPLOYEES table, 
but did not realize her keyboard's O key was broken until after completing the calculation. She wants your help finding the difference between 
her miscalculation (using salaries with any zeroes removed), and the actual average salary.
Write a query calculating the amount of error (i.e.: actual-miscalculated average monthly salaries), and round it up to the next integer.*/


-- Check Existing Tables and Columns
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE';

SELECT COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'EMPLOYEES';


-- Create a Sample Table (if needed)
CREATE TABLE EMPLOYEES (
    employee_id INT PRIMARY KEY,
    salary INT
);

INSERT INTO EMPLOYEES (employee_id, salary) VALUES
(1, 1000),
(2, 2000),
(3, 3050),
(4, 4500),
(5, 5200);


-- Calculate the Average Monthly Salaries
WITH SalaryData AS (
    SELECT 
        salary,
        CAST(REPLACE(CAST(salary AS VARCHAR(20)), '0', '') AS INT) AS miscalculated_salary
    FROM 
        EMPLOYEES
),
Averages AS (
    SELECT 
        AVG(salary) AS actual_avg_salary,
        AVG(miscalculated_salary) AS miscalculated_avg_salary
    FROM 
        SalaryData
)
SELECT 
    CEILING(actual_avg_salary - miscalculated_avg_salary) AS error_amount
FROM 
    Averages;



----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

-- Q.Task 20 Copy new data of one table to another(you do not have indicator for new data and old data).


-- Create the Source Table
CREATE TABLE source_table (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    age INT
);


--  Insert Data into the Source Table
INSERT INTO source_table (id, name, age) VALUES
(1, 'John', 30),
(2, 'Alice', 25),
(3, 'Bob', 35);


-- Create the Target Table
CREATE TABLE target_table (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    age INT
);


-- Copy Data from Source Table to Target Table
INSERT INTO target_table (id, name, age)
SELECT id, name, age
FROM source_table;


SELECT * FROM target_table;



-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------

