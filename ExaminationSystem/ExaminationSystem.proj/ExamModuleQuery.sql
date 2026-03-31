-- PHASE 1: EXAM CORE (CRUD)
-- 1. Create Exam
CREATE PROCEDURE Exam.Create_Exam
    @Exam_Id INT,
    @Crs_Id INT,
    @Year INT,
    @ExamType VARCHAR(50),
    @StartTime DATETIME,
    @EndTime DATETIME
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Academic.Course WHERE Course_Id = @Crs_Id)
    BEGIN
        PRINT 'Course does not exist';
        RETURN;
    END

    IF (@EndTime <= @StartTime)
    BEGIN
        PRINT 'Invalid Time';
        RETURN;
    END

    INSERT INTO Exam.Exam (Exam_Id, Crs_Id, Year, ExamType, StartTime, EndTime)
    VALUES (@Exam_Id, @Crs_Id, @Year, @ExamType, @StartTime, @EndTime);

    PRINT 'Exam Created Successfully';
END;
GO

-- 2. Get Exam 
CREATE PROCEDURE Exam.Get_Exam
    @Exam_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Exam.Exam WHERE Exam_Id = @Exam_Id;
END;
GO

-- 3. Update Exam
CREATE PROCEDURE Exam.Update_Exam
    @Exam_Id INT,
    @ExamType VARCHAR(50),
    @StartTime DATETIME,
    @EndTime DATETIME
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Exam.Exam WHERE Exam_Id = @Exam_Id)
    BEGIN
        PRINT 'Exam not found';
        RETURN;
    END

    IF (@EndTime <= @StartTime)
    BEGIN
        PRINT 'Invalid Time';
        RETURN;
    END

    UPDATE Exam.Exam
    SET ExamType = @ExamType, StartTime = @StartTime, EndTime = @EndTime
    WHERE Exam_Id = @Exam_Id;

    PRINT 'Updated Successfully';
END;
GO

-- 4. Delete Exam
CREATE PROCEDURE Exam.Delete_Exam
    @Exam_Id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Exam.Exam WHERE Exam_Id = @Exam_Id)
    BEGIN
        PRINT 'Exam not found';
        RETURN;
    END

    DELETE FROM Exam.Exam_Question WHERE Exam_Id = @Exam_Id;
    DELETE FROM Exam.Exam WHERE Exam_Id = @Exam_Id;

    PRINT 'Deleted Successfully';
END;
GO

-- PHASE 2: BUILD EXAM
-- 5. Add Question to Exam
CREATE PROCEDURE Exam.Add_Question_To_Exam
    @Exam_Id INT,
    @Q_Id INT,
    @Degree INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Exam.Exam WHERE Exam_Id = @Exam_Id)
    BEGIN
        PRINT 'Exam not found';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Exam.Question WHERE Question_ID = @Q_Id)
    BEGIN
        PRINT 'Question not found';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Exam.Exam_Question WHERE Exam_Id = @Exam_Id AND Q_Id = @Q_Id)
    BEGIN
        PRINT 'Question already added';
        RETURN;
    END

    IF @Degree <= 0
    BEGIN
        PRINT 'Invalid Degree';
        RETURN;
    END

    DECLARE @CurrentTotal INT;
    DECLARE @MaxDegree INT;

    SELECT @CurrentTotal = ISNULL(SUM(Degree), 0) FROM Exam.Exam_Question WHERE Exam_Id = @Exam_Id;
    SELECT @MaxDegree = C.MaxDegree FROM Academic.Course C JOIN Exam.Exam E ON C.Course_Id = E.Crs_Id WHERE E.Exam_Id = @Exam_Id;

    IF (@CurrentTotal + @Degree > @MaxDegree)
    BEGIN
        PRINT 'Exceeds course max degree';
        RETURN;
    END

    INSERT INTO Exam.Exam_Question (Exam_Id, Q_Id, Degree) VALUES (@Exam_Id, @Q_Id, @Degree);
    PRINT 'Question added successfully';
END;
GO

-- 6. Remove Question from Exam
CREATE PROCEDURE Exam.Remove_Question_From_Exam
    @Exam_Id INT,
    @Q_Id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Exam.Exam_Question WHERE Exam_Id = @Exam_Id AND Q_Id = @Q_Id)
    BEGIN
        PRINT 'Question not found in exam';
        RETURN;
    END

    DELETE FROM Exam.Exam_Question WHERE Exam_Id = @Exam_Id AND Q_Id = @Q_Id;
    PRINT 'Deleted successfully';
END;
GO

-- PHASE 3: ASSIGN EXAM
-- 7. Assign Exam
CREATE PROCEDURE Exam.Assign_Exam
    @Exam_Id INT,
    @Intake_Id INT,
    @Branch_Id INT,
    @Track_Id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Exam.Exam WHERE Exam_Id = @Exam_Id)
    BEGIN
        PRINT 'Exam not found';
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM Exam.Exam_Intake_Branch_Track
        WHERE Exam_Id = @Exam_Id AND Intake_Id = @Intake_Id AND Branch_Id = @Branch_Id AND Track_Id = @Track_Id
    )
    BEGIN
        PRINT 'Already assigned';
        RETURN;
    END

    INSERT INTO Exam.Exam_Intake_Branch_Track VALUES (@Exam_Id, @Intake_Id, @Branch_Id, @Track_Id);
    PRINT 'Assigned successfully';
END;
GO

-- PHASE 4: FUNCTIONS
-- 8. Function: Get Total Degree
CREATE FUNCTION Exam.Get_Exam_TotalDegree (@Exam_Id INT)
RETURNS INT
AS
BEGIN
    DECLARE @Total INT;
    SELECT @Total = ISNULL(SUM(Degree), 0) FROM Exam.Exam_Question WHERE Exam_Id = @Exam_Id;
    RETURN @Total;
END;
GO

--SELECT Exam.Get_Exam_TotalDegree(1);


-- 9. Function: Get Exam Questions
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

--SELECT * FROM Exam.Get_Exam_Questions(1);


-- PHASE 5: VIEWS
-- 10. View: Exam Details
CREATE VIEW Exam.V_Exam_Details
AS
SELECT E.Exam_Id, E.ExamType, E.Year, E.StartTime, E.EndTime, E.TotalTime, C.Crs_Name, C.MaxDegree
FROM Exam.Exam E
JOIN Academic.Course C ON E.Crs_Id = C.Course_Id;
GO

-- 11. View: Exam Questions
CREATE VIEW Exam.V_Exam_Questions
AS
SELECT E.Exam_Id, Q.Question_ID, Q.Ques_Header, Q.Question_Type, EQ.Degree
FROM Exam.Exam E
JOIN Exam.Exam_Question EQ ON E.Exam_Id = EQ.Exam_Id
JOIN Exam.Question Q ON EQ.Q_Id = Q.Question_ID;
GO

-- PHASE 6: TRIGGER
-- 12. Trigger
CREATE TRIGGER Exam.Check_Total_Degree
ON Exam.Exam_Question
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Exam.Exam_Question EQ
        JOIN Exam.Exam E ON EQ.Exam_Id = E.Exam_Id
        JOIN Academic.Course C ON E.Crs_Id = C.Course_Id
        WHERE EQ.Exam_Id IN (SELECT Exam_Id FROM inserted)
        GROUP BY EQ.Exam_Id, C.MaxDegree
        HAVING SUM(EQ.Degree) > C.MaxDegree
    )
    BEGIN
        RAISERROR ('Total Degree exceeded!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO