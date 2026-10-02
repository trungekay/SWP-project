-- =========================================================
-- ClinicDB_ERD  |  Phòng khám Mắt (Nhãn khoa) - FIXED
-- =========================================================

-- 1. Chuyển về master và xóa Database cũ nếu đang bị kẹt
USE master;
GO

IF DB_ID('eye_clinic_db') IS NOT NULL
BEGIN
    ALTER DATABASE eye_clinic_db SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE eye_clinic_db;
END
GO

-- 2. Tạo mới Database
CREATE DATABASE eye_clinic_db;
GO

-- 3. Bắt buộc ngắt lô lệnh bằng GO để chuyển sang DB mới
USE eye_clinic_db;
GO

-- =========================================================
-- PHẦN 1: TẠO BẢNG (TABLES) VÀ CÁC RÀNG BUỘC (CONSTRAINTS)
-- =========================================================

CREATE TABLE dbo.Role (
    Role_ID     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Role_Name   NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE dbo.Account (
    Account_ID      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Role_ID         INT NOT NULL,
    Email           NVARCHAR(150) NOT NULL UNIQUE,
    Password        NVARCHAR(255) NOT NULL,
    Auth_Provider   NVARCHAR(50)  NOT NULL CONSTRAINT DF_Account_Auth DEFAULT (N'Local'),
    Account_Status  NVARCHAR(50)  NOT NULL CONSTRAINT DF_Account_Status DEFAULT (N'Active'),
    CONSTRAINT fk_account_role FOREIGN KEY (Role_ID) REFERENCES dbo.Role(Role_ID),
    CONSTRAINT chk_account_status CHECK (Account_Status IN (N'Active', N'Inactive', N'Locked', N'Pending'))
);

CREATE TABLE dbo.Patient (
    Patient_ID  INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Account_ID  INT NOT NULL UNIQUE,
    Full_Name   NVARCHAR(150) NOT NULL,
    Phone       NVARCHAR(20)  NOT NULL UNIQUE,
    DOB         DATE NULL,
    Address     NVARCHAR(255) NULL,
    CONSTRAINT fk_patient_account FOREIGN KEY (Account_ID) REFERENCES dbo.Account(Account_ID)
);

CREATE TABLE dbo.Room (
    Room_ID     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Room_Name   NVARCHAR(100) NOT NULL UNIQUE,
    address     NVARCHAR(255) NULL,
    hotline     NVARCHAR(20) NULL,
    status      NVARCHAR(50) NOT NULL CONSTRAINT DF_Room_Status DEFAULT (N'Available'),
    created_at  DATETIME2 NOT NULL CONSTRAINT DF_Room_Created DEFAULT (SYSUTCDATETIME()),
    updated_at  DATETIME2 NOT NULL CONSTRAINT DF_Room_Updated DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT chk_room_status CHECK (status IN (N'Available', N'Maintenance', N'Closed'))
);

CREATE TABLE dbo.Employee_Profile (
    Employee_ID     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Account_ID      INT NOT NULL UNIQUE,
    Room_ID         INT NULL,
    Full_Name       NVARCHAR(150) NOT NULL,
	Phone           NVARCHAR(20) NULL,
    Specialty       NVARCHAR(100) NULL,
    License_Number  NVARCHAR(100) NULL, -- Bỏ UNIQUE inline tại đây
    CONSTRAINT fk_employee_account FOREIGN KEY (Account_ID) REFERENCES dbo.Account(Account_ID),
    CONSTRAINT fk_employee_room    FOREIGN KEY (Room_ID)    REFERENCES dbo.Room(Room_ID)
);

-- Filtered Index cho phép nhiều giá trị NULL trên License_Number nhưng vẫn đảm bảo duy nhất nếu có dữ liệu
CREATE UNIQUE NONCLUSTERED INDEX UQ_Employee_LicenseNumber
ON dbo.Employee_Profile(License_Number)
WHERE License_Number IS NOT NULL;

CREATE TABLE dbo.Work_Schedule (
    Schedule_ID             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Doctor_Employee_ID      INT NULL,
    Specialist_Employee_ID  INT NULL,
    Work_Date               DATE NOT NULL,
    Start_Time              TIME(0) NOT NULL,
    End_Time                TIME(0) NOT NULL,
    Slot                    INT NOT NULL CONSTRAINT DF_WS_Slot DEFAULT (0),
    Status                  NVARCHAR(50) NOT NULL CONSTRAINT DF_WS_Status DEFAULT (N'Scheduled'),
    CONSTRAINT fk_ws_doctor      FOREIGN KEY (Doctor_Employee_ID)      REFERENCES dbo.Employee_Profile(Employee_ID),
    CONSTRAINT fk_ws_specialist  FOREIGN KEY (Specialist_Employee_ID)  REFERENCES dbo.Employee_Profile(Employee_ID),
    CONSTRAINT chk_ws_has_employee CHECK (Doctor_Employee_ID IS NOT NULL OR Specialist_Employee_ID IS NOT NULL),
    CONSTRAINT chk_ws_time_order   CHECK (End_Time > Start_Time),
    CONSTRAINT chk_ws_slot_nonneg  CHECK (Slot >= 0),
    CONSTRAINT chk_ws_status       CHECK (Status IN (N'Scheduled', N'Available', N'Booked', N'Cancelled', N'Completed', N'OnLeave'))
);

CREATE TABLE dbo.Leave_Cancel_Request (
    Request_ID              INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Schedule_ID             INT NOT NULL,
    Requester_Employee_ID   INT NOT NULL,
    Approved_By_Employee_ID INT NULL,
    leave_Date              DATE NOT NULL,
    Reason                  NVARCHAR(MAX) NULL,
    request_status          NVARCHAR(50) NOT NULL CONSTRAINT DF_LCR_Status DEFAULT (N'Pending'),
    approved_at             DATETIME2 NULL,
    CONSTRAINT fk_lcr_schedule  FOREIGN KEY (Schedule_ID)              REFERENCES dbo.Work_Schedule(Schedule_ID),
    CONSTRAINT fk_lcr_requester FOREIGN KEY (Requester_Employee_ID)    REFERENCES dbo.Employee_Profile(Employee_ID),
    CONSTRAINT fk_lcr_approver  FOREIGN KEY (Approved_By_Employee_ID)  REFERENCES dbo.Employee_Profile(Employee_ID),
    CONSTRAINT chk_lcr_status   CHECK (request_status IN (N'Pending', N'Approved', N'Rejected', N'Cancelled'))
);

CREATE TABLE dbo.Appointment (
    Appointment_ID      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Patient_ID          INT NOT NULL,
    Schedule_ID         INT NOT NULL,
    Staff_Employee_ID   INT NULL,
    Status              NVARCHAR(50) NOT NULL CONSTRAINT DF_Appt_Status DEFAULT (N'Booked'),
    created_at          DATETIME2 NOT NULL CONSTRAINT DF_Appt_Created DEFAULT (SYSUTCDATETIME()),
    checkin_time        DATETIME2 NULL,
    CONSTRAINT fk_appt_patient  FOREIGN KEY (Patient_ID)        REFERENCES dbo.Patient(Patient_ID),
    CONSTRAINT fk_appt_schedule FOREIGN KEY (Schedule_ID)       REFERENCES dbo.Work_Schedule(Schedule_ID),
    CONSTRAINT fk_appt_staff    FOREIGN KEY (Staff_Employee_ID) REFERENCES dbo.Employee_Profile(Employee_ID),
    CONSTRAINT chk_appt_status  CHECK (Status IN (N'Booked', N'Checked-In', N'In-Progress', N'Completed', N'Cancelled', N'No-Show'))
);

CREATE TABLE dbo.Medical_Record (
    Record_ID           INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Appointment_ID      INT NOT NULL UNIQUE,
    Doctor_Employee_ID  INT NOT NULL,
    Clinical_Diagnosis  NVARCHAR(MAX) NULL,
    examination_result  NVARCHAR(MAX) NULL,
    conclusion          NVARCHAR(MAX) NULL,
    Created_At          DATETIME2 NOT NULL CONSTRAINT DF_MR_Created DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT fk_mr_appointment FOREIGN KEY (Appointment_ID)      REFERENCES dbo.Appointment(Appointment_ID),
    CONSTRAINT fk_mr_doctor      FOREIGN KEY (Doctor_Employee_ID)  REFERENCES dbo.Employee_Profile(Employee_ID)
);

CREATE TABLE dbo.Service (
    Service_ID      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Service_Name    NVARCHAR(255) NOT NULL,
    Actual_Price    DECIMAL(12,2) NOT NULL,
    Created_At      DATETIME2 NOT NULL CONSTRAINT DF_Service_Created DEFAULT (SYSUTCDATETIME()),
    Update_At       DATETIME2 NOT NULL CONSTRAINT DF_Service_Updated DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT chk_service_price CHECK (Actual_Price >= 0)
);

CREATE TABLE dbo.Procedure_Order (
    Order_ID                INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Specialist_Employee_ID  INT NULL,
    Record_ID               INT NOT NULL,
    Service_ID              INT NOT NULL,
    Status                  NVARCHAR(50) NOT NULL CONSTRAINT DF_PO_Status DEFAULT (N'Pending'),
    CONSTRAINT fk_po_specialist FOREIGN KEY (Specialist_Employee_ID) REFERENCES dbo.Employee_Profile(Employee_ID),
    CONSTRAINT fk_po_record     FOREIGN KEY (Record_ID)              REFERENCES dbo.Medical_Record(Record_ID),
    CONSTRAINT fk_po_service    FOREIGN KEY (Service_ID)             REFERENCES dbo.Service(Service_ID),
    CONSTRAINT chk_po_status    CHECK (Status IN (N'Pending', N'In-Progress', N'Completed', N'Cancelled'))
);

CREATE TABLE dbo.Prescription (
    Prescription_ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Record_ID       INT NOT NULL,
    Doctor_Notes    NVARCHAR(MAX) NULL,
    created_at      DATETIME2 NOT NULL CONSTRAINT DF_Pres_Created DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT fk_pres_record FOREIGN KEY (Record_ID) REFERENCES dbo.Medical_Record(Record_ID)
);

CREATE TABLE dbo.Prescription_Detail (
    Detail_ID           INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Prescription_ID     INT NOT NULL,
    Quantity            INT NOT NULL,
    Dosage_Instruction  NVARCHAR(MAX) NULL,
    Medicine_Name       NVARCHAR(255) NOT NULL,
    CONSTRAINT fk_pd_prescription FOREIGN KEY (Prescription_ID) REFERENCES dbo.Prescription(Prescription_ID) ON DELETE CASCADE,
    CONSTRAINT chk_prescription_qty_positive CHECK (Quantity > 0)
);

CREATE TABLE dbo.Master_Invoice (
    Invoice_ID      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Appointment_ID  INT NOT NULL UNIQUE,
    Total_Amount    DECIMAL(12,2) NOT NULL,
    Deposit_Amount  DECIMAL(12,2) NULL,
    Balance_Due     DECIMAL(12,2) NOT NULL,
    Status          NVARCHAR(50) NOT NULL CONSTRAINT DF_Invoice_Status DEFAULT (N'Unpaid'),
    Create_At       DATETIME2 NOT NULL CONSTRAINT DF_Invoice_Created DEFAULT (SYSUTCDATETIME()),
    Close_At        DATETIME2 NULL,
    CONSTRAINT fk_invoice_appointment       FOREIGN KEY (Appointment_ID) REFERENCES dbo.Appointment(Appointment_ID),
    CONSTRAINT chk_invoice_total_nonneg     CHECK (Total_Amount >= 0),
    CONSTRAINT chk_invoice_deposit_nonneg   CHECK (Deposit_Amount IS NULL OR Deposit_Amount >= 0),
    CONSTRAINT chk_invoice_balance_nonneg   CHECK (Balance_Due >= 0),
    CONSTRAINT chk_invoice_deposit_le_total CHECK (Deposit_Amount IS NULL OR Deposit_Amount <= Total_Amount),
    CONSTRAINT chk_invoice_balance_le_total CHECK (Balance_Due <= Total_Amount),
    CONSTRAINT chk_invoice_status           CHECK (Status IN (N'Unpaid', N'Partially Paid', N'Paid', N'Refunded', N'Cancelled', N'Closed'))
);

CREATE TABLE dbo.Payment_Transaction (
    Transaction_ID  INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Invoice_ID      INT NOT NULL,
    Amount          DECIMAL(12,2) NOT NULL,
    Gateway_Status  NVARCHAR(50) NULL,
    Trans_Date      DATETIME2 NOT NULL CONSTRAINT DF_Pay_TransDate DEFAULT (SYSUTCDATETIME()),
    Payment_Gateway NVARCHAR(50) NULL,
    CONSTRAINT fk_pt_invoice              FOREIGN KEY (Invoice_ID) REFERENCES dbo.Master_Invoice(Invoice_ID),
    CONSTRAINT chk_payment_amount_positive CHECK (Amount > 0),
    CONSTRAINT chk_payment_gateway_status  CHECK (Gateway_Status IS NULL OR Gateway_Status IN (N'Pending', N'Success', N'Failed', N'Cancelled', N'Refunded'))
);

CREATE TABLE dbo.Refund_Request (
    Refund_ID               INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Invoice_ID              INT NOT NULL,
    created_by_employee_id  INT NOT NULL,
    approved_by_employee_id INT NULL,
    Patient_ID              INT NOT NULL,
    Refund_Amount           DECIMAL(12,2) NOT NULL,
    Reason                  NVARCHAR(MAX) NULL,
    Status                  NVARCHAR(50) NOT NULL CONSTRAINT DF_Refund_Status DEFAULT (N'Pending'),
    Created_At              DATETIME2 NOT NULL CONSTRAINT DF_Refund_Created DEFAULT (SYSUTCDATETIME()),
    Update_At               DATETIME2 NOT NULL CONSTRAINT DF_Refund_Updated DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT fk_rr_invoice     FOREIGN KEY (Invoice_ID)               REFERENCES dbo.Master_Invoice(Invoice_ID),
    CONSTRAINT fk_rr_created_by  FOREIGN KEY (created_by_employee_id)   REFERENCES dbo.Employee_Profile(Employee_ID),
    CONSTRAINT fk_rr_approved_by FOREIGN KEY (approved_by_employee_id)  REFERENCES dbo.Employee_Profile(Employee_ID),
    CONSTRAINT fk_rr_patient     FOREIGN KEY (Patient_ID)               REFERENCES dbo.Patient(Patient_ID),
    CONSTRAINT chk_refund_amount_positive CHECK (Refund_Amount > 0),
    CONSTRAINT chk_refund_status CHECK (Status IN (N'Pending', N'Approved', N'Rejected', N'Completed', N'Cancelled'))
);


-- =========================================================
-- PHẦN 2: DỮ LIỆU MẪU (DUMMY DATA)
-- =========================================================

INSERT INTO dbo.Role (Role_Name) VALUES
(N'Admin'), (N'Doctor'), (N'Specialist'), (N'Staff'), (N'Patient'),(N'Director');


INSERT INTO dbo.Account (Role_ID, Email, Password, Auth_Provider, Account_Status) VALUES
(1, N'admin@clinic.com',            N'123', N'Local',  N'Active'),
(2, N'bs.nguyenminh@clinic.com',    N'123', N'Local',  N'Active'),
(2, N'bs.tranthihanh@clinic.com',   N'123', N'Local',  N'Active'),
(2, N'bs.phamthilan@clinic.com',    N'123', N'Local',  N'Active'),
(2, N'bs.voquangminh@clinic.com',   N'123', N'Local',  N'Active'),
(2, N'bs.dothibich@clinic.com',     N'123', N'Local',  N'Active'),
(2, N'bs.nguyenvanhung@clinic.com', N'123', N'Local',  N'Active'),
(2, N'bs.lethimai@clinic.com',      N'123', N'Local',  N'Active'),
(2, N'bs.hoangvanlong@clinic.com',  N'123', N'Local',  N'Active'),
(2, N'bs.phamthuyduong@clinic.com', N'123', N'Local',  N'Active'),
(2, N'bs.tranquocbao@clinic.com',   N'123', N'Local',  N'Active'),
(3, N'ktv.phamvanhung@clinic.com',  N'123', N'Local',  N'Active'),
(3, N'ktv.lethithuy@clinic.com',    N'123', N'Local',  N'Active'),
(3, N'ktv.nguyenvanduc@clinic.com', N'123', N'Local',  N'Active'),
(4, N'nv.hoanganh@clinic.com',      N'123', N'Local',  N'Active'),
(4, N'nv.nguyenthu@clinic.com',     N'123', N'Local',  N'Active'),
(5, N'bn.nguyenvanan@gmail.com',    N'123', N'Google', N'Active'),
(5, N'bn.tranthimai@gmail.com',     N'123', N'Local',  N'Active'),
(5, N'bn.lequanghuy@gmail.com',     N'123', N'Local',  N'Active'),
(5, N'bn.phamthihoa@gmail.com',     N'123', N'Local',  N'Active'),
(5, N'bn.vuducthanh@gmail.com',     N'123', N'Local',  N'Active'),
(5, N'bn.ngothanhtam@gmail.com',    N'123', N'Local',  N'Active');

INSERT INTO dbo.Patient (Account_ID, Full_Name, Phone, DOB, Address) VALUES
(17, N'Nguyễn Văn An',  N'0912345678', '1985-03-12', N'25 Nguyễn Trãi, Quận 1, TP.HCM'),
(18, N'Trần Thị Mai',   N'0987654321', '1992-07-25', N'48 Lê Lợi, Quận 3, TP.HCM'),
(19, N'Lê Quang Huy',   N'0909123456', '1978-11-05', N'102 Cách Mạng Tháng 8, Quận 10, TP.HCM'),
(20, N'Phạm Thị Hoa',   N'0933111222', '2015-04-20', N'15 Pasteur, Quận 3, TP.HCM'),
(21, N'Vũ Đức Thành',   N'0944555666', '1960-01-08', N'88 Nguyễn Đình Chiểu, Quận 3, TP.HCM'),
(22, N'Ngô Thanh Tâm',  N'0977888999', '1988-09-14', N'12 Hoàng Văn Thụ, Tân Bình, TP.HCM');

INSERT INTO dbo.Employee_Profile (Account_ID, Room_ID, Full_Name, Phone, Specialty, License_Number) VALUES
(1,  NULL, N'Nguyễn Quản Trị',     '0900111222', N'Quản trị hệ thống',                   NULL),
(2,  1,    N'BS. Nguyễn Minh',     '0911222333', N'Nhãn khoa Tổng quát',                 N'NK-2020-001'),
(3,  3,    N'BS. Trần Thị Hạnh',   '0922333444', N'Phẫu thuật đục thủy tinh thể (Phaco)',N'NK-2018-015'),
(4,  5,    N'BS. Phạm Thị Lan',    '0933444555', N'Glaucoma (Cườm nước)',                N'NK-2017-022'),
(5,  3,    N'BS. Võ Quang Minh',   '0944555666', N'Võng mạc & Thị thần kinh',            N'NK-2016-009'),
(6,  6,    N'BS. Đỗ Thị Bích',     '0955666777', N'Nhãn khoa Nhi',                       N'NK-2019-031'),
(7,  3,    N'BS. Nguyễn Văn Hùng', '0966777888', N'Phẫu thuật tạo hình mi mắt',          N'NK-2015-004'),
(8,  1,    N'BS. Lê Thị Mai',      '0977888999', N'Nhãn khoa Tổng quát',                 N'NK-2021-018'),
(9,  3,    N'BS. Hoàng Văn Long',  '0988999000', N'Phẫu thuật Lasik / Khúc xạ',          N'NK-2019-027'),
(10, 5,    N'BS. Phạm Thùy Dương', '0999000111', N'Giác mạc & Bệnh khô mắt',             N'NK-2020-033'),
(11, 3,    N'BS. Trần Quốc Bảo',   '0901111222', N'U nội nhãn & Hốc mắt',                N'NK-2014-008'),
(12, 2,    N'Phạm Văn Hùng',       '0912222333', N'Kỹ thuật viên Khúc xạ',               N'KT-2021-008'),
(13, 4,    N'Lê Thị Thủy',         '0923333444', N'Kỹ thuật viên Siêu âm & Xét nghiệm',  N'KT-2022-012'),
(14, 2,    N'Nguyễn Văn Đức',      '0934444555', N'Kỹ thuật viên Đo thị lực',            N'KT-2023-005'),
(15, NULL, N'Hoàng Anh',           '0945555666', N'Lễ tân & Điều phối',                  NULL),
(16, NULL, N'Nguyễn Thu',          '0956666777', N'Thu ngân & Chăm sóc khách hàng',      NULL);

DECLARE @Today DATE = CAST(GETDATE() AS DATE);
DECLARE @Tomorrow DATE = DATEADD(DAY, 1, @Today);

INSERT INTO dbo.Work_Schedule (Doctor_Employee_ID, Specialist_Employee_ID, Work_Date, Start_Time, End_Time, Slot, Status) VALUES
(2,    NULL, @Today, '08:00:00', '08:30:00', 1, N'Booked'),
(2,    NULL, @Today, '08:30:00', '09:00:00', 1, N'Booked'),
(2,    NULL, @Today, '09:00:00', '09:30:00', 1, N'Booked'),
(8,    NULL, @Today, '08:00:00', '12:00:00', 0, N'Available'),
(3,    NULL, @Today, '07:30:00', '11:30:00', 0, N'Available'),
(4,    NULL, @Today, '08:00:00', '12:00:00', 0, N'Available'),
(5,    NULL, @Today, '13:00:00', '17:00:00', 0, N'Available'),
(6,    NULL, @Today, '08:00:00', '12:00:00', 0, N'Available'),
(7,    NULL, @Today, '13:00:00', '16:00:00', 0, N'Available'),
(9,    NULL, @Today, '08:00:00', '12:00:00', 0, N'Available'),
(10,   NULL, @Today, '13:00:00', '17:00:00', 0, N'Available'),
(11,   NULL, @Today, '08:00:00', '12:00:00', 0, N'Available'),
(NULL, 12,   @Today, '08:00:00', '12:00:00', 0, N'OnLeave'),
(NULL, 13,   @Today, '08:00:00', '12:00:00', 0, N'Available'),
(NULL, 14,   @Today, '13:00:00', '17:00:00', 0, N'Available'),
(6,    NULL, @Today, '08:00:00', '08:30:00', 1, N'Booked'),
(4,    NULL, @Today, '13:00:00', '13:30:00', 1, N'Booked'),
(9,    NULL, @Today, '09:00:00', '09:30:00', 1, N'Booked'),
(5,    NULL, @Tomorrow, '08:00:00', '08:30:00', 1, N'Available');

DECLARE @Today2 DATE = CAST(GETDATE() AS DATE);
INSERT INTO dbo.Leave_Cancel_Request
    (Schedule_ID, Requester_Employee_ID, Approved_By_Employee_ID, leave_Date, Reason, request_status, approved_at)
VALUES
(13, 12, 2,    @Today2, N'Máy đo khúc xạ đang bảo trì định kỳ', N'Approved', SYSUTCDATETIME()),
(12, 11, NULL, @Today2, N'Đi hội nghị nhãn khoa khu vực',       N'Pending',  NULL);

INSERT INTO dbo.Appointment (Patient_ID, Schedule_ID, Staff_Employee_ID, Status, checkin_time) VALUES
(1, 1,  15, N'Checked-In', SYSUTCDATETIME()),
(2, 2,  15, N'Checked-In', SYSUTCDATETIME()),
(3, 3,  16, N'Completed',  DATEADD(MINUTE, -40, SYSUTCDATETIME())),
(4, 16, 15, N'Checked-In', SYSUTCDATETIME()),
(5, 17, 16, N'Checked-In', SYSUTCDATETIME()),
(6, 18, 15, N'Booked',     NULL);

INSERT INTO dbo.Medical_Record (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis, examination_result, conclusion) VALUES
(1, 2, N'Mờ mắt 2 bên, nhìn gần khó khăn',
 N'Thị lực mắt phải 4/10, mắt trái 5/10. Có dấu hiệu đục thủy tinh thể giai đoạn đầu. Nhãn áp bình thường.',
 N'Đục thủy tinh thể độ 1 hai mắt – Theo dõi và điều trị nội khoa'),
(2, 2, N'Mỏi mắt, nhìn xa mờ khi làm việc máy tính',
 N'Cận thị nhẹ 2 mắt. Giác mạc khô độ 1. Nhãn áp 16 mmHg.',
 N'Cận thị – hội chứng khô mắt. Tư vấn nhỏ nước mắt nhân tạo, tái khám 3 tháng'),
(3, 2, N'Tái khám sau điều trị viêm kết mạc',
 N'Kết mạc hết sung huyết. Thị lực 8/10 hai mắt. Nhãn áp 15 mmHg.',
 N'Ổn định. Tiếp tục nhỏ nước mắt nhân tạo khi khô mắt'),
(4, 6, N'Trẻ nheo mắt, ngồi gần tivi',
 N'Thị lực chưa chỉnh: MP 6/10, MT 7/10. Khúc xạ cận nhẹ. Đáy mắt bình thường.',
 N'Cận thị nhi – theo dõi, tư vấn vệ sinh thị giác'),
(5, 4, N'Nhìn đèn có quầng, đau đầu vùng trán',
 N'Nhãn áp MP 26 mmHg, MT 24 mmHg. Góc tiền phòng hẹp. Đĩa thị lõm C/D 0.6.',
 N'Nghi ngờ glaucoma góc đóng mạn – đo nhãn áp, điều trị hạ nhãn áp');

INSERT INTO dbo.Service (Service_Name, Actual_Price) VALUES
(N'Khám mắt tổng quát', 250000),
(N'Đo khúc xạ & thị lực', 150000),
(N'Siêu âm mắt A/B', 350000),
(N'Đo nhãn áp không tiếp xúc', 100000),
(N'Phẫu thuật phaco đục thủy tinh thể', 18000000),
(N'Tiêm nội nhãn Anti-VEGF', 8500000),
(N'Phẫu thuật Lasik 2 mắt', 25000000),
(N'Khám glaucoma chuyên sâu', 400000);

INSERT INTO dbo.Procedure_Order (Specialist_Employee_ID, Record_ID, Service_ID, Status) VALUES
(2, 1, 1, N'Completed'), (12, 1, 2, N'Completed'), (13, 1, 3, N'Completed'),
(2, 2, 1, N'Completed'), (14, 2, 2, N'Completed'),
(2, 3, 1, N'Completed'), (13, 3, 4, N'Completed'),
(6, 4, 1, N'Completed'), (14, 4, 2, N'In-Progress'),
(4, 5, 8, N'Completed'), (13, 5, 4, N'Completed');

INSERT INTO dbo.Prescription (Record_ID, Doctor_Notes) VALUES
(1, N'Dùng thuốc nhỏ mắt đúng giờ. Tái khám sau 1 tháng hoặc khi giảm thị lực đột ngột.'),
(2, N'Hạn chế dùng điện thoại liên tục. Nhỏ nước mắt nhân tạo khi khô, mỏi mắt.'),
(3, N'Ổn định. Tái khám định kỳ 6 tháng.'),
(4, N'Không ngồi gần màn hình. Tái khám khúc xạ sau 6 tháng.'),
(5, N'Nhỏ thuốc hạ nhãn áp đúng giờ. Tái khám sau 1 tuần.');

INSERT INTO dbo.Prescription_Detail (Prescription_ID, Quantity, Dosage_Instruction, Medicine_Name) VALUES
(1, 1,  N'Nhỏ 1 giọt/lần, ngày 4 lần', N'Tobradex 5ml'),
(1, 1,  N'Nhỏ 1 giọt/lần, ngày 3 lần', N'Systane Ultra 10ml'),
(1, 30, N'Uống 1 viên/ngày sau ăn sáng', N'Vitamin A - Lutein'),
(2, 1,  N'Nhỏ 1 giọt/lần, ngày 4 lần', N'Systane Ultra 10ml'),
(2, 1,  N'Nhỏ 1 giọt buổi tối', N'Refresh Plus'),
(3, 1,  N'Nhỏ khi khô mắt, ngày 2–3 lần', N'Systane Ultra 10ml'),
(4, 1,  N'Nhỏ 1 giọt/lần, ngày 3 lần', N'Tears Naturale II'),
(5, 1,  N'Nhỏ 1 giọt mắt phải, ngày 2 lần', N'Timolol 0.5%'),
(5, 1,  N'Nhỏ 1 giọt/lần, ngày 1 lần buổi tối', N'Latanoprost 0.005%');

INSERT INTO dbo.Master_Invoice (Appointment_ID, Total_Amount, Deposit_Amount, Balance_Due, Status, Close_At) VALUES
(1, 750000, NULL,  0,      N'Paid',            SYSUTCDATETIME()),
(2, 400000, NULL,  400000, N'Unpaid',          NULL),
(3, 350000, 50000, 150000, N'Partially Paid',  NULL),
(4, 400000, NULL,  400000, N'Unpaid',          NULL),
(5, 500000, NULL,  0,      N'Paid',            SYSUTCDATETIME());

INSERT INTO dbo.Payment_Transaction (Invoice_ID, Amount, Gateway_Status, Payment_Gateway) VALUES
(1, 750000, N'Success', N'VNPAY'),
(3, 200000, N'Success', N'MOMO'),
(3, 150000, N'Failed',  N'CASH'),
(5, 500000, N'Success', N'VNPAY'),
(4, 100000, N'Pending', N'BANK');

INSERT INTO dbo.Refund_Request
    (Invoice_ID, created_by_employee_id, approved_by_employee_id, Patient_ID, Refund_Amount, Reason, Status)
VALUES
(1, 15, 2,    1, 150000, N'Bệnh nhân yêu cầu hoàn phí đo khúc xạ do máy tạm ngưng', N'Pending'),
(5, 16, NULL, 5, 100000, N'BN xin hoàn phí đo nhãn áp vì đã đo ở nơi khác', N'Pending');
