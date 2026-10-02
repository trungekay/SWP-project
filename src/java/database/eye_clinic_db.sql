USE master;
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'eye_clinic_db_v2')
BEGIN
    ALTER DATABASE eye_clinic_db_v2 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE eye_clinic_db_v2;
END
GO
CREATE DATABASE eye_clinic_db_v2;
GO
USE eye_clinic_db_v2;
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

CREATE TABLE Room (
    Room_ID     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Room_Name   NVARCHAR(100) NOT NULL UNIQUE,
    address     NVARCHAR(255) NULL,
    hotline     NVARCHAR(20) NULL,
    status      NVARCHAR(50) NOT NULL DEFAULT (N'Available'),
    created_at  DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
    updated_at  DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME())
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
    Specialty       NVARCHAR(100) NULL,
    License_Number  NVARCHAR(100) NULL,
    FOREIGN KEY (Account_ID) REFERENCES Account(Account_ID),
    FOREIGN KEY (Room_ID)    REFERENCES Room(Room_ID)
);

CREATE TABLE Work_Schedule (
    Schedule_ID             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Doctor_Employee_ID      INT NULL,
    Specialist_Employee_ID  INT NULL,
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
    CHECK (Account_Status IN (N'Active', N'Inactive', N'Banned', N'Locked'));
ALTER TABLE Room ADD CONSTRAINT CHK_Room_Status
    CHECK (status IN (N'Available', N'Maintenance', N'Closed'));
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

INSERT INTO Room (Room_Name, address, hotline, status) VALUES
(N'Cơ sở Quận 1',     N'25 Nguyễn Trãi, Quận 1, TP.HCM',     N'1900-0101', N'Available'),
(N'Cơ sở Quận 3',     N'48 Lê Lợi, Quận 3, TP.HCM',          N'1900-0103', N'Available'),
(N'Cơ sở Tân Bình',   N'12 Hoàng Văn Thụ, Tân Bình, TP.HCM', N'1900-0104', N'Available');

INSERT INTO Account (Role_ID, Email, Password, Auth_Provider, Account_Status) VALUES
(1, N'admin@eyeclinic.com',          N'123', N'Local', N'Active'),
(2, N'director@eyeclinic.com',       N'123', N'Local', N'Active'),
(3, N'doctor.nam@eyeclinic.com',     N'123', N'Local', N'Active'),
(4, N'specialist.hoa@eyeclinic.com', N'123', N'Local', N'Active'),
(5, N'staff.lan@eyeclinic.com',      N'123', N'Local', N'Active'),
(6, N'patient.an@gmail.com',         N'123', N'Local', N'Active'),
(3, N'doctor.tinh@eyeclinic.com',    N'123', N'Local', N'Active'),
(3, N'doctor.lan2@eyeclinic.com',    N'123', N'Local', N'Active'),
(3, N'doctor.huy@eyeclinic.com',     N'123', N'Local', N'Active'),
(3, N'doctor.ngoc@eyeclinic.com',    N'123', N'Local', N'Active');

INSERT INTO Patient (Account_ID, Full_Name, Phone, DOB, Address) VALUES
(6,    N'Nguyễn Văn An',  N'0901234567', '1995-05-15', N'123 Lê Lợi, Q.1, TP.HCM'),
(NULL, N'Trần Thị Bình',  N'0918765432', '1988-10-20', N'456 Nguyễn Huệ, Q.1, TP.HCM');

INSERT INTO Employee_Profile (Account_ID, Room_ID, Full_Name, Phone, Specialty, License_Number) VALUES
(1,  NULL, N'Quản trị viên Hệ thống',     NULL, N'Quản trị hệ thống',     NULL),
(2,  NULL, N'Nguyễn Văn Giám Đốc',        NULL, N'Giám đốc',              NULL),
(3,  1,    N'BS. Trần Văn Nam',           NULL, N'Khám mắt tổng quát',    N'BS-12345/EYE'),
(4,  3,    N'KTV. Lê Thị Hoa',            NULL, N'Chẩn đoán hình ảnh',    NULL),
(5,  NULL, N'Lễ Tân Phạm Thị Lan',        NULL, N'Thu Ngân & Tiếp Đón',   NULL),
(7,  1,    N'TS.BS. Nguyễn Xuân Tịnh',    NULL, N'Khúc xạ & Kính',        N'BS-56789/EYE'),
(8,  1,    N'ThS.BS. Lê Hoàng Lan',       NULL, N'Phẫu thuật LASIK',      N'BS-98765/EYE'),
(9,  1,    N'BSCKII. Trần Quang Huy',     NULL, N'Đục thủy tinh thể',     N'BS-45678/EYE'),
(10, 1,    N'BS. Phạm Bảo Ngọc',          NULL, N'Nhãn khoa trẻ em',      N'BS-34567/EYE');

INSERT INTO Work_Schedule
    (Doctor_Employee_ID, Specialist_Employee_ID, Work_Date, Slot, Start_Time, End_Time, Status)
VALUES
(3,    NULL, '2026-04-01', N'Slot 1', '08:00:00', '08:30:00', N'Available'),
(3,    NULL, '2026-04-01', N'Slot 2', '08:30:00', '09:00:00', N'Available'),
(3,    NULL, '2026-04-01', N'Slot 3', '09:00:00', '09:30:00', N'Available'),
(3,    NULL, '2026-04-01', N'Slot 4', '09:30:00', '10:00:00', N'Available'),
(NULL, 4,    '2026-04-01', N'Slot 1', '08:00:00', '08:30:00', N'Available');

INSERT INTO Leave_Cancel_Request
    (Schedule_ID, Requester_Employee_ID, Approved_By_Employee_ID, leave_Date, Reason, request_status, approved_at)
VALUES
(3, 3, 2, '2026-04-01', N'Bác sĩ bận họp đột xuất', N'Pending', NULL);

INSERT INTO Appointment (Patient_ID, Schedule_ID, Staff_Employee_ID, Status, created_at, checkin_time) VALUES
(1, 1, 5, N'Completed', SYSUTCDATETIME(), SYSUTCDATETIME()),
(2, 2, 5, N'Pending',   SYSUTCDATETIME(), NULL);

INSERT INTO Medical_Record
    (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis, examination_result, conclusion)
VALUES
(1, 3, N'Mắt phải cận thị 1.5 độ, viêm kết mạc nhẹ', NULL, NULL);

INSERT INTO Service (Service_Name, Actual_Price) VALUES
(N'Khám mắt tổng quát', 200000),
(N'Đo khúc xạ máy',     100000),
(N'Chụp OCT đáy mắt',   400000);

INSERT INTO Procedure_Order (Specialist_Employee_ID, Record_ID, Service_ID, Status) VALUES
(4, 1, 2, N'Completed');

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
(1, 5, 2, 1, 50000, N'Bệnh nhân hủy dịch vụ phát sinh thêm', N'Approved');
GO
