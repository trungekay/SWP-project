-- =========================================================================
-- VISIONCARE: DỮ LIỆU MẪU LỊCH HẸN VÀ HÀNG ĐỢI CHO NGÀY HÔM NAY (2026-10-19)
-- File: database_seed_2026_10_19.sql
-- Chạy script này trong SQL Server Management Studio (SSMS) trên database eye_clinic_db
-- =========================================================================

USE eye_clinic_db;
GO

SET NOCOUNT ON;

DECLARE @today DATE = '2026-10-19';

PRINT N'=== BẮT ĐẦU TẠO DỮ LIỆU MẪU CHO NGÀY: ' + CONVERT(NVARCHAR(10), @today);

-- -------------------------------------------------------------------------
-- 1. TẠO CA LÀM VIỆC (WORK_SCHEDULE) CHO NGÀY 2026-10-19 NẾU CHƯA CÓ
-- -------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM Work_Schedule WHERE Work_Date = @today)
BEGIN
    PRINT N'1. Tạo danh sách ca làm việc cho ngày 2026-10-19...';
    INSERT INTO Work_Schedule (Doctor_Employee_ID, Specialist_Employee_ID, Work_Date, Slot, Start_Time, End_Time, Status) VALUES
    -- Bác sĩ 3: BS. Trần Văn Nam (Phòng 1: Nhãn khoa tổng quát)
    (3, NULL, @today, N'Slot 1',  '08:00:00', '08:30:00', N'Available'),
    (3, NULL, @today, N'Slot 2',  '08:30:00', '09:00:00', N'Available'),
    (3, NULL, @today, N'Slot 3',  '09:00:00', '09:30:00', N'Available'),
    (3, NULL, @today, N'Slot 4',  '09:30:00', '10:00:00', N'Available'),
    (3, NULL, @today, N'Slot 5',  '10:00:00', '10:30:00', N'Available'),
    (3, NULL, @today, N'Slot 6',  '10:30:00', '11:00:00', N'Available'),
    (3, NULL, @today, N'Slot 7',  '11:00:00', '11:30:00', N'Available'),
    (3, NULL, @today, N'Slot 8',  '13:30:00', '14:00:00', N'Available'),
    (3, NULL, @today, N'Slot 9',  '14:00:00', '14:30:00', N'Available'),
    (3, NULL, @today, N'Slot 10', '14:30:00', '15:00:00', N'Available'),

    -- Bác sĩ 4: TS.BS. Nguyễn Xuân Tịnh (Phòng 2: Đo Khúc Xạ & Kính)
    (4, NULL, @today, N'Slot 1',  '08:00:00', '08:30:00', N'Available'),
    (4, NULL, @today, N'Slot 2',  '08:30:00', '09:00:00', N'Available'),
    (4, NULL, @today, N'Slot 3',  '09:00:00', '09:30:00', N'Available'),
    (4, NULL, @today, N'Slot 4',  '09:30:00', '10:00:00', N'Available'),
    (4, NULL, @today, N'Slot 5',  '10:00:00', '10:30:00', N'Available'),

    -- Bác sĩ 5: BS. Lê Hoàng Lan (Phòng 3: Phẫu thuật khúc xạ / LASIK)
    (5, NULL, @today, N'Slot 1',  '08:00:00', '08:30:00', N'Available'),
    (5, NULL, @today, N'Slot 2',  '08:30:00', '09:00:00', N'Available'),
    (5, NULL, @today, N'Slot 3',  '09:00:00', '09:30:00', N'Available'),
    (5, NULL, @today, N'Slot 4',  '09:30:00', '10:00:00', N'Available'),

    -- Bác sĩ 6: BS. Phạm Bảo Ngọc (Phòng 4: Nhãn khoa trẻ em)
    (6, NULL, @today, N'Slot 1',  '08:00:00', '08:30:00', N'Available'),
    (6, NULL, @today, N'Slot 2',  '08:30:00', '09:00:00', N'Available'),
    (6, NULL, @today, N'Slot 3',  '09:00:00', '09:30:00', N'Available'),
    (6, NULL, @today, N'Slot 4',  '09:30:00', '10:00:00', N'Available'),

    -- Bác sĩ 7: BS. CKII. Võ Huy (Phòng 5: Đục thủy tinh thể / Phaco)
    (7, NULL, @today, N'Slot 1',  '08:00:00', '08:30:00', N'Available'),
    (7, NULL, @today, N'Slot 2',  '08:30:00', '09:00:00', N'Available'),

    -- Bác sĩ 8: ThS.BS. Đỗ Thị Dũng (Phòng 6: Glaucoma & Võng mạc)
    (8, NULL, @today, N'Slot 1',  '08:00:00', '08:30:00', N'Available'),
    (8, NULL, @today, N'Slot 2',  '08:30:00', '09:00:00', N'Available'),
    (8, NULL, @today, N'Slot 3',  '09:00:00', '09:30:00', N'Available');
END
ELSE
BEGIN
    PRINT N'1. Đã có ca làm việc cho ngày 2026-10-19 trong database.';
END
GO

-- -------------------------------------------------------------------------
-- 2. TẠO CÁC LỊCH HẸN MẪU CHO NGÀY 2026-10-19
-- -------------------------------------------------------------------------
DECLARE @today DATE = '2026-10-19';

-- Lấy Schedule_ID của các bác sĩ ngày hôm nay
DECLARE @sch_nam_s1 INT = (SELECT TOP 1 Schedule_ID FROM Work_Schedule WHERE Work_Date = @today AND Doctor_Employee_ID = 3 AND Slot = N'Slot 1');
DECLARE @sch_nam_s2 INT = (SELECT TOP 1 Schedule_ID FROM Work_Schedule WHERE Work_Date = @today AND Doctor_Employee_ID = 3 AND Slot = N'Slot 2');
DECLARE @sch_nam_s3 INT = (SELECT TOP 1 Schedule_ID FROM Work_Schedule WHERE Work_Date = @today AND Doctor_Employee_ID = 3 AND Slot = N'Slot 3');

DECLARE @sch_tinh_s1 INT = (SELECT TOP 1 Schedule_ID FROM Work_Schedule WHERE Work_Date = @today AND Doctor_Employee_ID = 4 AND Slot = N'Slot 1');
DECLARE @sch_tinh_s2 INT = (SELECT TOP 1 Schedule_ID FROM Work_Schedule WHERE Work_Date = @today AND Doctor_Employee_ID = 4 AND Slot = N'Slot 2');

DECLARE @sch_lan_s2 INT = (SELECT TOP 1 Schedule_ID FROM Work_Schedule WHERE Work_Date = @today AND Doctor_Employee_ID = 5 AND Slot = N'Slot 2');

DECLARE @sch_ngoc_s3 INT = (SELECT TOP 1 Schedule_ID FROM Work_Schedule WHERE Work_Date = @today AND Doctor_Employee_ID = 6 AND Slot = N'Slot 3');

DECLARE @sch_huy_s1 INT = (SELECT TOP 1 Schedule_ID FROM Work_Schedule WHERE Work_Date = @today AND Doctor_Employee_ID = 7 AND Slot = N'Slot 1');

DECLARE @sch_dung_s2 INT = (SELECT TOP 1 Schedule_ID FROM Work_Schedule WHERE Work_Date = @today AND Doctor_Employee_ID = 8 AND Slot = N'Slot 2');

-- Helper biến lưu Appointment_ID vừa tạo
DECLARE @newApptId INT;

PRINT N'2. Đang tạo các ca khám mẫu ngày 2026-10-19...';

-- CA 1: CHỜ TIẾP ĐÓN (Pending) - Nguyễn Văn An (Bệnh nhân 1) - BS Trần Văn Nam (Slot 3: 09:00)
IF NOT EXISTS (SELECT 1 FROM Appointment a JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID WHERE ws.Work_Date = @today AND a.Patient_ID = 1)
BEGIN
    INSERT INTO Appointment (Patient_ID, Schedule_ID, Staff_Employee_ID, Status, created_at, checkin_time)
    VALUES (1, @sch_nam_s3, 12, N'Pending', '2026-10-19 07:30:00', NULL);
    SET @newApptId = SCOPE_IDENTITY();

    INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis, Created_At)
    VALUES (@newApptId, 3, N'Dịch vụ: Khám mắt tổng quát & Soi đáy mắt | Lý do: Mắt cộm xốn, mỏi mắt nhiều khi nhìn máy tính liên tục', SYSUTCDATETIME());

    INSERT INTO Master_Invoice (Appointment_ID, Total_Amount, Deposit_Amount, Balance_Due, Status, Close_At)
    VALUES (@newApptId, 200000, 200000, 0, N'Paid', SYSUTCDATETIME());

    UPDATE Work_Schedule SET Status = N'Booked' WHERE Schedule_ID = @sch_nam_s3;
    PRINT N'  -> Đã tạo Ca 1 (#APPT-' + CAST(@newApptId AS NVARCHAR) + N') [Pending]: Nguyễn Văn An';
END

-- CA 2: CHỜ TIẾP ĐÓN (Pending) - Hoàng Minh Tuấn (Bệnh nhân 4) - TS.BS Nguyễn Xuân Tịnh (Slot 2: 08:30)
IF NOT EXISTS (SELECT 1 FROM Appointment a JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID WHERE ws.Work_Date = @today AND a.Patient_ID = 4)
BEGIN
    INSERT INTO Appointment (Patient_ID, Schedule_ID, Staff_Employee_ID, Status, created_at, checkin_time)
    VALUES (4, @sch_tinh_s2, 12, N'Pending', '2026-10-19 07:45:00', NULL);
    SET @newApptId = SCOPE_IDENTITY();

    INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis, Created_At)
    VALUES (@newApptId, 4, N'Dịch vụ: Đo khúc xạ và tư vấn kính | Lý do: Độ kính cũ bị mờ, thường xuyên nhức đầu khi đọc sách', SYSUTCDATETIME());

    INSERT INTO Master_Invoice (Appointment_ID, Total_Amount, Deposit_Amount, Balance_Due, Status, Close_At)
    VALUES (@newApptId, 150000, 150000, 0, N'Paid', SYSUTCDATETIME());

    UPDATE Work_Schedule SET Status = N'Booked' WHERE Schedule_ID = @sch_tinh_s2;
    PRINT N'  -> Đã tạo Ca 2 (#APPT-' + CAST(@newApptId AS NVARCHAR) + N') [Pending]: Hoàng Minh Tuấn';
END

-- CA 3: CHỜ TIẾP ĐÓN (Pending) - Bùi Quốc Anh (Bé) (Bệnh nhân 7) - BS Phạm Bảo Ngọc (Slot 3: 09:00)
IF NOT EXISTS (SELECT 1 FROM Appointment a JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID WHERE ws.Work_Date = @today AND a.Patient_ID = 7)
BEGIN
    INSERT INTO Appointment (Patient_ID, Schedule_ID, Staff_Employee_ID, Status, created_at, checkin_time)
    VALUES (7, @sch_ngoc_s3, 12, N'Pending', '2026-10-19 08:00:00', NULL);
    SET @newApptId = SCOPE_IDENTITY();

    INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis, Created_At)
    VALUES (@newApptId, 6, N'Dịch vụ: Khám mắt trẻ em và tư vấn nhược thị | Lý do: Bé hay dụi mắt, nghiêng đầu và nheo mắt khi xem tivi', SYSUTCDATETIME());

    INSERT INTO Master_Invoice (Appointment_ID, Total_Amount, Deposit_Amount, Balance_Due, Status, Close_At)
    VALUES (@newApptId, 300000, 300000, 0, N'Paid', SYSUTCDATETIME());

    UPDATE Work_Schedule SET Status = N'Booked' WHERE Schedule_ID = @sch_ngoc_s3;
    PRINT N'  -> Đã tạo Ca 3 (#APPT-' + CAST(@newApptId AS NVARCHAR) + N') [Pending]: Bé Bùi Quốc Anh';
END

-- CA 4: CHỜ KHÁM TRONG HÀNG ĐỢI (Confirmed) - Trần Thị Bình (Bệnh nhân 2) - BS Trần Văn Nam (Slot 2: 08:30)
IF NOT EXISTS (SELECT 1 FROM Appointment a JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID WHERE ws.Work_Date = @today AND a.Patient_ID = 2)
BEGIN
    INSERT INTO Appointment (Patient_ID, Schedule_ID, Staff_Employee_ID, Status, created_at, checkin_time)
    VALUES (2, @sch_nam_s2, 12, N'Confirmed', '2026-10-19 07:15:00', '2026-10-19 08:15:00');
    SET @newApptId = SCOPE_IDENTITY();

    INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis, Created_At)
    VALUES (@newApptId, 3, N'Dịch vụ: Khám mắt tổng quát & Soi đáy mắt | Lý do: Mắt trái đỏ nhẹ, hay chảy nước mắt sống khi ra gió', SYSUTCDATETIME());

    INSERT INTO Master_Invoice (Appointment_ID, Total_Amount, Deposit_Amount, Balance_Due, Status, Close_At)
    VALUES (@newApptId, 200000, 200000, 0, N'Paid', SYSUTCDATETIME());

    UPDATE Work_Schedule SET Status = N'Booked' WHERE Schedule_ID = @sch_nam_s2;
    PRINT N'  -> Đã tạo Ca 4 (#APPT-' + CAST(@newApptId AS NVARCHAR) + N') [Confirmed]: Trần Thị Bình (Chờ khám)';
END

-- CA 5: CHỜ KHÁM TRONG HÀNG ĐỢI (Confirmed) - Đặng Thùy Linh (Bệnh nhân 3) - BS Lê Hoàng Lan (Slot 2: 08:30)
IF NOT EXISTS (SELECT 1 FROM Appointment a JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID WHERE ws.Work_Date = @today AND a.Patient_ID = 3)
BEGIN
    INSERT INTO Appointment (Patient_ID, Schedule_ID, Staff_Employee_ID, Status, created_at, checkin_time)
    VALUES (3, @sch_lan_s2, 12, N'Confirmed', '2026-10-19 07:20:00', '2026-10-19 08:20:00');
    SET @newApptId = SCOPE_IDENTITY();

    INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis, Created_At)
    VALUES (@newApptId, 5, N'Dịch vụ: Khám tiền phẫu & Tư vấn xóa cận LASIK/SMILE | Lý do: Cận 5.5 độ hai mắt, muốn đo bản đồ giác mạc để tư vấn mổ Femto-Lasik', SYSUTCDATETIME());

    INSERT INTO Master_Invoice (Appointment_ID, Total_Amount, Deposit_Amount, Balance_Due, Status, Close_At)
    VALUES (@newApptId, 500000, 500000, 0, N'Paid', SYSUTCDATETIME());

    UPDATE Work_Schedule SET Status = N'Booked' WHERE Schedule_ID = @sch_lan_s2;
    PRINT N'  -> Đã tạo Ca 5 (#APPT-' + CAST(@newApptId AS NVARCHAR) + N') [Confirmed]: Đặng Thùy Linh (Chờ khám)';
END

-- CA 6: CHỜ KHÁM TRONG HÀNG ĐỢI (Confirmed) - Phạm Thanh Thảo (Bệnh nhân 8) - ThS.BS Đỗ Thị Dũng (Slot 2: 08:30)
IF NOT EXISTS (SELECT 1 FROM Appointment a JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID WHERE ws.Work_Date = @today AND a.Patient_ID = 8)
BEGIN
    INSERT INTO Appointment (Patient_ID, Schedule_ID, Staff_Employee_ID, Status, created_at, checkin_time)
    VALUES (8, @sch_dung_s2, 12, N'Confirmed', '2026-10-19 07:35:00', '2026-10-19 08:25:00');
    SET @newApptId = SCOPE_IDENTITY();

    INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis, Created_At)
    VALUES (@newApptId, 8, N'Dịch vụ: Đo nhãn áp & Tầm soát Glaucoma | Lý do: Đau nhức tức hốc mắt và nửa đầu, nhìn thấy quầng màu quanh bóng đèn', SYSUTCDATETIME());

    INSERT INTO Master_Invoice (Appointment_ID, Total_Amount, Deposit_Amount, Balance_Due, Status, Close_At)
    VALUES (@newApptId, 250000, 250000, 0, N'Paid', SYSUTCDATETIME());

    UPDATE Work_Schedule SET Status = N'Booked' WHERE Schedule_ID = @sch_dung_s2;
    PRINT N'  -> Đã tạo Ca 6 (#APPT-' + CAST(@newApptId AS NVARCHAR) + N') [Confirmed]: Phạm Thanh Thảo (Chờ khám)';
END

-- CA 7: ĐANG KHÁM TRONG PHÒNG (In_Progress) - Lê Thị Ngọc Mai (Bệnh nhân 5) - BS Trần Văn Nam (Slot 1: 08:00)
IF NOT EXISTS (SELECT 1 FROM Appointment a JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID WHERE ws.Work_Date = @today AND a.Patient_ID = 5)
BEGIN
    INSERT INTO Appointment (Patient_ID, Schedule_ID, Staff_Employee_ID, Status, created_at, checkin_time)
    VALUES (5, @sch_nam_s1, 12, N'In_Progress', '2026-10-19 07:00:00', '2026-10-19 07:55:00');
    SET @newApptId = SCOPE_IDENTITY();

    INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis, Created_At)
    VALUES (@newApptId, 3, N'Dịch vụ: Khám mắt tổng quát & Soi đáy mắt | Lý do: Khám định kỳ theo dõi thị lực và kiểm tra giác mạc', SYSUTCDATETIME());

    INSERT INTO Master_Invoice (Appointment_ID, Total_Amount, Deposit_Amount, Balance_Due, Status, Close_At)
    VALUES (@newApptId, 200000, 200000, 0, N'Paid', SYSUTCDATETIME());

    UPDATE Work_Schedule SET Status = N'Booked' WHERE Schedule_ID = @sch_nam_s1;
    PRINT N'  -> Đã tạo Ca 7 (#APPT-' + CAST(@newApptId AS NVARCHAR) + N') [In_Progress]: Lê Thị Ngọc Mai (Đang khám trong phòng)';
END

-- CA 8: ĐÃ HOÀN TẤT KHÁM (Completed) - Vũ Trọng Đức (Bệnh nhân 6) - BS CKII Võ Huy (Slot 1: 08:00)
IF NOT EXISTS (SELECT 1 FROM Appointment a JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID WHERE ws.Work_Date = @today AND a.Patient_ID = 6)
BEGIN
    INSERT INTO Appointment (Patient_ID, Schedule_ID, Staff_Employee_ID, Status, created_at, checkin_time)
    VALUES (6, @sch_huy_s1, 12, N'Completed', '2026-10-19 06:45:00', '2026-10-19 07:45:00');
    SET @newApptId = SCOPE_IDENTITY();

    INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis, examination_result, conclusion, Created_At)
    VALUES (@newApptId, 7, 
            N'Dịch vụ: Khám tầm soát & Tư vấn phẫu thuật Phaco (Đục thủy tinh thể) | Lý do: Mắt phải mờ như có màn sương mỏng, nhìn đèn chói lóa ban đêm',
            N'Đục thể thủy tinh người già giai đoạn tiến triển mắt phải (độ 2). Thị lực mắt phải 4/10, mắt trái 7/10. Nhãn áp hai mắt trong giới hạn bình thường.',
            N'Chỉ định theo dõi thêm 3 tháng hoặc sắp xếp phẫu thuật Phaco tán nhuyễn đặt thể thủy tinh nhân tạo nếu giảm thị lực gây ảnh hưởng sinh hoạt.',
            SYSUTCDATETIME());

    INSERT INTO Master_Invoice (Appointment_ID, Total_Amount, Deposit_Amount, Balance_Due, Status, Close_At)
    VALUES (@newApptId, 300000, 300000, 0, N'Paid', SYSUTCDATETIME());

    UPDATE Work_Schedule SET Status = N'Booked' WHERE Schedule_ID = @sch_huy_s1;
    PRINT N'  -> Đã tạo Ca 8 (#APPT-' + CAST(@newApptId AS NVARCHAR) + N') [Completed]: Vũ Trọng Đức (Đã khám xong)';
END

-- CA 9: ĐÃ HỦY CA / VẮNG MẶT (Canceled) - Ngô Đình Cường (Bệnh nhân 9) - TS.BS Nguyễn Xuân Tịnh (Slot 1: 08:00)
IF NOT EXISTS (SELECT 1 FROM Appointment a JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID WHERE ws.Work_Date = @today AND a.Patient_ID = 9)
BEGIN
    INSERT INTO Appointment (Patient_ID, Schedule_ID, Staff_Employee_ID, Status, created_at, checkin_time)
    VALUES (9, @sch_tinh_s1, 12, N'Canceled', '2026-10-19 07:10:00', NULL);
    SET @newApptId = SCOPE_IDENTITY();

    INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis, conclusion, Created_At)
    VALUES (@newApptId, 4, 
            N'Dịch vụ: Đo khúc xạ và tư vấn kính | Lý do: Khám kiểm tra độ cận và cắt kính lão thị',
            N'Bệnh nhân bận công tác đột xuất, gọi điện báo xin hủy lịch khám hôm nay và dời sang tuần sau.',
            SYSUTCDATETIME());

    INSERT INTO Master_Invoice (Appointment_ID, Total_Amount, Deposit_Amount, Balance_Due, Status, Close_At)
    VALUES (@newApptId, 150000, 0, 0, N'Canceled', SYSUTCDATETIME());

    PRINT N'  -> Đã tạo Ca 9 (#APPT-' + CAST(@newApptId AS NVARCHAR) + N') [Canceled]: Ngô Đình Cường (Đã hủy)';
END

PRINT N'=== HOÀN TẤT TẠO DỮ LIỆU MẪU CHO NGÀY 2026-10-19 ===';
GO
