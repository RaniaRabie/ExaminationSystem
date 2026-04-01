DECLARE @BackupPath NVARCHAR(200);
DECLARE @Date NVARCHAR(50);

SET @Date = REPLACE(CONVERT(VARCHAR, GETDATE(), 120), ':', '-');

SET @BackupPath = 
'D:\Examination_System\ExamSYSBackup' + @Date + '.bak';

BACKUP DATABASE Examination_System
TO DISK = @BackupPath
WITH 
    INIT,
    NAME = 'Weekly Backup',
    STATS = 10;
GO
