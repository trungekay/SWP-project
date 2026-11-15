# SWP391 PROJECT REPORT
# AI Usage Report

**Nguyễn Văn Trung · [Mã SV: HE18xxxx] · [Lớp: SE18xx] · Nhóm 2 (VisionCare)**

– Hanoi, Nov 2026 –

---

## I. Mục đích của báo cáo
Báo cáo trình bày cách em sử dụng công cụ AI (ChatGPT / Antigravity) trong dự án **VisionCare - Eye Clinic Management System** của Nhóm 2, môn SWP391. Với mỗi sản phẩm (artifact/tính năng) được chọn, em ghi rõ phần AI hỗ trợ, quyết định do em đưa ra và căn cứ kỹ thuật để điều chỉnh kết quả.

Các ví dụ bao quát những công việc do em trực tiếp đảm nhiệm xuyên suốt dự án từ tháng 09 đến tháng 11/2026. Em tập trung vào:
1. **Phân tích yêu cầu (SRS):** Tự xây dựng toàn bộ Sơ đồ Use Case Diagram toàn hệ thống cho 5 tác nhân (Patient, Doctor, Staff, Specialist, Admin/Director) và bộ hồ sơ đặc tả Use Case Specification toàn diện.
2. **Thiết kế giao diện (UI/UX):** Trang chủ (Home Page MediLab), Cấu hình phòng khám và ca khám cho Admin (Time Slots, Clinic Rooms, System Images, Pending Hold Time), Full luồng Đặt lịch khám trực tuyến (Online Booking 5 bước) và Bộ 6 màn hình Danh sách & Lịch trực dành cho Giám đốc (Director).
3. **Triển khai kỹ thuật (Implementation):** Tích hợp cổng thanh toán trực tuyến PayOS (VietQR động), giải thuật khóa giữ chỗ tạm thời (Slot Hold Time với Session/Database), cơ chế Polling AJAX tự động xác thực biên lai chuyển khoản, giải thuật ma trận lịch trực 53 tuần ISO 8601 (`ScheduleCell[7][14]`), và logic đặt lại 14 ca khám chuẩn y tế tại `TimeSlotDAO`.

---

## II. Cấu trúc báo cáo

### Phần 0 - Thông Tin Chung

| Mục | Nội dung |
| :--- | :--- |
| **Nhóm / sinh viên** | Nhóm 2 · Nguyễn Văn Trung · [Mã SV: HE18xxxx] · [Lớp: SE18xx] |
| **Công cụ AI đã dùng** | Antigravity AI Agent & ChatGPT Codex trong workspace dự án. |
| **Phạm vi báo cáo** | Hệ thống VisionCare (Java Servlet, JSP, JSTL, JDBC, SQL Server, Bootstrap 5, PayOS API). Ba giai đoạn: Phân tích yêu cầu, Thiết kế và Triển khai mã nguồn. |
| **Hình thức lưu log** | File log hội thoại tương tác trực tiếp trong workspace dự án, work log commits trên nhánh `trung-dev` của Git repository. |
| **Chiến lược tổng thể** | Em xác định trước các ràng buộc nghiệp vụ phòng khám (chuẩn y tế 14 ca/ngày, thời gian giữ chỗ chống race condition, tích hợp VietQR PayOS, phân quyền Director). Em yêu cầu AI sinh mã khung/boilerplate, sau đó tự tay rà soát, kiểm thử JDBC, bắt lỗi khóa ngoại và tối ưu hóa trải nghiệm người dùng trước khi đóng gói commit. |

---

### Phần 1 - Báo Cáo Theo Từng Giai Đoạn

Các mức dưới đây ghi nhận vai trò chính của AI trong từng sản phẩm. “Sửa” bao gồm phản hồi làm thay đổi phương án hoặc yêu cầu AI cập nhật mã theo quyết định của em:

| Mức | Ý nghĩa |
| :---: | :--- || **A - AI tạo, SV giữ nguyên** | AI tạo ra gần như hoàn chỉnh, SV review và chấp nhận không sửa nội dung (chỉ format). |
| **B - AI tạo khung, SV chỉnh nội dung** | AI tạo cấu trúc/khung ban đầu, SV sửa đổi đáng kể nội dung (business logic, số liệu, quyết định thiết kế). |
| **C - SV tạo, AI hỗ trợ hoàn thiện** | SV tự viết ý tưởng/bản thảo trước, AI giúp diễn đạt/format/bổ sung chi tiết. |
| **D - SV tự làm hoàn toàn** | Không dùng AI cho phần này (SV tự tư duy, phân tích và thực hiện 100%). |

---

### 1. Phân tích yêu cầu

#### 1.1.1 - Bảng phân công AI ↔ Sinh viên (Contribution Map)

| Artifact / Mục | Mức | Tóm tắt phần SV đã sửa/thêm (nếu B hoặc C) |
| :--- | :---: | :--- |
| **SRS - Use Case Diagram toàn hệ thống** | **D** | **SV tự làm hoàn toàn 100%:** Tự phân rã nghiệp vụ phòng khám chuyên khoa Mắt thành 5 tác nhân chính (Patient, Doctor, Staff, Specialist, Admin/Director), xác định các mối quan hệ `<<include>>`, `<<extend>>` và vẽ sơ đồ tổng thể. |
| **SRS - Đặc tả Use Case (Use Case Specs toàn hệ thống)** | **C** | **SV tự thiết kế kịch bản & cấu trúc luồng:** SV lên ý tưởng luồng khám bệnh và các ngoại lệ thực tế; AI hỗ trợ chuẩn hóa biểu mẫu (Main Flow, Alternative Flow, Exception Flow). SV đã loại bỏ 4 use case thừa không phù hợp quy mô đồ án và bổ sung các use case cốt lõi: Giữ chỗ ca khám tạm thời, Hủy lịch trực tuyến, Đối soát giao dịch PayOS và Reset 14 ca khám chuẩn. |
| **SRS - Mockup giao diện các màn hình phụ trách** | **B** | **AI tạo bố cục lưới cơ bản, SV tinh chỉnh chi tiết:** AI gợi ý layout wireframe; SV trực tiếp chỉnh sửa giao diện chọn ca khám trực quan dạng grid badge, bổ sung màn hình quét mã VietQR kèm đồng hồ đếm ngược (Hold time), và thiết kế bố cục ma trận 7 ngày x 14 ca cho màn hình Giám đốc. |

#### 1.1.2 - Ví dụ Prompt Tiêu Biểu

##### PT-01 · Sơ đồ Use Case toàn hệ thống và Phân rã Actor
*Prompt tổng hợp từ hội thoại.*
- **Bối cảnh:** Dự án VisionCare cần phân rã rõ ràng ranh giới nghiệp vụ giữa 5 nhóm người dùng: Bệnh nhân (đặt lịch, thanh toán), Bác sĩ (khám, chẩn đoán), Kỹ thuật viên khúc xạ/chuyên viên (thực hiện cận lâm sàng), Lễ tân (tiếp đón, check-in, thu ngân) và Ban Giám đốc/Admin (giám sát lịch trực toàn viện, cấu hình hệ thống).
- **Yêu cầu:** Xác định các gói use case theo từng Actor, phân biệt rạch ròi phạm vi giữa việc Giám đốc xem lịch trực (chỉ giám sát, không chỉnh sửa trực tiếp trên lịch của Admin) và Bệnh nhân tự hủy lịch trước giờ khám.
- **Đầu ra:** Bảng danh mục Use Case có phân nhóm theo Actor và danh sách các quan hệ phụ thuộc (`include`/`extend`).
- **Trích output AI:** *“Đề xuất chia hệ thống thành 5 phân hệ tương ứng 5 Actor. Riêng Actor Director cần gộp quyền xem lịch của cả Bác sĩ, Nhân viên lễ tân và Chuyên viên y tế để đảm bảo tính điều phối vĩ mô...”*
- **Nhận xét:** Em đã không để AI tự vẽ sơ đồ mà chỉ tham khảo đề xuất cấu trúc, sau đó tự tay vẽ hoàn chỉnh sơ đồ Use Case Diagram mức tổng quát và mức chi tiết cho từng actor (Mức D).

##### PT-02 · Đặc tả Use Case Đặt lịch khám và Cơ chế Giữ chỗ (Hold Time)
*Prompt tổng hợp từ hội thoại.*
- **Bối cảnh:** Khi bệnh nhân chọn ca khám và chuyển sang bước quét mã QR, ca khám đó cần được tạm khóa để tránh tình trạng hai người cùng đặt một bác sĩ tại cùng một khung giờ (Race condition / Overbooking). Nếu bệnh nhân không thanh toán trong thời hạn cho phép, hệ thống phải tự động nhả ca khám ra cho người khác.
- **Yêu cầu:** Soạn thảo kịch bản đặc tả chi tiết Use Case `UC-Online-Booking`, bao gồm: Pre-conditions, Main Flow (4 bước), Alternative Flows (hết hạn giữ chỗ, giao dịch thanh toán thất bại, người dùng chủ động bấm Hủy) và Post-conditions.
- **Đầu ra:** Bảng đặc tả chuẩn IEEE-830 với đầy đủ mã lỗi và quy tắc nghiệp vụ thời gian giữ chỗ động (`hold_time_minutes`).
- **Trích output AI:** *“Alternative Flow AF-02 (Hết thời gian giữ chỗ): Nếu sau N phút hệ thống chưa nhận được Webhook thanh toán thành công, trạng thái lịch hẹn chuyển từ PENDING_PAYMENT sang CANCELLED_TIMEOUT, time slot được mở lại cho bệnh nhân khác...”*
- **Nhận xét:** Em đã chuẩn hóa quy tắc nghiệp vụ: tham số thời gian giữ chỗ `hold_time_minutes` không được hard-code mà phải lấy động từ bảng cấu hình `Clinic_Setting`, mặc định là 10 phút và cho phép Admin điều chỉnh từ 1 đến 120 phút.

#### 1.1.3 - Thay Đổi So Với Output AI & Lý Do
- **Cơ chế hủy ca và giữ chỗ:** AI ban đầu đề xuất hủy ngay slot nếu người dùng tải lại trang (F5). Em đã thay đổi yêu cầu: hệ thống phải giữ nguyên phiên đặt khám (`orderCode` và `appointmentId`) qua Session để bệnh nhân F5 trang vẫn tiếp tục đồng hồ đếm ngược mà không bị mất chỗ.
- **Tách bạch vai trò Director:** AI từng gộp chung quyền sửa đổi lịch vào vai trò Giám đốc. Em đã chỉnh lại trong SRS: Giám đốc chỉ có quyền giám sát (Read-only / Audit) đối với 6 danh mục lịch trực của Bác sĩ, Nhân viên và Chuyên viên; quyền phân bổ ca làm việc thuộc về Admin/Trưởng bộ phận.

#### 1.1.4 - Vấn Đề / Sai Sót Của AI Đã Phát Hiện
- AI bỏ sót kịch bản người dùng chuyển khoản sai số tiền hoặc sai nội dung chuyển khoản dẫn đến treo trạng thái `PENDING_PAYMENT`. Em đã tự bổ sung vào SRS mục kịch bản Exception Flow: Hệ thống phải có nút "Hủy phiên đặt lịch" để người bệnh tự giải phóng ca khám ngay lập tức mà không cần chờ hết thời gian time-out.

#### 1.1.5 - Tự Đánh Giá Hiểu Bài (Self-Check)
1. **Tại sao cơ chế đặt lịch khám bệnh trực tuyến bắt buộc phải có trạng thái PENDING giữ chỗ tạm thời?**
   - *Trả lời:* Nếu chỉ ghi nhận lịch hẹn sau khi thanh toán thành công, trong khoảng thời gian từ lúc bệnh nhân mở mã QR đến lúc quét mã (khoảng 3–10 phút), một bệnh nhân khác hoàn toàn có thể chọn cùng bác sĩ và ca khám đó, dẫn đến xung đột dữ liệu kép (Double Booking). Trạng thái PENDING đóng vai trò là một khóa logic (soft-lock) để bảo vệ tính toàn vẹn của lịch khám.
2. **Tại sao use case xem lịch trực của Director lại cần tách thành 6 màn hình riêng biệt?**
   - *Trả lời:* Vì trong phòng khám chuyên khoa Mắt, ba khối nhân sự (Bác sĩ chuyên khoa, Nhân viên lễ tân/hành chính, và Chuyên viên/Kỹ thuật viên đo khúc xạ) có đặc thù ca kíp, phòng làm việc và quy trình nghiệp vụ hoàn toàn khác nhau. Việc tách thành 6 màn hình (3 màn danh sách nhân sự + 3 màn hình ma trận lịch tuần tương ứng) giúp Giám đốc bao quát đúng chuyên môn mà không bị lẫn lộn thông tin.

---

### 2. Thiết kế

#### 1.2.1 - Bảng phân công AI ↔ Sinh viên (Contribution Map)

| Artifact / Mục | Mức | Tóm tắt phần SV đã sửa/thêm (nếu B hoặc C) |
| :--- | :---: | :--- |
| **Trang chủ (Home Page MediLab)** | **B** | **AI chuyển đổi template HTML sang JSP:** SV phát hiện hiện tượng giật layout (jank) khi cuộn chuột và thanh navbar che mất nội dung; SV đã tự tay sửa CSS `sticky-top`, cấu hình dynamic banner và dynamic service cards từ CSDL. |
| **Admin - Configure Appointment Time Slots** | **B** | **SV thiết kế lại chuẩn y tế 14 ca/ngày:** AI sinh khung bảng CRUD; SV thay thế toàn bộ bằng mô hình 14 ca chuẩn (30 phút/ca, sáng 8h00–11h30, chiều 13h30–17h00, nghỉ trưa 2h), bổ sung tính năng nút Reset 14 ca chuẩn và xóa bỏ buffer slot không phù hợp. |
| **Admin - Configure Clinic Rooms** | **B** | **SV thiết kế Card Grid trực quan:** Thay thế bảng table thô sơ của AI bằng giao diện Card Grid hiện đại, tự động nhận diện Icon chuyên khoa theo tên phòng (Phòng khám mắt tổng quát, Phòng đo khúc xạ, Phòng tiểu phẫu), bổ sung cảnh báo ràng buộc khóa ngoại khi xóa phòng. |
| **Admin - Configure Image of System** | **B** | **SV thiết kế giao diện Banner & Gallery:** Tích hợp bộ quản lý ảnh Banner Slider trang chủ và Gallery phòng khám, hỗ trợ xem trước ảnh (image preview) tức thì và toggle trạng thái hiển thị Active/Inactive. |
| **Admin - Configure Pending Hold Time** | **C** | **SV thiết kế form cài đặt tham số động:** Thiết kế giao diện cho phép Admin cấu hình thời gian giữ chỗ (1–120 phút), bổ sung 4 nút chọn nhanh (+5p, +10p, +15p, +30p) để nâng cao trải nghiệm thao tác của Admin. |
| **Patient - Luồng Online Booking & PayOS VietQR** | **B** | **SV thiết kế Wizard 4 bước + Màn 5 thành công:** Thiết kế thanh tiến trình (Step Progress Bar), giao diện chọn ca khám trực quan có màu sắc phân biệt (Trống, Đã đặt, Quá giờ), màn hình quét mã VietQR ngân hàng kèm thanh đếm lùi thời gian thực (Circular / Linear countdown timer). |
| **Director - Bộ 6 màn hình Danh sách & Lịch trực** | **B** | **SV thiết kế giao diện Ma trận Lịch tuần 7x14:** Thiết kế layout chuyên nghiệp gồm bộ lọc tuần ISO 8601 (53 tuần/năm), dropdown chọn phòng/bác sĩ, và bảng ma trận 7 ngày x 14 ca hiển thị chi tiết tên bác sĩ, bệnh nhân và trạng thái ca khám. |

#### 1.2.2 - Ví dụ Prompt Tiêu Biểu

##### TK-01 · Màn hình Thanh toán VietQR PayOS và Đồng hồ đếm lùi giữ chỗ
*Prompt tổng hợp từ hội thoại.*
- **Bối cảnh:** Bệnh nhân sau khi điền thông tin ở Bước 3 sẽ chuyển sang Bước 4 (Thanh toán). Cần hiển thị mã QR Code chuẩn EMVCo của PayOS để người dùng mở ứng dụng ngân hàng quét mã, đồng thời hiển thị đồng hồ đếm lùi thời gian giữ chỗ.
- **Yêu cầu:** Thiết kế giao diện Bootstrap 5 chia 2 cột: Cột trái là thông tin tóm tắt lịch khám (Bác sĩ, Dịch vụ, Ngày khám, Ca khám, Viện phí); Cột phải là khung quét mã QR thanh toán PayOS kèm số tài khoản, tên chủ tài khoản, mã đơn hàng và widget đồng hồ đếm lùi từ thời gian cấu hình về 00:00.
- **Đầu ra:** Đoạn mã giao diện JSP/HTML đáp ứng chuẩn responsive mobile-friendly, có hiệu ứng trực quan khi thanh toán thành công hoặc khi hết hạn.
- **Trích output AI:** *“Sử dụng thẻ `<div class="card shadow-sm">` kết hợp thư viện ảnh VietQR từ PayOS API và một đoạn mã JavaScript `setInterval` để đếm lùi 600 giây...”*
- **Nhận xét:** Em đã chỉnh sửa lại mã JS của AI: thay vì hard-code 600 giây trên client, thời gian giữ chỗ được truyền trực tiếp từ model server (`${holdTimeSeconds}`) dựa trên `Clinic_Setting`, đồng thời gắn kèm cơ chế Polling ngầm kiểm tra trạng thái thanh toán mà không làm đơ trình duyệt.

##### TK-02 · Lưới Card Phòng khám và Ma trận Lịch trực 53 tuần ISO cho Director
*Prompt tổng hợp từ hội thoại.*
- **Bối cảnh:** Giám đốc cần một cái nhìn trực quan về toàn bộ hoạt động phòng khám trong từng tuần của năm. Bảng hiển thị thông thường theo hàng dọc rất khó theo dõi xung đột lịch.
- **Yêu cầu:** Thiết kế giao diện ma trận hai chiều: Trục ngang là 7 ngày trong tuần (Thứ Hai đến Chủ Nhật kèm ngày tháng thực tế), Trục dọc là 14 ca khám bệnh chuẩn y tế. Mỗi ô trong ma trận thể hiện trạng thái ca trực của nhân sự.
- **Đầu ra:** Giao diện Table responsive với các class CSS phân biệt rõ màu sắc: ca có lịch hẹn (xanh lam), ca đang trống (xám nhạt), ca đã hoàn thành (xanh lá). Phía trên có thanh chọn Tuần (Tuần 1 đến Tuần 52/53 của năm được chọn).
- **Trích output AI:** *“Tạo table với header là danh sách thứ trong tuần, thân bảng lặp qua danh sách 14 TimeSlot, mỗi cell sẽ kiểm tra xem có lịch trực tương ứng hay không...”*
- **Nhận xét:** Em đã bổ sung thêm tính năng tự động nhảy đến đúng Tuần hiện tại của ngày hôm nay (`selectedWeek`), và thiết kế modal xem nhanh thông tin chi tiết bác sĩ khi click vào từng ô trên ma trận.

#### 1.2.3 - Thay Đổi So Với Output AI & Lý Do
- **Loại bỏ buffer slot:** AI từng đề xuất thêm một ca "buffer slot" vào cuối ngày trong màn hình `AdminTimeSlotConfig`. Em đã xóa bỏ hoàn toàn vì theo thực tế phòng khám Mắt, các ca khám đã được ấn định cố định 30 phút/ca; việc thêm buffer slot tự do sẽ phá vỡ quy chuẩn phân lịch của bác sĩ.
- **Tối ưu hiển thị Icon phòng khám:** AI ban đầu chỉ dùng một icon phòng mặc định (`bi-door-closed`). Em đã viết hàm script phân tích tên phòng để gán icon y tế tương ứng: nếu tên có chữ "Khúc xạ" gán icon kính mắt (`bi-eyeglasses`), "Tiểu phẫu" gán icon kéo phẫu thuật (`bi-scissors`), "Tổng quát" gán icon ống nghe y tế (`bi-clipboard2-pulse`).

#### 1.2.4 - Vấn Đề / Sai Sót Của AI Đã Phát Hiện
- AI tạo giao diện thanh toán bằng form submit tự động reload trang mỗi 3 giây để kiểm tra tiền vào. Cách làm này khiến màn hình bị giật trắng liên tục và người dùng không thể quét được mã QR. Em đã sửa lại bằng cách sử dụng AJAX `fetch()` ngầm để kiểm tra biên lai thanh toán một cách mượt mà.

#### 1.2.5 - Tự Đánh Giá Hiểu Bài (Self-Check)
1. **Tại sao việc chia lưới 14 ca khám chuẩn (30 phút/ca) lại tối ưu hơn việc cho phép Admin tạo ca khám có thời lượng tùy ý?**
   - *Trả lời:* Trong phòng khám chuyên khoa, thời lượng khám trung bình cho một bệnh nhân mắt là 20–30 phút. Việc chuẩn hóa 14 ca/ngày (7 ca sáng, 7 ca chiều) với giờ nghỉ trưa cố định từ 11h30 đến 13h30 giúp đồng bộ hóa toàn bộ lịch hẹn của bệnh nhân với ca trực của bác sĩ, tránh chồng chéo giờ nghỉ ngơi và hỗ trợ xây dựng ma trận tuần một cách khoa học.
2. **Cơ chế đồng bộ giữa thanh tiến trình 4 bước và URL của trang đặt lịch hoạt động như thế nào?**
   - *Trả lời:* Controller `BookAppointmentServlet` nhận tham số `step` (1, 2, 3, 4) qua Request Param. Tương ứng với từng bước, Servlet nạp dữ liệu cần thiết (Step 1: danh sách chuyên khoa; Step 2: danh sách bác sĩ và ca trống; Step 3: thông tin cá nhân; Step 4: dữ liệu VietQR PayOS) và truyền thuộc tính `currentStep` ra JSP để kích hoạt active class trên thanh tiến trình.

---

### 3. Triển khai

#### 1.3.1 - Bảng phân công AI ↔ Sinh viên (Contribution Map)

| Artifact / Mục | Mức | Tóm tắt phần SV đã sửa/thêm (nếu B hoặc C) |
| :--- | :---: | :--- |
| **`BookAppointmentServlet.java`** | **B** | **SV hoàn thiện luồng thanh toán kép và kiểm soát phiên:** AI tạo khung router Servlet; SV trực tiếp triển khai: (1) Tạo link PayOS chuẩn HMAC-SHA256, (2) Tạo cơ chế Session `BookingPaymentSession` chống tạo trùng mã đơn khi F5, (3) Hàm API `checkPayment` phục vụ Polling AJAX, (4) Logic tự động rollback ca khám khi bệnh nhân hủy hoặc timeout. |
| **`DirectorScheduleServlet.java`** | **B** | **SV viết thuật toán Ma trận 7x14 và Lịch tuần ISO 8601:** SV chia cấu trúc controller thành 7 phần logic rõ ràng; tự viết giải thuật tính toán 53 tuần ISO theo `Calendar` và ánh xạ dữ liệu phẳng từ database vào ma trận hai chiều `ScheduleCell[7][14]` phục vụ render JSP. |
| **`AdminTimeSlotConfigServlet.java` & `TimeSlotDAO.java`** | **B** | **SV triển khai nghiệp vụ Reset 14 ca chuẩn & Ràng buộc toàn vẹn:** Bổ sung transaction an toàn trong `TimeSlotDAO` để khôi phục cấu hình mặc định; bổ sung kiểm tra khóa ngoại để ngăn chặn việc xóa ca khám đã có bệnh nhân đặt lịch trong tương lai. |
| **`AdminRoomConfigServlet.java` & `RoomDAO.java`** | **B** | **SV xử lý CRUD phòng khám & Ràng buộc khóa ngoại:** Triển khai quản lý phòng khám, kiểm tra điều kiện phòng đang có ca trực bác sĩ trước khi cho phép vô hiệu hóa hoặc xóa. |
| **`ClinicBannerDAO.java` & `ClinicGalleryDAO.java`** | **C** | **SV xây dựng DAO tương tác CSDL ảnh hệ thống:** SV viết câu lệnh SQL và logic mapping ResultSet, AI hỗ trợ tối ưu cấu trúc kết nối `DBContext` và xử lý đóng `PreparedStatement` an toàn. |
| **`AppointmentDAO.java` (Các hàm phục vụ Booking)** | **B** | **SV tối ưu câu lệnh kiểm tra trùng lịch (Overlap Check):** Tự viết câu query kiểm tra slot khả dụng: loại trừ các lịch hẹn đã bị `CANCELLED` hoặc `EXPIRED_TIMEOUT`, đảm bảo bệnh nhân chỉ chọn được ca khám thực sự còn trống. |

#### 1.3.2 - Ví dụ Prompt Tiêu Biểu

##### TR-01 · Tích hợp PayOS VietQR động và Polling AJAX trong BookAppointmentServlet
*Prompt tổng hợp từ hội thoại.*
- **Bối cảnh:** Khi bệnh nhân xác nhận thông tin đặt lịch ở Bước 3, hệ thống cần lưu lịch hẹn ở trạng thái `PENDING_PAYMENT`, đồng thời gọi API sang PayOS để lấy chuỗi dữ liệu thanh toán VietQR động kèm chữ ký số HMAC-SHA256. Client cần tự động nhận biết ngay khi bệnh nhân chuyển khoản thành công để chuyển sang Bước 5.
- **Yêu cầu:** Triển khai logic trong `BookAppointmentServlet.java` xử lý action `createPendingAppointment` và action `checkPayment`. Đảm bảo sinh mã đơn `orderCode` duy nhất không bị lỗi tràn số nguyên (dùng kiểu `long`).
- **Ràng buộc:** Không được tạo nhiều bản ghi `Appointment` trùng lặp khi người dùng F5 tại màn hình quét mã QR; phải đóng kết nối CSDL và xử lý ngoại lệ mạng khi gọi API PayOS.
- **Trích output AI:** *“Tạo phương thức gọi HTTP POST tới endpoint `/v2/payment-requests` của PayOS với các trường: orderCode, amount, description, cancelUrl, returnUrl. Sau đó trả về JSON checkoutUrl...”*
- **Nhận xét:** Em đã phát hiện AI lưu `orderCode` dưới dạng số ngẫu nhiên không kiểm soát, dễ dẫn đến xung đột khi tải lại trang. Em đã bổ sung lớp `BookingPaymentSession` để lưu vết `(appointmentId, orderCode, expireTime)` trong HTTP Session, tái sử dụng mã đơn cũ nếu bệnh nhân vẫn trong thời gian giữ chỗ.

##### TR-02 · Thuật toán Lịch tuần 53 tuần ISO và Ma trận 7x14 trong DirectorScheduleServlet
*Prompt tổng hợp từ hội thoại.*
- **Bối cảnh:** Bảng CSDL lưu lịch trực theo từng dòng riêng lẻ `(schedule_id, staff_id, room_id, slot_id, work_date)`. Giám đốc cần xem bảng tổng hợp 7 ngày x 14 ca của một nhân sự bất kỳ trong một tuần ISO 8601 cụ thể.
- **Yêu cầu:** Xây dựng thuật toán trong `DirectorScheduleServlet.java` để: (1) Tính toán ngày bắt đầu (Thứ Hai) và ngày kết thúc (Chủ Nhật) của tuần thứ `W` trong năm `Y`, (2) Khởi tạo ma trận `ScheduleCell[7][14]`, (3) Điền dữ liệu từ danh sách trả về của DAO vào đúng tọa độ `[dayOfWeek - 1][slotIndex]`.
- **Ràng buộc:** Chuẩn hóa theo chuẩn ISO 8601 (Thứ Hai là ngày đầu tuần, Tuần 1 là tuần có ít nhất 4 ngày thuộc năm mới).
- **Trích output AI:** *“Sử dụng `java.util.Calendar` thiết lập `setFirstDayOfWeek(Calendar.MONDAY)` và `setMinimalDaysInFirstWeek(4)` để tính toán dải ngày từ Thứ Hai đến Chủ Nhật...”*
- **Nhận xét:** Em đã trực tiếp tái cấu trúc toàn bộ file `DirectorScheduleServlet.java` thành 7 khối chức năng rành mạch (Khối 1: Điều hướng chung; Khối 2: Doctor Schedule; Khối 3: Doctor List; Khối 4: Staff Schedule; Khối 5: Staff List; Khối 6: Specialist Schedule; Khối 7: Specialist List), thêm chú thích tường minh cho từng khối để thuận tiện cho việc bảo trì và chấm điểm đồ án.

#### 1.3.3 - Thay Đổi So Với Output AI & Lý Do
- **Khắc phục lỗi tạo trùng Appointment khi Refresh:** AI ban đầu viết logic mỗi lần vào action `payment` lại gọi hàm `INSERT INTO Appointment`, khiến cho việc bệnh nhân F5 trang thanh toán tạo ra hàng loạt bản ghi rác trong database. Em đã sửa lại: chỉ INSERT một lần duy nhất tại bước submit Form, sau đó lưu `appointmentId` vào Session và chỉ thực hiện `SELECT` đối soát.
- **Chuyển đổi kiểu dữ liệu OrderCode PayOS:** AI sử dụng kiểu `int` cho mã đơn hàng `orderCode`. Do PayOS yêu cầu mã đơn hàng là số nguyên dương ngẫu nhiên lớn (lên tới 9 chữ số hoặc timestamp), kiểu `int` trong Java dễ bị tràn số (`Integer Overflow`). Em đã chủ động sửa thành kiểu `long`.

#### 1.3.4 - Vấn Đề / Sai Sót Của AI Đã Phát Hiện

| Tình huống | AI đã làm/đề xuất gì | Vì sao sai/ko phù hợp | Em đã làm gì |
| :--- | :--- | :--- | :--- |
| **Phân bổ ca khám mặc định** | AI đề xuất cho phép Admin xóa sạch bảng `Time_Slot` mà không kiểm tra ràng buộc. | Vi phạm toàn vẹn dữ liệu: Bảng `Appointment` và `Doctor_Schedule` chứa khóa ngoại tham chiếu đến `slot_id`. Nếu xóa trắng sẽ gây lỗi crash `SQLException (Foreign Key Constraint Fail)`. | Em đã viết lại hàm `resetDefaultTimeSlots()` trong `TimeSlotDAO`: Chỉ cập nhật lại giờ bắt đầu/kết thúc cho 14 ca hiện có và chuyển trạng thái `is_active = 1`, không dùng lệnh `DELETE` nguy hiểm. |
| **Xử lý bất đồng bộ khi thanh toán** | AI đề xuất dùng Webhook công khai trỏ về `localhost` của sinh viên. | Webhook của máy chủ PayOS trên Internet không thể gọi trực tiếp về địa chỉ IP `localhost:8080` của máy tính cá nhân khi chưa cấu hình dynamic DNS phức tạp (như ngrok). | Em đã chuyển đổi sang cơ chế kép: Vừa hỗ trợ Webhook chuẩn cho môi trường triển khai thực tế, vừa triển khai cơ chế **Polling AJAX (`checkPayment`)** gọi định kỳ mỗi 3 giây từ trình duyệt client về Servlet để đối soát trực tiếp với PayOS qua REST API. |
| **Tính toán tuần đầu tiên của năm** | AI sử dụng `Calendar.DAY_OF_YEAR / 7` để tính số thứ tự tuần. | Cách tính chia số học đơn giản này hoàn toàn sai lệch so với chuẩn quốc tế ISO 8601, dẫn đến việc các ngày đầu năm bị tính sai tuần và nhảy lịch trực của bác sĩ. | Em đã sửa lại bằng cách sử dụng các hằng số chuẩn `Calendar.WEEK_OF_YEAR`, ép `Calendar.MONDAY` làm ngày đầu tuần và quy định `MinimalDaysInFirstWeek = 4`. |

#### 1.3.5 - Tự Đánh Giá Hiểu Bài (Self-Check)
1. **Lệnh `response.getWriter().write(json.toString());` trong `handleCheckPayment()` có vai trò kỹ thuật gì?**
   - *Trả lời:* Lệnh này dùng để ghi dữ liệu văn bản thuần định dạng JSON trực tiếp vào luồng xuất (Output Stream) của HTTP Response gửi về cho Client, thay vì điều hướng (forward/redirect) sang trang JSP. Nhờ đó, trình duyệt phía người dùng có thể nhận kết quả ngầm qua AJAX `fetch()`, tự động phát hiện khi nào hóa đơn đã thanh toán thành công để chuyển trang mà không gây tải lại toàn bộ giao diện.
2. **Tại sao cần dùng cơ chế mã hóa HMAC-SHA256 khi giao tiếp với cổng PayOS?**
   - *Trả lời:* Chuỗi chữ ký số HMAC-SHA256 được tạo ra từ việc ghép các tham số đơn hàng (amount, orderCode, description, returnUrl) theo thứ tự bảng chữ cái và băm với khóa bí mật `CHECKSUM_KEY`. Cơ chế này đảm bảo tính toàn vẹn dữ liệu (Data Integrity): nếu kẻ tấn công cố tình sửa đổi số tiền trên đường truyền mạng, chữ ký băm sẽ không khớp và PayOS sẽ lập tức từ chối giao dịch, ngăn chặn hoàn toàn nguy cơ gian lận viện phí.

---

### Phần 2 - Số Liệu Tổng Hợp (Quantitative Summary)

| Giai đoạn | Số artifact chính | Mức A (AI tạo, giữ nguyên) | Mức B (AI tạo khung, SV sửa) | Mức C (SV tạo, AI hỗ trợ) | Mức D (SV tự làm hoàn toàn) | Số vòng lặp prompt TrB /artifact |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **1. Phân tích yêu cầu** | 3 | 0 | 1 | 1 | 1 | 2 - 3 |
| **2. Thiết kế** | 7 | 0 | 6 | 1 | 0 | 3 - 4 |
| **3. Triển khai** | 6 | 0 | 5 | 1 | 0 | 4 - 6 |
| **TỔNG CỘNG** | **16** | **0 (0%)** | **12 (75%)** | **3 (18.75%)** | **1 (6.25%)** | **~ 3.8 vòng/artifact** |

**Phân tích số liệu:**
Số liệu phản ánh chân thực quá trình học tập và làm việc của em trong đồ án:
- Không có bất kỳ artifact cốt lõi nào thuộc **Mức A** (0% sao chép nguyên mẫu từ AI). Điều này khẳng định em luôn giữ vai trò phản biện, làm chủ logic nghiệp vụ và mã nguồn.
- Phần lớn sản phẩm nằm ở **Mức B (75%)**: Em tận dụng tối đa thế mạnh của AI trong việc sinh mã khung chuẩn (HTML form, Servlet boilerplate, JDBC queries), sau đó tự tay lập trình bổ sung các nghiệp vụ phức tạp đặc thù của đồ án (PayOS VietQR, Hold Time, Ma trận 53 tuần, Reset 14 ca chuẩn).
- **Mức C (18.75%)** và **Mức D (6.25%)**: Em tự mình tư duy và vẽ toàn bộ Sơ đồ Use Case Diagram toàn hệ thống cho 5 Actor mà không để AI làm thay, đồng thời tự tay thiết kế tài liệu đặc tả và cấu hình tham số hệ thống.

#### Checklist Traceability

Bảng dưới đây đối chiếu mức độ hoàn thiện minh chứng theo quy trình công nghệ phần mềm:

| Giai đoạn | Số mục checklist đạt / tổng | Mục chưa đạt (nếu có) + kế hoạch xử lý |
| :--- | :---: | :--- |
| **1. Phân tích yêu cầu** | 6 / 6 (100%) | Đã đối chiếu đầy đủ giữa Sơ đồ Use Case Diagram toàn hệ thống, tài liệu đặc tả luồng Booking Online, và bảng phân quyền 5 Actor. |
| **2. Thiết kế** | 7 / 7 (100%) | Đã hoàn thiện mockup và giao diện thực tế của 7 màn hình (Home, 4 màn Admin, Luồng Booking/VietQR, 6 màn hình Director). |
| **3. Triển khai** | 6 / 6 (100%) | Toàn bộ mã nguồn trên controller (`BookAppointmentServlet`, `DirectorScheduleServlet`, `AdminTimeSlotConfigServlet`,...) đã được kiểm thử, biên dịch thành công không lỗi cú pháp và push đầy đủ lên nhánh `trung-dev`. |

---

### Phần 3 - Phản Tư (Reflection)

#### 1. Việc AI làm tốt hơn em
- **Tốc độ sinh mã khung và cấu trúc lặp:** AI có khả năng viết rất nhanh các đoạn mã chuẩn lặp đi lặp lại như khai báo tham số HTTP request, mở/đóng kết nối JDBC, và sinh các thành phần giao diện Bootstrap cơ bản.
- **Tra cứu cú pháp thư viện:** AI hỗ trợ tra cứu rất nhanh các phương thức mã hóa băm HMAC-SHA256 của Java `Mac` và cú pháp thiết lập lịch của thư viện `java.util.Calendar`.

#### 2. Việc em làm tốt hơn AI
- **Kiểm soát tính toàn vẹn nghiệp vụ (Business Integrity):** AI thường chỉ tập trung vào việc làm cho đoạn code chạy được mà bỏ qua các ràng buộc sâu xa của cơ sở dữ liệu. Em là người trực tiếp chặn việc xóa ca khám đang có lịch hẹn, phát hiện lỗi tràn số `orderCode`, và bổ sung cơ chế Session để ngăn ngừa việc tạo trùng lịch khi người dùng tải lại trang.
- **Thấu hiểu trải nghiệm thực tế của người dùng:** AI đề xuất cách làm thô sơ (như reload trang định kỳ để kiểm tra tiền). Em đã chủ động thay thế bằng cơ chế Polling AJAX mượt mà kèm đồng hồ đếm lùi thời gian thực, đồng thời tự động hóa việc nhận diện icon chuyên khoa của phòng khám.

#### 3. Rủi ro lớn nhất nếu bỏ qua việc rà soát
- Rủi ro lớn nhất là **lỗi sập hệ thống (Runtime Crash) do vi phạm ràng buộc toàn vẹn dữ liệu** và **lỗ hổng bảo mật giao dịch**. Nếu chấp nhận mã nguồn AI sinh ra mà không kiểm tra, câu lệnh xóa trắng ca khám sẽ làm sập database khi có khóa ngoại tham chiếu. Nguy hiểm hơn, nếu không áp dụng chữ ký số HMAC-SHA256 và cơ chế kiểm soát mã đơn hàng, kẻ gian có thể sửa đổi viện phí hoặc gian lận trạng thái thanh toán của phòng khám.

#### 4. Nếu làm lại từ đầu
- Em sẽ thiết lập tài liệu mô tả cấu trúc CSDL và các quy tắc nghiệp vụ bất biến (như chuẩn 14 ca y tế, thời gian giữ chỗ động, định dạng mã đơn hàng) ngay từ prompt đầu tiên trước khi yêu cầu AI viết mã.
- Em sẽ yêu cầu AI tạo ngay các file kiểm thử tự động (Unit Test / Integration Test) cho từng DAO và Servlet ngay từ đầu để rút ngắn thời gian debug thủ công trên giao diện.
