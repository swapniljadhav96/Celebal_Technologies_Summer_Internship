
IF OBJECT_ID('Attendance', 'U') IS NOT NULL 
    DROP TABLE Attendance;

IF OBJECT_ID('FirstCheckIn', 'U') IS NOT NULL 
    DROP TABLE FirstCheckIn;

IF OBJECT_ID('LastCheckOut', 'U') IS NOT NULL 
    DROP TABLE LastCheckOut;

IF OBJECT_ID('TotalOuts', 'U') IS NOT NULL 
    DROP TABLE TotalOuts;

IF OBJECT_ID('WorkDurations', 'U') IS NOT NULL 
    DROP TABLE WorkDurations;

IF OBJECT_ID('TotalWorkTime', 'U') IS NOT NULL 
    DROP TABLE TotalWorkTime;


CREATE TABLE Attendance (
    EmpID INT,
    Name VARCHAR(50),
    DateTime DATETIME,
    Attendance VARCHAR(3)
);

INSERT INTO Attendance (EmpID, Name, DateTime, Attendance) VALUES
(1, 'Him', '2024-01-03 10:08:00', 'IN'),
(2, 'Raj', '2024-01-03 10:10:00', 'IN'),
(3, 'Anu', '2024-01-03 10:12:00', 'IN'),
(1, 'Him', '2024-01-03 11:11:00', 'OUT'),
(2, 'Raj', '2024-01-03 12:12:00', 'OUT'),
(3, 'Anu', '2024-01-03 12:35:00', 'OUT'),
(1, 'Him', '2024-01-03 12:08:00', 'IN'),
(2, 'Raj', '2024-01-03 12:25:00', 'IN'),
(3, 'Anu', '2024-01-03 12:40:00', 'IN'),
(1, 'Him', '2024-01-03 14:12:00', 'OUT'),
(2, 'Raj', '2024-01-03 15:12:00', 'OUT'),
(3, 'Anu', '2024-01-03 18:35:00', 'OUT'),
(1, 'Him', '2024-01-03 15:08:00', 'IN'),
(1, 'Him', '2024-01-03 18:08:00', 'OUT');


WITH FirstCheckIn AS (
    SELECT EmpID, Name, MIN(DateTime) AS FirstCheckInTime
    FROM Attendance
    WHERE Attendance = 'IN'
    GROUP BY EmpID, Name
),
LastCheckOut AS (
    SELECT EmpID, Name, MAX(DateTime) AS LastCheckOutTime
    FROM Attendance
    WHERE Attendance = 'OUT'
    GROUP BY EmpID, Name
),
TotalOuts AS (
    SELECT EmpID, Name, COUNT(*) AS TotalOutCount
    FROM Attendance
    WHERE Attendance = 'OUT'
    GROUP BY EmpID, Name
),
WorkDurations AS (
    SELECT 
        a.EmpID, 
        a.Name, 
        a.DateTime AS CheckInTime,
        LEAD(a.DateTime) OVER (PARTITION BY a.EmpID ORDER BY a.DateTime) AS CheckOutTime
    FROM Attendance a
    WHERE a.Attendance = 'IN'
),
TotalWorkTime AS (
    SELECT 
        EmpID,
        Name,
        SUM(DATEDIFF(SECOND, CheckInTime, CheckOutTime)) AS TotalWorkSeconds
    FROM WorkDurations
    WHERE CheckOutTime IS NOT NULL
    GROUP BY EmpID, Name
)
SELECT 
    fc.EmpID,
    fc.Name,
    fc.FirstCheckInTime,
    lc.LastCheckOutTime,
    to_cnt.TotalOutCount,
    RIGHT('0' + CAST(TotalWorkSeconds / 3600 AS VARCHAR), 2) + ':' +
    RIGHT('0' + CAST((TotalWorkSeconds % 3600) / 60 AS VARCHAR), 2) AS TotalWorkHours
FROM 
    FirstCheckIn fc
JOIN 
    LastCheckOut lc ON fc.EmpID = lc.EmpID AND fc.Name = lc.Name
JOIN 
    TotalOuts to_cnt ON fc.EmpID = to_cnt.EmpID AND fc.Name = to_cnt.Name
JOIN 
    TotalWorkTime twt ON fc.EmpID = twt.EmpID AND fc.Name = twt.Name;

