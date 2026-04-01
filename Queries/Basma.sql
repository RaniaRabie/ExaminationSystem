/* =============================================
   PROCEDURES
============================================= */

DROP PROCEDURE IF EXISTS Exam.Create_Exam;
GO
-- This procedure creates a new exam with the provided details. It checks for duplicate exam IDs, validates the course ID, and ensures that the end time is after the start time before inserting the exam into the database.
CREATE PROCEDURE Exam.Create_Exam
    @Exam_Id INT,
    @Crs_Id INT,
    @Year INT,
    @ExamType VARCHAR(50),
    @StartTime DATETIME,
    @EndTime DATETIME
AS
BEGIN
-- Check if the exam already exists
    IF EXISTS (SELECT 1 FROM Exam.Exam WHERE Exam_Id = @Exam_Id)
    BEGIN
        RAISERROR('Exam already exists',16,1);
        RETURN;
    END
    -- Check if the course exists
    IF NOT EXISTS (SELECT 1 FROM Academic.Course WHERE Course_Id = @Crs_Id)
    BEGIN
        RAISERROR('Course does not exist',16,1);
        RETURN;
    END
    --  Validate that the end time is after the start time
    IF (@EndTime <= @StartTime)
    BEGIN
        RAISERROR('Invalid Time',16,1);
        RETURN;
    END
    
    INSERT INTO Exam.Exam (Exam_Id, Crs_Id, Year, ExamType, StartTime, EndTime)
    VALUES (@Exam_Id, @Crs_Id, @Year, @ExamType, @StartTime, @EndTime);
END
GO


DROP PROCEDURE IF EXISTS Exam.Get_Exam;
GO
-- This procedure retrieves the details of an exam based on the provided exam ID. It checks if the exam exists before returning the exam information.
CREATE PROCEDURE Exam.Get_Exam
    @Exam_Id INT
AS
BEGIN
-- Check if the exam exists
    IF NOT EXISTS (SELECT 1 FROM Exam.Exam WHERE Exam_Id = @Exam_Id)
    BEGIN
        RAISERROR('Exam not found',16,1);
        RETURN;
    END

    SELECT * FROM Exam.Exam WHERE Exam_Id = @Exam_Id;
END
GO


DROP PROCEDURE IF EXISTS Exam.Update_Exam;
GO
-- This procedure updates the details of an existing exam. It checks if the exam exists and validates the new start and end times before applying the updates to the database.
CREATE PROCEDURE Exam.Update_Exam
    @Exam_Id INT,
    @ExamType VARCHAR(50),
    @StartTime DATETIME,
    @EndTime DATETIME
AS
BEGIN
-- Check if the exam exists
    IF NOT EXISTS (SELECT 1 FROM Exam.Exam WHERE Exam_Id = @Exam_Id)
    BEGIN
        RAISERROR('Exam not found',16,1);
        RETURN;
    END
    -- Validate that the end time is after the start time
    IF (@EndTime <= @StartTime)
    BEGIN
        RAISERROR('Invalid Time',16,1);
        RETURN;
    END
    -- Update the exam details
    UPDATE Exam.Exam
    SET ExamType = @ExamType,
        StartTime = @StartTime,
        EndTime = @EndTime
    WHERE Exam_Id = @Exam_Id;
END
GO


DROP PROCEDURE IF EXISTS Exam.Delete_Exam;
GO
-- This procedure deletes an exam from the database based on the provided exam ID. It checks if the exam exists before deleting it and also removes any associated questions from the Exam_Question table to maintain referential integrity.
CREATE PROCEDURE Exam.Delete_Exam
    @Exam_Id INT
AS
BEGIN
-- Check if the exam exists
    IF NOT EXISTS (SELECT 1 FROM Exam.Exam WHERE Exam_Id = @Exam_Id)
    BEGIN
        RAISERROR('Exam not found',16,1);
        RETURN;
    END

    DELETE FROM Exam.Exam_Question WHERE Exam_Id = @Exam_Id;
    DELETE FROM Exam.Exam WHERE Exam_Id = @Exam_Id;
END
GO


DROP PROCEDURE IF EXISTS Exam.Add_Question_To_Exam;
GO
-- This procedure adds a question to an exam with a specified degree. It performs several checks to ensure that the exam and question exist, that the question is not already added to the exam, and that the total degree does not exceed the maximum allowed for the course before inserting the new record into the Exam_Question table.
CREATE PROCEDURE Exam.Add_Question_To_Exam
    @Exam_Id INT,
    @Q_Id INT,
    @Degree INT
AS
BEGIN
-- Check if the exam exists
    IF NOT EXISTS (SELECT 1 FROM Exam.Exam WHERE Exam_Id = @Exam_Id)
    BEGIN
        RAISERROR('Exam not found',16,1);
        RETURN;
    END
    -- Check if the question exists
    IF NOT EXISTS (SELECT 1 FROM Exam.Question WHERE Question_ID = @Q_Id)
    BEGIN
        RAISERROR('Question not found',16,1);
        RETURN;
    END
    -- Check if the question is already added to the exam
    IF EXISTS (SELECT 1 FROM Exam.Exam_Question WHERE Exam_Id = @Exam_Id AND Q_Id = @Q_Id)
    BEGIN
        RAISERROR('Question already added',16,1);
        RETURN;
    END
    -- Validate that the degree is positive
    IF @Degree <= 0
    BEGIN
        RAISERROR('Invalid Degree',16,1);
        RETURN;
    END

    DECLARE @CurrentTotal INT;
    DECLARE @MaxDegree INT;

    SELECT @CurrentTotal = ISNULL(SUM(Degree), 0)
    FROM Exam.Exam_Question WHERE Exam_Id = @Exam_Id;

    SELECT @MaxDegree = C.MaxDegree
    FROM Academic.Course C
    JOIN Exam.Exam E ON C.Course_Id = E.Crs_Id
    WHERE E.Exam_Id = @Exam_Id;
    -- Check if adding the new question's degree exceeds the course's maximum degree
    IF (@CurrentTotal + @Degree > @MaxDegree)
    BEGIN
        RAISERROR('Exceeds course max degree',16,1);
        RETURN;
    END

    INSERT INTO Exam.Exam_Question (Exam_Id, Q_Id, Degree)
    VALUES (@Exam_Id, @Q_Id, @Degree);
END
GO


DROP PROCEDURE IF EXISTS Exam.Remove_Question_From_Exam;
GO
-- This procedure removes a question from an exam. It checks if the question is currently associated with the exam before deleting the record from the Exam_Question table to ensure that only existing associations are removed.
CREATE PROCEDURE Exam.Remove_Question_From_Exam
    @Exam_Id INT,
    @Q_Id INT
AS
BEGIN
-- Check if the question is associated with the exam
    IF NOT EXISTS (
        SELECT 1 FROM Exam.Exam_Question 
        WHERE Exam_Id = @Exam_Id AND Q_Id = @Q_Id
    )
    BEGIN
        RAISERROR('Question not found in exam',16,1);
        RETURN;
    END

    DELETE FROM Exam.Exam_Question
    WHERE Exam_Id = @Exam_Id AND Q_Id = @Q_Id;
END
GO


DROP PROCEDURE IF EXISTS Exam.Assign_Exam;
GO
-- This procedure assigns an exam to a specific intake, branch, and track. It checks if the exam exists and if the assignment already exists to prevent duplicates before inserting the new assignment into the Exam_Intake_Branch_Track table.
CREATE PROCEDURE Exam.Assign_Exam
    @Exam_Id INT,
    @Intake_Id INT,
    @Branch_Id INT,
    @Track_Id INT
AS
BEGIN
-- Check if the exam exists
    IF NOT EXISTS (SELECT 1 FROM Exam.Exam WHERE Exam_Id = @Exam_Id)
    BEGIN
        RAISERROR('Exam not found',16,1);
        RETURN;
    END
    --  Check if the assignment already exists
    IF EXISTS (
        SELECT 1 FROM Exam.Exam_Intake_Branch_Track
        WHERE Exam_Id = @Exam_Id 
        AND Intake_Id = @Intake_Id 
        AND Branch_Id = @Branch_Id 
        AND Track_Id = @Track_Id
    )
    BEGIN
        RAISERROR('Already assigned',16,1);
        RETURN;
    END

    INSERT INTO Exam.Exam_Intake_Branch_Track
    (Exam_Id, Intake_Id, Branch_Id, Track_Id)
    VALUES (@Exam_Id, @Intake_Id, @Branch_Id, @Track_Id);
END
GO

DROP PROCEDURE IF EXISTS Exam.Search_Exam_ByDate;
GO
-- This procedure retrieves exams scheduled on a specific date, 
--including their details and associated course names.
CREATE PROCEDURE Exam.Search_Exam_ByDate
    @Date DATE
AS
BEGIN
    SELECT 
        E.Exam_Id,
        E.ExamType,
        E.StartTime,
        E.EndTime,
        C.Crs_Name
    FROM Exam.Exam E
    JOIN Academic.Course C ON E.Crs_Id = C.Course_Id
    WHERE CAST(E.StartTime AS DATE) = @Date;
END
GO

/* =============================================
   FUNCTIONS
============================================= */

DROP FUNCTION IF EXISTS Exam.Get_Exam_TotalDegree;
GO
-- This function calculates the total degree of an exam by summing the degrees of all questions associated with the specified exam ID. It returns the total degree as an integer.
CREATE FUNCTION Exam.Get_Exam_TotalDegree (@Exam_Id INT)
RETURNS INT
AS
BEGIN
    DECLARE @Total INT;

    SELECT @Total = ISNULL(SUM(Degree), 0)
    FROM Exam.Exam_Question
    WHERE Exam_Id = @Exam_Id;

    RETURN @Total;
END
GO


DROP FUNCTION IF EXISTS Exam.Get_Exam_Questions;
GO
-- This function retrieves the questions associated with a specific exam ID, including their headers, types, and assigned degrees. It returns a table containing the question details for the specified exam.
CREATE FUNCTION Exam.Get_Exam_Questions (@Exam_Id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT Q.Question_ID, Q.Ques_Header, Q.Question_Type, EQ.Degree
    FROM Exam.Exam_Question EQ
    JOIN Exam.Question Q ON EQ.Q_Id = Q.Question_ID
    WHERE EQ.Exam_Id = @Exam_Id
);
GO


/* =============================================
   VIEWS
============================================= */

DROP VIEW IF EXISTS Exam.V_Exam_Details;
GO
-- This view provides a comprehensive overview of exams, including their details such as exam type, year, start and end times, total time, associated course name, and maximum degree for the course.
CREATE VIEW Exam.V_Exam_Details
AS
SELECT 
    E.Exam_Id,
    E.ExamType,
    E.Year,
    E.StartTime,
    E.EndTime,
    E.TotalTime,
    C.Crs_Name,
    C.MaxDegree
FROM Exam.Exam E
JOIN Academic.Course C ON E.Crs_Id = C.Course_Id;
GO


DROP VIEW IF EXISTS Exam.V_Exam_Questions;
GO
-- This view provides a detailed list of questions associated with each exam, including the question header, type, and the degree assigned to each question in the context of the exam.
CREATE VIEW Exam.V_Exam_Questions
AS
SELECT 
    E.Exam_Id,
    Q.Question_ID,
    Q.Ques_Header,
    Q.Question_Type,
    EQ.Degree
FROM Exam.Exam E
JOIN Exam.Exam_Question EQ ON E.Exam_Id = EQ.Exam_Id
JOIN Exam.Question Q ON EQ.Q_Id = Q.Question_ID;
GO


/* =============================================
   TRIGGER
============================================= */

DROP TRIGGER IF EXISTS Exam.Check_Total_Degree;
GO
-- This trigger ensures that the total degree of questions assigned to an exam does not exceed the maximum degree defined for the associated course. It is triggered after any insert or update operation on the Exam_Question table and checks the total degree against the course's maximum degree, rolling back the transaction if the limit is exceeded.
CREATE TRIGGER Exam.Check_Total_Degree
ON Exam.Exam_Question
AFTER INSERT, UPDATE
AS
BEGIN
-- Check if the total degree for the exam exceeds the maximum degree defined for the course
    IF EXISTS (
        SELECT 1
        FROM Exam.Exam_Question EQ
        JOIN Exam.Exam E ON EQ.Exam_Id = E.Exam_Id
        JOIN Academic.Course C ON E.Crs_Id = C.Course_Id
        WHERE EQ.Exam_Id IN (SELECT Exam_Id FROM inserted)
        GROUP BY EQ.Exam_Id, C.MaxDegree
        HAVING SUM(EQ.Degree) > C.MaxDegree
    )
    BEGIN
        RAISERROR('Total Degree exceeded!',16,1);
        ROLLBACK;
    END
END
GO