USE master;
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'eye_clinic_db')
BEGIN
    ALTER DATABASE eye_clinic_db SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE eye_clinic_db;
END
GO
CREATE DATABASE eye_clinic_db;
GO
USE eye_clinic_db;
GO

CREATE TABLE Role (
    Role_ID     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Role_Name   NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Account (
    Account_ID      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Role_ID         INT NOT NULL,
    Email           NVARCHAR(150) NOT NULL UNIQUE,
    Password        NVARCHAR(255) NOT NULL,
    Auth_Provider   NVARCHAR(50)  NOT NULL DEFAULT (N'Local'),
    Account_Status  NVARCHAR(50)  NOT NULL DEFAULT (N'Active'),
    FOREIGN KEY (Role_ID) REFERENCES Role(Role_ID)
);

CREATE TABLE Service_Catalog (
    Service_ID      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Created_By      INT NULL,
    Service_Code    VARCHAR(20) NULL,
    Service_Name    NVARCHAR(255) NOT NULL,
    Price           DECIMAL(18,0) NOT NULL,
    Specialty_Code  VARCHAR(30) NULL,
    Tag             NVARCHAR(100) NULL,
    Summary         NVARCHAR(500) NULL,
    Description     NVARCHAR(MAX) NULL,
    Image_Path      VARCHAR(255) NULL,
    Image_Data      VARBINARY(MAX) NULL,
    Image_Mime_Type VARCHAR(50) NULL,
    FOREIGN KEY (Created_By) REFERENCES Account(Account_ID),
    CONSTRAINT CHK_Service_Catalog_Price CHECK (Price >= 0)
);
CREATE UNIQUE INDEX UX_Service_Catalog_Code ON Service_Catalog(Service_Code)
    WHERE Service_Code IS NOT NULL;

CREATE TABLE Medical_Supply (
    Supply_ID    INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Supply_Name  NVARCHAR(255) NOT NULL,
    Category     NVARCHAR(100) NOT NULL,
    Batch_Code   VARCHAR(50) NULL,
    Unit         NVARCHAR(30) NOT NULL,
    Quantity     INT NOT NULL DEFAULT (0),
    Price        DECIMAL(18,0) NOT NULL,
    Image_Data   VARBINARY(MAX) NULL,
    Image_Mime_Type VARCHAR(50) NULL,
    CONSTRAINT CHK_Medical_Supply_Quantity CHECK (Quantity >= 0),
    CONSTRAINT CHK_Medical_Supply_Price CHECK (Price >= 0)
);

CREATE TABLE Room (
    Room_ID     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Room_Name   NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Patient (
    Patient_ID  INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Account_ID  INT NULL UNIQUE,
    Full_Name   NVARCHAR(150) NOT NULL,
    Phone       NVARCHAR(20)  NOT NULL UNIQUE,
    DOB         DATE NULL,
    Address     NVARCHAR(255) NULL,
    FOREIGN KEY (Account_ID) REFERENCES Account(Account_ID)
);

CREATE TABLE Employee_Profile (
    Employee_ID     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Account_ID      INT NOT NULL UNIQUE,
    Room_ID         INT NULL,
    Full_Name       NVARCHAR(150) NOT NULL,
    Phone           NVARCHAR(20) NULL,
    DOB         DATE NULL,
    Address     NVARCHAR(255) NULL,
    Specialty       NVARCHAR(100) NULL,
    License_Number  NVARCHAR(100) NULL,
    Biography       NVARCHAR(MAX) NULL,
    FOREIGN KEY (Account_ID) REFERENCES Account(Account_ID),
    FOREIGN KEY (Room_ID)    REFERENCES Room(Room_ID)
);

CREATE TABLE Work_Schedule (
    Schedule_ID             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Doctor_Employee_ID      INT NULL,
    Specialist_Employee_ID  INT NULL,
    Staff_Employee_ID       INT NULL,
    Work_Date               DATE NOT NULL,
    Start_Time              TIME(0) NOT NULL,
    End_Time                TIME(0) NOT NULL,
    Slot                    NVARCHAR(50) NOT NULL,
    Status                  NVARCHAR(50) NOT NULL DEFAULT (N'Available'),
    FOREIGN KEY (Doctor_Employee_ID)     REFERENCES Employee_Profile(Employee_ID),
    FOREIGN KEY (Specialist_Employee_ID) REFERENCES Employee_Profile(Employee_ID)
);

CREATE TABLE Leave_Cancel_Request (
    Request_ID              INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Schedule_ID             INT NOT NULL,
    Requester_Employee_ID   INT NOT NULL,
    Approved_By_Employee_ID INT NULL,
    leave_Date              DATE NOT NULL,
    Reason                  NVARCHAR(MAX) NOT NULL,
    request_status          NVARCHAR(50) NOT NULL DEFAULT (N'Pending'),
    created_at              DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
    approved_at             DATETIME2 NULL,
    FOREIGN KEY (Schedule_ID)             REFERENCES Work_Schedule(Schedule_ID),
    FOREIGN KEY (Requester_Employee_ID)   REFERENCES Employee_Profile(Employee_ID),
    FOREIGN KEY (Approved_By_Employee_ID) REFERENCES Employee_Profile(Employee_ID)
);

CREATE TABLE Appointment (
    Appointment_ID      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Patient_ID          INT NOT NULL,
    Schedule_ID         INT NOT NULL,
    Staff_Employee_ID   INT NULL,
    Status              NVARCHAR(50) NOT NULL DEFAULT (N'Pending'),
    created_at          DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
    checkin_time        DATETIME2 NULL,
    FOREIGN KEY (Patient_ID)        REFERENCES Patient(Patient_ID),
    FOREIGN KEY (Schedule_ID)       REFERENCES Work_Schedule(Schedule_ID),
    FOREIGN KEY (Staff_Employee_ID) REFERENCES Employee_Profile(Employee_ID)
);

CREATE TABLE Medical_Record (
    Record_ID           INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Appointment_ID      INT NOT NULL UNIQUE,
    Doctor_Employee_ID  INT NOT NULL,
    Clinical_Diagnosis  NVARCHAR(MAX) NULL,
    examination_result  NVARCHAR(MAX) NULL,
    conclusion          NVARCHAR(MAX) NULL,
    Created_At          DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
    FOREIGN KEY (Appointment_ID)     REFERENCES Appointment(Appointment_ID),
    FOREIGN KEY (Doctor_Employee_ID) REFERENCES Employee_Profile(Employee_ID)
);

CREATE TABLE Service (
    Service_ID      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Service_Name    NVARCHAR(255) NOT NULL,
    Actual_Price    DECIMAL(18,0) NOT NULL,
    Created_At      DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
    Update_At       DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME())
);

CREATE TABLE Procedure_Order (
    Order_ID                INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Specialist_Employee_ID  INT NULL,
    Record_ID               INT NOT NULL,
    Service_ID              INT NOT NULL,
    Status                  NVARCHAR(50) NOT NULL DEFAULT (N'Pending'),
    FOREIGN KEY (Specialist_Employee_ID) REFERENCES Employee_Profile(Employee_ID),
    FOREIGN KEY (Record_ID)              REFERENCES Medical_Record(Record_ID),
    FOREIGN KEY (Service_ID)             REFERENCES Service(Service_ID)
);

CREATE TABLE Prescription (
    Prescription_ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Record_ID       INT NOT NULL,
    Doctor_Notes    NVARCHAR(MAX) NULL,
    created_at      DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
    FOREIGN KEY (Record_ID) REFERENCES Medical_Record(Record_ID)
);

CREATE TABLE Prescription_Detail (
    Detail_ID           INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Prescription_ID     INT NOT NULL,
    Quantity            INT NOT NULL,
    Dosage_Instruction  NVARCHAR(MAX) NULL,
    Medicine_Name       NVARCHAR(255) NOT NULL,
    FOREIGN KEY (Prescription_ID) REFERENCES Prescription(Prescription_ID) ON DELETE CASCADE
);

CREATE TABLE Master_Invoice (
    Invoice_ID      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Appointment_ID  INT NOT NULL UNIQUE,
    Total_Amount    DECIMAL(18,0) NOT NULL,
    Deposit_Amount  DECIMAL(18,0) NULL,
    Balance_Due     DECIMAL(18,0) NOT NULL,
    Status          NVARCHAR(50) NOT NULL DEFAULT (N'Unpaid'),
    Create_At       DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
    Close_At        DATETIME2 NULL,
    FOREIGN KEY (Appointment_ID) REFERENCES Appointment(Appointment_ID)
);

CREATE TABLE Payment_Transaction (
    Transaction_ID  INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Invoice_ID      INT NOT NULL,
    Amount          DECIMAL(18,0) NOT NULL,
    Gateway_Status  NVARCHAR(50) NOT NULL,
    Trans_Date      DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
    Payment_Gateway NVARCHAR(50) NOT NULL,
    FOREIGN KEY (Invoice_ID) REFERENCES Master_Invoice(Invoice_ID)
);

CREATE TABLE Refund_Request (
    Refund_ID               INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Invoice_ID              INT NOT NULL,
    created_by_employee_id  INT NOT NULL,
    approved_by_employee_id INT NULL,
    Patient_ID              INT NOT NULL,
    Refund_Amount           DECIMAL(18,0) NOT NULL,
    Reason                  NVARCHAR(MAX) NULL,
    Status                  NVARCHAR(50) NOT NULL DEFAULT (N'Pending'),
    Created_At              DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
    Update_At               DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
    FOREIGN KEY (Invoice_ID)              REFERENCES Master_Invoice(Invoice_ID),
    FOREIGN KEY (created_by_employee_id)  REFERENCES Employee_Profile(Employee_ID),
    FOREIGN KEY (approved_by_employee_id) REFERENCES Employee_Profile(Employee_ID),
    FOREIGN KEY (Patient_ID)              REFERENCES Patient(Patient_ID)
);
GO

ALTER TABLE Account ADD CONSTRAINT CHK_Account_Status
    CHECK (Account_Status IN (N'Active', N'Inactive', N'Banned', N'Locked','Deleted'));
ALTER TABLE Work_Schedule ADD CONSTRAINT CHK_WS_Has_Employee
    CHECK (Doctor_Employee_ID IS NOT NULL OR Specialist_Employee_ID IS NOT NULL);
ALTER TABLE Work_Schedule ADD CONSTRAINT CHK_WS_Time CHECK (End_Time > Start_Time);
ALTER TABLE Work_Schedule ADD CONSTRAINT CHK_WS_Slot_30Mins
    CHECK (DATEDIFF(MINUTE, Start_Time, End_Time) = 30);
ALTER TABLE Work_Schedule ADD CONSTRAINT CHK_WS_Status
    CHECK (Status IN (N'Available', N'Booked', N'Canceled', N'On_Leave'));
ALTER TABLE Leave_Cancel_Request ADD CONSTRAINT CHK_LCR_Status
    CHECK (request_status IN (N'Pending', N'Approved', N'Rejected'));
ALTER TABLE Appointment ADD CONSTRAINT CHK_Appt_Status
    CHECK (Status IN (N'Pending', N'Confirmed', N'In_Progress', N'Completed', N'Canceled'));
ALTER TABLE Service ADD CONSTRAINT CHK_Service_Price CHECK (Actual_Price >= 0);
ALTER TABLE Procedure_Order ADD CONSTRAINT CHK_PO_Status
    CHECK (Status IN (N'Pending', N'Completed', N'Cancelled'));
ALTER TABLE Prescription_Detail ADD CONSTRAINT CHK_Medicine_Quantity CHECK (Quantity > 0);
ALTER TABLE Master_Invoice ADD CONSTRAINT CHK_Total_Amount CHECK (Total_Amount >= 0);
ALTER TABLE Master_Invoice ADD CONSTRAINT CHK_Deposit_Amount
    CHECK (Deposit_Amount IS NULL OR Deposit_Amount >= 0);
ALTER TABLE Master_Invoice ADD CONSTRAINT CHK_Balance_Due CHECK (Balance_Due >= 0);
ALTER TABLE Master_Invoice ADD CONSTRAINT CHK_Deposit_Le_Total
    CHECK (Deposit_Amount IS NULL OR Deposit_Amount <= Total_Amount);
ALTER TABLE Master_Invoice ADD CONSTRAINT CHK_Balance_Le_Total CHECK (Balance_Due <= Total_Amount);
ALTER TABLE Master_Invoice ADD CONSTRAINT CHK_Invoice_Status
    CHECK (Status IN (N'Pending_Deposit', N'Partial_Paid', N'Paid', N'Refunded', N'Canceled', N'Unpaid'));
ALTER TABLE Payment_Transaction ADD CONSTRAINT CHK_Transaction_Amount CHECK (Amount > 0);
ALTER TABLE Refund_Request ADD CONSTRAINT CHK_Refund_Amount CHECK (Refund_Amount > 0);
ALTER TABLE Refund_Request ADD CONSTRAINT CHK_Refund_Status
    CHECK (Status IN (N'Pending', N'Approved', N'Rejected'));
GO

INSERT INTO Role (Role_Name) VALUES
(N'System_Admin'), (N'Director'), (N'Doctor'),
(N'Medical_Specialist'), (N'Staff'), (N'Patient');

INSERT INTO Room (Room_Name) VALUES
(N'Phòng Khám Nhãn khoa tổng quát'),
(N'Phòng Khám Đo Khúc xạ & Kính'),
(N'Phòng Khám Phẫu thuật LASIK'),
(N'Phòng Khám Nhãn khoa trẻ em & Nhược thị'),
(N'Phòng Khám Đục thủy tinh thể (Phaco)'),
(N'Phòng Khám Glaucoma & Võng mạc'),
(N'Phòng Tiểu Phẫu 1'),
(N'Phòng Tiểu Phẫu 2'),
(N'Phòng Tiểu Phẫu 3');

INSERT INTO Account (Role_ID, Email, Password, Auth_Provider, Account_Status) VALUES
(1, N'admin@eyeclinic.com',          N'123', N'Local', N'Active'),
(2, N'director@eyeclinic.com',       N'123', N'Local', N'Active'),
(3, N'doctor.nam@eyeclinic.com',     N'123', N'Local', N'Active'),
(3, N'doctor.tinh@eyeclinic.com',    N'123', N'Local', N'Active'),
(3, N'doctor.lan@eyeclinic.com',     N'123', N'Local', N'Active'),
(3, N'doctor.ngoc@eyeclinic.com',    N'123', N'Local', N'Active'),
(3, N'doctor.huy@eyeclinic.com',     N'123', N'Local', N'Active'),
(3, N'doctor.dung@eyeclinic.com',    N'123', N'Local', N'Active'),
(4, N'specialist.lan@eyeclinic.com', N'123', N'Local', N'Active'),
(4, N'specialist.huy@eyeclinic.com', N'123', N'Local', N'Active'),
(4, N'specialist.c@eyeclinic.com',   N'123', N'Local', N'Active'),
(5, N'staff.lan@eyeclinic.com',      N'123', N'Local', N'Active'),
(6, N'patient.an@gmail.com',         N'123', N'Local', N'Active');

INSERT INTO Patient (Account_ID, Full_Name, Phone, DOB, Address) VALUES
(13,   N'Nguyễn Văn An',  N'0901234567', '1995-05-15', N'123 Lê Lợi, Q.1, TP.HCM'),
(NULL, N'Trần Thị Bình',  N'0918765432', '1988-10-20', N'456 Nguyễn Huệ, Q.1, TP.HCM');

INSERT INTO Employee_Profile (Account_ID, Room_ID, Full_Name, Phone, Specialty, License_Number, Biography) VALUES
(1,  NULL, N'Quản trị viên Hệ thống',     NULL, N'Quản trị hệ thống',     NULL,            NULL),
(2,  NULL, N'Nguyễn Văn Giám Đốc',        NULL, N'Giám đốc',              NULL,            NULL),
(3,  1,    N'BS. Trần Văn Nam',           NULL, N'Nhãn khoa tổng quát',            N'BS-12345/EYE', N'Hơn 12 năm kinh nghiệm trong chẩn đoán và điều trị toàn diện các bệnh lý mắt. Từng công tác tại Bệnh viện Mắt TP.HCM và tích cực tham gia các hội thảo nhãn khoa quốc tế.'),
(4,  2,    N'TS.BS. Nguyễn Xuân Tịnh',    NULL, N'Đo Khúc xạ & Kính',              N'BS-56789/EYE', N'Tiến sĩ Nhãn khoa với hơn 15 năm chuyên sâu về tật khúc xạ, kiểm soát tiến triển cận thị học đường và ứng dụng công nghệ đo thị lực hiện đại từ Đức.'),
(5,  3,    N'BS. Lê Hoàng Lan',           NULL, N'Phẫu thuật LASIK',               N'BS-98765/EYE', N'Chuyên gia phẫu thuật khúc xạ hàng đầu, thực hiện thành công hơn 6,000 ca phẫu thuật Femto-LASIK và SMILE. Tận tâm, chu đáo và luôn đồng hành cùng bệnh nhân.'),
(6,  4,    N'BS. Phạm Bảo Ngọc',          NULL, N'Nhãn khoa trẻ em & Nhược thị',   N'BS-34567/EYE', N'Bác sĩ giàu kinh nghiệm trong điều trị nhược thị, lác mắt và các bệnh lý mắt bẩm sinh ở trẻ em. Được đào tạo chuyên sâu tại Bệnh viện Mắt Trung ương và Singapore.'),
(7,  5,    N'BS. Trần Quang Huy',         NULL, N'Đục thủy tinh thể (Phaco)',      N'BS-45678/EYE', N'Bàn tay vàng trong phẫu thuật Phaco tán nhuyễn thể thủy tinh đục, phục hồi thị lực sáng rõ cho hàng ngàn bệnh nhân cao tuổi với kỹ thuật đường mổ siêu nhỏ.'),
(8,  6,    N'BS. Ngô Tiến Dũng',          NULL, N'Glaucoma & Võng mạc',            N'BS-99999/EYE', NULL),
(9,  7,    N'ThS.BS. Lê Hoàng Lan',       NULL, N'Medical Specialist tiểu phẫu',   N'BS-11111/EYE', NULL),
(10, 8,    N'BSCKII. Trần Quang Huy',     NULL, N'Medical Specialist tiểu phẫu',   N'BS-22222/EYE', NULL),
(11, 9,    N'ThS. Lê Văn C',              NULL, N'Medical Specialist tiểu phẫu',   N'BS-33333/EYE', NULL),
(12, NULL, N'Lễ Tân Phạm Thị Lan',        NULL, N'Thu Ngân & Tiếp Đón',            NULL,            NULL);

INSERT INTO Work_Schedule
    (Doctor_Employee_ID, Specialist_Employee_ID, Work_Date, Slot, Start_Time, End_Time, Status)
VALUES
(3,    NULL, '2026-04-01', N'Slot 1', '08:00:00', '08:30:00', N'Available'),
(3,    NULL, '2026-04-01', N'Slot 2', '08:30:00', '09:00:00', N'Available'),
(3,    NULL, '2026-04-01', N'Slot 3', '09:00:00', '09:30:00', N'Available'),
(3,    NULL, '2026-04-01', N'Slot 4', '09:30:00', '10:00:00', N'Available'),
(NULL, 9,    '2026-04-01', N'Slot 1', '08:00:00', '08:30:00', N'Available');

INSERT INTO Leave_Cancel_Request
    (Schedule_ID, Requester_Employee_ID, Approved_By_Employee_ID, leave_Date, Reason, request_status, approved_at)
VALUES
(3, 3, 2, '2026-04-01', N'Bác sĩ bận họp đột xuất', N'Pending', NULL);

INSERT INTO Appointment (Patient_ID, Schedule_ID, Staff_Employee_ID, Status, created_at, checkin_time) VALUES
(1, 1, 12, N'Completed', SYSUTCDATETIME(), SYSUTCDATETIME()),
(2, 2, 12, N'Pending',   SYSUTCDATETIME(), NULL);

INSERT INTO Medical_Record
    (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis, examination_result, conclusion)
VALUES
(1, 3, N'Mắt phải cận thị 1.5 độ, viêm kết mạc nhẹ', NULL, NULL);

INSERT INTO Service (Service_Name, Actual_Price) VALUES
(N'Khám mắt tổng quát', 200000),
(N'Đo khúc xạ máy',     100000),
(N'Chụp OCT đáy mắt',   400000);

-- Danh mục quản trị; bảng Service ở trên dùng cho Procedure_Order.
INSERT INTO Service_Catalog
    (Service_Code, Service_Name, Price, Specialty_Code, Tag, Summary, Description, Image_Path)
VALUES
('NK-01', N'Nhãn khoa tổng quát', 250000, 'general', N'Gói cơ bản', N'Khám và chẩn đoán toàn diện các bệnh lý về mắt, phù hợp với mọi lứa tuổi.', N'Bao gồm đo thị lực, kiểm tra áp lực nhãn cầu, soi đáy mắt, đánh giá tình trạng giác mạc và thủy tinh thể.', 'departments-1.jpg'),
('KX-02', N'Đo Khúc xạ & Kính', 150000, 'refraction', N'Khúc xạ kế', N'Khám sàng lọc và đo độ khúc xạ với hệ thống đo tự động chuẩn xác.', N'Đo khúc xạ chính xác bằng máy tự động, thử thị lực và tư vấn tròng kính phù hợp.', 'departments-2.jpg'),
('LS-03', N'Phẫu thuật LASIK', 18000000, 'lasik', N'Kỹ thuật cao', N'Xóa cận không dao, thời gian phục hồi nhanh chóng.', N'Phẫu thuật khúc xạ laser LASIK/SMILE điều trị cận thị, viễn thị và loạn thị với công nghệ hiện đại.', 'departments-3.jpg'),
('PE-04', N'Nhãn khoa trẻ em & Nhược thị', 300000, 'children', N'Trẻ em & Học đường', N'Sàng lọc sớm các tật khúc xạ tiến triển, tật lác và suy giảm thị lực ở trẻ nhỏ.', N'Sàng lọc cận thị sớm, điều trị nhược thị và lác mắt trong không gian khám thân thiện.', 'departments-4.jpg'),
('TT-05', N'Đục thủy tinh thể (Phaco)', 12000000, 'cataract', N'Phẫu thuật Phaco', N'Tái tạo tầm nhìn trong sáng bằng phương pháp tán nhuyễn Phaco tiên tiến.', N'Phẫu thuật thay thế thủy tinh nhân tạo điều trị đục thủy tinh thể an toàn, đường mổ siêu nhỏ.', 'departments-5.jpg'),
('GL-06', N'Glaucoma & Võng mạc', 500000, 'retina', N'Đáy mắt chuyên sâu', N'Kiểm soát nhãn áp, bảo tồn thị trường thần kinh mắt và ngăn ngừa biến chứng mù lòa.', N'Tầm soát và can thiệp bệnh Glaucoma, thoái hóa hoàng điểm và tổn thương võng mạc với hệ thống OCT.', 'gallery/gallery-1.jpg');

INSERT INTO Medical_Supply (Supply_Name, Category, Batch_Code, Unit, Quantity, Price) VALUES
(N'Thuốc nhỏ mắt Systane Ultra (10ml)', N'Dung dịch nhỏ mắt', 'SYS-2026A', N'lọ', 142, 95000),
(N'Tròng kính Essilor Crizal Alize 1.60', N'Tròng kính', 'ESL-8839', N'cặp', 45, 1250000),
(N'Nước mắt nhân tạo Sanlein 0.1% (5ml)', N'Dung dịch nhỏ mắt', 'SNL-091', N'lọ', 8, 88000),
(N'Que thử màu huỳnh quang Fluorescein Strips', N'Vật tư chẩn đoán', 'FLS-002', N'hộp', 22, 320000);

INSERT INTO Procedure_Order (Specialist_Employee_ID, Record_ID, Service_ID, Status) VALUES
(9, 1, 2, N'Completed');

INSERT INTO Prescription (Record_ID, Doctor_Notes) VALUES
(1, N'Nhỏ thuốc đúng giờ, tái khám sau 7 ngày nếu mắt còn đỏ');

INSERT INTO Prescription_Detail (Prescription_ID, Medicine_Name, Quantity, Dosage_Instruction) VALUES
(1, N'Thuốc nhỏ mắt Tobradex', 1, N'Nhỏ 1 giọt/lần, ngày 2 lần vào mắt phải'),
(1, N'Nước muối sinh lý 0.9%', 2, N'Rửa mắt hàng ngày sáng và tối');

INSERT INTO Master_Invoice
    (Appointment_ID, Total_Amount, Deposit_Amount, Balance_Due, Status, Close_At)
VALUES
(1, 300000, 100000, 0, N'Paid', SYSUTCDATETIME());

INSERT INTO Payment_Transaction (Invoice_ID, Amount, Gateway_Status, Payment_Gateway) VALUES
(1, 100000, N'Success', N'VNPay'),
(1, 200000, N'Success', N'Cash');

INSERT INTO Refund_Request
    (Invoice_ID, created_by_employee_id, approved_by_employee_id, Patient_ID, Refund_Amount, Reason, Status)
VALUES
(1, 12, 2, 1, 50000, N'Bệnh nhân hủy dịch vụ phát sinh thêm', N'Approved');
GO
