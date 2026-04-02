/* =====================================================
   1. CREATE EXAM
===================================================== */

DECLARE @StartTime DATETIME;
DECLARE @EndTime DATETIME;

SET @StartTime = DATEADD(MINUTE, -10, GETDATE());
SET @EndTime = DATEADD(HOUR, 1, GETDATE());

EXEC Exam.Create_Exam
    @Exam_Id = 100,
    @Crs_Id = 1,
    @Year = 2026,
    @ExamType = 'Exam',
    @StartTime = @StartTime,
    @EndTime = @EndTime;
GO


/* =====================================================
   2. ADD QUESTIONS TO EXAM
===================================================== */

EXEC Exam.Add_Question_To_Exam 100, 1, 30;
EXEC Exam.Add_Question_To_Exam 100, 2, 30;
EXEC Exam.Add_Question_To_Exam 100, 3, 40;
GO


/* =====================================================
   3. ASSIGN EXAM TO STUDENTS
===================================================== */

EXEC Exam.Assign_Exam
    @Exam_Id = 100,
    @Intake_Id = 3,
    @Branch_Id = 1,
    @Track_Id = 1;
GO


/* =====================================================
   4. SEARCH TEST
===================================================== */

-- Search Student
EXEC Student_Activity.Search_Student 'Ahmed';

-- Search Exam
DECLARE @D DATE;
SET @D = CAST(GETDATE() AS DATE);

EXEC Exam.Search_Exam_ByDate @D;

-- Search Question
EXEC Exam.Search_Question 'Java';
GO


/* =====================================================
   5. STUDENT START EXAM
===================================================== */

EXEC Student_Activity.Start_Exam 1, 100;
GO


/* =====================================================
   6. SUBMIT ANSWERS
===================================================== */

EXEC Student_Activity.Submit_Answer 1, 100, 1, 'Java Virtual Machine';
EXEC Student_Activity.Submit_Answer 1, 100, 2, '1';
EXEC Student_Activity.Submit_Answer 1, 100, 3, 'Encapsulation';
GO


/* =====================================================
   7. FINISH EXAM
===================================================== */

EXEC Student_Activity.Finish_Exam 1, 100;
GO


/* =====================================================
   8. CHECK RESULTS (VIEWS)
===================================================== */

SELECT * FROM Student_Activity.Student_Results;
SELECT * FROM Student_Activity.Student_Answers_Details;
GO


/* =====================================================
   9. CHECK REPORTS
===================================================== */

SELECT * FROM Student_Activity.V_Student_Full_Report;
SELECT * FROM Student_Activity.V_Exam_Summary;
GO


/* =====================================================
   10. CHECK FUNCTIONS
===================================================== */

SELECT Exam.Get_Question_Degree(100,1) AS QuestionDegree;

SELECT Student_Activity.Get_Student_TotalScore(1,100) AS TotalScore;
GO


/* =====================================================
   11. NEGATIVE TEST (ERROR HANDLING)
===================================================== */

-- Duplicate exam
Declare @a Date;
declare @b Time;
set @a=GETDATE();
set @b=DATEADD(HOUR,1,GETDATE());

EXEC Exam.Create_Exam 100,1,2026,'Exam',@a,@b;

-- Submit without starting
EXEC Student_Activity.Submit_Answer 2,100,1,'Test';

-- Add duplicate question
EXEC Exam.Add_Question_To_Exam 100,1,30;
GO