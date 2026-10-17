-- =========================================================================================
-- VISIONCARE CLINIC - SCRIPT NẠP DỮ LIỆU MẪU CHO HÀNG ĐỢI CẬN LÂM SÀNG & THỦ THUẬT
-- =========================================================================================

USE eye_clinic_db;
GO

SET NOCOUNT ON;

-- Dọn dẹp dữ liệu cũ theo đúng thứ tự khóa ngoại
DELETE FROM Refund_Request;
DELETE FROM Payment_Transaction;
DELETE FROM Master_Invoice;
DELETE FROM Prescription_Detail;
DELETE FROM Prescription;
DELETE FROM Procedure_Order;
DELETE FROM Medical_Record;
DELETE FROM Appointment;
GO

-- 1. Appointment 1 (Bệnh nhân Nguyễn Văn An - Patient_ID = 1, BS Trần Văn Nam)
INSERT INTO Appointment (Patient_ID, Schedule_ID, Staff_Employee_ID, Status, created_at, checkin_time)
VALUES (1, 1, 12, N'In_Progress', DATEADD(minute, -50, SYSUTCDATETIME()), DATEADD(minute, -45, SYSUTCDATETIME()));
DECLARE @Appt1 INT = SCOPE_IDENTITY();

INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis, examination_result, conclusion, Created_At)
VALUES (@Appt1, 3, N'Theo dõi cườm nước (Glaucoma), thị lực giảm sút mắt trái, nhãn áp nghi cao', 
        N'Thị lực MP: 9/10, MT: 5/10. Bán phần trước bình thường.', 
        N'Chỉ định chụp OCT võng mạc và đo nhãn áp không tiếp xúc', DATEADD(minute, -40, SYSUTCDATETIME()));
DECLARE @Rec1 INT = SCOPE_IDENTITY();

-- Procedure 1: Đang chờ, giao cho ThS. Lê Văn C (Employee_ID = 11)
INSERT INTO Procedure_Order (Specialist_Employee_ID, Record_ID, Service_ID, Actual_Price, Status)
VALUES (11, @Rec1, 6, 500000, N'Pending');


-- 2. Appointment 2 (Bệnh nhân Trần Thị Bình - Patient_ID = 2, BS Nguyễn Xuân Tịnh)
INSERT INTO Appointment (Patient_ID, Schedule_ID, Staff_Employee_ID, Status, created_at, checkin_time)
VALUES (2, 2, 12, N'In_Progress', DATEADD(minute, -35, SYSUTCDATETIME()), DATEADD(minute, -30, SYSUTCDATETIME()));
DECLARE @Appt2 INT = SCOPE_IDENTITY();

INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis, examination_result, conclusion, Created_At)
VALUES (@Appt2, 4, N'Tật khúc xạ hai mắt, cận loạn thị tiến triển, nhìn mờ khi làm việc máy tính', 
        N'Thị lực không kính: MP 2/10, MT 3/10.', 
        N'Đo khúc xạ máy và thử thị lực chi tiết trước chỉnh kính', DATEADD(minute, -25, SYSUTCDATETIME()));
DECLARE @Rec2 INT = SCOPE_IDENTITY();

-- Procedure 2: Đang chờ, giao cho ThS. Lê Văn C (Employee_ID = 11)
INSERT INTO Procedure_Order (Specialist_Employee_ID, Record_ID, Service_ID, Actual_Price, Status)
VALUES (11, @Rec2, 2, 150000, N'Pending');


-- 3. Appointment 3 (Bệnh nhân Đặng Thùy Linh - Patient_ID = 3, BS Trần Văn Nam)
INSERT INTO Appointment (Patient_ID, Schedule_ID, Staff_Employee_ID, Status, created_at, checkin_time)
VALUES (3, 3, 12, N'In_Progress', DATEADD(minute, -20, SYSUTCDATETIME()), DATEADD(minute, -15, SYSUTCDATETIME()));
DECLARE @Appt3 INT = SCOPE_IDENTITY();

INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis, examination_result, conclusion, Created_At)
VALUES (@Appt3, 3, N'Vẩn đục dịch kính diện rộng (ruồi bay), nghi ngờ thoái hóa dịch kính hoặc rách võng mạc', 
        N'Đáy mắt có nhiều chấm đục lơ lửng.', 
        N'Chỉ định chụp OCT cắt lớp bán phần sau & đáy mắt', DATEADD(minute, -10, SYSUTCDATETIME()));
DECLARE @Rec3 INT = SCOPE_IDENTITY();

-- Procedure 3: Đang chờ, bác sĩ chỉ định cho ThS. Lê Văn C (Employee_ID = 11)
INSERT INTO Procedure_Order (Specialist_Employee_ID, Record_ID, Service_ID, Actual_Price, Status)
VALUES (11, @Rec3, 8, 400000, N'Pending');


-- 4. Appointment 4 (Bệnh nhân Hoàng Minh Tuấn - Patient_ID = 4, BS Nguyễn Xuân Tịnh)
INSERT INTO Appointment (Patient_ID, Schedule_ID, Staff_Employee_ID, Status, created_at, checkin_time)
VALUES (4, 4, 12, N'In_Progress', DATEADD(minute, -15, SYSUTCDATETIME()), DATEADD(minute, -10, SYSUTCDATETIME()));
DECLARE @Appt4 INT = SCOPE_IDENTITY();

INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis, examination_result, conclusion, Created_At)
VALUES (@Appt4, 4, N'Khám mắt định kỳ cho học sinh, kiểm tra độ cận để cấp đơn kính mới', 
        N'Mắt phải -2.50D, Mắt trái -3.00D.', 
        N'Đo khúc xạ máy tự động', DATEADD(minute, -8, SYSUTCDATETIME()));
DECLARE @Rec4 INT = SCOPE_IDENTITY();

-- Procedure 4: Đang chờ, bác sĩ chỉ định cho ThS. Lê Văn C (Employee_ID = 11)
INSERT INTO Procedure_Order (Specialist_Employee_ID, Record_ID, Service_ID, Actual_Price, Status)
VALUES (11, @Rec4, 7, 100000, N'Pending');


-- 5. Appointment 5 (Bệnh nhân Lê Thị Ngọc Mai - Patient_ID = 5, BS Trần Văn Nam)
INSERT INTO Appointment (Patient_ID, Schedule_ID, Staff_Employee_ID, Status, created_at, checkin_time)
VALUES (5, 5, 12, N'Completed', DATEADD(hour, -2, SYSUTCDATETIME()), DATEADD(hour, -2, SYSUTCDATETIME()));
DECLARE @Appt5 INT = SCOPE_IDENTITY();

INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis, examination_result, conclusion, Created_At)
VALUES (@Appt5, 3, N'Đục bao sau sau phẫu thuật Phaco mắt phải 6 tháng trước', 
        N'Thị lực giảm còn 4/10 do đục bao sau trung tâm.', 
        N'Đo nhãn áp & chụp OCT trước thủ thuật bắn laser YAG', DATEADD(hour, -2, SYSUTCDATETIME()));
DECLARE @Rec5 INT = SCOPE_IDENTITY();

-- Procedure 5: Đã hoàn thành bởi ThS. Lê Văn C (Employee_ID = 11)
INSERT INTO Procedure_Order (Specialist_Employee_ID, Record_ID, Service_ID, Actual_Price, Status)
VALUES (11, @Rec5, 6, 500000, N'Completed');


-- 6. Appointment 6 (Bệnh nhân Vũ Trọng Đức - Patient_ID = 6, BS Trần Quang Huy)
INSERT INTO Appointment (Patient_ID, Schedule_ID, Staff_Employee_ID, Status, created_at, checkin_time)
VALUES (6, 6, 12, N'Completed', DATEADD(day, -1, SYSUTCDATETIME()), DATEADD(day, -1, SYSUTCDATETIME()));
DECLARE @Appt6 INT = SCOPE_IDENTITY();

INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis, examination_result, conclusion, Created_At)
VALUES (@Appt6, 7, N'Cận thị nặng -6.00D hai mắt, có nhu cầu phẫu thuật xóa cận khúc xạ LASIK', 
        N'Giác mạc đủ dày (>540um), bản đồ giác mạc bình thường.', 
        N'Đủ điều kiện phẫu thuật Femto-LASIK', DATEADD(day, -1, SYSUTCDATETIME()));
DECLARE @Rec6 INT = SCOPE_IDENTITY();

-- Procedure 6: Đã hoàn thành bởi BSCKII. Trần Quang Huy (Employee_ID = 10)
INSERT INTO Procedure_Order (Specialist_Employee_ID, Record_ID, Service_ID, Actual_Price, Status)
VALUES (10, @Rec6, 3, 18000000, N'Completed');


-- 7. Appointment 7 (Bệnh nhân Phạm Thanh Thảo - Patient_ID = 8, BS Nguyễn Xuân Tịnh)
INSERT INTO Appointment (Patient_ID, Schedule_ID, Staff_Employee_ID, Status, created_at, checkin_time)
VALUES (8, 7, 12, N'In_Progress', DATEADD(minute, -5, SYSUTCDATETIME()), DATEADD(minute, -2, SYSUTCDATETIME()));
DECLARE @Appt7 INT = SCOPE_IDENTITY();

INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis, examination_result, conclusion, Created_At)
VALUES (@Appt7, 4, N'Cận thị tiến triển, nhìn mờ khi lái xe ban đêm, cần đo khúc xạ kiểm tra độ mới', 
        N'Thị lực không kính 3/10', 
        N'Chỉ định đo khúc xạ máy tự động', DATEADD(minute, -2, SYSUTCDATETIME()));
DECLARE @Rec7 INT = SCOPE_IDENTITY();

-- Procedure 7: Đang chờ thực hiện, chỉ định cho ThS. Lê Văn C (Employee_ID = 11)
INSERT INTO Procedure_Order (Specialist_Employee_ID, Record_ID, Service_ID, Actual_Price, Status)
VALUES (11, @Rec7, 7, 100000, N'Pending');

PRINT N'==> ĐÃ NẠP DỮ LIỆU MẪU HÀNG ĐỢI CẬN LÂM SÀNG THÀNH CÔNG!';
GO
