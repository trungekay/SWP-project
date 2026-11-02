-- Staff may refer a checked-in patient directly to a surgical specialist.
-- Existing records, orders and foreign keys are preserved. Run manually.
SET XACT_ABORT ON;
BEGIN TRANSACTION;
ALTER TABLE dbo.Medical_Record ALTER COLUMN Doctor_Employee_ID INT NULL;
IF COL_LENGTH('dbo.Procedure_Order', 'Requested_By_Employee_ID') IS NULL
    ALTER TABLE dbo.Procedure_Order ADD Requested_By_Employee_ID INT NULL
        CONSTRAINT FK_Procedure_Order_Requester REFERENCES dbo.Employee_Profile(Employee_ID);
IF COL_LENGTH('dbo.Procedure_Order', 'Requested_At') IS NULL
    ALTER TABLE dbo.Procedure_Order ADD Requested_At DATETIME2 NULL;
COMMIT;
