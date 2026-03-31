use ExaminationSystem

-- Department
create table Department
(
    Dept_Id int identity primary key,
    Dept_Name varchar(50) unique not null
)

-- Branch
create table Branch
(
    Branch_Id int identity primary key,
    Branch_Name varchar(50) unique not null
)

-- Track
create table Track
(
    Track_Id int identity primary key,
    Track_Name varchar(50) not null,
    Dept_Id int NOT NULL,

    CONSTRAINT FK_Track_Department
    FOREIGN KEY (Dept_Id)
    REFERENCES Department(Dept_Id)
)

-- Branch_Track
CREATE TABLE Branch_Track
(
    Branch_Id INT NOT NULL,
    Track_Id INT NOT NULL,

    CONSTRAINT PK_BranchTrack
    PRIMARY KEY (Branch_Id,Track_Id),

    CONSTRAINT FK_BranchTrack_Branch
    FOREIGN KEY (Branch_Id)
    REFERENCES Branch(Branch_Id),

    CONSTRAINT FK_BranchTrack_Track
    FOREIGN KEY (Track_Id)
    REFERENCES Track(Track_Id)
)

-- Intake
CREATE TABLE Intake
(
    Intake_Id INT IDENTITY PRIMARY KEY,
    Intake_Name VARCHAR(100) NOT NULL,
    Year INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,

    CONSTRAINT CHK_Intake_Dates
    CHECK (EndDate > StartDate)
);


-- Track_Intake
CREATE TABLE Track_Intake
(
    Track_Id INT NOT NULL,
    Intake_Id INT NOT NULL,

    CONSTRAINT PK_TrackIntake
    PRIMARY KEY (Track_Id,Intake_Id),

    CONSTRAINT FK_TrackIntake_Track
    FOREIGN KEY (Track_Id)
    REFERENCES Track(Track_Id),

    CONSTRAINT FK_TrackIntake_Intake
    FOREIGN KEY (Intake_Id)
    REFERENCES Intake(Intake_Id)
);


-- Users
CREATE TABLE Users
(
    User_Id INT IDENTITY PRIMARY KEY,
    UserName VARCHAR(20) NOT NULL UNIQUE,
    Password VARCHAR(16) NOT NULL,
    Role VARCHAR(50) NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Phone VARCHAR(20) UNIQUE,

    CONSTRAINT CHK_Users_Role
    CHECK (Role IN ('Student','Instructor','Admin', 'Training Manager'))
);


-- Student
CREATE TABLE Student
(
    Student_Id INT PRIMARY KEY,
    GPA DECIMAL(3,2) NULL,
    Track_Id INT NOT NULL,
    Branch_Id INT NOT NULL,

    CONSTRAINT FK_Student_Users
    FOREIGN KEY (Student_Id)
    REFERENCES Users(User_Id),

    CONSTRAINT FK_Student_Track
    FOREIGN KEY (Track_Id)
    REFERENCES Track(Track_Id),

    CONSTRAINT FK_Student_Branch
    FOREIGN KEY (Branch_Id)
    REFERENCES Branch(Branch_Id),

    CONSTRAINT CHK_GPA
    CHECK (GPA BETWEEN 0 AND 4)
);


-- Instructor
CREATE TABLE Instructor(
    Instructor_Id INT PRIMARY KEY,
    Salary DECIMAL(10,2),
    
    FOREIGN KEY (Instructor_Id) REFERENCES Users(User_Id)
);


-- Course
CREATE TABLE Course(
    Course_Id INT PRIMARY KEY,
    Crs_Name VARCHAR(50),
    Description VARCHAR(255),
    MinDegree INT,
    MaxDegree INT
);


-- Instructor_Course
CREATE TABLE Instructor_Course(
    Crs_Id INT,
    Ins_Id INT,
    Year INT,

    CONSTRAINT PK_InsCourse PRIMARY KEY (Crs_Id,Ins_Id, Year),

    FOREIGN KEY (Crs_Id) REFERENCES Course(Course_Id),
    FOREIGN KEY (Ins_Id) REFERENCES Instructor(Instructor_Id)
);


-- Question
CREATE TABLE Question(
    Question_ID INT PRIMARY KEY ,
    Question_Type VARCHAR(50),
    Ques_Header VARCHAR(500),
    Course_Id INT,

    FOREIGN KEY (Course_Id) REFERENCES Course(Course_Id)
);


-- Text_Question
CREATE TABLE Text_Question(
    Text_Question_ID INT PRIMARY KEY,
    Model_Answer VARCHAR(500),

    FOREIGN KEY (Text_Question_ID) REFERENCES Question(Question_ID)
);


-- TF_Question
CREATE TABLE TF_Question(
    TF_Question_ID INT PRIMARY KEY,
    Correct_Answer BIT,

    FOREIGN KEY (TF_Question_ID) REFERENCES Question(Question_ID)
);


-- MCQ
CREATE TABLE MCQ(
    MCQ_ID INT PRIMARY KEY,

    FOREIGN KEY (MCQ_ID) REFERENCES Question(Question_ID)
);


-- MCQ_Choices
CREATE TABLE MCQ_Choices(
    MCQ_ID INT,
    Choice_ID INT,
    Choice_Text VARCHAR(100),
    IsCorrect BIT,

    CONSTRAINT PK_Choice PRIMARY KEY (MCQ_ID,Choice_ID),

    FOREIGN KEY(MCQ_ID) REFERENCES MCQ(MCQ_ID)
);


-- Exam
CREATE TABLE Exam(
    Exam_Id INT PRIMARY KEY,
    Crs_Id INT,
    Year INT,
    ExamType VARCHAR(50),
    StartTime DATETIME,
    EndTime DATETIME,
    TotalTime AS 
    DATEDIFF(MINUTE, StartTime, EndTime) PERSISTED,

    FOREIGN KEY (Crs_Id) REFERENCES Course(Course_Id),

    CONSTRAINT CHK_Exam_Time
    CHECK (EndTime > StartTime)
);


-- Exam_Question
CREATE TABLE Exam_Question(
    Exam_Id INT,
    Q_Id INT,
    Degree INT,

    CONSTRAINT PK_ExamQuestion PRIMARY KEY (Exam_Id,Q_Id),

    FOREIGN KEY (Exam_Id) REFERENCES Exam(Exam_Id),
    FOREIGN KEY (Q_Id) REFERENCES Question(Question_ID)


);


-- Instructor_Exam
CREATE TABLE Instructor_Exam(
    Exam_Id INT,
    Ins_Id INT,
    Crs_Id INT,

    CONSTRAINT PK_InstructorExam PRIMARY KEY (Exam_Id,Ins_Id,Crs_Id),

    FOREIGN KEY (Exam_Id) REFERENCES Exam(Exam_Id),
    FOREIGN KEY (Ins_Id) REFERENCES Instructor(Instructor_Id),
    FOREIGN KEY (Crs_Id) REFERENCES Course(Course_Id)
);


-- Exam_Intake_Branch_Track
CREATE TABLE Exam_Intake_Branch_Track(
    Exam_Id INT,
    Intake_Id INT,
    Branch_Id INT,
    Track_Id INT,

    CONSTRAINT PK_ExamIntakeBranch 
    PRIMARY KEY (Exam_Id,Intake_Id,Branch_Id,Track_Id),

    FOREIGN KEY (Exam_Id) REFERENCES Exam(Exam_Id),
    FOREIGN KEY (Intake_Id) REFERENCES Intake(Intake_Id),
    FOREIGN KEY (Branch_Id) REFERENCES Branch(Branch_Id),
    FOREIGN KEY (Track_Id) REFERENCES Track(Track_Id)
);


-- Student_Intake
CREATE TABLE Student_Intake(
    St_Id INT,
    Intake_Id INT,

    CONSTRAINT PK_StudentIntake PRIMARY KEY (St_Id,Intake_Id),

    FOREIGN KEY (St_Id) REFERENCES Student(Student_Id),
    FOREIGN KEY (Intake_Id) REFERENCES Intake(Intake_Id)
);


-- Student_Exam
CREATE TABLE Student_Exam(
    St_Id INT,
    Exam_Id INT,
    Start_Time DATETIME,
    End_Time DATETIME,
    Total_Score INT,

    CONSTRAINT PK_StudentExam PRIMARY KEY (St_Id,Exam_Id),

    FOREIGN KEY (St_Id) REFERENCES Student(Student_Id),
    FOREIGN KEY (Exam_Id) REFERENCES Exam(Exam_Id)
);


-- Student_Answer
CREATE TABLE Student_Answer(
    St_Id INT,
    Exam_Id INT,
    Q_Id INT,
    Answer VARCHAR(500),
    IsCorrect BIT,
    Score INT,

    CONSTRAINT PK_StudentAnswer 
    PRIMARY KEY (St_Id,Exam_Id,Q_Id),

    FOREIGN KEY (St_Id) REFERENCES Student(Student_Id),
    FOREIGN KEY (Exam_Id) REFERENCES Exam(Exam_Id),
    FOREIGN KEY (Q_Id) REFERENCES Question(Question_ID)
);