# TÀI LIỆU TOÀN DIỆN: HƯỚNG DẪN DEMO & REVIEW MÃ NGUỒN PHÂN HỆ BOOKING
# HỆ THỐNG PHÒNG KHÁM CHUYÊN KHOA MẮT VISIONCARE (SWP PROJECT)

> **Mục đích:** Tài liệu tổng hợp toàn bộ luồng nghiệp vụ, kịch bản thuyết trình, chỉ dẫn mã nguồn chi tiết từ Frontend (JSP/JavaScript) đến Backend (Servlet/DAO) và Cơ sở dữ liệu (SQL Server) phục vụ buổi báo cáo và bảo vệ trước Hội đồng phản biện.

---

## MỤC LỤC
1. [Kịch bản thuyết trình tổng quan (Elevator Pitch 30 giây)](#1-kịch-bản-thuyết-trình-tổng-quan-elevator-pitch-30-giây)
2. [Sơ đồ luồng toàn trình từ Giao diện đến Backend & Database](#2-sơ-đồ-luồng-toàn-trình-từ-giao-diện-đến-backend--database)
3. [Hướng dẫn Demo từng bước: Thao tác giao diện $\leftrightarrow$ Chỉ đúng dòng Code](#3-hướng-dẫn-demo-từng-bước-thao-tác-giao-diện--chỉ-đúng-dòng-code)
   - [Bước 1: Khởi tạo trang đặt lịch & Kiểm tra quyền truy cập](#bước-1-khởi-tạo-trang-đặt-lịch--kiểm-tra-quyền-truy-cập)
   - [Bước 2: Chọn dịch vụ khám & Chọn bác sĩ điều trị (Wizard Step 1)](#bước-2-chọn-dịch-vụ-khám--chọn-bác-sĩ-điều-trị-wizard-step-1)
   - [Bước 3: Chọn ngày & Tải khung giờ khám động qua AJAX (Wizard Step 2)](#bước-3-chọn-ngày--tải-khung-giờ-khám-động-qua-ajax-wizard-step-2)
   - [Bước 4: Điền thông tin & Mở Transaction chống trùng lịch (Wizard Step 3)](#bước-4-điền-thông-tin--mở-transaction-chống-trùng-lịch-wizard-step-3)
   - [Bước 5: Sinh mã VietQR / PayOS thanh toán giữ chỗ 15 phút](#bước-5-sinh-mã-vietqr--payos-thanh-toán-giữ-chỗ-15-phút)
   - [Bước 6: Tự động bắt thanh toán (Polling / Webhook) & Xuất vé khám](#bước-6-tự-động-bắt-thanh-toán-polling--webhook--xuất-vé-khám)
4. [Bóc tách kỹ thuật chuyên sâu 1: Xử lý 2 người cùng bấm 1 slot cùng lúc (Race Condition)](#4-bóc-tách-kỹ-thuật-chuyên-sâu-1-xử-lý-2-người-cùng-bấm-1-slot-cùng-lúc-race-condition)
5. [Bóc tách kỹ thuật chuyên sâu 2: Quy trình thu cọc khám trước & Khấu trừ vào tiền mổ sau](#5-bóc-tách-kỹ-thuật-chuyên-sâu-2-quy-trình-thu-cọc-khám-trước--khấu-trừ-vào-tiền-mổ-sau)
6. [Bộ câu hỏi phản biện của Giảng viên / Hội đồng & Câu trả lời chuẩn mực](#6-bộ-câu-hỏi-phản-biện-của-giảng-viên--hội-đồng--câu-trả-lời-chuẩn-mực)

---

## 1. KỊCH BẢN THUYẾT TRÌNH TỔNG QUAN (ELEVATOR PITCH 30 GIÂY)

> *"Kính thưa thầy/cô và Hội đồng,  
> Phân hệ Đặt lịch khám trực tuyến (Online Booking) của dự án VisionCare được xây dựng theo mô hình MVC hoàn chỉnh trên nền tảng Java Servlet/JSP kết hợp Microsoft SQL Server.  
> Điểm cốt lõi của phân hệ không chỉ dừng lại ở form đặt lịch thông thường, mà giải quyết trọn vẹn 3 bài toán nghiệp vụ y khoa thực tế:  
> 1. **Tải khung giờ động theo ca trực thực tế của bác sĩ qua AJAX (không hardcode).**  
> 2. **Cơ chế khóa Database Transaction chống đặt trùng lịch (Anti Double-Booking) khi có tương tranh (Race Condition).**  
> 3. **Cơ chế thanh toán giữ chỗ thông minh: Chỉ thu phí khám tiền phẫu ban đầu (500.000đ) qua VietQR/PayOS, sau đó tự động khấu trừ 100% vào chi phí phẫu thuật lớn (18 - 42 triệu) sau khi bác sĩ khám lâm sàng.**"*

---

## 2. SƠ ĐỒ LUỒNG TOÀN TRÌNH TỪ GIAO DIỆN ĐẾN BACKEND & DATABASE

```
[CLIENT / BROWSER]           [CONTROLLER (SERVLET)]           [DAO / DATABASE]
        |                              |                              |
1. GET /book-appointment ------------->|                              |
        |                              |-- getSession(user) --------->|
        |                              |-- catalogDAO.listServices()->| Bảng Service_Catalog
        |                              |-- doctorDAO.getAll() ------->| Bảng Employee_Profile
        |<-- Trả về JSP Wizard Step 1 -|                              |
        |                              |                              |
2. Chọn Ngày & Đổi Bác sĩ              |                              |
   Gửi AJAX: ?action=getSlots -------->|                              |
        |                              |-- getDoctorSlotsForDate() -->| Bảng Work_Schedule +
        |<-- Trả về JSON slots --------|                              | Kiểm tra trùng slot
        |                              |                              |
3. Submit Form (POST) ---------------->|                              |
   patientName, phone, slot...         |-- Validate dữ liệu (Regex)   |
        |                              |-- conn.setAutoCommit(false)->| MỞ TRANSACTION
        |                              |   Kiểm tra ActiveAppts       |
        |                              |   INSERT Appointment (Pending)
        |                              |   INSERT Master_Invoice (Cọc)|
        |                              |<-- conn.commit() ------------| ĐÓNG TRANSACTION
        |<-- Render Màn hình VietQR ---|                              |
        |                              |                              |
4. Quét mã QR chuyển khoản             |                              |
   Polling: ?action=checkPayment ----->|-- PayOS Webhook / Check ---->| UPDATE Status='Confirmed'
        |                              |-- EmailUtil.sendMail() ----->| Gửi Email vé khám
        |<-- Tự động nhảy sang trang --|                              |
        |    "Thành công / Vé khám"    |                              |
```

---

## 3. HƯỚNG DẪN DEMO TỪNG BƯỚC: THAO TÁC GIAO DIỆN $\leftrightarrow$ CHỈ ĐÚNG DÒNG CODE

### Bước 1: Khởi tạo trang đặt lịch & Kiểm tra quyền truy cập

#### 🖥️ Thao tác trên giao diện:
- Nhấp vào nút **"Đặt lịch khám"** trên Menu Navbar (`/book-appointment`).
- Nếu chưa đăng nhập: Trình duyệt chuyển hướng về trang `/login` kèm thông báo *"Vui lòng đăng nhập để thực hiện đặt lịch khám mắt"*.
- Đăng nhập tài khoản Bệnh nhân $\rightarrow$ Hệ thống tự động chuyển lại trang `/book-appointment` với thông tin đã được điền sẵn.

#### 💻 Chỉ Code Backend:
* **File:** `src/java/com/visioncare/controller/BookAppointmentServlet.java` (Dòng 176 – 190):
```java
// Bắt buộc bệnh nhân phải đăng nhập để đặt lịch khám
HttpSession session = request.getSession(false);
User user = (session != null) ? (User) session.getAttribute("user") : null;
if (user == null) {
    String query = request.getQueryString();
    String redirectUrl = request.getContextPath() + "/book-appointment" + (query != null ? "?" + query : "");
    session = request.getSession(true);
    session.setAttribute("redirectAfterLogin", redirectUrl);
    session.setAttribute("infoMsg", "Vui lòng đăng nhập để thực hiện đặt lịch khám mắt.");
    response.sendRedirect(request.getContextPath() + "/login");
    return;
}
```

* **File:** `src/java/com/visioncare/controller/BookAppointmentServlet.java` (Dòng 580 – 607):
```java
private void prepareFormData(HttpServletRequest request) throws Exception {
    // 1. Tải danh mục dịch vụ khám & tư vấn từ bảng Service_Catalog (lọc <= 1 triệu)
    List<CatalogService> allServices = catalogDAO.listServices();
    List<CatalogService> bookingServices = new java.util.ArrayList<>();
    if (allServices != null) {
        for (CatalogService cs : allServices) {
            if ("Khám và tư vấn".equalsIgnoreCase(cs.getCategory())
                    || "Kiểm tra và chẩn đoán".equalsIgnoreCase(cs.getCategory())
                    || (cs.getPrice() != null && cs.getPrice().longValue() <= 1000000)) {
                bookingServices.add(cs);
            }
        }
    }
    request.setAttribute("services", bookingServices);

    // 2. Tải danh sách bác sĩ đang hoạt động
    List<Doctor> doctors = doctorDAO.getAll();
    request.setAttribute("doctors", doctors);

    // 3. Tự động lấy thông tin người dùng đang đăng nhập
    HttpSession session = request.getSession(false);
    if (session != null && session.getAttribute("user") != null) {
        User loggedUser = (User) session.getAttribute("user");
        request.setAttribute("loggedUser", loggedUser);
    }
}
```

---

### Bước 2: Chọn dịch vụ khám & Chọn bác sĩ điều trị (Wizard Step 1)

#### 🖥️ Thao tác trên giao diện:
1. Bấm vào các tab phân loại: *Khám & Khúc xạ*, *Tiền phẫu & Tầm soát*, *Mắt trẻ em*.
2. Chọn gói: **Khám tiền phẫu & Tư vấn xóa cận LASIK/SMILE (500.000 ₫)**.
3. Quan sát dropdown Bác sĩ tự động lọc ra các bác sĩ đúng chuyên khoa Giác mạc / Khúc xạ.
4. Chọn một bác sĩ (VD: *BS.CKII Nguyễn Văn Nam*).
5. Thẻ **Doctor Preview Card** xuất hiện bên dưới hiển thị ảnh chân dung, chuyên khoa và số phòng khám.
6. Bấm nút **"Tiếp tục: Chọn ngày & giờ khám"**.

#### 💻 Chỉ Code Giao diện & JavaScript:
* **File:** `web/views/appointment/book-appointment.jsp` (Render danh sách dịch vụ):
```jsp
<input type="radio" class="d-none service-radio"
  name="serviceId" value="${svc.id}"
  data-specialty="${svc.specialty}"
  data-name="${svc.name}" data-price="${svc.price}"
  onchange="filterDoctorsByService(this)">
```

* **File:** `web/views/appointment/book-appointment.jsp` (Dropdown chọn bác sĩ):
```jsp
<select class="form-select form-select-lg rounded-3" id="doctorSelect" name="doctorId" required onchange="onDoctorSelectChange()">
  <option value="">— Vui lòng chọn bác sĩ nhãn khoa —</option>
  <c:forEach var="doc" items="${doctors}">
    <option value="${doc.id}" data-dept="${doc.departmentKey}" data-specialty="${doc.specialty}"
            data-name="${doc.fullName}" data-room="${doc.roomName}" data-avatar="...">
      ${doc.fullName} — Chuyên khoa: ${doc.specialty} (${doc.roomName})
    </option>
  </c:forEach>
</select>
```

---

### Bước 3: Chọn ngày & Tải khung giờ khám động qua AJAX (Wizard Step 2)

#### 🖥️ Thao tác trên giao diện:
1. Chọn một ngày khám trong tương lai trên lịch hẹn.
2. Trình duyệt gửi AJAX ngầm, hiển thị các nút giờ theo 2 ca:
   - **Ca Sáng (08:00 — 11:30)**
   - **Ca Chiều (13:30 — 16:30)**
3. Những slot đã có người đặt trước sẽ bị **làm mờ và gạch ngang (disabled)**.
4. Chọn một slot còn trống (nút chuyển sang màu xanh ngọc).
5. Bấm nút **"Tiếp tục: Điền thông tin người khám"**.

#### 💻 Chỉ Code AJAX & Backend Query:
* **File:** `src/java/com/visioncare/controller/BookAppointmentServlet.java` (Dòng 137 – 168):
```java
// AJAX: Lấy khung giờ động theo Bác sĩ & Ngày
if ("getSlots".equalsIgnoreCase(action)) {
    response.setContentType("application/json;charset=UTF-8");
    String docIdStr = request.getParameter("doctorId");
    String dateStr = request.getParameter("date");
    int doctorId = Integer.parseInt(docIdStr);

    List<TimeSlot> slots = workScheduleDAO.getDoctorSlotsForDate(doctorId, dateStr);
    
    // Đóng gói JSON trả về client
    StringBuilder json = new StringBuilder();
    json.append("{\"slots\":[");
    for (int i = 0; i < slots.size(); i++) {
        TimeSlot s = slots.get(i);
        if (i > 0) json.append(",");
        json.append("{")
            .append("\"id\":").append(s.getId()).append(",")
            .append("\"startTime\":\"").append(s.getStartTime()).append("\",")
            .append("\"session\":\"").append(s.getSession()).append("\",")
            .append("\"isBooked\":").append(s.isBooked()) // true nếu đã bận
            .append("}");
    }
    json.append("]}");
    response.getWriter().write(json.toString());
    return;
}
```

* **File:** `src/java/com/visioncare/dao/WorkScheduleDAO.java` (SQL kiểm tra slot đã bận, dòng 238 – 253):
```sql
SELECT ws.Schedule_ID, ws.Doctor_Employee_ID, ws.Work_Date, ws.Slot,
       CONVERT(VARCHAR(5), ws.Start_Time, 108) AS Start_Time_Str,
       CASE 
         WHEN ws.Status = 'Booked' THEN 1 
         WHEN EXISTS (SELECT 1 FROM Appointment ap WHERE ap.Schedule_ID = ws.Schedule_ID 
                      AND (ap.Status IN ('Confirmed', 'In_Progress', 'Completed') 
                           OR (ap.Status = 'Pending' AND DATEDIFF(MINUTE, ap.created_at, SYSUTCDATETIME()) < 15))) THEN 1 
         ELSE 0 
       END AS Is_Booked 
FROM Work_Schedule ws 
WHERE ws.Doctor_Employee_ID = ? AND ws.Work_Date = ? 
  AND CAST(ws.Start_Time AS TIME) < '17:30:00' 
  AND ws.Status NOT IN ('Canceled', 'On_Leave', 'Inactive', 'Closed')
ORDER BY ws.Start_Time ASC;
```

---

### Bước 4: Điền thông tin & Mở Transaction chống trùng lịch (Wizard Step 3)

#### 🖥️ Thao tác trên giao diện:
1. Rà soát Thẻ tóm tắt lịch hẹn đã chọn.
2. Kiểm tra các ô Họ tên, Số điện thoại, Email đã được tự động điền sẵn.
3. Nhập triệu chứng vào ô Lý do khám: *"Mắt phải nhìn mờ, khô rát khi dùng máy tính"*.
4. Chỉ vào số tiền giữ chỗ: **500.000 ₫**.
5. Bấm nút: **"Xác nhận lịch hẹn (Verify Appointment)"**.

#### 💻 Chỉ Code Controller & Database Transaction:
* **File:** `src/java/com/visioncare/controller/BookAppointmentServlet.java` (Validate & Gọi DAO, dòng 457 – 528):
```java
// 1. Server-side validation bằng Regular Expression
if (appointment.getPhone() == null || !appointment.getPhone().matches("^0[3|5|7|8|9][0-9]{8}$")) {
    request.setAttribute("error", "Số điện thoại không hợp lệ (yêu cầu 10 chữ số).");
    repopulateAndForward(request, response, appointment);
    return;
}

// 2. Định nghĩa phí khám giữ chỗ 100%
long fee = totalServicePrice > 0 ? totalServicePrice : 200000;
appointment.setFee(fee);
appointment.setBalanceDue(0);

// 3. Thực thi Transaction trong DAO
int newId = appointmentDAO.createPendingAppointment(appointment, serviceId, fee);

// 4. Báo lỗi nếu trùng lịch hoặc thất bại
if (newId <= 0) {
    request.setAttribute("error", "Khung giờ này không còn trống hoặc hệ thống đang bận. Vui lòng thử lại.");
    repopulateAndForward(request, response, appointment);
    return;
}
```

* **File:** `src/java/com/visioncare/dao/AppointmentDAO.java` (Transaction ACID, dòng 10 – 89):
```java
public int createPendingAppointment(Appointment a, int serviceId, long fee) throws Exception {
    Connection conn = null;
    try {
        conn = DBContext.getConnection();
        // 1. MỞ TRANSACTION
        conn.setAutoCommit(false);

        int patientId = getOrCreatePatient(conn, a);
        int scheduleId = a.getScheduleId();

        // 2. KIỂM TRA XUNG ĐỘT TỨC THÌ (RACE CONDITION CHECK)
        String checkSlotSql = "SELECT ws.Status, " +
                              "(SELECT COUNT(*) FROM Appointment ap WHERE ap.Schedule_ID = ws.Schedule_ID " +
                              " AND (ap.Status IN ('Confirmed', 'In_Progress', 'Completed') " +
                              "      OR (ap.Status = 'Pending' AND DATEDIFF(MINUTE, ap.created_at, SYSUTCDATETIME()) < 15))) AS ActiveAppts " +
                              "FROM Work_Schedule ws WHERE ws.Schedule_ID = ?";
        try (PreparedStatement psCheck = conn.prepareStatement(checkSlotSql)) {
            psCheck.setInt(1, scheduleId);
            try (ResultSet rsCheck = psCheck.executeQuery()) {
                if (rsCheck.next()) {
                    int count = rsCheck.getInt("ActiveAppts");
                    if (count > 0) {
                        conn.rollback(); // ĐÃ BỊ ĐẶT -> HỦY TRANSACTION
                        return -1;
                    }
                }
            }
        }

        // 3. INSERT APPOINTMENT (TRẠNG THÁI PENDING)
        String sqlAppt = "INSERT INTO Appointment (Patient_ID, Schedule_ID, Status, created_at) VALUES (?, ?, 'Pending', SYSUTCDATETIME())";
        // ... lấy mã sinh tự động appointmentId ...

        // 4. INSERT MASTER_INVOICE (LƯU TIỀN CỌC GIỮ CHỖ)
        String sqlInvoice = "INSERT INTO Master_Invoice (Appointment_ID, Total_Amount, Deposit_Amount, Balance_Due, Status, Create_At) " +
                            "VALUES (?, ?, ?, ?, 'Pending_Deposit', SYSUTCDATETIME())";
        // ... gán Deposit_Amount = fee ...

        // 5. INSERT MEDICAL_RECORD (LƯU LÝ DO KHÁM SƠ BỘ)
        String sqlRecord = "INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis, Created_At) VALUES (?, ?, ?, SYSUTCDATETIME())";
        // ... gán Clinical_Diagnosis = a.getReason() ...

        // TẤT CẢ THÀNH CÔNG -> COMMIT
        conn.commit();
        return appointmentId;
    } catch (Exception e) {
        if (conn != null) conn.rollback();
        throw e;
    }
}
```

---

### Bước 5: Sinh mã VietQR / PayOS thanh toán giữ chỗ 15 phút

#### 🖥️ Thao tác trên giao diện:
- Màn hình chuyển sang trang **Thanh toán VietQR**.
- Mã QR hiện lên kèm số tiền đúng **500.000 ₫**, số tài khoản MB Bank, nội dung chuyển khoản tự động `VC101 0912345678`.
- Đồng hồ đếm ngược 15 phút.

#### 💻 Chỉ Code Backend:
* **File:** `src/java/com/visioncare/controller/BookAppointmentServlet.java` (Dòng 530 – 550):
```java
// Sinh mã VietQR theo chuẩn NAPAS 247
String phoneSafe = appointment.getPhone() != null ? appointment.getPhone() : "";
String paymentDesc = "VC" + newId + " " + phoneSafe;
String encodedDesc = URLEncoder.encode(paymentDesc, StandardCharsets.UTF_8);
String qrUrl = "https://img.vietqr.io/image/MB-0877757889-compact2.png?amount=" + fee + "&addInfo=" + encodedDesc + "&accountName=NGUYEN%20DINH%20TRUNG";

// Tích hợp cổng PayOS SDK
com.visioncare.util.PayOSUtil.PaymentLinkResult payosRes = com.visioncare.util.PayOSUtil.createPaymentLink(newId, (int) fee, payosDesc, cancelUrl, returnUrl);
```

---

### Bước 6: Tự động bắt thanh toán (Polling / Webhook) & Xuất vé khám

#### 🖥️ Thao tác trên giao diện:
- Giả lập chuyển khoản thành công / Webhook kích hoạt.
- Trình duyệt tự động chuyển ngay sang màn hình **"Đặt Lịch & Thanh Toán Thành Công!"**.
- Màn hình hiển thị: **Mã phiếu hẹn (#VC101)**, Bác sĩ, Ngày giờ, Đã thanh toán 500.000đ, thông báo email xác nhận đã được gửi.

#### 💻 Chỉ Code Polling & Webhook:
* **File:** `web/views/appointment/book-appointment.jsp` (Frontend Polling):
```javascript
const pollInterval = setInterval(() => {
    fetch(`${contextPath}/book-appointment?action=checkPayment&appointmentId=${appointmentId}`)
        .then(res => res.json())
        .then(data => {
            if (data.isPaid) {
                clearInterval(pollInterval);
                // Tự động chuyển trang thành công
                window.location.href = `${contextPath}/book-appointment?step=success&id=${appointmentId}`;
            }
        });
}, 2500);
```

* **File:** `src/java/com/visioncare/controller/BookAppointmentServlet.java` (Check Payment Endpoint, dòng 40 – 60):
```java
if ("checkPayment".equalsIgnoreCase(action)) {
    int apptId = Integer.parseInt(request.getParameter("appointmentId"));
    Appointment appt = appointmentDAO.getAppointmentDetailById(apptId);
    boolean isPaid = (appt != null && "Confirmed".equalsIgnoreCase(appt.getStatus()));
    
    // Nếu PayOS xác nhận đã nhận tiền -> cập nhật DB
    if (!isPaid && "PAID".equalsIgnoreCase(PayOSUtil.getPaymentStatus(apptId))) {
        appointmentDAO.confirmPayment(apptId); // Cập nhật Status sang Confirmed & Hóa đơn sang Paid
        isPaid = true;
    }
    response.getWriter().write("{\"isPaid\":" + isPaid + "}");
    return;
}
```

---

## 4. BÓC TÁCH KỸ THUẬT CHUYÊN SÂU 1: XỬ LÝ 2 NGƯỜI CÙNG BẤM 1 SLOT CÙNG LÚC (RACE CONDITION)

Khi 2 người dùng (A và B) cùng mở form lúc 09:00:00 và cùng bấm "Xác nhận & Thanh toán":

```
[Bệnh nhân A] --------> Thread A --------> Transaction A --------> COMMIT (ActiveAppts=0 -> Thành công)
                                                                         |
                                                                         v Ghi nhận ActiveAppts = 1
[Bệnh nhân B] (trễ 5ms)> Thread B --------> Transaction B --------> ROLLBACK (ActiveAppts=1 -> Trả về -1)
```

1. **Người A (Request đến trước 5ms):**
   * Mở Transaction: `conn.setAutoCommit(false)`.
   * Chạy câu query kiểm tra: `ActiveAppts = 0`. Thỏa mãn!
   * Chạy lệnh `INSERT INTO Appointment` với trạng thái `'Pending'`.
   * Gọi `conn.commit()`. Bản ghi của A tồn tại trong DB.
2. **Người B (Request đến sau 5ms):**
   * Mở Transaction riêng của B.
   * Chạy câu query kiểm tra: Tìm thấy bản ghi của A vừa tạo có `Status = 'Pending'` và `DATEDIFF(MINUTE, created_at, NOW) = 0` (< 15 phút).
   * Kết quả: `ActiveAppts = 1`.
   * Nhánh `if (count > 0)` của B được kích hoạt $\rightarrow$ Thực hiện `conn.rollback()` và trả về `-1`.
   * Giao diện của B hiển thị thông báo: *"Khung giờ này không còn trống hoặc hệ thống đang bận. Vui lòng thử lại."*
3. **Cơ chế Time-to-Live (15 phút tự giải phóng):**
   * Nếu A không thanh toán trong 15 phút, `DATEDIFF >= 15`. Lần kiểm tra tiếp theo của người khác sẽ coi slot này là hợp lệ (`ActiveAppts = 0`) và slot tự động được giải phóng mà không cần can thiệp thủ công.

---

## 5. BÓC TÁCH KỸ THUẬT CHUYÊN SÂU 2: QUY TRÌNH THU CỌC KHÁM TRƯỚC & KHẤU TRỪ VÀO TIỀN MỔ SAU

### Câu hỏi: *"Sao lúc đầu gói mổ 18 triệu, mà chỉ bắt cọc 500k, sau đó làm sao code trừ được tiền?"*

#### 1. Tại Database: Bảng `Master_Invoice` được thiết kế chuẩn tài chính y tế:
- `Total_Amount`: Tổng giá trị đợt điều trị.
- `Deposit_Amount`: Số tiền cọc đã đóng trước khi đến khám.
- `Balance_Due`: Số tiền còn nợ phải thu thêm tại quầy thu ngân.

#### 2. Phân nhánh sau khi khám:
* **Nhánh 1: Không đủ điều kiện mổ (Giác mạc mỏng, viêm nhiễm):**
  - Bác sĩ chỉ kết luận vào bệnh án `Medical_Record`.
  - Không tạo lệnh phẫu thuật.
  - Bệnh nhân ra về, chỉ mất đúng **500.000 ₫** tiền khám chuyên sâu ban đầu.
* **Nhánh 2: Đủ điều kiện mổ & Đồng ý mổ:**
  - Bác sĩ tạo lệnh phẫu thuật `PT-LASIK` (18.000.000 ₫) vào bảng `Procedure_Order`.
  - Bác sĩ kê đơn thuốc nhỏ mắt sau mổ (200.000 ₫) vào bảng `Prescription_Detail`.

#### 3. Thuật toán khấu trừ tiền trong `InvoiceDAO.java` (Dòng 454 – 472):
```java
// 1. Lấy lại số tiền cọc 500k bệnh nhân đã đóng khi đặt online
long depositAmount = (long) invoice.get("depositAmount"); // 500.000đ

// 2. Tổng chi phí phát sinh thực tế:
long computedTotal = depositAmount + totalProcedureCost + totalMedCost;
// = 500.000đ (tiền khám) + 18.000.000đ (tiền mổ) + 200.000đ (thuốc) = 18.700.000đ

// 3. CÔNG THỨC KHẤU TRỪ TIỀN (BALANCE DUE):
long balanceDue = Math.max(0, computedTotal - depositAmount);
// = 18.700.000đ - 500.000đ (TRỪ 100% TIỀN CỌC BAN ĐẦU)
// ===> balanceDue = 18.200.000đ
```
👉 Bệnh nhân chỉ cần quẹt thẻ đóng nốt **18.200.000 ₫** tại quầy thu ngân trước khi vào phòng phẫu thuật.

---

## 6. BỘ CÂU HỎI PHẢN BIỆN CỦA GIẢNG VIÊN / HỘI ĐỒNG & CÂU TRẢ LỜI CHUẨN MỰC

### Câu 1: Tại sao nhóm không thu luôn 18 triệu từ lúc đặt lịch online?
> **Trả lời:**  
> *"Dạ thưa thầy/cô, về mặt tâm lý khách hàng, bắt người bệnh trả 18 - 42 triệu qua mạng khi chưa gặp bác sĩ là rào cản rất lớn. Về mặt y tế, tỷ lệ bệnh nhân không đủ điều kiện phẫu thuật giác mạc chiếm tới 15 - 20%. Nếu thu trước 18 triệu rồi làm thủ tục hoàn tiền qua ngân hàng sẽ mất từ 3 - 7 ngày, gây bức xúc cho bệnh nhân. Do đó, mô hình đặt cọc gói khám tiền phẫu 500.000đ và khấu trừ vào tiền mổ là quy trình chuẩn của các bệnh viện mắt quốc tế hiện nay."*

### Câu 2: Đây là System Test hay Integration Test?
> **Trả lời:**  
> *"Dạ bộ test case trong file Excel tracking của nhóm em là **System Test (Kiểm thử hệ thống)**, vì nó kiểm thử từ giao diện người dùng (UI) đi xuyên suốt toàn bộ hệ thống từ Client $\rightarrow$ Servlet $\rightarrow$ Database $\rightarrow$ PayOS/Email theo các kịch bản người dùng (User Scenarios). Tuy nhiên, bên dưới code có tích hợp các cơ chế kiểm thử tích hợp (Integration) giữa Servlet, DAO và Database Transaction."*

### Câu 3: Làm sao đảm bảo giao dịch không bị mất dữ liệu nếu mạng bị rớt khi đang quét mã QR?
> **Trả lời:**  
> *"Dạ hệ thống sử dụng cơ chế **Hai lớp đối soát (Dual-check)**:  
> 1. Phía máy chủ nhận Webhook trực tiếp từ PayOS Server qua Servlet `PayOSWebhookServlet` với chữ ký mã hóa HMAC-SHA256.  
> 2. Phía máy khách (Browser) chạy vòng lặp Polling kiểm tra trạng thái đơn hàng mỗi 2.5 giây.  
> Kể cả khi người dùng vô tình tắt trình duyệt, khi họ mở lại mục 'Lịch sử lịch hẹn', hệ thống vẫn tự động kiểm tra với PayOS và cập nhật trạng thái đã thanh toán."*

---

> [!TIP]
> **Lời khuyên khi vào phòng vấn đáp:**
> 1. Mở sẵn Visual Studio Code tại 3 file: `BookAppointmentServlet.java`, `AppointmentDAO.java`, `InvoiceDAO.java`.
> 2. Mở sẵn 1 tab trình duyệt đã đăng nhập tài khoản bệnh nhân tại trang `/book-appointment`.
> 3. Tự tin trả lời mạch lạc theo đúng các đề mục trên, bạn chắc chắn sẽ đạt điểm xuất sắc cho phân hệ này!
