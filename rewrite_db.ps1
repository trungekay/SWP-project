$content = Get-Content -Path "src\java\database\eye_clinic_db (1).sql" -Encoding UTF8 -Raw

$newInserts = @"
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

INSERT INTO Employee_Profile (Account_ID, Room_ID, Full_Name, Phone, Specialty, License_Number) VALUES
(1,  NULL, N'Quản trị viên Hệ thống',     NULL, N'Quản trị hệ thống',     NULL),
(2,  NULL, N'Nguyễn Văn Giám Đốc',        NULL, N'Giám đốc',              NULL),
(3,  1,    N'BS. Trần Văn Nam',           NULL, N'Nhãn khoa tổng quát',            N'BS-12345/EYE'),
(4,  2,    N'TS.BS. Nguyễn Xuân Tịnh',    NULL, N'Đo Khúc xạ & Kính',              N'BS-56789/EYE'),
(5,  3,    N'BS. Lê Hoàng Lan',           NULL, N'Phẫu thuật LASIK',               N'BS-98765/EYE'),
(6,  4,    N'BS. Phạm Bảo Ngọc',          NULL, N'Nhãn khoa trẻ em & Nhược thị',   N'BS-34567/EYE'),
(7,  5,    N'BS. Trần Quang Huy',         NULL, N'Đục thủy tinh thể (Phaco)',      N'BS-45678/EYE'),
(8,  6,    N'BS. Ngô Tiến Dũng',          NULL, N'Glaucoma & Võng mạc',            N'BS-99999/EYE'),
(9,  7,    N'ThS.BS. Lê Hoàng Lan',       NULL, N'Medical Specialist tiểu phẫu',   N'BS-11111/EYE'),
(10, 8,    N'BSCKII. Trần Quang Huy',     NULL, N'Medical Specialist tiểu phẫu',   N'BS-22222/EYE'),
(11, 9,    N'ThS. Lê Văn C',              NULL, N'Medical Specialist tiểu phẫu',   N'BS-33333/EYE'),
(12, NULL, N'Lễ Tân Phạm Thị Lan',        NULL, N'Thu Ngân & Tiếp Đón',            NULL);

INSERT INTO Work_Schedule
    (Doctor_Employee_ID, Specialist_Employee_ID, Work_Date, Slot, Start_Time, End_Time, Status)
VALUES
(3,    NULL, '2026-04-01', N'Slot 1', '08:00:00', '08:30:00', N'Available'),
(3,    NULL, '2026-04-01', N'Slot 2', '08:30:00', '09:00:00', N'Available'),
(3,    NULL, '2026-04-01', N'Slot 3', '09:00:00', '09:30:00', N'Available'),
(3,    NULL, '2026-04-01', N'Slot 4', '09:30:00', '10:00:00', N'Available'),
(NULL, 9,    '2026-04-01', N'Slot 1', '08:00:00', '08:30:00', N'Available');
"@

$startIdx = $content.IndexOf("INSERT INTO Room (Room_Name) VALUES")
$endIdx = $content.IndexOf("INSERT INTO Leave_Cancel_Request")

$newContent = $content.Substring(0, $startIdx) + $newInserts + "`r`n`r`n" + $content.Substring($endIdx)

# We also need to update Procedure_Order because Specialist_Employee_ID was 4, now 9.
# Appointment uses Staff_Employee_ID = 5, but Staff is now 12! Let's find "INSERT INTO Appointment (Patient_ID, Schedule_ID, Staff_Employee_ID"
# And Medical_Record uses Doctor_Employee_ID = 3, which is still 3.
# Refund_Request uses created_by = 5, now 12.
$newContent = $newContent.Replace("(1, 1, 5, N'Completed', SYSUTCDATETIME(), SYSUTCDATETIME()),`r`n(2, 2, 5, N'Pending',   SYSUTCDATETIME(), NULL);", "(1, 1, 12, N'Completed', SYSUTCDATETIME(), SYSUTCDATETIME()),`r`n(2, 2, 12, N'Pending',   SYSUTCDATETIME(), NULL);")
$newContent = $newContent.Replace("(4, 1, 2, N'Completed');", "(9, 1, 2, N'Completed');")
$newContent = $newContent.Replace("(1, 5, 2, 1, 50000, N'Bệnh nhân hủy dịch vụ phát sinh thêm', N'Approved');", "(1, 12, 2, 1, 50000, N'Bệnh nhân hủy dịch vụ phát sinh thêm', N'Approved');")

[IO.File]::WriteAllText("src\java\database\eye_clinic_db (1).sql", $newContent, [System.Text.Encoding]::UTF8)
