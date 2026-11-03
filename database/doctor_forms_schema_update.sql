-- Add fields required by the doctor examination and prescription forms.
-- Safe to run again on databases that already have some or all of these fields.
IF COL_LENGTH('dbo.Medical_Record', 'Staff_Notes') IS NULL
    ALTER TABLE dbo.Medical_Record ADD Staff_Notes nvarchar(max) NULL;

IF COL_LENGTH('dbo.Examination_Detail', 'Surgery_Indication') IS NULL
    ALTER TABLE dbo.Examination_Detail ADD Surgery_Indication nvarchar(1000) NULL;

IF COL_LENGTH('dbo.Prescription', 'Follow_Up_Date') IS NULL
    ALTER TABLE dbo.Prescription ADD Follow_Up_Date date NULL;

IF COL_LENGTH('dbo.Prescription_Detail', 'Strength') IS NULL
    ALTER TABLE dbo.Prescription_Detail ADD Strength nvarchar(100) NULL;
IF COL_LENGTH('dbo.Prescription_Detail', 'Dosage') IS NULL
    ALTER TABLE dbo.Prescription_Detail ADD Dosage nvarchar(255) NULL;
IF COL_LENGTH('dbo.Prescription_Detail', 'Frequency') IS NULL
    ALTER TABLE dbo.Prescription_Detail ADD Frequency nvarchar(255) NULL;
IF COL_LENGTH('dbo.Prescription_Detail', 'Duration') IS NULL
    ALTER TABLE dbo.Prescription_Detail ADD Duration nvarchar(100) NULL;
IF COL_LENGTH('dbo.Prescription_Detail', 'Unit') IS NULL
    ALTER TABLE dbo.Prescription_Detail ADD Unit nvarchar(50) NULL;
IF COL_LENGTH('dbo.Prescription_Detail', 'Additional_Instruction') IS NULL
    ALTER TABLE dbo.Prescription_Detail ADD Additional_Instruction nvarchar(255) NULL;

IF OBJECT_ID('dbo.Eyeglass_Prescription', 'U') IS NULL
    CREATE TABLE dbo.Eyeglass_Prescription (
        Prescription_ID int NOT NULL PRIMARY KEY,
        OD_SPH decimal(5,2) NULL,
        OD_CYL decimal(5,2) NULL,
        OD_AXIS smallint NULL,
        OD_ADD decimal(5,2) NULL,
        OS_SPH decimal(5,2) NULL,
        OS_CYL decimal(5,2) NULL,
        OS_AXIS smallint NULL,
        OS_ADD decimal(5,2) NULL,
        PD decimal(4,1) NULL,
        Lens_Type varchar(30) NULL,
        Glasses_Notes nvarchar(1000) NULL,
        CONSTRAINT FK_Eyeglass_Prescription_Prescription
            FOREIGN KEY (Prescription_ID) REFERENCES dbo.Prescription(Prescription_ID)
    );
