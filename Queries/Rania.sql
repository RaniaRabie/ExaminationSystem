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

/* =====================================================
   ======================= VIEWS ========================
===================================================== */

DROP VIEW IF EXISTS Exam.V_QuestionPool;
GO
-- This view provides a pool of all questions along with their headers, types, and associated course names. It joins the Question table with the Course table to retrieve the course names.
CREATE VIEW Exam.V_QuestionPool AS
SELECT 
    Q.Question_ID,
    Q.Ques_Header,
    Q.Question_Type,
    C.Crs_Name
FROM Exam.Question Q
JOIN Academic.Course C ON C.Course_Id = Q.Course_Id;
GO


DROP VIEW IF EXISTS Exam.V_MCQQuestions;
GO
-- This view lists all MCQ questions along with their headers, choices, and whether each choice is correct. It joins the Question table with the MCQ and MCQ_Choices tables to retrieve the relevant information.
CREATE VIEW Exam.V_MCQQuestions AS
SELECT 
    Q.Question_ID,
    Q.Ques_Header,
    C.Choice_Text,
    C.IsCorrect
FROM Exam.Question Q
JOIN Exam.MCQ M ON Q.Question_ID = M.MCQ_ID
JOIN Exam.MCQ_Choices C ON M.MCQ_ID = C.MCQ_ID;
GO


DROP VIEW IF EXISTS Exam.V_MCQCorrectChoice;
GO
-- This view lists all MCQ questions along with their headers and the text of the correct choice. It filters the choices to include only those that are marked as correct.
CREATE VIEW Exam.V_MCQCorrectChoice AS
SELECT 
    Q.Question_ID,
    Q.Ques_Header,
    C.Choice_Text 
FROM Exam.Question Q
JOIN Exam.MCQ M ON Q.Question_ID = M.MCQ_ID
JOIN Exam.MCQ_Choices C ON M.MCQ_ID = C.MCQ_ID
WHERE C.IsCorrect = 1;
GO


DROP VIEW IF EXISTS Exam.V_TFQuestions;
GO
-- This view lists all True/False questions along with their headers and the correct answer. It joins the Question table with the TF_Question table to retrieve the relevant information.
CREATE VIEW Exam.V_TFQuestions AS
SELECT 
    Q.Question_ID,
    Q.Ques_Header,
    TF.Correct_Answer
FROM Exam.Question Q
JOIN Exam.TF_Question TF ON Q.Question_ID = TF.TF_Question_ID;
GO


DROP VIEW IF EXISTS Exam.V_TextQuestions;
GO
-- This view lists all Text questions along with their headers and the model answer. It joins the Question table with the Text_Question table to retrieve the relevant information.
CREATE VIEW Exam.V_TextQuestions AS
SELECT 
    Q.Question_ID,
    Q.Ques_Header,
    T.Model_Answer
FROM Exam.Question Q
JOIN Exam.Text_Question T ON Q.Question_ID = T.Text_Question_ID;
GO


/* =====================================================
   ======================= INDEXES ======================
===================================================== */

DROP INDEX IF EXISTS Index_Question_Course ON Exam.Question;
CREATE INDEX Index_Question_Course ON Exam.Question (Course_Id);

DROP INDEX IF EXISTS Index_MCQ_Choices_MCQ ON Exam.MCQ_Choices;
CREATE INDEX Index_MCQ_Choices_MCQ ON Exam.MCQ_Choices (MCQ_ID);

DROP INDEX IF EXISTS Index_MCQ_Choices_Correct ON Exam.MCQ_Choices;
CREATE INDEX Index_MCQ_Choices_Correct ON Exam.MCQ_Choices (MCQ_ID, IsCorrect);

DROP INDEX IF EXISTS Index_StudentAnswer_StudentExam ON Student_Activity.Student_Answer;
CREATE INDEX Index_StudentAnswer_StudentExam ON Student_Activity.Student_Answer (St_Id, Exam_Id);

DROP INDEX IF EXISTS Index_StudentAnswer_Question ON Student_Activity.Student_Answer;
CREATE INDEX Index_StudentAnswer_Question ON Student_Activity.Student_Answer (Q_Id);

DROP INDEX IF EXISTS Index_ExamQuestion_Exam ON Exam.Exam_Question;
CREATE INDEX Index_ExamQuestion_Exam ON Exam.Exam_Question (Exam_Id);

DROP INDEX IF EXISTS Index_ExamQuestion_Question ON Exam.Exam_Question;
CREATE INDEX Index_ExamQuestion_Question ON Exam.Exam_Question (Q_Id);

DROP INDEX IF EXISTS Index_StudentExam_Student ON Student_Activity.Student_Exam;
CREATE INDEX Index_StudentExam_Student ON Student_Activity.Student_Exam (St_Id);

DROP INDEX IF EXISTS Index_StudentExam_Exam ON Student_Activity.Student_Exam;
CREATE INDEX Index_StudentExam_Exam ON Student_Activity.Student_Exam (Exam_Id);
GO