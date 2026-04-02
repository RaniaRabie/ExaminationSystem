
-- Create Core Schema
create schema Core;
go
-- Trnasfer tables Into Core Schema
alter schema Core transfer Users;
alter schema Core transfer Student;
alter schema Core transfer Instructor;
go
/* ============================================= */

-- Create Academic Schema
CREATE SCHEMA Academic;
go
-- Trnasfer tables Into Academic Schema
alter schema Academic transfer Course;
alter schema Academic transfer Instructor_Course;
alter schema Academic transfer Department;
alter schema Academic transfer Track;
alter schema Academic transfer Branch;
alter schema Academic transfer Intake;
alter schema Academic transfer Branch_Track;
alter schema Academic transfer Track_Intake;

go
/* ============================================= */

-- Create Exam Schema
CREATE schema Exam;
go
-- Trsnafer tables Into Exam Schema
alter schema Exam transfer Exam;
alter schema Exam transfer Question;
alter schema Exam transfer MCQ;
alter schema Exam transfer MCQ_Choices;
alter schema Exam transfer TF_Question;
alter schema Exam transfer Text_Question;
alter schema Exam transfer Exam_Question;
alter schema Exam transfer Instructor_Exam;
alter schema Exam transfer Exam_Intake_Branch_Track;

go
/* ============================================= */

-- Create Student_Activity Schema
create schema Student_Activity
go
-- Transfer tables Into Student Schema
alter schema Student_Activity transfer Student_Exam;
alter schema Student_Activity transfer Student_Answer;
alter schema Student_Activity transfer Student_Intake;

