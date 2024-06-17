
-- Create Tables

-- Create the SubjectAllotments table
CREATE TABLE SubjectAllotments (
    StudentID VARCHAR(50),
    SubjectID VARCHAR(50),
    Is_Valid BIT
);

-- Create the SubjectRequest table
CREATE TABLE SubjectRequest (
    StudentID VARCHAR(50),
    SubjectID VARCHAR(50)
);



-- Insert Sample Data

-- Insert sample data into the SubjectAllotments table
INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid) VALUES
('159103036', 'PO1491', 1),
('159103036', 'PO1492', 0),
('159103036', 'PO1493', 0),
('159103036', 'PO1494', 0),
('159103036', 'PO1495', 0);

-- Insert sample data into the SubjectRequest table
INSERT INTO SubjectRequest (StudentID, SubjectID) VALUES
('159103036', 'PO1496');



-- Define the Stored Procedure

CREATE PROCEDURE UpdateSubjectAllotments
AS
BEGIN
    -- Declare variables to hold student and subject details
    DECLARE @StudentID VARCHAR(50);
    DECLARE @RequestedSubjectID VARCHAR(50);
    DECLARE @CurrentSubjectID VARCHAR(50);
    DECLARE @IsValid BIT;
    
    -- Create a cursor to iterate through each record in the SubjectRequest table
    DECLARE subject_cursor CURSOR FOR
    SELECT StudentID, SubjectID
    FROM SubjectRequest;

    -- Open the cursor
    OPEN subject_cursor;

    -- Fetch the first record
    FETCH NEXT FROM subject_cursor INTO @StudentID, @RequestedSubjectID;

    -- Loop through all the records in the SubjectRequest table
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Check if the student has a valid subject in the SubjectAllotments table
        SELECT @CurrentSubjectID = SubjectID, @IsValid = Is_Valid
        FROM SubjectAllotments
        WHERE StudentID = @StudentID AND Is_Valid = 1;

        -- If the student has a current valid subject and it's different from the requested one
        IF (@IsValid = 1 AND @CurrentSubjectID <> @RequestedSubjectID)
        BEGIN
            -- Set the current subject to invalid
            UPDATE SubjectAllotments
            SET Is_Valid = 0
            WHERE StudentID = @StudentID AND SubjectID = @CurrentSubjectID;
            
            -- Insert the new requested subject as valid
            INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
            VALUES (@StudentID, @RequestedSubjectID, 1);
        END
        ELSE IF (@IsValid IS NULL) -- If the student does not have any current valid subject
        BEGIN
            -- Insert the requested subject as valid
            INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
            VALUES (@StudentID, @RequestedSubjectID, 1);
        END
        
        -- Fetch the next record
        FETCH NEXT FROM subject_cursor INTO @StudentID, @RequestedSubjectID;
    END

    -- Close and deallocate the cursor
    CLOSE subject_cursor;
    DEALLOCATE subject_cursor;
END;



-- Execute the Stored Procedure

EXEC UpdateSubjectAllotments;



-- Verify the Results

-- Check the contents of the SubjectAllotments table
SELECT * FROM SubjectAllotments;

