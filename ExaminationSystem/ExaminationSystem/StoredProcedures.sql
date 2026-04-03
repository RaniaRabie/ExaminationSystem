/* =====================================================
   =============== STORED PROCEDURES ====================
===================================================== */

DROP PROCEDURE IF EXISTS Exam.AddQuestion;
GO
-- This procedure adds a new question to the Question table. It checks for duplicate question IDs and validates the course ID before insertion.
CREATE PROCEDURE Exam.AddQuestion 
    @QId INT,
    @QType VARCHAR(50),
    @QHead VARCHAR(500),
    @CrsId INT
AS
BEGIN
-- Check for duplicate question ID
    IF EXISTS (SELECT 1 FROM Exam.Question WHERE Question_ID = @QId)
    BEGIN
        RAISERROR('Duplicate Id',16,1);
        RETURN;
    END
    -- Validate course ID
    IF NOT EXISTS (SELECT 1 FROM Academic.Course WHERE Course_Id = @CrsId)
    BEGIN
        RAISERROR('Course Not Found',16,1);
        RETURN;
    END

    INSERT INTO Exam.Question (Question_ID, Question_Type, Ques_Header, Course_Id)
    VALUES (@QId, @QType, @QHead, @CrsId);
END
GO


DROP PROCEDURE IF EXISTS Exam.UpdateQuestion;
GO
-- This procedure updates the header of an existing question. It checks if the question exists before attempting to update it.
CREATE PROCEDURE Exam.UpdateQuestion
    @QId INT,
    @QHead VARCHAR(500)
AS
BEGIN
-- Check if the question exists
    IF NOT EXISTS (SELECT 1 FROM Exam.Question WHERE Question_ID = @QId)
    BEGIN
        RAISERROR('Question Not Found',16,1);
        RETURN;
    END

    UPDATE Exam.Question
    SET Ques_Header = @QHead
    WHERE Question_ID = @QId;
END
GO


DROP PROCEDURE IF EXISTS Exam.DeleteQuestion;
GO
--  This procedure deletes a question from the Question table. It checks if the question exists before attempting to delete it.
CREATE PROCEDURE Exam.DeleteQuestion
    @QId INT
AS
BEGIN
--  Check if the question exists
    IF NOT EXISTS (SELECT 1 FROM Exam.Question WHERE Question_ID = @QId)
    BEGIN
    
        RAISERROR('Question Not Found',16,1);
        RETURN;
    END

    DELETE FROM Exam.Question
    WHERE Question_ID = @QId;
END
GO


DROP PROCEDURE IF EXISTS Exam.AddMCQQuestion;
GO
-- This procedure adds a new MCQ question to the MCQ table. It checks if the question exists in the Question table and is of type 'MCQ' before insertion.
CREATE PROCEDURE Exam.AddMCQQuestion
    @QId INT
AS
BEGIN
-- Check if the question exists and is of type 'MCQ'
    IF NOT EXISTS (
        SELECT 1 FROM Exam.Question
        WHERE Question_ID = @QId AND Question_Type = 'MCQ'
    )
    BEGIN
        RAISERROR('Invalid MCQ Question',16,1);
        RETURN;
    END

    INSERT INTO Exam.MCQ (MCQ_ID)
    VALUES (@QId);
END
GO


DROP PROCEDURE IF EXISTS Exam.AddChoice;
GO
-- This procedure adds a choice to an existing MCQ question. It checks if the MCQ question exists before inserting the choice.
CREATE PROCEDURE Exam.AddChoice
    @MCQId INT,
    @ChoiceId INT,
    @ChoiceText VARCHAR(100),
    @IsCorrect BIT
AS
BEGIN
-- Check if the MCQ question exists
    IF NOT EXISTS (SELECT 1 FROM Exam.MCQ WHERE MCQ_ID = @MCQId)
    BEGIN
        RAISERROR('MCQ Not Found',16,1);
        RETURN;
    END

    INSERT INTO Exam.MCQ_Choices (MCQ_ID, Choice_ID, Choice_Text, IsCorrect)
    VALUES (@MCQId, @ChoiceId, @ChoiceText, @IsCorrect);
END
GO


DROP PROCEDURE IF EXISTS Exam.AddTFQuestion;
GO
-- This procedure adds a new True/False question to the TF_Question table. It checks if the question exists in the Question table and is of type 'TF' before insertion.
CREATE PROCEDURE Exam.AddTFQuestion
    @QId INT,
    @CorrectAnswer BIT
AS
BEGIN
-- Check if the question exists and is of type 'TF'
    IF NOT EXISTS (
        SELECT 1 FROM Exam.Question
        WHERE Question_ID = @QId AND Question_Type = 'TF'
    )
    BEGIN
        RAISERROR('Invalid TF Question',16,1);
        RETURN;
    END

    INSERT INTO Exam.TF_Question (TF_Question_ID, Correct_Answer)
    VALUES (@QId, @CorrectAnswer);
END
GO


DROP PROCEDURE IF EXISTS Exam.AddTextQuestion;
GO
-- This procedure adds a new Text question to the Text_Question table. It checks if the question exists in the Question table and is of type 'Text' before insertion.
CREATE PROCEDURE Exam.AddTextQuestion
    @QId INT,
    @ModelAnswer VARCHAR(500)
AS
BEGIN
-- Check if the question exists and is of type 'Text'
    IF NOT EXISTS (
        SELECT 1 FROM Exam.Question
        WHERE Question_ID = @QId AND Question_Type = 'Text'
    )
    BEGIN
        RAISERROR('Invalid Text Question',16,1);
        RETURN;
    END

    INSERT INTO Exam.Text_Question (Text_Question_ID, Model_Answer)
    VALUES (@QId, @ModelAnswer);
END
GO

DROP PROCEDURE IF EXISTS Exam.Search_Question;
GO
-- This procedure allows searching for questions based on a text fragment in the question header.
CREATE PROCEDURE Exam.Search_Question
    @Text VARCHAR(200)
AS
BEGIN
    SELECT 
        Q.Question_ID,
        Q.Ques_Header,
        Q.Question_Type,
        C.Crs_Name
    FROM Exam.Question Q
    JOIN Academic.Course C ON Q.Course_Id = C.Course_Id
    WHERE Q.Ques_Header LIKE '%' + @Text + '%';
END
GO


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


DROP PROCEDURE IF EXISTS Student_Activity.Start_Exam;
GO
-- This procedure allows a student to start an exam. It checks if the exam is active and if the student has already started it. If the checks pass, it inserts a new record into the Student_Exam table with the start time and initializes the total score to 0.
CREATE PROCEDURE Student_Activity.Start_Exam
(
    @St_Id INT,
    @Exam_Id INT
)
AS
BEGIN
-- Check if the exam is active
    IF Exam.Is_Exam_Active(@Exam_Id) = 0
    BEGIN
        RAISERROR('Exam not available',16,1);
        RETURN;
    END
    -- Check if the student has already started the exam
    IF Student_Activity.Has_Started_Exam(@St_Id, @Exam_Id) = 1
    BEGIN
        RAISERROR('Already started',16,1);
        RETURN;
    END
    -- If checks pass, insert a new record into Student_Exam with the start time and initialize total score to 0
    INSERT INTO Student_Activity.Student_Exam
    VALUES (@St_Id, @Exam_Id, GETDATE(), NULL, 0);
END
GO

DROP PROCEDURE IF EXISTS Student_Activity.Submit_Answer;
GO
-- This procedure allows a student to submit an answer for a specific question in an exam. It performs several checks
CREATE PROCEDURE Student_Activity.Submit_Answer
(
    @St_Id INT,
    @Exam_Id INT,
    @Q_Id INT,
    @Answer VARCHAR(100)
)
AS
BEGIN
-- Check if the student has started the exam
    IF Student_Activity.Has_Started_Exam(@St_Id, @Exam_Id) = 0
    BEGIN
        RAISERROR('Start exam first',16,1);
        RETURN;
    END
    -- Check if the exam is active
    IF Exam.Is_Exam_Active(@Exam_Id) = 0
    BEGIN
        RAISERROR('Exam not active',16,1);
        RETURN;
    END
    -- Check if the question exists in the exam
    IF NOT EXISTS (
        SELECT 1 FROM Exam.Exam_Question 
        WHERE Exam_Id = @Exam_Id AND Q_Id = @Q_Id
    )
    BEGIN
        RAISERROR('Question not in exam',16,1);
        RETURN;
    END
    -- Check if the student has already submitted an answer for this question
    IF EXISTS (
        SELECT 1 FROM Student_Activity.Student_Answer
        WHERE St_Id = @St_Id AND Exam_Id = @Exam_Id AND Q_Id = @Q_Id
    )
    BEGIN
        RAISERROR('Already answered',16,1);
        RETURN;
    END

    DECLARE @IsCorrect BIT;
    DECLARE @Score INT;
    DECLARE @Degree INT;

    SET @IsCorrect = Exam.Check_Answer(@Q_Id, @Answer);
    SET @Degree = Exam.Get_Question_Degree(@Exam_Id, @Q_Id);
    SET @Score = CASE WHEN @IsCorrect = 1 THEN @Degree ELSE 0 END;

    INSERT INTO Student_Activity.Student_Answer
    VALUES (@St_Id, @Exam_Id, @Q_Id, @Answer, @IsCorrect, @Score);
END
GO

DROP PROCEDURE IF EXISTS Student_Activity.Finish_Exam;
GO
-- This procedure allows a student to finish an exam. It checks if the student has started the exam and then updates the Student_Exam record with the end time
--and calculates the total score using the Get_Student_TotalScore function.
CREATE PROCEDURE Student_Activity.Finish_Exam
(
    @St_Id INT,
    @Exam_Id INT
)
AS
BEGIN
    IF Student_Activity.Has_Started_Exam(@St_Id, @Exam_Id) = 0
    BEGIN
        RAISERROR('Exam not started',16,1);
        RETURN;
    END

    UPDATE Student_Activity.Student_Exam
    SET End_Time = GETDATE(),
        Total_Score = Student_Activity.Get_Student_TotalScore(@St_Id, @Exam_Id)
    WHERE St_Id = @St_Id AND Exam_Id = @Exam_Id;
END
GO

DROP PROCEDURE IF EXISTS Student_Activity.Get_Student_Exam;
GO
-- This procedure retrieves the questions and their corresponding degrees for a specific exam.
--It joins the Exam_Question table with the Question table to get the question details and filters by the provided exam ID.
CREATE PROCEDURE Student_Activity.Get_Student_Exam
(
    @Exam_Id INT
)
AS
BEGIN
    SELECT 
        Q.Question_ID,
        Q.Ques_Header,
        Q.Question_Type,
        EQ.Degree
    FROM Exam.Exam_Question EQ
    JOIN Exam.Question Q ON EQ.Q_Id = Q.Question_ID
    WHERE EQ.Exam_Id = @Exam_Id;
END
GO
-- This procedure allows searching for students by their name.
--It retrieves the student's ID, name, username, GPA, track name,
--and branch name by joining the Users, Student, Track, and Branch tables.
DROP PROCEDURE IF EXISTS Student_Activity.Search_Student;
GO
CREATE PROCEDURE Student_Activity.Search_Student
    @Name VARCHAR(100)
AS
BEGIN
    SELECT 
        U.User_Id,
        U.Name,
        U.UserName,
        S.GPA,
        T.Track_Name,
        B.Branch_Name
    FROM Core.Users U
    JOIN Core.Student S ON U.User_Id = S.Student_Id
    JOIN Academic.Track T ON S.Track_Id = T.Track_Id
    JOIN Academic.Branch B ON S.Branch_Id = B.Branch_Id
    WHERE U.Name LIKE '%' + @Name + '%';
END
GO
