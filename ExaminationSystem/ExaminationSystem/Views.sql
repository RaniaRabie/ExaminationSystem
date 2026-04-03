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
