-- Run once against an existing eye_clinic_db_v2 database. Safe to run again.
USE eye_clinic_db_v2;
GO

IF COL_LENGTH('dbo.Service_Catalog', 'Service_Code') IS NULL ALTER TABLE dbo.Service_Catalog ADD Service_Code VARCHAR(20) NULL;
IF COL_LENGTH('dbo.Service_Catalog', 'Specialty_Code') IS NULL ALTER TABLE dbo.Service_Catalog ADD Specialty_Code VARCHAR(30) NULL;
IF COL_LENGTH('dbo.Service_Catalog', 'Tag') IS NULL ALTER TABLE dbo.Service_Catalog ADD Tag NVARCHAR(100) NULL;
IF COL_LENGTH('dbo.Service_Catalog', 'Summary') IS NULL ALTER TABLE dbo.Service_Catalog ADD Summary NVARCHAR(500) NULL;
IF COL_LENGTH('dbo.Service_Catalog', 'Description') IS NULL ALTER TABLE dbo.Service_Catalog ADD Description NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.Service_Catalog', 'Image_Path') IS NULL ALTER TABLE dbo.Service_Catalog ADD Image_Path VARCHAR(255) NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_Service_Catalog_Code' AND object_id = OBJECT_ID('dbo.Service_Catalog'))
    CREATE UNIQUE INDEX UX_Service_Catalog_Code ON dbo.Service_Catalog(Service_Code) WHERE Service_Code IS NOT NULL;
GO

IF OBJECT_ID('dbo.Medical_Supply', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Medical_Supply (
        Supply_ID INT IDENTITY(1,1) PRIMARY KEY,
        Supply_Name NVARCHAR(255) NOT NULL,
        Category NVARCHAR(100) NOT NULL,
        Batch_Code VARCHAR(50) NULL,
        Unit NVARCHAR(30) NOT NULL,
        Quantity INT NOT NULL CONSTRAINT DF_Medical_Supply_Quantity DEFAULT 0,
        Price DECIMAL(18,0) NOT NULL,
        CONSTRAINT CHK_Medical_Supply_Quantity CHECK (Quantity >= 0),
        CONSTRAINT CHK_Medical_Supply_Price CHECK (Price >= 0)
    );
END;
GO

-- Reuse the two matching services already present in the original seed.
UPDATE dbo.Service_Catalog SET Service_Code = 'NK-01', Service_Name = N'Nhãn khoa tổng quát', Specialty_Code = 'general', Tag = N'Gói cơ bản',
    Summary = N'Khám và chẩn đoán toàn diện các bệnh lý về mắt, phù hợp với mọi lứa tuổi.',
    Description = N'Bao gồm đo thị lực, kiểm tra áp lực nhãn cầu, soi đáy mắt, đánh giá tình trạng giác mạc và thủy tinh thể. Bác sĩ tư vấn lộ trình điều trị phù hợp.',
    Image_Path = 'departments-1.jpg', Price = 250000
WHERE Service_Name = N'Khám mắt tổng quát' AND Service_Code IS NULL;
UPDATE dbo.Service_Catalog SET Service_Name = N'Nhãn khoa tổng quát'
WHERE Service_Code = 'NK-01' AND Service_Name = N'Khám mắt tổng quát';
UPDATE dbo.Service_Catalog SET Service_Code = 'KX-02', Service_Name = N'Đo Khúc xạ & Kính', Specialty_Code = 'refraction',
    Tag = N'Khúc xạ kế', Summary = N'Khám sàng lọc và đo độ khúc xạ với hệ thống đo tự động chuẩn xác.',
    Description = N'Đo khúc xạ chính xác bằng máy tự động, thử thị lực và tư vấn tròng kính cận, viễn, loạn cùng kính áp tròng phù hợp.',
    Image_Path = 'departments-2.jpg', Price = 150000
WHERE Service_Name = N'Đo khúc xạ máy' AND Service_Code IS NULL;

IF NOT EXISTS (SELECT 1 FROM dbo.Service_Catalog WHERE Service_Code = 'NK-01')
    INSERT INTO dbo.Service_Catalog (Service_Code, Service_Name, Price, Specialty_Code, Tag, Summary, Description, Image_Path)
    VALUES ('NK-01', N'Nhãn khoa tổng quát', 250000, 'general', N'Gói cơ bản', N'Khám và chẩn đoán toàn diện các bệnh lý về mắt, phù hợp với mọi lứa tuổi.', N'Bao gồm đo thị lực, kiểm tra áp lực nhãn cầu, soi đáy mắt, đánh giá tình trạng giác mạc và thủy tinh thể.', 'departments-1.jpg');
IF NOT EXISTS (SELECT 1 FROM dbo.Service_Catalog WHERE Service_Code = 'KX-02')
    INSERT INTO dbo.Service_Catalog (Service_Code, Service_Name, Price, Specialty_Code, Tag, Summary, Description, Image_Path)
    VALUES ('KX-02', N'Đo Khúc xạ & Kính', 150000, 'refraction', N'Khúc xạ kế', N'Khám sàng lọc và đo độ khúc xạ với hệ thống đo tự động chuẩn xác.', N'Đo khúc xạ chính xác bằng máy tự động, thử thị lực và tư vấn tròng kính phù hợp.', 'departments-2.jpg');
IF NOT EXISTS (SELECT 1 FROM dbo.Service_Catalog WHERE Service_Code = 'LS-03')
    INSERT INTO dbo.Service_Catalog (Service_Code, Service_Name, Price, Specialty_Code, Tag, Summary, Description, Image_Path)
    VALUES ('LS-03', N'Phẫu thuật LASIK', 18000000, 'lasik', N'Kỹ thuật cao', N'Xóa cận không dao, thời gian phục hồi nhanh chóng.', N'Phẫu thuật khúc xạ laser LASIK/SMILE điều trị cận thị, viễn thị và loạn thị với công nghệ hiện đại.', 'departments-3.jpg');
IF NOT EXISTS (SELECT 1 FROM dbo.Service_Catalog WHERE Service_Code = 'PE-04')
    INSERT INTO dbo.Service_Catalog (Service_Code, Service_Name, Price, Specialty_Code, Tag, Summary, Description, Image_Path)
    VALUES ('PE-04', N'Nhãn khoa trẻ em & Nhược thị', 300000, 'children', N'Trẻ em & Học đường', N'Sàng lọc sớm các tật khúc xạ tiến triển, tật lé và suy giảm thị lực ở trẻ nhỏ.', N'Sàng lọc cận thị sớm, điều trị nhược thị và lác mắt trong không gian khám thân thiện.', 'departments-4.jpg');
IF NOT EXISTS (SELECT 1 FROM dbo.Service_Catalog WHERE Service_Code = 'TT-05')
    INSERT INTO dbo.Service_Catalog (Service_Code, Service_Name, Price, Specialty_Code, Tag, Summary, Description, Image_Path)
    VALUES ('TT-05', N'Đục thủy tinh thể (Phaco)', 12000000, 'cataract', N'Phẫu thuật Phaco', N'Tái tạo tầm nhìn trong sáng bằng phương pháp tán nhuyễn Phaco tiên tiến.', N'Phẫu thuật thay thể thủy tinh nhân tạo điều trị đục thủy tinh thể an toàn, đường mổ siêu nhỏ.', 'departments-5.jpg');
IF NOT EXISTS (SELECT 1 FROM dbo.Service_Catalog WHERE Service_Code = 'GL-06')
    INSERT INTO dbo.Service_Catalog (Service_Code, Service_Name, Price, Specialty_Code, Tag, Summary, Description, Image_Path)
    VALUES ('GL-06', N'Glaucoma & Võng mạc', 500000, 'retina', N'Đáy mắt chuyên sâu', N'Kiểm soát nhãn áp, bảo tồn thị trường thần kinh mắt và ngăn ngừa biến chứng mù lòa.', N'Tầm soát và can thiệp bệnh Glaucoma, thoái hóa hoàng điểm và tổn thương võng mạc với hệ thống OCT.', 'gallery/gallery-1.jpg');

IF NOT EXISTS (SELECT 1 FROM dbo.Medical_Supply WHERE Batch_Code = 'SYS-2026A')
    INSERT INTO dbo.Medical_Supply (Supply_Name, Category, Batch_Code, Unit, Quantity, Price) VALUES (N'Thuốc nhỏ mắt Systane Ultra (10ml)', N'Dung dịch nhỏ mắt', 'SYS-2026A', N'lọ', 142, 95000);
IF NOT EXISTS (SELECT 1 FROM dbo.Medical_Supply WHERE Batch_Code = 'ESL-8839')
    INSERT INTO dbo.Medical_Supply (Supply_Name, Category, Batch_Code, Unit, Quantity, Price) VALUES (N'Tròng kính Essilor Crizal Alize 1.60', N'Tròng kính', 'ESL-8839', N'cặp', 45, 1250000);
IF NOT EXISTS (SELECT 1 FROM dbo.Medical_Supply WHERE Batch_Code = 'SNL-091')
    INSERT INTO dbo.Medical_Supply (Supply_Name, Category, Batch_Code, Unit, Quantity, Price) VALUES (N'Nước mắt nhân tạo Sanlein 0.1% (5ml)', N'Dung dịch nhỏ mắt', 'SNL-091', N'lọ', 8, 88000);
IF NOT EXISTS (SELECT 1 FROM dbo.Medical_Supply WHERE Batch_Code = 'FLS-002')
    INSERT INTO dbo.Medical_Supply (Supply_Name, Category, Batch_Code, Unit, Quantity, Price) VALUES (N'Que thử màu huỳnh quang Fluorescein Strips', N'Vật tư chẩn đoán', 'FLS-002', N'hộp', 22, 320000);
GO
