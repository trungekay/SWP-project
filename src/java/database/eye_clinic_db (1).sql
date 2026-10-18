-- =====================================================
-- VisionCare Eye Clinic Database Export
-- Generated: 2026-10-18 22:58:01
-- Database: eye_clinic_db
-- =====================================================
USE [eye_clinic_db];
GO

-- -----------------------------------------------------
-- Table: [Role]
-- -----------------------------------------------------
IF OBJECT_ID(N'dbo.[Role]', N'U') IS NULL
BEGIN
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Role](
	[Role_ID] [int] IDENTITY(1,1) NOT NULL,
	[Role_Name] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Role_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Role_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

END
GO

-- -----------------------------------------------------
-- Table: [Account]
-- -----------------------------------------------------
IF OBJECT_ID(N'dbo.[Account]', N'U') IS NULL
BEGIN
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Account](
	[Account_ID] [int] IDENTITY(1,1) NOT NULL,
	[Role_ID] [int] NOT NULL,
	[Email] [nvarchar](150) NOT NULL,
	[Password] [nvarchar](255) NOT NULL,
	[Auth_Provider] [nvarchar](50) NOT NULL,
	[Account_Status] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Account_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

END
GO

-- -----------------------------------------------------
-- Table: [Employee_Profile]
-- -----------------------------------------------------
IF OBJECT_ID(N'dbo.[Employee_Profile]', N'U') IS NULL
BEGIN
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Employee_Profile](
	[Employee_ID] [int] IDENTITY(1,1) NOT NULL,
	[Account_ID] [int] NOT NULL,
	[Room_ID] [int] NULL,
	[Full_Name] [nvarchar](150) NOT NULL,
	[Phone] [nvarchar](20) NULL,
	[DOB] [date] NULL,
	[Address] [nvarchar](255) NULL,
	[Specialty] [nvarchar](100) NULL,
	[License_Number] [nvarchar](100) NULL,
	[Biography] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[Employee_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Account_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

END
GO

-- -----------------------------------------------------
-- Table: [Service_Catalog]
-- -----------------------------------------------------
IF OBJECT_ID(N'dbo.[Service_Catalog]', N'U') IS NULL
BEGIN
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Service_Catalog](
	[Service_ID] [int] IDENTITY(1,1) NOT NULL,
	[Service_Code] [varchar](20) NULL,
	[Service_Name] [nvarchar](255) NOT NULL,
	[Price] [decimal](18, 0) NOT NULL,
	[Category] [nvarchar](100) NOT NULL,
	[Summary] [nvarchar](500) NULL,
	[Description] [nvarchar](max) NULL,
	[Image_Data] [varbinary](max) NULL,
	[Image_Mime_Type] [varchar](50) NULL,
	[Image_Path] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[Service_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

SET ANSI_PADDING ON

CREATE UNIQUE NONCLUSTERED INDEX [UX_Service_Catalog_Code] ON [dbo].[Service_Catalog]
(
	[Service_Code] ASC
)
WHERE ([Service_Code] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
END
GO

-- -----------------------------------------------------
-- Table: [Room]
-- -----------------------------------------------------
IF OBJECT_ID(N'dbo.[Room]', N'U') IS NULL
BEGIN
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Room](
	[Room_ID] [int] IDENTITY(1,1) NOT NULL,
	[Room_Name] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Room_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Room_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

END
GO

-- -----------------------------------------------------
-- Table: [Work_Schedule]
-- -----------------------------------------------------
IF OBJECT_ID(N'dbo.[Work_Schedule]', N'U') IS NULL
BEGIN
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Work_Schedule](
	[Schedule_ID] [int] IDENTITY(1,1) NOT NULL,
	[Doctor_Employee_ID] [int] NULL,
	[Specialist_Employee_ID] [int] NULL,
	[Staff_Employee_ID] [int] NULL,
	[Work_Date] [date] NOT NULL,
	[Start_Time] [time](0) NOT NULL,
	[End_Time] [time](0) NOT NULL,
	[Slot] [nvarchar](50) NOT NULL,
	[Status] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Schedule_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

END
GO

-- -----------------------------------------------------
-- Table: [Patient]
-- -----------------------------------------------------
IF OBJECT_ID(N'dbo.[Patient]', N'U') IS NULL
BEGIN
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Patient](
	[Patient_ID] [int] IDENTITY(1,1) NOT NULL,
	[Account_ID] [int] NULL,
	[Full_Name] [nvarchar](150) NOT NULL,
	[Phone] [nvarchar](20) NOT NULL,
	[DOB] [date] NULL,
	[Address] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[Patient_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Phone] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

CREATE UNIQUE NONCLUSTERED INDEX [UX_Patient_Account_ID] ON [dbo].[Patient]
(
	[Account_ID] ASC
)
WHERE ([Account_ID] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
END
GO

-- -----------------------------------------------------
-- Table: [Appointment]
-- -----------------------------------------------------
IF OBJECT_ID(N'dbo.[Appointment]', N'U') IS NULL
BEGIN
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Appointment](
	[Appointment_ID] [int] IDENTITY(1,1) NOT NULL,
	[Patient_ID] [int] NOT NULL,
	[Schedule_ID] [int] NOT NULL,
	[Staff_Employee_ID] [int] NULL,
	[Status] [nvarchar](50) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[checkin_time] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[Appointment_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

END
GO

-- -----------------------------------------------------
-- Table: [Master_Invoice]
-- -----------------------------------------------------
IF OBJECT_ID(N'dbo.[Master_Invoice]', N'U') IS NULL
BEGIN
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Master_Invoice](
	[Invoice_ID] [int] IDENTITY(1,1) NOT NULL,
	[Appointment_ID] [int] NOT NULL,
	[Total_Amount] [decimal](18, 0) NOT NULL,
	[Deposit_Amount] [decimal](18, 0) NULL,
	[Balance_Due] [decimal](18, 0) NOT NULL,
	[Status] [nvarchar](50) NOT NULL,
	[Create_At] [datetime2](7) NOT NULL,
	[Close_At] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[Invoice_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Appointment_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

END
GO

-- -----------------------------------------------------
-- Table: [Payment_Transaction]
-- -----------------------------------------------------
IF OBJECT_ID(N'dbo.[Payment_Transaction]', N'U') IS NULL
BEGIN
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Payment_Transaction](
	[Transaction_ID] [int] IDENTITY(1,1) NOT NULL,
	[Invoice_ID] [int] NOT NULL,
	[Amount] [decimal](18, 0) NOT NULL,
	[Gateway_Status] [nvarchar](50) NOT NULL,
	[Trans_Date] [datetime2](7) NOT NULL,
	[Payment_Gateway] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Transaction_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

END
GO

-- -----------------------------------------------------
-- Table: [Medical_Record]
-- -----------------------------------------------------
IF OBJECT_ID(N'dbo.[Medical_Record]', N'U') IS NULL
BEGIN
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Medical_Record](
	[Record_ID] [int] IDENTITY(1,1) NOT NULL,
	[Appointment_ID] [int] NOT NULL,
	[Doctor_Employee_ID] [int] NOT NULL,
	[Clinical_Diagnosis] [nvarchar](max) NULL,
	[examination_result] [nvarchar](max) NULL,
	[conclusion] [nvarchar](max) NULL,
	[Created_At] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Record_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Appointment_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

END
GO

-- -----------------------------------------------------
-- Table: [Prescription]
-- -----------------------------------------------------
IF OBJECT_ID(N'dbo.[Prescription]', N'U') IS NULL
BEGIN
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Prescription](
	[Prescription_ID] [int] IDENTITY(1,1) NOT NULL,
	[Record_ID] [int] NOT NULL,
	[Doctor_Notes] [nvarchar](max) NULL,
	[created_at] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Prescription_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

END
GO

-- -----------------------------------------------------
-- Table: [Medical_Supply]
-- -----------------------------------------------------
IF OBJECT_ID(N'dbo.[Medical_Supply]', N'U') IS NULL
BEGIN
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Medical_Supply](
	[Supply_ID] [int] IDENTITY(1,1) NOT NULL,
	[Supply_Name] [nvarchar](255) NOT NULL,
	[Category] [nvarchar](100) NOT NULL,
	[Price] [decimal](18, 0) NOT NULL,
	[Image_Data] [varbinary](max) NULL,
	[Image_Mime_Type] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[Supply_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

END
GO

-- -----------------------------------------------------
-- Table: [Prescription_Detail]
-- -----------------------------------------------------
IF OBJECT_ID(N'dbo.[Prescription_Detail]', N'U') IS NULL
BEGIN
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Prescription_Detail](
	[Detail_ID] [int] IDENTITY(1,1) NOT NULL,
	[Prescription_ID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[Dosage_Instruction] [nvarchar](max) NULL,
	[Medicine_Name] [nvarchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Detail_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

END
GO

-- -----------------------------------------------------
-- Table: [Procedure_Order]
-- -----------------------------------------------------
IF OBJECT_ID(N'dbo.[Procedure_Order]', N'U') IS NULL
BEGIN
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Procedure_Order](
	[Order_ID] [int] IDENTITY(1,1) NOT NULL,
	[Specialist_Employee_ID] [int] NULL,
	[Record_ID] [int] NOT NULL,
	[Service_ID] [int] NOT NULL,
	[Actual_Price] [decimal](18, 0) NOT NULL,
	[Status] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Order_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

END
GO

-- -----------------------------------------------------
-- Table: [Leave_Cancel_Request]
-- -----------------------------------------------------
IF OBJECT_ID(N'dbo.[Leave_Cancel_Request]', N'U') IS NULL
BEGIN
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Leave_Cancel_Request](
	[Request_ID] [int] IDENTITY(1,1) NOT NULL,
	[Schedule_ID] [int] NOT NULL,
	[Requester_Employee_ID] [int] NOT NULL,
	[Approved_By_Employee_ID] [int] NULL,
	[leave_Date] [date] NOT NULL,
	[Reason] [nvarchar](max) NOT NULL,
	[request_status] [nvarchar](50) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[approved_at] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[Request_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

END
GO

-- -----------------------------------------------------
-- Table: [Refund_Request]
-- -----------------------------------------------------
IF OBJECT_ID(N'dbo.[Refund_Request]', N'U') IS NULL
BEGIN
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Refund_Request](
	[Refund_ID] [int] IDENTITY(1,1) NOT NULL,
	[Invoice_ID] [int] NOT NULL,
	[created_by_employee_id] [int] NOT NULL,
	[approved_by_employee_id] [int] NULL,
	[Patient_ID] [int] NOT NULL,
	[Refund_Amount] [decimal](18, 0) NOT NULL,
	[Reason] [nvarchar](max) NULL,
	[Status] [nvarchar](50) NOT NULL,
	[Created_At] [datetime2](7) NOT NULL,
	[Update_At] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Refund_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

END
GO

-- -----------------------------------------------------
-- Table: [Clinic_Gallery]
-- -----------------------------------------------------
IF OBJECT_ID(N'dbo.[Clinic_Gallery]', N'U') IS NULL
BEGIN
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Clinic_Gallery](
	[Item_ID] [int] NOT NULL,
	[Title] [nvarchar](200) NULL,
	[Description] [nvarchar](500) NULL,
	[Display_Order] [int] NOT NULL,
	[Default_Filename] [varchar](100) NULL,
	[Image_Data] [varbinary](max) NULL,
	[Image_Mime_Type] [varchar](50) NULL,
	[Updated_At] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Item_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

END
GO

-- -----------------------------------------------------
-- Table: [Clinic_Setting]
-- -----------------------------------------------------
IF OBJECT_ID(N'dbo.[Clinic_Setting]', N'U') IS NULL
BEGIN
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Clinic_Setting](
	[Setting_Key] [varchar](50) NOT NULL,
	[Setting_Value] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[Setting_Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

END
GO

-- -----------------------------------------------------
-- Data: [Role] (6 rows)
-- -----------------------------------------------------
SET IDENTITY_INSERT [dbo].[Role] ON 

INSERT [dbo].[Role] ([Role_ID], [Role_Name]) VALUES (2, N'Director')
INSERT [dbo].[Role] ([Role_ID], [Role_Name]) VALUES (3, N'Doctor')
INSERT [dbo].[Role] ([Role_ID], [Role_Name]) VALUES (4, N'Medical_Specialist')
INSERT [dbo].[Role] ([Role_ID], [Role_Name]) VALUES (6, N'Patient')
INSERT [dbo].[Role] ([Role_ID], [Role_Name]) VALUES (5, N'Staff')
INSERT [dbo].[Role] ([Role_ID], [Role_Name]) VALUES (1, N'System_Admin')
SET IDENTITY_INSERT [dbo].[Role] OFF
GO

-- -----------------------------------------------------
-- Data: [Account] (17 rows)
-- -----------------------------------------------------
SET IDENTITY_INSERT [dbo].[Account] ON 

INSERT [dbo].[Account] ([Account_ID], [Role_ID], [Email], [Password], [Auth_Provider], [Account_Status]) VALUES (1, 1, N'admin@eyeclinic.com', N'123', N'Local', N'Active')
INSERT [dbo].[Account] ([Account_ID], [Role_ID], [Email], [Password], [Auth_Provider], [Account_Status]) VALUES (2, 2, N'director@eyeclinic.com', N'123', N'Local', N'Active')
INSERT [dbo].[Account] ([Account_ID], [Role_ID], [Email], [Password], [Auth_Provider], [Account_Status]) VALUES (3, 3, N'doctor.nam@eyeclinic.com', N'123', N'Local', N'Active')
INSERT [dbo].[Account] ([Account_ID], [Role_ID], [Email], [Password], [Auth_Provider], [Account_Status]) VALUES (4, 3, N'doctor.tinh@eyeclinic.com', N'123', N'Local', N'Active')
INSERT [dbo].[Account] ([Account_ID], [Role_ID], [Email], [Password], [Auth_Provider], [Account_Status]) VALUES (5, 3, N'doctor.lan@eyeclinic.com', N'123', N'Local', N'Active')
INSERT [dbo].[Account] ([Account_ID], [Role_ID], [Email], [Password], [Auth_Provider], [Account_Status]) VALUES (6, 3, N'doctor.ngoc@eyeclinic.com', N'123', N'Local', N'Active')
INSERT [dbo].[Account] ([Account_ID], [Role_ID], [Email], [Password], [Auth_Provider], [Account_Status]) VALUES (7, 3, N'doctor.huy@eyeclinic.com', N'123', N'Local', N'Active')
INSERT [dbo].[Account] ([Account_ID], [Role_ID], [Email], [Password], [Auth_Provider], [Account_Status]) VALUES (8, 3, N'doctor.dung@eyeclinic.com', N'123', N'Local', N'Active')
INSERT [dbo].[Account] ([Account_ID], [Role_ID], [Email], [Password], [Auth_Provider], [Account_Status]) VALUES (9, 4, N'specialist.lan@eyeclinic.com', N'123', N'Local', N'Active')
INSERT [dbo].[Account] ([Account_ID], [Role_ID], [Email], [Password], [Auth_Provider], [Account_Status]) VALUES (10, 4, N'specialist.huy@eyeclinic.com', N'123', N'Local', N'Active')
INSERT [dbo].[Account] ([Account_ID], [Role_ID], [Email], [Password], [Auth_Provider], [Account_Status]) VALUES (11, 4, N'specialist.c@eyeclinic.com', N'123', N'Local', N'Active')
INSERT [dbo].[Account] ([Account_ID], [Role_ID], [Email], [Password], [Auth_Provider], [Account_Status]) VALUES (12, 5, N'staff.lan@eyeclinic.com', N'123', N'Local', N'Active')
INSERT [dbo].[Account] ([Account_ID], [Role_ID], [Email], [Password], [Auth_Provider], [Account_Status]) VALUES (13, 6, N'patient.an@gmail.com', N'123', N'Local', N'Active')
INSERT [dbo].[Account] ([Account_ID], [Role_ID], [Email], [Password], [Auth_Provider], [Account_Status]) VALUES (14, 6, N'patient.linh@gmail.com', N'123', N'Local', N'Active')
INSERT [dbo].[Account] ([Account_ID], [Role_ID], [Email], [Password], [Auth_Provider], [Account_Status]) VALUES (15, 6, N'patient.hoang@gmail.com', N'123', N'Local', N'Active')
INSERT [dbo].[Account] ([Account_ID], [Role_ID], [Email], [Password], [Auth_Provider], [Account_Status]) VALUES (16, 6, N'patient.mai@gmail.com', N'123', N'Local', N'Active')
INSERT [dbo].[Account] ([Account_ID], [Role_ID], [Email], [Password], [Auth_Provider], [Account_Status]) VALUES (17, 6, N'patient.duc@gmail.com', N'123', N'Local', N'Active')
SET IDENTITY_INSERT [dbo].[Account] OFF
GO

-- -----------------------------------------------------
-- Data: [Employee_Profile] (12 rows)
-- -----------------------------------------------------
SET IDENTITY_INSERT [dbo].[Employee_Profile] ON 

INSERT [dbo].[Employee_Profile] ([Employee_ID], [Account_ID], [Room_ID], [Full_Name], [Phone], [DOB], [Address], [Specialty], [License_Number], [Biography]) VALUES (1, 1, NULL, N'Quản trị viên Hệ thống', NULL, NULL, NULL, N'Quản trị hệ thống', NULL, NULL)
INSERT [dbo].[Employee_Profile] ([Employee_ID], [Account_ID], [Room_ID], [Full_Name], [Phone], [DOB], [Address], [Specialty], [License_Number], [Biography]) VALUES (2, 2, NULL, N'Nguyễn Văn Giám Đốc', NULL, NULL, NULL, N'Giám đốc', NULL, NULL)
INSERT [dbo].[Employee_Profile] ([Employee_ID], [Account_ID], [Room_ID], [Full_Name], [Phone], [DOB], [Address], [Specialty], [License_Number], [Biography]) VALUES (3, 3, 1, N'BS. Trần Văn Nam', NULL, NULL, NULL, N'Nhãn khoa tổng quát', N'BS-12345/EYE', N'Hơn 12 năm kinh nghiệm trong chẩn đoán và điều trị toàn diện các bệnh lý mắt. Từng công tác tại Bệnh viện Mắt TP.HCM và tích cực tham gia các hội thảo nhãn khoa quốc tế.')
INSERT [dbo].[Employee_Profile] ([Employee_ID], [Account_ID], [Room_ID], [Full_Name], [Phone], [DOB], [Address], [Specialty], [License_Number], [Biography]) VALUES (4, 4, 2, N'TS.BS. Nguyễn Xuân Tịnh', NULL, NULL, NULL, N'Đo Khúc xạ & Kính', N'BS-56789/EYE', N'Tiến sĩ Nhãn khoa với hơn 15 năm chuyên sâu về tật khúc xạ, kiểm soát tiến triển cận thị học đường và ứng dụng công nghệ đo thị lực hiện đại từ Đức.')
INSERT [dbo].[Employee_Profile] ([Employee_ID], [Account_ID], [Room_ID], [Full_Name], [Phone], [DOB], [Address], [Specialty], [License_Number], [Biography]) VALUES (5, 5, 3, N'BS. Lê Hoàng Lan', NULL, NULL, NULL, N'Phẫu thuật LASIK', N'BS-98765/EYE', N'Chuyên gia phẫu thuật khúc xạ hàng đầu, thực hiện thành công hơn 6,000 ca phẫu thuật Femto-LASIK và SMILE. Tận tâm, chu đáo và luôn đồng hành cùng bệnh nhân.')
INSERT [dbo].[Employee_Profile] ([Employee_ID], [Account_ID], [Room_ID], [Full_Name], [Phone], [DOB], [Address], [Specialty], [License_Number], [Biography]) VALUES (6, 6, 4, N'BS. Phạm Bảo Ngọc', NULL, NULL, NULL, N'Nhãn khoa trẻ em & Nhược thị', N'BS-34567/EYE', N'Bác sĩ giàu kinh nghiệm trong điều trị nhược thị, lác mắt và các bệnh lý mắt bẩm sinh ở trẻ em. Được đào tạo chuyên sâu tại Bệnh viện Mắt Trung ương và Singapore.')
INSERT [dbo].[Employee_Profile] ([Employee_ID], [Account_ID], [Room_ID], [Full_Name], [Phone], [DOB], [Address], [Specialty], [License_Number], [Biography]) VALUES (7, 7, 5, N'BS. Trần Quang Huy', NULL, NULL, NULL, N'Đục thủy tinh thể (Phaco)', N'BS-45678/EYE', N'Bàn tay vàng trong phẫu thuật Phaco tán nhuyễn thể thủy tinh đục, phục hồi thị lực sáng rõ cho hàng ngàn bệnh nhân cao tuổi với kỹ thuật đường mổ siêu nhỏ.')
INSERT [dbo].[Employee_Profile] ([Employee_ID], [Account_ID], [Room_ID], [Full_Name], [Phone], [DOB], [Address], [Specialty], [License_Number], [Biography]) VALUES (8, 8, 6, N'BS. Ngô Tiến Dũng', NULL, NULL, NULL, N'Glaucoma & Võng mạc', N'BS-99999/EYE', NULL)
INSERT [dbo].[Employee_Profile] ([Employee_ID], [Account_ID], [Room_ID], [Full_Name], [Phone], [DOB], [Address], [Specialty], [License_Number], [Biography]) VALUES (9, 9, 7, N'ThS.BS. Lê Hoàng Lan', NULL, NULL, NULL, N'Medical Specialist tiểu phẫu', N'BS-11111/EYE', NULL)
INSERT [dbo].[Employee_Profile] ([Employee_ID], [Account_ID], [Room_ID], [Full_Name], [Phone], [DOB], [Address], [Specialty], [License_Number], [Biography]) VALUES (10, 10, 8, N'BSCKII. Trần Quang Huy', NULL, NULL, NULL, N'Medical Specialist tiểu phẫu', N'BS-22222/EYE', NULL)
INSERT [dbo].[Employee_Profile] ([Employee_ID], [Account_ID], [Room_ID], [Full_Name], [Phone], [DOB], [Address], [Specialty], [License_Number], [Biography]) VALUES (11, 11, 9, N'ThS. Lê Văn C', NULL, NULL, NULL, N'Medical Specialist tiểu phẫu', N'BS-33333/EYE', NULL)
INSERT [dbo].[Employee_Profile] ([Employee_ID], [Account_ID], [Room_ID], [Full_Name], [Phone], [DOB], [Address], [Specialty], [License_Number], [Biography]) VALUES (12, 12, NULL, N'Lễ Tân Phạm Thị Lan', NULL, NULL, NULL, N'Thu Ngân & Tiếp Đón', NULL, NULL)
SET IDENTITY_INSERT [dbo].[Employee_Profile] OFF
GO

-- -----------------------------------------------------
-- Data: [Service_Catalog] (16 rows)
-- -----------------------------------------------------
SET IDENTITY_INSERT [dbo].[Service_Catalog] ON 

INSERT [dbo].[Service_Catalog] ([Service_ID], [Service_Code], [Service_Name], [Price], [Category], [Summary], [Description], [Image_Path], [Image_Data], [Image_Mime_Type]) VALUES (1, N'NK-01', N'Khám mắt tổng quát & Soi đáy mắt', CAST(200000 AS Decimal(18, 0)), N'Khám và tư vấn', N'Khám và chẩn đoán toàn diện các bệnh lý về mắt, đo thị lực, kiểm tra áp lực nhãn cầu và soi đáy mắt.', N'Bao gồm đo thị lực, kiểm tra áp lực nhãn cầu, soi đáy mắt, đánh giá tình trạng giác mạc và thủy tinh thể.', N'services/service-general.jpg', NULL, NULL)
INSERT [dbo].[Service_Catalog] ([Service_ID], [Service_Code], [Service_Name], [Price], [Category], [Summary], [Description], [Image_Path], [Image_Data], [Image_Mime_Type]) VALUES (2, N'KX-02', N'Đo khúc xạ và tư vấn kính', CAST(150000 AS Decimal(18, 0)), N'Kiểm tra và chẩn đoán', N'Khám sàng lọc và đo độ khúc xạ với hệ thống đo tự động chuẩn xác.', N'Đo khúc xạ chính xác bằng máy tự động, thử thị lực và tư vấn tròng kính phù hợp.', N'services/service-refraction.jpg', NULL, NULL)
INSERT [dbo].[Service_Catalog] ([Service_ID], [Service_Code], [Service_Name], [Price], [Category], [Summary], [Description], [Image_Path], [Image_Data], [Image_Mime_Type]) VALUES (3, N'LS-03', N'Khám tiền phẫu & Tư vấn xóa cận LASIK/SMILE', CAST(500000 AS Decimal(18, 0)), N'Khám và tư vấn', N'Khám chuyên sâu 8 bước bản đồ giác mạc, đo độ dày giác mạc, soi đáy mắt và tư vấn phương pháp xóa cận. Hoàn trừ 100% phí khám nếu thực hiện mổ.', N'Gói khám tiền phẫu bắt buộc để đánh giá mắt đủ điều kiện phẫu thuật khúc xạ (Femto-LASIK, ReLEx SMILE). Toàn bộ phí khám 500.000đ sẽ được trừ 100% vào chi phí ca mổ nếu quý khách tiến hành phẫu thuật.', N'services/service-lasik-consult.jpg', NULL, NULL)
INSERT [dbo].[Service_Catalog] ([Service_ID], [Service_Code], [Service_Name], [Price], [Category], [Summary], [Description], [Image_Path], [Image_Data], [Image_Mime_Type]) VALUES (4, N'PE-04', N'Khám mắt trẻ em và tư vấn nhược thị', CAST(300000 AS Decimal(18, 0)), N'Khám và tư vấn', N'Sàng lọc sớm các tật khúc xạ tiến triển, tật lé và suy giảm thị lực ở trẻ nhỏ.', N'Sàng lọc cận thị sớm, điều trị nhược thị và lác mắt trong không gian khám thân thiện.', N'services/service-pediatric.jpg', NULL, NULL)
INSERT [dbo].[Service_Catalog] ([Service_ID], [Service_Code], [Service_Name], [Price], [Category], [Summary], [Description], [Image_Path], [Image_Data], [Image_Mime_Type]) VALUES (5, N'TT-05', N'Khám tầm soát & Tư vấn phẫu thuật Phaco (Đục thủy tinh thể)', CAST(300000 AS Decimal(18, 0)), N'Khám và tư vấn', N'Kiểm tra mức độ đục thể thủy tinh, đo công suất thể thủy tinh nhân tạo và tư vấn phẫu thuật Phaco. Hoàn trừ 100% phí khám nếu thực hiện mổ.', N'Khám sàng lọc và tư vấn phẫu thuật Phaco đặt kính nội nhãn. Toàn bộ phí khám được khấu trừ 100% vào chi phí ca mổ khi thực hiện phẫu thuật.', N'departments-5.jpg', NULL, NULL)
INSERT [dbo].[Service_Catalog] ([Service_ID], [Service_Code], [Service_Name], [Price], [Category], [Summary], [Description], [Image_Path], [Image_Data], [Image_Mime_Type]) VALUES (6, N'GL-06', N'Đo nhãn áp & Tầm soát Glaucoma', CAST(250000 AS Decimal(18, 0)), N'Khám và tư vấn', N'Kiểm tra áp lực nhãn cầu, soi góc tiền phòng và tầm soát phát hiện sớm bệnh lý thiên đầu thống (Glaucoma).', N'Tầm soát và can thiệp bệnh Glaucoma, thoái hóa hoàng điểm và tổn thương võng mạc với hệ thống OCT.', N'services/service-glaucoma.jpg', NULL, NULL)
INSERT [dbo].[Service_Catalog] ([Service_ID], [Service_Code], [Service_Name], [Price], [Category], [Summary], [Description], [Image_Path], [Image_Data], [Image_Mime_Type]) VALUES (7, N'KX-MAY', N'Đo khúc xạ máy', CAST(100000 AS Decimal(18, 0)), N'Kiểm tra và chẩn đoán', N'Đo độ khúc xạ bằng máy đo tự động kỹ thuật số.', NULL, N'services/service-autorefraction.jpg', NULL, NULL)
INSERT [dbo].[Service_Catalog] ([Service_ID], [Service_Code], [Service_Name], [Price], [Category], [Summary], [Description], [Image_Path], [Image_Data], [Image_Mime_Type]) VALUES (8, N'OCT-DM', N'Chụp OCT đáy mắt', CAST(400000 AS Decimal(18, 0)), N'Kiểm tra và chẩn đoán', N'Chụp cắt lớp quang học võng mạc, gai thị độ phân giải cao.', NULL, N'services/service-retina.jpg', NULL, NULL)
INSERT [dbo].[Service_Catalog] ([Service_ID], [Service_Code], [Service_Name], [Price], [Category], [Summary], [Description], [Image_Path], [Image_Data], [Image_Mime_Type]) VALUES (9, N'KM-CVS', N'Khám & Điều trị Khô mắt (Hội chứng màn hình)', CAST(200000 AS Decimal(18, 0)), N'Khám và tư vấn', N'Đo màng phim nước mắt, kiểm tra tuyến Meibomius và điều trị khô rát mỏi mắt do sử dụng máy tính, điện thoại kéo dài.', N'Gói khám và phục hồi mắt chuyên sâu cho nhân viên văn phòng, học sinh sinh viên thường xuyên tiếp xúc màn hình điện tử.', N'services/service-dry-eye.jpg', NULL, NULL)
INSERT [dbo].[Service_Catalog] ([Service_ID], [Service_Code], [Service_Name], [Price], [Category], [Summary], [Description], [Image_Path], [Image_Data], [Image_Mime_Type]) VALUES (10, N'KM-DM', N'Khám & Tầm soát Đáy mắt - Võng mạc tiểu đường', CAST(300000 AS Decimal(18, 0)), N'Khám và tư vấn', N'Chụp màu đáy mắt, soi võng mạc tầm soát biến chứng xuất huyết võng mạc ở người tiểu đường và cao huyết áp.', N'Quy trình chẩn đoán chuyên sâu giúp phát hiện sớm và can thiệp kịp thời các tổn thương võng mạc do đái tháo đường.', N'services/service-fundus.jpg', NULL, NULL)
INSERT [dbo].[Service_Catalog] ([Service_ID], [Service_Code], [Service_Name], [Price], [Category], [Summary], [Description], [Image_Path], [Image_Data], [Image_Mime_Type]) VALUES (11, N'PT-LASIK', N'Phẫu thuật Femto-LASIK hai mắt', CAST(18000000 AS Decimal(18, 0)), N'Điều trị và thủ thuật', N'Phẫu thuật khúc xạ không dao Femtosecond Laser chính xác, phục hồi thị lực nhanh 10/10.', N'Phương pháp xóa cận viễn loạn hiện đại, an toàn, không đau, thời gian thực hiện chỉ 15 phút.', N'services/service-lasik.jpg', NULL, NULL)
INSERT [dbo].[Service_Catalog] ([Service_ID], [Service_Code], [Service_Name], [Price], [Category], [Summary], [Description], [Image_Path], [Image_Data], [Image_Mime_Type]) VALUES (12, N'PT-SMILE', N'Phẫu thuật ReLEx SMILE xóa cận', CAST(42000000 AS Decimal(18, 0)), N'Điều trị và thủ thuật', N'Công nghệ phẫu thuật khúc xạ không vạt tiên tiến nhất, đường rạch siêu nhỏ 2mm bảo tồn giác mạc tối đa.', N'Kỹ thuật rút lõi mô giác mạc bằng công nghệ VisuMax từ Đức, giảm thiểu tối đa khô mắt sau mổ.', N'gallery/gallery-1.jpg', NULL, NULL)
INSERT [dbo].[Service_Catalog] ([Service_ID], [Service_Code], [Service_Name], [Price], [Category], [Summary], [Description], [Image_Path], [Image_Data], [Image_Mime_Type]) VALUES (13, N'PT-PHACO', N'Phẫu thuật Phaco đặt thủy tinh thể nhân tạo', CAST(12000000 AS Decimal(18, 0)), N'Điều trị và thủ thuật', N'Tán nhuyễn thể thủy tinh đục bằng sóng siêu âm Phaco và đặt thể thủy tinh nhân tạo cao cấp đường mổ 2.2mm.', N'Ca phẫu thuật nhanh chóng 10-15 phút, xuất viện trong ngày, khôi phục thị lực sáng rõ cho người cao tuổi.', N'services/service-cataract.jpg', NULL, NULL)
INSERT [dbo].[Service_Catalog] ([Service_ID], [Service_Code], [Service_Name], [Price], [Category], [Summary], [Description], [Image_Path], [Image_Data], [Image_Mime_Type]) VALUES (14, N'TP-LEO', N'Chích rạch chắp lẹo mi mắt', CAST(250000 AS Decimal(18, 0)), N'Điều trị và thủ thuật', N'Tiểu phẫu dẫn lưu ổ viêm chắp lẹo mí mắt an toàn, vô trùng, hạn chế tái phát và đảm bảo thẩm mỹ.', N'Thực hiện thủ thuật tại phòng tiểu phẫu vô khuẩn.', N'gallery/gallery-6.jpg', NULL, NULL)
INSERT [dbo].[Service_Catalog] ([Service_ID], [Service_Code], [Service_Name], [Price], [Category], [Summary], [Description], [Image_Path], [Image_Data], [Image_Mime_Type]) VALUES (15, N'TP-LEDAO', N'Bơm thông rửa lệ đạo', CAST(300000 AS Decimal(18, 0)), N'Điều trị và thủ thuật', N'Thông tắc đường dẫn lệ giải quyết triệt để triệu chứng chảy nước mắt sống và viêm túi lệ mạn tính.', N'Quy trình thông rửa nhẹ nhàng với dụng cụ chuyên dụng.', N'gallery/gallery-8.jpg', NULL, NULL)
INSERT [dbo].[Service_Catalog] ([Service_ID], [Service_Code], [Service_Name], [Price], [Category], [Summary], [Description], [Image_Path], [Image_Data], [Image_Mime_Type]) VALUES (16, N'TP-YAG', N'Bắn Laser YAG bao sau đục', CAST(1500000 AS Decimal(18, 0)), N'Điều trị và thủ thuật', N'Thủ thuật laser ngoại trú làm trong suốt lại bao sau thể thủy tinh sau phẫu thuật Phaco.', N'Không phẫu thuật, chỉ mất 5 phút, thị lực sáng rõ trở lại ngay sau khi bắn laser.', N'services/service-procedure.jpg', NULL, NULL)
SET IDENTITY_INSERT [dbo].[Service_Catalog] OFF
GO

-- -----------------------------------------------------
-- Data: [Room] (9 rows)
-- -----------------------------------------------------
SET IDENTITY_INSERT [dbo].[Room] ON 

INSERT [dbo].[Room] ([Room_ID], [Room_Name]) VALUES (2, N'Phòng Khám Đo Khúc xạ & Kính')
INSERT [dbo].[Room] ([Room_ID], [Room_Name]) VALUES (5, N'Phòng Khám Đục thủy tinh thể (Phaco)')
INSERT [dbo].[Room] ([Room_ID], [Room_Name]) VALUES (6, N'Phòng Khám Glaucoma & Võng mạc')
INSERT [dbo].[Room] ([Room_ID], [Room_Name]) VALUES (1, N'Phòng Khám Nhãn khoa tổng quát')
INSERT [dbo].[Room] ([Room_ID], [Room_Name]) VALUES (4, N'Phòng Khám Nhãn khoa trẻ em & Nhược thị')
INSERT [dbo].[Room] ([Room_ID], [Room_Name]) VALUES (3, N'Phòng Khám Phẫu thuật LASIK')
INSERT [dbo].[Room] ([Room_ID], [Room_Name]) VALUES (7, N'Phòng Tiểu Phẫu 1')
INSERT [dbo].[Room] ([Room_ID], [Room_Name]) VALUES (8, N'Phòng Tiểu Phẫu 2')
INSERT [dbo].[Room] ([Room_ID], [Room_Name]) VALUES (9, N'Phòng Tiểu Phẫu 3')
SET IDENTITY_INSERT [dbo].[Room] OFF
GO

-- -----------------------------------------------------
-- Data: [Work_Schedule] (71 rows)
-- -----------------------------------------------------
SET IDENTITY_INSERT [dbo].[Work_Schedule] ON 

INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (1, 3, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'08:00:00' AS Time), CAST(N'08:30:00' AS Time), N'Slot 1', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (2, 3, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'08:30:00' AS Time), CAST(N'09:00:00' AS Time), N'Slot 2', N'Booked')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (3, 3, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'09:00:00' AS Time), CAST(N'09:30:00' AS Time), N'Slot 3', N'Booked')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (4, 3, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'09:30:00' AS Time), CAST(N'10:00:00' AS Time), N'Slot 4', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (5, 3, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'10:00:00' AS Time), CAST(N'10:30:00' AS Time), N'Slot 5', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (6, 3, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'10:30:00' AS Time), CAST(N'11:00:00' AS Time), N'Slot 6', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (7, 3, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'11:00:00' AS Time), CAST(N'11:30:00' AS Time), N'Slot 7', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (8, 3, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'13:30:00' AS Time), CAST(N'14:00:00' AS Time), N'Slot 8', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (9, 3, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'14:00:00' AS Time), CAST(N'14:30:00' AS Time), N'Slot 9', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (10, 3, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'14:30:00' AS Time), CAST(N'15:00:00' AS Time), N'Slot 10', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (11, 3, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'15:00:00' AS Time), CAST(N'15:30:00' AS Time), N'Slot 11', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (12, 3, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'15:30:00' AS Time), CAST(N'16:00:00' AS Time), N'Slot 12', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (13, 3, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'16:00:00' AS Time), CAST(N'16:30:00' AS Time), N'Slot 13', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (14, 3, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'16:30:00' AS Time), CAST(N'17:00:00' AS Time), N'Slot 14', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (15, 3, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'17:00:00' AS Time), CAST(N'17:30:00' AS Time), N'Slot 15', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (16, 4, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'08:00:00' AS Time), CAST(N'08:30:00' AS Time), N'Slot 1', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (17, 4, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'08:30:00' AS Time), CAST(N'09:00:00' AS Time), N'Slot 2', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (18, 4, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'09:00:00' AS Time), CAST(N'09:30:00' AS Time), N'Slot 3', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (19, 4, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'09:30:00' AS Time), CAST(N'10:00:00' AS Time), N'Slot 4', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (20, 4, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'10:00:00' AS Time), CAST(N'10:30:00' AS Time), N'Slot 5', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (21, 4, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'10:30:00' AS Time), CAST(N'11:00:00' AS Time), N'Slot 6', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (22, 4, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'11:00:00' AS Time), CAST(N'11:30:00' AS Time), N'Slot 7', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (23, 4, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'13:30:00' AS Time), CAST(N'14:00:00' AS Time), N'Slot 8', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (24, 4, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'14:00:00' AS Time), CAST(N'14:30:00' AS Time), N'Slot 9', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (25, 4, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'14:30:00' AS Time), CAST(N'15:00:00' AS Time), N'Slot 10', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (26, 5, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'08:00:00' AS Time), CAST(N'08:30:00' AS Time), N'Slot 1', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (27, 5, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'08:30:00' AS Time), CAST(N'09:00:00' AS Time), N'Slot 2', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (28, 5, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'09:00:00' AS Time), CAST(N'09:30:00' AS Time), N'Slot 3', N'Booked')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (29, 5, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'09:30:00' AS Time), CAST(N'10:00:00' AS Time), N'Slot 4', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (30, 5, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'10:00:00' AS Time), CAST(N'10:30:00' AS Time), N'Slot 5', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (31, 5, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'10:30:00' AS Time), CAST(N'11:00:00' AS Time), N'Slot 6', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (32, 5, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'11:00:00' AS Time), CAST(N'11:30:00' AS Time), N'Slot 7', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (33, 5, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'13:30:00' AS Time), CAST(N'14:00:00' AS Time), N'Slot 8', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (34, 5, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'14:00:00' AS Time), CAST(N'14:30:00' AS Time), N'Slot 9', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (35, 5, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'14:30:00' AS Time), CAST(N'15:00:00' AS Time), N'Slot 10', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (36, 6, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'08:00:00' AS Time), CAST(N'08:30:00' AS Time), N'Slot 1', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (37, 6, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'08:30:00' AS Time), CAST(N'09:00:00' AS Time), N'Slot 2', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (38, 6, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'09:00:00' AS Time), CAST(N'09:30:00' AS Time), N'Slot 3', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (39, 6, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'09:30:00' AS Time), CAST(N'10:00:00' AS Time), N'Slot 4', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (40, 6, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'10:00:00' AS Time), CAST(N'10:30:00' AS Time), N'Slot 5', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (41, 6, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'10:30:00' AS Time), CAST(N'11:00:00' AS Time), N'Slot 6', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (42, 6, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'11:00:00' AS Time), CAST(N'11:30:00' AS Time), N'Slot 7', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (43, 6, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'13:30:00' AS Time), CAST(N'14:00:00' AS Time), N'Slot 8', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (44, 6, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'14:00:00' AS Time), CAST(N'14:30:00' AS Time), N'Slot 9', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (45, 6, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'14:30:00' AS Time), CAST(N'15:00:00' AS Time), N'Slot 10', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (46, 7, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'08:00:00' AS Time), CAST(N'08:30:00' AS Time), N'Slot 1', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (47, 7, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'08:30:00' AS Time), CAST(N'09:00:00' AS Time), N'Slot 2', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (48, 7, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'09:00:00' AS Time), CAST(N'09:30:00' AS Time), N'Slot 3', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (49, 7, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'09:30:00' AS Time), CAST(N'10:00:00' AS Time), N'Slot 4', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (50, 7, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'10:00:00' AS Time), CAST(N'10:30:00' AS Time), N'Slot 5', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (51, 7, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'10:30:00' AS Time), CAST(N'11:00:00' AS Time), N'Slot 6', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (52, 7, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'11:00:00' AS Time), CAST(N'11:30:00' AS Time), N'Slot 7', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (53, 7, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'13:30:00' AS Time), CAST(N'14:00:00' AS Time), N'Slot 8', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (54, 7, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'14:00:00' AS Time), CAST(N'14:30:00' AS Time), N'Slot 9', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (55, 7, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'14:30:00' AS Time), CAST(N'15:00:00' AS Time), N'Slot 10', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (56, 8, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'08:00:00' AS Time), CAST(N'08:30:00' AS Time), N'Slot 1', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (57, 8, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'08:30:00' AS Time), CAST(N'09:00:00' AS Time), N'Slot 2', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (58, 8, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'09:00:00' AS Time), CAST(N'09:30:00' AS Time), N'Slot 3', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (59, 8, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'09:30:00' AS Time), CAST(N'10:00:00' AS Time), N'Slot 4', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (60, 8, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'10:00:00' AS Time), CAST(N'10:30:00' AS Time), N'Slot 5', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (61, 8, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'10:30:00' AS Time), CAST(N'11:00:00' AS Time), N'Slot 6', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (62, 8, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'11:00:00' AS Time), CAST(N'11:30:00' AS Time), N'Slot 7', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (63, 8, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'13:30:00' AS Time), CAST(N'14:00:00' AS Time), N'Slot 8', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (64, 8, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'14:00:00' AS Time), CAST(N'14:30:00' AS Time), N'Slot 9', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (65, 8, NULL, NULL, CAST(N'2026-10-18' AS Date), CAST(N'14:30:00' AS Time), CAST(N'15:00:00' AS Time), N'Slot 10', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (66, NULL, 9, NULL, CAST(N'2026-10-18' AS Date), CAST(N'08:00:00' AS Time), CAST(N'08:30:00' AS Time), N'Slot 1', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (67, NULL, 9, NULL, CAST(N'2026-10-18' AS Date), CAST(N'08:30:00' AS Time), CAST(N'09:00:00' AS Time), N'Slot 2', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (68, NULL, 10, NULL, CAST(N'2026-10-18' AS Date), CAST(N'08:00:00' AS Time), CAST(N'08:30:00' AS Time), N'Slot 1', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (69, NULL, 10, NULL, CAST(N'2026-10-18' AS Date), CAST(N'08:30:00' AS Time), CAST(N'09:00:00' AS Time), N'Slot 2', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (70, NULL, 11, NULL, CAST(N'2026-10-18' AS Date), CAST(N'08:00:00' AS Time), CAST(N'08:30:00' AS Time), N'Slot 1', N'Available')
INSERT [dbo].[Work_Schedule] ([Schedule_ID], [Doctor_Employee_ID], [Specialist_Employee_ID], [Staff_Employee_ID], [Work_Date], [Start_Time], [End_Time], [Slot], [Status]) VALUES (71, NULL, 11, NULL, CAST(N'2026-10-18' AS Date), CAST(N'08:30:00' AS Time), CAST(N'09:00:00' AS Time), N'Slot 2', N'Available')
SET IDENTITY_INSERT [dbo].[Work_Schedule] OFF
GO

-- -----------------------------------------------------
-- Data: [Patient] (11 rows)
-- -----------------------------------------------------
SET IDENTITY_INSERT [dbo].[Patient] ON 

INSERT [dbo].[Patient] ([Patient_ID], [Account_ID], [Full_Name], [Phone], [DOB], [Address]) VALUES (1, 13, N'Nguyễn Văn An', N'0901234567', CAST(N'1995-05-15' AS Date), N'123 Lê Lợi, Q.1, TP.HCM')
INSERT [dbo].[Patient] ([Patient_ID], [Account_ID], [Full_Name], [Phone], [DOB], [Address]) VALUES (2, NULL, N'Trần Thị Bình', N'0918765432', CAST(N'1988-10-20' AS Date), N'456 Nguyễn Huệ, Q.1, TP.HCM')
INSERT [dbo].[Patient] ([Patient_ID], [Account_ID], [Full_Name], [Phone], [DOB], [Address]) VALUES (3, 14, N'Đặng Thùy Linh', N'0933112233', CAST(N'1998-08-12' AS Date), N'78 Nguyễn Trãi, Q.5, TP.HCM')
INSERT [dbo].[Patient] ([Patient_ID], [Account_ID], [Full_Name], [Phone], [DOB], [Address]) VALUES (4, 15, N'Hoàng Minh Tuấn', N'0977889900', CAST(N'1985-03-24' AS Date), N'154 Hai Bà Trưng, Q.3, TP.HCM')
INSERT [dbo].[Patient] ([Patient_ID], [Account_ID], [Full_Name], [Phone], [DOB], [Address]) VALUES (5, 16, N'Lê Thị Ngọc Mai', N'0966554433', CAST(N'2002-11-05' AS Date), N'45 Xô Viết Nghệ Tĩnh, Bình Thạnh, TP.HCM')
INSERT [dbo].[Patient] ([Patient_ID], [Account_ID], [Full_Name], [Phone], [DOB], [Address]) VALUES (6, 17, N'Vũ Trọng Đức', N'0912334455', CAST(N'1970-07-19' AS Date), N'210 Điện Biên Phủ, Q.3, TP.HCM')
INSERT [dbo].[Patient] ([Patient_ID], [Account_ID], [Full_Name], [Phone], [DOB], [Address]) VALUES (7, NULL, N'Bùi Quốc Anh (Bé)', N'0988776655', CAST(N'2015-09-10' AS Date), N'12 Hoàng Diệu, Q.4, TP.HCM')
INSERT [dbo].[Patient] ([Patient_ID], [Account_ID], [Full_Name], [Phone], [DOB], [Address]) VALUES (8, NULL, N'Phạm Thanh Thảo', N'0909112244', CAST(N'1992-06-30' AS Date), N'89 Cách Mạng Tháng 8, Q.10, TP.HCM')
INSERT [dbo].[Patient] ([Patient_ID], [Account_ID], [Full_Name], [Phone], [DOB], [Address]) VALUES (9, NULL, N'Ngô Đình Cường', N'0944556677', CAST(N'1963-04-18' AS Date), N'33 Nam Kỳ Khởi Nghĩa, Q.1, TP.HCM')
INSERT [dbo].[Patient] ([Patient_ID], [Account_ID], [Full_Name], [Phone], [DOB], [Address]) VALUES (10, NULL, N'Đỗ Bảo Châu (Bé)', N'0938445566', CAST(N'2017-02-14' AS Date), N'66 Lê Văn Sỹ, Phú Nhuận, TP.HCM')
INSERT [dbo].[Patient] ([Patient_ID], [Account_ID], [Full_Name], [Phone], [DOB], [Address]) VALUES (11, NULL, N'Nguyễn Hữu Nghĩa', N'0919223344', CAST(N'1990-12-08' AS Date), N'102 Pasteur, Q.1, TP.HCM')
SET IDENTITY_INSERT [dbo].[Patient] OFF
GO

-- -----------------------------------------------------
-- Data: [Appointment] (29 rows)
-- -----------------------------------------------------
SET IDENTITY_INSERT [dbo].[Appointment] ON 

INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (1, 1, 1, 12, N'Completed', CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2), CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2))
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (2, 2, 2, 12, N'Pending', CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2), NULL)
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (3, 1, 3, 12, N'Pending', CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2), NULL)
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (4, 3, 4, 12, N'Completed', CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2), CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2))
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (5, 4, 5, 12, N'Completed', CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2), CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2))
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (6, 1, 6, 12, N'Confirmed', CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2), CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2))
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (7, 5, 7, 12, N'Pending', CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2), NULL)
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (8, 5, 16, 12, N'Completed', CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2), CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2))
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (9, 1, 17, 12, N'Completed', CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2), CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2))
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (10, 8, 18, 12, N'Confirmed', CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2), CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2))
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (11, 11, 26, 12, N'Completed', CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2), CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2))
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (12, 3, 27, 12, N'In_Progress', CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2), CAST(N'2026-10-18T14:15:47.2916969' AS DateTime2))
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (13, 4, 28, 12, N'Pending', CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2), NULL)
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (14, 7, 36, 12, N'Completed', CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2), CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2))
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (15, 10, 37, 12, N'Completed', CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2), CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2))
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (16, 7, 38, 12, N'Confirmed', CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2), CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2))
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (17, 9, 46, 12, N'Completed', CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2), CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2))
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (18, 6, 47, 12, N'Confirmed', CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2), CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2))
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (19, 6, 56, 12, N'Completed', CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2), CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2))
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (20, 9, 57, 12, N'Confirmed', CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2), CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2))
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (21, 2, 8, 12, N'Canceled', CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2), NULL)
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (22, 1, 2, NULL, N'Pending', CAST(N'2026-10-18T14:39:56.1444096' AS DateTime2), NULL)
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (23, 1, 3, NULL, N'Confirmed', CAST(N'2026-10-18T14:54:14.6824054' AS DateTime2), NULL)
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (24, 1, 2, NULL, N'Pending', CAST(N'2026-10-18T15:00:59.6598251' AS DateTime2), NULL)
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (25, 1, 28, NULL, N'Pending', CAST(N'2026-10-18T15:09:08.2392222' AS DateTime2), NULL)
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (26, 1, 28, NULL, N'Confirmed', CAST(N'2026-10-18T15:28:30.7760424' AS DateTime2), NULL)
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (27, 1, 58, NULL, N'Pending', CAST(N'2026-10-18T15:33:51.3330171' AS DateTime2), NULL)
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (28, 1, 59, NULL, N'Pending', CAST(N'2026-10-18T15:35:18.7626400' AS DateTime2), NULL)
INSERT [dbo].[Appointment] ([Appointment_ID], [Patient_ID], [Schedule_ID], [Staff_Employee_ID], [Status], [created_at], [checkin_time]) VALUES (29, 1, 2, NULL, N'Confirmed', CAST(N'2026-10-18T15:40:01.4183777' AS DateTime2), NULL)
SET IDENTITY_INSERT [dbo].[Appointment] OFF
GO

-- -----------------------------------------------------
-- Data: [Master_Invoice] (28 rows)
-- -----------------------------------------------------
SET IDENTITY_INSERT [dbo].[Master_Invoice] ON 

INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (1, 1, CAST(300000 AS Decimal(18, 0)), CAST(100000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), N'Paid', CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2), CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2))
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (2, 3, CAST(250000 AS Decimal(18, 0)), CAST(200000 AS Decimal(18, 0)), CAST(50000 AS Decimal(18, 0)), N'Pending_Deposit', CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2), NULL)
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (3, 4, CAST(250000 AS Decimal(18, 0)), CAST(200000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), N'Paid', CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2), CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2))
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (4, 5, CAST(250000 AS Decimal(18, 0)), CAST(200000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), N'Paid', CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2), CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2))
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (5, 6, CAST(250000 AS Decimal(18, 0)), CAST(200000 AS Decimal(18, 0)), CAST(50000 AS Decimal(18, 0)), N'Partial_Paid', CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2), CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2))
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (6, 7, CAST(250000 AS Decimal(18, 0)), CAST(200000 AS Decimal(18, 0)), CAST(250000 AS Decimal(18, 0)), N'Pending_Deposit', CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2), NULL)
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (7, 8, CAST(150000 AS Decimal(18, 0)), CAST(150000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), N'Paid', CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2), CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2))
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (8, 9, CAST(150000 AS Decimal(18, 0)), CAST(150000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), N'Paid', CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2), CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2))
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (9, 10, CAST(150000 AS Decimal(18, 0)), CAST(150000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), N'Paid', CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2), CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2))
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (10, 11, CAST(18000000 AS Decimal(18, 0)), CAST(18000000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), N'Paid', CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2), CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2))
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (11, 12, CAST(18000000 AS Decimal(18, 0)), CAST(200000 AS Decimal(18, 0)), CAST(17800000 AS Decimal(18, 0)), N'Partial_Paid', CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2), CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2))
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (12, 13, CAST(18000000 AS Decimal(18, 0)), CAST(200000 AS Decimal(18, 0)), CAST(18000000 AS Decimal(18, 0)), N'Pending_Deposit', CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2), NULL)
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (13, 14, CAST(300000 AS Decimal(18, 0)), CAST(300000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), N'Paid', CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2), CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2))
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (14, 15, CAST(300000 AS Decimal(18, 0)), CAST(300000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), N'Paid', CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2), CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2))
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (15, 16, CAST(300000 AS Decimal(18, 0)), CAST(200000 AS Decimal(18, 0)), CAST(100000 AS Decimal(18, 0)), N'Partial_Paid', CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2), CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2))
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (16, 17, CAST(12000000 AS Decimal(18, 0)), CAST(12000000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), N'Paid', CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2), CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2))
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (17, 18, CAST(12000000 AS Decimal(18, 0)), CAST(200000 AS Decimal(18, 0)), CAST(11800000 AS Decimal(18, 0)), N'Partial_Paid', CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2), CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2))
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (18, 19, CAST(500000 AS Decimal(18, 0)), CAST(500000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), N'Paid', CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2), CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2))
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (19, 20, CAST(500000 AS Decimal(18, 0)), CAST(200000 AS Decimal(18, 0)), CAST(300000 AS Decimal(18, 0)), N'Partial_Paid', CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2), CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2))
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (20, 21, CAST(250000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), N'Canceled', CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2), NULL)
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (21, 22, CAST(200000 AS Decimal(18, 0)), CAST(200000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), N'Pending_Deposit', CAST(N'2026-10-18T14:39:56.1484255' AS DateTime2), NULL)
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (22, 23, CAST(200000 AS Decimal(18, 0)), CAST(200000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), N'Paid', CAST(N'2026-10-18T14:54:14.6884055' AS DateTime2), CAST(N'2026-10-18T14:54:19.5042287' AS DateTime2))
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (23, 24, CAST(200000 AS Decimal(18, 0)), CAST(200000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), N'Pending_Deposit', CAST(N'2026-10-18T15:00:59.6651289' AS DateTime2), NULL)
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (24, 25, CAST(500000 AS Decimal(18, 0)), CAST(500000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), N'Pending_Deposit', CAST(N'2026-10-18T15:09:08.2436887' AS DateTime2), NULL)
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (25, 26, CAST(500000 AS Decimal(18, 0)), CAST(500000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), N'Paid', CAST(N'2026-10-18T15:28:30.7800445' AS DateTime2), CAST(N'2026-10-18T15:29:34.0943582' AS DateTime2))
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (26, 27, CAST(300000 AS Decimal(18, 0)), CAST(300000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), N'Pending_Deposit', CAST(N'2026-10-18T15:33:51.3370210' AS DateTime2), NULL)
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (27, 28, CAST(300000 AS Decimal(18, 0)), CAST(300000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), N'Pending_Deposit', CAST(N'2026-10-18T15:35:18.7666395' AS DateTime2), NULL)
INSERT [dbo].[Master_Invoice] ([Invoice_ID], [Appointment_ID], [Total_Amount], [Deposit_Amount], [Balance_Due], [Status], [Create_At], [Close_At]) VALUES (28, 29, CAST(200000 AS Decimal(18, 0)), CAST(200000 AS Decimal(18, 0)), CAST(0 AS Decimal(18, 0)), N'Paid', CAST(N'2026-10-18T15:40:01.4223791' AS DateTime2), CAST(N'2026-10-18T15:43:01.2838460' AS DateTime2))
SET IDENTITY_INSERT [dbo].[Master_Invoice] OFF
GO

-- -----------------------------------------------------
-- Data: [Payment_Transaction] (6 rows)
-- -----------------------------------------------------
SET IDENTITY_INSERT [dbo].[Payment_Transaction] ON 

INSERT [dbo].[Payment_Transaction] ([Transaction_ID], [Invoice_ID], [Amount], [Gateway_Status], [Trans_Date], [Payment_Gateway]) VALUES (1, 1, CAST(100000 AS Decimal(18, 0)), N'Success', CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2), N'VNPay')
INSERT [dbo].[Payment_Transaction] ([Transaction_ID], [Invoice_ID], [Amount], [Gateway_Status], [Trans_Date], [Payment_Gateway]) VALUES (2, 1, CAST(200000 AS Decimal(18, 0)), N'Success', CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2), N'Cash')
INSERT [dbo].[Payment_Transaction] ([Transaction_ID], [Invoice_ID], [Amount], [Gateway_Status], [Trans_Date], [Payment_Gateway]) VALUES (3, 22, CAST(200000 AS Decimal(18, 0)), N'Success', CAST(N'2026-10-18T14:54:18.4000816' AS DateTime2), N'VietQR_Banking')
INSERT [dbo].[Payment_Transaction] ([Transaction_ID], [Invoice_ID], [Amount], [Gateway_Status], [Trans_Date], [Payment_Gateway]) VALUES (4, 22, CAST(200000 AS Decimal(18, 0)), N'Success', CAST(N'2026-10-18T14:54:19.5086844' AS DateTime2), N'VietQR_Banking')
INSERT [dbo].[Payment_Transaction] ([Transaction_ID], [Invoice_ID], [Amount], [Gateway_Status], [Trans_Date], [Payment_Gateway]) VALUES (5, 25, CAST(500000 AS Decimal(18, 0)), N'Success', CAST(N'2026-10-18T15:29:34.0963585' AS DateTime2), N'VietQR_Banking')
INSERT [dbo].[Payment_Transaction] ([Transaction_ID], [Invoice_ID], [Amount], [Gateway_Status], [Trans_Date], [Payment_Gateway]) VALUES (6, 28, CAST(200000 AS Decimal(18, 0)), N'Success', CAST(N'2026-10-18T15:43:01.2868457' AS DateTime2), N'VietQR_Banking')
SET IDENTITY_INSERT [dbo].[Payment_Transaction] OFF
GO

-- -----------------------------------------------------
-- Data: [Medical_Record] (28 rows)
-- -----------------------------------------------------
SET IDENTITY_INSERT [dbo].[Medical_Record] ON 

INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (1, 1, 3, N'Mắt phải cận thị 1.5 độ, viêm kết mạc nhẹ', NULL, NULL, CAST(N'2026-10-18T08:19:54.6561348' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (2, 3, 3, N'Dịch vụ/Bệnh lý: Khám mắt tổng quát', NULL, NULL, CAST(N'2026-10-18T08:19:54.6561348' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (3, 4, 3, N'Dịch vụ: Khám mắt tổng quát | Lý do: Khô rát mắt, nhìn màn hình máy tính mỏi mắt', N'Khô mắt độ 1 cả hai mắt, hội chứng thị giác màn hình (CVS). Thị lực OD 10/10, OS 10/10, nhãn áp bình thường.', N'Hạn chế nhìn màn hình liên tục >45 phút không nghỉ, chớp mắt thường xuyên. Nhỏ nước mắt nhân tạo hàng ngày.', CAST(N'2026-10-18T08:19:54.6561348' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (4, 5, 3, N'Dịch vụ: Khám mắt tổng quát | Lý do: Cộm xốn mắt trái, mi mắt sưng đỏ', N'Viêm bờ mi mạn tính, xước biểu mô giác mạc nông mắt trái do dị vật cọ xát. Thị lực OD 10/10, OS 8/10.', N'Vệ sinh bờ mi bằng gạc ấm mỗi sáng và tối. Dùng thuốc nhỏ kháng sinh và chất làm ẩm bảo vệ giác mạc. Tái khám sau 5 ngày.', CAST(N'2026-10-18T08:19:54.6561348' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (5, 6, 3, N'Dịch vụ: Khám mắt tổng quát | Lý do: Tái khám định kỳ sau điều trị viêm kết mạc', NULL, NULL, CAST(N'2026-10-18T08:19:54.6561348' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (6, 7, 3, N'Dịch vụ: Khám mắt tổng quát | Lý do: Khám sức khỏe định kỳ cho sinh viên', NULL, NULL, CAST(N'2026-10-18T08:19:54.6561348' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (7, 8, 4, N'Dịch vụ: Đo khúc xạ và tư vấn kính | Lý do: Mắt nhìn mờ bảng đen, nhức đầu khi đọc sách', N'Cận thị tiến triển: OD -2.50D (thị lực chỉnh kính 10/10), OS -3.00D loạn 0.5D trục 180 (chỉnh kính 10/10).', N'Kê đơn kính mới chống ánh sáng xanh. Tư vấn tư thế ngồi học và giữ khoảng cách 35cm khi đọc sách.', CAST(N'2026-10-18T08:19:54.6561348' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (8, 9, 4, N'Dịch vụ: Đo khúc xạ và tư vấn kính | Lý do: Kiểm tra lại độ cận mắt kính cũ', N'Độ cận ổn định: OD -1.25D, OS -1.50D. Đáy mắt bình thường không tổn thương võng mạc.', N'Giữ nguyên độ kính hiện tại, không cần tăng độ. Tái kiểm tra khúc xạ sau 6 tháng.', CAST(N'2026-10-18T08:19:54.6561348' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (9, 10, 4, N'Dịch vụ: Đo khúc xạ và tư vấn kính | Lý do: Đo độ làm kính cận râm đi du lịch', NULL, NULL, CAST(N'2026-10-18T08:19:54.6561348' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (10, 11, 5, N'Dịch vụ: Phẫu thuật LASIK | Lý do: Muốn xóa cận thị cao để thi tuyển ngành công an', N'Cận thị 2 mắt OD -6.50D, OS -7.00D. Chiều dày giác mạc trung tâm 545µm. Đủ tiêu chuẩn phẫu thuật Femto-LASIK.', N'Phẫu thuật Femto-LASIK hai mắt thành công hoàn hảo. Thị lực không kính ngày 1 sau mổ: OD 10/10, OS 10/10.', CAST(N'2026-10-18T08:19:54.6561348' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (11, 12, 5, N'Dịch vụ: Phẫu thuật LASIK | Lý do: Khám tiền phẫu và đo bản đồ giác mạc xóa cận', NULL, NULL, CAST(N'2026-10-18T08:19:54.6561348' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (12, 13, 5, N'Dịch vụ: Phẫu thuật LASIK | Lý do: Tư vấn phẫu thuật Smile / Femto-Lasik', NULL, NULL, CAST(N'2026-10-18T08:19:54.6561348' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (13, 14, 6, N'Dịch vụ: Khám mắt trẻ em và tư vấn nhược thị | Lý do: Bé hay nheo mắt nghiêng đầu xem tivi', N'Nhược thị khúc xạ mắt trái do bất đồng khúc xạ: OD +0.75D (thị lực 9/10), OS +4.25D loạn 1.0D (thị lực 3/10).', N'Chỉ định đeo kính đúng độ liên tục. Áp dụng liệu pháp bịt mắt lành (mắt phải) 2 giờ mỗi ngày kết hợp tập thị giác. Tái khám sau 1 tháng.', CAST(N'2026-10-18T08:19:54.6561348' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (14, 15, 6, N'Dịch vụ: Khám mắt trẻ em và tư vấn nhược thị | Lý do: Bố mẹ phát hiện mắt bé thỉnh thoảng lé vào trong', N'Lác trong điều tiết một phần mắt phải góc 15 độ Hirschberg. Đáy mắt trong suốt, không u nguyên bào võng mạc.', N'Cho tra atropine giãn cơ thể mi và cấp kính điều chỉnh toàn phần. Hẹn đo lại góc lác sau 3 tuần đeo kính.', CAST(N'2026-10-18T08:19:54.6561348' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (15, 16, 6, N'Dịch vụ: Khám mắt trẻ em và tư vấn nhược thị | Lý do: Tái khám kiểm tra thị lực sau 1 tháng tập che mắt', NULL, NULL, CAST(N'2026-10-18T08:19:54.6561348' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (16, 17, 7, N'Dịch vụ: Phẫu thuật Phaco điều trị đục thủy tinh thể | Lý do: Mắt phải mờ như có màn sương che, chói mắt ban ngày', N'Đục thể thủy tinh người già nhân vỏ độ 3 mắt phải. Thị lực mắt phải đếm ngón tay 2m. Mắt trái đục nhẹ thị lực 6/10.', N'Thực hiện tán nhuyễn Phaco đặt thể thủy tinh nhân tạo đa tiêu mắt phải thành công. Thị lực sau mổ 1 ngày: OD 9/10.', CAST(N'2026-10-18T08:19:54.6561348' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (17, 18, 7, N'Dịch vụ: Phẫu thuật Phaco điều trị đục thủy tinh thể | Lý do: Khám tầm soát đục thủy tinh thể người cao tuổi', NULL, NULL, CAST(N'2026-10-18T08:19:54.6561348' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (18, 19, 8, N'Dịch vụ: Đo nhãn áp và chụp OCT võng mạc | Lý do: Nhức tức vùng hốc mắt, nhìn thấy quầng màu cầu vồng quanh đèn', N'Nghi ngờ Glaucoma góc mở. Nhãn áp OD 26 mmHg, OS 24 mmHg (giá trị cao). Hình ảnh OCT cho thấy lớp sợi thần kinh võng mạc khuyết nhẹ góc thái dương dưới.', N'Kê thuốc hạ nhãn áp, theo dõi sát thị trường mắt. Tuyệt đối không tự ý nhỏ các loại thuốc có chứa corticoid.', CAST(N'2026-10-18T08:19:54.6561348' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (19, 20, 8, N'Dịch vụ: Đo nhãn áp và chụp OCT võng mạc | Lý do: Tái khám định kỳ theo dõi nhãn áp sau điều trị', NULL, NULL, CAST(N'2026-10-18T08:19:54.6561348' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (20, 21, 3, N'Dịch vụ: Khám mắt tổng quát | Lý do: Bệnh nhân báo bận công tác đột xuất, xin hủy lịch khám', NULL, NULL, CAST(N'2026-10-18T08:19:54.6561348' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (21, 22, 3, N'Dịch vụ/Bệnh lý: Khám mắt tổng quát & Soi đáy mắt', NULL, NULL, CAST(N'2026-10-18T14:39:56.1534173' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (22, 23, 3, N'Dịch vụ/Bệnh lý: Khám mắt tổng quát & Soi đáy mắt', NULL, NULL, CAST(N'2026-10-18T14:54:14.6924021' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (23, 24, 3, N'Dịch vụ/Bệnh lý: Khám mắt tổng quát & Soi đáy mắt', NULL, NULL, CAST(N'2026-10-18T15:00:59.6681290' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (24, 25, 5, N'Dịch vụ/Bệnh lý: Khám tiền phẫu & Tư vấn xóa cận LASIK/SMILE', NULL, NULL, CAST(N'2026-10-18T15:09:08.2480067' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (25, 26, 5, N'Dịch vụ/Bệnh lý: Khám tiền phẫu & Tư vấn xóa cận LASIK/SMILE', NULL, NULL, CAST(N'2026-10-18T15:28:30.7850407' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (26, 27, 8, N'Dịch vụ/Bệnh lý: Khám & Tầm soát Đáy mắt - Võng mạc tiểu đường', NULL, NULL, CAST(N'2026-10-18T15:33:51.3400255' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (27, 28, 8, N'Dịch vụ/Bệnh lý: Khám & Tầm soát Đáy mắt - Võng mạc tiểu đường', NULL, NULL, CAST(N'2026-10-18T15:35:18.7696429' AS DateTime2))
INSERT [dbo].[Medical_Record] ([Record_ID], [Appointment_ID], [Doctor_Employee_ID], [Clinical_Diagnosis], [examination_result], [conclusion], [Created_At]) VALUES (28, 29, 3, N'Dịch vụ/Bệnh lý: Khám mắt tổng quát & Soi đáy mắt', NULL, NULL, CAST(N'2026-10-18T15:40:01.4243785' AS DateTime2))
SET IDENTITY_INSERT [dbo].[Medical_Record] OFF
GO

-- -----------------------------------------------------
-- Data: [Prescription] (10 rows)
-- -----------------------------------------------------
SET IDENTITY_INSERT [dbo].[Prescription] ON 

INSERT [dbo].[Prescription] ([Prescription_ID], [Record_ID], [Doctor_Notes], [created_at]) VALUES (1, 1, N'Nhỏ thuốc đúng giờ, tái khám sau 7 ngày nếu mắt còn đỏ', CAST(N'2026-10-18T08:19:54.6587122' AS DateTime2))
INSERT [dbo].[Prescription] ([Prescription_ID], [Record_ID], [Doctor_Notes], [created_at]) VALUES (2, 3, N'Hạn chế nhìn màn hình liên tục >45 phút không nghỉ, chớp mắt thường xuyên. Nhỏ nước mắt nhân tạo hàng ngày.', CAST(N'2026-10-18T08:19:54.6587122' AS DateTime2))
INSERT [dbo].[Prescription] ([Prescription_ID], [Record_ID], [Doctor_Notes], [created_at]) VALUES (3, 4, N'Vệ sinh bờ mi bằng gạc ấm mỗi sáng và tối. Dùng thuốc nhỏ kháng sinh và chất làm ẩm bảo vệ giác mạc. Tái khám sau 5 ngày.', CAST(N'2026-10-18T08:19:54.6587122' AS DateTime2))
INSERT [dbo].[Prescription] ([Prescription_ID], [Record_ID], [Doctor_Notes], [created_at]) VALUES (4, 7, N'Kê đơn kính mới chống ánh sáng xanh. Tư vấn tư thế ngồi học và giữ khoảng cách 35cm khi đọc sách.', CAST(N'2026-10-18T08:19:54.6587122' AS DateTime2))
INSERT [dbo].[Prescription] ([Prescription_ID], [Record_ID], [Doctor_Notes], [created_at]) VALUES (5, 8, N'Giữ nguyên độ kính hiện tại, không cần tăng độ. Tái kiểm tra khúc xạ sau 6 tháng.', CAST(N'2026-10-18T08:19:54.6587122' AS DateTime2))
INSERT [dbo].[Prescription] ([Prescription_ID], [Record_ID], [Doctor_Notes], [created_at]) VALUES (6, 10, N'Phẫu thuật Femto-LASIK hai mắt thành công hoàn hảo. Thị lực không kính ngày 1 sau mổ: OD 10/10, OS 10/10.', CAST(N'2026-10-18T08:19:54.6587122' AS DateTime2))
INSERT [dbo].[Prescription] ([Prescription_ID], [Record_ID], [Doctor_Notes], [created_at]) VALUES (7, 13, N'Chỉ định đeo kính đúng độ liên tục. Áp dụng liệu pháp bịt mắt lành (mắt phải) 2 giờ mỗi ngày kết hợp tập thị giác. Tái khám sau 1 tháng.', CAST(N'2026-10-18T08:19:54.6587122' AS DateTime2))
INSERT [dbo].[Prescription] ([Prescription_ID], [Record_ID], [Doctor_Notes], [created_at]) VALUES (8, 14, N'Cho tra atropine giãn cơ thể mi và cấp kính điều chỉnh toàn phần. Hẹn đo lại góc lác sau 3 tuần đeo kính.', CAST(N'2026-10-18T08:19:54.6587122' AS DateTime2))
INSERT [dbo].[Prescription] ([Prescription_ID], [Record_ID], [Doctor_Notes], [created_at]) VALUES (9, 16, N'Thực hiện tán nhuyễn Phaco đặt thể thủy tinh nhân tạo đa tiêu mắt phải thành công. Thị lực sau mổ 1 ngày: OD 9/10.', CAST(N'2026-10-18T08:19:54.6587122' AS DateTime2))
INSERT [dbo].[Prescription] ([Prescription_ID], [Record_ID], [Doctor_Notes], [created_at]) VALUES (10, 18, N'Kê thuốc hạ nhãn áp, theo dõi sát thị trường mắt. Tuyệt đối không tự ý nhỏ các loại thuốc có chứa corticoid.', CAST(N'2026-10-18T08:19:54.6587122' AS DateTime2))
SET IDENTITY_INSERT [dbo].[Prescription] OFF
GO

-- -----------------------------------------------------
-- Data: [Medical_Supply] (4 rows)
-- -----------------------------------------------------
SET IDENTITY_INSERT [dbo].[Medical_Supply] ON 

INSERT [dbo].[Medical_Supply] ([Supply_ID], [Supply_Name], [Category], [Price], [Image_Data], [Image_Mime_Type]) VALUES (1, N'Thuốc nhỏ mắt Systane Ultra (10ml)', N'Thuốc & Dung dịch', CAST(95000 AS Decimal(18, 0)), NULL, NULL)
INSERT [dbo].[Medical_Supply] ([Supply_ID], [Supply_Name], [Category], [Price], [Image_Data], [Image_Mime_Type]) VALUES (2, N'Tròng kính Essilor Crizal Alize 1.60', N'Kính & Phụ kiện', CAST(1250000 AS Decimal(18, 0)), NULL, NULL)
INSERT [dbo].[Medical_Supply] ([Supply_ID], [Supply_Name], [Category], [Price], [Image_Data], [Image_Mime_Type]) VALUES (3, N'Nước mắt nhân tạo Sanlein 0.1% (5ml)', N'Thuốc & Dung dịch', CAST(88000 AS Decimal(18, 0)), NULL, NULL)
INSERT [dbo].[Medical_Supply] ([Supply_ID], [Supply_Name], [Category], [Price], [Image_Data], [Image_Mime_Type]) VALUES (4, N'Que thử màu huỳnh quang Fluorescein Strips', N'Vật tư y tế tiêu hao', CAST(320000 AS Decimal(18, 0)), NULL, NULL)
SET IDENTITY_INSERT [dbo].[Medical_Supply] OFF
GO

-- -----------------------------------------------------
-- Data: [Prescription_Detail] (15 rows)
-- -----------------------------------------------------
SET IDENTITY_INSERT [dbo].[Prescription_Detail] ON 

INSERT [dbo].[Prescription_Detail] ([Detail_ID], [Prescription_ID], [Quantity], [Dosage_Instruction], [Medicine_Name]) VALUES (1, 1, 1, N'Nhỏ 1 giọt/lần, ngày 2 lần vào mắt phải', N'Thuốc nhỏ mắt Tobradex')
INSERT [dbo].[Prescription_Detail] ([Detail_ID], [Prescription_ID], [Quantity], [Dosage_Instruction], [Medicine_Name]) VALUES (2, 1, 2, N'Rửa mắt hàng ngày sáng và tối', N'Nước muối sinh lý 0.9%')
INSERT [dbo].[Prescription_Detail] ([Detail_ID], [Prescription_ID], [Quantity], [Dosage_Instruction], [Medicine_Name]) VALUES (3, 2, 1, N'Nhỏ 1 giọt mỗi bên mắt, ngày 3-4 lần khi khô mắt', N'Thuốc nhỏ mắt Systane Ultra (10ml)')
INSERT [dbo].[Prescription_Detail] ([Detail_ID], [Prescription_ID], [Quantity], [Dosage_Instruction], [Medicine_Name]) VALUES (4, 2, 1, N'Nhỏ 1 giọt mỗi bên mắt trước khi đi ngủ', N'Nước mắt nhân tạo Sanlein 0.1% (5ml)')
INSERT [dbo].[Prescription_Detail] ([Detail_ID], [Prescription_ID], [Quantity], [Dosage_Instruction], [Medicine_Name]) VALUES (5, 3, 1, N'Nhỏ 1 giọt mắt trái, ngày 2 lần trong 5 ngày', N'Thuốc nhỏ mắt Tobradex')
INSERT [dbo].[Prescription_Detail] ([Detail_ID], [Prescription_ID], [Quantity], [Dosage_Instruction], [Medicine_Name]) VALUES (6, 3, 2, N'Rửa mắt sáng và tối hàng ngày', N'Nước muối sinh lý 0.9%')
INSERT [dbo].[Prescription_Detail] ([Detail_ID], [Prescription_ID], [Quantity], [Dosage_Instruction], [Medicine_Name]) VALUES (7, 4, 1, N'Đeo kính thường xuyên khi học tập và nhìn xa', N'Tròng kính Essilor Crizal Alize 1.60')
INSERT [dbo].[Prescription_Detail] ([Detail_ID], [Prescription_ID], [Quantity], [Dosage_Instruction], [Medicine_Name]) VALUES (8, 5, 1, N'Nhỏ 1 giọt mỗi bên khi mỏi mắt', N'Nước mắt nhân tạo Sanlein 0.1% (5ml)')
INSERT [dbo].[Prescription_Detail] ([Detail_ID], [Prescription_ID], [Quantity], [Dosage_Instruction], [Medicine_Name]) VALUES (9, 6, 1, N'Nhỏ 1 giọt mỗi mắt, 4 lần/ngày trong 7 ngày', N'Thuốc nhỏ mắt Tobradex')
INSERT [dbo].[Prescription_Detail] ([Detail_ID], [Prescription_ID], [Quantity], [Dosage_Instruction], [Medicine_Name]) VALUES (10, 6, 2, N'Nhỏ dưỡng ẩm mắt đều đặn mỗi 2 tiếng', N'Nước mắt nhân tạo Sanlein 0.1% (5ml)')
INSERT [dbo].[Prescription_Detail] ([Detail_ID], [Prescription_ID], [Quantity], [Dosage_Instruction], [Medicine_Name]) VALUES (11, 7, 1, N'Nhỏ 1 giọt dưỡng mắt mỗi ngày', N'Thuốc nhỏ mắt Systane Ultra (10ml)')
INSERT [dbo].[Prescription_Detail] ([Detail_ID], [Prescription_ID], [Quantity], [Dosage_Instruction], [Medicine_Name]) VALUES (12, 8, 1, N'Vệ sinh mắt nhẹ nhàng hàng ngày', N'Nước muối sinh lý 0.9%')
INSERT [dbo].[Prescription_Detail] ([Detail_ID], [Prescription_ID], [Quantity], [Dosage_Instruction], [Medicine_Name]) VALUES (13, 9, 1, N'Nhỏ 1 giọt mắt phải ngày 3 lần trong 2 tuần', N'Thuốc nhỏ mắt Tobradex')
INSERT [dbo].[Prescription_Detail] ([Detail_ID], [Prescription_ID], [Quantity], [Dosage_Instruction], [Medicine_Name]) VALUES (14, 9, 1, N'Nhỏ bôi trơn mắt sau mổ', N'Thuốc nhỏ mắt Systane Ultra (10ml)')
INSERT [dbo].[Prescription_Detail] ([Detail_ID], [Prescription_ID], [Quantity], [Dosage_Instruction], [Medicine_Name]) VALUES (15, 10, 1, N'Nhỏ 1 giọt ngày 2 lần', N'Nước mắt nhân tạo Sanlein 0.1% (5ml)')
SET IDENTITY_INSERT [dbo].[Prescription_Detail] OFF
GO

-- -----------------------------------------------------
-- Data: [Procedure_Order] (10 rows)
-- -----------------------------------------------------
SET IDENTITY_INSERT [dbo].[Procedure_Order] ON 

INSERT [dbo].[Procedure_Order] ([Order_ID], [Specialist_Employee_ID], [Record_ID], [Service_ID], [Actual_Price], [Status]) VALUES (1, 9, 1, 7, CAST(100000 AS Decimal(18, 0)), N'Completed')
INSERT [dbo].[Procedure_Order] ([Order_ID], [Specialist_Employee_ID], [Record_ID], [Service_ID], [Actual_Price], [Status]) VALUES (2, 9, 3, 1, CAST(200000 AS Decimal(18, 0)), N'Completed')
INSERT [dbo].[Procedure_Order] ([Order_ID], [Specialist_Employee_ID], [Record_ID], [Service_ID], [Actual_Price], [Status]) VALUES (3, 9, 4, 1, CAST(200000 AS Decimal(18, 0)), N'Completed')
INSERT [dbo].[Procedure_Order] ([Order_ID], [Specialist_Employee_ID], [Record_ID], [Service_ID], [Actual_Price], [Status]) VALUES (4, 9, 7, 7, CAST(100000 AS Decimal(18, 0)), N'Completed')
INSERT [dbo].[Procedure_Order] ([Order_ID], [Specialist_Employee_ID], [Record_ID], [Service_ID], [Actual_Price], [Status]) VALUES (5, 9, 8, 7, CAST(100000 AS Decimal(18, 0)), N'Completed')
INSERT [dbo].[Procedure_Order] ([Order_ID], [Specialist_Employee_ID], [Record_ID], [Service_ID], [Actual_Price], [Status]) VALUES (6, 9, 10, 8, CAST(400000 AS Decimal(18, 0)), N'Completed')
INSERT [dbo].[Procedure_Order] ([Order_ID], [Specialist_Employee_ID], [Record_ID], [Service_ID], [Actual_Price], [Status]) VALUES (7, 9, 13, 1, CAST(200000 AS Decimal(18, 0)), N'Completed')
INSERT [dbo].[Procedure_Order] ([Order_ID], [Specialist_Employee_ID], [Record_ID], [Service_ID], [Actual_Price], [Status]) VALUES (8, 9, 14, 1, CAST(200000 AS Decimal(18, 0)), N'Completed')
INSERT [dbo].[Procedure_Order] ([Order_ID], [Specialist_Employee_ID], [Record_ID], [Service_ID], [Actual_Price], [Status]) VALUES (9, 9, 16, 8, CAST(400000 AS Decimal(18, 0)), N'Completed')
INSERT [dbo].[Procedure_Order] ([Order_ID], [Specialist_Employee_ID], [Record_ID], [Service_ID], [Actual_Price], [Status]) VALUES (10, 9, 18, 8, CAST(400000 AS Decimal(18, 0)), N'Completed')
SET IDENTITY_INSERT [dbo].[Procedure_Order] OFF
GO

-- -----------------------------------------------------
-- Data: [Leave_Cancel_Request] (1 rows)
-- -----------------------------------------------------
SET IDENTITY_INSERT [dbo].[Leave_Cancel_Request] ON 

INSERT [dbo].[Leave_Cancel_Request] ([Request_ID], [Schedule_ID], [Requester_Employee_ID], [Approved_By_Employee_ID], [leave_Date], [Reason], [request_status], [created_at], [approved_at]) VALUES (1, 3, 3, 2, CAST(N'2026-10-18' AS Date), N'Bác sĩ bận họp đột xuất', N'Pending', CAST(N'2026-10-18T08:19:54.6551278' AS DateTime2), NULL)
SET IDENTITY_INSERT [dbo].[Leave_Cancel_Request] OFF
GO

-- -----------------------------------------------------
-- Data: [Refund_Request] (1 rows)
-- -----------------------------------------------------
SET IDENTITY_INSERT [dbo].[Refund_Request] ON 

INSERT [dbo].[Refund_Request] ([Refund_ID], [Invoice_ID], [created_by_employee_id], [approved_by_employee_id], [Patient_ID], [Refund_Amount], [Reason], [Status], [Created_At], [Update_At]) VALUES (1, 1, 12, 2, 1, CAST(50000 AS Decimal(18, 0)), N'Bệnh nhân hủy dịch vụ phát sinh thêm', N'Approved', CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2), CAST(N'2026-10-18T08:19:54.6603658' AS DateTime2))
SET IDENTITY_INSERT [dbo].[Refund_Request] OFF
GO

-- -----------------------------------------------------
-- Data: [Clinic_Gallery] (8 rows)
-- -----------------------------------------------------
INSERT [dbo].[Clinic_Gallery] ([Item_ID], [Title], [Description], [Display_Order], [Default_Filename], [Image_Data], [Image_Mime_Type], [Updated_At]) VALUES (1, N'Sảnh tiếp đón và quầy tư vấn dịch vụ', N'Không gian hiện đại, tiện nghi tại VisionCare.', 1, N'gallery-1.jpg', NULL, NULL, CAST(N'2026-10-18T14:05:57.8711533' AS DateTime2))
INSERT [dbo].[Clinic_Gallery] ([Item_ID], [Title], [Description], [Display_Order], [Default_Filename], [Image_Data], [Image_Mime_Type], [Updated_At]) VALUES (2, N'Phòng khám khúc xạ và kiểm tra thị lực tự động', N'Không gian hiện đại, tiện nghi tại VisionCare.', 2, N'gallery-2.jpg', NULL, NULL, CAST(N'2026-10-18T14:05:57.8733962' AS DateTime2))
INSERT [dbo].[Clinic_Gallery] ([Item_ID], [Title], [Description], [Display_Order], [Default_Filename], [Image_Data], [Image_Mime_Type], [Updated_At]) VALUES (3, N'Phòng khám nhãn khoa tổng quát và soi đáy mắt', N'Không gian hiện đại, tiện nghi tại VisionCare.', 3, N'gallery-3.jpg', NULL, NULL, CAST(N'2026-10-18T14:05:57.8779607' AS DateTime2))
INSERT [dbo].[Clinic_Gallery] ([Item_ID], [Title], [Description], [Display_Order], [Default_Filename], [Image_Data], [Image_Mime_Type], [Updated_At]) VALUES (4, N'Phòng phẫu thuật khúc xạ công nghệ cao (LASIK/SMILE)', N'Không gian hiện đại, tiện nghi tại VisionCare.', 4, N'gallery-4.jpg', NULL, NULL, CAST(N'2026-10-18T14:05:57.8789613' AS DateTime2))
INSERT [dbo].[Clinic_Gallery] ([Item_ID], [Title], [Description], [Display_Order], [Default_Filename], [Image_Data], [Image_Mime_Type], [Updated_At]) VALUES (5, N'Hệ thống máy chụp cắt lớp võng mạc OCT hiện đại', N'Không gian hiện đại, tiện nghi tại VisionCare.', 5, N'gallery-5.jpg', NULL, NULL, CAST(N'2026-10-18T14:05:57.8799636' AS DateTime2))
INSERT [dbo].[Clinic_Gallery] ([Item_ID], [Title], [Description], [Display_Order], [Default_Filename], [Image_Data], [Image_Mime_Type], [Updated_At]) VALUES (6, N'Khu vực phòng chờ tiện nghi, thân thiện cho bệnh nhân', N'Không gian hiện đại, tiện nghi tại VisionCare.', 6, N'gallery-6.jpg', NULL, NULL, CAST(N'2026-10-18T14:05:57.8812442' AS DateTime2))
INSERT [dbo].[Clinic_Gallery] ([Item_ID], [Title], [Description], [Display_Order], [Default_Filename], [Image_Data], [Image_Mime_Type], [Updated_At]) VALUES (7, N'Phòng tiểu phẫu vô trùng đạt chuẩn y tế', N'Không gian hiện đại, tiện nghi tại VisionCare.', 7, N'gallery-7.jpg', NULL, NULL, CAST(N'2026-10-18T14:05:57.8826599' AS DateTime2))
INSERT [dbo].[Clinic_Gallery] ([Item_ID], [Title], [Description], [Display_Order], [Default_Filename], [Image_Data], [Image_Mime_Type], [Updated_At]) VALUES (8, N'Trung tâm kính mắt chuyên sâu và tư vấn tròng kính', N'Không gian hiện đại, tiện nghi tại VisionCare.', 8, N'gallery-8.jpg', NULL, NULL, CAST(N'2026-10-18T14:05:57.8836592' AS DateTime2))
GO

-- -----------------------------------------------------
-- Data: [Clinic_Setting] (1 rows)
-- -----------------------------------------------------
INSERT [dbo].[Clinic_Setting] ([Setting_Key], [Setting_Value], [Description]) VALUES (N'MIN_WORK_HOURS_PER_WEEK', N'30.0', N'Số giờ làm việc tối thiểu mỗi tuần')
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TABLE [dbo].[Account] ADD  DEFAULT (N'Local') FOR [Auth_Provider]
GO
ALTER TABLE [dbo].[Account] ADD  DEFAULT (N'Active') FOR [Account_Status]
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD FOREIGN KEY([Role_ID])
REFERENCES [dbo].[Role] ([Role_ID])
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [CHK_Account_Status] CHECK  (([Account_Status]='Deleted' OR [Account_Status]=N'Locked' OR [Account_Status]=N'Banned' OR [Account_Status]=N'Inactive' OR [Account_Status]=N'Active'))
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [CHK_Account_Status]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TABLE [dbo].[Employee_Profile]  WITH CHECK ADD FOREIGN KEY([Account_ID])
REFERENCES [dbo].[Account] ([Account_ID])
GO
ALTER TABLE [dbo].[Employee_Profile]  WITH CHECK ADD FOREIGN KEY([Room_ID])
REFERENCES [dbo].[Room] ([Room_ID])
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TABLE [dbo].[Service_Catalog]  WITH CHECK ADD  CONSTRAINT [CHK_Service_Catalog_Category] CHECK  (([Category]=N'Dịch vụ ngoài' OR [Category]=N'Khác' OR [Category]=N'Điều trị và thủ thuật' OR [Category]=N'Kiểm tra và chẩn đoán' OR [Category]=N'Khám và tư vấn'))
GO
ALTER TABLE [dbo].[Service_Catalog] CHECK CONSTRAINT [CHK_Service_Catalog_Category]
GO
ALTER TABLE [dbo].[Service_Catalog]  WITH CHECK ADD  CONSTRAINT [CHK_Service_Catalog_Price] CHECK  (([Price]>=(0)))
GO
ALTER TABLE [dbo].[Service_Catalog] CHECK CONSTRAINT [CHK_Service_Catalog_Price]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TABLE [dbo].[Work_Schedule] ADD  DEFAULT (N'Available') FOR [Status]
GO
ALTER TABLE [dbo].[Work_Schedule]  WITH CHECK ADD FOREIGN KEY([Doctor_Employee_ID])
REFERENCES [dbo].[Employee_Profile] ([Employee_ID])
GO
ALTER TABLE [dbo].[Work_Schedule]  WITH CHECK ADD FOREIGN KEY([Specialist_Employee_ID])
REFERENCES [dbo].[Employee_Profile] ([Employee_ID])
GO
ALTER TABLE [dbo].[Work_Schedule]  WITH CHECK ADD  CONSTRAINT [CHK_WS_Has_Employee] CHECK  (([Doctor_Employee_ID] IS NOT NULL OR [Specialist_Employee_ID] IS NOT NULL))
GO
ALTER TABLE [dbo].[Work_Schedule] CHECK CONSTRAINT [CHK_WS_Has_Employee]
GO
ALTER TABLE [dbo].[Work_Schedule]  WITH CHECK ADD  CONSTRAINT [CHK_WS_Slot_30Mins] CHECK  ((datediff(minute,[Start_Time],[End_Time])=(30)))
GO
ALTER TABLE [dbo].[Work_Schedule] CHECK CONSTRAINT [CHK_WS_Slot_30Mins]
GO
ALTER TABLE [dbo].[Work_Schedule]  WITH CHECK ADD  CONSTRAINT [CHK_WS_Status] CHECK  (([Status]=N'On_Leave' OR [Status]=N'Canceled' OR [Status]=N'Booked' OR [Status]=N'Available'))
GO
ALTER TABLE [dbo].[Work_Schedule] CHECK CONSTRAINT [CHK_WS_Status]
GO
ALTER TABLE [dbo].[Work_Schedule]  WITH CHECK ADD  CONSTRAINT [CHK_WS_Time] CHECK  (([End_Time]>[Start_Time]))
GO
ALTER TABLE [dbo].[Work_Schedule] CHECK CONSTRAINT [CHK_WS_Time]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TABLE [dbo].[Patient]  WITH CHECK ADD FOREIGN KEY([Account_ID])
REFERENCES [dbo].[Account] ([Account_ID])
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TABLE [dbo].[Appointment] ADD  DEFAULT (N'Pending') FOR [Status]
GO
ALTER TABLE [dbo].[Appointment] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[Appointment]  WITH CHECK ADD FOREIGN KEY([Patient_ID])
REFERENCES [dbo].[Patient] ([Patient_ID])
GO
ALTER TABLE [dbo].[Appointment]  WITH CHECK ADD FOREIGN KEY([Schedule_ID])
REFERENCES [dbo].[Work_Schedule] ([Schedule_ID])
GO
ALTER TABLE [dbo].[Appointment]  WITH CHECK ADD FOREIGN KEY([Staff_Employee_ID])
REFERENCES [dbo].[Employee_Profile] ([Employee_ID])
GO
ALTER TABLE [dbo].[Appointment]  WITH CHECK ADD  CONSTRAINT [CHK_Appt_Status] CHECK  (([Status]=N'Canceled' OR [Status]=N'Completed' OR [Status]=N'In_Progress' OR [Status]=N'Confirmed' OR [Status]=N'Pending'))
GO
ALTER TABLE [dbo].[Appointment] CHECK CONSTRAINT [CHK_Appt_Status]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TABLE [dbo].[Master_Invoice] ADD  DEFAULT (N'Unpaid') FOR [Status]
GO
ALTER TABLE [dbo].[Master_Invoice] ADD  DEFAULT (sysutcdatetime()) FOR [Create_At]
GO
ALTER TABLE [dbo].[Master_Invoice]  WITH CHECK ADD FOREIGN KEY([Appointment_ID])
REFERENCES [dbo].[Appointment] ([Appointment_ID])
GO
ALTER TABLE [dbo].[Master_Invoice]  WITH CHECK ADD  CONSTRAINT [CHK_Balance_Due] CHECK  (([Balance_Due]>=(0)))
GO
ALTER TABLE [dbo].[Master_Invoice] CHECK CONSTRAINT [CHK_Balance_Due]
GO
ALTER TABLE [dbo].[Master_Invoice]  WITH CHECK ADD  CONSTRAINT [CHK_Balance_Le_Total] CHECK  (([Balance_Due]<=[Total_Amount]))
GO
ALTER TABLE [dbo].[Master_Invoice] CHECK CONSTRAINT [CHK_Balance_Le_Total]
GO
ALTER TABLE [dbo].[Master_Invoice]  WITH CHECK ADD  CONSTRAINT [CHK_Deposit_Amount] CHECK  (([Deposit_Amount] IS NULL OR [Deposit_Amount]>=(0)))
GO
ALTER TABLE [dbo].[Master_Invoice] CHECK CONSTRAINT [CHK_Deposit_Amount]
GO
ALTER TABLE [dbo].[Master_Invoice]  WITH CHECK ADD  CONSTRAINT [CHK_Deposit_Le_Total] CHECK  (([Deposit_Amount] IS NULL OR [Deposit_Amount]<=[Total_Amount]))
GO
ALTER TABLE [dbo].[Master_Invoice] CHECK CONSTRAINT [CHK_Deposit_Le_Total]
GO
ALTER TABLE [dbo].[Master_Invoice]  WITH CHECK ADD  CONSTRAINT [CHK_Invoice_Status] CHECK  (([Status]=N'Unpaid' OR [Status]=N'Canceled' OR [Status]=N'Refunded' OR [Status]=N'Paid' OR [Status]=N'Partial_Paid' OR [Status]=N'Pending_Deposit'))
GO
ALTER TABLE [dbo].[Master_Invoice] CHECK CONSTRAINT [CHK_Invoice_Status]
GO
ALTER TABLE [dbo].[Master_Invoice]  WITH CHECK ADD  CONSTRAINT [CHK_Total_Amount] CHECK  (([Total_Amount]>=(0)))
GO
ALTER TABLE [dbo].[Master_Invoice] CHECK CONSTRAINT [CHK_Total_Amount]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TABLE [dbo].[Payment_Transaction] ADD  DEFAULT (sysutcdatetime()) FOR [Trans_Date]
GO
ALTER TABLE [dbo].[Payment_Transaction]  WITH CHECK ADD FOREIGN KEY([Invoice_ID])
REFERENCES [dbo].[Master_Invoice] ([Invoice_ID])
GO
ALTER TABLE [dbo].[Payment_Transaction]  WITH CHECK ADD  CONSTRAINT [CHK_Transaction_Amount] CHECK  (([Amount]>(0)))
GO
ALTER TABLE [dbo].[Payment_Transaction] CHECK CONSTRAINT [CHK_Transaction_Amount]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TABLE [dbo].[Medical_Record] ADD  DEFAULT (sysutcdatetime()) FOR [Created_At]
GO
ALTER TABLE [dbo].[Medical_Record]  WITH CHECK ADD FOREIGN KEY([Appointment_ID])
REFERENCES [dbo].[Appointment] ([Appointment_ID])
GO
ALTER TABLE [dbo].[Medical_Record]  WITH CHECK ADD FOREIGN KEY([Doctor_Employee_ID])
REFERENCES [dbo].[Employee_Profile] ([Employee_ID])
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TABLE [dbo].[Prescription] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[Prescription]  WITH CHECK ADD FOREIGN KEY([Record_ID])
REFERENCES [dbo].[Medical_Record] ([Record_ID])
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TABLE [dbo].[Medical_Supply]  WITH CHECK ADD  CONSTRAINT [CHK_Medical_Supply_Category] CHECK  (([Category]=N'Khác' OR [Category]=N'Vật tư y tế tiêu hao' OR [Category]=N'Kính & Phụ kiện' OR [Category]=N'Thuốc & Dung dịch'))
GO
ALTER TABLE [dbo].[Medical_Supply] CHECK CONSTRAINT [CHK_Medical_Supply_Category]
GO
ALTER TABLE [dbo].[Medical_Supply]  WITH CHECK ADD  CONSTRAINT [CHK_Medical_Supply_Price] CHECK  (([Price]>=(0)))
GO
ALTER TABLE [dbo].[Medical_Supply] CHECK CONSTRAINT [CHK_Medical_Supply_Price]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TABLE [dbo].[Prescription_Detail]  WITH CHECK ADD FOREIGN KEY([Prescription_ID])
REFERENCES [dbo].[Prescription] ([Prescription_ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Prescription_Detail]  WITH CHECK ADD  CONSTRAINT [CHK_Medicine_Quantity] CHECK  (([Quantity]>(0)))
GO
ALTER TABLE [dbo].[Prescription_Detail] CHECK CONSTRAINT [CHK_Medicine_Quantity]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TABLE [dbo].[Procedure_Order] ADD  DEFAULT (N'Pending') FOR [Status]
GO
ALTER TABLE [dbo].[Procedure_Order]  WITH CHECK ADD FOREIGN KEY([Record_ID])
REFERENCES [dbo].[Medical_Record] ([Record_ID])
GO
ALTER TABLE [dbo].[Procedure_Order]  WITH CHECK ADD FOREIGN KEY([Service_ID])
REFERENCES [dbo].[Service_Catalog] ([Service_ID])
GO
ALTER TABLE [dbo].[Procedure_Order]  WITH CHECK ADD FOREIGN KEY([Specialist_Employee_ID])
REFERENCES [dbo].[Employee_Profile] ([Employee_ID])
GO
ALTER TABLE [dbo].[Procedure_Order]  WITH CHECK ADD  CONSTRAINT [CHK_PO_Status] CHECK  (([Status]=N'Cancelled' OR [Status]=N'Completed' OR [Status]=N'Pending'))
GO
ALTER TABLE [dbo].[Procedure_Order] CHECK CONSTRAINT [CHK_PO_Status]
GO
ALTER TABLE [dbo].[Procedure_Order]  WITH CHECK ADD  CONSTRAINT [CHK_Procedure_Order_Actual_Price] CHECK  (([Actual_Price]>=(0)))
GO
ALTER TABLE [dbo].[Procedure_Order] CHECK CONSTRAINT [CHK_Procedure_Order_Actual_Price]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TABLE [dbo].[Leave_Cancel_Request] ADD  DEFAULT (N'Pending') FOR [request_status]
GO
ALTER TABLE [dbo].[Leave_Cancel_Request] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[Leave_Cancel_Request]  WITH CHECK ADD FOREIGN KEY([Approved_By_Employee_ID])
REFERENCES [dbo].[Employee_Profile] ([Employee_ID])
GO
ALTER TABLE [dbo].[Leave_Cancel_Request]  WITH CHECK ADD FOREIGN KEY([Requester_Employee_ID])
REFERENCES [dbo].[Employee_Profile] ([Employee_ID])
GO
ALTER TABLE [dbo].[Leave_Cancel_Request]  WITH CHECK ADD FOREIGN KEY([Schedule_ID])
REFERENCES [dbo].[Work_Schedule] ([Schedule_ID])
GO
ALTER TABLE [dbo].[Leave_Cancel_Request]  WITH CHECK ADD  CONSTRAINT [CHK_LCR_Status] CHECK  (([request_status]=N'Rejected' OR [request_status]=N'Approved' OR [request_status]=N'Pending'))
GO
ALTER TABLE [dbo].[Leave_Cancel_Request] CHECK CONSTRAINT [CHK_LCR_Status]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TABLE [dbo].[Refund_Request] ADD  DEFAULT (N'Pending') FOR [Status]
GO
ALTER TABLE [dbo].[Refund_Request] ADD  DEFAULT (sysutcdatetime()) FOR [Created_At]
GO
ALTER TABLE [dbo].[Refund_Request] ADD  DEFAULT (sysutcdatetime()) FOR [Update_At]
GO
ALTER TABLE [dbo].[Refund_Request]  WITH CHECK ADD FOREIGN KEY([approved_by_employee_id])
REFERENCES [dbo].[Employee_Profile] ([Employee_ID])
GO
ALTER TABLE [dbo].[Refund_Request]  WITH CHECK ADD FOREIGN KEY([created_by_employee_id])
REFERENCES [dbo].[Employee_Profile] ([Employee_ID])
GO
ALTER TABLE [dbo].[Refund_Request]  WITH CHECK ADD FOREIGN KEY([Invoice_ID])
REFERENCES [dbo].[Master_Invoice] ([Invoice_ID])
GO
ALTER TABLE [dbo].[Refund_Request]  WITH CHECK ADD FOREIGN KEY([Patient_ID])
REFERENCES [dbo].[Patient] ([Patient_ID])
GO
ALTER TABLE [dbo].[Refund_Request]  WITH CHECK ADD  CONSTRAINT [CHK_Refund_Amount] CHECK  (([Refund_Amount]>(0)))
GO
ALTER TABLE [dbo].[Refund_Request] CHECK CONSTRAINT [CHK_Refund_Amount]
GO
ALTER TABLE [dbo].[Refund_Request]  WITH CHECK ADD  CONSTRAINT [CHK_Refund_Status] CHECK  (([Status]=N'Rejected' OR [Status]=N'Approved' OR [Status]=N'Pending'))
GO
ALTER TABLE [dbo].[Refund_Request] CHECK CONSTRAINT [CHK_Refund_Status]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TABLE [dbo].[Clinic_Gallery] ADD  DEFAULT ((1)) FOR [Display_Order]
GO
ALTER TABLE [dbo].[Clinic_Gallery] ADD  DEFAULT (sysutcdatetime()) FOR [Updated_At]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO