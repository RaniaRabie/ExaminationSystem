USE [master]
GO
/****** Object:  Database [Examination_System]    Script Date: 4/2/2026 2:23:55 PM ******/
CREATE DATABASE [Examination_System]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Examination_System', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\Examination_System.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Examination_System_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\Examination_System_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [Examination_System] ADD FILEGROUP [Secondary]
GO
ALTER DATABASE [Examination_System] ADD FILEGROUP [Third]
GO
ALTER DATABASE [Examination_System] MODIFY FILEGROUP [PRIMARY] AUTOGROW_ALL_FILES
GO
ALTER DATABASE [Examination_System] SET COMPATIBILITY_LEVEL = 170
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Examination_System].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Examination_System] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Examination_System] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Examination_System] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Examination_System] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Examination_System] SET ARITHABORT OFF 
GO
ALTER DATABASE [Examination_System] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Examination_System] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Examination_System] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Examination_System] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Examination_System] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Examination_System] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Examination_System] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Examination_System] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Examination_System] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Examination_System] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Examination_System] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Examination_System] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Examination_System] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Examination_System] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Examination_System] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Examination_System] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Examination_System] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Examination_System] SET RECOVERY FULL 
GO
ALTER DATABASE [Examination_System] SET  MULTI_USER 
GO
ALTER DATABASE [Examination_System] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Examination_System] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Examination_System] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Examination_System] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Examination_System] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [Examination_System] SET OPTIMIZED_LOCKING = OFF 
GO
ALTER DATABASE [Examination_System] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [Examination_System] SET QUERY_STORE = ON
GO
ALTER DATABASE [Examination_System] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [Examination_System]
GO
/****** Object:  User [TM_User]    Script Date: 4/2/2026 2:23:55 PM ******/
CREATE USER [TM_User] FOR LOGIN [TM_Login] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [Student_User]    Script Date: 4/2/2026 2:23:55 PM ******/
CREATE USER [Student_User] FOR LOGIN [Student_Login] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [Instructor_User]    Script Date: 4/2/2026 2:23:55 PM ******/
CREATE USER [Instructor_User] FOR LOGIN [Instructor_Login] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [Admin_User]    Script Date: 4/2/2026 2:23:55 PM ******/
CREATE USER [Admin_User] FOR LOGIN [Admin_Login] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  DatabaseRole [TrainingManager_Role]    Script Date: 4/2/2026 2:23:55 PM ******/
CREATE ROLE [TrainingManager_Role]
GO
/****** Object:  DatabaseRole [Student_Role]    Script Date: 4/2/2026 2:23:55 PM ******/
CREATE ROLE [Student_Role]
GO
/****** Object:  DatabaseRole [Instructor_Role]    Script Date: 4/2/2026 2:23:55 PM ******/
CREATE ROLE [Instructor_Role]
GO
/****** Object:  DatabaseRole [Admin_Role]    Script Date: 4/2/2026 2:23:55 PM ******/
CREATE ROLE [Admin_Role]
GO
ALTER ROLE [TrainingManager_Role] ADD MEMBER [TM_User]
GO
ALTER ROLE [Student_Role] ADD MEMBER [Student_User]
GO
ALTER ROLE [Instructor_Role] ADD MEMBER [Instructor_User]
GO
ALTER ROLE [Admin_Role] ADD MEMBER [Admin_User]
GO
ALTER ROLE [db_owner] ADD MEMBER [Admin_User]
GO
/****** Object:  Schema [Academic]    Script Date: 4/2/2026 2:23:55 PM ******/
CREATE SCHEMA [Academic]
GO
/****** Object:  Schema [Core]    Script Date: 4/2/2026 2:23:55 PM ******/
CREATE SCHEMA [Core]
GO
/****** Object:  Schema [Exam]    Script Date: 4/2/2026 2:23:55 PM ******/
CREATE SCHEMA [Exam]
GO
/****** Object:  Schema [Student_Activity]    Script Date: 4/2/2026 2:23:55 PM ******/
CREATE SCHEMA [Student_Activity]
GO
/****** Object:  UserDefinedFunction [Exam].[Check_Answer]    Script Date: 4/2/2026 2:23:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This function checks if a given answer for a specific question ID is correct. It handles different question types (MCQ, TF, Text) and returns 1 (true) if the answer is correct,
--and 0 (false) otherwise.
CREATE FUNCTION [Exam].[Check_Answer]
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
/****** Object:  UserDefinedFunction [Exam].[Get_Exam_TotalDegree]    Script Date: 4/2/2026 2:23:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This function calculates the total degree of an exam by summing the degrees of all questions associated with the specified exam ID. It returns the total degree as an integer.
CREATE FUNCTION [Exam].[Get_Exam_TotalDegree] (@Exam_Id INT)
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
/****** Object:  UserDefinedFunction [Exam].[Get_Question_Degree]    Script Date: 4/2/2026 2:23:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This function retrieves the degree (point value) of a specific question in a given exam. It takes the exam ID and question ID as parameters and returns the degree. If the question is not found in the exam,
--it returns 0.
CREATE FUNCTION [Exam].[Get_Question_Degree]
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
/****** Object:  UserDefinedFunction [Exam].[Is_Exam_Active]    Script Date: 4/2/2026 2:23:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This function checks if a given exam is currently active by comparing the current date and time with the exam's start and end times. It returns 1 (true) if the exam is active,
--and 0 (false) otherwise.
CREATE FUNCTION [Exam].[Is_Exam_Active]
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
/****** Object:  UserDefinedFunction [Student_Activity].[Get_Student_TotalScore]    Script Date: 4/2/2026 2:23:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This function calculates the total score for a student in a specific exam by summing up the scores of all their answers for that exam.
--If there are no answers, it returns 0.
CREATE FUNCTION [Student_Activity].[Get_Student_TotalScore]
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
/****** Object:  UserDefinedFunction [Student_Activity].[Has_Started_Exam]    Script Date: 4/2/2026 2:23:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This function checks if a student has already started a specific exam by looking for a record in the Student_Exam table. It returns 1 (true) if the student has started the exam,
--and 0 (false) otherwise.
CREATE FUNCTION [Student_Activity].[Has_Started_Exam]
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
/****** Object:  Table [Exam].[Exam_Question]    Script Date: 4/2/2026 2:23:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Exam].[Exam_Question](
	[Exam_Id] [int] NOT NULL,
	[Q_Id] [int] NOT NULL,
	[Degree] [int] NULL,
 CONSTRAINT [PK_ExamQuestion] PRIMARY KEY CLUSTERED 
(
	[Exam_Id] ASC,
	[Q_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Exam].[Question]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Exam].[Question](
	[Question_ID] [int] NOT NULL,
	[Question_Type] [varchar](50) NULL,
	[Ques_Header] [varchar](500) NULL,
	[Course_Id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Question_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [Exam].[Get_Exam_Questions]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This function retrieves the questions associated with a specific exam ID, including their headers, types, and assigned degrees. It returns a table containing the question details for the specified exam.
CREATE FUNCTION [Exam].[Get_Exam_Questions] (@Exam_Id INT)
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
/****** Object:  Table [Academic].[Course]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Academic].[Course](
	[Course_Id] [int] NOT NULL,
	[Crs_Name] [varchar](50) NULL,
	[Description] [varchar](255) NULL,
	[MinDegree] [int] NULL,
	[MaxDegree] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Course_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Exam].[Exam]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Exam].[Exam](
	[Exam_Id] [int] NOT NULL,
	[Crs_Id] [int] NULL,
	[Year] [int] NULL,
	[ExamType] [varchar](50) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[TotalTime]  AS (datediff(minute,[StartTime],[EndTime])) PERSISTED,
PRIMARY KEY CLUSTERED 
(
	[Exam_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Exam].[V_Exam_Details]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This view provides a comprehensive overview of exams, including their details such as exam type, year, start and end times, total time, associated course name, and maximum degree for the course.
CREATE VIEW [Exam].[V_Exam_Details]
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
/****** Object:  View [Exam].[V_Exam_Questions]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This view provides a detailed list of questions associated with each exam, including the question header, type, and the degree assigned to each question in the context of the exam.
CREATE VIEW [Exam].[V_Exam_Questions]
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
/****** Object:  View [Exam].[V_QuestionPool]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This view provides a pool of all questions along with their headers, types, and associated course names. It joins the Question table with the Course table to retrieve the course names.
CREATE VIEW [Exam].[V_QuestionPool] AS
SELECT 
    Q.Question_ID,
    Q.Ques_Header,
    Q.Question_Type,
    C.Crs_Name
FROM Exam.Question Q
JOIN Academic.Course C ON C.Course_Id = Q.Course_Id;
GO
/****** Object:  Table [Exam].[MCQ]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Exam].[MCQ](
	[MCQ_ID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MCQ_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Exam].[MCQ_Choices]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Exam].[MCQ_Choices](
	[MCQ_ID] [int] NOT NULL,
	[Choice_ID] [int] NOT NULL,
	[Choice_Text] [varchar](100) NULL,
	[IsCorrect] [bit] NULL,
 CONSTRAINT [PK_Choice] PRIMARY KEY CLUSTERED 
(
	[MCQ_ID] ASC,
	[Choice_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Exam].[V_MCQQuestions]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This view lists all MCQ questions along with their headers, choices, and whether each choice is correct. It joins the Question table with the MCQ and MCQ_Choices tables to retrieve the relevant information.
CREATE VIEW [Exam].[V_MCQQuestions] AS
SELECT 
    Q.Question_ID,
    Q.Ques_Header,
    C.Choice_Text,
    C.IsCorrect
FROM Exam.Question Q
JOIN Exam.MCQ M ON Q.Question_ID = M.MCQ_ID
JOIN Exam.MCQ_Choices C ON M.MCQ_ID = C.MCQ_ID;
GO
/****** Object:  View [Exam].[V_MCQCorrectChoice]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This view lists all MCQ questions along with their headers and the text of the correct choice. It filters the choices to include only those that are marked as correct.
CREATE VIEW [Exam].[V_MCQCorrectChoice] AS
SELECT 
    Q.Question_ID,
    Q.Ques_Header,
    C.Choice_Text 
FROM Exam.Question Q
JOIN Exam.MCQ M ON Q.Question_ID = M.MCQ_ID
JOIN Exam.MCQ_Choices C ON M.MCQ_ID = C.MCQ_ID
WHERE C.IsCorrect = 1;
GO
/****** Object:  Table [Exam].[TF_Question]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Exam].[TF_Question](
	[TF_Question_ID] [int] NOT NULL,
	[Correct_Answer] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[TF_Question_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Exam].[V_TFQuestions]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This view lists all True/False questions along with their headers and the correct answer. It joins the Question table with the TF_Question table to retrieve the relevant information.
CREATE VIEW [Exam].[V_TFQuestions] AS
SELECT 
    Q.Question_ID,
    Q.Ques_Header,
    TF.Correct_Answer
FROM Exam.Question Q
JOIN Exam.TF_Question TF ON Q.Question_ID = TF.TF_Question_ID;
GO
/****** Object:  Table [Exam].[Text_Question]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Exam].[Text_Question](
	[Text_Question_ID] [int] NOT NULL,
	[Model_Answer] [varchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[Text_Question_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Exam].[V_TextQuestions]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This view lists all Text questions along with their headers and the model answer. It joins the Question table with the Text_Question table to retrieve the relevant information.
CREATE VIEW [Exam].[V_TextQuestions] AS
SELECT 
    Q.Question_ID,
    Q.Ques_Header,
    T.Model_Answer
FROM Exam.Question Q
JOIN Exam.Text_Question T ON Q.Question_ID = T.Text_Question_ID;
GO
/****** Object:  Table [Student_Activity].[Student_Exam]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Student_Activity].[Student_Exam](
	[St_Id] [int] NOT NULL,
	[Exam_Id] [int] NOT NULL,
	[Start_Time] [datetime] NULL,
	[End_Time] [datetime] NULL,
	[Total_Score] [int] NULL,
 CONSTRAINT [PK_StudentExam] PRIMARY KEY CLUSTERED 
(
	[St_Id] ASC,
	[Exam_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Student_Activity].[Student_Results]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This view provides a summary of students' exam results, showing the student ID, exam ID, and total score for each exam taken by students.
--It selects data from the Student_Exam table.
CREATE VIEW [Student_Activity].[Student_Results]
AS
SELECT St_Id, Exam_Id, Total_Score
FROM Student_Activity.Student_Exam;
GO
/****** Object:  Table [Student_Activity].[Student_Answer]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Student_Activity].[Student_Answer](
	[St_Id] [int] NOT NULL,
	[Exam_Id] [int] NOT NULL,
	[Q_Id] [int] NOT NULL,
	[Answer] [varchar](100) NULL,
	[IsCorrect] [bit] NULL,
	[Score] [int] NULL,
 CONSTRAINT [PK_StudentAnswer] PRIMARY KEY CLUSTERED 
(
	[St_Id] ASC,
	[Exam_Id] ASC,
	[Q_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Student_Activity].[Student_Answers_Details]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This view provides detailed information about students' answers for each question in an exam, including whether the answer was correct and the score received for that answer.
--It selects data from the Student_Answer table.
CREATE VIEW [Student_Activity].[Student_Answers_Details]
AS
SELECT St_Id, Exam_Id, Q_Id, Answer, IsCorrect, Score
FROM Student_Activity.Student_Answer;
GO
/****** Object:  Table [Core].[Users]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Core].[Users](
	[User_Id] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [varchar](20) NOT NULL,
	[Password] [varchar](16) NOT NULL,
	[Role] [varchar](50) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Phone] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[User_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Phone] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Core].[Student]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Core].[Student](
	[Student_Id] [int] NOT NULL,
	[GPA] [decimal](3, 2) NULL,
	[Track_Id] [int] NULL,
	[Branch_Id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Student_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Student_Activity].[V_Student_Full_Report]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This view provides a comprehensive report of students' exam performance, including the student's name, course name, exam ID, and total score. It joins the Student_Exam table with the Student,
--Users, Exam, and Course tables to gather all relevant information.
CREATE VIEW [Student_Activity].[V_Student_Full_Report]
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
/****** Object:  View [Student_Activity].[V_Exam_Summary]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This view provides a summary of exam results, showing the total number of students who took each exam,
--the average score, and the maximum and minimum scores for each exam.
CREATE VIEW [Student_Activity].[V_Exam_Summary]
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
/****** Object:  View [Student_Activity].[V_Student_Answers_With_Questions]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Student_Activity].[V_Student_Answers_With_Questions]
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
/****** Object:  View [Exam].[vw_QuestionPool]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Exam].[vw_QuestionPool] AS
SELECT 
    Q.Question_ID,
    Q.Ques_Header,
    Q.Question_Type,
    C.Crs_Name
FROM Exam.Question Q
JOIN Academic.Course C ON C.Course_Id = Q.Course_Id;
GO
/****** Object:  View [Exam].[vw_MCQQuestions]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Exam].[vw_MCQQuestions] AS
SELECT 
    Q.Question_ID,
    Q.Ques_Header,
    C.Choice_Text,
    C.IsCorrect
FROM Exam.Question Q
JOIN Exam.MCQ M ON Q.Question_ID = M.MCQ_ID
JOIN Exam.MCQ_Choices C ON M.MCQ_ID = C.MCQ_ID;
GO
/****** Object:  View [Exam].[vw_MCQWithCorrectChoice]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Exam].[vw_MCQWithCorrectChoice] AS
SELECT 
    Q.Question_ID,
    Q.Ques_Header,
    C.Choice_Text 
FROM Exam.Question Q
JOIN Exam.MCQ M ON Q.Question_ID = M.MCQ_ID
JOIN Exam.MCQ_Choices C ON M.MCQ_ID = C.MCQ_ID
WHERE C.IsCorrect = 1;
GO
/****** Object:  View [Exam].[vw_TFQuestions]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Exam].[vw_TFQuestions] AS
SELECT 
    Q.Question_ID,
    Q.Ques_Header,
    TF.Correct_Answer
FROM Exam.Question Q
JOIN Exam.TF_Question TF ON Q.Question_ID = TF.TF_Question_ID;
GO
/****** Object:  View [Exam].[vw_TextQuestions]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Exam].[vw_TextQuestions] AS
SELECT 
    Q.Question_ID,
    Q.Ques_Header,
    T.Model_Answer
FROM Exam.Question Q
JOIN Exam.Text_Question T ON Q.Question_ID = T.Text_Question_ID;
GO
/****** Object:  View [Student_Activity].[vw_StudentAnswers]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Student_Activity].[vw_StudentAnswers] AS
SELECT 
    SA.St_Id,
    SA.Exam_Id,
    SA.Q_Id,
    SA.Answer,
    SA.IsCorrect,
    SA.Score
FROM Student_Activity.Student_Answer SA;
GO
/****** Object:  Table [Academic].[Branch]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Academic].[Branch](
	[Branch_Id] [int] IDENTITY(1,1) NOT NULL,
	[Branch_Name] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Branch_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Branch_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Academic].[Branch_Track]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Academic].[Branch_Track](
	[Branch_Id] [int] NOT NULL,
	[Track_Id] [int] NOT NULL,
 CONSTRAINT [PK_BranchTrack] PRIMARY KEY CLUSTERED 
(
	[Branch_Id] ASC,
	[Track_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Academic].[Department]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Academic].[Department](
	[Dept_Id] [int] IDENTITY(1,1) NOT NULL,
	[Dept_Name] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Dept_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Dept_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Academic].[Instructor_Course]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Academic].[Instructor_Course](
	[Crs_Id] [int] NOT NULL,
	[Ins_Id] [int] NOT NULL,
	[Year] [int] NOT NULL,
 CONSTRAINT [PK_InsCourse] PRIMARY KEY CLUSTERED 
(
	[Crs_Id] ASC,
	[Ins_Id] ASC,
	[Year] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Academic].[Intake]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Academic].[Intake](
	[Intake_Id] [int] IDENTITY(1,1) NOT NULL,
	[Intake_Name] [varchar](100) NOT NULL,
	[Year] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Intake_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Academic].[Track]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Academic].[Track](
	[Track_Id] [int] IDENTITY(1,1) NOT NULL,
	[Track_Name] [varchar](50) NOT NULL,
	[Dept_Id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Track_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Academic].[Track_Intake]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Academic].[Track_Intake](
	[Track_Id] [int] NOT NULL,
	[Intake_Id] [int] NOT NULL,
 CONSTRAINT [PK_TrackIntake] PRIMARY KEY CLUSTERED 
(
	[Track_Id] ASC,
	[Intake_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Core].[Instructor]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Core].[Instructor](
	[Instructor_Id] [int] NOT NULL,
	[Salary] [decimal](10, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[Instructor_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Exam].[Exam_Intake_Branch_Track]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Exam].[Exam_Intake_Branch_Track](
	[Exam_Id] [int] NOT NULL,
	[Intake_Id] [int] NOT NULL,
	[Branch_Id] [int] NOT NULL,
	[Track_Id] [int] NOT NULL,
 CONSTRAINT [PK_ExamIntakeBranch] PRIMARY KEY CLUSTERED 
(
	[Exam_Id] ASC,
	[Intake_Id] ASC,
	[Branch_Id] ASC,
	[Track_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Exam].[Instructor_Exam]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Exam].[Instructor_Exam](
	[Exam_Id] [int] NOT NULL,
	[Ins_Id] [int] NOT NULL,
	[Crs_Id] [int] NOT NULL,
 CONSTRAINT [PK_InstructorExam] PRIMARY KEY CLUSTERED 
(
	[Exam_Id] ASC,
	[Ins_Id] ASC,
	[Crs_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Student_Activity].[Student_Intake]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Student_Activity].[Student_Intake](
	[St_Id] [int] NOT NULL,
	[Intake_Id] [int] NOT NULL,
 CONSTRAINT [PK_StudentIntake] PRIMARY KEY CLUSTERED 
(
	[St_Id] ASC,
	[Intake_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [Index_ExamQuestion_Exam]    Script Date: 4/2/2026 2:23:56 PM ******/
CREATE NONCLUSTERED INDEX [Index_ExamQuestion_Exam] ON [Exam].[Exam_Question]
(
	[Exam_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [Index_ExamQuestion_Question]    Script Date: 4/2/2026 2:23:56 PM ******/
CREATE NONCLUSTERED INDEX [Index_ExamQuestion_Question] ON [Exam].[Exam_Question]
(
	[Q_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [Index_MCQ_Choices_Correct]    Script Date: 4/2/2026 2:23:56 PM ******/
CREATE NONCLUSTERED INDEX [Index_MCQ_Choices_Correct] ON [Exam].[MCQ_Choices]
(
	[MCQ_ID] ASC,
	[IsCorrect] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [Index_MCQ_Choices_MCQ]    Script Date: 4/2/2026 2:23:56 PM ******/
CREATE NONCLUSTERED INDEX [Index_MCQ_Choices_MCQ] ON [Exam].[MCQ_Choices]
(
	[MCQ_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [Index_Question_Course]    Script Date: 4/2/2026 2:23:56 PM ******/
CREATE NONCLUSTERED INDEX [Index_Question_Course] ON [Exam].[Question]
(
	[Course_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [Index_StudentAnswer_Question]    Script Date: 4/2/2026 2:23:56 PM ******/
CREATE NONCLUSTERED INDEX [Index_StudentAnswer_Question] ON [Student_Activity].[Student_Answer]
(
	[Q_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [Index_StudentAnswer_StudentExam]    Script Date: 4/2/2026 2:23:56 PM ******/
CREATE NONCLUSTERED INDEX [Index_StudentAnswer_StudentExam] ON [Student_Activity].[Student_Answer]
(
	[St_Id] ASC,
	[Exam_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [Index_StudentExam_Exam]    Script Date: 4/2/2026 2:23:56 PM ******/
CREATE NONCLUSTERED INDEX [Index_StudentExam_Exam] ON [Student_Activity].[Student_Exam]
(
	[Exam_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [Index_StudentExam_Student]    Script Date: 4/2/2026 2:23:56 PM ******/
CREATE NONCLUSTERED INDEX [Index_StudentExam_Student] ON [Student_Activity].[Student_Exam]
(
	[St_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Academic].[Branch_Track]  WITH CHECK ADD  CONSTRAINT [FK_BranchTrack_Branch] FOREIGN KEY([Branch_Id])
REFERENCES [Academic].[Branch] ([Branch_Id])
ON DELETE CASCADE
GO
ALTER TABLE [Academic].[Branch_Track] CHECK CONSTRAINT [FK_BranchTrack_Branch]
GO
ALTER TABLE [Academic].[Branch_Track]  WITH CHECK ADD  CONSTRAINT [FK_BranchTrack_Track] FOREIGN KEY([Track_Id])
REFERENCES [Academic].[Track] ([Track_Id])
ON DELETE CASCADE
GO
ALTER TABLE [Academic].[Branch_Track] CHECK CONSTRAINT [FK_BranchTrack_Track]
GO
ALTER TABLE [Academic].[Instructor_Course]  WITH CHECK ADD FOREIGN KEY([Crs_Id])
REFERENCES [Academic].[Course] ([Course_Id])
GO
ALTER TABLE [Academic].[Instructor_Course]  WITH CHECK ADD FOREIGN KEY([Ins_Id])
REFERENCES [Core].[Instructor] ([Instructor_Id])
GO
ALTER TABLE [Academic].[Track]  WITH CHECK ADD  CONSTRAINT [FK_Track_Department] FOREIGN KEY([Dept_Id])
REFERENCES [Academic].[Department] ([Dept_Id])
ON DELETE CASCADE
GO
ALTER TABLE [Academic].[Track] CHECK CONSTRAINT [FK_Track_Department]
GO
ALTER TABLE [Academic].[Track_Intake]  WITH CHECK ADD FOREIGN KEY([Intake_Id])
REFERENCES [Academic].[Intake] ([Intake_Id])
ON DELETE CASCADE
GO
ALTER TABLE [Academic].[Track_Intake]  WITH CHECK ADD FOREIGN KEY([Track_Id])
REFERENCES [Academic].[Track] ([Track_Id])
ON DELETE CASCADE
GO
ALTER TABLE [Core].[Instructor]  WITH CHECK ADD FOREIGN KEY([Instructor_Id])
REFERENCES [Core].[Users] ([User_Id])
ON DELETE CASCADE
GO
ALTER TABLE [Core].[Student]  WITH CHECK ADD FOREIGN KEY([Branch_Id])
REFERENCES [Academic].[Branch] ([Branch_Id])
ON DELETE SET NULL
GO
ALTER TABLE [Core].[Student]  WITH CHECK ADD FOREIGN KEY([Student_Id])
REFERENCES [Core].[Users] ([User_Id])
ON DELETE CASCADE
GO
ALTER TABLE [Core].[Student]  WITH CHECK ADD FOREIGN KEY([Track_Id])
REFERENCES [Academic].[Track] ([Track_Id])
ON DELETE SET NULL
GO
ALTER TABLE [Exam].[Exam]  WITH CHECK ADD FOREIGN KEY([Crs_Id])
REFERENCES [Academic].[Course] ([Course_Id])
GO
ALTER TABLE [Exam].[Exam_Intake_Branch_Track]  WITH CHECK ADD FOREIGN KEY([Branch_Id])
REFERENCES [Academic].[Branch] ([Branch_Id])
GO
ALTER TABLE [Exam].[Exam_Intake_Branch_Track]  WITH CHECK ADD FOREIGN KEY([Exam_Id])
REFERENCES [Exam].[Exam] ([Exam_Id])
GO
ALTER TABLE [Exam].[Exam_Intake_Branch_Track]  WITH CHECK ADD FOREIGN KEY([Intake_Id])
REFERENCES [Academic].[Intake] ([Intake_Id])
GO
ALTER TABLE [Exam].[Exam_Intake_Branch_Track]  WITH CHECK ADD FOREIGN KEY([Track_Id])
REFERENCES [Academic].[Track] ([Track_Id])
GO
ALTER TABLE [Exam].[Exam_Question]  WITH CHECK ADD FOREIGN KEY([Exam_Id])
REFERENCES [Exam].[Exam] ([Exam_Id])
GO
ALTER TABLE [Exam].[Exam_Question]  WITH CHECK ADD FOREIGN KEY([Q_Id])
REFERENCES [Exam].[Question] ([Question_ID])
GO
ALTER TABLE [Exam].[Instructor_Exam]  WITH CHECK ADD FOREIGN KEY([Crs_Id])
REFERENCES [Academic].[Course] ([Course_Id])
GO
ALTER TABLE [Exam].[Instructor_Exam]  WITH CHECK ADD FOREIGN KEY([Exam_Id])
REFERENCES [Exam].[Exam] ([Exam_Id])
GO
ALTER TABLE [Exam].[Instructor_Exam]  WITH CHECK ADD FOREIGN KEY([Ins_Id])
REFERENCES [Core].[Instructor] ([Instructor_Id])
GO
ALTER TABLE [Exam].[MCQ]  WITH CHECK ADD FOREIGN KEY([MCQ_ID])
REFERENCES [Exam].[Question] ([Question_ID])
ON DELETE CASCADE
GO
ALTER TABLE [Exam].[MCQ_Choices]  WITH CHECK ADD FOREIGN KEY([MCQ_ID])
REFERENCES [Exam].[MCQ] ([MCQ_ID])
ON DELETE CASCADE
GO
ALTER TABLE [Exam].[Question]  WITH CHECK ADD FOREIGN KEY([Course_Id])
REFERENCES [Academic].[Course] ([Course_Id])
GO
ALTER TABLE [Exam].[Text_Question]  WITH CHECK ADD FOREIGN KEY([Text_Question_ID])
REFERENCES [Exam].[Question] ([Question_ID])
ON DELETE CASCADE
GO
ALTER TABLE [Exam].[TF_Question]  WITH CHECK ADD FOREIGN KEY([TF_Question_ID])
REFERENCES [Exam].[Question] ([Question_ID])
ON DELETE CASCADE
GO
ALTER TABLE [Student_Activity].[Student_Answer]  WITH CHECK ADD FOREIGN KEY([Exam_Id])
REFERENCES [Exam].[Exam] ([Exam_Id])
GO
ALTER TABLE [Student_Activity].[Student_Answer]  WITH CHECK ADD FOREIGN KEY([St_Id])
REFERENCES [Core].[Student] ([Student_Id])
GO
ALTER TABLE [Student_Activity].[Student_Answer]  WITH CHECK ADD FOREIGN KEY([Q_Id])
REFERENCES [Exam].[Question] ([Question_ID])
GO
ALTER TABLE [Student_Activity].[Student_Exam]  WITH CHECK ADD FOREIGN KEY([Exam_Id])
REFERENCES [Exam].[Exam] ([Exam_Id])
GO
ALTER TABLE [Student_Activity].[Student_Exam]  WITH CHECK ADD FOREIGN KEY([St_Id])
REFERENCES [Core].[Student] ([Student_Id])
GO
ALTER TABLE [Student_Activity].[Student_Intake]  WITH CHECK ADD FOREIGN KEY([Intake_Id])
REFERENCES [Academic].[Intake] ([Intake_Id])
GO
ALTER TABLE [Student_Activity].[Student_Intake]  WITH CHECK ADD FOREIGN KEY([St_Id])
REFERENCES [Core].[Student] ([Student_Id])
GO
ALTER TABLE [Academic].[Intake]  WITH CHECK ADD  CONSTRAINT [CHK_Intake_Dates] CHECK  (([EndDate]>[StartDate]))
GO
ALTER TABLE [Academic].[Intake] CHECK CONSTRAINT [CHK_Intake_Dates]
GO
ALTER TABLE [Core].[Student]  WITH CHECK ADD  CONSTRAINT [CHK_GPA] CHECK  (([GPA]>=(0) AND [GPA]<=(4)))
GO
ALTER TABLE [Core].[Student] CHECK CONSTRAINT [CHK_GPA]
GO
ALTER TABLE [Core].[Users]  WITH CHECK ADD  CONSTRAINT [CHK_Users_Role] CHECK  (([Role]='Training Manager' OR [Role]='Admin' OR [Role]='Instructor' OR [Role]='Student'))
GO
ALTER TABLE [Core].[Users] CHECK CONSTRAINT [CHK_Users_Role]
GO
ALTER TABLE [Exam].[Exam]  WITH CHECK ADD  CONSTRAINT [CHK_Exam_Time] CHECK  (([EndTime]>[StartTime]))
GO
ALTER TABLE [Exam].[Exam] CHECK CONSTRAINT [CHK_Exam_Time]
GO
ALTER TABLE [Exam].[Exam]  WITH CHECK ADD  CONSTRAINT [CHK_ExamType] CHECK  (([ExamType]='Exam' OR [ExamType]='Corrective'))
GO
ALTER TABLE [Exam].[Exam] CHECK CONSTRAINT [CHK_ExamType]
GO
ALTER TABLE [Exam].[Question]  WITH CHECK ADD  CONSTRAINT [CHK_Question_Type] CHECK  (([Question_Type]='Text' OR [Question_Type]='MCQ' OR [Question_Type]='TF'))
GO
ALTER TABLE [Exam].[Question] CHECK CONSTRAINT [CHK_Question_Type]
GO
/****** Object:  StoredProcedure [Exam].[Add_Question_To_Exam]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This procedure adds a question to an exam with a specified degree. It performs several checks to ensure that the exam and question exist, that the question is not already added to the exam, and that the total degree does not exceed the maximum allowed for the course before inserting the new record into the Exam_Question table.
CREATE PROCEDURE [Exam].[Add_Question_To_Exam]
    @Exam_Id INT,
    @Q_Id INT,
    @Degree INT
AS
BEGIN
-- Check if the exam exists
    IF NOT EXISTS (SELECT 1 FROM Exam.Exam WHERE Exam_Id = @Exam_Id)
    BEGIN
        RAISERROR('Exam not found',16,1);
        RETURN;
    END
    -- Check if the question exists
    IF NOT EXISTS (SELECT 1 FROM Exam.Question WHERE Question_ID = @Q_Id)
    BEGIN
        RAISERROR('Question not found',16,1);
        RETURN;
    END
    -- Check if the question is already added to the exam
    IF EXISTS (SELECT 1 FROM Exam.Exam_Question WHERE Exam_Id = @Exam_Id AND Q_Id = @Q_Id)
    BEGIN
        RAISERROR('Question already added',16,1);
        RETURN;
    END
    -- Validate that the degree is positive
    IF @Degree <= 0
    BEGIN
        RAISERROR('Invalid Degree',16,1);
        RETURN;
    END

    DECLARE @CurrentTotal INT;
    DECLARE @MaxDegree INT;

    SELECT @CurrentTotal = ISNULL(SUM(Degree), 0)
    FROM Exam.Exam_Question WHERE Exam_Id = @Exam_Id;

    SELECT @MaxDegree = C.MaxDegree
    FROM Academic.Course C
    JOIN Exam.Exam E ON C.Course_Id = E.Crs_Id
    WHERE E.Exam_Id = @Exam_Id;
    -- Check if adding the new question's degree exceeds the course's maximum degree
    IF (@CurrentTotal + @Degree > @MaxDegree)
    BEGIN
        RAISERROR('Exceeds course max degree',16,1);
        RETURN;
    END

    INSERT INTO Exam.Exam_Question (Exam_Id, Q_Id, Degree)
    VALUES (@Exam_Id, @Q_Id, @Degree);
END
GO
/****** Object:  StoredProcedure [Exam].[AddChoice]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This procedure adds a choice to an existing MCQ question. It checks if the MCQ question exists before inserting the choice.
CREATE PROCEDURE [Exam].[AddChoice]
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
/****** Object:  StoredProcedure [Exam].[AddMCQQuestion]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This procedure adds a new MCQ question to the MCQ table. It checks if the question exists in the Question table and is of type 'MCQ' before insertion.
CREATE PROCEDURE [Exam].[AddMCQQuestion]
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
/****** Object:  StoredProcedure [Exam].[AddQuestion]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This procedure adds a new question to the Question table. It checks for duplicate question IDs and validates the course ID before insertion.
CREATE PROCEDURE [Exam].[AddQuestion] 
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
/****** Object:  StoredProcedure [Exam].[AddTextQuestion]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This procedure adds a new Text question to the Text_Question table. It checks if the question exists in the Question table and is of type 'Text' before insertion.
CREATE PROCEDURE [Exam].[AddTextQuestion]
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
/****** Object:  StoredProcedure [Exam].[AddTFQuestion]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This procedure adds a new True/False question to the TF_Question table. It checks if the question exists in the Question table and is of type 'TF' before insertion.
CREATE PROCEDURE [Exam].[AddTFQuestion]
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
/****** Object:  StoredProcedure [Exam].[Assign_Exam]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This procedure assigns an exam to a specific intake, branch, and track. It checks if the exam exists and if the assignment already exists to prevent duplicates before inserting the new assignment into the Exam_Intake_Branch_Track table.
CREATE PROCEDURE [Exam].[Assign_Exam]
    @Exam_Id INT,
    @Intake_Id INT,
    @Branch_Id INT,
    @Track_Id INT
AS
BEGIN
-- Check if the exam exists
    IF NOT EXISTS (SELECT 1 FROM Exam.Exam WHERE Exam_Id = @Exam_Id)
    BEGIN
        RAISERROR('Exam not found',16,1);
        RETURN;
    END
    --  Check if the assignment already exists
    IF EXISTS (
        SELECT 1 FROM Exam.Exam_Intake_Branch_Track
        WHERE Exam_Id = @Exam_Id 
        AND Intake_Id = @Intake_Id 
        AND Branch_Id = @Branch_Id 
        AND Track_Id = @Track_Id
    )
    BEGIN
        RAISERROR('Already assigned',16,1);
        RETURN;
    END

    INSERT INTO Exam.Exam_Intake_Branch_Track
    (Exam_Id, Intake_Id, Branch_Id, Track_Id)
    VALUES (@Exam_Id, @Intake_Id, @Branch_Id, @Track_Id);
END
GO
/****** Object:  StoredProcedure [Exam].[Create_Exam]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This procedure creates a new exam with the provided details. It checks for duplicate exam IDs, validates the course ID, and ensures that the end time is after the start time before inserting the exam into the database.
CREATE PROCEDURE [Exam].[Create_Exam]
    @Exam_Id INT,
    @Crs_Id INT,
    @Year INT,
    @ExamType VARCHAR(50),
    @StartTime DATETIME,
    @EndTime DATETIME
AS
BEGIN
-- Check if the exam already exists
    IF EXISTS (SELECT 1 FROM Exam.Exam WHERE Exam_Id = @Exam_Id)
    BEGIN
        RAISERROR('Exam already exists',16,1);
        RETURN;
    END
    -- Check if the course exists
    IF NOT EXISTS (SELECT 1 FROM Academic.Course WHERE Course_Id = @Crs_Id)
    BEGIN
        RAISERROR('Course does not exist',16,1);
        RETURN;
    END
    --  Validate that the end time is after the start time
    IF (@EndTime <= @StartTime)
    BEGIN
        RAISERROR('Invalid Time',16,1);
        RETURN;
    END
    
    INSERT INTO Exam.Exam (Exam_Id, Crs_Id, Year, ExamType, StartTime, EndTime)
    VALUES (@Exam_Id, @Crs_Id, @Year, @ExamType, @StartTime, @EndTime);
END
GO
/****** Object:  StoredProcedure [Exam].[Delete_Exam]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This procedure deletes an exam from the database based on the provided exam ID. It checks if the exam exists before deleting it and also removes any associated questions from the Exam_Question table to maintain referential integrity.
CREATE PROCEDURE [Exam].[Delete_Exam]
    @Exam_Id INT
AS
BEGIN
-- Check if the exam exists
    IF NOT EXISTS (SELECT 1 FROM Exam.Exam WHERE Exam_Id = @Exam_Id)
    BEGIN
        RAISERROR('Exam not found',16,1);
        RETURN;
    END

    DELETE FROM Exam.Exam_Question WHERE Exam_Id = @Exam_Id;
    DELETE FROM Exam.Exam WHERE Exam_Id = @Exam_Id;
END
GO
/****** Object:  StoredProcedure [Exam].[DeleteQuestion]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--  This procedure deletes a question from the Question table. It checks if the question exists before attempting to delete it.
CREATE PROCEDURE [Exam].[DeleteQuestion]
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
/****** Object:  StoredProcedure [Exam].[Get_Exam]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This procedure retrieves the details of an exam based on the provided exam ID. It checks if the exam exists before returning the exam information.
CREATE PROCEDURE [Exam].[Get_Exam]
    @Exam_Id INT
AS
BEGIN
-- Check if the exam exists
    IF NOT EXISTS (SELECT 1 FROM Exam.Exam WHERE Exam_Id = @Exam_Id)
    BEGIN
        RAISERROR('Exam not found',16,1);
        RETURN;
    END

    SELECT * FROM Exam.Exam WHERE Exam_Id = @Exam_Id;
END
GO
/****** Object:  StoredProcedure [Exam].[Remove_Question_From_Exam]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This procedure removes a question from an exam. It checks if the question is currently associated with the exam before deleting the record from the Exam_Question table to ensure that only existing associations are removed.
CREATE PROCEDURE [Exam].[Remove_Question_From_Exam]
    @Exam_Id INT,
    @Q_Id INT
AS
BEGIN
-- Check if the question is associated with the exam
    IF NOT EXISTS (
        SELECT 1 FROM Exam.Exam_Question 
        WHERE Exam_Id = @Exam_Id AND Q_Id = @Q_Id
    )
    BEGIN
        RAISERROR('Question not found in exam',16,1);
        RETURN;
    END

    DELETE FROM Exam.Exam_Question
    WHERE Exam_Id = @Exam_Id AND Q_Id = @Q_Id;
END
GO
/****** Object:  StoredProcedure [Exam].[Search_Exam_ByDate]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This procedure retrieves exams scheduled on a specific date, 
--including their details and associated course names.
CREATE PROCEDURE [Exam].[Search_Exam_ByDate]
    @Date DATE
AS
BEGIN
    SELECT 
        E.Exam_Id,
        E.ExamType,
        E.StartTime,
        E.EndTime,
        C.Crs_Name
    FROM Exam.Exam E
    JOIN Academic.Course C ON E.Crs_Id = C.Course_Id
    WHERE CAST(E.StartTime AS DATE) = @Date;
END
GO
/****** Object:  StoredProcedure [Exam].[Search_Question]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This procedure allows searching for questions based on a text fragment in the question header.
CREATE PROCEDURE [Exam].[Search_Question]
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
/****** Object:  StoredProcedure [Exam].[Update_Exam]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This procedure updates the details of an existing exam. It checks if the exam exists and validates the new start and end times before applying the updates to the database.
CREATE PROCEDURE [Exam].[Update_Exam]
    @Exam_Id INT,
    @ExamType VARCHAR(50),
    @StartTime DATETIME,
    @EndTime DATETIME
AS
BEGIN
-- Check if the exam exists
    IF NOT EXISTS (SELECT 1 FROM Exam.Exam WHERE Exam_Id = @Exam_Id)
    BEGIN
        RAISERROR('Exam not found',16,1);
        RETURN;
    END
    -- Validate that the end time is after the start time
    IF (@EndTime <= @StartTime)
    BEGIN
        RAISERROR('Invalid Time',16,1);
        RETURN;
    END
    -- Update the exam details
    UPDATE Exam.Exam
    SET ExamType = @ExamType,
        StartTime = @StartTime,
        EndTime = @EndTime
    WHERE Exam_Id = @Exam_Id;
END
GO
/****** Object:  StoredProcedure [Exam].[UpdateQuestion]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This procedure updates the header of an existing question. It checks if the question exists before attempting to update it.
CREATE PROCEDURE [Exam].[UpdateQuestion]
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
/****** Object:  StoredProcedure [Student_Activity].[Finish_Exam]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This procedure allows a student to finish an exam. It checks if the student has started the exam and then updates the Student_Exam record with the end time
--and calculates the total score using the Get_Student_TotalScore function.
CREATE PROCEDURE [Student_Activity].[Finish_Exam]
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
/****** Object:  StoredProcedure [Student_Activity].[Get_Student_Exam]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This procedure retrieves the questions and their corresponding degrees for a specific exam.
--It joins the Exam_Question table with the Question table to get the question details and filters by the provided exam ID.
CREATE PROCEDURE [Student_Activity].[Get_Student_Exam]
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
/****** Object:  StoredProcedure [Student_Activity].[Search_Student]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Student_Activity].[Search_Student]
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
/****** Object:  StoredProcedure [Student_Activity].[Start_Exam]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This procedure allows a student to start an exam. It checks if the exam is active and if the student has already started it. If the checks pass, it inserts a new record into the Student_Exam table with the start time and initializes the total score to 0.
CREATE PROCEDURE [Student_Activity].[Start_Exam]
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
/****** Object:  StoredProcedure [Student_Activity].[Submit_Answer]    Script Date: 4/2/2026 2:23:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This procedure allows a student to submit an answer for a specific question in an exam. It performs several checks
CREATE PROCEDURE [Student_Activity].[Submit_Answer]
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
USE [master]
GO
ALTER DATABASE [Examination_System] SET  READ_WRITE 
GO
