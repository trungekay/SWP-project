# Bộ dữ liệu kiểm thử đúng luồng — FLOW-20261026

Database: `eye_clinic_db`. Không tạo database/bảng/tài khoản/email mới. Chạy lại không reset/xóa/tạo trùng ca đã dùng.

Patient: **Nguyễn Văn An**, email sẵn có `patient.an@gmail.com` (Account_ID=13, Patient_ID=1). Dùng mật khẩu hiện tại của tài khoản; script không đọc/đổi mật khẩu.

Đã xóa 9 ca cũ APT-97..APT-105, INV-00063..INV-00071 và các bản ghi phụ thuộc của riêng bộ ca đó; đã xóa Account `nam.flow.test@example.test`. APT-96/INV-00062 của Nguyễn Văn Nam vẫn giữ nguyên, patient Nam không còn liên kết tài khoản email test.

Phương thức thanh toán dùng Cash / QR_Banking như luồng thật. Các mã ca trong tài liệu là dữ liệu mô phỏng, không phải PayOS receipt thật.

| Ca | Lịch | Hóa đơn | Cách test |
|---|---|---|---|
| BOOKED | APT-111 | INV-00077 | Đã trả phí khám, chưa check-in; patient gửi yêu cầu hủy |
| CANCEL_PENDING | APT-112 | INV-00078 | Patient đã gửi hủy; staff duyệt hủy trước khi tạo refund |
| REFUND_ELIGIBLE | APT-113 | INV-00079 | Staff đã duyệt hủy; patient hoặc staff tạo refund |
| DOCTOR_CANCEL | APT-114 | INV-00080 | Bác sĩ đổi lịch không thể bố trí lịch khác; staff tạo refund |
| REFUND_PENDING | APT-115 | INV-00081 | Refund đã tạo; director duyệt; không được tạo trùng |
| EXPIRED | APT-116 | INV-00082 | Quá 15 phút chưa thanh toán, lịch hủy; không được refund |
| EXAM_DONE_BASE | APT-117 | INV-00083 | Khám xong, không mua thêm; staff chủ động chốt với số tiền thu thêm bằng 0 |
| EXAM_DONE_EXTRAS | APT-118 | INV-00084 | Khám xong, tiểu phẫu đã thực hiện và thêm thuốc; test bỏ mua thuốc và thu phần còn lại |
| PAID_FINAL | APT-119 | INV-00085 | Đã chốt đầy đủ; test xem trước/in hóa đơn và khóa sửa |

Staff và director dùng tài khoản hiện có. Các ca hủy chưa check-in; ca khám xong có check-in, kết quả khám và Examination_Detail. Chỉ Invoice_Checkout.Finalized_At thể hiện staff chốt cuối.
