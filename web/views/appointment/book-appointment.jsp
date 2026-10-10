<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%-- Include Header --%>
<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Đặt lịch khám mắt trực tuyến" />
  <jsp:param name="pageDescription" value="Hệ thống đặt lịch khám chuyên khoa mắt và thanh toán trực tuyến — VisionCare" />
  <jsp:param name="bodyClass" value="booking-page" />
  <jsp:param name="activeNav" value="booking" />
</jsp:include>

<style>
  :root {
    --primary-color: #0d9488;
    --primary-hover: #0f766e;
    --primary-light: #f0fdfa;
    --primary-border: #99f6e4;
  }
  .booking-card {
    background: #ffffff;
    border-radius: 20px;
    box-shadow: 0 10px 40px rgba(15, 23, 42, 0.08);
    border: 1px solid #e2e8f0;
    overflow: hidden;
  }
  .booking-header {
    background: linear-gradient(135deg, #0f766e 0%, #0d9488 50%, #14b8a6 100%);
    color: #ffffff;
    padding: 35px 30px;
    text-align: center;
  }
  .wizard-progress {
    display: flex;
    justify-content: space-between;
    position: relative;
    max-width: 650px;
    margin: 0 auto;
    padding: 0 15px;
  }
  .wizard-progress::before {
    content: "";
    position: absolute;
    top: 22px;
    left: 40px;
    right: 40px;
    height: 3px;
    background: #e2e8f0;
    z-index: 1;
  }
  .progress-step {
    position: relative;
    z-index: 2;
    text-align: center;
    cursor: pointer;
  }
  .step-dot {
    width: 44px;
    height: 44px;
    border-radius: 50%;
    background: #ffffff;
    border: 3px solid #cbd5e1;
    color: #64748b;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 700;
    font-size: 15px;
    margin: 0 auto 8px;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  }
  .progress-step.active .step-dot {
    background: var(--primary-color);
    border-color: var(--primary-color);
    color: #ffffff;
    box-shadow: 0 0 0 5px rgba(13, 148, 136, 0.2);
    transform: scale(1.05);
  }
  .progress-step.completed .step-dot {
    background: #10b981;
    border-color: #10b981;
    color: #ffffff;
  }
  .step-label {
    font-size: 13px;
    font-weight: 600;
    color: #64748b;
    transition: color 0.3s;
  }
  .progress-step.active .step-label {
    color: var(--primary-color);
  }
  .progress-step.completed .step-label {
    color: #10b981;
  }
  .slot-btn {
    border: 1.5px solid #cbd5e1;
    background: #ffffff;
    color: #1e293b;
    border-radius: 10px;
    padding: 10px 16px;
    font-weight: 600;
    font-size: 14px;
    transition: all 0.2s;
    cursor: pointer;
  }
  .slot-btn:hover:not(:disabled) {
    border-color: var(--primary-color);
    background: var(--primary-light);
    color: var(--primary-color);
  }
  .btn-check:checked + .slot-btn {
    background: var(--primary-color) !important;
    border-color: var(--primary-color) !important;
    color: #ffffff !important;
    box-shadow: 0 4px 12px rgba(13, 148, 136, 0.3);
  }
  .slot-btn:disabled {
    background: #f1f5f9;
    border-color: #e2e8f0;
    color: #94a3b8;
    cursor: not-allowed;
    text-decoration: line-through;
  }
  .service-card {
    border: 2px solid #e2e8f0;
    border-radius: 12px;
    padding: 14px 16px;
    cursor: pointer;
    transition: all 0.25s;
    height: 100%;
    background: #ffffff;
  }
  .service-card:hover {
    border-color: #99f6e4;
    background: #f8fafc;
  }
  .service-radio:checked + .service-card {
    border-color: var(--primary-color);
    background: var(--primary-light);
    box-shadow: 0 4px 12px rgba(13, 148, 136, 0.15);
  }
  .qr-box {
    background: #ffffff;
    border-radius: 16px;
    padding: 24px;
    border: 2px dashed #0d9488;
    text-align: center;
    box-shadow: 0 4px 20px rgba(13, 148, 136, 0.08);
  }
  .ticket-card {
    background: #f8fafc;
    border: 1px solid #e2e8f0;
    border-radius: 14px;
    padding: 24px;
    position: relative;
  }
  .ticket-card::before {
    content: "";
    position: absolute;
    top: 0;
    left: 0;
    bottom: 0;
    width: 6px;
    background: #0d9488;
    border-radius: 14px 0 0 14px;
  }
  .badge-session {
    font-size: 12px;
    font-weight: 600;
    padding: 4px 10px;
    border-radius: 20px;
  }
  .badge-morning {
    background: #fef3c7;
    color: #b45309;
  }
  .badge-afternoon {
    background: #e0f2fe;
    color: #0369a1;
  }
</style>

<main class="main bg-light py-5">
  <div class="container">

    <div class="row justify-content-center">
      <div class="col-lg-10 col-xl-9">

        <%-- THÔNG BÁO LỖI (NẾU CÓ) --%>
        <c:if test="${not empty error}">
          <div class="alert alert-danger alert-dismissible fade show rounded-4 shadow-sm mb-4" role="alert">
            <div class="d-flex align-items-center">
              <i class="bi bi-exclamation-triangle-fill fs-4 me-3 text-danger"></i>
              <div>
                <strong class="d-block">Xác nhận không thành công</strong>
                <span>${error}</span>
              </div>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
          </div>
        </c:if>

        <div class="booking-card mb-5">

          <%-- HEADER TIÊU ĐỀ & TIẾN TRÌNH --%>
          <div class="booking-header">
            <h2 class="fw-bold mb-2">ĐẶT LỊCH KHÁM MẮT ONLINE</h2>
            <p class="mb-4 opacity-90">Hệ thống tiếp nhận bệnh nhân &amp; xác nhận ca khám tự động trực tuyến</p>

            <div class="wizard-progress">
              <div class="progress-step ${step == null || step == 'form' ? 'active' : 'completed'}" id="p-step-1">
                <div class="step-dot"><i class="bi bi-person-check"></i></div>
                <div class="step-label text-white">1. Chọn lịch khám</div>
              </div>
              <div class="progress-step ${step == 'payment' ? 'active' : (step == 'success' ? 'completed' : '')}" id="p-step-2">
                <div class="step-dot"><i class="bi bi-qr-code-scan"></i></div>
                <div class="step-label text-white">2. Thanh toán QR</div>
              </div>
              <div class="progress-step ${step == 'success' ? 'active' : ''}" id="p-step-3">
                <div class="step-dot"><i class="bi bi-check2-circle"></i></div>
                <div class="step-label text-white">3. Hoàn tất</div>
              </div>
            </div>
          </div>

          <div class="p-4 p-md-5">

            <%-- ======================================================== --%>
            <%-- MÀN HÌNH 3: XÁC NHẬN THÀNH CÔNG (SUCCESS SCREEN)        --%>
            <%-- ======================================================== --%>
            <c:if test="${step == 'success'}">
              <div class="text-center py-4">
                <div class="d-inline-flex p-3 rounded-circle bg-success bg-opacity-10 text-success mb-3">
                  <i class="bi bi-check-circle-fill" style="font-size: 64px;"></i>
                </div>
                <h2 class="fw-bold text-success mb-2">Đặt Lịch &amp; Thanh Toán Thành Công!</h2>
                <p class="text-muted fs-6 mb-4">
                  Hệ thống VisionCare đã ghi nhận vé khám và cập nhật trạng thái đã thanh toán.
                </p>

                <div class="ticket-card text-start mx-auto mb-4" style="max-width: 620px;">
                  <div class="d-flex justify-content-between align-items-center border-bottom pb-3 mb-3">
                    <div>
                      <span class="text-muted small text-uppercase fw-bold">Mã Phiếu Hẹn</span>
                      <h4 class="fw-bold text-teal mb-0" style="color: #0d9488;">#VC${appointment.id}</h4>
                    </div>
                    <span class="badge bg-success px-3 py-2 fs-6 rounded-pill">
                      <i class="bi bi-shield-check me-1"></i>ĐÃ XÁC NHẬN &amp; THANH TOÁN
                    </span>
                  </div>

                  <div class="row g-3">
                    <div class="col-sm-6">
                      <span class="text-muted small d-block">Họ và tên bệnh nhân:</span>
                      <strong class="fs-6 text-dark">${appointment.patientName}</strong>
                    </div>
                    <div class="col-sm-6">
                      <span class="text-muted small d-block">Số điện thoại:</span>
                      <strong class="fs-6 text-dark">${appointment.phone}</strong>
                    </div>
                    <div class="col-sm-6">
                      <span class="text-muted small d-block">Bác sĩ phụ trách:</span>
                      <strong class="fs-6 text-primary">${appointment.doctorName}</strong>
                    </div>
                    <div class="col-sm-6">
                      <span class="text-muted small d-block">Chuyên khoa:</span>
                      <strong class="fs-6 text-dark">${appointment.department}</strong>
                    </div>
                    <div class="col-sm-6">
                      <span class="text-muted small d-block">Ngày khám hẹn:</span>
                      <strong class="fs-6 text-danger">${appointment.appointmentDate}</strong>
                    </div>
                    <div class="col-sm-6">
                      <span class="text-muted small d-block">Khung giờ tiếp đón:</span>
                      <strong class="fs-6 text-danger">${appointment.timeSlot}</strong>
                    </div>
                    <div class="col-12 border-top pt-2 mt-2">
                      <div class="d-flex justify-content-between">
                        <span class="text-muted">Phí khám ban đầu đã trả:</span>
                        <strong class="text-success fs-5">
                          <fmt:formatNumber value="${appointment.fee}" type="number" groupingUsed="true"/> ₫
                        </strong>
                      </div>
                    </div>
                  </div>
                </div>

                <div class="alert alert-info d-inline-block text-start rounded-3 p-3 mb-4" style="max-width: 620px;">
                  <i class="bi bi-envelope-check-fill me-2 fs-5 text-primary"></i>
                  <span>Email xác nhận và phiếu hướng dẫn chuẩn bị khám đã được tự động gửi tới: <b>${appointment.email}</b>. Vui lòng kiểm tra hộp thư của bạn!</span>
                </div>

                <div class="d-flex justify-content-center gap-3">
                  <a href="${pageContext.request.contextPath}/home" class="btn btn-outline-secondary px-4 py-2 rounded-pill">
                    <i class="bi bi-house me-2"></i>Về trang chủ
                  </a>
                  <a href="${pageContext.request.contextPath}/profile" class="btn btn-primary px-4 py-2 rounded-pill" style="background: #0d9488; border-color: #0d9488;">
                    <i class="bi bi-calendar-check me-2"></i>Xem lịch hẹn của tôi
                  </a>
                </div>
              </div>
            </c:if>

            <%-- ======================================================== --%>
            <%-- MÀN HÌNH 2: XÁC THỰC THANH TOÁN QR (PAYMENT SCREEN)     --%>
            <%-- ======================================================== --%>
            <c:if test="${step == 'payment'}">
              <div class="row align-items-center g-4">
                <div class="col-md-5 text-center">
                  <div class="qr-box">
                    <h5 class="fw-bold text-dark mb-1">Quét mã VietQR</h5>
                    <p class="text-muted small mb-3">Mở ứng dụng Ngân hàng hoặc Ví điện tử để quét</p>

                    <div class="position-relative d-inline-block">
                      <img src="${qrUrl}" alt="VietQR VisionCare" class="img-fluid rounded-3 border" style="max-width: 260px; min-height: 260px;">
                    </div>

                    <div class="mt-3">
                      <span class="badge bg-warning text-dark px-3 py-2 rounded-pill">
                        <i class="bi bi-clock me-1"></i>Hạn thanh toán: 15 phút
                      </span>
                    </div>
                  </div>
                </div>

                <div class="col-md-7">
                  <div class="ticket-card mb-4">
                    <h5 class="fw-bold text-dark border-bottom pb-2 mb-3">Chi tiết phiếu đặt lịch khám</h5>
                    <div class="row g-2 small">
                      <div class="col-6 text-muted">Mã lịch hẹn:</div>
                      <div class="col-6 fw-bold text-dark text-end">#VC${appointment.id}</div>

                      <div class="col-6 text-muted">Bệnh nhân:</div>
                      <div class="col-6 fw-bold text-dark text-end">${appointment.patientName}</div>

                      <div class="col-6 text-muted">Bác sĩ khám:</div>
                      <div class="col-6 fw-bold text-primary text-end">${appointment.doctorName}</div>

                      <div class="col-6 text-muted">Thời gian hẹn:</div>
                      <div class="col-6 fw-bold text-danger text-end">${appointment.timeSlot} — ${appointment.appointmentDate}</div>

                      <div class="col-12 border-top my-2"></div>

                      <div class="col-6 text-muted">Ngân hàng:</div>
                      <div class="col-6 fw-bold text-dark text-end">${bankName}</div>

                      <div class="col-6 text-muted">Số tài khoản:</div>
                      <div class="col-6 fw-bold text-dark text-end">${accountNumber}</div>

                      <div class="col-6 text-muted">Chủ tài khoản:</div>
                      <div class="col-6 fw-bold text-dark text-end">${accountHolder}</div>

                      <div class="col-6 text-muted">Nội dung chuyển khoản:</div>
                      <div class="col-6 fw-bold text-danger text-end">
                        <code class="p-1 rounded bg-light border">${paymentDesc}</code>
                      </div>

                      <div class="col-6 fs-6 text-dark fw-bold mt-2">Tổng phí khám ban đầu:</div>
                      <div class="col-6 fs-5 fw-bold text-success text-end mt-2">
                        <fmt:formatNumber value="${fee}" type="number" groupingUsed="true"/> ₫
                      </div>
                    </div>
                  </div>

                  <form method="post" action="${pageContext.request.contextPath}/book-appointment">
                    <input type="hidden" name="action" value="confirmPayment">
                    <input type="hidden" name="appointmentId" value="${appointment.id}">
                    <input type="hidden" name="email" value="${appointment.email}">

                    <div class="d-grid gap-2">
                      <button type="submit" class="btn btn-success btn-lg py-3 rounded-3 shadow-sm fw-bold">
                        <i class="bi bi-shield-check me-2"></i>Tôi đã thanh toán (Xác nhận lịch)
                      </button>
                      <a href="${pageContext.request.contextPath}/book-appointment" class="btn btn-link text-muted text-center mt-2">
                        <i class="bi bi-arrow-left me-1"></i>Hủy và chọn lại lịch khác
                      </a>
                    </div>
                  </form>
                </div>
              </div>
            </c:if>

            <%-- ======================================================== --%>
            <%-- MÀN HÌNH 1: FORM CHỌN BỆNH, BÁC SĨ & GIỜ (WIZARD FORM)  --%>
            <%-- ======================================================== --%>
            <c:if test="${step == null || step == 'form'}">
              <form id="bookingWizardForm" method="post" action="${pageContext.request.contextPath}/book-appointment">
                <input type="hidden" name="action" value="verify">
                <input type="hidden" name="scheduleId" id="selectedScheduleId" value="">

                <%-- PHẦN 1: CHỌN BỆNH LÝ & BÁC SĨ KHÁM HOÀN TOÀN TỪ DATABASE --%>
                <div class="mb-5">
                  <div class="d-flex align-items-center mb-3">
                    <span class="badge rounded-circle bg-teal me-2 p-2" style="background:#0d9488; width:28px; height:28px; display:inline-flex; align-items:center; justify-content:center;">1</span>
                    <h5 class="fw-bold mb-0 text-dark">Chọn Bệnh Lý / Dịch Vụ Khám Mắt (Từ cơ sở dữ liệu)</h5>
                  </div>
                  <p class="text-muted small mb-3">Vui lòng chọn triệu chứng hoặc dịch vụ bạn có nhu cầu thăm khám:</p>

                  <div class="row g-3 mb-4">
                    <c:forEach var="svc" items="${services}" varStatus="status">
                      <div class="col-md-6 col-lg-4">
                        <label class="d-block h-100">
                          <input type="radio" class="d-none service-radio" name="serviceId" value="${svc.id}"
                            data-specialty="${svc.specialty}"
                            ${(selectedServiceId == svc.id or (empty selectedServiceId and status.first)) ? 'checked' : ''}>
                          <div class="service-card d-flex flex-column justify-content-between">
                            <div>
                              <div class="d-flex justify-content-between align-items-start mb-2">
                                <span class="badge bg-light text-secondary border small">${svc.code != null ? svc.code : 'DV'}</span>
                                <span class="text-teal fw-bold" style="color: #0d9488;">
                                  <fmt:formatNumber value="${svc.price}" type="number" groupingUsed="true"/> ₫
                                </span>
                              </div>
                              <h6 class="fw-bold text-dark mb-1">${svc.name}</h6>
                              <p class="text-muted small mb-0 text-truncate-2" style="display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; font-size: 12px;">
                                ${svc.summary != null ? svc.summary : 'Dịch vụ khám nhãn khoa chất lượng cao với trang thiết bị chuẩn quốc tế.'}
                              </p>
                            </div>
                          </div>
                        </label>
                      </div>
                    </c:forEach>
                  </div>

                  <div class="row g-3">
                    <div class="col-md-12">
                      <label for="doctorSelect" class="form-label fw-bold">Chọn Bác sĩ điều trị phụ trách <span class="text-danger">*</span></label>
                      <select class="form-select form-select-lg rounded-3" id="doctorSelect" name="doctorId" required onchange="onDoctorOrDateChange()">
                        <option value="">— Vui lòng chọn bác sĩ nhãn khoa —</option>
                        <c:forEach var="doc" items="${doctors}">
                          <option value="${doc.id}" data-dept="${doc.departmentKey}"
                            ${(selectedDoctorId == doc.id or doc.id == appointment.doctorId) ? 'selected' : ''}>
                            ${doc.fullName} — Chuyên khoa: ${doc.specialty} ${doc.roomName != null ? ('(' + doc.roomName + ')') : ''}
                          </option>
                        </c:forEach>
                      </select>
                    </div>
                  </div>
                </div>

                <%-- PHẦN 2: CHỌN NGÀY VÀ KHUNG GIỜ ĐỘNG (KHÔNG CÓ CA TỐI) --%>
                <div class="mb-5 border-top pt-4">
                  <div class="d-flex align-items-center mb-3">
                    <span class="badge rounded-circle bg-teal me-2 p-2" style="background:#0d9488; width:28px; height:28px; display:inline-flex; align-items:center; justify-content:center;">2</span>
                    <h5 class="fw-bold mb-0 text-dark">Chọn Ngày &amp; Khung Giờ Khám Trực Tuyến</h5>
                  </div>

                  <div class="row g-3 align-items-center mb-3">
                    <div class="col-md-6">
                      <label for="appointmentDate" class="form-label fw-bold">Ngày khám <span class="text-danger">*</span></label>
                      <input type="date" class="form-control form-control-lg rounded-3" id="appointmentDate" name="appointmentDate"
                        value="${not empty selectedDate ? selectedDate : appointment.appointmentDate}"
                        required onchange="onDoctorOrDateChange()">
                    </div>
                    <div class="col-md-6 mt-md-4">
                      <div id="doctorShiftBadge" class="p-2 px-3 rounded-3 bg-light border text-muted small">
                        <i class="bi bi-info-circle me-1"></i>Chọn bác sĩ và ngày để xem ca làm việc
                      </div>
                    </div>
                  </div>

                  <%-- KHUNG GIỜ ĐỘNG ĐƯỢC LOAD QUA AJAX THEO CA BÁC SĨ (CHỈ SÁNG VÀ CHIỀU, BỎ HOÀN TOÀN TỐI) --%>
                  <div class="mb-4">
                    <label class="form-label fw-bold d-block">Khung giờ tiếp nhận còn trống <span class="text-danger">*</span></label>

                    <%-- Loading Spinner --%>
                    <div id="slotsLoading" class="py-3 text-center d-none">
                      <div class="spinner-border spinner-border-sm text-teal" style="color:#0d9488;" role="status"></div>
                      <span class="ms-2 text-muted small">Đang kiểm tra lịch ca trực của bác sĩ...</span>
                    </div>

                    <%-- Group Ca Sáng --%>
                    <div id="morningSection" class="mb-3 d-none">
                      <div class="d-flex align-items-center mb-2">
                        <span class="badge-session badge-morning me-2"><i class="bi bi-sun me-1"></i>Ca Sáng</span>
                        <small class="text-muted">(08:00 — 11:30)</small>
                      </div>
                      <div class="d-flex flex-wrap gap-2" id="morningSlotsContainer"></div>
                    </div>

                    <%-- Group Ca Chiều --%>
                    <div id="afternoonSection" class="mb-3 d-none">
                      <div class="d-flex align-items-center mb-2">
                        <span class="badge-session badge-afternoon me-2"><i class="bi bi-brightness-high me-1"></i>Ca Chiều</span>
                        <small class="text-muted">(13:30 — 16:30)</small>
                      </div>
                      <div class="d-flex flex-wrap gap-2" id="afternoonSlotsContainer"></div>
                    </div>

                    <%-- Thông báo không có lịch --%>
                    <div id="noSlotsAlert" class="alert alert-warning py-3 rounded-3 d-none mb-0">
                      <i class="bi bi-calendar-x me-2"></i>Bác sĩ không có ca trực hoặc tất cả khung giờ trong ngày này đã kín. Vui lòng chọn ngày khác hoặc bác sĩ khác!
                    </div>
                  </div>
                </div>

                <%-- PHẦN 3: THÔNG TIN BỆNH NHÂN (TỰ ĐỘNG ĐIỀN NẾU ĐÃ ĐĂNG NHẬP) --%>
                <div class="mb-5 border-top pt-4">
                  <div class="d-flex align-items-center mb-3">
                    <span class="badge rounded-circle bg-teal me-2 p-2" style="background:#0d9488; width:28px; height:28px; display:inline-flex; align-items:center; justify-content:center;">3</span>
                    <h5 class="fw-bold mb-0 text-dark">Thông Tin Người Khám &amp; Triệu Chứng</h5>
                  </div>

                  <c:if test="${not empty loggedUser}">
                    <div class="alert alert-light border d-flex align-items-center rounded-3 p-2 px-3 mb-3 small">
                      <i class="bi bi-person-check-fill text-success fs-5 me-2"></i>
                      <span>Đang đăng nhập với tài khoản: <b>${loggedUser.fullName}</b> (${loggedUser.email}). Thông tin đã được tự động điền.</span>
                    </div>
                  </c:if>

                  <div class="row g-3">
                    <div class="col-md-6">
                      <label class="form-label" for="patientName">Họ và tên người khám <span class="text-danger">*</span></label>
                      <input type="text" class="form-control form-control-lg rounded-3" id="patientName" name="patientName"
                        value="${not empty appointment.patientName ? appointment.patientName : (not empty loggedUser ? loggedUser.fullName : '')}"
                        placeholder="Ví dụ: Nguyễn Văn A" required>
                    </div>

                    <div class="col-md-6">
                      <label class="form-label" for="patientPhone">Số điện thoại liên hệ <span class="text-danger">*</span></label>
                      <input type="tel" class="form-control form-control-lg rounded-3" id="patientPhone" name="patientPhone"
                        value="${not empty appointment.phone ? appointment.phone : (not empty loggedUser ? loggedUser.phone : '')}"
                        placeholder="Ví dụ: 0912345678" pattern="^0[3|5|7|8|9][0-9]{8}$" required>
                    </div>

                    <div class="col-md-6">
                      <label class="form-label" for="patientEmail">Email nhận vé khám &amp; lời nhắc <span class="text-danger">*</span></label>
                      <input type="email" class="form-control form-control-lg rounded-3" id="patientEmail" name="patientEmail"
                        value="${not empty appointment.email ? appointment.email : (not empty loggedUser ? loggedUser.email : '')}"
                        placeholder="email@example.com" required>
                    </div>

                    <div class="col-md-6">
                      <label class="form-label" for="patientDob">Ngày tháng năm sinh <span class="text-danger">*</span></label>
                      <input type="text" class="form-control form-control-lg rounded-3" id="patientDob" name="patientDob"
                        value="${not empty appointment.dob ? appointment.dob : (not empty loggedUser ? loggedUser.dob : '')}"
                        placeholder="dd/mm/yyyy" pattern="\d{2}[/-]\d{2}[/-]\d{4}|\d{4}-\d{2}-\d{2}" required>
                    </div>

                    <div class="col-12">
                      <label class="form-label" for="visitReason">Lý do khám / Triệu chứng cụ thể</label>
                      <textarea class="form-control rounded-3" id="visitReason" name="visitReason" rows="2"
                        placeholder="Ví dụ: Nhìn mờ mắt phải khi đọc sách, mỏi mắt khi làm việc máy tính, muốn đo tật khúc xạ...">${appointment.reason}</textarea>
                    </div>
                  </div>
                </div>

                <%-- PHÍ KHÁM & NÚT XÁC NHẬN VERIFY APPOINTMENT --%>
                <div class="border-top pt-4">
                  <div class="d-flex flex-wrap justify-content-between align-items-center gap-3">
                    <div>
                      <span class="text-muted small d-block">Phí khám chuyên khoa ban đầu:</span>
                      <strong class="fs-4 text-teal" style="color: #0d9488;">200.000 ₫</strong>
                      <span class="badge bg-light text-secondary border ms-2">Đã bao gồm VAT &amp; Phí tư vấn</span>
                    </div>

                    <button type="submit" class="btn btn-primary btn-lg px-5 py-3 rounded-pill fw-bold shadow"
                      style="background: #0d9488; border-color: #0d9488;">
                      <i class="bi bi-calendar-check me-2"></i>Xác nhận lịch hẹn (Verify Appointment)
                    </button>
                  </div>
                </div>

              </form>
            </c:if>

          </div>
        </div>

      </div>
    </div>

  </div>
</main>

<%-- Include Footer --%>
<jsp:include page="/views/common/footer.jsp" />

<script>
  // Thiết lập ngày tối thiểu là ngày hôm nay
  const todayStr = new Date().toISOString().split('T')[0];
  const dateInput = document.getElementById('appointmentDate');
  if (dateInput) {
    dateInput.min = todayStr;
    if (!dateInput.value) {
      dateInput.value = todayStr;
    }
  }

  // Tải danh sách slots qua AJAX khi người dùng thay đổi Bác sĩ hoặc Ngày
  function onDoctorOrDateChange() {
    const docSelect = document.getElementById('doctorSelect');
    const dateVal = document.getElementById('appointmentDate')?.value;
    const badge = document.getElementById('doctorShiftBadge');
    const loading = document.getElementById('slotsLoading');
    const morningSection = document.getElementById('morningSection');
    const afternoonSection = document.getElementById('afternoonSection');
    const morningSlotsContainer = document.getElementById('morningSlotsContainer');
    const afternoonSlotsContainer = document.getElementById('afternoonSlotsContainer');
    const noSlotsAlert = document.getElementById('noSlotsAlert');

    if (!docSelect || !docSelect.value || !dateVal) {
      if (badge) badge.innerHTML = '<i class="bi bi-info-circle me-1"></i>Chọn bác sĩ và ngày để xem ca làm việc';
      return;
    }

    const docId = docSelect.value;
    loading.classList.remove('d-none');
    morningSection.classList.add('d-none');
    afternoonSection.classList.add('d-none');
    noSlotsAlert.classList.add('d-none');

    fetch('${pageContext.request.contextPath}/book-appointment?action=getSlots&doctorId=' + docId + '&date=' + dateVal)
      .then(res => res.json())
      .then(data => {
        loading.classList.add('d-none');
        morningSlotsContainer.innerHTML = '';
        afternoonSlotsContainer.innerHTML = '';

        // Hiển thị badge ca làm việc
        if (data.shiftSummary === 'FULL') {
          badge.innerHTML = '<span class="badge bg-success me-1">Full ngày</span> Bác sĩ trực cả ca Sáng và ca Chiều';
        } else if (data.shiftSummary === 'MORNING') {
          badge.innerHTML = '<span class="badge bg-warning text-dark me-1">Chỉ ca Sáng</span> Bác sĩ chỉ nhận lịch khám ca Sáng';
        } else if (data.shiftSummary === 'AFTERNOON') {
          badge.innerHTML = '<span class="badge bg-info text-dark me-1">Chỉ ca Chiều</span> Bác sĩ chỉ nhận lịch khám ca Chiều';
        } else {
          badge.innerHTML = '<span class="badge bg-secondary me-1">Nghỉ</span> Bác sĩ không có lịch trực trong ngày này';
        }

        if (!data.slots || data.slots.length === 0) {
          noSlotsAlert.classList.remove('d-none');
          return;
        }

        let hasMorning = false;
        let hasAfternoon = false;
        const preselectedTime = '${appointment.timeSlot != null ? appointment.timeSlot : selectedTime}';

        data.slots.forEach((s, idx) => {
          const isMorning = s.session === 'Morning';
          const container = isMorning ? morningSlotsContainer : afternoonSlotsContainer;
          if (isMorning) hasMorning = true;
          else hasAfternoon = true;

          const isChecked = preselectedTime && (preselectedTime.startsWith(s.startTime));
          const slotItem = document.createElement('div');
          slotItem.className = 'position-relative';
          slotItem.innerHTML = `
            <input type="radio" class="btn-check" name="timeSlot" id="slot_${s.id}"
                   value="${s.startTime}" data-schedule-id="${s.id}"
                   ${s.isBooked ? 'disabled' : ''} ${isChecked ? 'checked' : ''}
                   onchange="document.getElementById('selectedScheduleId').value = '${s.id}'" required>
            <label class="slot-btn" for="slot_${s.id}">
              ${s.startTime} — ${s.endTime}
              ${s.isBooked ? '<span class="badge bg-secondary ms-1 small" style="font-size:10px;">Đã kín</span>' : ''}
            </label>
          `;
          container.appendChild(slotItem);

          if (isChecked) {
            document.getElementById('selectedScheduleId').value = s.id;
          }
        });

        if (hasMorning) morningSection.classList.remove('d-none');
        if (hasAfternoon) afternoonSection.classList.remove('d-none');

        if (!hasMorning && !hasAfternoon) {
          noSlotsAlert.classList.remove('d-none');
        }
      })
      .catch(err => {
        console.error('Lỗi tải khung giờ:', err);
        loading.classList.add('d-none');
        noSlotsAlert.classList.remove('d-none');
      });
  }

  // Tự động kích hoạt tải slot khi trang sẵn sàng nếu đã có sẵn Doctor & Date
  document.addEventListener('DOMContentLoaded', function () {
    const docSelect = document.getElementById('doctorSelect');
    if (docSelect && docSelect.value) {
      onDoctorOrDateChange();
    }
  });
</script>
