-- Run once against an existing eye_clinic_db. This script keeps all existing IDs and images.
-- Do not run the fresh setup script for an existing database; it drops the database.
USE eye_clinic_db;
GO
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'dbo.Medicine', N'U') IS NOT NULL OR OBJECT_ID(N'dbo.Consumables', N'U') IS NOT NULL
        THROW 51000, 'Medicine or Consumables already exists; review the migration state before retrying.', 1;

    CREATE TABLE dbo.Medicine (
        Medicine_ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Supply_Name NVARCHAR(255) NOT NULL,
        Category NVARCHAR(100) NOT NULL,
        Price DECIMAL(18,0) NOT NULL,
        Image_Data VARBINARY(MAX) NULL,
        Image_Mime_Type VARCHAR(50) NULL,
        CONSTRAINT CHK_Medicine_Price CHECK (Price >= 0),
        CONSTRAINT CHK_Medicine_Category CHECK (Category IN (N'Thuốc & Dung dịch', N'Kính & Phụ kiện'))
    );

    CREATE TABLE dbo.Consumables (
        Consumable_ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Supply_Name NVARCHAR(255) NOT NULL,
        Category NVARCHAR(100) NOT NULL DEFAULT (N'Vật tư y tế tiêu hao'),
        Price DECIMAL(18,0) NOT NULL,
        Image_Data VARBINARY(MAX) NULL,
        Image_Mime_Type VARCHAR(50) NULL,
        CONSTRAINT CHK_Consumables_Price CHECK (Price >= 0),
        CONSTRAINT CHK_Consumables_Category CHECK (Category = N'Vật tư y tế tiêu hao')
    );

    SET IDENTITY_INSERT dbo.Medicine ON;
    INSERT INTO dbo.Medicine (Medicine_ID, Supply_Name, Category, Price, Image_Data, Image_Mime_Type)
    SELECT Supply_ID, Supply_Name, Category, Price, Image_Data, Image_Mime_Type
    FROM dbo.Medical_Supply
    WHERE Category IN (N'Thuốc & Dung dịch', N'Kính & Phụ kiện');
    SET IDENTITY_INSERT dbo.Medicine OFF;

    SET IDENTITY_INSERT dbo.Consumables ON;
    INSERT INTO dbo.Consumables (Consumable_ID, Supply_Name, Category, Price, Image_Data, Image_Mime_Type)
    SELECT Supply_ID, Supply_Name, Category, Price, Image_Data, Image_Mime_Type
    FROM dbo.Medical_Supply
    WHERE Category = N'Vật tư y tế tiêu hao';
    SET IDENTITY_INSERT dbo.Consumables OFF;

    DELETE FROM dbo.Medical_Supply
    WHERE Category IN (N'Thuốc & Dung dịch', N'Kính & Phụ kiện', N'Vật tư y tế tiêu hao');

    ALTER TABLE dbo.Medical_Supply DROP CONSTRAINT CHK_Medical_Supply_Category;
    ALTER TABLE dbo.Medical_Supply ADD CONSTRAINT CHK_Medical_Supply_Category
        CHECK (Category = N'Khác');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
