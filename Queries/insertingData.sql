/* =========================
   4. INSERT DATA (FULL)
========================= */

-- Academic
INSERT INTO Academic.Department VALUES
('Software Engineering'),('Information Technology'),('Artificial Intelligence'),
('Cyber Security'),('Data Science'),('Cloud Computing'),
('Network Engineering'),('Embedded Systems');

INSERT INTO Academic.Branch VALUES
('Cairo'),('Alexandria'),('Assiut'),('Mansoura'),
('Ismailia'),('Smart Village'),('New Capital'),('Tanta');

INSERT INTO Academic.Track VALUES
('Java Backend',1),('.NET Full Stack',1),('Frontend Development',1),
('Machine Learning',3),('Deep Learning',3),
('Penetration Testing',4),('Security Operations',4),
('Data Analysis',5),('Cloud DevOps',6),('Network Administration',7);

INSERT INTO Academic.Branch_Track VALUES
(1,1),(1,2),(1,3),(2,1),(2,4),
(3,5),(4,6),(5,7),(6,8),(7,9),(8,10);

INSERT INTO Academic.Intake VALUES
('Intake 43',2023,'2023-01-10','2023-06-10'),
('Intake 44',2023,'2023-07-01','2023-12-01'),
('Intake 45',2024,'2024-01-10','2024-06-10'),
('Intake 46',2024,'2024-07-01','2024-12-01');

INSERT INTO Academic.Track_Intake VALUES
(1,1),(2,1),(3,1),(4,2),(5,2),
(6,2),(7,3),(8,3),(9,4),(10,4);

-- Core
INSERT INTO Core.Users VALUES
('ahmed.ali','123','Student','Ahmed Ali','01011111111'),
('mohamed.hassan','123','Student','Mohamed Hassan','01022222222'),
('sara.adel','123','Student','Sara Adel','01033333333'),
('youssef.wael','123','Student','Youssef Wael','01044444444'),
('mariam.hany','123','Student','Mariam Hany','01055555555'),
('dr.khaled','123','Instructor','Dr Khaled Mahmoud','01066666666'),
('dr.mona','123','Instructor','Dr Mona Ibrahim','01077777777'),
('dr.ahmed','123','Instructor','Dr Ahmed Samy','01088888888'),
('admin','123','Admin','System Admin','01099999999'),
('training.manager','123','Training Manager','Training Manager','01111111111');

INSERT INTO Core.Student VALUES
(1,3.4,1,1),(2,3.1,2,1),(3,3.7,1,2),(4,2.9,3,1),(5,3.5,4,1);

INSERT INTO Core.Instructor VALUES
(6,15000),(7,17000),(8,18000);

-- Academic Courses
INSERT INTO Academic.Course VALUES
(1,'Java Programming','Core Java concepts',60,100),
(2,'Spring Boot','Building REST APIs',60,100),
(3,'C# Programming','OOP using C#',60,100),
(4,'ASP.NET Core','Web API Development',60,100),
(5,'HTML & CSS','Frontend fundamentals',40,100),
(6,'Machine Learning','ML algorithms',60,100),
(7,'Cyber Security Basics','Security principles',40,100),
(8,'Data Analysis','Python analysis',60,100);

INSERT INTO Academic.Instructor_Course VALUES
(1,6,2024),(2,6,2024),(3,7,2024),(4,7,2024),
(5,8,2024),(6,8,2024),(2,6,2025);

-- Exam
INSERT INTO Exam.Question VALUES
(1,'MCQ','What does JVM stand for?',1),
(2,'TF','Java is platform independent',1),
(3,'Text','Explain OOP principles',1),
(4,'MCQ','What is CLR in .NET?',3),
(5,'TF','C# supports inheritance',3),
(6,'Text','Explain REST API',2);

INSERT INTO Exam.Text_Question VALUES
(3,'Encapsulation, Inheritance, Polymorphism, Abstraction'),
(6,'Representational State Transfer architecture');

INSERT INTO Exam.TF_Question VALUES
(2,1),(5,1);

INSERT INTO Exam.MCQ VALUES (1),(4);

INSERT INTO Exam.MCQ_Choices VALUES
(1,1,'Java Virtual Machine',1),
(1,2,'Java Variable Method',0),
(1,3,'Joint Virtual Machine',0),
(1,4,'Java Verified Mode',0),
(4,1,'Common Language Runtime',1),
(4,2,'Code Logic Runtime',0),
(4,3,'Computer Language Resource',0),
(4,4,'Control Language Runtime',0);

INSERT INTO Exam.Exam VALUES
(1,1,2024,'Exam','2024-05-10 10:00','2024-05-10 12:00'),
(2,3,2024,'Exam','2024-05-12 10:00','2024-05-12 12:00'),
(3,2,2024,'Corrective','2024-04-20 09:00','2024-04-20 10:00');

INSERT INTO Exam.Exam_Question VALUES
(1,1,30),(1,2,30),(1,3,40),
(2,4,50),(2,5,50),(3,6,50),(3,1,50);

INSERT INTO Exam.Instructor_Exam VALUES
(1,6,1),(2,6,2),(3,7,3),
(1,7,2),(2,8,1),(3,8,3);

INSERT INTO Exam.Exam_Intake_Branch_Track VALUES
(1,3,1,1),(2,3,1,2),(3,3,2,4),
(1,4,1,1),(2,4,1,2),(3,4,2,4);

-- Student Activity
INSERT INTO Student_Activity.Student_Exam VALUES
(1,1,'2024-05-10 10:00','2024-05-10 11:30',85),
(2,1,'2024-05-10 10:05','2024-05-10 11:40',78),
(3,2,'2024-05-12 10:00','2024-05-12 11:50',90),
(4,3,'2024-04-20 09:00','2024-04-20 09:50',70);

INSERT INTO Student_Activity.Student_Intake VALUES
(1,3),(2,3),(3,3),(4,3),(5,3);

INSERT INTO Student_Activity.Student_Answer VALUES
(1,1,1,'Java Virtual Machine',1,30),
(1,1,2,'True',1,30),
(1,1,3,'OOP concepts explanation',1,25),
(2,1,1,'Java Virtual Machine',1,30),
(2,1,2,'True',1,30),
(2,1,3,'OOP explanation',1,20);