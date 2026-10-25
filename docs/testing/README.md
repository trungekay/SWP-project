# Phạm vi dữ liệu và hướng dẫn test

Database project đang cấu hình: **eye_clinic_db**. SQL Server còn nhiều database khác, nhưng không có bằng chứng chúng thuộc chức năng của project này; không sửa các database đó. Database ứng dụng có **24 bảng**. Không tạo database hay bảng mới khi seed.

## Bảng thuộc phạm vi bạn liệt kê

| Chức năng | Bảng chính | Bảng liên quan / dùng chung |
|---|---|---|
| Login, Register, Forgot/Change password, profile | Account, Patient | Role; Employee_Profile cho tài khoản staff/director |
| OTP, Log out | Không có bảng riêng | OTP, pendingUser, resetEmail, resetOtpVerified và user được lưu trong HTTP session |
| Appointment history, gửi/duyệt hủy | Appointment, Medical_Record | Patient, Work_Schedule, Employee_Profile, Master_Invoice |
| Request refund, director duyệt refund | Refund_Request | Appointment, Medical_Record, Master_Invoice, Patient, Employee_Profile |
| Medical history | Medical_Record, Examination_Detail, Prescription, Prescription_Detail, Procedure_Order | Appointment, Patient, Employee_Profile, Service_Catalog, Medical_Supply |
| Master invoice, payment status, phương thức, cash/QR, export | Master_Invoice, Payment_Transaction, Invoice_Checkout, Invoice_Checkout_Item, Invoice_Checkout_Payment | Appointment, Patient, Medical_Record, Prescription_Detail, Procedure_Order, Service_Catalog, Medical_Supply |
| Thu tiền chỉ định phẫu thuật | Procedure_Payment_Request | Procedure_Order, Payment_Transaction, Master_Invoice; bảng dùng chung với luồng bác sĩ/chuyên viên |
| Dữ liệu phòng khám/lịch | Work_Schedule, Room | Dùng chung, không sở hữu riêng bởi chức năng hóa đơn |
| Ngoài danh sách chức năng ở yêu cầu này | Clinic_Gallery, Clinic_Setting, Leave_Cancel_Request | Giao diện phòng khám và yêu cầu nghỉ/đổi lịch nhân sự |

Quan hệ chính: `Account → Patient → Appointment → Master_Invoice → Payment_Transaction / Invoice_Checkout / Refund_Request`. Nhánh khám: `Appointment → Medical_Record → Examination_Detail / Prescription → Prescription_Detail / Procedure_Order`. Prescription và Procedure_Order đều tham chiếu trực tiếp Medical_Record (không phải Procedure_Order thuộc Prescription).

Invoice_Checkout_Item là bản chụp khoản thu; Invoice_Checkout.Finalized_At xác định staff đã chốt cuối. Invoice_Checkout_Payment lưu vòng đời yêu cầu QR, không phải một hóa đơn thứ hai. Export dùng hóa đơn đã chốt, không có bảng Export_Invoice riêng.

## Những điểm đã kiểm tra/phát hiện

- 108 khai báo khóa ngoại được kiểm tra, không có bản ghi mồ côi ở thời điểm kiểm kê.
- Không có lịch hẹn bị tạo nhiều master invoice.
- Có 15 lịch Confirmed thiếu hóa đơn trong dữ liệu cũ. Không suy ra đã thu tiền chỉ từ Confirmed; cần chứng từ/thông tin nguồn trước khi sửa.
- Có 1 Refund_Request Pending không khớp điều kiện hủy được duyệt trước check-in. Không tự duyệt/xóa/chuyển tiền cho bản ghi đó.
- 16 hóa đơn Paid chưa chốt checkout trước seed không đồng nghĩa 16 lỗi: Paid cũ có thể mới là phí khám; trạng thái giao diện phải dựa thêm bước kết thúc khám và chốt cuối.
- Đã sửa lỗi patient invoice truy vấn bảng Medicine không tồn tại; dùng chung cách tính với StaffInvoiceDAO, giữ giá/bản chụp cuối, không đoán giá thuốc.
- Bảng Eyeglass_Prescription không có trong database hiện tại. Trang bệnh án kiểm tra bảng tùy chọn trước khi đọc, vẫn hiển thị đơn thuốc bình thường; không tạo bảng giả để che lỗi. Mua tròng kính trong hóa đơn dùng Medical_Supply/Prescription_Detail; thông số đơn kính chi tiết cần một công việc riêng nếu muốn có chức năng này.
- Dùng tài khoản An hiện có để test login/profile/history. Chỉ gửi OTP/quên mật khẩu đến email bạn kiểm soát khi tự test trên UI; không chèn OTP giả hoặc gửi email tự động trong quá trình chuẩn bị dữ liệu.
- Bộ ca được seed vào các trạng thái bắt đầu cần test; không có nghĩa toàn bộ chuyển bước trên browser/email/PayOS đã được chạy thật. Các bài kiểm tra tích hợp dùng fixture rollback; không chi tiêu/chuyển tiền thật.

## Đăng nhập và ca test

Xem `user-flow-fixtures-20261026.md` để lấy tài khoản patient, các mã lịch/hóa đơn. Dùng **tài khoản Nguyễn Văn An hiện có** (`patient.an@gmail.com`, Account_ID=13, Patient_ID=1), không tạo email/tài khoản mới, không đổi mật khẩu hoặc profile của An. Bộ cũ APT-97..105 và email nam.flow.test@example.test đã xóa. Ca pending tiểu phẫu APT-96 của Nguyễn Văn Nam vẫn giữ riêng, không thuộc tài khoản An.

1. Đăng nhập Nguyễn Văn An bằng mật khẩu hiện tại: xem lịch sử, mở hóa đơn, cập nhật profile, đăng xuất/đăng nhập lại. Nếu tự test đổi mật khẩu, bạn sẽ đổi mật khẩu tài khoản An thật đang dùng; seed không đổi/reset mật khẩu.
2. APT-111: patient gửi hủy → staff duyệt hủy → patient hoặc staff tạo refund → director duyệt. Trước duyệt hủy không có quyền tạo refund.
3. APT-112: vào tab Chờ duyệt hủy để staff tiếp tục từ bước chờ duyệt; chưa tạo Refund_Request.
4. APT-113: đã duyệt hủy trước check-in, thử tạo refund từ patient hoặc staff; chỉ tạo một yêu cầu đang xử lý.
5. APT-114: hủy vì bác sĩ đổi lịch không bố trí lịch khác; staff chủ động tạo refund.
6. APT-115: director xem refund Pending để duyệt/từ chối; kiểm tra staff không duyệt refund.
7. APT-116: hết 15 phút chưa trả tiền và đã hủy, hiển thị Chưa thanh toán; không được hoàn tiền/chốt thu thêm.
8. APT-117: Khám xong, không mua thêm, dư nợ 0; chỉ thành Hoàn thành khi staff chủ động chốt, không phát sinh giao dịch tiền mặt giả.
9. APT-118: Khám xong, phí khám đã thu 200.000, tiểu phẫu đã làm 250.000, thuốc Systane 95.000; tổng 545.000, còn 345.000. Thử bỏ mua thuốc: tổng 450.000, còn 250.000; không được bỏ tiểu phẫu đã thực hiện. Thu cash hoặc tạo QR; chỉ xác nhận cash nếu đang kiểm thử thu tiền giả lập. Nếu tạo PayOS QR thật, chỉ chuyển khoản khi bạn muốn thực hiện giao dịch thật.
10. APT-119: Hoàn thành; xem preview/in hóa đơn, không được sửa/chốt thu tiền lần nữa.
11. APT-96 cũ: đang khám, tiểu phẫu pending 250.000; không được thu khoản pending như đã thực hiện, không được hoàn tiền sau check-in.

Các ca test thay đổi khi bạn thao tác. Không tự reset để tránh xóa kết quả bạn đang kiểm tra. Chạy seed lần hai tạo thêm 0 ca đã được xác minh.

## File và cách chạy lại

- `database-audit-20261026.md`: tên DB nhìn thấy, toàn bộ 24 bảng, cột/số dòng trước seed; không chứa mật khẩu DB.
- `user-flow-verification-20261026.md`: kết quả 89 kiểm tra trên bộ ca và chi tiết kiểm tra khóa ngoại.
- `../../scripts/testdata/DatabaseAudit.java`: chỉ đọc schema/count; ghi báo cáo audit.
- `../../scripts/testdata/SeedUserFlows.java`: seed có nhận diện theo marker `[FLOW-20261026:...]`, một transaction rollback nếu lỗi; không xóa dữ liệu hoặc reset ca đã dùng. Chỉ dùng eye_clinic_db local.
- `../../scripts/testdata/VerifyUserFlows.java`: chỉ đọc để kiểm tra trạng thái ban đầu; sau khi bạn thao tác đổi trạng thái test, assertion ban đầu có thể fail là bình thường.
- `../../scripts/testdata/user-flow-checks.sql`: các SELECT để bạn kiểm tra trong SSMS.

Từ thư mục project, sau khi build ứng dụng, chạy PowerShell:

```powershell
New-Item -ItemType Directory -Force build/test-data/classes | Out-Null
javac -encoding UTF-8 -cp 'build/web/WEB-INF/classes;web/WEB-INF/lib/*' -d build/test-data/classes scripts/testdata/*.java
java -cp 'build/test-data/classes;build/web/WEB-INF/classes;src/java;web/WEB-INF/lib/*' DatabaseAudit
java -cp 'build/test-data/classes;build/web/WEB-INF/classes;src/java;web/WEB-INF/lib/*' SeedUserFlows --seed-local
java -cp 'build/test-data/classes;build/web/WEB-INF/classes;src/java;web/WEB-INF/lib/*' VerifyUserFlows
```

Không chạy seed trên database production hoặc dùng các khoản thuộc bộ ca mô phỏng làm doanh thu thật. Mọi tiền thanh toán trong bộ ca là giả lập, không có PayOS receipt thật. Phương thức vẫn lưu đúng nghiệp vụ: `Cash` hoặc `QR_Banking`; nhận diện bộ ca bằng mã lịch trong manifest, không dùng tên phương thức giả.

## Chuẩn hóa phương thức thanh toán (26/10/2026)

Ba cột `Payment_Transaction.Payment_Gateway`, `Invoice_Checkout.Payment_Method`, `Procedure_Payment_Request.Payment_Method` chỉ lưu **Cash** hoặc **QR_Banking**. Giá trị NULL ở hai bảng sau nghĩa là chưa chọn/chưa có giao dịch xác định phương thức; không phải phương thức thứ ba.

Đã gộp Cash_At_Counter → Cash; VietQR_Banking, Bank_Transfer, PayOS_Checkout, VNPay → QR_Banking theo phạm vi hai phương thức được yêu cầu. Dữ liệu mô phỏng Test_Seed/Demo_Seed chuyển QR_Banking. Đây là chuẩn hóa tên nghiệp vụ, không xác nhận thêm giao dịch hay biến tiền mô phỏng thành tiền thật. Chốt dư nợ 0 kế thừa phương thức khoản thu thành công gần nhất; nếu không có chứng từ thì để NULL.

Không thay số tiền, mã/ngày giao dịch, trạng thái khám/hóa đơn/refund. Database hiện có 2 giao dịch Cash, 19 giao dịch QR_Banking tại thời điểm chuẩn hóa. Các trạng thái hiện có đã đối chiếu: Appointment (Pending, Confirmed, In_Progress, Completed, Canceled), Master_Invoice (Paid, Partial_Paid, Canceled, Refunded), Payment_Transaction (Success), Refund_Request (Pending, Approved), Procedure_Order (Pending, Completed), Invoice_Checkout_Payment (Pending). Không có trạng thái Test_Seed/Demo_Seed; không gộp trạng thái của các thực thể khác nhau.

Migration đã áp dụng: `database/migrations/20261026_payment_methods.sql`, có transaction, kiểm tra giá trị lạ và CHECK constraint chống ghi tên sai. Khi tạo mới DB: chạy schema gốc → migration checkout 20261025 → migration phương thức 20261026. Hai bản schema SQL gốc cũng đã cập nhật tên phương thức.

Kiểm tra nhanh:

```sql
SELECT Payment_Gateway, COUNT(*) AS SoGiaoDich FROM Payment_Transaction GROUP BY Payment_Gateway;
SELECT Payment_Method, COUNT(*) AS SoHoaDon FROM Invoice_Checkout GROUP BY Payment_Method;
SELECT Payment_Method, COUNT(*) AS SoYeuCau FROM Procedure_Payment_Request GROUP BY Payment_Method;
```
