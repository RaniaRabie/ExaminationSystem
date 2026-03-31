use ExaminationSystem

-- >>>>>>>>>>>>>>>....... Stored Procedure .......<<<<<<<<<<<<<<<<<

create proc AddQuestion @QId int , @QType varchar(50), @QHead varchar(500), @CrsId int
as
begin 
	if not exists ( select Question_ID from Exam.Question where Question_ID = @QId)
		select 'Duplicate Id'
	if not exists (SELECT 1 FROM Academic.Course WHERE Course_Id = @CrsId)
			select 'Course Not Found'

		INSERT INTO Exam.Question(Question_ID, Question_Type, Ques_Header, Course_Id) 
		VALUES(@QId, @QType, @QHead, @CrsId)
end

CREATE PROC UpdateQuestion
    @QId INT,
    @QHead VARCHAR(500)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Exam.Question WHERE Question_ID = @QId)
    BEGIN
        select 'Question Not Found';
    END

    UPDATE Exam.Question
    SET Ques_Header = @QHead
    WHERE Question_ID = @QId;
END

CREATE PROC DeleteQuestion
    @QId INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Exam.Question WHERE Question_ID = @QId)
    BEGIN
        select 'Question Not Found';
    END

    DELETE FROM Exam.Question
    WHERE Question_ID = @QId;
END

-------------------------------------------------------------

create proc AddMCQQuestion
    @QId int
as
begin
    IF not exists (
        select 1 from Question 
        where Question_ID = @QId and Question_Type = 'MCQ'
    )
        select 'Invalid MCQ Question';

    insert into Exam.MCQ (MCQ_ID)
    values (@QId);
end
-------------------------------------------------------------

create proc AddChoice
    @MCQId int,
    @ChoiceId int,
    @ChoiceText varchar(100),
    @IsCorrect bit
as
begin
    if not exists (select 1 from MCQ where MCQ_ID = @MCQId)
        select 'MCQ Not Found';

   insert into Exam.MCQ_Choices (MCQ_ID, Choice_ID, Choice_Text, IsCorrect)
    values (@MCQId, @ChoiceId, @ChoiceText, @IsCorrect);
end

------------------------------------------------------------------

create proc AddTFQuestion
    @QId int,
    @CorrectAnswer bit
as
begin
    if not exists(
        select 1 from Question 
        where Question_ID = @QId and Question_Type = 'TF'
    )
        select 'Invalid TF Question';

    insert into Exam.TF_Question (TF_Question_ID, Correct_Answer)
    values (@QId, @CorrectAnswer);
end

-----------------------------------------------------------------------

create proc AddTextQuestion
    @QId int,
    @ModelAnswer varchar(500)
AS
BEGIN
    if not exists (
        select 1 from Question 
        where Question_ID = @QId and Question_Type = 'Text'
    )
        select 'Invalid Text Question';

    insert into Exam.Text_Question (Text_Question_ID, Model_Answer)
    values (@QId, @ModelAnswer);
end

------------------------------------------------------------------------

-- >>>>>>>>>>>>>>>....... Views .......<<<<<<<<<<<<<<<<<

-- QuestionPool
create view vw_QuestionPool as
select 
    Q.Question_ID,
    Q.Ques_Header,
    Q.Question_Type,
    C.Crs_Name
from Exam.Question Q inner join Academic.Course C
on C.Course_Id = Q.Course_Id

select * from vw_QuestionPool

---------------------------------------------

-- MCQQuestions => Show all MCQ Questions with its Choices
create view vw_MCQQuestions 
as
select 
    Q.Question_ID,
    Q.Ques_Header,
    C.Choice_Text,
    C.IsCorrect
from Exam.Question Q inner join Exam.MCQ M
on Q.Question_ID = M.MCQ_ID
inner join Exam.MCQ_Choices C 
on M.MCQ_ID = C.MCQ_ID;

select * from vw_MCQQuestions


-- vw_MCQWithCorrectChoice => show MCQ question with its correct value
create view vw_MCQWithCorrectChoice
as
select 
    Q.Question_ID,
    Q.Ques_Header,
    C.Choice_Text 
from Exam.Question Q inner join Exam.MCQ M
on Q.Question_ID = M.MCQ_ID
inner join Exam.MCQ_Choices C 
on M.MCQ_ID = C.MCQ_ID
where C.IsCorrect = 1

select * from vw_MCQWithCorrectChoice
---------------------------------------------

-- vw_TFQuestions =>  show TF question with its correct value
create view vw_TFQuestions
as
select 
    Q.Question_ID,
    Q.Ques_Header,
    TF.Correct_Answer
from Exam.Question Q inner join Exam.TF_Question TF
on Q.Question_ID = TF.TF_Question_ID

select * from vw_TFQuestions

--------------------------------------------------------------

-- vw_TextQuestions =>  show Text question with its correct value
create view vw_TextQuestions
as
select 
    Q.Question_ID,
    Q.Ques_Header,
    T.Model_Answer
from Exam.Question Q inner join Exam.Text_Question T
on Q.Question_ID = T.Text_Question_ID

select * from vw_TextQuestions

--------------------------------------------------------------------------


create view vw_StudentAnswers 
as
select SA.St_Id,
    SA.Exam_Id,
    SA.Q_Id,
    SA.Answer,
    SA.IsCorrect,
    SA.Score
from Student_Activity.Student_Answer SA

select * 
from vw_StudentAnswers SA
order by SA.St_Id, SA.Exam_Id, SA.Q_Id



-- >>>>>>>>>>>>>>>....... Indexes .......<<<<<<<<<<<<<<<<<

-- Because We will get Question in specific Course
create nonclustered index Index_Question_Course
on Exam.Question(Course_Id);

-- Because we always get MCQ_Choices for an MCQ 
create nonclustered index Index_MCQ_Choices_MCQ
on Exam.MCQ_Choices (MCQ_ID);

-- Because we always check if answer is correct
create nonclustered index Index_MCQ_Choices_Correct
on Exam.MCQ_Choices (MCQ_ID, IsCorrect);

-- Because we will get StudentAnswer in an Exam
create nonclustered index Index_StudentAnswer_StudentExam
on Student_Activity.Student_Answer (St_Id, Exam_Id);


create nonclustered index Index_StudentAnswer_Question
on Student_Activity.Student_Answer (Q_Id);


create nonclustered index Index_ExamQuestion_Exam
on Exam.Exam_Question (Exam_Id);


create nonclustered index Index_ExamQuestion_Question
on Exam.Exam_Question (Q_Id);


create nonclustered index Index_StudentExam_Student
ON Student_Activity.Student_Exam (St_Id);


create nonclustered index Index_StudentExam_Exam
on Student_Activity.Student_Exam (Exam_Id);
