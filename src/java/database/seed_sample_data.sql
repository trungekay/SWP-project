-- =========================================================================================
-- VISIONCARE CLINIC - SCRIPT NẠP DỮ LIỆU MẪU CHUẨN HOÁ
-- File: seed_sample_data.sql
-- Mục đích: Nạp dữ liệu hoàn chỉnh, đúng 100% ràng buộc khóa ngoại (Foreign Key)
--          để hiển thị đầy đủ Lịch hẹn, Hồ sơ bệnh án, Đơn thuốc, Hóa đơn và Hoàn tiền
-- =========================================================================================

USE eye_clinic_db;
GO

SET NOCOUNT ON;

-- 1. Đảm bảo cột created_by_employee_id trong Refund_Request cho phép NULL (để bệnh nhân tự gửi yêu cầu hoàn tiền)
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Refund_Request') AND name = 'created_by_employee_id' AND is_nullable = 0)
BEGIN
    ALTER TABLE Refund_Request ALTER COLUMN created_by_employee_id INT NULL;
END
GO

-- 2. Dọn dẹp dữ liệu giao dịch cũ (nếu có) để tránh xung đột khoá
DELETE FROM Refund_Request;
DELETE FROM Payment_Transaction;
DELETE FROM Master_Invoice;
DELETE FROM Prescription_Detail;
DELETE FROM Prescription;
DELETE FROM Procedure_Order;
DELETE FROM Medical_Record;
DELETE FROM Appointment;
GO

-- 3. Tạo các cuộc hẹn mẫu (Sử dụng đúng Schedule_ID 1, 2, 3 đã tồn tại trong Work_Schedule)
-- Appointment #1: Đã hoàn thành (Completed) - Của bệnh nhân An (Patient_ID = 1)
INSERT INTO Appointment (Patient_ID, Schedule_ID, Staff_Employee_ID, Status, created_at, checkin_time)
VALUES (1, 1, 12, N'Completed', DATEADD(day, -5, SYSUTCDATETIME()), DATEADD(day, -5, SYSUTCDATETIME()));

DECLARE @Appt1 INT = SCOPE_IDENTITY();

-- Appointment #2: Đã xác nhận (Confirmed) - Sắp tới khám
INSERT INTO Appointment (Patient_ID, Schedule_ID, Staff_Employee_ID, Status, created_at, checkin_time)
VALUES (1, 2, 12, N'Confirmed', DATEADD(day, -1, SYSUTCDATETIME()), NULL);

DECLARE @Appt2 INT = SCOPE_IDENTITY();

-- Appointment #3: Chờ duyệt hủy & hoàn tiền cọc (Pending)
INSERT INTO Appointment (Patient_ID, Schedule_ID, Staff_Employee_ID, Status, created_at, checkin_time)
VALUES (1, 3, 12, N'Pending', SYSUTCDATETIME(), NULL);

DECLARE @Appt3 INT = SCOPE_IDENTITY();

-- 4. Tạo Hóa đơn Master_Invoice
-- Invoice #1 cho Cuộc hẹn #1 (Đã khám xong - Đặt cọc 250k khám BS. Nam + Tiền thuốc phát sinh 226k = 476k)
INSERT INTO Master_Invoice (Appointment_ID, Total_Amount, Deposit_Amount, Balance_Due, Status, Create_At, Close_At)
VALUES (@Appt1, 476000, 250000, 0, N'Paid', DATEADD(day, -5, SYSUTCDATETIME()), DATEADD(day, -5, SYSUTCDATETIME()));

DECLARE @Inv1 INT = SCOPE_IDENTITY();

-- Giao dịch thanh toán qua VNPay cho Invoice #1
INSERT INTO Payment_Transaction (Invoice_ID, Amount, Gateway_Status, Trans_Date, Payment_Gateway)
VALUES (@Inv1, 350000, N'Success', DATEADD(day, -5, SYSUTCDATETIME()), N'VNPay');

-- Invoice #2 cho Cuộc hẹn #2 (Đã đặt cọc 250.000 đ)
INSERT INTO Master_Invoice (Appointment_ID, Total_Amount, Deposit_Amount, Balance_Due, Status, Create_At, Close_At)
VALUES (@Appt2, 250000, 250000, 0, N'Paid', DATEADD(day, -1, SYSUTCDATETIME()), DATEADD(day, -1, SYSUTCDATETIME()));

-- Invoice #3 cho Cuộc hẹn #3 (Đang chờ duyệt hoàn cọc 250.000 đ)
INSERT INTO Master_Invoice (Appointment_ID, Total_Amount, Deposit_Amount, Balance_Due, Status, Create_At, Close_At)
VALUES (@Appt3, 250000, 250000, 0, N'Paid', SYSUTCDATETIME(), NULL);

DECLARE @Inv3 INT = SCOPE_IDENTITY();

-- 5. Tạo Hồ sơ khám bệnh ngoại trú (Medical_Record) cho Cuộc hẹn #1
INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis, examination_result, conclusion, Created_At)
VALUES (
    @Appt1, 
    3, -- Bác sĩ Trần Văn Nam
    N'Mắt phải cận thị nhẹ 1.5 độ, viêm kết mạc kích ứng',
    N'Thị lực MP: 8/10, MT: 10/10. Kết mạc cương tụ nhẹ góc trong. Giác mạc trong suốt, nhãn áp hai mắt trong giới hạn bình thường (16 mmHg).',
    N'Kê đơn thuốc nhỏ mắt kháng viêm và nước mắt nhân tạo. Đeo kính khi học tập và làm việc máy tính. Tái khám sau 7 ngày nếu còn cộm mắt.',
    DATEADD(day, -5, SYSUTCDATETIME())
);

DECLARE @Rec1 INT = SCOPE_IDENTITY();

-- Dịch vụ cận lâm sàng / thủ thuật (Procedure_Order do BS. Trần Văn Nam thực hiện)
INSERT INTO Procedure_Order (Specialist_Employee_ID, Record_ID, Service_ID, Status)
VALUES (3, @Rec1, 1, N'Completed');

-- Đơn thuốc (Prescription)
INSERT INTO Prescription (Record_ID, Doctor_Notes, created_at)
VALUES (
    @Rec1, 
    N'Nhỏ thuốc đúng giờ, giữ vệ sinh mắt sạch sẽ, tái khám sau 7 ngày nếu mắt còn đỏ hoặc khó chịu.', 
    DATEADD(day, -5, SYSUTCDATETIME())
);

DECLARE @Pres1 INT = SCOPE_IDENTITY();

-- Chi tiết các loại thuốc trong đơn (Prescription_Detail)
INSERT INTO Prescription_Detail (Prescription_ID, Medicine_Name, Quantity, Dosage_Instruction)
VALUES 
(@Pres1, N'Thuốc nhỏ mắt Tobradex', 1, N'Nhỏ 1 giọt/lần, ngày 2 lần vào mắt phải trong 5 ngày'),
(@Pres1, N'Nước mắt nhân tạo Sanlein 0.1%', 2, N'Nhỏ 1 giọt mỗi bên mắt khi mỏi hoặc khô mắt, ngày 3-4 lần');

-- 6. Tạo Yêu cầu hoàn tiền (Refund_Request) cho Invoice #3
INSERT INTO Refund_Request (Invoice_ID, created_by_employee_id, approved_by_employee_id, Patient_ID, Refund_Amount, Reason, Status, Created_At)
VALUES (@Inv3, 12, NULL, 1, 250000, N'Bệnh nhân bận công tác đột xuất, xin hủy lịch và hoàn cọc', N'Pending', SYSUTCDATETIME());

PRINT N'==> NẠP DỮ LIỆU MẪU THÀNH CÔNG CHO VISIONCARE CLINIC!';
GO
