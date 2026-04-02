/* =========================================
   1. CREATE LOGINS
========================================= */

CREATE LOGIN Admin_Login WITH PASSWORD = 'Admin@123';
CREATE LOGIN TM_Login WITH PASSWORD = 'TM@123';
CREATE LOGIN Instructor_Login WITH PASSWORD = 'Ins@123';
CREATE LOGIN Student_Login WITH PASSWORD = 'St@123';


/* =========================================
   2. CREATE USERS (INSIDE DATABASE)
========================================= */

CREATE USER Admin_User FOR LOGIN Admin_Login;
CREATE USER TM_User FOR LOGIN TM_Login;
CREATE USER Instructor_User FOR LOGIN Instructor_Login;
CREATE USER Student_User FOR LOGIN Student_Login;


/* =========================================
   3. CREATE ROLES
========================================= */

CREATE ROLE Admin_Role;
CREATE ROLE TrainingManager_Role;
CREATE ROLE Instructor_Role;
CREATE ROLE Student_Role;


/* =========================================
   4. ASSIGN USERS TO ROLES
========================================= */

ALTER ROLE Admin_Role ADD MEMBER Admin_User;
ALTER ROLE TrainingManager_Role ADD MEMBER TM_User;
ALTER ROLE Instructor_Role ADD MEMBER Instructor_User;
ALTER ROLE Student_Role ADD MEMBER Student_User;


/* =========================================
   5. PERMISSIONS
========================================= */

-- Admin → Full Control
ALTER ROLE db_owner ADD MEMBER Admin_User;


--  Training Manager
GRANT SELECT, INSERT, UPDATE ON SCHEMA::Academic TO TrainingManager_Role;

GRANT SELECT, INSERT, UPDATE ON Core.Users TO TrainingManager_Role;
GRANT SELECT, INSERT, UPDATE ON Core.Student TO TrainingManager_Role;


-- Instructor
GRANT SELECT ON SCHEMA::Academic TO Instructor_Role;

GRANT SELECT, INSERT, UPDATE ON SCHEMA::Exam TO Instructor_Role;

GRANT SELECT ON Core.Student TO Instructor_Role;

GRANT SELECT, INSERT, UPDATE ON Student_Activity.Student_Answer TO Instructor_Role;
GRANT SELECT, INSERT, UPDATE ON Student_Activity.Student_Exam TO Instructor_Role;


-- Student
GRANT SELECT ON SCHEMA::Academic TO Student_Role;
GRANT SELECT ON SCHEMA::Exam TO Student_Role;

GRANT SELECT ON Core.Student TO Student_Role;

GRANT INSERT ON Student_Activity.Student_Answer TO Student_Role;

GRANT SELECT ON Student_Activity.Student_Exam TO Student_Role;


/* =========================================
   6. EXTRA SECURITY (DENY)
========================================= */

DENY DELETE ON SCHEMA::Academic TO Instructor_Role;
DENY DELETE ON SCHEMA::Exam TO Student_Role;

DENY UPDATE ON SCHEMA::Academic TO Student_Role;
DENY UPDATE ON SCHEMA::Exam TO Student_Role;
