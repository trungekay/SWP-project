SET XACT_ABORT ON;
IF OBJECT_ID('dbo.Time_Slot_Config', 'U') IS NULL
BEGIN
CREATE TABLE dbo.Time_Slot_Config (
 Slot_ID INT IDENTITY PRIMARY KEY,
 Slot_Name NVARCHAR(100) NOT NULL UNIQUE,
 Start_Time TIME(0) NOT NULL UNIQUE,
 End_Time TIME(0) NOT NULL,
 Status VARCHAR(20) NOT NULL DEFAULT 'Available',
 CHECK (DATEDIFF(SECOND,Start_Time,End_Time)=1800),
 CHECK (Status IN ('Available','Canceled'))
);
SELECT * INTO dbo.Work_Schedule_Before_Slot_Config FROM dbo.Work_Schedule;
;WITH labels AS (
 SELECT Slot,Start_Time,End_Time,COUNT(*) Uses,
 ROW_NUMBER() OVER(PARTITION BY Start_Time,End_Time ORDER BY COUNT(*) DESC,Slot) Label_Rank
 FROM dbo.Work_Schedule GROUP BY Slot,Start_Time,End_Time
), ranges AS (
 SELECT l.Slot,l.Start_Time,l.End_Time,
 CASE WHEN EXISTS(SELECT 1 FROM dbo.Work_Schedule w
 WHERE w.Start_Time=l.Start_Time AND w.End_Time=l.End_Time AND w.Status<>'Canceled')
 THEN 'Available' ELSE 'Canceled' END Status
 FROM labels l WHERE Label_Rank=1
), names AS (
 SELECT *,COUNT(*) OVER(PARTITION BY Slot) Name_Count FROM ranges
)
INSERT dbo.Time_Slot_Config(Slot_Name,Start_Time,End_Time,Status)
SELECT CASE WHEN Name_Count>1 THEN CONCAT(Slot,' (',CONVERT(VARCHAR(5),Start_Time,108),')') ELSE Slot END,
 Start_Time,End_Time,Status FROM names;
UPDATE ws SET Slot=cfg.Slot_Name FROM dbo.Work_Schedule ws
JOIN dbo.Time_Slot_Config cfg ON cfg.Start_Time=ws.Start_Time AND cfg.End_Time=ws.End_Time;
END;

