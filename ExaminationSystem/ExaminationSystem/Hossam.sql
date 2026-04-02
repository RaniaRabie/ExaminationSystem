/* =============================================
   FUNCTIONS
============================================= */

DROP FUNCTION IF EXISTS Exam.Check_Answer;
GO
-- This function checks if a given answer for a specific question ID is correct. It handles different question types (MCQ, TF, Text) and returns 1 (true) if the answer is correct,
--and 0 (false) otherwise.
CREATE FUNCTION Exam.Check_Answer
(
    @Q_Id INT,
    @Answer VARCHAR(100)
)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT = 0;
    -- Check if the question is an MCQ
    IF EXISTS (SELECT 1 FROM Exam.MCQ WHERE MCQ_ID = @Q_Id)
    BEGIN
    -- If it's an MCQ, check if the provided answer matches any correct choice for that question
        IF EXISTS (
            SELECT 1 FROM Exam.MCQ_Choices
            WHERE MCQ_ID = @Q_Id
            AND Choice_Text = @Answer
            AND IsCorrect = 1
        )
            SET @Result = 1;
    END
    -- Check if the question is a True/False question
    ELSE IF EXISTS (SELECT 1 FROM Exam.TF_Question WHERE TF_Question_ID = @Q_Id)
    BEGIN
    -- If it's a TF question, check if the provided answer matches the correct answer (cast to VARCHAR for comparison)
        IF EXISTS (
            SELECT 1 FROM Exam.TF_Question
            WHERE TF_Question_ID = @Q_Id
            AND CAST(Correct_Answer AS VARCHAR) = @Answer
        )
            SET @Result = 1;
    END
    -- Check if the question is a Text question
    ELSE IF EXISTS (SELECT 1 FROM Exam.Text_Question WHERE Text_Question_ID = @Q_Id)
    BEGIN
    -- If it's a Text question, check if the provided answer is contained within the model answer (using LIKE for partial matching)
        IF EXISTS (
            SELECT 1 FROM Exam.Text_Question
            WHERE Text_Question_ID = @Q_Id
            AND Model_Answer LIKE '%' + @Answer + '%'
        )
            SET @Result = 1;
    END

    RETURN @Result;
END
GO

DROP FUNCTION IF EXISTS Exam.Get_Question_Degree;
GO
-- This function retrieves the degree (point value) of a specific question in a given exam. It takes the exam ID and question ID as parameters and returns the degree. If the question is not found in the exam,
--it returns 0.
CREATE FUNCTION Exam.Get_Question_Degree
(
    @Exam_Id INT,
    @Q_Id INT
)
RETURNS INT
AS
BEGIN
    DECLARE @Degree INT;

    SELECT @Degree = Degree
    FROM Exam.Exam_Question
    WHERE Exam_Id = @Exam_Id AND Q_Id = @Q_Id;

    RETURN ISNULL(@Degree,0);
END
GO
 
DROP FUNCTION IF EXISTS Exam.Is_Exam_Active;
GO
-- This function checks if a given exam is currently active by comparing the current date and time with the exam's start and end times. It returns 1 (true) if the exam is active,
--and 0 (false) otherwise.
CREATE FUNCTION Exam.Is_Exam_Active
(
    @Exam_Id INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT = 0;

    IF EXISTS (
        SELECT 1
        FROM Exam.Exam
        WHERE Exam_Id = @Exam_Id
        AND GETDATE() BETWEEN StartTime AND EndTime
    )
        SET @Result = 1;

    RETURN @Result;
END
GO

DROP FUNCTION IF EXISTS Student_Activity.Has_Started_Exam;
GO
-- This function checks if a student has already started a specific exam by looking for a record in the Student_Exam table. It returns 1 (true) if the student has started the exam,
--and 0 (false) otherwise.
CREATE FUNCTION Student_Activity.Has_Started_Exam
(
    @St_Id INT,
    @Exam_Id INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT = 0;

    IF EXISTS (
        SELECT 1
        FROM Student_Activity.Student_Exam
        WHERE St_Id = @St_Id AND Exam_Id = @Exam_Id
    )
        SET @Result = 1;

    RETURN @Result;
END
GO

DROP FUNCTION IF EXISTS Student_Activity.Get_Student_TotalScore;
GO
-- This function calculates the total score for a student in a specific exam by summing up the scores of all their answers for that exam.
--If there are no answers, it returns 0.
CREATE FUNCTION Student_Activity.Get_Student_TotalScore
(
    @St_Id INT,
    @Exam_Id INT
)
RETURNS INT
AS
BEGIN
    DECLARE @Total INT;

    SELECT @Total = SUM(Score)
    FROM Student_Activity.Student_Answer
    WHERE St_Id = @St_Id AND Exam_Id = @Exam_Id;

    RETURN ISNULL(@Total,0);
END
GO


/* =============================================
   PROCEDURES
============================================= */

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
/* =============================================
   TRIGGER
============================================= */

DROP TRIGGER IF EXISTS Student_Activity.trg_UpdateScore;
GO
-- This trigger is executed after a new record is inserted into the Student_Answer table. It performs two main functions:
CREATE TRIGGER Student_Activity.trg_UpdateScore
ON Student_Activity.Student_Answer
AFTER INSERT
AS
BEGIN
-- Check if the exam is still active before updating the score. If the exam is not active,
--raise an error and roll back the transaction to prevent score updates for inactive exams.
    IF EXISTS (
        SELECT 1 FROM inserted i
        WHERE Exam.Is_Exam_Active(i.Exam_Id) = 0
    )
    BEGIN
        RAISERROR('Exam not active',16,1);
        ROLLBACK;
        RETURN;
    END
    -- After a student submits an answer, this trigger updates the total score for that student and
    --exam in the Student_Exam table by calling the Get_Student_TotalScore function.
    UPDATE se
    SET Total_Score = Student_Activity.Get_Student_TotalScore(se.St_Id, se.Exam_Id)
    FROM Student_Activity.Student_Exam se
    JOIN inserted i
    ON se.St_Id = i.St_Id AND se.Exam_Id = i.Exam_Id;
END
GO


/* =============================================
   VIEWS
============================================= */

DROP VIEW IF EXISTS Student_Activity.Student_Results;
GO
-- This view provides a summary of students' exam results, showing the student ID, exam ID, and total score for each exam taken by students.
--It selects data from the Student_Exam table.
CREATE VIEW Student_Activity.Student_Results
AS
SELECT St_Id, Exam_Id, Total_Score
FROM Student_Activity.Student_Exam;
GO

DROP VIEW IF EXISTS Student_Activity.Student_Answers_Details;
GO
-- This view provides detailed information about students' answers for each question in an exam, including whether the answer was correct and the score received for that answer.
--It selects data from the Student_Answer table.
CREATE VIEW Student_Activity.Student_Answers_Details
AS
SELECT St_Id, Exam_Id, Q_Id, Answer, IsCorrect, Score
FROM Student_Activity.Student_Answer;
GO

DROP VIEW IF EXISTS Student_Activity.V_Student_Full_Report;
GO
-- This view provides a comprehensive report of students' exam performance, including the student's name, course name, exam ID, and total score. It joins the Student_Exam table with the Student,
--Users, Exam, and Course tables to gather all relevant information.
CREATE VIEW Student_Activity.V_Student_Full_Report
AS
SELECT 
    U.Name AS Student_Name,
    C.Crs_Name,
    E.Exam_Id,
    SE.Total_Score
FROM Student_Activity.Student_Exam SE
JOIN Core.Student S ON SE.St_Id = S.Student_Id
JOIN Core.Users U ON S.Student_Id = U.User_Id
JOIN Exam.Exam E ON SE.Exam_Id = E.Exam_Id
JOIN Academic.Course C ON E.Crs_Id = C.Course_Id;
GO

DROP VIEW IF EXISTS Student_Activity.V_Exam_Summary;
GO
-- This view provides a summary of exam results, showing the total number of students who took each exam,
--the average score, and the maximum and minimum scores for each exam.
CREATE VIEW Student_Activity.V_Exam_Summary
AS
SELECT 
    Exam_Id,
    COUNT(St_Id) AS Total_Students,
    AVG(Total_Score) AS Avg_Score,
    MAX(Total_Score) AS Max_Score,
    MIN(Total_Score) AS Min_Score
FROM Student_Activity.Student_Exam
GROUP BY Exam_Id;
GO

DROP VIEW IF EXISTS Student_Activity.V_Student_Answers_With_Questions;
GO
CREATE VIEW Student_Activity.V_Student_Answers_With_Questions
AS
SELECT 
    SA.St_Id,
    Q.Ques_Header,
    SA.Answer,
    SA.IsCorrect,
    SA.Score
FROM Student_Activity.Student_Answer SA
JOIN Exam.Question Q ON SA.Q_Id = Q.Question_ID;
GO
