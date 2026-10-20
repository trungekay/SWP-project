-- Run once on an existing VisionCare SQL Server database before deploying this feature.
IF OBJECT_ID('dbo.Procedure_Payment_Request', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Procedure_Payment_Request (
        Order_ID INT NOT NULL PRIMARY KEY
            REFERENCES dbo.Procedure_Order(Order_ID),
        Amount DECIMAL(18, 0) NOT NULL
            CONSTRAINT CHK_ProcedurePayment_Amount CHECK (Amount >= 0),
        Credit_Amount DECIMAL(18, 0) NOT NULL DEFAULT 0 CHECK (Credit_Amount >= 0),
        Status NVARCHAR(20) NOT NULL DEFAULT 'Pending'
            CHECK (Status IN ('Pending', 'Paid')),
        Created_At DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        Confirmed_At DATETIME2 NULL,
        Confirmed_By_Employee_ID INT NULL
            REFERENCES dbo.Employee_Profile(Employee_ID),
        Payment_Method NVARCHAR(50) NULL,
        Transaction_ID INT NULL
            REFERENCES dbo.Payment_Transaction(Transaction_ID)
    );
END;
GO

IF COL_LENGTH('dbo.Procedure_Payment_Request', 'Credit_Amount') IS NULL
    ALTER TABLE dbo.Procedure_Payment_Request
        ADD Credit_Amount DECIMAL(18, 0) NOT NULL
            CONSTRAINT DF_ProcedurePayment_Credit DEFAULT 0;
GO

-- Upgrade a table created by an earlier version that required Amount > 0.
DECLARE @oldAmountCheck SYSNAME;
SELECT TOP 1 @oldAmountCheck = name
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('dbo.Procedure_Payment_Request')
  AND CHARINDEX('[Amount]>(0)', definition) > 0;
IF @oldAmountCheck IS NOT NULL
    EXEC('ALTER TABLE dbo.Procedure_Payment_Request DROP CONSTRAINT [' + @oldAmountCheck + ']');
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints
               WHERE parent_object_id = OBJECT_ID('dbo.Procedure_Payment_Request')
                 AND name = 'CHK_ProcedurePayment_Amount')
    ALTER TABLE dbo.Procedure_Payment_Request
        ADD CONSTRAINT CHK_ProcedurePayment_Amount CHECK (Amount >= 0);
GO

-- Previously created, unstarted surgery referrals must also wait for payment.
INSERT INTO dbo.Procedure_Payment_Request (Order_ID, Amount, Credit_Amount)
SELECT po.Order_ID, po.Actual_Price - credit.Credit_Amount, credit.Credit_Amount
FROM dbo.Procedure_Order po
JOIN dbo.Service_Catalog s ON s.Service_ID = po.Service_ID
JOIN dbo.Medical_Record mr ON mr.Record_ID = po.Record_ID
JOIN dbo.Master_Invoice i ON i.Appointment_ID = mr.Appointment_ID
OUTER APPLY (
    SELECT COALESCE(SUM(t.Amount), 0) AS Paid_Amount
    FROM dbo.Payment_Transaction t
    WHERE t.Invoice_ID = i.Invoice_ID AND t.Gateway_Status = 'Success'
) paid
CROSS APPLY (
    SELECT CASE WHEN po.Actual_Price < COALESCE(i.Deposit_Amount, 0)
                AND po.Actual_Price < paid.Paid_Amount THEN po.Actual_Price
                WHEN COALESCE(i.Deposit_Amount, 0) < paid.Paid_Amount
                THEN COALESCE(i.Deposit_Amount, 0) ELSE paid.Paid_Amount END AS Credit_Amount
) credit
WHERE s.Service_Code LIKE 'PT-%'
  AND po.Referral_Notes IS NOT NULL
  AND po.Status = 'Pending'
  AND po.Actual_Price >= credit.Credit_Amount
  AND NOT EXISTS (SELECT 1 FROM dbo.Procedure_Payment_Request p WHERE p.Order_ID = po.Order_ID);
GO
