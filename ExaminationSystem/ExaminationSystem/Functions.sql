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
