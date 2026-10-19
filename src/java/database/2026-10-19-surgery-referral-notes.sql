IF COL_LENGTH('dbo.Procedure_Order', 'Referral_Notes') IS NULL
    ALTER TABLE dbo.Procedure_Order ADD Referral_Notes NVARCHAR(2000) NULL;
