--Functions
-- 1.Check answer for a question
CREATE FUNCTION Exam.Check_Answer
(
    @Q_Id INT,
    @Answer VARCHAR(100)
)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT = 0;

    -- MCQ
    IF EXISTS (SELECT 1 FROM exam.MCQ WHERE MCQ_ID = @Q_Id)
    BEGIN
    -- check if the answer is correct
        IF EXISTS (
            SELECT 1
            FROM exam.MCQ_Choices
            WHERE MCQ_ID = @Q_Id
            AND Choice_Text = @Answer
            AND IsCorrect = 1
        )
            SET @Result = 1;
    END

    -- TF
    ELSE IF EXISTS (SELECT 1 FROM exam.TF_Question WHERE TF_Question_ID = @Q_Id)
    BEGIN
    -- check if the answer is correct
        IF EXISTS (
            SELECT 1
            FROM exam.TF_Question
            WHERE TF_Question_ID = @Q_Id
            AND CAST(Correct_Answer AS VARCHAR) = @Answer
        )
            SET @Result = 1;
    END

    -- Text (basic)
    ELSE IF EXISTS (SELECT 1 FROM exam.Text_Question WHERE Text_Question_ID = @Q_Id)
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM exam.Text_Question
            WHERE Text_Question_ID = @Q_Id
            AND Model_Answer = @Answer
        )
            SET @Result = 1;
    END

    RETURN @Result;
END
go
-- 2.Get degree of a question in an exam
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
    FROM exam.Exam_Question
    WHERE Exam_Id = @Exam_Id AND Q_Id = @Q_Id;

    RETURN ISNULL(@Degree,0);
END
go
-- 3.Check if an exam is active
CREATE FUNCTION exam.Is_Exam_Active
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
END;
go
-- 4.Check if student has started an exam
CREATE FUNCTION student_Activity.Has_Started_Exam
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
        FROM student.Student_Exam
        WHERE St_Id = @St_Id AND Exam_Id = @Exam_Id
    )
        SET @Result = 1;

    RETURN @Result;
END
go
-- 5.Calculate total score for a student in an exam
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
go


--Procedures
-- 1.Start an exam for a student
CREATE PROCEDURE Student_Activity.Start_Exam
(    @St_Id INT,
    @Exam_Id INT
)
AS
BEGIN
    -- Check if the exam is active
    IF exam.Is_Exam_Active(@Exam_Id) = 0
    BEGIN
        PRINT 'Exam not available';
        RETURN;
    END
    -- Check if the student has already started the exam
    IF Student_Activity.Has_Started_Exam(@St_Id, @Exam_Id) = 1
    BEGIN
        PRINT 'Already started';
        RETURN;
    END

    INSERT INTO Student_Activity.Student_Exam
    (St_Id, Exam_Id, Start_Time, Total_Score)
    VALUES (@St_Id, @Exam_Id, GETDATE(), 0);

    PRINT 'Exam started';
END
go

-- 2.Submit an answer for a question in an exam
CREATE PROCEDURE Student_Activity.Submit_Answer
(    @St_Id INT,
    @Exam_Id INT,
    @Q_Id INT,
    @Answer VARCHAR(100)
)
AS
BEGIN   
    -- Check if the student has started the exam
    IF Student_Activity.Has_Started_Exam(@St_Id, @Exam_Id) = 0
    BEGIN
        PRINT 'Start exam first';
        RETURN;
    END
    -- Check if the exam is active
    IF exam.Is_Exam_Active(@Exam_Id) = 0
    BEGIN
        PRINT 'Exam not active';
        RETURN;
    END
    -- Check if the student has already answered this question
    IF EXISTS (
        SELECT 1 FROM Student_Activity.Student_Answer
        WHERE St_Id = @St_Id AND Exam_Id = @Exam_Id AND Q_Id = @Q_Id
    )
    BEGIN
        PRINT 'Already answered';
        RETURN;
    END

    DECLARE @IsCorrect BIT;
    DECLARE @Score INT;
    DECLARE @Degree INT;
    -- Check the answer and get the degree for the question
    SET @IsCorrect = exam.Check_Answer(@Q_Id, @Answer);
    SET @Degree = exam.Get_Question_Degree(@Exam_Id, @Q_Id);

    SET @Score = CASE WHEN @IsCorrect = 1 THEN @Degree ELSE 0 END;

    INSERT INTO Student_Activity.Student_Answer
    VALUES (@St_Id, @Exam_Id, @Q_Id, @Answer, @IsCorrect, @Score);

    PRINT 'Answer submitted';
END
go
-- 3.Finish an exam for a student and calculate total score
CREATE PROCEDURE Student_Activity.Finish_Exam
 (   @St_Id INT,
    @Exam_Id INT
 )
AS
BEGIN
    IF Student_Activity.Has_Started_Exam(@St_Id, @Exam_Id) = 0
    BEGIN
        PRINT 'Exam not started';
        RETURN;
    END

    UPDATE Student_Activity.Student_Exam
    SET End_Time = GETDATE(),
        Total_Score = student.Get_Student_TotalScore(@St_Id, @Exam_Id)
    WHERE St_Id = @St_Id AND Exam_Id = @Exam_Id;

    PRINT 'Exam finished';
END
go

--Triggers
-- 1.Update total score in Student_Exam after inserting an answer in Student_Answer
CREATE TRIGGER Student_Activity.trg_UpdateScore
ON Student_Activity.Student_Answer
AFTER INSERT
AS
BEGIN
    UPDATE se
    SET Total_Score = Student_Activity.Get_Student_TotalScore(se.St_Id, se.Exam_Id)
    FROM Student_Activity.Student_Exam se
    JOIN inserted i -- inserted table to get the St_Id and Exam_Id of the newly inserted answer
    ON se.St_Id = i.St_Id AND se.Exam_Id = i.Exam_Id;
END
go
--2.Prevent inserting answers for inactive exams
CREATE TRIGGER Student_Activity.trg_CheckTime
ON Student_Activity.Student_Answer
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE exam.Is_Exam_Active(i.Exam_Id) = 0
    )
    BEGIN
        PRINT 'Exam not active';
        RETURN;
    END

    INSERT INTO Student_Activity.Student_Answer
    SELECT * FROM inserted;
END
go
-- Views
-- 1.View to show student results for each exam
CREATE VIEW Student_Activity.Student_Results
AS
SELECT 
    St_Id,
    Exam_Id,
    Total_Score
FROM Student_Activity.Student_Exam;
go
-- 2.View to show detailed answers for each student in each exam
CREATE VIEW Student_Activity.Student_Answers_Details
AS
SELECT 
    St_Id,
    Exam_Id,
    Q_Id,
    Answer,
    IsCorrect,
    Score
FROM Student_Activity.Student_Answer;
go