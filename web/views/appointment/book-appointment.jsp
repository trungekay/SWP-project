<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

      <%-- Include Header --%>
        <jsp:include page="/views/common/header.jsp">
          <jsp:param name="pageTitle" value="Đặt lịch khám mắt trực tuyến" />
          <jsp:param name="pageDescription"
            value="Hệ thống đặt lịch khám chuyên khoa mắt và thanh toán trực tuyến — VisionCare" />
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

          .btn-check:checked+.slot-btn {
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

          .service-radio:checked+.service-card {
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
                        <p class="mb-4 opacity-90">Hệ thống tiếp nhận bệnh nhân &amp; xác nhận ca khám tự động trực
                          tuyến</p>

                        <div class="wizard-progress">
                          <div class="progress-step ${step == 'payment' || step == 'success' ? 'completed' : 'active'}"
                            id="p-step-1" onclick="jumpToWizardStep(1)">
                            <div class="step-dot"><i class="bi bi-person-badge"></i></div>
                            <div class="step-label text-white">1. Chọn bác sĩ</div>
                          </div>
                          <div class="progress-step ${step == 'payment' || step == 'success' ? 'completed' : ''}"
                            id="p-step-2" onclick="jumpToWizardStep(2)">
                            <div class="step-dot"><i class="bi bi-calendar2-week"></i></div>
                            <div class="step-label text-white">2. Ngày &amp; Giờ</div>
                          </div>
                          <div class="progress-step ${step == 'payment' || step == 'success' ? 'completed' : ''}"
                            id="p-step-3" onclick="jumpToWizardStep(3)">
                            <div class="step-dot"><i class="bi bi-card-checklist"></i></div>
                            <div class="step-label text-white">3. Điền thông tin</div>
                          </div>
                          <div
                            class="progress-step ${step == 'payment' ? 'active' : (step == 'success' ? 'completed' : '')}"
                            id="p-step-4">
                            <div class="step-dot"><i class="bi bi-qr-code-scan"></i></div>
                            <div class="step-label text-white">4. Thanh toán QR</div>
                          </div>
                        </div>
                      </div>

                      <div class="p-4 p-md-5">

                        <%--========================================================--%>
                          <%-- MÀN HÌNH 3: XÁC NHẬN THÀNH CÔNG (SUCCESS SCREEN) --%>
                            <%--========================================================--%>
                              <c:if test="${step == 'success'}">
                                <div class="text-center py-4">
                                  <div
                                    class="d-inline-flex p-3 rounded-circle bg-success bg-opacity-10 text-success mb-3">
                                    <i class="bi bi-check-circle-fill" style="font-size: 64px;"></i>
                                  </div>
                                  <h2 class="fw-bold text-success mb-2">Đặt Lịch &amp; Thanh Toán Thành Công!</h2>
                                  <p class="text-muted fs-6 mb-4">
                                    Hệ thống VisionCare đã ghi nhận vé khám và cập nhật trạng thái đã thanh toán.
                                  </p>

                                  <div class="ticket-card text-start mx-auto mb-4" style="max-width: 620px;">
                                    <div
                                      class="d-flex justify-content-between align-items-center border-bottom pb-3 mb-3">
                                      <div>
                                        <span class="text-muted small text-uppercase fw-bold">Mã Phiếu Hẹn</span>
                                        <h4 class="fw-bold text-teal mb-0" style="color: #0d9488;">#VC${appointment.id}
                                        </h4>
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
                                            <fmt:formatNumber value="${appointment.fee}" type="number"
                                              groupingUsed="true" /> ₫
                                          </strong>
                                        </div>
                                      </div>
                                    </div>
                                  </div>

                                  <div class="alert alert-info d-inline-block text-start rounded-3 p-3 mb-4"
                                    style="max-width: 620px;">
                                    <i class="bi bi-envelope-check-fill me-2 fs-5 text-primary"></i>
                                    <span>Email xác nhận và phiếu hướng dẫn chuẩn bị khám đã được tự động gửi tới:
                                      <b>${appointment.email}</b>. Vui lòng kiểm tra hộp thư của bạn!</span>
                                  </div>

                                  <div class="d-flex justify-content-center gap-3">
                                    <a href="${pageContext.request.contextPath}/home"
                                      class="btn btn-outline-secondary px-4 py-2 rounded-pill">
                                      <i class="bi bi-house me-2"></i>Về trang chủ
                                    </a>
                                    <a href="${pageContext.request.contextPath}/profile"
                                      class="btn btn-primary px-4 py-2 rounded-pill"
                                      style="background: #0d9488; border-color: #0d9488;">
                                      <i class="bi bi-calendar-check me-2"></i>Xem lịch hẹn của tôi
                                    </a>
                                  </div>
                                </div>
                              </c:if>

                              <%--========================================================--%>
                                <%-- MÀN HÌNH 2: XÁC THỰC THANH TOÁN QR (PAYMENT SCREEN) --%>
                                  <%--========================================================--%>
                                    <c:if test="${step == 'payment'}">
                                      <div class="row align-items-center g-4">
                                        <div class="col-md-5 text-center">
                                          <div class="qr-box">
                                            <h5 class="fw-bold text-dark mb-1">Quét mã VietQR</h5>
                                            <p class="text-muted small mb-3">Mở ứng dụng Ngân hàng hoặc Ví điện tử để
                                              quét</p>

                                            <div class="position-relative d-inline-block">
                                              <img src="${qrUrl}" alt="VietQR VisionCare"
                                                class="img-fluid rounded-3 border"
                                                style="max-width: 260px; min-height: 260px;">
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
                                            <h5 class="fw-bold text-dark border-bottom pb-2 mb-3">Chi tiết phiếu đặt
                                              lịch khám</h5>
                                            <div class="row g-2 small">
                                              <div class="col-6 text-muted">Mã lịch hẹn:</div>
                                              <div class="col-6 fw-bold text-dark text-end">#VC${appointment.id}</div>

                                              <div class="col-6 text-muted">Bệnh nhân:</div>
                                              <div class="col-6 fw-bold text-dark text-end">${appointment.patientName}
                                              </div>

                                              <div class="col-6 text-muted">Bác sĩ khám:</div>
                                              <div class="col-6 fw-bold text-primary text-end">${appointment.doctorName}
                                              </div>

                                              <div class="col-6 text-muted">Thời gian hẹn:</div>
                                              <div class="col-6 fw-bold text-danger text-end">${appointment.timeSlot} —
                                                ${appointment.appointmentDate}</div>

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

                                              <div class="col-6 fs-6 text-dark fw-bold mt-2">Tổng phí khám ban đầu:
                                              </div>
                                              <div class="col-6 fs-5 fw-bold text-success text-end mt-2">
                                                <fmt:formatNumber value="${fee}" type="number" groupingUsed="true" /> ₫
                                              </div>
                                            </div>
                                          </div>

                                          <form method="post"
                                            action="${pageContext.request.contextPath}/book-appointment">
                                            <input type="hidden" name="action" value="confirmPayment">
                                            <input type="hidden" name="appointmentId" value="${appointment.id}">
                                            <input type="hidden" name="email" value="${appointment.email}">

                                            <div class="d-grid gap-2">
                                              <div class="alert alert-info py-2 px-3 small rounded-3 mb-2 d-flex align-items-center">
                                                <div class="spinner-grow spinner-grow-sm text-info me-2" role="status"></div>
                                                <span>Hệ thống tự động kiểm tra biến động số dư qua PayOS. Trang sẽ <b>tự động chuyển sang Thành công</b> ngay khi hoàn tất chuyển khoản!</span>
                                              </div>
                                              <c:if test="${not empty payosCheckoutUrl}">
                                                <a href="${payosCheckoutUrl}" target="_blank"
                                                  class="btn btn-primary btn-lg py-3 rounded-3 fw-bold text-white shadow-sm mb-2" style="background:#0d9488; border-color:#0d9488;">
                                                  <i class="bi bi-credit-card-2-front me-2"></i>Mở cổng thanh toán PayOS trực tiếp
                                                </a>
                                              </c:if>
                                              <button type="submit"
                                                class="btn btn-success btn-lg py-3 rounded-3 shadow-sm fw-bold">
                                                <i class="bi bi-shield-check me-2"></i>Tôi đã thanh toán (Xác nhận thủ công)
                                              </button>
                                              <a href="${pageContext.request.contextPath}/book-appointment"
                                                class="btn btn-link text-muted text-center mt-2">
                                                <i class="bi bi-arrow-left me-1"></i>Hủy và chọn lại lịch khác
                                              </a>
                                            </div>
                                          </form>
                                        </div>
                                      </div>
                                    </c:if>

                                    <%--========================================================--%>
                                      <%-- MÀN HÌNH 1: FORM CHỌN BỆNH, BÁC SĨ & GIỜ (WIZARD FORM) --%>
                                        <%--========================================================--%>
                                          <c:if test="${step == null || step == 'form'}">
                                            <form id="bookingWizardForm" method="post"
                                              action="${pageContext.request.contextPath}/book-appointment">
                                              <input type="hidden" name="action" value="verify">
                                              <input type="hidden" name="scheduleId" id="selectedScheduleId" value="">

                                              <%--========================================================--%>
                                                <%-- BƯỚC 1: CHỌN DỊCH VỤ KHÁM & BÁC SĨ PHỤ TRÁCH --%>
                                                  <%--========================================================--%>
                                                    <div id="wizardSection1">
                                                      <div class="d-flex align-items-center mb-3">
                                                        <span class="badge rounded-circle text-white me-2 p-2"
                                                          style="background:#0d9488; width:28px; height:28px; display:inline-flex; align-items:center; justify-content:center;">1</span>
                                                        <h5 class="fw-bold mb-0 text-dark">Chọn Bệnh Lý / Dịch Vụ Khám
                                                          Mắt &amp; Bác Sĩ</h5>
                                                      </div>
                                                      <p class="text-muted small mb-3">Vui lòng chọn triệu chứng hoặc
                                                        dịch vụ bạn có nhu cầu thăm khám:</p>

                                                      <div class="row g-3 mb-4">
                                                        <c:forEach var="svc" items="${services}" varStatus="status">
                                                          <div class="col-md-6 col-lg-4">
                                                            <label class="d-block h-100">
                                                              <input type="radio" class="d-none service-radio"
                                                                name="serviceId" value="${svc.id}"
                                                                data-specialty="${svc.specialty}"
                                                                data-name="${svc.name}" data-price="${svc.price}"
                                                                onchange="filterDoctorsByService(this)"
                                                                ${(selectedServiceId==svc.id or (empty selectedServiceId
                                                                and status.first)) ? 'checked' : '' }>
                                                              <div
                                                                class="service-card d-flex flex-column justify-content-between">
                                                                <div>
                                                                  <div
                                                                    class="d-flex justify-content-between align-items-start mb-2">
                                                                    <span
                                                                      class="badge bg-light text-secondary border small">${svc.code
                                                                      != null ? svc.code : 'DV'}</span>
                                                                    <span class="text-teal fw-bold"
                                                                      style="color: #0d9488;">
                                                                      <fmt:formatNumber value="${svc.price}"
                                                                        type="number" groupingUsed="true" /> ₫
                                                                    </span>
                                                                  </div>
                                                                  <h6 class="fw-bold text-dark mb-1">${svc.name}</h6>
                                                                  <p class="text-muted small mb-0 text-truncate-2"
                                                                    style="display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; font-size: 12px;">
                                                                    ${svc.summary != null ? svc.summary : 'Dịch vụ khám
                                                                    nhãn khoa chất lượng cao với trang thiết bị chuẩn
                                                                    quốc tế.'}
                                                                  </p>
                                                                </div>
                                                              </div>
                                                            </label>
                                                          </div>
                                                        </c:forEach>
                                                      </div>

                                                      <div class="row g-3">
                                                        <div class="col-md-12">
                                                          <div
                                                            class="d-flex justify-content-between align-items-center mb-1">
                                                            <label for="doctorSelect"
                                                              class="form-label fw-bold mb-0">Bác sĩ điều trị phụ trách
                                                              <span class="text-danger">*</span></label>
                                                            <span id="doctorFilterTag"
                                                              class="badge bg-teal text-white small"
                                                              style="background:#0d9488;">
                                                              <i class="bi bi-people-fill me-1"></i>Đội ngũ bác sĩ
                                                              VisionCare
                                                            </span>
                                                          </div>
                                                          <div id="doctorFilterNotice"
                                                            class="alert alert-light border rounded-3 p-2 px-3 mb-2 small text-muted">
                                                          </div>

                                                          <select class="form-select form-select-lg rounded-3"
                                                            id="doctorSelect" name="doctorId" required
                                                            onchange="onDoctorSelectChange()">
                                                            <option value="">— Vui lòng chọn bác sĩ nhãn khoa —</option>
                                                            <c:forEach var="doc" items="${doctors}">
                                                              <option value="${doc.id}" data-dept="${doc.departmentKey}"
                                                                data-specialty="${doc.specialty}"
                                                                data-name="${doc.fullName}"
                                                                data-room="${doc.roomName != null ? doc.roomName : 'Phòng khám chuyên khoa'}"
                                                                data-avatar="${pageContext.request.contextPath}/assets/img/${not empty doc.image ? doc.image : 'doctors/doctors-1.jpg'}"
                                                                ${(selectedDoctorId==doc.id or
                                                                doc.id==appointment.doctorId) ? 'selected' : '' }>
                                                                ${doc.fullName} — Chuyên khoa: ${doc.specialty}<c:if
                                                                  test="${not empty doc.roomName}"> (${doc.roomName})
                                                                </c:if>
                                                              </option>
                                                            </c:forEach>
                                                          </select>

                                                          <%-- Doctor Preview Card --%>
                                                            <div id="doctorPreviewCard"
                                                              class="card border-0 shadow-sm rounded-4 p-3 mt-3 bg-light d-none">
                                                              <div class="d-flex align-items-center">
                                                                <img id="docPreviewAvatar" src="" alt="Bác sĩ"
                                                                  class="rounded-circle border me-3 shadow-sm"
                                                                  style="width: 65px; height: 65px; object-fit: cover;">
                                                                <div class="flex-grow-1">
                                                                  <div
                                                                    class="d-flex align-items-center justify-content-between flex-wrap">
                                                                    <h6 class="fw-bold mb-0 text-dark"
                                                                      id="docPreviewName"></h6>
                                                                    <span id="docMatchBadge"
                                                                      class="badge bg-success-subtle text-success border border-success-subtle rounded-pill small">
                                                                      <i class="bi bi-check-circle me-1"></i>Bác sĩ tiếp
                                                                      nhận
                                                                    </span>
                                                                  </div>
                                                                  <p class="text-primary small mb-1 fw-semibold"
                                                                    id="docPreviewSpecialty"></p>
                                                                  <span
                                                                    class="badge bg-white border text-secondary small"
                                                                    id="docPreviewRoom"></span>
                                                                </div>
                                                              </div>
                                                            </div>
                                                        </div>
                                                      </div>

                                                      <%-- NÚT TIẾP TỤC BƯỚC 1 --%>
                                                        <div
                                                          class="d-flex justify-content-between align-items-center mt-5 pt-3 border-top">
                                                          <span class="text-muted small"><i
                                                              class="bi bi-info-circle me-1"></i>Bước 1/3: Chọn dịch vụ
                                                            và bác sĩ điều trị</span>
                                                          <button type="button"
                                                            class="btn btn-primary btn-lg px-5 py-3 rounded-pill fw-bold shadow-sm"
                                                            style="background: #0d9488; border-color: #0d9488;"
                                                            onclick="nextWizardStep(1)">
                                                            Tiếp tục: Chọn ngày &amp; giờ khám <i
                                                              class="bi bi-arrow-right ms-2"></i>
                                                          </button>
                                                        </div>
                                                    </div>

                                                    <%--========================================================--%>
                                                      <%-- BƯỚC 2: CHỌN NGÀY VÀ KHUNG GIỜ TIẾP NHẬN --%>
                                                        <%--========================================================--%>
                                                          <div id="wizardSection2" style="display: none;">
                                                            <div class="d-flex align-items-center mb-3">
                                                              <span class="badge rounded-circle text-white me-2 p-2"
                                                                style="background:#0d9488; width:28px; height:28px; display:inline-flex; align-items:center; justify-content:center;">2</span>
                                                              <h5 class="fw-bold mb-0 text-dark">Chọn Ngày &amp; Khung
                                                                Giờ Khám Trực Tuyến</h5>
                                                            </div>

                                                            <%-- Tóm tắt lựa chọn ở Bước 1 --%>
                                                              <div
                                                                class="alert alert-light border rounded-3 p-3 mb-4 d-flex flex-wrap justify-content-between align-items-center gap-2">
                                                                <div>
                                                                  <i class="bi bi-person-badge-fill text-teal me-2 fs-5"
                                                                    style="color: #0d9488;"></i>
                                                                  <span>Bác sĩ phụ trách: <b class="text-dark"
                                                                      id="summaryDocName">Chưa chọn</b> (<span
                                                                      class="text-muted"
                                                                      id="summaryDocSpecialty"></span>)</span>
                                                                  <span class="mx-2 text-muted">|</span>
                                                                  <span>Dịch vụ: <b class="text-teal"
                                                                      id="summaryServiceName"
                                                                      style="color: #0d9488;">Chưa chọn</b></span>
                                                                </div>
                                                                <button type="button"
                                                                  class="btn btn-sm btn-outline-secondary rounded-pill px-3"
                                                                  onclick="prevWizardStep(2)">
                                                                  <i class="bi bi-pencil-square me-1"></i>Đổi bác sĩ /
                                                                  dịch vụ
                                                                </button>
                                                              </div>

                                                              <div class="row g-3 align-items-center mb-3">
                                                                <div class="col-md-6">
                                                                  <label for="appointmentDate"
                                                                    class="form-label fw-bold">Ngày khám <span
                                                                      class="text-danger">*</span></label>
                                                                  <input type="date"
                                                                    class="form-control form-control-lg rounded-3"
                                                                    id="appointmentDate" name="appointmentDate"
                                                                    value="${not empty selectedDate ? selectedDate : appointment.appointmentDate}"
                                                                    required onchange="onDoctorOrDateChange()">
                                                                </div>
                                                                <div class="col-md-6 mt-md-4">
                                                                  <div id="doctorShiftBadge"
                                                                    class="p-2 px-3 rounded-3 bg-light border text-muted small">
                                                                    <i class="bi bi-info-circle me-1"></i>Chọn bác sĩ và
                                                                    ngày để xem ca làm việc
                                                                  </div>
                                                                </div>
                                                              </div>

                                                              <%-- KHUNG GIỜ ĐỘNG QUA AJAX THEO CA BÁC SĨ (CHỈ SÁNG VÀ
                                                                CHIỀU) --%>
                                                                <div class="mb-4">
                                                                  <label class="form-label fw-bold d-block">Khung giờ
                                                                    tiếp nhận còn trống <span
                                                                      class="text-danger">*</span></label>

                                                                  <%-- Loading Spinner --%>
                                                                    <div id="slotsLoading"
                                                                      class="py-3 text-center d-none">
                                                                      <div
                                                                        class="spinner-border spinner-border-sm text-teal"
                                                                        style="color:#0d9488;" role="status"></div>
                                                                      <span class="ms-2 text-muted small">Đang kiểm tra
                                                                        lịch ca trực của bác sĩ...</span>
                                                                    </div>

                                                                    <%-- Group Ca Sáng --%>
                                                                      <div id="morningSection" class="mb-3 d-none">
                                                                        <div class="d-flex align-items-center mb-2">
                                                                          <span
                                                                            class="badge-session badge-morning me-2"><i
                                                                              class="bi bi-sun me-1"></i>Ca Sáng</span>
                                                                          <small class="text-muted">(08:00 —
                                                                            11:30)</small>
                                                                        </div>
                                                                        <div class="d-flex flex-wrap gap-2"
                                                                          id="morningSlotsContainer"></div>
                                                                      </div>

                                                                      <%-- Group Ca Chiều --%>
                                                                        <div id="afternoonSection" class="mb-3 d-none">
                                                                          <div class="d-flex align-items-center mb-2">
                                                                            <span
                                                                              class="badge-session badge-afternoon me-2"><i
                                                                                class="bi bi-brightness-high me-1"></i>Ca
                                                                              Chiều</span>
                                                                            <small class="text-muted">(13:30 —
                                                                              16:30)</small>
                                                                          </div>
                                                                          <div class="d-flex flex-wrap gap-2"
                                                                            id="afternoonSlotsContainer"></div>
                                                                        </div>

                                                                        <%-- Thông báo không có lịch --%>
                                                                          <div id="noSlotsAlert"
                                                                            class="alert alert-warning py-3 rounded-3 d-none mb-0">
                                                                            <i class="bi bi-calendar-x me-2"></i>Bác sĩ
                                                                            không có ca trực hoặc tất cả khung giờ trong
                                                                            ngày này đã kín. Vui lòng chọn ngày khác
                                                                            hoặc đổi bác sĩ!
                                                                          </div>
                                                                </div>

                                                                <%-- NÚT ĐIỀU HƯỚNG BƯỚC 2 --%>
                                                                  <div
                                                                    class="d-flex justify-content-between align-items-center mt-5 pt-3 border-top">
                                                                    <button type="button"
                                                                      class="btn btn-outline-secondary btn-lg px-4 py-2 rounded-pill fw-semibold"
                                                                      onclick="prevWizardStep(2)">
                                                                      <i class="bi bi-arrow-left me-2"></i>Quay lại bước
                                                                      1
                                                                    </button>
                                                                    <button type="button"
                                                                      class="btn btn-primary btn-lg px-5 py-3 rounded-pill fw-bold shadow-sm"
                                                                      style="background: #0d9488; border-color: #0d9488;"
                                                                      onclick="nextWizardStep(2)">
                                                                      Tiếp tục: Điền thông tin người khám <i
                                                                        class="bi bi-arrow-right ms-2"></i>
                                                                    </button>
                                                                  </div>
                                                          </div>

                                                          <%--========================================================--%>
                                                            <%-- BƯỚC 3: THÔNG TIN BỆNH NHÂN & XÁC NHẬN --%>
                                                              <%--========================================================--%>
                                                                <div id="wizardSection3" style="display: none;">
                                                                  <div class="d-flex align-items-center mb-3">
                                                                    <span
                                                                      class="badge rounded-circle text-white me-2 p-2"
                                                                      style="background:#0d9488; width:28px; height:28px; display:inline-flex; align-items:center; justify-content:center;">3</span>
                                                                    <h5 class="fw-bold mb-0 text-dark">Thông Tin Người
                                                                      Khám &amp; Triệu Chứng</h5>
                                                                  </div>

                                                                  <%-- Thẻ tóm tắt thông tin ca khám đã chọn --%>
                                                                    <div class="ticket-card mb-4">
                                                                      <div
                                                                        class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-3">
                                                                        <h6 class="fw-bold text-dark mb-0"><i
                                                                            class="bi bi-calendar-check me-2"
                                                                            style="color: #0d9488;"></i>Tóm tắt thông
                                                                          tin lịch hẹn đã chọn</h6>
                                                                        <button type="button"
                                                                          class="btn btn-sm btn-link text-decoration-none p-0 fw-semibold"
                                                                          style="color: #0d9488;"
                                                                          onclick="goToWizardStep(2)">
                                                                          <i class="bi bi-pencil-square me-1"></i>Sửa
                                                                          ngày / giờ
                                                                        </button>
                                                                      </div>
                                                                      <div class="row g-2 small">
                                                                        <div class="col-sm-6"><span
                                                                            class="text-muted">Bác sĩ phụ trách:</span>
                                                                          <b class="text-primary ms-1"
                                                                            id="recapDocName"></b></div>
                                                                        <div class="col-sm-6"><span
                                                                            class="text-muted">Chuyên khoa:</span> <b
                                                                            class="text-dark ms-1"
                                                                            id="recapDocSpecialty"></b></div>
                                                                        <div class="col-sm-6"><span
                                                                            class="text-muted">Dịch vụ khám:</span> <b
                                                                            class="text-dark ms-1"
                                                                            id="recapServiceName"></b></div>
                                                                        <div class="col-sm-6"><span
                                                                            class="text-muted">Thời gian khám:</span> <b
                                                                            class="text-danger ms-1"><span
                                                                              id="recapTimeSlot"></span> &mdash; <span
                                                                              id="recapDate"></span></b></div>
                                                                      </div>
                                                                    </div>

                                                                    <c:if test="${not empty loggedUser}">
                                                                      <div
                                                                        class="alert alert-light border d-flex align-items-center rounded-3 p-2 px-3 mb-3 small">
                                                                        <i
                                                                          class="bi bi-person-check-fill text-success fs-5 me-2"></i>
                                                                        <span>Đang đăng nhập với tài khoản:
                                                                          <b>${loggedUser.fullName}</b>
                                                                          (${loggedUser.email}). Thông tin đã được tự
                                                                          động điền.</span>
                                                                      </div>
                                                                    </c:if>

                                                                    <div class="row g-3">
                                                                      <div class="col-md-6">
                                                                        <label class="form-label" for="patientName">Họ
                                                                          và tên người khám <span
                                                                            class="text-danger">*</span></label>
                                                                        <input type="text"
                                                                          class="form-control form-control-lg rounded-3"
                                                                          id="patientName" name="patientName"
                                                                          value="${not empty appointment.patientName ? appointment.patientName : (not empty loggedUser ? loggedUser.fullName : '')}"
                                                                          placeholder="Ví dụ: Nguyễn Văn A" required>
                                                                      </div>

                                                                      <div class="col-md-6">
                                                                        <label class="form-label" for="patientPhone">Số
                                                                          điện thoại liên hệ <span
                                                                            class="text-danger">*</span></label>
                                                                        <input type="tel"
                                                                          class="form-control form-control-lg rounded-3"
                                                                          id="patientPhone" name="patientPhone"
                                                                          value="${not empty appointment.phone ? appointment.phone : (not empty loggedUser ? loggedUser.phone : '')}"
                                                                          placeholder="Ví dụ: 0912345678"
                                                                          pattern="^0[3|5|7|8|9][0-9]{8}$" required>
                                                                      </div>

                                                                      <div class="col-md-6">
                                                                        <label class="form-label"
                                                                          for="patientEmail">Email nhận vé khám &amp;
                                                                          lời nhắc <span
                                                                            class="text-danger">*</span></label>
                                                                        <input type="email"
                                                                          class="form-control form-control-lg rounded-3"
                                                                          id="patientEmail" name="patientEmail"
                                                                          value="${not empty appointment.email ? appointment.email : (not empty loggedUser ? loggedUser.email : '')}"
                                                                          placeholder="email@example.com" required>
                                                                      </div>

                                                                      <div class="col-md-6">
                                                                        <label class="form-label" for="patientDob">Ngày
                                                                          tháng năm sinh <span
                                                                            class="text-danger">*</span></label>
                                                                        <input type="text"
                                                                          class="form-control form-control-lg rounded-3"
                                                                          id="patientDob" name="patientDob"
                                                                          value="${not empty appointment.dob ? appointment.dob : (not empty loggedUser ? loggedUser.dob : '')}"
                                                                          placeholder="dd/mm/yyyy"
                                                                          pattern="\d{2}[/-]\d{2}[/-]\d{4}|\d{4}-\d{2}-\d{2}"
                                                                          required>
                                                                      </div>

                                                                      <div class="col-12">
                                                                        <label class="form-label" for="visitReason">Lý
                                                                          do khám / Triệu chứng cụ thể</label>
                                                                        <textarea class="form-control rounded-3"
                                                                          id="visitReason" name="visitReason" rows="2"
                                                                          placeholder="Ví dụ: Nhìn mờ mắt phải khi đọc sách, mỏi mắt khi làm việc máy tính, muốn đo tật khúc xạ...">${appointment.reason}</textarea>
                                                                      </div>
                                                                    </div>

                                                                    <%-- PHÍ KHÁM & NÚT XÁC NHẬN VERIFY APPOINTMENT --%>
                                                                      <div class="border-top pt-4 mt-4">
                                                                        <div
                                                                          class="d-flex flex-wrap justify-content-between align-items-center gap-3">
                                                                          <div>
                                                                            <span class="text-muted small d-block">Phí
                                                                              khám chuyên khoa ban đầu:</span>
                                                                            <strong class="fs-4 text-teal"
                                                                              style="color: #0d9488;">200.000 ₫</strong>
                                                                            <span
                                                                              class="badge bg-light text-secondary border ms-2">Đã
                                                                              bao gồm VAT &amp; Phí tư vấn</span>
                                                                          </div>

                                                                          <div class="d-flex gap-2">
                                                                            <button type="button"
                                                                              class="btn btn-outline-secondary btn-lg px-4 py-2 rounded-pill fw-semibold"
                                                                              onclick="prevWizardStep(3)">
                                                                              <i class="bi bi-arrow-left me-2"></i>Quay
                                                                              lại bước 2
                                                                            </button>
                                                                            <button type="submit"
                                                                              class="btn btn-primary btn-lg px-5 py-3 rounded-pill fw-bold shadow"
                                                                              style="background: #0d9488; border-color: #0d9488;">
                                                                              <i
                                                                                class="bi bi-calendar-check me-2"></i>Xác
                                                                              nhận lịch hẹn (Verify Appointment)
                                                                            </button>
                                                                          </div>
                                                                        </div>
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
            let currentWizardStep = 1;

            // Thiết lập ngày tối thiểu là ngày hôm nay theo giờ địa phương
            const now = new Date();
            const yyyy = now.getFullYear();
            const mm = String(now.getMonth() + 1).padStart(2, '0');
            const dd = String(now.getDate()).padStart(2, '0');
            const todayStr = yyyy + '-' + mm + '-' + dd;
            const dateInput = document.getElementById('appointmentDate');
            if (dateInput) {
              dateInput.min = todayStr;
              if (!dateInput.value) {
                dateInput.value = todayStr;
              }
            }

            // Điều hướng chuyển bước trong wizard
            function nextWizardStep(step) {
              if (step === 1) {
                const docSelect = document.getElementById('doctorSelect');
                if (!docSelect || !docSelect.value) {
                  alert('Vui lòng chọn bác sĩ nhãn khoa phụ trách trước khi tiếp tục.');
                  if (docSelect) docSelect.focus();
                  return;
                }
                const checkedSvc = document.querySelector('input[name="serviceId"]:checked');
                if (!checkedSvc) {
                  alert('Vui lòng chọn một dịch vụ / bệnh lý khám mắt.');
                  return;
                }

                goToWizardStep(2);
                onDoctorOrDateChange();
              } else if (step === 2) {
                const dateVal = document.getElementById('appointmentDate')?.value;
                if (!dateVal) {
                  alert('Vui lòng chọn ngày khám.');
                  document.getElementById('appointmentDate').focus();
                  return;
                }
                const checkedSlot = document.querySelector('input[name="timeSlot"]:checked');
                if (!checkedSlot) {
                  alert('Vui lòng chọn một khung giờ tiếp nhận còn trống.');
                  return;
                }

                goToWizardStep(3);
              }
            }

            function prevWizardStep(step) {
              goToWizardStep(step - 1);
            }

            function jumpToWizardStep(step) {
              if (step === 1) {
                goToWizardStep(1);
              } else if (step === 2) {
                const docSelect = document.getElementById('doctorSelect');
                if (docSelect && docSelect.value) {
                  goToWizardStep(2);
                } else {
                  alert('Vui lòng chọn bác sĩ trước.');
                }
              } else if (step === 3) {
                const docSelect = document.getElementById('doctorSelect');
                const checkedSlot = document.querySelector('input[name="timeSlot"]:checked');
                if (docSelect && docSelect.value && checkedSlot) {
                  goToWizardStep(3);
                } else {
                  alert('Vui lòng chọn bác sĩ, ngày và khung giờ khám trước.');
                }
              }
            }

            function goToWizardStep(step) {
              currentWizardStep = step;
              const sec1 = document.getElementById('wizardSection1');
              const sec2 = document.getElementById('wizardSection2');
              const sec3 = document.getElementById('wizardSection3');

              if (sec1) sec1.style.display = (step === 1 ? 'block' : 'none');
              if (sec2) sec2.style.display = (step === 2 ? 'block' : 'none');
              if (sec3) sec3.style.display = (step === 3 ? 'block' : 'none');

              // Cập nhật progress dots
              const p1 = document.getElementById('p-step-1');
              const p2 = document.getElementById('p-step-2');
              const p3 = document.getElementById('p-step-3');

              if (p1 && p2 && p3) {
                p1.className = 'progress-step ' + (step > 1 ? 'completed' : 'active');
                p2.className = 'progress-step ' + (step > 2 ? 'completed' : (step === 2 ? 'active' : ''));
                p3.className = 'progress-step ' + (step === 3 ? 'active' : '');
              }

              // Cập nhật thông tin tóm tắt bước 2
              if (step >= 2) {
                const docSelect = document.getElementById('doctorSelect');
                const opt = docSelect ? docSelect.selectedOptions[0] : null;
                const docName = opt ? (opt.dataset.name || opt.text) : 'Chưa chọn';
                const docSpec = opt ? (opt.dataset.specialty || '') : '';
                const checkedSvc = document.querySelector('input[name="serviceId"]:checked');
                const svcName = checkedSvc ? (checkedSvc.dataset.name || 'Khám chuyên khoa') : 'Khám chuyên khoa';

                const sDocName = document.getElementById('summaryDocName');
                if (sDocName) sDocName.textContent = docName;
                const sDocSpec = document.getElementById('summaryDocSpecialty');
                if (sDocSpec) sDocSpec.textContent = docSpec;
                const sSvcName = document.getElementById('summaryServiceName');
                if (sSvcName) sSvcName.textContent = svcName;
              }

              // Cập nhật thông tin tóm tắt bước 3
              if (step === 3) {
                const docSelect = document.getElementById('doctorSelect');
                const opt = docSelect ? docSelect.selectedOptions[0] : null;
                const docName = opt ? (opt.dataset.name || opt.text) : '';
                const docSpec = opt ? (opt.dataset.specialty || '') : '';
                const checkedSvc = document.querySelector('input[name="serviceId"]:checked');
                const svcName = checkedSvc ? (checkedSvc.dataset.name || '') : '';
                const dateVal = document.getElementById('appointmentDate')?.value || '';
                const checkedSlot = document.querySelector('input[name="timeSlot"]:checked');
                const slotVal = checkedSlot ? (checkedSlot.dataset.timeRange || checkedSlot.value) : '';

                const rDoc = document.getElementById('recapDocName');
                if (rDoc) rDoc.textContent = docName;
                const rSpec = document.getElementById('recapDocSpecialty');
                if (rSpec) rSpec.textContent = docSpec;
                const rSvc = document.getElementById('recapServiceName');
                if (rSvc) rSvc.textContent = svcName;
                const rDate = document.getElementById('recapDate');
                if (rDate) rDate.textContent = dateVal;
                const rTime = document.getElementById('recapTimeSlot');
                if (rTime) rTime.textContent = slotVal;
              }

              // Cuộn lên đầu thẻ booking
              const bookingCard = document.querySelector('.booking-card');
              if (bookingCard) {
                bookingCard.scrollIntoView({ behavior: 'smooth', block: 'start' });
              }
            }

            // Lọc bác sĩ theo chuyên khoa khi người dùng nhấn chọn dịch vụ / bệnh lý (KHÔNG ẨN BÁC SĨ NÀO)
            function filterDoctorsByService(radioElement) {
              if (!radioElement) return;
              const specialtyCode = (radioElement.dataset.specialty || '').toLowerCase().trim();
              const serviceName = radioElement.dataset.name || 'Dịch vụ đã chọn';
              const doctorSelect = document.getElementById('doctorSelect');
              if (!doctorSelect) return;

              const filterTag = document.getElementById('doctorFilterTag');
              const filterNotice = document.getElementById('doctorFilterNotice');

              let matchedCount = 0;
              let firstMatchedValue = '';
              let currentMatches = false;
              const currentVal = doctorSelect.value;

              Array.from(doctorSelect.options).forEach(opt => {
                if (!opt.value) return; // Bỏ qua placeholder
                const docDept = (opt.dataset.dept || '').toLowerCase().trim();
                const docSpecialty = (opt.dataset.specialty || '').toLowerCase().trim();

                let isMatch = false;
                if (!specialtyCode || specialtyCode === 'all') {
                  isMatch = true;
                } else if (docDept === specialtyCode || docSpecialty.includes(specialtyCode)) {
                  isMatch = true;
                } else if (specialtyCode === 'general' && (docDept === 'general' || docSpecialty.includes('tổng quát'))) {
                  isMatch = true;
                } else if (specialtyCode === 'refraction' && (docDept === 'refraction' || docSpecialty.includes('khúc xạ') || docSpecialty.includes('kính'))) {
                  isMatch = true;
                } else if (specialtyCode === 'lasik' && (docDept === 'lasik' || docSpecialty.includes('lasik') || docSpecialty.includes('phẫu thuật'))) {
                  isMatch = true;
                } else if (specialtyCode === 'children' && (docDept === 'children' || docSpecialty.includes('trẻ em') || docSpecialty.includes('nhược thị'))) {
                  isMatch = true;
                } else if (specialtyCode === 'cataract' && (docDept === 'cataract' || docSpecialty.includes('thủy tinh thể') || docSpecialty.includes('phaco'))) {
                  isMatch = true;
                } else if (specialtyCode === 'retina' && (docDept === 'retina' || docSpecialty.includes('võng mạc') || docSpecialty.includes('glaucoma'))) {
                  isMatch = true;
                }

                // Giữ cho TẤT CẢ bác sĩ luôn luôn hiển thị đầy đủ
                opt.hidden = false;
                opt.disabled = false;
                opt.style.display = '';

                const baseText = opt.dataset.name + ' — Chuyên khoa: ' + opt.dataset.specialty + (opt.dataset.room ? ' (' + opt.dataset.room + ')' : '');
                if (isMatch) {
                  opt.text = '★ [Đúng chuyên khoa] ' + baseText;
                  matchedCount++;
                  if (!firstMatchedValue) firstMatchedValue = opt.value;
                  if (opt.value === currentVal) currentMatches = true;
                } else {
                  opt.text = baseText;
                }
              });

              // Nếu bác sĩ hiện tại chưa được chọn hoặc không trùng chuyên khoa, tự động gợi ý bác sĩ chuyên khoa phù hợp
              if (!currentMatches && firstMatchedValue) {
                doctorSelect.value = firstMatchedValue;
              }

              if (filterTag) filterTag.classList.remove('d-none');
              if (filterNotice) {
                filterNotice.innerHTML = '<i class="bi bi-check-circle-fill text-success me-1"></i>' +
                  'Gợi ý <b>' + matchedCount + ' bác sĩ</b> chuyên khoa phù hợp cho: <b class="text-dark">' + serviceName + '</b>. (Bạn vẫn có thể tự do chọn bất kỳ bác sĩ nào khác bên dưới)';
                filterNotice.classList.remove('d-none');
              }

              updateDoctorPreview();
              if (currentWizardStep === 2) {
                onDoctorOrDateChange();
              }
            }

            // Khi người dùng chọn bác sĩ trong dropdown
            function onDoctorSelectChange() {
              const doctorSelect = document.getElementById('doctorSelect');
              if (!doctorSelect || !doctorSelect.value) {
                updateDoctorPreview();
                return;
              }

              const selectedOpt = doctorSelect.selectedOptions[0];
              const docDept = (selectedOpt.dataset.dept || '').toLowerCase().trim();
              const docSpecialty = (selectedOpt.dataset.specialty || '').toLowerCase().trim();

              // Tự động tìm dịch vụ tương ứng với bác sĩ này để check radio
              let matchedRadio = null;
              document.querySelectorAll('input.service-radio').forEach(r => {
                const svcDept = (r.dataset.specialty || '').toLowerCase().trim();
                if (svcDept === docDept || docSpecialty.includes(svcDept)) {
                  matchedRadio = r;
                }
              });
              if (matchedRadio && !matchedRadio.checked) {
                matchedRadio.checked = true;
                const filterNotice = document.getElementById('doctorFilterNotice');
                if (filterNotice) {
                  filterNotice.innerHTML = '<i class="bi bi-info-circle-fill text-teal me-1" style="color:#0d9488;"></i>' +
                    'Đã chọn bác sĩ: <b class="text-dark">' + (selectedOpt.dataset.name || selectedOpt.text) + '</b>. Dịch vụ tương ứng đã được tự động chọn.';
                  filterNotice.classList.remove('d-none');
                }
              }

              updateDoctorPreview();
              if (currentWizardStep === 2) {
                onDoctorOrDateChange();
              }
            }

            // Cập nhật thông tin chi tiết bác sĩ được chọn vào card xem trước
            function updateDoctorPreview() {
              const doctorSelect = document.getElementById('doctorSelect');
              const previewCard = document.getElementById('doctorPreviewCard');
              if (!doctorSelect || !previewCard) return;

              const selectedOpt = doctorSelect.selectedOptions[0];
              if (!selectedOpt || !selectedOpt.value) {
                previewCard.classList.add('d-none');
                return;
              }

              const docName = selectedOpt.dataset.name || selectedOpt.text;
              const docSpecialty = selectedOpt.dataset.specialty || '';
              const docRoom = selectedOpt.dataset.room || 'Phòng khám chuyên khoa';
              const docAvatar = selectedOpt.dataset.avatar || '${pageContext.request.contextPath}/assets/img/doctors/doctors-1.jpg';

              document.getElementById('docPreviewName').textContent = docName;
              document.getElementById('docPreviewSpecialty').textContent = 'Chuyên khoa: ' + docSpecialty;
              document.getElementById('docPreviewRoom').textContent = 'Vị trí: ' + docRoom;
              document.getElementById('docPreviewAvatar').src = docAvatar;

              previewCard.classList.remove('d-none');
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
              if (loading) loading.classList.remove('d-none');
              if (morningSection) morningSection.classList.add('d-none');
              if (afternoonSection) afternoonSection.classList.add('d-none');
              if (noSlotsAlert) noSlotsAlert.classList.add('d-none');

              fetch('${pageContext.request.contextPath}/book-appointment?action=getSlots&doctorId=' + docId + '&date=' + dateVal)
                .then(res => res.json())
                .then(data => {
                  if (loading) loading.classList.add('d-none');
                  if (morningSlotsContainer) morningSlotsContainer.innerHTML = '';
                  if (afternoonSlotsContainer) afternoonSlotsContainer.innerHTML = '';

                  // Hiển thị badge ca làm việc
                  if (badge) {
                    if (data.shiftSummary === 'FULL') {
                      badge.innerHTML = '<span class="badge bg-success me-1">Full ngày</span> Bác sĩ trực cả ca Sáng và ca Chiều';
                    } else if (data.shiftSummary === 'MORNING') {
                      badge.innerHTML = '<span class="badge bg-warning text-dark me-1">Chỉ ca Sáng</span> Bác sĩ chỉ nhận lịch khám ca Sáng';
                    } else if (data.shiftSummary === 'AFTERNOON') {
                      badge.innerHTML = '<span class="badge bg-info text-dark me-1">Chỉ ca Chiều</span> Bác sĩ chỉ nhận lịch khám ca Chiều';
                    } else {
                      badge.innerHTML = '<span class="badge bg-secondary me-1">Nghỉ</span> Bác sĩ không có lịch trực trong ngày này';
                    }
                  }

                  if (!data.slots || data.slots.length === 0) {
                    if (noSlotsAlert) noSlotsAlert.classList.remove('d-none');
                    return;
                  }

                  let hasMorning = false;
                  let hasAfternoon = false;
                  const preselectedTime = '${appointment.timeSlot != null ? appointment.timeSlot : selectedTime}';

                  data.slots.forEach(function (s) {
                    const isMorning = (s.session === 'Morning');
                    const container = isMorning ? morningSlotsContainer : afternoonSlotsContainer;
                    if (isMorning) hasMorning = true;
                    else hasAfternoon = true;

                    const isChecked = Boolean(preselectedTime && preselectedTime.indexOf(s.startTime) === 0);
                    const slotItem = document.createElement('div');
                    slotItem.className = 'position-relative';

                    let inputHtml = '<input type="radio" class="btn-check" name="timeSlot" id="slot_' + s.id + '" '
                      + 'value="' + s.startTime + '" data-schedule-id="' + s.id + '" '
                      + 'data-time-range="' + s.startTime + ' — ' + s.endTime + '" '
                      + (s.isBooked ? 'disabled ' : ' ')
                      + (isChecked ? 'checked ' : ' ')
                      + 'onchange="onSlotSelected(this)" required>';

                    let labelHtml = '<label class="slot-btn" for="slot_' + s.id + '">'
                      + s.startTime + ' — ' + s.endTime
                      + (s.isBooked ? '<span class="badge bg-secondary ms-1 small" style="font-size:10px;">Đã kín</span>' : '')
                      + '</label>';

                    slotItem.innerHTML = inputHtml + labelHtml;
                    if (container) container.appendChild(slotItem);

                    if (isChecked) {
                      const schedInput = document.getElementById('selectedScheduleId');
                      if (schedInput) schedInput.value = s.id;
                    }
                  });

                  if (hasMorning && morningSection) morningSection.classList.remove('d-none');
                  if (hasAfternoon && afternoonSection) afternoonSection.classList.remove('d-none');

                  if (!hasMorning && !hasAfternoon && noSlotsAlert) {
                    noSlotsAlert.classList.remove('d-none');
                  }
                })
                .catch(err => {
                  console.error('Lỗi tải khung giờ:', err);
                  if (loading) loading.classList.add('d-none');
                  if (noSlotsAlert) noSlotsAlert.classList.remove('d-none');
                });
            }

            // Khi người dùng click chọn khung giờ khám
            function onSlotSelected(radio) {
              if (!radio) return;
              const schedId = radio.dataset.scheduleId;
              const timeRange = radio.dataset.timeRange || radio.value;
              const schedInput = document.getElementById('selectedScheduleId');
              if (schedInput && schedId) {
                schedInput.value = schedId;
              }
              const recapTime = document.getElementById('recapTimeSlot');
              if (recapTime) {
                recapTime.textContent = timeRange;
              }
            }

            // Tự động khởi tạo khi tải trang
            document.addEventListener('DOMContentLoaded', function () {
              const docSelect = document.getElementById('doctorSelect');
              const checkedSvc = document.querySelector('input[name="serviceId"]:checked');

              // Nếu có selectedDoctorId từ trang trước (ví dụ: nhấn nút "Đặt lịch" ở card bác sĩ trên HomePage)
              const initialDocId = '${selectedDoctorId}';
              if (initialDocId && docSelect) {
                docSelect.value = initialDocId;
                onDoctorSelectChange();
              } else if (checkedSvc) {
                filterDoctorsByService(checkedSvc);
              } else {
                updateDoctorPreview();
              }

              // Tự động kiểm tra trạng thái thanh toán PayOS (Auto Polling)
              <c:if test="${step == 'payment'}">
                const currentApptId = '${appointmentId != null ? appointmentId : appointment.id}';
                let pollAttempts = 0;
                if (currentApptId) {
                  const checkInterval = setInterval(function () {
                    pollAttempts++;
                    if (pollAttempts > 180) { // Quá 15 phút thì dừng polling
                      clearInterval(checkInterval);
                      return;
                    }
                    fetch('${pageContext.request.contextPath}/book-appointment?action=checkPayment&appointmentId=' + currentApptId)
                      .then(res => res.json())
                      .then(data => {
                        if (data && data.isPaid) {
                          clearInterval(checkInterval);
                          // Tự động chuyển thẳng sang màn hình thành công!
                          window.location.href = '${pageContext.request.contextPath}/book-appointment?step=success&id=' + currentApptId;
                        }
                      })
                      .catch(err => console.log('Checking payment...', err));
                  }, 2500); // Mỗi 2.5 giây kiểm tra 1 lần
                }
              </c:if>
            });
          </script>