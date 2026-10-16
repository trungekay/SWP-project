-- Run once against an existing eye_clinic_db. Keeps a copy of the old retail catalog.
USE eye_clinic_db;
GO
SET XACT_ABORT ON;
BEGIN TRANSACTION;

IF OBJECT_ID(N'dbo.Medicine_Retail_Backup_20261017', N'U') IS NULL
    SELECT * INTO dbo.Medicine_Retail_Backup_20261017 FROM dbo.Medicine;

CREATE TABLE #RetailCatalog (
    Supply_Name NVARCHAR(255) NOT NULL PRIMARY KEY,
    Category NVARCHAR(100) NOT NULL,
    Price DECIMAL(18,0) NOT NULL
);

INSERT INTO #RetailCatalog (Supply_Name, Category, Price) VALUES
(N'Thuốc nhỏ mắt Systane Ultra (10ml)', N'Thuốc & dung dịch', 95000),
(N'Nước mắt nhân tạo Sanlein 0.1% (5ml)', N'Thuốc & dung dịch', 88000),
(N'Thuốc mỡ tra mắt (3,5g)', N'Thuốc & dung dịch', 65000),
(N'Dung dịch rửa mắt vô trùng (100 ml)', N'Thuốc & dung dịch', 45000),
(N'Nước mắt nhân tạo không chất bảo quản (hộp 10 ống)', N'Thuốc & dung dịch', 135000),
(N'Gọng kính nhựa TR90', N'Kính gọng & tròng kính', 320000),
(N'Gọng kính kim loại', N'Kính gọng & tròng kính', 450000),
(N'Tròng kính Essilor Crizal Alize 1.60', N'Kính gọng & tròng kính', 1250000),
(N'Tròng kính lọc ánh sáng xanh 1.56', N'Kính gọng & tròng kính', 650000),
(N'Kính râm chống tia UV400', N'Kính gọng & tròng kính', 280000),
(N'Kính áp tròng mềm dùng một ngày (-2.00D)', N'Kính áp tròng', 180000),
(N'Kính áp tròng mềm dùng một tháng (-2.00D)', N'Kính áp tròng', 250000),
(N'Kính áp tròng cứng RGP (1 chiếc)', N'Kính áp tròng', 1200000),
(N'Kính Ortho-K (1 chiếc)', N'Kính áp tròng', 7500000),
(N'Dung dịch ngâm và vệ sinh kính áp tròng (240ml)', N'Kính áp tròng', 98000),
(N'Hộp đựng kính cứng', N'Phụ kiện & sản phẩm hỗ trợ', 35000),
(N'Khăn lau kính microfiber', N'Phụ kiện & sản phẩm hỗ trợ', 20000),
(N'Dây đeo kính thể thao', N'Phụ kiện & sản phẩm hỗ trợ', 45000),
(N'Hộp đựng kính áp tròng', N'Phụ kiện & sản phẩm hỗ trợ', 25000),
(N'Miếng che mắt tập nhược thị', N'Phụ kiện & sản phẩm hỗ trợ', 60000);

ALTER TABLE dbo.Medicine DROP CONSTRAINT CHK_Medicine_Category;

-- Keep existing IDs, prices and images for matching products; remove surplus rows.
DELETE m FROM dbo.Medicine AS m
WHERE NOT EXISTS (SELECT 1 FROM #RetailCatalog AS c WHERE c.Supply_Name = m.Supply_Name);

;WITH Duplicates AS (
    SELECT Medicine_ID, ROW_NUMBER() OVER (PARTITION BY Supply_Name ORDER BY Medicine_ID) AS rn
    FROM dbo.Medicine
)
DELETE FROM Duplicates WHERE rn > 1;

UPDATE m SET Category = c.Category
FROM dbo.Medicine AS m
JOIN #RetailCatalog AS c ON c.Supply_Name = m.Supply_Name;

INSERT INTO dbo.Medicine (Supply_Name, Category, Price)
SELECT c.Supply_Name, c.Category, c.Price
FROM #RetailCatalog AS c
WHERE NOT EXISTS (SELECT 1 FROM dbo.Medicine AS m WHERE m.Supply_Name = c.Supply_Name);

ALTER TABLE dbo.Medicine WITH CHECK ADD CONSTRAINT CHK_Medicine_Category CHECK (Category IN (
    N'Thuốc & dung dịch', N'Kính gọng & tròng kính', N'Kính áp tròng',
    N'Phụ kiện & sản phẩm hỗ trợ', N'Khác'));

IF (SELECT COUNT(*) FROM dbo.Medicine) <> 20
    THROW 50001, N'Danh mục bán lẻ phải có đúng 20 sản phẩm.', 1;

COMMIT TRANSACTION;
GO
