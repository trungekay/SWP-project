USE eye_clinic_db;
SET XACT_ABORT ON;

BEGIN TRANSACTION;

IF COL_LENGTH('dbo.Procedure_Order', 'Requested_By_Employee_ID') IS NULL
    ALTER TABLE dbo.Procedure_Order
    ADD Requested_By_Employee_ID INT NULL;

IF COL_LENGTH('dbo.Procedure_Order', 'Requested_At') IS NULL
    ALTER TABLE dbo.Procedure_Order
    ADD Requested_At DATETIME2 NULL;

ALTER TABLE dbo.Medical_Record
ALTER COLUMN Doctor_Employee_ID INT NULL;

COMMIT;