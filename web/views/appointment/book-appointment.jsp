<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
    <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

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

          .booking-cat-btn {
            border: 1.5px solid #cbd5e1;
            background: #ffffff;
            color: #475569;
            border-radius: 50px;
            padding: 6px 16px;
            font-weight: 600;
            font-size: 13px;
            transition: all 0.2s ease;
            cursor: pointer;
          }

          .booking-cat-btn:hover {
            border-color: #0d9488;
            color: #0d9488;
            background: #f0fdfa;
          }

          .booking-cat-btn.active {
            background: #0d9488 !important;
            border-color: #0d9488 !important;
            color: #ffffff !important;
            box-shadow: 0 2px 8px rgba(13, 148, 136, 0.25);
          }

          .booking-service-col {
            transition: all 0.25s ease;
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
                                          <span class="text-muted">
                                            <c:choose>
                                              <c:when test="${appointment.balanceDue > 0}">Tiền cọc giữ chỗ đã thanh toán:</c:when>
                                              <c:otherwise>Chi phí dịch vụ đã thanh toán:</c:otherwise>
                                            </c:choose>
                                          </span>
                                          <strong class="text-success fs-5">
                                            <fmt:formatNumber value="${appointment.fee}" type="number"
                                              groupingUsed="true" /> ₫
                                          </strong>
                                        </div>
                                        <c:if test="${appointment.balanceDue > 0}">
                                          <div class="d-flex justify-content-between mt-2 pt-2 border-top">
                                            <span class="text-muted small">Tổng chi phí gói dịch vụ:</span>
                                            <span class="text-dark small fw-semibold">
                                              <fmt:formatNumber value="${appointment.totalAmount}" type="number" groupingUsed="true" /> ₫
                                            </span>
                                          </div>
                                          <div class="d-flex justify-content-between mt-1 text-danger small">
                                            <span>Số tiền còn lại (thanh toán sau khám tại quầy):</span>
                                            <strong>
                                              <fmt:formatNumber value="${appointment.balanceDue}" type="number" groupingUsed="true" /> ₫
                                            </strong>
                                          </div>
                                        </c:if>
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
                                    <a href="${pageContext.request.contextPath}/views/profile/appointment-history.jsp"
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

                                            <%-- ĐỒNG HỒ ĐẾM NGƯỢC THỜI HẠN THANH TOÁN (COUNTDOWN TIMER) --%>
                                            <div class="mt-3 p-3 rounded-4 border bg-white shadow-sm text-start" id="paymentCountdownCard">
                                              <div class="d-flex align-items-center justify-content-between mb-2">
                                                <span class="text-muted small fw-semibold">
                                                  <i class="bi bi-stopwatch text-danger me-1"></i>Thời gian giữ chỗ:
                                                </span>
                                                <span class="fs-5 fw-bold text-danger font-monospace" id="paymentCountdownTimer">15:00</span>
                                              </div>
                                              <div class="progress" style="height: 6px; border-radius: 6px; background-color: #f1f5f9;">
                                                <div id="countdownProgressBar" class="progress-bar progress-bar-striped progress-bar-animated bg-danger"
                                                  role="progressbar" style="width: 100%; transition: width 1s linear;"></div>
                                              </div>
                                              <div class="d-flex justify-content-between align-items-center mt-2">
                                                <small class="text-muted" style="font-size: 11px;">
                                                  <i class="bi bi-shield-lock me-1 text-teal" style="color: #0d9488;"></i>Đang giữ chỗ lịch hẹn
                                                </small>
                                                <small class="text-danger fw-semibold" style="font-size: 11px;" id="countdownStatusText">
                                                  Còn hiệu lực
                                                </small>
                                              </div>
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

                                              <div class="col-6 text-muted">Thời hạn thanh toán:</div>
                                              <div class="col-6 fw-bold text-end">
                                                <span class="badge bg-danger bg-opacity-10 text-danger border border-danger-subtle font-monospace px-2 py-1" id="ticketCountdownBadge">
                                                  <i class="bi bi-stopwatch me-1"></i>15:00
                                                </span>
                                              </div>


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

                                              <div class="col-6 fs-6 text-dark fw-bold mt-2">
                                                <c:choose>
                                                  <c:when test="${appointment.balanceDue > 0}">Tiền cọc cần thanh toán:</c:when>
                                                  <c:otherwise>Tổng phí khám cần thanh toán:</c:otherwise>
                                                </c:choose>
                                              </div>
                                              <div class="col-6 fs-5 fw-bold text-success text-end mt-2">
                                                <fmt:formatNumber value="${fee}" type="number" groupingUsed="true" /> ₫
                                              </div>
                                              <c:if test="${appointment.balanceDue > 0}">
                                                <div class="col-6 text-muted small">Tổng giá gói dịch vụ:</div>
                                                <div class="col-6 text-muted small text-end fw-semibold">
                                                  <fmt:formatNumber value="${appointment.totalAmount}" type="number" groupingUsed="true" /> ₫
                                                </div>
                                                <div class="col-6 text-danger small">Số tiền còn lại (thanh toán tại phòng khám):</div>
                                                <div class="col-6 text-danger small text-end fw-bold">
                                                  <fmt:formatNumber value="${appointment.balanceDue}" type="number" groupingUsed="true" /> ₫
                                                </div>
                                              </c:if>
                                              <c:if test="${fn:contains(appointment.serviceName, 'tiền phẫu') or fn:contains(appointment.serviceName, 'tầm soát')}">
                                                <div class="col-12 mt-2">
                                                  <div class="alert alert-success py-2 px-3 small rounded-3 mb-0 text-start">
                                                    <i class="bi bi-gift-fill me-1"></i> <b>Chính sách ưu đãi:</b> 100% phí khám tiền phẫu này sẽ được <b>khấu trừ trực tiếp vào chi phí ca mổ</b> nếu quý khách đủ điều kiện và tiến hành phẫu thuật tại VisionCare.
                                                  </div>
                                                </div>
                                              </c:if>
                                            </div>
                                          </div>

                                          <div id="paymentActionArea">
                                            <form method="post"
                                              action="${pageContext.request.contextPath}/book-appointment">
                                              <input type="hidden" name="action" value="confirmPayment">
                                              <input type="hidden" name="appointmentId" value="${appointment.id}">
                                              <input type="hidden" name="orderCode" value="${orderCode}">
                                              <input type="hidden" name="email" value="${appointment.email}">

                                              <div class="d-grid gap-2">
                                                <div class="alert alert-info py-2 px-3 small rounded-3 mb-2 d-flex align-items-center">
                                                  <div class="spinner-grow spinner-grow-sm text-info me-2" role="status"></div>
                                                  <span>Hệ thống tự động kiểm tra biến động số dư. Trang sẽ <b>tự động chuyển sang Thành công</b> ngay khi hoàn tất chuyển khoản!</span>
                                                </div>
                                                <button type="submit"
                                                  class="btn btn-success btn-lg py-3 rounded-3 shadow-sm fw-bold">
                                                  <i class="bi bi-shield-check me-2"></i>Tôi đã chuyển khoản (Kiểm tra thanh toán)
                                                </button>
                                                <a href="${pageContext.request.contextPath}/book-appointment"
                                                  class="btn btn-link text-muted text-center mt-2">
                                                  <i class="bi bi-arrow-left me-1"></i>Hủy và chọn lại lịch khác
                                                </a>
                                              </div>
                                            </form>
                                          </div>

                                          <div id="paymentExpiredArea" class="d-none text-center">
                                            <div class="alert alert-danger rounded-4 p-4 shadow-sm mb-3">
                                              <i class="bi bi-exclamation-octagon-fill text-danger fs-1 d-block mb-2"></i>
                                              <h5 class="fw-bold text-danger mb-1">Mã QR đã hết hạn thanh toán (Quá 15 phút)</h5>
                                              <p class="text-muted small mb-0">
                                                Khung giờ này đã tạm hết thời gian giữ chỗ ưu tiên. Quý khách vui lòng tạo lại lịch hẹn mới để hoàn tất đặt chỗ.
                                              </p>
                                            </div>
                                            <a href="${pageContext.request.contextPath}/book-appointment" class="btn btn-primary btn-lg py-3 rounded-pill shadow-sm fw-bold w-100" style="background:#0d9488; border-color:#0d9488;">
                                              <i class="bi bi-arrow-repeat me-2"></i>Đặt lại lịch hẹn mới
                                            </a>
                                          </div>
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
                                                      <div class="booking-category-bar mb-3 p-3 bg-light rounded-4 border">
                                                        <div class="d-flex align-items-center justify-content-between mb-2 flex-wrap gap-2">
                                                          <span class="text-dark small fw-bold">
                                                            <i class="bi bi-funnel-fill text-teal me-1" style="color: #0d9488;"></i> Phân loại dịch vụ thăm khám:
                                                          </span>
                                                          <span class="badge bg-white text-secondary border small">
                                                            <i class="bi bi-layers me-1"></i>${fn:length(services)} gói dịch vụ
                                                          </span>
                                                        </div>
                                                        <div class="d-flex flex-wrap gap-2" id="bookingCategoryButtons">
                                                          <button type="button" class="btn booking-cat-btn active" data-bgroup="all" onclick="filterBookingCategory('all', this)">
                                                            <i class="bi bi-grid-fill me-1"></i> Tất cả
                                                          </button>
                                                          <button type="button" class="btn booking-cat-btn" data-bgroup="kham_khucxa" onclick="filterBookingCategory('kham_khucxa', this)">
                                                            <i class="bi bi-eye-fill me-1"></i> Khám &amp; Khúc xạ
                                                          </button>
                                                          <button type="button" class="btn booking-cat-btn" data-bgroup="tienphau_tamsoat" onclick="filterBookingCategory('tienphau_tamsoat', this)">
                                                            <i class="bi bi-shield-check me-1"></i> Tiền phẫu &amp; Tầm soát
                                                          </button>
                                                          <button type="button" class="btn booking-cat-btn" data-bgroup="treem" onclick="filterBookingCategory('treem', this)">
                                                            <i class="bi bi-heart-pulse-fill me-1"></i> Mắt trẻ em
                                                          </button>
                                                          <button type="button" class="btn booking-cat-btn" data-bgroup="thuthuat" onclick="filterBookingCategory('thuthuat', this)">
                                                            <i class="bi bi-bandaid-fill me-1"></i> Thủ thuật ngoại trú
                                                          </button>
                                                        </div>
                                                      </div>

                                                      <div class="row g-3 mb-4" id="bookingServicesGrid">
                                                        <c:forEach var="svc" items="${services}" varStatus="status">
                                                          <c:set var="bGroup" value="kham_khucxa" />
                                                          <c:set var="bGroupLabel" value="Khám & Khúc xạ" />
                                                          <c:set var="bBadgeStyle" value="background: #ccfbf1; color: #0f766e; border: 1px solid #99f6e4;" />
                                                          <c:choose>
                                                            <c:when test="${svc.specialty == 'children' or fn:contains(svc.code, 'PE')}">
                                                              <c:set var="bGroup" value="treem" />
                                                              <c:set var="bGroupLabel" value="Mắt trẻ em" />
                                                              <c:set var="bBadgeStyle" value="background: #fce7f3; color: #be185d; border: 1px solid #fbcfe8;" />
                                                            </c:when>
                                                            <c:when test="${svc.specialty == 'lasik' or svc.specialty == 'cataract' or svc.code == 'LS-03' or svc.code == 'TT-05' or svc.code == 'GL-06' or svc.code == 'OCT-DM' or svc.code == 'KM-DM'}">
                                                              <c:set var="bGroup" value="tienphau_tamsoat" />
                                                              <c:set var="bGroupLabel" value="Tiền phẫu & Tầm soát" />
                                                              <c:set var="bBadgeStyle" value="background: #e0e7ff; color: #4338ca; border: 1px solid #c7d2fe;" />
                                                            </c:when>
                                                            <c:when test="${fn:startsWith(svc.code, 'TP-')}">
                                                              <c:set var="bGroup" value="thuthuat" />
                                                              <c:set var="bGroupLabel" value="Thủ thuật" />
                                                              <c:set var="bBadgeStyle" value="background: #ffedd5; color: #c2410c; border: 1px solid #fed7aa;" />
                                                            </c:when>
                                                            <c:otherwise>
                                                              <c:set var="bGroup" value="kham_khucxa" />
                                                              <c:set var="bGroupLabel" value="Khám & Khúc xạ" />
                                                              <c:set var="bBadgeStyle" value="background: #ccfbf1; color: #0f766e; border: 1px solid #99f6e4;" />
                                                            </c:otherwise>
                                                          </c:choose>

                                                          <div class="col-md-6 col-lg-4 booking-service-col" data-bgroup="${bGroup}">
                                                            <label class="d-block h-100 mb-0">
                                                              <input type="radio" class="d-none service-radio"
                                                                name="serviceId" value="${svc.id}"
                                                                data-code="${svc.code}"
                                                                data-specialty="${svc.specialty}"
                                                                data-bgroup="${bGroup}"
                                                                data-name="${svc.name}" data-price="${svc.price}"
                                                                onchange="filterDoctorsByService(this)"
                                                                onclick="filterDoctorsByService(this)"
                                                                ${(selectedServiceId==svc.id or (empty selectedServiceId
                                                                and status.first)) ? 'checked' : '' }>
                                                              <div
                                                                class="service-card d-flex flex-column justify-content-between">
                                                                <div>
                                                                  <div
                                                                    class="d-flex justify-content-between align-items-start mb-2">
                                                                    <div class="d-flex align-items-center gap-1 flex-wrap">
                                                                      <span class="badge rounded-pill small" style="${bBadgeStyle}; font-size: 11px;">
                                                                        ${bGroupLabel}
                                                                      </span>
                                                                    </div>
                                                                    <span class="text-teal fw-bold"
                                                                      style="color: #0d9488;">
                                                                      <fmt:formatNumber value="${svc.price}"
                                                                        type="number" groupingUsed="true" /> ₫
                                                                    </span>
                                                                  </div>
                                                                  <h6 class="fw-bold text-dark mb-1">${svc.name}</h6>
                                                                  <c:if test="${bGroup == 'thuthuat'}">
                                                                    <div class="mb-1">
                                                                      <span class="badge bg-warning-subtle text-dark border border-warning-subtle rounded-pill" style="font-size: 10px;">
                                                                        <i class="bi bi-shield-exclamation text-warning me-1"></i>Bác sĩ khám trước khi làm thủ thuật
                                                                      </span>
                                                                    </div>
                                                                  </c:if>
                                                                  <c:if test="${svc.code == 'LS-03' or svc.code == 'TT-05' or fn:contains(svc.name, 'tiền phẫu') or fn:contains(svc.name, 'tầm soát')}">
                                                                    <div class="mb-1">
                                                                      <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill" style="font-size: 10.5px;">
                                                                        <i class="bi bi-gift-fill me-1"></i>Trừ 100% vào chi phí mổ
                                                                      </span>
                                                                    </div>
                                                                  </c:if>
                                                                  <div class="service-desc-box mb-1">
                                                                    <p class="text-secondary small mb-0 lh-base" style="font-size: 12px;">
                                                                      ${svc.summary != null ? svc.summary : 'Dịch vụ khám nhãn khoa chất lượng cao với trang thiết bị chuẩn quốc tế.'}
                                                                    </p>
                                                                    <c:if test="${not empty svc.description and svc.description != svc.summary}">
                                                                      <p class="text-muted small mb-0 mt-1 lh-sm" style="font-size: 11.5px; opacity: 0.9;">
                                                                        <i class="bi bi-info-circle text-teal me-1" style="color: #0d9488;"></i>${svc.description}
                                                                      </p>
                                                                    </c:if>
                                                                  </div>
                                                                </div>
                                                                <div class="d-flex justify-content-between align-items-center mt-2 pt-2 border-top">
                                                                  <button type="button" class="btn btn-sm btn-link text-decoration-none text-muted p-0"
                                                                    style="font-size: 11.5px;"
                                                                    data-bs-toggle="modal" data-bs-target="#bookingServiceModal${svc.id}"
                                                                    onclick="event.stopPropagation();">
                                                                    <i class="bi bi-info-circle me-1 text-primary"></i>Chi tiết quy trình
                                                                  </button>
                                                                  <span class="text-teal small fw-semibold" style="font-size: 11px;">
                                                                    Chọn gói <i class="bi bi-chevron-right"></i>
                                                                  </span>
                                                                </div>
                                                              </div>
                                                            </label>
                                                          </div>
                                                        </c:forEach>
                                                      </div>

                                                      <%-- HỘP CẢNH BÁO LƯU Ý QUY TRÌNH Y KHOA NĂNG ĐỘNG --%>
                                                      <div id="serviceProtocolAlertBox" class="mb-3" style="display: none;"></div>

                                                      <%-- MODALS CHI TIẾT DỊCH VỤ TRONG MÀN HÌNH BOOKING --%>
                                                      <c:forEach var="svc" items="${services}">
                                                        <div class="modal fade" id="bookingServiceModal${svc.id}" tabindex="-1" aria-hidden="true">
                                                          <div class="modal-dialog modal-dialog-centered">
                                                            <div class="modal-content rounded-4 border-0 shadow">
                                                              <div class="modal-header border-bottom-0 pb-0 pt-4 px-4">
                                                                <div class="d-flex align-items-center gap-2 flex-wrap">
                                                                  <span class="badge bg-dark bg-opacity-75 rounded-pill px-2 py-1 small">${svc.code != null ? svc.code : 'DV'}</span>
                                                                  <span class="badge rounded-pill px-3 py-1 small fw-semibold" style="color: #0d9488; background: #ccfbf1; border: 1px solid #99f6e4;">
                                                                    ${svc.category}
                                                                  </span>
                                                                </div>
                                                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                              </div>
                                                              <div class="modal-body pt-2 px-4 pb-3">
                                                                <h5 class="fw-bold text-dark mt-2 mb-2">${svc.name}</h5>
                                                                <div class="d-flex align-items-center justify-content-between p-3 rounded-3 mb-3" style="background: #f8fafc; border: 1px solid #e2e8f0;">
                                                                  <span class="text-muted small">Chi phí dịch vụ:</span>
                                                                  <span class="fs-5 fw-bold text-teal" style="color: #0d9488;">
                                                                    <fmt:formatNumber value="${svc.price}" type="number" groupingUsed="true" /> ₫
                                                                  </span>
                                                                </div>
                                                                <c:if test="${not empty svc.summary}">
                                                                  <p class="text-secondary small fw-semibold mb-2">${svc.summary}</p>
                                                                </c:if>
                                                                <c:if test="${not empty svc.description}">
                                                                  <p class="text-muted small mb-3">${svc.description}</p>
                                                                </c:if>

                                                                <c:choose>
                                                                  <c:when test="${svc.surgery}">
                                                                    <div class="alert alert-warning border border-warning rounded-4 p-3 mb-0 shadow-sm" style="background: #fffbeb;">
                                                                      <div class="d-flex align-items-start">
                                                                        <i class="bi bi-exclamation-triangle-fill fs-4 text-warning me-3 flex-shrink-0 mt-1"></i>
                                                                        <div>
                                                                          <h6 class="fw-bold text-dark mb-1">⚠️ LƯU Ý BẮT BUỘC: PHẢI KHÁM TIỀN PHẪU TRƯỚC</h6>
                                                                          <p class="small text-secondary mb-0">
                                                                            Theo quy chuẩn y khoa, bệnh nhân <strong>bắt buộc phải thực hiện gói Khám tiền phẫu chuyên sâu trước</strong> để Bác sĩ đo đạc các chỉ số giác mạc/đáy mắt và kết luận mắt có đủ điều kiện phẫu thuật hay không. Sau khi có chỉ định chính thức từ Bác sĩ, bệnh viện mới xếp lịch mổ.
                                                                          </p>
                                                                        </div>
                                                                      </div>
                                                                    </div>
                                                                  </c:when>
                                                                  <c:when test="${svc.procedure}">
                                                                    <div class="alert alert-info border border-info rounded-4 p-3 mb-0 shadow-sm" style="background: #f0fdfa; border-color: #99f6e4 !important;">
                                                                      <div class="d-flex align-items-start">
                                                                        <i class="bi bi-shield-exclamation fs-4 text-teal me-3 flex-shrink-0 mt-1" style="color: #0d9488;"></i>
                                                                        <div>
                                                                          <h6 class="fw-bold text-dark mb-1">⚠️ LƯU Ý QUY TRÌNH THỦ THUẬT: BẮT BUỘC KHÁM TRƯỚC</h6>
                                                                          <p class="small text-secondary mb-0">
                                                                            Đối với thủ thuật / tiểu phẫu (như chích chắp lẹo, bơm thông lệ đạo...), bệnh nhân <strong>vẫn bắt buộc phải qua bước Thăm khám lâm sàng trực tiếp với Bác sĩ chuyên khoa trước</strong> để Bác sĩ dùng đèn sinh hiển vi đánh giá chính xác giai đoạn viêm nhiễm và chỉ định can thiệp an toàn, vô trùng nhất.
                                                                          </p>
                                                                        </div>
                                                                      </div>
                                                                    </div>
                                                                  </c:when>
                                                                  <c:when test="${svc.preOp}">
                                                                    <div class="alert alert-success border border-success rounded-4 p-3 mb-0 shadow-sm" style="background: #f0fdf4;">
                                                                      <div class="d-flex align-items-start">
                                                                        <i class="bi bi-gift-fill fs-4 text-success me-3 flex-shrink-0 mt-1"></i>
                                                                        <div>
                                                                          <h6 class="fw-bold text-success mb-1">ĐẶC QUYỀN: HOÀN TRỪ 100% PHÍ KHÁM</h6>
                                                                          <p class="small text-secondary mb-0">
                                                                            Toàn bộ chi phí của gói khám tiền phẫu này sẽ được khấu trừ 100% vào chi phí ca mổ nếu quý khách phẫu thuật tại VisionCare.
                                                                          </p>
                                                                        </div>
                                                                      </div>
                                                                    </div>
                                                                  </c:when>
                                                                </c:choose>
                                                              </div>
                                                              <div class="modal-footer border-top-0 pt-0 px-4 pb-4 d-flex justify-content-between">
                                                                <button type="button" class="btn btn-outline-secondary rounded-pill px-4 btn-sm" data-bs-dismiss="modal">Đóng</button>
                                                                <button type="button" class="btn btn-dental rounded-pill px-4 btn-sm shadow-sm" data-bs-dismiss="modal" onclick="selectServiceFromModal(${svc.id})">
                                                                  <i class="bi bi-check2-circle me-1"></i>Chọn gói dịch vụ này
                                                                </button>
                                                              </div>
                                                            </div>
                                                          </div>
                                                        </div>
                                                      </c:forEach>


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

                                                                    <div class="card bg-light border rounded-3 p-3 mb-3">
                                                                      <div class="d-flex flex-wrap justify-content-between align-items-center gap-2">
                                                                        <div class="d-flex align-items-center">
                                                                          <i class="bi bi-person-circle fs-4 me-2 text-primary" style="color: #0d9488 !important;"></i>
                                                                          <div>
                                                                            <div class="fw-bold text-dark small" id="bookingProfileTitle">
                                                                              <c:choose>
                                                                                <c:when test="${not empty loggedUser}">Tài khoản đặt lịch: ${loggedUser.fullName}</c:when>
                                                                                <c:otherwise>Thông tin người đặt lịch khám</c:otherwise>
                                                                              </c:choose>
                                                                            </div>
                                                                            <div class="text-muted small" id="bookingForNotice">
                                                                              <c:choose>
                                                                                <c:when test="${not empty loggedUser}">Hệ thống đã tự động điền thông tin của bạn. Nhấn "Đăng ký cho người khác" nếu bạn đặt lịch cho người thân.</c:when>
                                                                                <c:otherwise>Vui lòng điền thông tin chính xác của người đi khám.</c:otherwise>
                                                                              </c:choose>
                                                                            </div>
                                                                          </div>
                                                                        </div>
                                                                        <div class="d-flex align-items-center gap-2">
                                                                          <button type="button" class="btn btn-sm btn-outline-primary fw-semibold rounded-pill px-3 shadow-sm" id="btnBookForOther" onclick="setBookingForOther()" style="border-color:#0d9488; color:#0d9488;">
                                                                            <i class="bi bi-person-plus-fill me-1"></i> Đăng ký cho người khác
                                                                          </button>
                                                                          <button type="button" class="btn btn-sm btn-primary fw-semibold rounded-pill px-3 shadow-sm" id="btnBookForSelf" onclick="refillMyInfo()" style="display:none; background:#0d9488; border-color:#0d9488;">
                                                                            <i class="bi bi-person-check-fill me-1"></i> Đặt cho bản thân
                                                                          </button>
                                                                          <button type="button" class="btn btn-sm btn-outline-secondary fw-semibold rounded-pill px-3 shadow-sm" onclick="clearPatientForm()" title="Xóa toàn bộ ô nhập để điền lại từ đầu">
                                                                            <i class="bi bi-arrow-counterclockwise me-1"></i> Điền lại thông tin
                                                                          </button>
                                                                        </div>
                                                                      </div>
                                                                    </div>

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
                                                                            <span class="text-muted small d-block" id="feeLabelText">Chi phí dịch vụ (Thanh toán giữ chỗ):</span>
                                                                            <div class="d-flex align-items-baseline gap-2">
                                                                              <strong class="fs-4 text-teal"
                                                                                style="color: #0d9488;" id="feeDisplayAmount">-- ₫</strong>
                                                                              <span
                                                                                class="badge bg-success bg-opacity-10 text-success border border-success" id="feeBadgeText">Thanh toán giữ chỗ lịch hẹn 100%</span>
                                                                            </div>
                                                                            <div id="feeRemainingNotice" class="text-muted small mt-1" style="display: none;"></div>
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
                updateFeeDisplay();
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
              updateFeeDisplay();
              const specialtyCode = (radioElement.dataset.specialty || '').toLowerCase().trim();
              const bgroup = (radioElement.dataset.bgroup || '').toLowerCase().trim();
              const serviceName = radioElement.dataset.name || 'Dịch vụ đã chọn';
              const doctorSelect = document.getElementById('doctorSelect');
              if (!doctorSelect) return;

              const filterTag = document.getElementById('doctorFilterTag');
              const filterNotice = document.getElementById('doctorFilterNotice');

              let matchedCount = 0;
              let firstMatchedValue = '';
              const currentVal = doctorSelect.value;

              Array.from(doctorSelect.options).forEach(opt => {
                if (!opt.value) return; // Bỏ qua placeholder
                const docDept = (opt.dataset.dept || '').toLowerCase().trim();
                const docSpecialty = (opt.dataset.specialty || '').toLowerCase().trim();

                let isMatch = false;
                if (bgroup === 'thuthuat' || specialtyCode === 'thuthuat') {
                  // Với Thủ thuật / Tiểu phẫu: Bắt buộc khám lâm sàng ban đầu -> chỉ định Bác sĩ khám mắt tổng quát
                  if (docDept === 'general' || docSpecialty.includes('tổng quát')) {
                    isMatch = true;
                  }
                } else if (!specialtyCode || specialtyCode === 'all') {
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
                  opt.text = (bgroup === 'thuthuat' ? '★ [Bác sĩ khám lâm sàng chỉ định] ' : '★ [Đúng chuyên khoa] ') + baseText;
                  matchedCount++;
                  if (!firstMatchedValue) firstMatchedValue = opt.value;
                } else {
                  opt.text = baseText;
                }
              });

              // Khi ấn vào dịch vụ: luôn tự động chỉ định và chọn ngay bác sĩ chuyên khoa phù hợp nhất
              if (!firstMatchedValue) {
                const defaultDoc = Array.from(doctorSelect.options).find(opt => opt.value && (opt.dataset.dept === 'general' || (opt.dataset.specialty || '').toLowerCase().includes('tổng quát')));
                if (defaultDoc) firstMatchedValue = defaultDoc.value;
                else if (doctorSelect.options.length > 1) firstMatchedValue = doctorSelect.options[1].value;
              }
              if (firstMatchedValue) {
                doctorSelect.value = firstMatchedValue;
              }

              const selectedDocOpt = doctorSelect.selectedOptions[0];
              const assignedDocName = selectedDocOpt ? (selectedDocOpt.dataset.name || selectedDocOpt.text) : '';

              if (filterTag) filterTag.classList.remove('d-none');
              if (filterNotice) {
                if (bgroup === 'thuthuat') {
                  filterNotice.innerHTML = '<i class="bi bi-shield-check text-primary me-1"></i>' +
                    'Thủ thuật cần khám lâm sàng trước: Đã tự động chỉ định <b>Bác sĩ khám mắt tổng quát (' + assignedDocName + ')</b> tiếp nhận cho gói: <b class="text-dark">' + serviceName + '</b>.';
                } else {
                  filterNotice.innerHTML = '<i class="bi bi-check-circle-fill text-success me-1"></i>' +
                    'Đã tự động chỉ định bác sĩ chuyên khoa: <b class="text-teal" style="color:#0d9488;">' + assignedDocName + '</b> cho dịch vụ: <b class="text-dark">' + serviceName + '</b>. (Bạn vẫn có thể tự do chọn bác sĩ khác trong danh sách bên dưới)';
                }
                filterNotice.classList.remove('d-none');
              }

              updateDoctorPreview();

              // Cập nhật Banner cảnh báo quy trình y khoa cho dịch vụ đang chọn (tái sử dụng bgroup, không khai báo lại const)
              const protocolBox = document.getElementById('serviceProtocolAlertBox');
              if (protocolBox) {
                if (bgroup === 'thuthuat') {
                  protocolBox.style.display = 'block';
                  protocolBox.innerHTML =
                    '<div class="alert alert-warning border border-warning rounded-4 p-3 shadow-sm" style="background:#fffbeb;">' +
                      '<div class="d-flex align-items-start">' +
                        '<i class="bi bi-shield-exclamation fs-3 text-warning me-3 flex-shrink-0 mt-1"></i>' +
                        '<div>' +
                          '<h6 class="fw-bold text-dark mb-1">⚠️ LƯU Ý QUY TRÌNH THỦ THUẬT / TIỂU PHẪU: BẮT BUỘC KHÁM TRƯỚC</h6>' +
                          '<p class="small text-secondary mb-0">' +
                            'Đối với dịch vụ thủ thuật / tiểu phẫu (như chích chắp lẹo, bơm thông lệ đạo...), bệnh nhân <strong>bắt buộc phải qua bước Thăm khám lâm sàng trực tiếp với Bác sĩ chuyên khoa trước</strong>. Bác sĩ sẽ dùng đèn sinh hiển vi đánh giá chính xác mức độ tổn thương, giai đoạn viêm và chỉ định thời điểm làm thủ thuật an toàn, vô trùng nhất. Vui lòng chọn Bác sĩ tiếp nhận bên dưới để đặt lịch khám.' +
                          '</p>' +
                        '</div>' +
                      '</div>' +
                    '</div>';
                } else if (bgroup === 'tienphau_tamsoat') {
                  protocolBox.style.display = 'block';
                  protocolBox.innerHTML =
                    '<div class="alert alert-info border border-teal rounded-4 p-3 shadow-sm" style="background:#f0fdfa; border-color:#99f6e4 !important;">' +
                      '<div class="d-flex align-items-start">' +
                        '<i class="bi bi-shield-check fs-3 text-teal me-3 flex-shrink-0 mt-1" style="color:#0d9488;"></i>' +
                        '<div>' +
                          '<h6 class="fw-bold text-dark mb-1">🔬 QUY TRÌNH KHÁM TIỀN PHẪU / TẦM SOÁT ĐIỀU KIỆN MỔ:</h6>' +
                          '<p class="small text-secondary mb-0">' +
                            'Khám tiền phẫu chuyên sâu là bước điều kiện tiên quyết để xác nhận mắt có đủ tiêu chuẩn phẫu thuật xóa cận / thay thủy tinh thể hay không. Toàn bộ chi phí khám sẽ được <strong>hoàn trừ 100%</strong> vào giá gói phẫu thuật nếu quý khách thực hiện mổ tại VisionCare.' +
                          '</p>' +
                        '</div>' +
                      '</div>' +
                    '</div>';
                } else {
                  protocolBox.style.display = 'none';
                  protocolBox.innerHTML = '';
                }
              }

              if (currentWizardStep === 2) {
                onDoctorOrDateChange();
              }
            }

            function selectServiceFromModal(serviceId) {
              const radio = document.querySelector('input.service-radio[value="' + serviceId + '"]');
              if (radio) {
                radio.checked = true;
                filterDoctorsByService(radio);
                // Highlight card
                const col = radio.closest('.booking-service-col');
                if (col) {
                  col.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
              }
            }


            // Phân loại danh mục dịch vụ trong màn hình đặt lịch
            function filterBookingCategory(group, btn) {
              document.querySelectorAll('.booking-cat-btn').forEach(b => b.classList.remove('active'));
              if (btn) {
                btn.classList.add('active');
              } else {
                const targetBtn = document.querySelector('.booking-cat-btn[data-bgroup="' + group + '"]');
                if (targetBtn) targetBtn.classList.add('active');
              }

              const cols = document.querySelectorAll('.booking-service-col');
              cols.forEach(col => {
                if (group === 'all' || col.getAttribute('data-bgroup') === group) {
                  col.style.display = '';
                } else {
                  col.style.display = 'none';
                }
              });
            }

            // Khi người dùng chọn bác sĩ trong dropdown: Giữ nguyên bệnh/dịch vụ đã chọn, không tự ý nhảy sang dịch vụ khác
            function onDoctorSelectChange() {
              const doctorSelect = document.getElementById('doctorSelect');
              if (!doctorSelect || !doctorSelect.value) {
                updateDoctorPreview();
                return;
              }

              const selectedOpt = doctorSelect.selectedOptions[0];
              const docName = selectedOpt.dataset.name || selectedOpt.text;
              const docDept = (selectedOpt.dataset.dept || '').toLowerCase().trim();
              const docSpecialty = (selectedOpt.dataset.specialty || '').toLowerCase().trim();

              const selectedRadio = document.querySelector('input.service-radio:checked');
              const svcName = selectedRadio ? (selectedRadio.dataset.name || 'Dịch vụ đã chọn') : 'Dịch vụ đã chọn';
              const selectedSpecialty = (selectedRadio?.dataset.specialty || '').toLowerCase().trim();
              const bgroup = (selectedRadio?.dataset.bgroup || '').toLowerCase().trim();

              // Kiểm tra xem bác sĩ này có đúng chuyên khoa với dịch vụ đang chọn không
              let isMatch = false;
              if (bgroup === 'thuthuat' || selectedSpecialty === 'thuthuat') {
                if (docDept === 'general' || docSpecialty.includes('tổng quát')) isMatch = true;
              } else if (!selectedSpecialty || selectedSpecialty === 'all') {
                isMatch = true;
              } else if (docDept === selectedSpecialty || docSpecialty.includes(selectedSpecialty)) {
                isMatch = true;
              } else if (selectedSpecialty === 'general' && (docDept === 'general' || docSpecialty.includes('tổng quát'))) {
                isMatch = true;
              } else if (selectedSpecialty === 'refraction' && (docDept === 'refraction' || docSpecialty.includes('khúc xạ') || docSpecialty.includes('kính'))) {
                isMatch = true;
              } else if (selectedSpecialty === 'lasik' && (docDept === 'lasik' || docSpecialty.includes('lasik') || docSpecialty.includes('phẫu thuật'))) {
                isMatch = true;
              } else if (selectedSpecialty === 'children' && (docDept === 'children' || docSpecialty.includes('trẻ em') || docSpecialty.includes('nhược thị'))) {
                isMatch = true;
              } else if (selectedSpecialty === 'cataract' && (docDept === 'cataract' || docSpecialty.includes('thủy tinh thể') || docSpecialty.includes('phaco'))) {
                isMatch = true;
              } else if (selectedSpecialty === 'retina' && (docDept === 'retina' || docSpecialty.includes('võng mạc') || docSpecialty.includes('glaucoma'))) {
                isMatch = true;
              }

              const filterNotice = document.getElementById('doctorFilterNotice');
              if (filterNotice) {
                if (isMatch) {
                  filterNotice.innerHTML = '<i class="bi bi-check-circle-fill text-success me-1"></i>' +
                    'Bác sĩ <b>' + docName + '</b> đúng chuyên khoa tiếp nhận cho gói: <b class="text-dark">' + svcName + '</b>.';
                } else {
                  filterNotice.innerHTML = '<i class="bi bi-person-check-fill text-primary me-1"></i>' +
                    'Đã chọn bác sĩ: <b>' + docName + '</b> tiếp nhận theo yêu cầu cho gói: <b class="text-dark">' + svcName + '</b>.';
                }
                filterNotice.classList.remove('d-none');
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

              const nameEl = document.getElementById('docPreviewName');
              if (nameEl) nameEl.textContent = docName;
              const specEl = document.getElementById('docPreviewSpecialty');
              if (specEl) specEl.textContent = 'Chuyên khoa: ' + docSpecialty;
              const roomEl = document.getElementById('docPreviewRoom');
              if (roomEl) roomEl.textContent = 'Vị trí: ' + docRoom;
              const avatarEl = document.getElementById('docPreviewAvatar');
              if (avatarEl) avatarEl.src = docAvatar;

              const badgeEl = document.getElementById('docMatchBadge');
              if (badgeEl) {
                const checkedRadio = document.querySelector('input.service-radio:checked');
                const bgroup = checkedRadio ? (checkedRadio.dataset.bgroup || '').toLowerCase().trim() : '';
                const svcSpec = checkedRadio ? (checkedRadio.dataset.specialty || '').toLowerCase().trim() : '';
                const docDept = (selectedOpt.dataset.dept || '').toLowerCase().trim();
                const docSpecLower = docSpecialty.toLowerCase().trim();

                let isMatch = false;
                if (bgroup === 'thuthuat' || svcSpec === 'thuthuat') {
                  if (docDept === 'general' || docSpecLower.includes('tổng quát')) isMatch = true;
                } else if (!svcSpec || svcSpec === 'all' || docDept === svcSpec || docSpecLower.includes(svcSpec)) {
                  isMatch = true;
                } else if (svcSpec === 'general' && (docDept === 'general' || docSpecLower.includes('tổng quát'))) {
                  isMatch = true;
                } else if (svcSpec === 'refraction' && (docDept === 'refraction' || docSpecLower.includes('khúc xạ') || docSpecLower.includes('kính'))) {
                  isMatch = true;
                } else if (svcSpec === 'lasik' && (docDept === 'lasik' || docSpecLower.includes('lasik') || docSpecLower.includes('phẫu thuật'))) {
                  isMatch = true;
                } else if (svcSpec === 'children' && (docDept === 'children' || docSpecLower.includes('trẻ em') || docSpecLower.includes('nhược thị'))) {
                  isMatch = true;
                } else if (svcSpec === 'cataract' && (docDept === 'cataract' || docSpecLower.includes('thủy tinh thể') || docSpecLower.includes('phaco'))) {
                  isMatch = true;
                } else if (svcSpec === 'retina' && (docDept === 'retina' || docSpecLower.includes('võng mạc') || docSpecLower.includes('glaucoma'))) {
                  isMatch = true;
                }

                if (isMatch) {
                  if (bgroup === 'thuthuat') {
                    badgeEl.className = 'badge bg-warning-subtle text-dark border border-warning-subtle rounded-pill small';
                    badgeEl.style.cssText = '';
                    badgeEl.innerHTML = '<i class="bi bi-shield-check text-warning me-1"></i>Bác sĩ khám lâm sàng chỉ định';
                  } else {
                    badgeEl.className = 'badge rounded-pill small';
                    badgeEl.style.cssText = 'background: #ccfbf1; color: #0f766e; border: 1px solid #99f6e4;';
                    badgeEl.innerHTML = '<i class="bi bi-check-circle-fill text-success me-1"></i>Bác sĩ đúng chuyên khoa';
                  }
                } else {
                  badgeEl.className = 'badge rounded-pill small';
                  badgeEl.style.cssText = 'background: #eff6ff; color: #1d4ed8; border: 1px solid #bfdbfe;';
                  badgeEl.innerHTML = '<i class="bi bi-person-check-fill text-primary me-1"></i>Bác sĩ tiếp nhận theo yêu cầu';
                }
              }

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

            // Cập nhật hiển thị phí khám động theo dịch vụ được chọn (Chi phí gói dịch vụ là phí giữ chỗ luôn)
            function updateFeeDisplay() {
              const checkedSvc = document.querySelector('input[name="serviceId"]:checked');
              if (!checkedSvc) return;
              const price = parseFloat(checkedSvc.dataset.price) || 0;
              const svcName = (checkedSvc.dataset.name || '').toLowerCase();
              const labelEl = document.getElementById('feeLabelText');
              const amountEl = document.getElementById('feeDisplayAmount');
              const badgeEl = document.getElementById('feeBadgeText');
              const noticeEl = document.getElementById('feeRemainingNotice');

              if (labelEl) labelEl.textContent = 'Chi phí dịch vụ (Thanh toán giữ chỗ):';
              if (amountEl) amountEl.textContent = price.toLocaleString('vi-VN') + ' ₫';
              if (badgeEl) {
                badgeEl.className = 'badge bg-success bg-opacity-10 text-success border border-success';
                badgeEl.textContent = 'Thanh toán giữ chỗ lịch hẹn 100%';
              }
              if (noticeEl) {
                noticeEl.style.display = 'block';
                if (svcName.includes('tiền phẫu') || svcName.includes('tầm soát')) {
                  noticeEl.className = 'text-success small mt-1';
                  noticeEl.innerHTML = '<i class="bi bi-gift-fill me-1"></i>Chi phí khám này dùng để giữ chỗ lịch hẹn và <b>được khấu trừ 100% vào chi phí ca mổ</b> nếu quý khách tiến hành phẫu thuật.';
                } else {
                  noticeEl.className = 'text-muted small mt-1';
                  noticeEl.innerHTML = '<i class="bi bi-check-circle-fill text-success me-1"></i>Chi phí dịch vụ trọn gói dùng để xác nhận và giữ chỗ khung giờ tiếp đón với bác sĩ chuyên khoa.';
                }
              }
            }

            // Xử lý chuyển đổi: Đặt cho bản thân / Đăng ký cho người khác / Điền lại thông tin
            const loggedUserProfile = {
              name: '<c:out value="${loggedUser.fullName}" default="" />',
              phone: '<c:out value="${loggedUser.phone}" default="" />',
              email: '<c:out value="${loggedUser.email}" default="" />',
              dob: '<c:out value="${loggedUser.dob}" default="" />'
            };

            function setBookingForOther() {
              document.getElementById('patientName').value = '';
              document.getElementById('patientPhone').value = '';
              document.getElementById('patientDob').value = '';
              document.getElementById('visitReason').value = '';

              const title = document.getElementById('bookingProfileTitle');
              if (title) title.innerHTML = '<span class="text-primary"><i class="bi bi-people-fill me-1"></i> Đang đăng ký cho người khác / người thân</span>';

              const notice = document.getElementById('bookingForNotice');
              if (notice) notice.innerHTML = 'Vui lòng nhập họ tên, số điện thoại và ngày sinh của người trực tiếp đi khám mắt.';

              const btnOther = document.getElementById('btnBookForOther');
              const btnSelf = document.getElementById('btnBookForSelf');
              if (btnOther) btnOther.style.display = 'none';
              if (btnSelf) btnSelf.style.display = 'inline-block';

              document.getElementById('patientName').focus();
            }

            function refillMyInfo() {
              document.getElementById('patientName').value = loggedUserProfile.name || '';
              document.getElementById('patientPhone').value = loggedUserProfile.phone || '';
              document.getElementById('patientEmail').value = loggedUserProfile.email || '';
              document.getElementById('patientDob').value = loggedUserProfile.dob || '';
              document.getElementById('visitReason').value = '';

              const title = document.getElementById('bookingProfileTitle');
              if (title) title.innerText = 'Tài khoản đặt lịch: ' + (loggedUserProfile.name || '');

              const notice = document.getElementById('bookingForNotice');
              if (notice) notice.innerText = 'Hệ thống đã tự động điền thông tin của bạn. Nhấn "Đăng ký cho người khác" nếu bạn đặt lịch cho người thân.';

              const btnOther = document.getElementById('btnBookForOther');
              const btnSelf = document.getElementById('btnBookForSelf');
              if (btnOther) btnOther.style.display = 'inline-block';
              if (btnSelf) btnSelf.style.display = 'none';
            }

            function clearPatientForm() {
              if (confirm('Bạn có muốn xóa toàn bộ thông tin người khám để nhập lại từ đầu không?')) {
                document.getElementById('patientName').value = '';
                document.getElementById('patientPhone').value = '';
                document.getElementById('patientEmail').value = '';
                document.getElementById('patientDob').value = '';
                document.getElementById('visitReason').value = '';
                document.getElementById('patientName').focus();
              }
            }

            // Tự động khởi tạo khi tải trang
            document.addEventListener('DOMContentLoaded', function () {
              updateFeeDisplay();
              const docSelect = document.getElementById('doctorSelect');
              const checkedSvc = document.querySelector('input[name="serviceId"]:checked');

              // Gắn sự kiện click trực tiếp vào từng service-card
              document.querySelectorAll('.service-card').forEach(function (card) {
                card.addEventListener('click', function (e) {
                  if (e.target.closest('[data-bs-toggle="modal"]')) return;
                  const label = card.closest('label');
                  const radio = label ? label.querySelector('input.service-radio') : null;
                  if (radio) {
                    radio.checked = true;
                    filterDoctorsByService(radio);
                  }
                });
              });

              // Nếu có selectedDoctorId từ trang trước (ví dụ: nhấn nút "Đặt lịch" ở card bác sĩ trên HomePage)
              const initialDocId = '${selectedDoctorId}';
              if (initialDocId && docSelect) {
                docSelect.value = initialDocId;
                onDoctorSelectChange();
              } else if (checkedSvc) {
                const bg = (checkedSvc.dataset.bgroup || '').toLowerCase().trim();
                if (bg && bg !== 'all') {
                  const catBtn = document.querySelector('.booking-cat-btn[data-bgroup="' + bg + '"]');
                  if (catBtn) filterBookingCategory(bg, catBtn);
                }
                filterDoctorsByService(checkedSvc);
              } else {
                updateDoctorPreview();
              }

              // Tự động kiểm tra trạng thái thanh toán PayOS (Auto Polling) & Đồng hồ đếm ngược (Countdown Timer)
              <c:if test="${step == 'payment'}">
                const currentApptId = '${appointmentId != null ? appointmentId : appointment.id}';
                let pollAttempts = 0;
                let checkInterval = null;

                // Khởi tạo thời hạn thanh toán 15 phút (900s) lưu trong sessionStorage để không bị reset khi F5
                const storageKey = 'vc_pay_expire_' + currentApptId;
                let expireTimestamp = sessionStorage.getItem(storageKey);
                const now = Date.now();
                if (!expireTimestamp || isNaN(expireTimestamp) || parseInt(expireTimestamp) < now) {
                  expireTimestamp = now + (15 * 60 * 1000); // 15 phút
                  sessionStorage.setItem(storageKey, expireTimestamp);
                } else {
                  expireTimestamp = parseInt(expireTimestamp);
                }

                function updatePaymentCountdown() {
                  const remainingMs = expireTimestamp - Date.now();
                  const remainingSec = Math.max(0, Math.floor(remainingMs / 1000));
                  const m = Math.floor(remainingSec / 60);
                  const s = remainingSec % 60;
                  const formatted = (m < 10 ? '0' : '') + m + ':' + (s < 10 ? '0' : '') + s;

                  const timerEl = document.getElementById('paymentCountdownTimer');
                  const ticketEl = document.getElementById('ticketCountdownBadge');
                  const barEl = document.getElementById('countdownProgressBar');
                  const statusEl = document.getElementById('countdownStatusText');

                  if (timerEl) timerEl.textContent = formatted;
                  if (ticketEl) ticketEl.innerHTML = '<i class="bi bi-stopwatch me-1"></i>' + formatted;

                  const percent = Math.min(100, Math.max(0, (remainingSec / 900) * 100));
                  if (barEl) barEl.style.width = percent + '%';

                  // Đổi màu trực quan theo thời gian còn lại
                  if (remainingSec <= 120) { // Dưới 2 phút: Đỏ cảnh báo khẩn
                    if (barEl) { barEl.className = 'progress-bar progress-bar-striped progress-bar-animated bg-danger'; }
                    if (timerEl) { timerEl.className = 'fs-5 fw-bold text-danger font-monospace'; }
                    if (statusEl) { statusEl.textContent = 'Sắp hết hạn!'; statusEl.className = 'text-danger fw-bold'; }
                  } else if (remainingSec <= 300) { // Dưới 5 phút: Cam chú ý
                    if (barEl) { barEl.className = 'progress-bar progress-bar-striped progress-bar-animated bg-warning'; }
                    if (timerEl) { timerEl.className = 'fs-5 fw-bold text-warning font-monospace'; }
                    if (statusEl) { statusEl.textContent = 'Hạn còn dưới 5 phút'; statusEl.className = 'text-warning fw-semibold'; }
                  } else { // Bình thường: Xanh giữ chỗ an toàn
                    if (barEl) { barEl.className = 'progress-bar progress-bar-striped progress-bar-animated'; barEl.style.backgroundColor = '#0d9488'; }
                    if (timerEl) { timerEl.className = 'fs-5 fw-bold font-monospace'; timerEl.style.color = '#0d9488'; }
                    if (statusEl) { statusEl.textContent = 'Đang có hiệu lực'; statusEl.className = 'text-muted fw-semibold'; }
                  }

                  if (remainingSec <= 0) {
                    clearInterval(countdownInterval);
                    if (checkInterval) clearInterval(checkInterval);
                    sessionStorage.removeItem(storageKey);

                    if (timerEl) timerEl.textContent = '00:00 (Hết hạn)';
                    if (statusEl) { statusEl.textContent = 'Đã hết hạn'; statusEl.className = 'text-danger fw-bold'; }
                    if (barEl) { barEl.style.width = '0%'; }

                    const actionArea = document.getElementById('paymentActionArea');
                    const expiredArea = document.getElementById('paymentExpiredArea');
                    if (actionArea) actionArea.classList.add('d-none');
                    if (expiredArea) expiredArea.classList.remove('d-none');
                  }
                }

                updatePaymentCountdown();
                const countdownInterval = setInterval(updatePaymentCountdown, 1000);

                if (currentApptId) {
                  checkInterval = setInterval(function () {
                    pollAttempts++;
                    if (pollAttempts > 360) { // Tối đa 15 phút (mỗi 2.5s)
                      clearInterval(checkInterval);
                      return;
                    }
                    fetch('${pageContext.request.contextPath}/book-appointment?action=checkPayment&appointmentId=' + currentApptId + '&orderCode=${orderCode}')
                      .then(res => res.json())
                      .then(data => {
                        if (data && data.isPaid) {
                          clearInterval(checkInterval);
                          clearInterval(countdownInterval);
                          sessionStorage.removeItem(storageKey);
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
