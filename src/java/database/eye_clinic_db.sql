CREATE DATABASE eye_clinic_db;
GO
USE eye_clinic_db;
GO

-- TẠO BẢNG DANH MỤC & CẤU HÌNH (MASTER DATA)

CREATE TABLE Role (
    Role_ID INT IDENTITY(1,1) PRIMARY KEY,
    Role_Name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Room (
    Room_ID INT IDENTITY(1,1) PRIMARY KEY,
    Room_Name NVARCHAR(100) NOT NULL
);

-- TẠO BẢNG TÀI KHOẢN & HỒ SƠ (USERS)

CREATE TABLE Account (
    Account_ID INT IDENTITY(1,1) PRIMARY KEY,
    Role_ID INT NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    Auth_Provider VARCHAR(50) DEFAULT 'Local',
    Account_Status VARCHAR(50) DEFAULT 'Active',
    FOREIGN KEY (Role_ID) REFERENCES Role(Role_ID)
);

CREATE TABLE System_Admin (
    Admin_ID INT IDENTITY(1,1) PRIMARY KEY,
    Account_ID INT NOT NULL UNIQUE,
    Full_Name NVARCHAR(255) NOT NULL,
    -- (Đã xóa cột Price bất hợp lý)
    FOREIGN KEY (Account_ID) REFERENCES Account(Account_ID)
);

CREATE TABLE Service_Catalog (
    Service_ID INT IDENTITY(1,1) PRIMARY KEY,
    Created_By INT NULL, -- Đổi từ Admin_ID thành Created_By
    Service_Name NVARCHAR(255) NOT NULL,
    Price DECIMAL(18,0) NOT NULL,
    FOREIGN KEY (Created_By) REFERENCES Account(Account_ID)
);

CREATE TABLE Director (
    Director_ID INT IDENTITY(1,1) PRIMARY KEY,
    Account_ID INT NOT NULL UNIQUE,
    Full_Name NVARCHAR(255) NOT NULL,
    FOREIGN KEY (Account_ID) REFERENCES Account(Account_ID)
);

CREATE TABLE Staff (
    Staff_ID INT IDENTITY(1,1) PRIMARY KEY,
    Account_ID INT NOT NULL UNIQUE,
    Full_Name NVARCHAR(255) NOT NULL,
    Position NVARCHAR(100) NULL,
    FOREIGN KEY (Account_ID) REFERENCES Account(Account_ID)
);

CREATE TABLE Medical_Specialist (
    Specialist_ID INT IDENTITY(1,1) PRIMARY KEY,
    Account_ID INT NOT NULL UNIQUE,
    Full_Name NVARCHAR(255) NOT NULL,
    Specialty NVARCHAR(100) NULL,
    FOREIGN KEY (Account_ID) REFERENCES Account(Account_ID)
);

CREATE TABLE Doctor (
    Doctor_ID INT IDENTITY(1,1) PRIMARY KEY,
    Account_ID INT NOT NULL UNIQUE,
    Full_Name NVARCHAR(255) NOT NULL,
    License_Number VARCHAR(100) NOT NULL UNIQUE,
    Room_ID INT NULL,
    FOREIGN KEY (Account_ID) REFERENCES Account(Account_ID),
    FOREIGN KEY (Room_ID) REFERENCES Room(Room_ID)
);

CREATE TABLE Patient (
    Patient_ID INT IDENTITY(1,1) PRIMARY KEY,
    Account_ID INT NULL UNIQUE, -- (Đã thêm Account_ID để Patient có thể đăng nhập)
    Full_Name NVARCHAR(255) NOT NULL,
    Phone VARCHAR(20) NOT NULL UNIQUE,
    DOB DATE NULL,
    Address NVARCHAR(500) NULL,
    FOREIGN KEY (Account_ID) REFERENCES Account(Account_ID)
);

-- TẠO BẢNG LỊCH TRÌNH & NGHỈ PHÉP

CREATE TABLE Work_Schedule (
    Schedule_ID INT IDENTITY(1,1) PRIMARY KEY,
    Doctor_ID INT NULL,
    Specialist_ID INT NULL,
    Staff_ID INT NULL,
    Work_Date DATE NOT NULL,
    Slot VARCHAR(50) NOT NULL,
    Start_Time TIME(0) NOT NULL,   
    End_Time TIME(0) NOT NULL,      
    Session VARCHAR(20) NOT NULL DEFAULT 'Morning',
    Status VARCHAR(50) DEFAULT 'Available',
    FOREIGN KEY (Doctor_ID) REFERENCES Doctor(Doctor_ID),
    FOREIGN KEY (Specialist_ID) REFERENCES Medical_Specialist(Specialist_ID),
    FOREIGN KEY (Staff_ID) REFERENCES Staff(Staff_ID)
);

CREATE TABLE Leave_Cancel_Request (
    Request_ID INT IDENTITY(1,1) PRIMARY KEY,
    Schedule_ID INT NOT NULL UNIQUE,
    Doctor_ID INT NULL,
    Specialist_ID INT NULL,
    Staff_ID INT NULL,
    Director_ID INT NULL,
    Reason NVARCHAR(MAX) NOT NULL,
    Approval_Status VARCHAR(50) DEFAULT 'Pending',
    FOREIGN KEY (Schedule_ID) REFERENCES Work_Schedule(Schedule_ID),
    FOREIGN KEY (Doctor_ID) REFERENCES Doctor(Doctor_ID),
    FOREIGN KEY (Specialist_ID) REFERENCES Medical_Specialist(Specialist_ID),
    FOREIGN KEY (Staff_ID) REFERENCES Staff(Staff_ID),
    FOREIGN KEY (Director_ID) REFERENCES Director(Director_ID)
);

-- TẠO BẢNG ĐẶT KHÁM & LÂM SÀNG

CREATE TABLE Appointment (
    Appointment_ID INT IDENTITY(1,1) PRIMARY KEY,
    Patient_ID INT NOT NULL,
    Schedule_ID INT NOT NULL,
    Staff_ID INT NULL,
    Status VARCHAR(50) DEFAULT 'Pending',
    Created_At DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID),
    FOREIGN KEY (Schedule_ID) REFERENCES Work_Schedule(Schedule_ID),
    FOREIGN KEY (Staff_ID) REFERENCES Staff(Staff_ID)
);

CREATE TABLE Medical_Record (
    Record_ID INT IDENTITY(1,1) PRIMARY KEY,
    Appointment_ID INT NOT NULL UNIQUE,
    Doctor_ID INT NOT NULL,
    Clinical_Diagnosis NVARCHAR(MAX) NULL,
    Created_At DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (Appointment_ID) REFERENCES Appointment(Appointment_ID),
    FOREIGN KEY (Doctor_ID) REFERENCES Doctor(Doctor_ID)
);

CREATE TABLE Procedure_Order (
    Order_ID INT IDENTITY(1,1) PRIMARY KEY,
    Record_ID INT NOT NULL,
    Service_ID INT NOT NULL,
    Specialist_ID INT NULL,
    Status VARCHAR(50) DEFAULT 'Pending',
    Actual_Price DECIMAL(18,0) NOT NULL, -- (Đã thêm Actual_Price để lưu giá tại thời điểm chỉ định)
    FOREIGN KEY (Record_ID) REFERENCES Medical_Record(Record_ID),
    FOREIGN KEY (Service_ID) REFERENCES Service_Catalog(Service_ID),
    FOREIGN KEY (Specialist_ID) REFERENCES Medical_Specialist(Specialist_ID)
);

CREATE TABLE Prescription (
    Prescription_ID INT IDENTITY(1,1) PRIMARY KEY,
    Record_ID INT NOT NULL UNIQUE,
    Doctor_Notes NVARCHAR(MAX) NULL,
    FOREIGN KEY (Record_ID) REFERENCES Medical_Record(Record_ID)
);

CREATE TABLE Prescription_Detail (
    Detail_ID INT IDENTITY(1,1) PRIMARY KEY,
    Prescription_ID INT NOT NULL,
    Medicine_Name NVARCHAR(255) NOT NULL,
    Quantity INT NOT NULL,
    Dosage_Instruction NVARCHAR(MAX) NULL,
    FOREIGN KEY (Prescription_ID) REFERENCES Prescription(Prescription_ID) ON DELETE CASCADE
);

-- TẠO BẢNG HÓA ĐƠN & TÀI CHÍNH

CREATE TABLE Master_Invoice (
    Invoice_ID INT IDENTITY(1,1) PRIMARY KEY,
    Appointment_ID INT NOT NULL UNIQUE,
    Total_Amount DECIMAL(18,0) DEFAULT 0,
    Deposit_Amount DECIMAL(18,0) DEFAULT 0,
    Balance_Due DECIMAL(18,0) DEFAULT 0,
    Status VARCHAR(50) DEFAULT 'Pending_Deposit',
    FOREIGN KEY (Appointment_ID) REFERENCES Appointment(Appointment_ID)
);

CREATE TABLE Payment_Transaction (
    Transaction_ID INT IDENTITY(1,1) PRIMARY KEY,
    Invoice_ID INT NOT NULL,
    Amount DECIMAL(18,0) NOT NULL,
    Payment_Method VARCHAR(50) NOT NULL,
    Gateway_Status VARCHAR(50) NOT NULL,
    Trans_Date DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (Invoice_ID) REFERENCES Master_Invoice(Invoice_ID)
);

CREATE TABLE Refund_Request (
    Refund_ID INT IDENTITY(1,1) PRIMARY KEY,
    Invoice_ID INT NOT NULL,
    Patient_ID INT NOT NULL,
    Staff_ID INT NOT NULL,
    Director_ID INT NULL,
    Refund_Amount DECIMAL(18,0) NOT NULL,
    Reason NVARCHAR(MAX) NOT NULL,
    Status VARCHAR(50) DEFAULT 'Pending',
    FOREIGN KEY (Invoice_ID) REFERENCES Master_Invoice(Invoice_ID),
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID),
    FOREIGN KEY (Staff_ID) REFERENCES Staff(Staff_ID),
    FOREIGN KEY (Director_ID) REFERENCES Director(Director_ID)
);

-- THÊM CÁC RÀNG BUỘC (CONSTRAINTS) LOGIC NGHIỆP VỤ

-- Ràng buộc về Tài chính
ALTER TABLE Service_Catalog ADD CONSTRAINT CHK_Service_Price CHECK (Price >= 0);
ALTER TABLE Master_Invoice ADD CONSTRAINT CHK_Total_Amount CHECK (Total_Amount >= 0);
ALTER TABLE Master_Invoice ADD CONSTRAINT CHK_Deposit_Amount CHECK (Deposit_Amount >= 0);
ALTER TABLE Payment_Transaction ADD CONSTRAINT CHK_Transaction_Amount CHECK (Amount > 0);
ALTER TABLE Refund_Request ADD CONSTRAINT CHK_Refund_Amount CHECK (Refund_Amount > 0);
ALTER TABLE Prescription_Detail ADD CONSTRAINT CHK_Medicine_Quantity CHECK (Quantity > 0);
ALTER TABLE Procedure_Order ADD CONSTRAINT CHK_Procedure_Actual_Price CHECK (Actual_Price >= 0);

-- Ràng buộc Lịch làm việc
ALTER TABLE Work_Schedule ADD CONSTRAINT CHK_Schedule_Time CHECK (End_Time > Start_Time);
ALTER TABLE Work_Schedule ADD CONSTRAINT CHK_Slot_30Mins CHECK (DATEDIFF(MINUTE, Start_Time, End_Time) = 30); 
ALTER TABLE Work_Schedule ADD CONSTRAINT CHK_Schedule_Session CHECK (Session IN ('Morning', 'Afternoon', 'Evening', 'Full_Day'));

-- Ràng buộc Trạng thái chuẩn hóa
ALTER TABLE Account ADD CONSTRAINT CHK_Account_Status CHECK (Account_Status IN ('Active', 'Inactive', 'Banned', 'Locked'));
ALTER TABLE Work_Schedule ADD CONSTRAINT CHK_Schedule_Status CHECK (Status IN ('Available', 'Booked', 'Canceled', 'On_Leave'));
ALTER TABLE Appointment ADD CONSTRAINT CHK_Appointment_Status CHECK (Status IN ('Pending', 'Confirmed', 'In_Progress', 'Completed', 'Canceled'));
ALTER TABLE Master_Invoice ADD CONSTRAINT CHK_Invoice_Status CHECK (Status IN ('Pending_Deposit', 'Partial_Paid', 'Paid', 'Refunded', 'Canceled'));
ALTER TABLE Leave_Cancel_Request ADD CONSTRAINT CHK_Approval_Status CHECK (Approval_Status IN ('Pending', 'Approved', 'Rejected'));
GO

--  DỮ LIỆU KHỞI TẠO BAN ĐẦU (SEED DATA CHUẨN 30 PHÚT/SLOT)

INSERT INTO Role (Role_Name) 
VALUES ('System_Admin'), ('Director'), ('Doctor'), ('Medical_Specialist'), ('Staff'), ('Patient');

INSERT INTO Room (Room_Name) 
VALUES (N'Phòng Khám Mắt 101'), (N'Phòng Đo Khúc Xạ 201'), (N'Phòng Chụp OCT 202');

INSERT INTO Account (Role_ID, Email, Password, Auth_Provider, Account_Status) 
VALUES 
(1, 'admin@eyeclinic.com', '123', 'Local', 'Active'),    
(2, 'director@eyeclinic.com', '123', 'Local', 'Active'),
(3, 'doctor.nam@eyeclinic.com', '123', 'Local', 'Active'),
(4, 'specialist.hoa@eyeclinic.com', '123', 'Local', 'Active'),
(5, 'staff.lan@eyeclinic.com', '123', 'Local', 'Active'),
(6, 'patient.an@gmail.com', '123', 'Local', 'Active'); -- Tài khoản bệnh nhân mẫu

INSERT INTO System_Admin (Account_ID, Full_Name) VALUES (1, N'Quản trị viên Hệ thống'); 
INSERT INTO Director (Account_ID, Full_Name) VALUES (2, N'Nguyễn Văn Giám Đốc'); 
INSERT INTO Staff (Account_ID, Full_Name, Position) VALUES (5, N'Lễ Tân Phạm Thị Lan', N'Thu Ngân & Tiếp Đón'); 
INSERT INTO Medical_Specialist (Account_ID, Full_Name, Specialty) VALUES (4, N'KTV. Lê Thị Hoa', N'Chẩn đoán hình ảnh'); 
INSERT INTO Doctor (Account_ID, Full_Name, License_Number, Room_ID) VALUES (3, N'BS. Trần Văn Nam', 'BS-12345/EYE', 1); 

INSERT INTO Patient (Account_ID, Full_Name, Phone, DOB, Address) 
VALUES 
(6, N'Nguyễn Văn An', '0901234567', '1995-05-15', N'123 Lê Lợi, Q.1, TP.HCM'),  
(NULL, N'Trần Thị Bình', '0918765432', '1988-10-20', N'456 Nguyễn Huệ, Q.1, TP.HCM'); -- Khách vãng lai chưa có TK
GO

INSERT INTO Service_Catalog (Created_By, Service_Name, Price) 
VALUES 
(1, N'Khám mắt tổng quát', 200000), 
(1, N'Đo khúc xạ máy', 100000),     
(1, N'Chụp OCT đáy mắt', 400000);   

-- Lịch làm việc được chia theo các khung giờ 30 phút chuẩn
INSERT INTO Work_Schedule (Doctor_ID, Specialist_ID, Staff_ID, Work_Date, Slot, Start_Time, End_Time, Session, Status) 
VALUES 
(1, NULL, NULL, '2026-04-01', N'Slot 1', '08:00:00', '08:30:00', 'Morning', 'Available'), 
(1, NULL, NULL, '2026-04-01', N'Slot 2', '08:30:00', '09:00:00', 'Morning', 'Available'), 
(1, NULL, NULL, '2026-04-01', N'Slot 3', '09:00:00', '09:30:00', 'Morning', 'Available'), 
(1, NULL, NULL, '2026-04-01', N'Slot 4', '09:30:00', '10:00:00', 'Morning', 'Available'), 
(NULL, 1, NULL, '2026-04-01', N'Slot 1', '08:00:00', '08:30:00', 'Morning', 'Available');  

INSERT INTO Leave_Cancel_Request (Schedule_ID, Doctor_ID, Specialist_ID, Staff_ID, Director_ID, Reason, Approval_Status) 
VALUES (3, 1, NULL, NULL, 1, N'Bác sĩ bận họp đột xuất', 'Pending');

INSERT INTO Appointment (Patient_ID, Schedule_ID, Staff_ID, Status, Created_At) 
VALUES 
(1, 1, 1, 'Completed', GETDATE()), 
(2, 2, 1, 'Pending', GETDATE());   

INSERT INTO Medical_Record (Appointment_ID, Doctor_ID, Clinical_Diagnosis, Created_At) 
VALUES (1, 1, N'Mắt phải cận thị 1.5 độ, viêm kết mạc nhẹ', GETDATE()); 

INSERT INTO Procedure_Order (Record_ID, Service_ID, Specialist_ID, Status, Actual_Price) 
VALUES (1, 2, 1, 'Completed', 100000); 

INSERT INTO Prescription (Record_ID, Doctor_Notes) 
VALUES (1, N'Nhỏ thuốc đúng giờ, tái khám sau 7 ngày nếu mắt còn đỏ'); 

INSERT INTO Prescription_Detail (Prescription_ID, Medicine_Name, Quantity, Dosage_Instruction) 
VALUES 
(1, N'Thuốc nhỏ mắt Tobradex', 1, N'Nhỏ 1 giọt/lần, ngày 2 lần vào mắt phải'), 
(1, N'Nước muối sinh lý 0.9%', 2, N'Rửa mắt hàng ngày sáng và tối');          

INSERT INTO Master_Invoice (Appointment_ID, Total_Amount, Deposit_Amount, Balance_Due, Status) 
VALUES (1, 300000, 100000, 0, 'Paid'); 

INSERT INTO Payment_Transaction (Invoice_ID, Amount, Payment_Method, Gateway_Status, Trans_Date) 
VALUES 
(1, 100000, 'VNPay', 'Success', GETDATE()), 
(1, 200000, 'Cash', 'Success', GETDATE());  

INSERT INTO Refund_Request (Invoice_ID, Patient_ID, Staff_ID, Director_ID, Refund_Amount, Reason, Status) 
VALUES (1, 1, 1, 1, 50000, N'Bệnh nhân hủy dịch vụ phát sinh thêm', 'Approved');
