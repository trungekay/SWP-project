-- Run once after eye_clinic_db.sql. Records each staff change to a doctor's work slot.
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
IF OBJECT_ID(N'dbo.Doctor_Schedule_Change', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Doctor_Schedule_Change (
        Change_ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Source_Schedule_ID INT NOT NULL REFERENCES dbo.Work_Schedule(Schedule_ID),
        Target_Schedule_ID INT NULL REFERENCES dbo.Work_Schedule(Schedule_ID),
        Appointment_ID INT NULL REFERENCES dbo.Appointment(Appointment_ID),
        Changed_By_Account_ID INT NOT NULL REFERENCES dbo.Account(Account_ID),
        Reason NVARCHAR(500) NOT NULL,
        Changed_At DATETIME2(0) NOT NULL DEFAULT DATEADD(HOUR, 7, SYSUTCDATETIME())
    );
    CREATE INDEX IX_Doctor_Schedule_Change_Source
        ON dbo.Doctor_Schedule_Change(Source_Schedule_ID, Changed_At DESC);
END;
GO
