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