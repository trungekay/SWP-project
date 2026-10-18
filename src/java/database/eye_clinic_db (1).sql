-- Run against the existing eye_clinic_db. This file never drops or creates a database.
-- Initial schema and sample data are added only when this database is empty.
USE eye_clinic_db;
IF DB_NAME() <> N'eye_clinic_db'
    THROW 50000, N'Chỉ chạy script trong eye_clinic_db hiện có.', 1;

IF OBJECT_ID(N'dbo.Role', N'U') IS NULL
BEGIN
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
    Service_Code    VARCHAR(20) NULL,
    Service_Name    NVARCHAR(255) NOT NULL,
    Price           DECIMAL(18,0) NOT NULL,
    Category        NVARCHAR(100) NOT NULL,
    Summary         NVARCHAR(500) NULL,
    Description     NVARCHAR(MAX) NULL,
    Image_Data      VARBINARY(MAX) NULL,
    Image_Mime_Type VARCHAR(50) NULL,
    CONSTRAINT CHK_Service_Catalog_Category CHECK (Category IN (
        N'Khám và tư vấn', N'Kiểm tra và chẩn đoán', N'Điều trị và thủ thuật',
        N'Khác', N'Dịch vụ ngoài')),
    CONSTRAINT CHK_Service_Catalog_Price CHECK (Price >= 0)
);
CREATE UNIQUE INDEX UX_Service_Catalog_Code ON Service_Catalog(Service_Code)
    WHERE Service_Code IS NOT NULL;

CREATE TABLE Medical_Supply (
    Supply_ID    INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Supply_Name  NVARCHAR(255) NOT NULL,
    Category     NVARCHAR(100) NOT NULL,
    Price        DECIMAL(18,0) NOT NULL,
    Image_Data   VARBINARY(MAX) NULL,
    Image_Mime_Type VARCHAR(50) NULL,
    CONSTRAINT CHK_Medical_Supply_Price CHECK (Price >= 0),
    CONSTRAINT CHK_Medical_Supply_Category CHECK (Category IN (
        N'Thuốc & Dung dịch', N'Kính & Phụ kiện', N'Vật tư y tế tiêu hao', N'Khác'))
);

CREATE TABLE Consumables (
    Consumable_ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Supply_Name NVARCHAR(255) NOT NULL,
    Category NVARCHAR(100) NOT NULL,
    Price DECIMAL(18,0) NOT NULL,
    Image_Data VARBINARY(MAX) NULL,
    Image_Mime_Type VARCHAR(50) NULL,
    CONSTRAINT CHK_Consumables_Price CHECK (Price >= 0),
    CONSTRAINT CHK_Consumables_Category CHECK (Category = N'Vật tư y tế tiêu hao')
);
CREATE TABLE Room (
    Room_ID     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Room_Name   NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Patient (
    Patient_ID  INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Account_ID  INT NULL,
    Full_Name   NVARCHAR(150) NOT NULL,
    Phone       NVARCHAR(20)  NOT NULL UNIQUE,
    DOB         DATE NULL,
    Address     NVARCHAR(255) NULL,
    FOREIGN KEY (Account_ID) REFERENCES Account(Account_ID)
);
CREATE UNIQUE NONCLUSTERED INDEX UX_Patient_Account_ID ON Patient(Account_ID)
    WHERE Account_ID IS NOT NULL;

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

CREATE TABLE Procedure_Order (
    Order_ID                INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Specialist_Employee_ID  INT NULL,
    Record_ID               INT NOT NULL,
    Service_ID              INT NOT NULL,
    Actual_Price            DECIMAL(18,0) NOT NULL,
    Status                  NVARCHAR(50) NOT NULL DEFAULT (N'Pending'),
    FOREIGN KEY (Specialist_Employee_ID) REFERENCES Employee_Profile(Employee_ID),
    FOREIGN KEY (Record_ID)              REFERENCES Medical_Record(Record_ID),
    FOREIGN KEY (Service_ID)             REFERENCES Service_Catalog(Service_ID),
    CONSTRAINT CHK_Procedure_Order_Actual_Price CHECK (Actual_Price >= 0)
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
(6, N'patient.an@gmail.com',         N'123', N'Local', N'Active'),
(6, N'patient.linh@gmail.com',       N'123', N'Local', N'Active'),
(6, N'patient.hoang@gmail.com',      N'123', N'Local', N'Active'),
(6, N'patient.mai@gmail.com',        N'123', N'Local', N'Active'),
(6, N'patient.duc@gmail.com',        N'123', N'Local', N'Active');

INSERT INTO Patient (Account_ID, Full_Name, Phone, DOB, Address) VALUES
(13,   N'Nguyễn Văn An',       N'0901234567', '1995-05-15', N'123 Lê Lợi, Q.1, TP.HCM'),
(NULL, N'Trần Thị Bình',       N'0918765432', '1988-10-20', N'456 Nguyễn Huệ, Q.1, TP.HCM'),
(14,   N'Đặng Thùy Linh',      N'0933112233', '1998-08-12', N'78 Nguyễn Trãi, Q.5, TP.HCM'),
(15,   N'Hoàng Minh Tuấn',     N'0977889900', '1985-03-24', N'154 Hai Bà Trưng, Q.3, TP.HCM'),
(16,   N'Lê Thị Ngọc Mai',     N'0966554433', '2002-11-05', N'45 Xô Viết Nghệ Tĩnh, Bình Thạnh, TP.HCM'),
(17,   N'Vũ Trọng Đức',        N'0912334455', '1970-07-19', N'210 Điện Biên Phủ, Q.3, TP.HCM'),
(NULL, N'Bùi Quốc Anh (Bé)',   N'0988776655', '2015-09-10', N'12 Hoàng Diệu, Q.4, TP.HCM'),
(NULL, N'Phạm Thanh Thảo',     N'0909112244', '1992-06-30', N'89 Cách Mạng Tháng 8, Q.10, TP.HCM'),
(NULL, N'Ngô Đình Cường',      N'0944556677', '1963-04-18', N'33 Nam Kỳ Khởi Nghĩa, Q.1, TP.HCM'),
(NULL, N'Đỗ Bảo Châu (Bé)',    N'0938445566', '2017-02-14', N'66 Lê Văn Sỹ, Phú Nhuận, TP.HCM'),
(NULL, N'Nguyễn Hữu Nghĩa',    N'0919223344', '1990-12-08', N'102 Pasteur, Q.1, TP.HCM');

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
(3,    NULL, '2026-04-01', N'Slot 1',  '08:00:00', '08:30:00', N'Available'),
(3,    NULL, '2026-04-01', N'Slot 2',  '08:30:00', '09:00:00', N'Available'),
(3,    NULL, '2026-04-01', N'Slot 3',  '09:00:00', '09:30:00', N'Available'),
(3,    NULL, '2026-04-01', N'Slot 4',  '09:30:00', '10:00:00', N'Available'),
(3,    NULL, '2026-04-01', N'Slot 5',  '10:00:00', '10:30:00', N'Available'),
(3,    NULL, '2026-04-01', N'Slot 6',  '10:30:00', '11:00:00', N'Available'),
(3,    NULL, '2026-04-01', N'Slot 7',  '11:00:00', '11:30:00', N'Available'),
(3,    NULL, '2026-04-01', N'Slot 8',  '13:30:00', '14:00:00', N'Available'),
(3,    NULL, '2026-04-01', N'Slot 9',  '14:00:00', '14:30:00', N'Available'),
(3,    NULL, '2026-04-01', N'Slot 10', '14:30:00', '15:00:00', N'Available'),
(3,    NULL, '2026-04-01', N'Slot 11', '15:00:00', '15:30:00', N'Available'),
(3,    NULL, '2026-04-01', N'Slot 12', '15:30:00', '16:00:00', N'Available'),
(3,    NULL, '2026-04-01', N'Slot 13', '16:00:00', '16:30:00', N'Available'),
(3,    NULL, '2026-04-01', N'Slot 14', '16:30:00', '17:00:00', N'Available'),
(3,    NULL, '2026-04-01', N'Slot 15', '17:00:00', '17:30:00', N'Available'),
(NULL, 9,    '2026-04-01', N'Slot 1',  '08:00:00', '08:30:00', N'Available');

INSERT INTO Leave_Cancel_Request
    (Schedule_ID, Requester_Employee_ID, Approved_By_Employee_ID, leave_Date, Reason, request_status, approved_at)
VALUES
(3, 3, 2, '2026-04-01', N'Bác sĩ bận họp đột xuất', N'Pending', NULL);

INSERT INTO Appointment (Patient_ID, Schedule_ID, Staff_Employee_ID, Status, created_at, checkin_time) VALUES
(1, 1, 12, N'Completed', SYSUTCDATETIME(), SYSUTCDATETIME()),
(2, 2, 12, N'Pending',   SYSUTCDATETIME(), NULL),
(1, 60, 12, N'Pending', SYSUTCDATETIME(), NULL),
(3, 846, 12, N'Completed', SYSUTCDATETIME(), SYSUTCDATETIME()),
(4, 847, 12, N'Completed', SYSUTCDATETIME(), SYSUTCDATETIME()),
(1, 61, 12, N'Confirmed', SYSUTCDATETIME(), SYSUTCDATETIME()),
(5, 111, 12, N'Pending', SYSUTCDATETIME(), NULL),
(5, 848, 12, N'Completed', SYSUTCDATETIME(), SYSUTCDATETIME()),
(1, 849, 12, N'Completed', SYSUTCDATETIME(), SYSUTCDATETIME()),
(8, 86, 12, N'Confirmed', SYSUTCDATETIME(), SYSUTCDATETIME()),
(11, 850, 12, N'Completed', SYSUTCDATETIME(), SYSUTCDATETIME()),
(3, 151, 12, N'Confirmed', SYSUTCDATETIME(), SYSUTCDATETIME()),
(4, 204, 12, N'Pending', SYSUTCDATETIME(), NULL),
(7, 851, 12, N'Completed', SYSUTCDATETIME(), SYSUTCDATETIME()),
(10, 852, 12, N'Completed', SYSUTCDATETIME(), SYSUTCDATETIME()),
(7, 127, 12, N'Confirmed', SYSUTCDATETIME(), SYSUTCDATETIME()),
(9, 853, 12, N'Completed', SYSUTCDATETIME(), SYSUTCDATETIME()),
(6, 854, 12, N'Confirmed', SYSUTCDATETIME(), SYSUTCDATETIME()),
(6, 855, 12, N'Completed', SYSUTCDATETIME(), SYSUTCDATETIME()),
(9, 211, 12, N'Confirmed', SYSUTCDATETIME(), SYSUTCDATETIME()),
(2, 15, 12, N'Canceled', SYSUTCDATETIME(), NULL);

INSERT INTO Medical_Record
    (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis, examination_result, conclusion, Created_At)
VALUES
(1, 3, N'Mắt phải cận thị 1.5 độ, viêm kết mạc nhẹ', NULL, NULL, SYSUTCDATETIME()),
(3, 3, N'Dịch vụ/Bệnh lý: Khám mắt tổng quát', NULL, NULL, SYSUTCDATETIME()),
(4, 3, N'Dịch vụ: Khám mắt tổng quát | Lý do: Khô rát mắt, nhìn màn hình máy tính mỏi mắt', N'Khô mắt độ 1 cả hai mắt, hội chứng thị giác màn hình (CVS). Thị lực OD 10/10, OS 10/10, nhãn áp bình thường.', N'Hạn chế nhìn màn hình liên tục >45 phút không nghỉ, chớp mắt thường xuyên. Nhỏ nước mắt nhân tạo hàng ngày.', SYSUTCDATETIME()),
(5, 3, N'Dịch vụ: Khám mắt tổng quát | Lý do: Cộm xốn mắt trái, mi mắt sưng đỏ', N'Viêm bờ mi mạn tính, xước biểu mô giác mạc nông mắt trái do dị vật cọ xát. Thị lực OD 10/10, OS 8/10.', N'Vệ sinh bờ mi bằng gạc ấm mỗi sáng và tối. Dùng thuốc nhỏ kháng sinh và chất làm ẩm bảo vệ giác mạc. Tái khám sau 5 ngày.', SYSUTCDATETIME()),
(6, 3, N'Dịch vụ: Khám mắt tổng quát | Lý do: Tái khám định kỳ sau điều trị viêm kết mạc', NULL, NULL, SYSUTCDATETIME()),
(7, 3, N'Dịch vụ: Khám mắt tổng quát | Lý do: Khám sức khỏe định kỳ cho sinh viên', NULL, NULL, SYSUTCDATETIME()),
(8, 4, N'Dịch vụ: Đo khúc xạ và tư vấn kính | Lý do: Mắt nhìn mờ bảng đen, nhức đầu khi đọc sách', N'Cận thị tiến triển: OD -2.50D (thị lực chỉnh kính 10/10), OS -3.00D loạn 0.5D trục 180 (chỉnh kính 10/10).', N'Kê đơn kính mới chống ánh sáng xanh. Tư vấn tư thế ngồi học và giữ khoảng cách 35cm khi đọc sách.', SYSUTCDATETIME()),
(9, 4, N'Dịch vụ: Đo khúc xạ và tư vấn kính | Lý do: Kiểm tra lại độ cận mắt kính cũ', N'Độ cận ổn định: OD -1.25D, OS -1.50D. Đáy mắt bình thường không tổn thương võng mạc.', N'Giữ nguyên độ kính hiện tại, không cần tăng độ. Tái kiểm tra khúc xạ sau 6 tháng.', SYSUTCDATETIME()),
(10, 4, N'Dịch vụ: Đo khúc xạ và tư vấn kính | Lý do: Đo độ làm kính cận râm đi du lịch', NULL, NULL, SYSUTCDATETIME()),
(11, 5, N'Dịch vụ: Phẫu thuật LASIK | Lý do: Muốn xóa cận thị cao để thi tuyển ngành công an', N'Cận thị 2 mắt OD -6.50D, OS -7.00D. Chiều dày giác mạc trung tâm 545µm. Đủ tiêu chuẩn phẫu thuật Femto-LASIK.', N'Phẫu thuật Femto-LASIK hai mắt thành công hoàn hảo. Thị lực không kính ngày 1 sau mổ: OD 10/10, OS 10/10.', SYSUTCDATETIME()),
(12, 5, N'Dịch vụ: Phẫu thuật LASIK | Lý do: Khám tiền phẫu và đo bản đồ giác mạc xóa cận', NULL, NULL, SYSUTCDATETIME()),
(13, 5, N'Dịch vụ: Phẫu thuật LASIK | Lý do: Tư vấn phẫu thuật Smile / Femto-Lasik', NULL, NULL, SYSUTCDATETIME()),
(14, 6, N'Dịch vụ: Khám mắt trẻ em và tư vấn nhược thị | Lý do: Bé hay nheo mắt nghiêng đầu xem tivi', N'Nhược thị khúc xạ mắt trái do bất đồng khúc xạ: OD +0.75D (thị lực 9/10), OS +4.25D loạn 1.0D (thị lực 3/10).', N'Chỉ định đeo kính đúng độ liên tục. Áp dụng liệu pháp bịt mắt lành (mắt phải) 2 giờ mỗi ngày kết hợp tập thị giác. Tái khám sau 1 tháng.', SYSUTCDATETIME()),
(15, 6, N'Dịch vụ: Khám mắt trẻ em và tư vấn nhược thị | Lý do: Bố mẹ phát hiện mắt bé thỉnh thoảng lé vào trong', N'Lác trong điều tiết một phần mắt phải góc 15 độ Hirschberg. Đáy mắt trong suốt, không u nguyên bào võng mạc.', N'Cho tra atropine giãn cơ thể mi và cấp kính điều chỉnh toàn phần. Hẹn đo lại góc lác sau 3 tuần đeo kính.', SYSUTCDATETIME()),
(16, 6, N'Dịch vụ: Khám mắt trẻ em và tư vấn nhược thị | Lý do: Tái khám kiểm tra thị lực sau 1 tháng tập che mắt', NULL, NULL, SYSUTCDATETIME()),
(17, 7, N'Dịch vụ: Phẫu thuật Phaco điều trị đục thủy tinh thể | Lý do: Mắt phải mờ như có màn sương che, chói mắt ban ngày', N'Đục thể thủy tinh người già nhân vỏ độ 3 mắt phải. Thị lực mắt phải đếm ngón tay 2m. Mắt trái đục nhẹ thị lực 6/10.', N'Thực hiện tán nhuyễn Phaco đặt thể thủy tinh nhân tạo đa tiêu mắt phải thành công. Thị lực sau mổ 1 ngày: OD 9/10.', SYSUTCDATETIME()),
(18, 7, N'Dịch vụ: Phẫu thuật Phaco điều trị đục thủy tinh thể | Lý do: Khám tầm soát đục thủy tinh thể người cao tuổi', NULL, NULL, SYSUTCDATETIME()),
(19, 8, N'Dịch vụ: Đo nhãn áp và chụp OCT võng mạc | Lý do: Nhức tức vùng hốc mắt, nhìn thấy quầng màu cầu vồng quanh đèn', N'Nghi ngờ Glaucoma góc mở. Nhãn áp OD 26 mmHg, OS 24 mmHg (giá trị cao). Hình ảnh OCT cho thấy lớp sợi thần kinh võng mạc khuyết nhẹ góc thái dương dưới.', N'Kê thuốc hạ nhãn áp, theo dõi sát thị trường mắt. Tuyệt đối không tự ý nhỏ các loại thuốc có chứa corticoid.', SYSUTCDATETIME()),
(20, 8, N'Dịch vụ: Đo nhãn áp và chụp OCT võng mạc | Lý do: Tái khám định kỳ theo dõi nhãn áp sau điều trị', NULL, NULL, SYSUTCDATETIME()),
(21, 3, N'Dịch vụ: Khám mắt tổng quát | Lý do: Bệnh nhân báo bận công tác đột xuất, xin hủy lịch khám', NULL, NULL, SYSUTCDATETIME());

-- Một danh mục dịch vụ dùng chung cho đặt lịch và Procedure_Order.
-- Sample images remain in web/assets/img; Image_Data is used for admin uploads.
INSERT INTO Service_Catalog
    (Service_Code, Service_Name, Price, Category, Summary, Description)
VALUES
('NK-01', N'Khám mắt tổng quát', 250000, N'Khám và tư vấn', N'Khám và chẩn đoán toàn diện các bệnh lý về mắt, phù hợp với mọi lứa tuổi.', N'Bao gồm đo thị lực, kiểm tra áp lực nhãn cầu, soi đáy mắt, đánh giá tình trạng giác mạc và thủy tinh thể.'),
('KX-02', N'Đo khúc xạ và tư vấn kính', 150000, N'Kiểm tra và chẩn đoán', N'Khám sàng lọc và đo độ khúc xạ với hệ thống đo tự động chuẩn xác.', N'Đo khúc xạ chính xác bằng máy tự động, thử thị lực và tư vấn tròng kính phù hợp.'),
('LS-03', N'Phẫu thuật LASIK', 18000000, N'Điều trị và thủ thuật', N'Xóa cận không dao, thời gian phục hồi nhanh chóng.', N'Phẫu thuật khúc xạ laser LASIK/SMILE điều trị cận thị, viễn thị và loạn thị với công nghệ hiện đại.'),
('PE-04', N'Khám mắt trẻ em và tư vấn nhược thị', 300000, N'Khám và tư vấn', N'Sàng lọc sớm các tật khúc xạ tiến triển, tật lé và suy giảm thị lực ở trẻ nhỏ.', N'Sàng lọc cận thị sớm, điều trị nhược thị và lác mắt trong không gian khám thân thiện.'),
('TT-05', N'Phẫu thuật Phaco điều trị đục thủy tinh thể', 12000000, N'Điều trị và thủ thuật', N'Tái tạo tầm nhìn trong sáng bằng phương pháp tán nhuyễn Phaco tiên tiến.', N'Phẫu thuật thay thể thủy tinh nhân tạo điều trị đục thủy tinh thể an toàn, đường mổ siêu nhỏ.'),
('GL-06', N'Đo nhãn áp và chụp OCT võng mạc', 500000, N'Kiểm tra và chẩn đoán', N'Kiểm soát nhãn áp, bảo tồn thị trường thần kinh mắt và ngăn ngừa biến chứng mù lòa.', N'Tầm soát và can thiệp bệnh Glaucoma, thoái hóa hoàng điểm và tổn thương võng mạc với hệ thống OCT.'),
-- Dịch vụ khám khô mắt độc lập với gói đo khúc xạ KX-02.
('KM-09', N'Khám và tư vấn khô mắt', 200000, N'Khám và tư vấn', N'Đánh giá nguyên nhân khô mắt và tư vấn chăm sóc phù hợp.', N'Khám bề mặt nhãn cầu, đánh giá phim nước mắt và tư vấn hướng điều trị theo kết quả thăm khám.'),
('OCT-DM', N'Chụp OCT đáy mắt', 400000, N'Kiểm tra và chẩn đoán', NULL, NULL);

INSERT INTO Medical_Supply (Supply_Name, Category, Price) VALUES
(N'Thuốc nhỏ mắt Systane Ultra (10ml)', N'Thuốc & Dung dịch', 95000),
(N'Tròng kính Essilor Crizal Alize 1.60', N'Kính & Phụ kiện', 1250000),
(N'Nước mắt nhân tạo Sanlein 0.1% (5ml)', N'Thuốc & Dung dịch', 88000);

INSERT INTO Consumables (Supply_Name, Category, Price) VALUES
(N'Que thử màu huỳnh quang Fluorescein Strips', N'Vật tư y tế tiêu hao', 320000);

-- Service_ID 7/8 là hai dịch vụ cũ vừa thêm sau sáu dịch vụ hiện có.
-- Actual_Price giữ giá tại thời điểm lập chỉ định.
INSERT INTO Procedure_Order (Specialist_Employee_ID, Record_ID, Service_ID, Actual_Price, Status) VALUES
(9, 1, 7, 100000, N'Completed'),
(9, 3, 1, 200000, N'Completed'),
(9, 4, 1, 200000, N'Completed'),
(9, 7, 7, 100000, N'Completed'),
(9, 8, 7, 100000, N'Completed'),
(9, 10, 8, 400000, N'Completed'),
(9, 13, 1, 200000, N'Completed'),
(9, 14, 1, 200000, N'Completed'),
(9, 16, 8, 400000, N'Completed'),
(9, 18, 8, 400000, N'Completed');

INSERT INTO Prescription (Record_ID, Doctor_Notes) VALUES
(1, N'Nhỏ thuốc đúng giờ, tái khám sau 7 ngày nếu mắt còn đỏ'),
(3, N'Hạn chế nhìn màn hình liên tục >45 phút không nghỉ, chớp mắt thường xuyên. Nhỏ nước mắt nhân tạo hàng ngày.'),
(4, N'Vệ sinh bờ mi bằng gạc ấm mỗi sáng và tối. Dùng thuốc nhỏ kháng sinh và chất làm ẩm bảo vệ giác mạc. Tái khám sau 5 ngày.'),
(7, N'Kê đơn kính mới chống ánh sáng xanh. Tư vấn tư thế ngồi học và giữ khoảng cách 35cm khi đọc sách.'),
(8, N'Giữ nguyên độ kính hiện tại, không cần tăng độ. Tái kiểm tra khúc xạ sau 6 tháng.'),
(10, N'Phẫu thuật Femto-LASIK hai mắt thành công hoàn hảo. Thị lực không kính ngày 1 sau mổ: OD 10/10, OS 10/10.'),
(13, N'Chỉ định đeo kính đúng độ liên tục. Áp dụng liệu pháp bịt mắt lành (mắt phải) 2 giờ mỗi ngày kết hợp tập thị giác. Tái khám sau 1 tháng.'),
(14, N'Cho tra atropine giãn cơ thể mi và cấp kính điều chỉnh toàn phần. Hẹn đo lại góc lác sau 3 tuần đeo kính.'),
(16, N'Thực hiện tán nhuyễn Phaco đặt thể thủy tinh nhân tạo đa tiêu mắt phải thành công. Thị lực sau mổ 1 ngày: OD 9/10.'),
(18, N'Kê thuốc hạ nhãn áp, theo dõi sát thị trường mắt. Tuyệt đối không tự ý nhỏ các loại thuốc có chứa corticoid.');

INSERT INTO Prescription_Detail (Prescription_ID, Medicine_Name, Quantity, Dosage_Instruction) VALUES
(1, N'Thuốc nhỏ mắt Tobradex', 1, N'Nhỏ 1 giọt/lần, ngày 2 lần vào mắt phải'),
(1, N'Nước muối sinh lý 0.9%', 2, N'Rửa mắt hàng ngày sáng và tối'),
(2, N'Thuốc nhỏ mắt Systane Ultra (10ml)', 1, N'Nhỏ 1 giọt mỗi bên mắt, ngày 3-4 lần khi khô mắt'),
(2, N'Nước mắt nhân tạo Sanlein 0.1% (5ml)', 1, N'Nhỏ 1 giọt mỗi bên mắt trước khi đi ngủ'),
(3, N'Thuốc nhỏ mắt Tobradex', 1, N'Nhỏ 1 giọt mắt trái, ngày 2 lần trong 5 ngày'),
(3, N'Nước muối sinh lý 0.9%', 2, N'Rửa mắt sáng và tối hàng ngày'),
(4, N'Tròng kính Essilor Crizal Alize 1.60', 1, N'Đeo kính thường xuyên khi học tập và nhìn xa'),
(5, N'Nước mắt nhân tạo Sanlein 0.1% (5ml)', 1, N'Nhỏ 1 giọt mỗi bên khi mỏi mắt'),
(6, N'Thuốc nhỏ mắt Tobradex', 1, N'Nhỏ 1 giọt mỗi mắt, 4 lần/ngày trong 7 ngày'),
(6, N'Nước mắt nhân tạo Sanlein 0.1% (5ml)', 2, N'Nhỏ dưỡng ẩm mắt đều đặn mỗi 2 tiếng'),
(7, N'Thuốc nhỏ mắt Systane Ultra (10ml)', 1, N'Nhỏ 1 giọt dưỡng mắt mỗi ngày'),
(8, N'Nước muối sinh lý 0.9%', 1, N'Vệ sinh mắt nhẹ nhàng hàng ngày'),
(9, N'Thuốc nhỏ mắt Tobradex', 1, N'Nhỏ 1 giọt mắt phải ngày 3 lần trong 2 tuần'),
(9, N'Thuốc nhỏ mắt Systane Ultra (10ml)', 1, N'Nhỏ bôi trơn mắt sau mổ'),
(10, N'Nước mắt nhân tạo Sanlein 0.1% (5ml)', 1, N'Nhỏ 1 giọt ngày 2 lần');

INSERT INTO Master_Invoice
    (Appointment_ID, Total_Amount, Deposit_Amount, Balance_Due, Status, Close_At)
VALUES
(1, 300000, 100000, 0, N'Paid', SYSUTCDATETIME()),
(3, 250000, 200000, 50000, N'Pending_Deposit', NULL),
(4, 250000, 200000, 0, N'Paid', SYSUTCDATETIME()),
(5, 250000, 200000, 0, N'Paid', SYSUTCDATETIME()),
(6, 250000, 200000, 50000, N'Partial_Paid', SYSUTCDATETIME()),
(7, 250000, 200000, 250000, N'Pending_Deposit', NULL),
(8, 150000, 150000, 0, N'Paid', SYSUTCDATETIME()),
(9, 150000, 150000, 0, N'Paid', SYSUTCDATETIME()),
(10, 150000, 150000, 0, N'Paid', SYSUTCDATETIME()),
(11, 18000000, 18000000, 0, N'Paid', SYSUTCDATETIME()),
(12, 18000000, 200000, 17800000, N'Partial_Paid', SYSUTCDATETIME()),
(13, 18000000, 200000, 18000000, N'Pending_Deposit', NULL),
(14, 300000, 300000, 0, N'Paid', SYSUTCDATETIME()),
(15, 300000, 300000, 0, N'Paid', SYSUTCDATETIME()),
(16, 300000, 200000, 100000, N'Partial_Paid', SYSUTCDATETIME()),
(17, 12000000, 12000000, 0, N'Paid', SYSUTCDATETIME()),
(18, 12000000, 200000, 11800000, N'Partial_Paid', SYSUTCDATETIME()),
(19, 500000, 500000, 0, N'Paid', SYSUTCDATETIME()),
(20, 500000, 200000, 300000, N'Partial_Paid', SYSUTCDATETIME()),
(21, 250000, 0, 0, N'Canceled', NULL);

INSERT INTO Payment_Transaction (Invoice_ID, Amount, Gateway_Status, Payment_Gateway) VALUES
(1, 100000, N'Success', N'VNPay'),
(1, 200000, N'Success', N'Cash');

INSERT INTO Refund_Request
    (Invoice_ID, created_by_employee_id, approved_by_employee_id, Patient_ID, Refund_Amount, Reason, Status)
VALUES
(1, 12, 2, 1, 50000, N'Bệnh nhân hủy dịch vụ phát sinh thêm', N'Approved');

-- Retail catalog table required by the merged category migration.
CREATE TABLE dbo.Medicine (
    Medicine_ID     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Supply_Name     NVARCHAR(255) NOT NULL,
    Category        NVARCHAR(100) NOT NULL,
    Price           DECIMAL(18,0) NOT NULL,
    Image_Data      VARBINARY(MAX) NULL,
    Image_Mime_Type VARCHAR(50) NULL,
    CONSTRAINT CHK_Medicine_Price CHECK (Price >= 0),
    CONSTRAINT CHK_Medicine_Category CHECK (Category IN (
        N'Thuốc & dung dịch', N'Kính gọng & tròng kính', N'Kính áp tròng',
        N'Phụ kiện & sản phẩm hỗ trợ', N'Khác'))
);

-- Merged from migrate_retail_categories.sql.
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
END;

-- Bring an existing catalog up to date without recreating the database.
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'dbo.Consumables', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Consumables (
            Consumable_ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            Supply_Name NVARCHAR(255) NOT NULL,
            Category NVARCHAR(100) NOT NULL,
            Price DECIMAL(18,0) NOT NULL,
            Image_Data VARBINARY(MAX) NULL,
            Image_Mime_Type VARCHAR(50) NULL,
            CONSTRAINT CHK_Consumables_Price CHECK (Price >= 0),
            CONSTRAINT CHK_Consumables_Category CHECK (Category = N'Vật tư y tế tiêu hao')
        );
    END;

    -- Keep existing items and uploaded images when separating consumables from equipment.
    INSERT INTO dbo.Consumables (Supply_Name, Category, Price, Image_Data, Image_Mime_Type)
    SELECT source.Supply_Name, source.Category, source.Price, source.Image_Data, source.Image_Mime_Type
    FROM dbo.Medical_Supply AS source
    WHERE source.Category = N'Vật tư y tế tiêu hao'
      AND NOT EXISTS (
          SELECT 1 FROM dbo.Consumables AS target
          WHERE target.Supply_Name = source.Supply_Name
            AND target.Category = source.Category
      );

    DELETE FROM dbo.Medical_Supply WHERE Category = N'Vật tư y tế tiêu hao';

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;

-- Doctor examination and prescription forms. Runs after initial setup on a
-- new database and adds only missing objects on an existing database.
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'dbo.Examination_Detail', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Examination_Detail (
            Record_ID INT NOT NULL PRIMARY KEY,
            Chief_Complaint NVARCHAR(1000) NULL,
            Medical_History NVARCHAR(1000) NULL,
            OD_Uncorrected NVARCHAR(20) NULL,
            OS_Uncorrected NVARCHAR(20) NULL,
            OD_Corrected NVARCHAR(20) NULL,
            OS_Corrected NVARCHAR(20) NULL,
            OD_IOP DECIMAL(4,1) NULL,
            OS_IOP DECIMAL(4,1) NULL,
            Anterior_Findings NVARCHAR(2000) NULL,
            Posterior_Findings NVARCHAR(2000) NULL,
            Follow_Up_Date DATE NULL,
            CONSTRAINT FK_Examination_Detail_Record FOREIGN KEY (Record_ID)
                REFERENCES dbo.Medical_Record(Record_ID),
            CONSTRAINT CHK_Exam_OD_IOP CHECK (OD_IOP IS NULL OR OD_IOP BETWEEN 0 AND 80),
            CONSTRAINT CHK_Exam_OS_IOP CHECK (OS_IOP IS NULL OR OS_IOP BETWEEN 0 AND 80)
        );
    END;

    IF COL_LENGTH('dbo.Prescription', 'Follow_Up_Date') IS NULL
        ALTER TABLE dbo.Prescription ADD Follow_Up_Date DATE NULL;
    IF COL_LENGTH('dbo.Prescription_Detail', 'Strength') IS NULL
        ALTER TABLE dbo.Prescription_Detail ADD Strength NVARCHAR(100) NULL;
    IF COL_LENGTH('dbo.Prescription_Detail', 'Dosage') IS NULL
        ALTER TABLE dbo.Prescription_Detail ADD Dosage NVARCHAR(100) NULL;
    IF COL_LENGTH('dbo.Prescription_Detail', 'Frequency') IS NULL
        ALTER TABLE dbo.Prescription_Detail ADD Frequency NVARCHAR(100) NULL;
    IF COL_LENGTH('dbo.Prescription_Detail', 'Duration') IS NULL
        ALTER TABLE dbo.Prescription_Detail ADD Duration NVARCHAR(100) NULL;
    IF COL_LENGTH('dbo.Prescription_Detail', 'Unit') IS NULL
        ALTER TABLE dbo.Prescription_Detail ADD Unit NVARCHAR(20) NULL;
    IF COL_LENGTH('dbo.Prescription_Detail', 'Additional_Instruction') IS NULL
        ALTER TABLE dbo.Prescription_Detail ADD Additional_Instruction NVARCHAR(255) NULL;

    IF OBJECT_ID(N'dbo.Eyeglass_Prescription', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Eyeglass_Prescription (
            Prescription_ID INT NOT NULL PRIMARY KEY,
            OD_SPH DECIMAL(5,2) NULL,
            OD_CYL DECIMAL(5,2) NULL,
            OD_AXIS SMALLINT NULL,
            OD_ADD DECIMAL(4,2) NULL,
            OS_SPH DECIMAL(5,2) NULL,
            OS_CYL DECIMAL(5,2) NULL,
            OS_AXIS SMALLINT NULL,
            OS_ADD DECIMAL(4,2) NULL,
            PD DECIMAL(4,1) NULL,
            Lens_Type VARCHAR(20) NULL,
            Glasses_Notes NVARCHAR(1000) NULL,
            CONSTRAINT FK_Eyeglass_Prescription_Parent FOREIGN KEY (Prescription_ID)
                REFERENCES dbo.Prescription(Prescription_ID) ON DELETE CASCADE,
            CONSTRAINT CHK_Eyeglass_OD_Axis CHECK (OD_AXIS IS NULL OR OD_AXIS BETWEEN 0 AND 180),
            CONSTRAINT CHK_Eyeglass_OS_Axis CHECK (OS_AXIS IS NULL OR OS_AXIS BETWEEN 0 AND 180),
            CONSTRAINT CHK_Eyeglass_PD CHECK (PD IS NULL OR PD BETWEEN 40 AND 80)
        );
    END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
