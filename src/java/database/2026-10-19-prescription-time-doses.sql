IF COL_LENGTH('dbo.Prescription_Detail', 'Morning_Dose') IS NULL
    ALTER TABLE dbo.Prescription_Detail ADD Morning_Dose NVARCHAR(100) NULL;
IF COL_LENGTH('dbo.Prescription_Detail', 'Afternoon_Dose') IS NULL
    ALTER TABLE dbo.Prescription_Detail ADD Afternoon_Dose NVARCHAR(100) NULL;
IF COL_LENGTH('dbo.Prescription_Detail', 'Evening_Dose') IS NULL
    ALTER TABLE dbo.Prescription_Detail ADD Evening_Dose NVARCHAR(100) NULL;
IF COL_LENGTH('dbo.Prescription_Detail', 'Is_Custom_Medicine') IS NULL
    ALTER TABLE dbo.Prescription_Detail ADD Is_Custom_Medicine BIT NOT NULL DEFAULT(0);
