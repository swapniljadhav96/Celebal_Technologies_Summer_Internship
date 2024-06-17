

DROP PROCEDURE IF EXISTS AllocateSubjects;

/*
-- Drop existing tables if they exist
IF OBJECT_ID('StudentDetails', 'U') IS NOT NULL
    DROP TABLE StudentDetails;

IF OBJECT_ID('SubjectDetails', 'U') IS NOT NULL
    DROP TABLE SubjectDetails;

IF OBJECT_ID('StudentPreference', 'U') IS NOT NULL
    DROP TABLE StudentPreference;

IF OBJECT_ID('Allotments', 'U') IS NOT NULL
    DROP TABLE Allotments;

IF OBJECT_ID('UnallotedStudents', 'U') IS NOT NULL
    DROP TABLE UnallotedStudents;

GO

*/


-- Create Necessary Tables

-- Create StudentDetails table
CREATE TABLE StudentDetails (
    Studentid INT PRIMARY KEY,
    StudentName VARCHAR(100),
    GPA FLOAT,
    Branch VARCHAR(10),
    Section CHAR(1)
);

-- Create SubjectDetails table
CREATE TABLE SubjectDetails (
    Subjectid VARCHAR(10) PRIMARY KEY,
    SubjectName VARCHAR(100),
    MaxSeats INT,
    RemainingSeats INT
);

-- Create StudentPreference table
CREATE TABLE StudentPreference (
    Studentid INT,
    Subjectid VARCHAR(10),
    Preference INT,
    PRIMARY KEY (Studentid, Subjectid),
    FOREIGN KEY (Studentid) REFERENCES StudentDetails(Studentid),
    FOREIGN KEY (Subjectid) REFERENCES SubjectDetails(Subjectid)
);

-- Create Allotments table
CREATE TABLE Allotments (
    Subjectid VARCHAR(10),
    Studentid INT,
    PRIMARY KEY (Subjectid, Studentid),
    FOREIGN KEY (Subjectid) REFERENCES SubjectDetails(Subjectid),
    FOREIGN KEY (Studentid) REFERENCES StudentDetails(Studentid)
);

-- Create UnallotedStudents table
CREATE TABLE UnallotedStudents (
    Studentid INT PRIMARY KEY,
    FOREIGN KEY (Studentid) REFERENCES StudentDetails(Studentid)
);

GO

-- Populate the Tables with Sample Data

-- Insert data into StudentDetails
INSERT INTO StudentDetails (Studentid, StudentName, GPA, Branch, Section) VALUES
(159103036, 'Mohit Agarwal', 8.9, 'CCE', 'A'),
(159103037, 'Rohit Agarwal', 5.2, 'CCE', 'A'),
(159103038, 'Shohit Garg', 7.1, 'CCE', 'B'),
(159103039, 'Mrinal Malhotra', 7.9, 'CCE', 'A'),
(159103040, 'Mehreet Singh', 5.6, 'CCE', 'A'),
(159103041, 'Arjun Tehlan', 9.2, 'CCE', 'B');

-- Insert data into SubjectDetails
INSERT INTO SubjectDetails (Subjectid, SubjectName, MaxSeats, RemainingSeats) VALUES
('PO1491', 'Basics of Political Science', 60, 2),
('PO1492', 'Basics of Accounting', 120, 119),
('PO1493', 'Basics of Financial Markets', 90, 90),
('PO1494', 'Eco philosophy', 60, 50),
('PO1495', 'Automotive Trends', 60, 60);

-- Insert data into StudentPreference
INSERT INTO StudentPreference (Studentid, Subjectid, Preference) VALUES
(159103036, 'PO1491', 1),
(159103036, 'PO1492', 2),
(159103036, 'PO1493', 3),
(159103036, 'PO1494', 4),
(159103036, 'PO1495', 5);

GO

-- Drop the existing stored procedure if it exists
IF OBJECT_ID('AllocateSubjects', 'P') IS NOT NULL
    DROP PROCEDURE AllocateSubjects;
GO

-- Create the Stored Procedure to Allocate Subjects
CREATE PROCEDURE AllocateSubjects
AS
BEGIN
    DECLARE @student_id INT;
    DECLARE @subject_id VARCHAR(10);
    DECLARE @preference INT;
    DECLARE @gpa FLOAT;
    DECLARE @remaining_seats INT;
    DECLARE @pref_done BIT;

    -- Declare the cursor for students
    DECLARE student_cursor CURSOR FOR
        SELECT Studentid, GPA
        FROM StudentDetails
        ORDER BY GPA DESC;

    -- Open the student cursor
    OPEN student_cursor;
    FETCH NEXT FROM student_cursor INTO @student_id, @gpa;

    -- Loop through each student
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Declare the cursor for preferences
        DECLARE pref_cursor CURSOR FOR
            SELECT Subjectid, Preference
            FROM StudentPreference
            WHERE Studentid = @student_id
            ORDER BY Preference ASC;

        -- Open the preference cursor
        OPEN pref_cursor;
        FETCH NEXT FROM pref_cursor INTO @subject_id, @preference;

        SET @pref_done = 0;

        -- Loop through each preference
        WHILE @@FETCH_STATUS = 0 AND @pref_done = 0
        BEGIN
            -- Get the remaining seats for the current subject
            SELECT @remaining_seats = RemainingSeats FROM SubjectDetails WHERE Subjectid = @subject_id;

            IF @remaining_seats > 0
            BEGIN
                -- Allocate the subject to the student
                INSERT INTO Allotments (Subjectid, Studentid) VALUES (@subject_id, @student_id);

                -- Update the remaining seats
                UPDATE SubjectDetails SET RemainingSeats = RemainingSeats - 1 WHERE Subjectid = @subject_id;

                -- Mark preference as done
                SET @pref_done = 1;
            END

            -- Fetch the next preference
            FETCH NEXT FROM pref_cursor INTO @subject_id, @preference;
        END

        -- Close and deallocate the preference cursor
        CLOSE pref_cursor;
        DEALLOCATE pref_cursor;

        -- If no preference was allocated, mark the student as unallotted
        IF @pref_done = 0
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM UnallotedStudents WHERE Studentid = @student_id)
            BEGIN
                INSERT INTO UnallotedStudents (Studentid) VALUES (@student_id);
            END
        END

        -- Fetch the next student
        FETCH NEXT FROM student_cursor INTO @student_id, @gpa;
    END

    -- Close and deallocate the student cursor
    CLOSE student_cursor;
    DEALLOCATE student_cursor;
END
GO

-- Execution
EXEC AllocateSubjects;
GO


