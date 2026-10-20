# KỊCH BẢN THUYẾT TRÌNH & BẢO VỆ PHÂN HỆ BOOKING (ITERATION 2)
# HỆ THỐNG PHÒNG KHÁM CHUYÊN KHOA MẮT VISIONCARE

> **Mục đích tài liệu:** Hướng dẫn từng bước từ thao tác giao diện, kịch bản trả lời cô giáo, chỉ thẳng file code và câu lệnh Database SQL Server tương ứng phục vụ buổi review Iteration 2.

---

## MỤC LỤC
1. [Checklist chuẩn bị trước khi vào phòng review](#1-checklist-chuẩn-bị-trước-khi-vào-phòng-review)
2. [Bước 1: Chọn Dịch Vụ & Bệnh Lý (Service Catalog & Medical Packages)](#2-bước-1-chọn-dịch-vụ--bệnh-lý-service-catalog--medical-packages)
3. [Bước 2: Liên Kết Thông Minh Đến Bác Sĩ (Doctor Linking)](#3-bước-2-liên-kết-thông-minh-đến-bác-sĩ-doctor-linking)
4. [Bước 3: Chọn Ngày & Khung Giờ Real-time (Real-time Slots Engine)](#4-bước-3-chọn-ngày--khung-giờ-real-time-real-time-slots-engine)
5. [Bước 4: Điền Thông Tin & Đăng Ký Cho Người Khác (Patient Profiles)](#5-bước-4-điền-thông-tin--đăng-ký-cho-người-khác-patient-profiles)
6. [Bước 5: Sinh Mã QR Động & Cơ Chế Khóa Số Tiền (VietQR & PayOS)](#6-bước-5-sinh-mã-qr-động--cơ-chế-khóa-số-tiền-vietqr--payos)
7. [Bước 6: Tự Động Bắt Thanh Toán (Dual-check) & Cập Nhật Database](#7-bước-6-tự-động-bắt-thanh-toán-dual-check--cập-nhật-database)
8. [Hướng dẫn sửa thời gian Countdown (Nếu cô bảo đổi thành 10 phút / 5 phút)](#8-hướng-dẫn-sửa-thời-gian-countdown-nếu-cô-bảo-đổi-thành-10-phút--5-phút)
9. [Bộ câu lệnh SQL ngắn gọn mở sẵn trong SSMS để Demo](#9-bộ-câu-lệnh-sql-ngắn-gọn-mở-sẵn-trong-ssms-để-demo)
10. [Bộ câu hỏi bẫy phản biện của Giảng viên & Câu trả lời 10/10](#10-bộ-câu-hỏi-bẫy-phản-biện-của-giảng-viên--câu-trả-lời-1010)

---

## 1. CHECKLIST CHUẨN BỊ TRƯỚC KHI VÀO PHÒNG REVIEW

Mở sẵn trên màn hình máy tính 4 tab sau để cô hỏi đến đâu là bấm qua ngay:
* **Tab 1 Trình duyệt:** `http://localhost:8080/SWP-project/book-appointment` (đã đăng nhập tài khoản bệnh nhân).
* **Tab 2 VS Code / NetBeans:** File `BookAppointmentServlet.java`.
* **Tab 3 VS Code / NetBeans:** File `AppointmentDAO.java` và `WorkScheduleDAO.java`.
* **Tab 4 SQL Server (SSMS):** Cửa sổ Query có sẵn các câu lệnh `SELECT` ở [Mục 9](#9-bộ-câu-lệnh-sql-ngắn-gọn-mở-sẵn-trong-ssms-để-demo).

---

## 2. BƯỚC 1: CHỌN DỊCH VỤ & BỆNH LÝ (SERVICE CATALOG & MEDICAL PACKAGES)

### 🎙️ Kịch bản nói với cô:
> *"Dạ thưa cô, phân hệ Booking của nhóm em bắt đầu bằng việc hiển thị danh mục Dịch vụ và Bệnh lý được tải động hoàn toàn từ bảng `Service_Catalog` trong Database.  
> Các gói khám được chia thành 4 nhóm tab trực quan: **Khám & Khúc xạ**, **Tiền phẫu & Tầm soát**, **Mắt trẻ em**, và **Thủ thuật ngoại trú**.  
> **Điểm đặc biệt về nghiệp vụ:** Hệ thống **chủ động lọc bỏ các ca phẫu thuật tiền to (18 — 42 triệu)** như `PT-LASIK`, `PT-SMILE`, `PT-PHACO`. Vì theo quy trình y khoa, bệnh nhân không thể tự đặt mổ qua mạng mà bắt buộc phải đặt gói **Khám tiền phẫu & Tầm soát (500.000 ₫)** trước để đo chiều dày giác mạc. Chi phí 500k này sau đó được hệ thống **cam kết khấu trừ 100% vào chi phí mổ** nếu bệnh nhân đủ điều kiện phẫu thuật."*

### 💻 Vị trí Code:
* **Backend lọc bỏ gói phẫu thuật tiền to:**  
  `src/java/com/visioncare/controller/BookAppointmentServlet.java` (Dòng 586 – 600)
  ```java
  String c = cs.getCode() != null ? cs.getCode().toUpperCase(java.util.Locale.ROOT).trim() : "";
  boolean isMajorSurgery = c.startsWith("PT-"); // Lọc bỏ gói đại phẫu PT-LASIK, PT-SMILE (18-42tr)
  if (!isMajorSurgery) {
      bookingServices.add(cs);
  }
  ```
* **Frontend chia Tab & Vòng lặp hiển thị:**  
  `web/views/appointment/book-appointment.jsp` (Dòng 585 – 670)

---

## 3. BƯỚC 2: LIÊN KẾT THÔNG MINH ĐẾN BÁC SĨ (DOCTOR LINKING)

### 🎙️ Kịch bản nói với cô:
> *"Dạ hệ thống có **cơ chế liên kết thông minh 2 chiều giữa Gói khám và Bác sĩ**:*  
> *1. **Từ ngoài vào:** Nếu bệnh nhân bấm 'Đặt lịch' từ trang giới thiệu bác sĩ (`/book-appointment?doc=5`), Servlet tự nhận diện chuyên khoa của bác sĩ đó để chọn sẵn gói dịch vụ phù hợp.*  
> *2. **Trực tiếp trên form:** Khi bệnh nhân bấm vào bất kỳ gói khám nào, hàm JavaScript `filterDoctorsByService` lập tức quét dropdown, tự động chọn bác sĩ đúng chuyên khoa nhất, gắn nhãn `★ [Đúng chuyên khoa]` và bật thẻ **Doctor Preview Card** hiển thị ảnh chân dung, chuyên môn và phòng khám của bác sĩ."*

### 💻 Vị trí Code:
* **Backend nhận param URL `?doc=...`:**  
  `src/java/com/visioncare/controller/BookAppointmentServlet.java` (Dòng 219 – 245)
* **Frontend tự khớp chuyên khoa:**  
  `web/views/appointment/book-appointment.jsp` (Hàm `filterDoctorsByService`, Dòng 1343 – 1428)
* **Thẻ Preview Card Bác sĩ:**  
  `web/views/appointment/book-appointment.jsp` (Hàm `updateDoctorPreview`, Dòng 1565 – 1635)

---

## 4. BƯỚC 3: CHỌN NGÀY & KHUNG GIỜ REAL-TIME (REAL-TIME SLOTS ENGINE)

### 🎙️ Kịch bản nói với cô:
> *"Dạ sang Bước 2 là chọn Ngày và Khung giờ tiếp đón qua AJAX ngầm (`action=getSlots`). Khung giờ được quản lý theo cơ chế **Real-time (Thời gian thực)**:*  
> *1. **Khóa ngày quá khứ:** Ô chọn ngày được gán `min = today`, người dùng không thể chọn ngày cũ.*  
> *2. **Nhận diện giờ đã trôi qua:** Nếu chọn ngày hôm nay, các khung giờ trước thời điểm hiện tại sẽ tự động bị **gạch ngang, vô hiệu hóa (disabled)** và hiển thị badge màu xám **`Đã qua`**.*  
> *3. **Phân biệt với slot đã đặt:** Slot có người đặt sẽ hiện badge **`Đã kín`**, chỉ có slot còn trống trong tương lai mới bấm chọn được.*  
> *4. **Kiểm tra 2 lớp:** Kể cả khi người dùng cố tình can thiệp mã nguồn để gửi slot quá khứ, Servlet và Database Transaction vẫn kiểm tra lại và chặn ngay lập tức."*

### 💻 Vị trí Code:
* **SQL tính toán Is_Past thời gian thực:**  
  `src/java/com/visioncare/dao/WorkScheduleDAO.java` (Dòng 244 – 255)
  ```sql
  CASE 
    WHEN ws.Work_Date < CAST(DATEADD(HOUR, 7, SYSUTCDATETIME()) AS DATE) THEN 1 
    WHEN ws.Work_Date = CAST(DATEADD(HOUR, 7, SYSUTCDATETIME()) AS DATE) 
         AND CAST(ws.Start_Time AS TIME) <= CAST(DATEADD(HOUR, 7, SYSUTCDATETIME()) AS TIME) THEN 1 
    ELSE 0 
  END AS Is_Past
  ```
* **Frontend hiển thị badge "Đã qua" / "Đã kín":**  
  `web/views/appointment/book-appointment.jsp` (Dòng 1705 – 1720)
* **Server-side chặn đặt slot quá khứ:**  
  `src/java/com/visioncare/controller/BookAppointmentServlet.java` (Dòng 491 – 512)

---

## 5. BƯỚC 4: ĐIỀN THÔNG TIN & ĐĂNG KÝ CHO NGƯỜI KHÁC (PATIENT PROFILES)

### 🎙️ Kịch bản nói với cô:
> *"Dạ ở Bước 3 là Xác thực thông tin bệnh nhân. Phân hệ giải quyết bài toán bệnh viện thực tế:*  
> *1. **Tự động điền (Auto-fill):** Hệ thống tự động lấy thông tin từ tài khoản bệnh nhân đang đăng nhập (Họ tên, SĐT, Email, Ngày sinh) để họ không phải gõ lại.*  
> *2. **Tính năng Đăng ký cho người khác / người thân (`setBookingForOther`):** Người dùng có thể đặt lịch cho bố mẹ hoặc con cái. Khi bấm nút, form sẽ xóa trắng và đổi tiêu đề, cho phép nhập thông tin người đi khám thật. Khi lưu vào DB, hồ sơ bệnh nhân mới được tạo riêng nhưng vẫn liên kết với `Account_ID` của người đặt.*  
> *3. **Điền lại thông tin của tôi (`refillMyInfo`):** Cho phép khôi phục lại dữ liệu người dùng ban đầu nếu đổi ý.*  
> *4. **Validate dữ liệu:** Kiểm tra nghiêm ngặt Regex SĐT 10 số Việt Nam (`^0[3|5|7|8|9]...`) và Email hợp lệ trước khi tạo đơn."*

### 💻 Vị trí Code:
* **Hàm Đăng ký cho người khác & Điền lại:**  
  `web/views/appointment/book-appointment.jsp` (Dòng 1803 – 1840)
* **Tự tạo hồ sơ Patient và liên kết Account:**  
  `src/java/com/visioncare/dao/AppointmentDAO.java` (Hàm `getOrCreatePatient`, Dòng 260 – 315)
* **Regex Server-side Validation:**  
  `src/java/com/visioncare/controller/BookAppointmentServlet.java` (Dòng 460 – 475)

---

## 6. BƯỚC 5: SINH MÃ QR ĐỘNG & CƠ CHẾ KHÓA SỐ TIỀN (VIETQR & PAYOS)

### 🎙️ Kịch bản nói với cô:
> *"Dạ sau khi bấm 'Xác nhận lịch hẹn', Transaction tạo lịch ở trạng thái `Pending` và chuyển sang màn hình Thanh toán giữ chỗ 15 phút:*  
> *1. **Sinh mã QR Động:** Hệ thống không dùng mã QR tĩnh mà gọi SDK PayOS và VietQR NAPAS 247 để sinh mã QR động mang đúng số tiền khám (500.000 ₫) và nội dung chuyển khoản tự động theo mã lịch hẹn `VC{id}`.*  
> *2. **Tại sao khi quét mã không sửa được số tiền:** Vì dữ liệu số tiền được mã hóa theo chuẩn EMVCo và được **ký số bảo mật HMAC-SHA256** tại Backend. Khi app ngân hàng quét vào, nó nhận diện đây là hóa đơn thanh toán đích danh nên **tự động khóa cứng ô số tiền (Read-only)** để chống gian lận (tránh việc khách chuyển 1.000đ hay gõ nhầm số 0)."*

### 💻 Vị trí Code:
* **Backend sinh mã VietQR và PayOS:**  
  `src/java/com/visioncare/controller/BookAppointmentServlet.java` (Dòng 115 – 140)
* **Ký số HMAC-SHA256 khóa số tiền:**  
  `src/java/com/visioncare/util/PayOSUtil.java` (Dòng 100 – 116)
  ```java
  String signData = "amount=" + amount + "&cancelUrl=" + ... + "&orderCode=" + orderCode;
  String signature = hmacSHA256(signData, CHECKSUM_KEY);
  ```
* **Hiển thị QR & Countdown 15 phút:**  
  `web/views/appointment/book-appointment.jsp` (Dòng 400 – 435)

---

## 7. BƯỚC 6: TỰ ĐỘNG BẮT THANH TOÁN (DUAL-CHECK) & CẬP NHẬT DATABASE

### 🎙️ Kịch bản nói với cô:
> *"Dạ hệ thống áp dụng cơ chế **Hai lớp đối soát (Dual-check Architecture)** để bắt thanh toán và phát hành vé khám:*  
> *1. **Lớp 1: Auto-Polling ở Frontend:** Trình duyệt chạy ngầm hàm `setInterval` mỗi 2.5 giây gửi AJAX hỏi Servlet `?action=checkPayment`. Ngay khi tiền vào tài khoản MB Bank, Servlet gọi PayOS API phát hiện trạng thái `PAID` $\rightarrow$ gọi hàm `confirmPayment()` và trả về `isPaid: true`. Trình duyệt nhận tín hiệu này và **tự động nhảy sang trang Vé khám thành công mà người dùng không cần ấn F5**.*  
> *2. **Lớp 2: Webhook ở Backend:** Nếu người dùng vô tình tắt trình duyệt, máy chủ PayOS sẽ bắn HTTP POST về servlet `PayOSWebhookServlet` để cập nhật Database và tự động gửi **Email vé khám điện tử** qua `EmailUtil`.*  
> *3. **Cập nhật Database:** Trong 1 Transaction duy nhất: `Master_Invoice` đổi sang `Paid`, `Payment_Transaction` ghi nhận dòng tiền, `Appointment` đổi sang `Confirmed`, và `Work_Schedule` đổi sang `Booked`."*

### 💻 Vị trí Code:
* **Polling lặp 2.5s ở Frontend:**  
  `web/views/appointment/book-appointment.jsp` (Dòng 1941 – 1960)
* **Servlet kiểm tra PayOS:**  
  `src/java/com/visioncare/controller/BookAppointmentServlet.java` (Dòng 40 – 74)
* **Server-to-Server Webhook:**  
  `src/java/com/visioncare/controller/PayOSWebhookServlet.java` (Dòng 35 – 65)
* **Hàm cập nhật DB liên hoàn `confirmPayment`:**  
  `src/java/com/visioncare/dao/AppointmentDAO.java` (Dòng 108 – 197)

---

## 8. HƯỚNG DẪN SỬA THỜI GIAN COUNTDOWN (NẾU CÔ BẢO ĐỔI THÀNH 10 PHÚT / 5 PHÚT)

Nếu cô giáo bảo sửa từ 15 phút thành 10 phút, bạn mở **3 file** sau để chỉ/sửa:

1. **Frontend:** `web/views/appointment/book-appointment.jsp`
   * Dòng 1907: Đổi `15 * 60 * 1000` thành `10 * 60 * 1000`.
   * Dòng 1928: Đổi `(remainingSec / 900)` thành `(remainingSec / 600)`.
   * Dòng 1957: Đổi `pollAttempts > 360` thành `pollAttempts > 240` (600s / 2.5s).
2. **Backend kiểm tra Slot:** `src/java/com/visioncare/dao/WorkScheduleDAO.java` (Dòng 248)
   * Đổi `< 15` thành `< 10`.
3. **Backend kiểm tra Transaction & Hủy quá hạn:** `src/java/com/visioncare/dao/AppointmentDAO.java`
   * Dòng 27: Đổi `< 15` thành `< 10`.
   * Dòng 1600: Đổi `>= 900` thành `>= 600`.

---

## 9. BỘ CÂU LỆNH SQL NGẮN GỌN MỞ SẴN TRONG SSMS ĐỂ DEMO

### Câu 1: Xem trạng thái Slot giờ (Đã Book hay Chưa Book)
```sql
USE eye_clinic_db;

SELECT TOP 10 
    ws.Schedule_ID, 
    ws.Work_Date, 
    ws.Start_Time, 
    ws.Status AS [Trang_Thai_Slot],
    ap.Status AS [Trang_Thai_Cuoc_Hen]
FROM Work_Schedule ws
LEFT JOIN Appointment ap ON ws.Schedule_ID = ap.Schedule_ID
ORDER BY ws.Schedule_ID DESC;
```
* **Chưa book:** `Trang_Thai_Slot` = `Available`, `Trang_Thai_Cuoc_Hen` = `NULL`
* **Vừa đặt (đang giữ chỗ):** `Trang_Thai_Slot` = `Available`, `Trang_Thai_Cuoc_Hen` = `Pending`
* **Đã thanh toán (xong):** `Trang_Thai_Slot` = `Booked`, `Trang_Thai_Cuoc_Hen` = `Confirmed`

### Câu 2: Xem Hóa Đơn và Tiền Cọc (Đã chuẩn giờ Việt Nam)
```sql
USE eye_clinic_db;

SELECT TOP 5 
    Invoice_ID, 
    Appointment_ID, 
    Deposit_Amount AS [Tien_Coc], 
    Status AS [Trang_Thai_Hoa_Don], 
    Create_At AS [Gio_Tao_Viet_Nam]
FROM Master_Invoice 
ORDER BY Invoice_ID DESC;
```

---

## 10. BỘ CÂU HỎI BẪY PHẢN BIỆN CỦA GIẢNG VIÊN & CÂU TRẢ LỜI 10/10

### Câu 1: Nếu 2 người cùng bấm đặt 1 slot trong cùng 1 tích tắc (Race Condition), hệ thống giải quyết thế nào?
> **Trả lời:**  
> *"Dạ thưa cô, hệ thống giải quyết bằng **Database Transaction kết hợp Kiểm tra trạng thái tức thì (Instant Lock)** tại `AppointmentDAO.java` (dòng 24 – 41).  
> Khi Request của Người A đến trước, Transaction của A ghi bản ghi `Pending`. Khi Request của Người B đến sau chỉ 5 mili-giây, câu query `SELECT COUNT(*)` phát hiện slot đang có `Pending < 15 phút` $\rightarrow$ Transaction của B lập tức kích hoạt `conn.rollback()` và trả về `-1`. Giao diện của B báo lỗi slot vừa bị người khác đặt."*

### Câu 2: Tại sao không thu luôn 18 triệu từ lúc đặt lịch online mà lại chỉ thu 500k?
> **Trả lời:**  
> *"Dạ thưa cô, về mặt tâm lý khách hàng, bắt người bệnh trả 18 - 42 triệu qua mạng khi chưa gặp bác sĩ là rào cản rất lớn. Về mặt y tế, tỷ lệ bệnh nhân không đủ điều kiện phẫu thuật giác mạc chiếm tới 15 - 20%. Nếu thu trước 18 triệu rồi làm thủ tục hoàn tiền qua ngân hàng sẽ mất từ 3 - 7 ngày, gây bức xúc cho bệnh nhân. Do đó, mô hình đặt cọc gói khám tiền phẫu 500.000đ và khấu trừ vào tiền mổ là quy trình chuẩn của các bệnh viện mắt quốc tế hiện nay."*

### Câu 3: Làm sao đảm bảo giao dịch không bị mất dữ liệu nếu mạng bị rớt khi đang quét mã QR?
> **Trả lời:**  
> *"Dạ hệ thống sử dụng cơ chế **Hai lớp đối soát (Dual-check)**:  
> 1. Phía máy chủ nhận Webhook trực tiếp từ PayOS Server qua Servlet `PayOSWebhookServlet` với chữ ký mã hóa HMAC-SHA256.  
> 2. Phía máy khách (Browser) chạy vòng lặp Polling kiểm tra trạng thái đơn hàng mỗi 2.5 giây.  
> Kể cả khi người dùng vô tình tắt trình duyệt, khi họ mở lại mục 'Lịch sử lịch hẹn', hệ thống vẫn tự động kiểm tra với PayOS và cập nhật trạng thái đã thanh toán."*
