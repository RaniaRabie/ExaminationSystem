/* =====================================================
================== Triggers ============================
===================================================== */

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