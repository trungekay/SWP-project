# BỘ TEST CASE CHI TIẾT - PHÒNG KHÁM CHUYÊN KHOA MẮT VISIONCARE (ITERATION 1 & 2)

> **Dự án:** VisionCare (SWP Project)
> **Mẫu chuẩn:** Google Sheets Test Case Template
> **Tổng số Workflow:** 8 Workflow chính bao quát 35 màn hình của Iteration 1 & 2
> **File CSV kèm theo để import trực tiếp vào Google Sheets / Excel:** [TEST_CASES_ITERATION_1_2.csv](./TEST_CASES_ITERATION_1_2.csv)

---

## Workflow 1: Authentication & Account Management (Xác thực & Hồ sơ cá nhân)

- **Yêu cầu kiểm thử (Requirement):** Kiểm tra toàn bộ luồng đăng nhập, đăng ký tài khoản bệnh nhân, xác thực OTP qua email, quên mật khẩu và quản lý thông tin hồ sơ cá nhân, đổi mật khẩu.
- **Số lượng Test Case:** 17 TCs

### Scenario 1: Đăng nhập hệ thống (Login Screen)

| Test Case ID | Test Case Description | Test Case Procedure | Expected Results | Pre-conditions | Status | Test Date | Tester |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-AUTH-001** | Verify that a Patient can successfully log in with valid credentials and redirect to Home page. | 1. Navigate to /login.<br>2. Enter registered Patient email: patient@gmail.com.<br>3. Enter valid password: Pass@123.<br>4. Click 'Đăng nhập' (Login) button. | Login succeeds. User session is created with Patient role. System redirects to /home. Navigation bar shows user name and profile dropdown. | Patient account patient@gmail.com exists with status 'Active'. | Passed | 18/10/2026 | Minh Trường |
| **TC-AUTH-002** | Verify that System Staff / Doctor / Admin can log in and redirect to their respective management dashboard. | 1. Navigate to /login.<br>2. Enter staff/doctor/admin email (e.g. admin@eyeclinic.com).<br>3. Enter valid password.<br>4. Click 'Đăng nhập' button. | Login succeeds. System redirects based on role: Admin to /admin/dashboard or /admin/users, Staff to /staff/appointments, Doctor to /employee/schedule. | Staff/Doctor/Admin account exists with status 'Active'. | Passed | 18/10/2026 | Minh Trường |
| **TC-AUTH-003** | Verify that logging in with incorrect password displays an error message and keeps user on login page. | 1. Navigate to /login.<br>2. Enter email: patient@gmail.com.<br>3. Enter wrong password: IncorrectPass123.<br>4. Click 'Đăng nhập' button. | Login fails. User remains on /login. An inline alert displays: 'Email hoặc mật khẩu không chính xác'. Password field is cleared. | User account exists in database. | Passed | 18/10/2026 | Minh Trường |
| **TC-AUTH-004** | Verify that logging in with a deactivated or banned account is blocked with an appropriate notification. | 1. Navigate to /login.<br>2. Enter credentials of a deactivated account.<br>3. Click 'Đăng nhập' button. | Login is blocked. System displays alert: 'Tài khoản của bạn đã bị khóa hoặc ngừng hoạt động. Vui lòng liên hệ Admin'. | Account status is 'Deactivated' or 'Banned'. | Passed | 18/10/2026 | Minh Trường |
| **TC-AUTH-005** | Verify that submitting login form with empty email or password triggers required field validation. | 1. Navigate to /login.<br>2. Leave Email or Password blank.<br>3. Click 'Đăng nhập' button. | Form submission is halted by frontend HTML5/JS validation. Tooltip shows 'Vui lòng điền thông tin vào trường này'. No HTTP request sent. | Browser is on /login. | Passed | 18/10/2026 | Minh Trường |

### Scenario 2: Đăng ký tài khoản & Xác thực OTP (Register & Verify Screen)

| Test Case ID | Test Case Description | Test Case Procedure | Expected Results | Pre-conditions | Status | Test Date | Tester |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-REG-001** | Verify that a new user can register with valid details, triggering an OTP email and redirecting to OTP verification screen. | 1. Navigate to /register.<br>2. Enter Full Name: Nguyễn Văn An.<br>3. Enter unique Email: an.nguyen@test.com.<br>4. Enter Phone: 0987654321.<br>5. Enter Password: Pass@123.<br>6. Enter Confirm Password: Pass@123.<br>7. Click 'Đăng ký' button. | System generates a 6-digit OTP, sends it via SMTP email, stores pending registration in session, and redirects user to /verify-otp. | Email is not already registered. SMTP mail service is online. | Passed | 18/10/2026 | Minh Trường |
| **TC-REG-002** | Verify that registering with an email already in use is rejected with duplicate validation error. | 1. Navigate to /register.<br>2. Enter an existing email: patient@gmail.com.<br>3. Fill in other fields validly.<br>4. Click 'Đăng ký' button. | Registration fails. Error message displayed: 'Email này đã được sử dụng. Vui lòng chọn email khác hoặc Đăng nhập'. No OTP sent. | Email patient@gmail.com already exists in database. | Passed | 18/10/2026 | Minh Trường |
| **TC-REG-003** | Verify that submitting the correct OTP activates the account and allows logging in. | 1. On /verify-otp screen, check mailbox for 6-digit OTP.<br>2. Input the exact OTP received.<br>3. Click 'Xác nhận' button. | OTP is verified. Account status is set to 'Active' in database. Success notification displayed. User is redirected to login. | Valid registration session exists and OTP is within 5 minutes expiry. | Passed | 18/10/2026 | Minh Trường |
| **TC-REG-004** | Verify that submitting an incorrect or expired OTP shows error and prevents activation. | 1. On /verify-otp screen, input wrong OTP: 000000.<br>2. Click 'Xác nhận' button. | Verification fails. Error message displayed: 'Mã OTP không chính xác hoặc đã hết hiệu lực'. Account remains inactive. | User is on /verify-otp screen. | Passed | 18/10/2026 | Minh Trường |
| **TC-REG-005** | Verify that clicking 'Resend OTP' generates a new code and resets countdown timer. | 1. Wait for 60 seconds cooldown to elapse.<br>2. Click 'Gửi lại mã OTP' link.<br>3. Check email inbox. | New 6-digit OTP is sent to user email. Old OTP is invalidated. 60-second cooldown timer restarts. | User is on /verify-otp and cooldown finished. | Passed | 18/10/2026 | Minh Trường |

### Scenario 3: Quên mật khẩu & Đặt lại mật khẩu (Forgot Password Screen)

| Test Case ID | Test Case Description | Test Case Procedure | Expected Results | Pre-conditions | Status | Test Date | Tester |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-FP-001** | Verify that submitting a registered email on Forgot Password sends password reset OTP. | 1. Navigate to /forgot-password.<br>2. Enter registered email: patient@gmail.com.<br>3. Click 'Gửi mã xác nhận' button. | Reset OTP is sent to the email. User is redirected to /verify-reset-otp with success notice. | Email exists in database. | Passed | 18/10/2026 | Minh Trường |
| **TC-FP-002** | Verify that entering an unregistered email displays error message. | 1. Navigate to /forgot-password.<br>2. Enter non-existent email: unknown@domain.com.<br>3. Click 'Gửi mã xác nhận' button. | System displays error: 'Email này không tồn tại trong hệ thống'. No email is dispatched. | Email does not exist in database. | Passed | 18/10/2026 | Minh Trường |
| **TC-FP-003** | Verify that user can set a new password after valid OTP verification and log in with it. | 1. Verify OTP successfully on /verify-reset-otp.<br>2. Enter New Password: NewPass@2026.<br>3. Confirm Password: NewPass@2026.<br>4. Click 'Lưu thay đổi'.<br>5. Try logging in with new password. | Password hash is updated in database. Success alert displayed. User can log in with new password. | Reset OTP verified successfully. | Passed | 18/10/2026 | Minh Trường |

### Scenario 4: Quản lý hồ sơ cá nhân & Đổi mật khẩu (Personal Profile Screen)

| Test Case ID | Test Case Description | Test Case Procedure | Expected Results | Pre-conditions | Status | Test Date | Tester |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-PROF-001** | Verify that logged-in user can update their full name, phone number, DOB, and address. | 1. Log in and go to /profile.<br>2. Update Full Name to 'Trần Văn Bình', Phone to '0912345678', DOB to '1995-10-20', Address to '456 Hai Bà Trưng, Q1'.<br>3. Click 'Lưu thông tin' button. | Profile is updated in database. Success alert: 'Cập nhật hồ sơ thành công'. Refreshing page retains new values. | User is logged in. | Passed | 18/10/2026 | Minh Trường |
| **TC-PROF-002** | Verify that user can change password when supplying correct current password. | 1. Navigate to Change Password tab in profile.<br>2. Enter Current Password: Pass@123.<br>3. Enter New Password: Pass@456.<br>4. Confirm New Password: Pass@456.<br>5. Click 'Cập nhật mật khẩu'. | Password is updated. Success notification displayed. Subsequent login with Pass@456 succeeds. | User is logged in. | Passed | 18/10/2026 | Minh Trường |
| **TC-PROF-003** | Verify that entering wrong current password prevents password change. | 1. In Change Password tab, enter wrong Current Password: WrongPass.<br>2. Enter valid new password.<br>3. Click 'Cập nhật mật khẩu'. | Password change fails. Error message: 'Mật khẩu hiện tại không chính xác'. Password remains unchanged. | User is logged in. | Passed | 18/10/2026 | Minh Trường |
| **TC-PROF-004** | Verify that clicking Logout terminates session and prevents back-button access to private pages. | 1. Click user avatar in top navbar.<br>2. Click 'Đăng xuất' (Logout).<br>3. In browser, click Back button. | Session is invalidated. Redirects to /home or /login. Clicking Back button does not allow viewing protected user data. | User is currently logged in. | Passed | 18/10/2026 | Minh Trường |

---

## Workflow 2: Public Portal & Online Booking (Trang chủ & Đặt lịch khám trực tuyến)

- **Yêu cầu kiểm thử (Requirement):** Kiểm tra hiển thị thông tin phòng khám, tra cứu lịch bác sĩ, đặt lịch khám trực tuyến 4 bước, thanh toán VietQR / PayOS, cơ chế chống trùng lịch (Anti-double booking) và tra cứu lịch sử khám.
- **Số lượng Test Case:** 11 TCs

### Scenario 1: Thông tin phòng khám & Lịch làm việc công khai

| Test Case ID | Test Case Description | Test Case Procedure | Expected Results | Pre-conditions | Status | Test Date | Tester |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-PUB-001** | Verify that Landing Page displays clinic information, service catalog, doctor team, and medical equipment. | 1. Access website root URL /.<br>2. Scroll through sections: About Clinic, Featured Services, Doctors, Facility Gallery. | All images, doctor bios, specialties, and service pricing load properly without UI defects. | System web app is running. | Passed | 18/10/2026 | Minh Trường |
| **TC-PUB-002** | Verify that public doctor schedule screen displays approved weekly working shifts for doctors. | 1. Navigate to /doctor-schedules.<br>2. Select week from dropdown.<br>3. Filter by specialty or doctor name. | Timetable grid renders showing Morning/Afternoon shifts, assigned rooms, and doctor names accurately. | Doctors have approved work schedules for the selected week. | Passed | 18/10/2026 | Minh Trường |

### Scenario 2: Đặt lịch khám trực tuyến 4 bước & Thanh toán VietQR / PayOS

| Test Case ID | Test Case Description | Test Case Procedure | Expected Results | Pre-conditions | Status | Test Date | Tester |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-BOOK-001** | Verify complete 4-step online booking flow resulting in QR payment generation. | 1. Go to /booking.<br>2. Step 1: Select service 'Khám tổng quát mắt'.<br>3. Step 2: Choose future date, doctor, and an available slot (e.g. 09:00 - 09:30).<br>4. Step 3: Enter patient name, phone, symptoms.<br>5. Step 4: Review summary and click 'Xác nhận & Thanh toán'. | Appointment is created with status 'Pending_Payment'. VietQR code with exact service fee and payment description is displayed with a 10-minute countdown. | Selected time slot is vacant. PayOS/VietQR API is operational. | Passed | 18/10/2026 | Minh Trường |
| **TC-BOOK-002** | Verify anti-double-booking concurrency lock prevents two patients from booking the same doctor slot. | 1. User A books slot 09:00 for Dr. Nam and proceeds to payment.<br>2. User B simultaneously attempts to book the same slot 09:00 for Dr. Nam and clicks Confirm. | User B is rejected with error: 'Khung giờ này vừa có người đặt trước. Vui lòng chọn khung giờ hoặc bác sĩ khác'. No duplicate appointment created. | Slot 09:00 is active or pending for another patient. | Passed | 18/10/2026 | Minh Trường |
| **TC-BOOK-003** | Verify that booking date picker disables past dates and days when the doctor is off-duty. | 1. In Step 2 of booking form, observe the calendar picker.<br>2. Try to pick yesterday's date or a date where doctor has no registered schedule. | Past dates are grayed out/unclickable. When picking an off-duty day, system shows 'Bác sĩ không có lịch khám vào ngày này' and hides slots. | Doctor has days off in Work_Schedule. | Passed | 18/10/2026 | Minh Trường |
| **TC-BOOK-004** | Verify that successful PayOS payment webhook automatically updates appointment status to Confirmed and dispatches email. | 1. On payment QR screen, simulate successful bank transfer / PayOS webhook callback.<br>2. Check browser screen and patient mailbox. | System processes webhook, updates status to 'Confirmed', redirects to booking success page with digital ticket, and sends confirmation email. | Appointment is in 'Pending_Payment' state. | Passed | 18/10/2026 | Minh Trường |
| **TC-BOOK-005** | Verify that if payment is not completed within 10 minutes, the booking expires and slot is released. | 1. Generate payment QR and wait for 10-minute timer to reach 00:00.<br>2. Attempt to scan QR after expiration. | QR is disabled with notice: 'Giao dịch đã hết hạn'. Appointment status becomes 'Cancelled'. Slot becomes available again. | 10-minute timeout expires. | Passed | 18/10/2026 | Minh Trường |

### Scenario 3: Quản lý lịch hẹn & Yêu cầu hoàn tiền (Patient History & Refund)

| Test Case ID | Test Case Description | Test Case Procedure | Expected Results | Pre-conditions | Status | Test Date | Tester |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-HIST-001** | Verify that patient can view full appointment history with statuses. | 1. Log in as Patient.<br>2. Navigate to /appointment-history. | Table lists all appointments with Code, Date & Time, Doctor, Service, Status (Pending, Confirmed, Completed, Cancelled). | Patient has at least one appointment. | Passed | 18/10/2026 | Minh Trường |
| **TC-HIST-002** | Verify that patient can cancel an appointment >24 hours prior to appointment time. | 1. Locate a Confirmed appointment scheduled >24 hours in the future.<br>2. Click 'Hủy lịch hẹn'.<br>3. Enter cancellation reason: 'Bận việc gia đình'.<br>4. Confirm. | Appointment status changes to 'Cancelled'. Slot is released for other patients. Success message displayed. | Current time is at least 24 hours before appointment slot. | Passed | 18/10/2026 | Minh Trường |
| **TC-HIST-003** | Verify that patient can submit a refund request for a paid cancelled appointment. | 1. Go to /refund-request.<br>2. Select cancelled paid appointment.<br>3. Enter Bank Name, Account Number, Account Holder Name.<br>4. Click 'Gửi yêu cầu'. | Refund request is submitted with status 'Pending'. Success alert displayed. Request appears in staff refund dashboard. | Appointment was paid and cancelled in accordance with clinic refund policy. | Passed | 18/10/2026 | Minh Trường |
| **TC-HIST-004** | Verify that patient can view detailed invoice and medical examination records for completed appointments. | 1. In /medical-history, click on a 'Completed' appointment.<br>2. Click 'Xem chi tiết hóa đơn'. | Screen renders doctor diagnosis, visual acuity results, prescribed medicines/glasses, and breakdown of fees. | Appointment status is 'Completed'. | Passed | 18/10/2026 | Minh Trường |

---

## Workflow 3: Admin - System Configuration & User Management (Quản trị hệ thống & Cấu hình)

- **Yêu cầu kiểm thử (Requirement):** Kiểm tra chức năng cấu hình khung giờ khám, cấu hình danh sách phòng khám, hình ảnh cơ sở vật chất và quản trị người dùng nội bộ (thêm mới, sửa quyền, kích hoạt/vô hiệu hóa).
- **Số lượng Test Case:** 7 TCs

### Scenario 1: Cấu hình phòng khám, khung giờ & hình ảnh (Clinic Configuration)

| Test Case ID | Test Case Description | Test Case Procedure | Expected Results | Pre-conditions | Status | Test Date | Tester |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-ADM-CFG-001** | Verify that Admin can activate/deactivate appointment time slots in Clinic Configuration. | 1. Log in as Admin, navigate to /admin/clinic-config tab Time Slots.<br>2. Toggle slot 07:30 - 08:00 to 'Inactive'.<br>3. Click 'Lưu cấu hình'.<br>4. Open /booking on another tab. | Configuration saved to database. The 07:30 - 08:00 slot is no longer displayed on the booking page. | User has System_Admin role. | Passed | 18/10/2026 | Minh Trường |
| **TC-ADM-CFG-002** | Verify that Admin can add a new examination clinic room. | 1. In /admin/clinic-config tab Rooms, click 'Thêm phòng'.<br>2. Enter Room Name: 'Phòng Khám Khúc Xạ 3', Floor: 'Tầng 2', Department: 'Khúc xạ'.<br>3. Click 'Lưu'. | New room is added to room list and becomes selectable when assigning employee work schedules. | Admin is logged in. | Passed | 18/10/2026 | Minh Trường |
| **TC-ADM-CFG-003** | Verify that Admin can upload facility and imaging system images. | 1. In Gallery tab, select an eye examination machine image (.jpg, <5MB).<br>2. Enter Title and Description.<br>3. Click 'Cập nhật'. | Image uploads successfully, shows preview in admin, and reflects on public landing page gallery. | Image format is valid (.jpg/.png). | Passed | 18/10/2026 | Minh Trường |

### Scenario 2: Quản lý người dùng hệ thống (System User List & Add & Detail)

| Test Case ID | Test Case Description | Test Case Procedure | Expected Results | Pre-conditions | Status | Test Date | Tester |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-ADM-USR-001** | Verify that Admin can view and filter system users by role and keyword. | 1. Go to /admin/users.<br>2. Filter role by 'Doctor'.<br>3. Enter doctor name keyword in search box.<br>4. Click Search. | Table lists only matching Doctor accounts, showing Full Name, Email, Phone, Specialty, and Status. | Admin is logged in. | Passed | 18/10/2026 | Minh Trường |
| **TC-ADM-USR-002** | Verify that Admin can create a new staff or doctor system user account. | 1. Go to /admin/user-add.<br>2. Enter Email: doctor.tran@eyeclinic.com.<br>3. Role: Doctor, Full Name: 'BS. Trần Quốc Tuấn', Phone: '0938112233', Specialty: 'Giác mạc'.<br>4. Click 'Thêm người dùng'. | Account created with initial password, status 'Active', linked to Employee record. Success notice shown. | Email is unique in system. | Passed | 18/10/2026 | Minh Trường |
| **TC-ADM-USR-003** | Verify that Admin can deactivate and reactivate a user account. | 1. On user list, click 'Vô hiệu hóa' (Deactivate) on an active user.<br>2. Confirm dialog.<br>3. Try logging into deactivated account.<br>4. Click 'Kích hoạt' (Activate). | Step 1-2: Status changes to 'Deactivated'. Step 3: Login is rejected. Step 4: Status becomes 'Active' and user can log in. | Target user exists. | Passed | 18/10/2026 | Minh Trường |
| **TC-ADM-USR-004** | Verify that Admin can view user detail and update role / permissions. | 1. Open /admin/user-detail?id=X.<br>2. Change role from Staff to Medical_Specialist.<br>3. Click 'Lưu cập nhật'. | Role and employee profile updated in database. User accesses Medical_Specialist features on next login. | Admin is logged in. | Passed | 18/10/2026 | Minh Trường |

---

## Workflow 4: Admin - Catalog & Medical Items (Danh mục Dịch vụ & Vật tư Y tế)

- **Yêu cầu kiểm thử (Requirement):** Quản lý danh mục dịch vụ khám, giá dịch vụ, danh mục thuốc nhỏ mắt/thuốc điều trị và tròng kính/gọng kính y tế.
- **Số lượng Test Case:** 5 TCs

### Scenario 1: Quản lý danh mục dịch vụ phòng khám (Clinic Services)

| Test Case ID | Test Case Description | Test Case Procedure | Expected Results | Pre-conditions | Status | Test Date | Tester |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-SRV-001** | Verify that Admin can update clinic service prices. | 1. Go to /admin/catalog tab Services.<br>2. Select service 'Đo khúc xạ chuyên sâu'.<br>3. Update Price from 150,000 to 180,000 VND.<br>4. Click 'Cập nhật'. | Price is updated. Booking wizard and service catalog reflect new price 180,000 VND immediately. | Admin is logged in. | Passed | 18/10/2026 | Minh Trường |
| **TC-SRV-002** | Verify that Admin can add a new clinic medical service. | 1. Click 'Thêm dịch vụ mới'.<br>2. Enter Code: 'DV-OCT01', Name: 'Chụp cắt lớp võng mạc OCT', Category: 'Cận lâm sàng', Price: '350000'.<br>3. Click 'Lưu dịch vụ'. | New service appears in catalog, becomes available for doctor order and online booking. | Service code is unique. | Passed | 18/10/2026 | Minh Trường |
| **TC-SRV-003** | Verify that adding service with negative price or blank name is rejected. | 1. Leave Service Name blank or enter Price: -50000.<br>2. Click 'Lưu dịch vụ'. | Form submission is blocked with validation error: 'Đơn giá phải là số nguyên dương lớn hơn 0'. | Admin is on add service screen. | Passed | 18/10/2026 | Minh Trường |

### Scenario 2: Quản lý danh mục thuốc & kính mắt (Medical Items & Glasses)

| Test Case ID | Test Case Description | Test Case Procedure | Expected Results | Pre-conditions | Status | Test Date | Tester |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-ITEM-001** | Verify that Admin can update medical item pricing and stock thresholds. | 1. Go to Medical Items tab.<br>2. Search item 'Systane Ultra'.<br>3. Update unit price to 110,000 VND.<br>4. Click 'Lưu'. | Unit price is updated in DB. Doctors prescribing this item see the updated 110,000 VND price. | Item exists in catalog. | Passed | 18/10/2026 | Minh Trường |
| **TC-ITEM-002** | Verify that Admin can add a new medication or optical glasses item. | 1. Click 'Thêm vật tư/thuốc'.<br>2. Select Type: 'Thuốc nhỏ mắt', Name: 'Tobrex 0.3% 5ml', Unit: 'Lọ', Price: 75000.<br>3. Click 'Lưu'. | New item is saved in database and appears in prescription auto-suggest dropdown for doctors. | Admin is logged in. | Passed | 18/10/2026 | Minh Trường |

---

## Workflow 5: Employee - Work Schedule Management (Đăng ký & Xem lịch làm việc)

- **Yêu cầu kiểm thử (Requirement):** Bác sĩ/Nhân viên tra cứu lịch phân ca theo tuần và thực hiện đăng ký nguyện vọng ca làm việc cho tuần tới.
- **Số lượng Test Case:** 3 TCs

### Scenario 1: Tra cứu & Đăng ký lịch làm việc

| Test Case ID | Test Case Description | Test Case Procedure | Expected Results | Pre-conditions | Status | Test Date | Tester |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-SCH-001** | Verify that employee/doctor can view their assigned weekly working schedule. | 1. Log in as Doctor/Staff.<br>2. Go to /employee/schedule.<br>3. Select target week from dropdown. | Timetable renders with Monday-Sunday columns, showing Morning/Afternoon shifts, assigned rooms, and shift status. | Employee has approved schedule. | Passed | 18/10/2026 | Minh Trường |
| **TC-SCH-002** | Verify that employee can register preferred working shifts for upcoming open week. | 1. Go to /employee/register-schedule.<br>2. Choose upcoming open week.<br>3. Check desired slots (e.g. Mon Morning, Wed Afternoon).<br>4. Click 'Gửi đăng ký lịch'. | Registrations are stored with status 'Pending_Approval'. Confirmation message: 'Đăng ký lịch làm việc thành công'. | Upcoming week registration is still open (before Sunday deadline). | Passed | 18/10/2026 | Minh Trường |
| **TC-SCH-003** | Verify that registering shifts for a closed or past week is disabled. | 1. Try to open registration for current or past week. | Checkboxes are disabled. Notice displayed: 'Thời gian đăng ký ca cho tuần này đã kết thúc'. | Week deadline has passed. | Passed | 18/10/2026 | Minh Trường |

---

## Workflow 6: Receptionist / Staff - Clinic Queue & Check-in (Lễ tân - Tiếp đón & Hàng đợi)

- **Yêu cầu kiểm thử (Requirement):** Lễ tân tiếp đón bệnh nhân đến phòng khám, Check-in vào hàng đợi, ghi chú y tế ban đầu, gọi số vào phòng khám hoặc xử lý vắng mặt / bỏ qua lượt.
- **Số lượng Test Case:** 7 TCs

### Scenario 1: Tiếp đón & Check-in bệnh nhân (Appointment List & Detail)

| Test Case ID | Test Case Description | Test Case Procedure | Expected Results | Pre-conditions | Status | Test Date | Tester |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-STF-001** | Verify that Staff can search today's appointments and check-in arriving patient. | 1. Log in as Staff, navigate to /staff/appointments.<br>2. Search patient by phone number or appointment ID.<br>3. Click 'Tiếp đón / Check-in'. | Status transitions from 'Confirmed' to 'Waiting'. Patient is moved into today's examination queue (/staff/waiting-list). | Appointment is Confirmed and scheduled for today. | Passed | 18/10/2026 | Minh Trường |
| **TC-STF-002** | Verify that Receptionist can record initial medical intake notes. | 1. Open /staff/appointment-detail?id=X.<br>2. In 'Medical Notes' field, type: 'Bệnh nhân dị ứng penicillin, mắt trái mờ đột ngột 2 ngày'.<br>3. Click 'Lưu ghi chú'. | Notes are saved to appointment record. Attending doctor sees these notes upon starting consultation. | Staff has active session. | Passed | 18/10/2026 | Minh Trường |
| **TC-STF-003** | Verify that Staff can cancel an appointment directly at reception with reason. | 1. On appointment detail, click 'Hủy lịch'.<br>2. Select reason: 'Bệnh nhân báo bận, yêu cầu đổi lịch'.<br>3. Confirm cancellation. | Appointment status is set to 'Cancelled'. Doctor's slot is liberated. Success message displayed. | Appointment is not completed. | Passed | 18/10/2026 | Minh Trường |

### Scenario 2: Điều phối hàng đợi phòng khám (Receptionist Waiting List & Queue Actions)

| Test Case ID | Test Case Description | Test Case Procedure | Expected Results | Pre-conditions | Status | Test Date | Tester |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-QUE-001** | Verify that Staff can call a waiting patient into doctor's consultation room (Start Exam). | 1. Navigate to /staff/waiting-list.<br>2. Find patient in 'Waiting' status.<br>3. Click 'Gọi vào phòng' (Call into room). | Status updates to 'In_Progress'. Queue board shows patient currently inside doctor's examination room. | Doctor and room currently have no other In_Progress patient. | Passed | 18/10/2026 | Minh Trường |
| **TC-QUE-002** | Verify that system prevents calling another patient if doctor already has an In_Progress examination. | 1. Dr. Nam currently has Patient A 'In_Progress'.<br>2. Staff attempts to call Patient B for Dr. Nam. | Action blocked with error: 'Bác sĩ hiện đang khám cho bệnh nhân khác! Mỗi ca chỉ có 1 bệnh nhân trong phòng, vui lòng hoàn tất ca hiện tại trước'. | A patient is already In_Progress with the same doctor/room. | Passed | 18/10/2026 | Minh Trường |
| **TC-QUE-003** | Verify that Staff can skip turn (Missed Queue) for an absent patient, moving them to end of queue. | 1. Patient is called but not at waiting room.<br>2. Staff clicks 'Bỏ qua lượt / Nhường lượt' (Skip queue). | Patient remains in 'Waiting' status but is reordered to the end of the queue line. | Patient status is 'Waiting'. | Passed | 18/10/2026 | Minh Trường |
| **TC-QUE-004** | Verify that Staff can mark a patient as absent after multiple calls. | 1. Staff clicks 'Báo vắng mặt' on patient.<br>2. Select reason: 'Gọi nhiều lần không có mặt'.<br>3. Confirm. | Status changes to 'Cancelled' (Reason: Vắng mặt). Patient is removed from the active waiting list. | Patient is in waiting list. | Passed | 18/10/2026 | Minh Trường |

---

## Workflow 7: Doctor - Examination & Prescription (Bác sĩ - Khám bệnh & Kê đơn)

- **Yêu cầu kiểm thử (Requirement):** Bác sĩ tiếp nhận bệnh nhân trong phòng, xem bệnh sử mắt, nhập kết quả khám lâm sàng (thị lực, nhãn áp, chẩn đoán), chỉ định cận lâm sàng và kê đơn thuốc/kính mắt.
- **Số lượng Test Case:** 6 TCs

### Scenario 1: Khám lâm sàng & Nhập kết quả (Doctor Examination Flow)

| Test Case ID | Test Case Description | Test Case Procedure | Expected Results | Pre-conditions | Status | Test Date | Tester |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-DOC-001** | Verify that Doctor can filter waiting list to see only their assigned patients. | 1. Log in as Doctor.<br>2. Navigate to /staff/waiting-list.<br>3. Verify default view or select 'Bác sĩ của tôi'. | Table lists only patients checked-in for this specific doctor today. | Doctor has patients checked in. | Passed | 18/10/2026 | Minh Trường |
| **TC-DOC-002** | Verify that Doctor can view patient profile and medical history. | 1. Click on patient in queue.<br>2. Review patient demographics, allergies, past diagnoses, and previous prescriptions. | Complete patient history is retrieved and displayed clearly. | Patient has previous medical records. | Passed | 18/10/2026 | Minh Trường |
| **TC-DOC-003** | Verify that Doctor can input and save clinical eye examination results. | 1. On Clinical Examination Form, enter:<br>   - Right Eye (OD) Visual Acuity: 10/10<br>   - Left Eye (OS) Visual Acuity: 6/10<br>   - Intraocular Pressure: 16 mmHg<br>   - Diagnosis: Viêm kết mạc cấp mắt trái<br>   - Advice: Tránh dụi mắt, đeo kính bảo hộ.<br>2. Click 'Lưu kết quả khám'. | Results are persisted to Medical_Record in database. Success alert shown. Ready for prescription. | Appointment is In_Progress. | Passed | 18/10/2026 | Minh Trường |

### Scenario 2: Kê đơn thuốc, đo kính & Hoàn tất ca khám (Prescription Form)

| Test Case ID | Test Case Description | Test Case Procedure | Expected Results | Pre-conditions | Status | Test Date | Tester |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-DOC-004** | Verify that Doctor can prescribe medications with dosage instructions. | 1. On Prescription tab, search 'Tobrex 0.3%'.<br>2. Enter Quantity: 1 Lọ, Dosage: 'Nhỏ mắt trái 1 giọt x 3 lần/ngày'.<br>3. Click 'Thêm vào đơn'.<br>4. Click 'Lưu đơn thuốc'. | Medication item is added. Total prescription cost is calculated based on unit price. Saved to database. | Examination form completed. | Passed | 18/10/2026 | Minh Trường |
| **TC-DOC-005** | Verify that Doctor can prescribe optical glasses refractive parameters. | 1. On Glasses tab, enter SPH, CYL, AXIS, PD parameters for both eyes.<br>2. Click 'Lưu đơn kính'. | Glasses prescription parameters are recorded in patient's medical file ready for printing. | Refraction examination completed. | Passed | 18/10/2026 | Minh Trường |
| **TC-DOC-006** | Verify that Doctor can mark examination as Completed, freeing the room and generating bill. | 1. After completing diagnosis and prescription, click 'Hoàn tất ca khám' (Complete Exam). | Appointment status changes to 'Completed'. Room is released for next patient. Final invoice is generated. | Clinical diagnosis saved. | Passed | 18/10/2026 | Minh Trường |

---

## Workflow 8: Medical Specialist - Paraclinical Procedures (Kỹ thuật viên Cận lâm sàng)

- **Yêu cầu kiểm thử (Requirement):** Tiếp nhận các chỉ định cận lâm sàng từ bác sĩ (chụp đáy mắt, đo khúc xạ máy, chụp bản đồ giác mạc), thực hiện kỹ thuật và trả kết quả/hình ảnh chẩn đoán.
- **Số lượng Test Case:** 3 TCs

### Scenario 1: Danh sách hàng đợi & Thực hiện thủ thuật cận lâm sàng

| Test Case ID | Test Case Description | Test Case Procedure | Expected Results | Pre-conditions | Status | Test Date | Tester |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-SPC-001** | Verify that Medical Specialist can view queue of pending paraclinical procedure orders. | 1. Log in as Medical_Specialist.<br>2. Navigate to /specialist/waiting-list.<br>3. Filter status by 'Pending' and date today. | List of pending procedure orders displays Patient Name, Order ID, Requested Procedure, Requesting Doctor, Status. | Specialist role active. Procedure orders exist. | Passed | 18/10/2026 | Minh Trường |
| **TC-SPC-002** | Verify that Specialist can view order instructions and patient details. | 1. Click on a procedure order in queue.<br>2. View target eye (OD / OS / Both) and doctor's clinical notes. | Order details and required imaging instructions are displayed accurately. | Order exists in system. | Passed | 18/10/2026 | Minh Trường |
| **TC-SPC-003** | Verify that Specialist can execute procedure, upload imaging results, and mark completed. | 1. On execution form, enter findings: 'Hình ảnh gai thị tròn rõ, tỷ lệ C/D 0.3, hoàng điểm bình thường'.<br>2. Upload fundus photography image file.<br>3. Click 'Hoàn thành thủ thuật'. | Order status changes to 'Completed'. Imaging file and notes attach to patient's electronic health record. | Valid image file selected. | Passed | 18/10/2026 | Minh Trường |

---

