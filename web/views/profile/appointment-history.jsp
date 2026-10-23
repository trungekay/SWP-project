<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

    <%-- Include Header --%>
      <jsp:include page="/views/common/header.jsp">
        <jsp:param name="pageTitle" value="Lịch sử hẹn khám" />
        <jsp:param name="pageDescription" value="Lịch sử hẹn khám VisionCare" />
        <jsp:param name="bodyClass" value="starter-page-page" />
        <jsp:param name="activeNav" value="" />
      </jsp:include>

      <style>
        .profile-card {
          background: #fff;
          border-radius: 15px;
          box-shadow: 0 5px 30px rgba(0, 0, 0, 0.05);
          padding: 30px;
          margin-bottom: 30px;
        }

        .profile-avatar {
          width: 120px;
          height: 120px;
          border-radius: 50%;
          object-fit: cover;
          margin-bottom: 20px;
          border: 4px solid #e0f2fe;
        }

        .btn-custom {
          background: #0d9488;
          color: #fff;
        }

        .btn-custom:hover {
          background: #0f766e;
          color: #fff;
        }

        .nav-pills .nav-link.active {
          background-color: #0d9488;
        }

        .nav-pills .nav-link {
          color: #333;
        }

        .table th {
          font-weight: 600;
          color: #333;
          border-bottom-width: 1px;
        }

        .table td {
          vertical-align: middle;
          color: #555;
        }

        .badge-success-custom {
          background-color: #2e7d32;
          color: #fff;
          padding: 5px 10px;
          border-radius: 4px;
          font-weight: 500;
          font-size: 12px;
          white-space: nowrap;
        }

        .badge-warning-custom {
          background-color: #f59e0b;
          color: #fff;
          padding: 5px 10px;
          border-radius: 4px;
          font-weight: 500;
          font-size: 12px;
          white-space: nowrap;
        }

        .badge-danger-custom {
          background-color: #ef4444;
          color: #fff;
          padding: 5px 10px;
          border-radius: 4px;
          font-weight: 500;
          font-size: 12px;
          white-space: nowrap;
        }

        /* Admin UI Sync */
        .content-card {
          background: white;
          border-radius: 12px;
          box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
          border: 1px solid rgba(0, 0, 0, 0.05);
          overflow: hidden;
        }

        .sidebar-menu {
          padding: 0;
          list-style: none;
          margin: 0;
        }

        .sidebar-menu li {
          margin-bottom: 4px;
        }

        .sidebar-menu li a {
          display: flex;
          align-items: center;
          padding: 12px 16px;
          color: #64748b;
          text-decoration: none;
          border-radius: 8px;
          font-weight: 500;
          font-size: 14px;
          transition: all 0.2s ease;
        }

        .sidebar-menu li a i {
          margin-right: 12px;
          font-size: 18px;
          color: #94a3b8;
        }

        .sidebar-menu li a:hover {
          background-color: #f8fafc;
          color: #0f172a;
        }

        .sidebar-menu li a:hover i {
          color: #64748b;
        }

        .sidebar-menu li a.active {
          background-color: #f0f7f6;
          color: #0d9488;
          font-weight: 600;
        }

        .sidebar-menu li a.active i {
          color: #0d9488;
        }

        .sidebar-menu li a.text-danger:hover {
          background-color: #fef2f2;
          color: #ef4444 !important;
        }

        .sidebar-menu li a.text-danger i {
          color: #ef4444;
        }

        /* Form overrides */
        .form-control,
        .form-select {
          border-radius: 8px;
          border: 1px solid #e2e8f0;
          padding: 10px 16px;
          font-size: 14px;
        }

        .form-control:focus,
        .form-select:focus {
          border-color: #0d9488;
          box-shadow: 0 0 0 3px rgba(13, 148, 136, 0.1);
        }

        .btn-primary-custom {
          background-color: #0d9488;
          color: white;
          border: none;
          padding: 10px 20px;
          border-radius: 8px;
          font-weight: 500;
          font-size: 14px;
          transition: all 0.2s;
        }

        .btn-primary-custom:hover {
          background-color: #0f766e;
          color: white;
        }

        .custom-table {
          width: 100%;
          margin: 0;
          border-collapse: collapse;
        }

        .custom-table th {
          background-color: #f8fafc;
          color: #64748b;
          font-size: 12px;
          font-weight: 600;
          text-transform: uppercase;
          letter-spacing: 0.5px;
          padding: 16px 24px;
          border-bottom: 1px solid #e2e8f0;
        }

        .custom-table td {
          padding: 16px 24px;
          vertical-align: middle;
          border-bottom: 1px solid #f1f5f9;
          color: #334155;
          font-size: 14px;
        }

        .custom-table tbody tr:hover {
          background-color: #f8fafc;
        }

        .badge-status {
          padding: 6px 12px;
          border-radius: 20px;
          font-size: 12px;
          font-weight: 500;
          display: inline-block;
        }

        .btn-table-cancel {
          font-family: inherit;
          font-size: 12px;
          font-weight: 500;
          padding: 4px 10px;
          border-radius: 6px;
          line-height: 1.4;
          display: inline-flex;
          align-items: center;
          justify-content: center;
          gap: 4px;
          white-space: nowrap;
        }

        .status-active {
          background-color: #dcfce7;
          color: #166534;
        }
      </style>

      <main class="main bg-light pb-5">

        <div class="page-title">
          <div class="heading">
            <div class="container">
              <div class="row d-flex justify-content-center text-center">
                <div class="col-lg-8">
                  <h1>Hồ sơ cá nhân</h1>
                  <p class="mb-0">Quản lý thông tin cá nhân và lịch sử hẹn khám.</p>
                </div>
              </div>
            </div>
          </div>
          <nav class="breadcrumbs">
            <div class="container">
              <ol>
                <li><a href="${pageContext.request.contextPath}/home">Trang chủ</a></li>
                <li class="current">Lịch sử hẹn khám</li>
              </ol>
            </div>
          </nav>
        </div>

        <section class="section pt-4">
          <div class="container">
            <div class="row">
              <div class="col-lg-3">
                <div class="content-card text-center border-0 mb-4 mb-lg-0" style="padding: 30px 20px;">
                  <div class="mb-3">
                    <span class="badge bg-light text-dark rounded-pill border px-3 py-1">Avatar</span>
                  </div>
                  <h4 class="fw-bold" style="color: #1e293b; font-size: 18px;">${not empty sessionScope.user.fullName ?
                    sessionScope.user.fullName : 'Nguyễn Văn A'}</h4>
                  <p class="text-muted small mb-4">
                    <c:choose>
                      <c:when test="${sessionScope.user.role == 'admin'}">Super Admin</c:when>
                      <c:when test="${sessionScope.user.role == 'manager'}">Manager</c:when>
                      <c:when test="${sessionScope.user.role == 'doctor'}">Bác sĩ</c:when>
                      <c:when test="${sessionScope.user.role == 'medical_specialist'}">Bác sĩ Chuyên khoa</c:when>
                      <c:when test="${sessionScope.user.role == 'staff'}">Nhân viên</c:when>
                      <c:otherwise>Bệnh nhân</c:otherwise>
                    </c:choose>
                  </p>

                  <ul class="sidebar-menu text-start">
                    <li>
                      <a href="${pageContext.request.contextPath}/views/profile/manage.jsp" class=""><i
                          class="bi bi-person"></i> Thông tin chung</a>
                    </li>
                    <c:if test="${sessionScope.user.role == 'patient'}">
                      <li>
                        <a href="${pageContext.request.contextPath}/views/profile/appointment-history.jsp"
                          class="active"><i class="bi bi-calendar-check"></i> Lịch sử hẹn khám</a>
                      </li>
                      <li>
                        <a href="${pageContext.request.contextPath}/views/profile/medical-history.jsp" class=""><i
                            class="bi bi-journal-medical"></i> Lịch sử khám bệnh</a>
                      </li>
                      <li>
                        <a href="${pageContext.request.contextPath}/views/profile/refund-request.jsp" class=""><i
                            class="bi bi-cash-coin"></i> Yêu cầu hoàn tiền</a>
                      </li>
                    </c:if>
                    <li>
                      <a href="${pageContext.request.contextPath}/views/profile/change-password.jsp" class=""><i
                          class="bi bi-key"></i> Đổi mật khẩu</a>
                    </li>
                    <li class="mt-3 pt-3" style="border-top: 1px solid #f1f5f9;">
                      <a href="${pageContext.request.contextPath}/logout" class="text-danger"><i
                          class="bi bi-box-arrow-right"></i> Đăng xuất</a>
                    </li>
                  </ul>
                </div>
              </div>
              <div class="col-lg-9 ps-lg-5">
                <div class="pt-2">
                  <h4 class="fw-bold" style="color: #1c355e;">Lịch sử hẹn khám</h4>
                  <p class="text-muted small mb-4">Xem chi tiết các lịch hẹn khám bệnh và thực hiện yêu cầu hủy lịch</p>
                  <hr class="mb-4">

                  <c:if test="${not empty successMessage}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                      <i class="bi bi-check-circle-fill me-2"></i>${successMessage}
                      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                  </c:if>
                  <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                      <i class="bi bi-exclamation-triangle-fill me-2"></i>${errorMessage}
                      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                  </c:if>

                  <h6 class="fw-bold mb-3" style="color: #0d9488;"><i class="bi bi-calendar2-week me-2"></i>Danh sách
                    lịch hẹn</h6>
                  <div class="content-card mb-5">
                    <div class="table-responsive">
                      <table class="custom-table">
                        <thead>
                          <tr>
                            <th class="py-3">Mã lịch hẹn</th>
                            <th class="py-3">Ngày & Giờ</th>
                            <th class="py-3">Bác sĩ</th>
                            <th class="py-3">Dịch vụ</th>
                            <th class="py-3">Trạng thái</th>
                            <th class="py-3 text-center">Thao tác</th>
                          </tr>
                        </thead>
                        <tbody>
                          <c:choose>
                            <c:when test="${not empty appointments}">
                              <c:forEach var="appt" items="${appointments}">
                                <tr>
                                  <td class="py-3">#APT-${appt.id}</td>
                                  <td class="py-3">${appt.appointmentDate}<br><small
                                      class="text-muted">${appt.timeSlot}</small></td>
                                  <td class="py-3">${appt.doctorName}</td>
                                  <td class="py-3">
                                    <c:choose>
                                      <c:when test="${not empty appt.serviceName}">
                                        <span class="fw-semibold text-dark">${appt.serviceName}</span>
                                      </c:when>
                                      <c:otherwise>Khám chuyên khoa</c:otherwise>
                                    </c:choose>
                                  </td>
                                  <td class="py-3">
                                    <c:choose>
                                      <c:when test="${appt.status == 'Pending'}">
                                        <c:choose>
                                          <c:when test="${appt.cancellationRequested}">
                                            <span class="badge-status" style="background: #fef3c7; color: #b45309;"><i
                                                class="bi bi-clock-history me-1"></i>Chờ duyệt hủy</span>
                                          </c:when>
                                          <c:when test="${appt.depositPaid}">
                                            <span class="badge-status" style="background: #e0f2fe; color: #0369a1;">Đã thanh toán · Chờ xử lý</span>
                                          </c:when>
                                          <c:otherwise>
                                            <span class="badge-status" style="background: #fff7ed; color: #c2410c;"><i
                                                class="bi bi-credit-card me-1"></i>Chờ thanh toán</span>
                                          </c:otherwise>
                                        </c:choose>
                                      </c:when>
                                      <c:when test="${appt.status == 'Confirmed' && empty appt.checkinTime}">
                                        <span class="badge-status" style="background: #e0f2fe; color: #0369a1;"><i
                                            class="bi bi-check-circle me-1"></i>Đã xác nhận</span>
                                      </c:when>
                                      <c:when test="${appt.status == 'Confirmed' && not empty appt.checkinTime}"><span class="badge-status">Chờ khám</span></c:when>
                                      <c:when test="${appt.status == 'In_Progress'}">
                                        <span class="badge-status" style="background: #f3e8ff; color: #6b21a8;"><i
                                            class="bi bi-activity me-1"></i>Đang khám</span>
                                      </c:when>
                                      <c:when test="${appt.status == 'Completed'}">
                                        <span class="badge-status status-active"><i
                                            class="bi bi-check-all me-1"></i>Hoàn thành</span>
                                      </c:when>
                                      <c:when test="${appt.status == 'Canceled'}">
                                        <span class="badge-status" style="background: #fee2e2; color: #b91c1c;"><i
                                            class="bi bi-x-circle me-1"></i>Đã hủy</span>
                                        <c:if test="${not empty appt.reason}">
                                          <div class="small text-muted mt-1 text-truncate" style="font-size: 11px; max-width: 220px;" title="${appt.reason}">
                                            <i class="bi bi-info-circle me-1"></i><c:out value="${appt.reason}" />
                                          </div>
                                        </c:if>
                                      </c:when>
                                      <c:otherwise>
                                        <span class="badge-status text-muted">${appt.status}</span>
                                      </c:otherwise>
                                    </c:choose>
                                  </td>
                                  <td class="py-3 text-center">
                                    <c:choose>
                                      <c:when test="${appt.status == 'Confirmed' && empty appt.checkinTime}">
                                        <button type="button" class="btn btn-sm btn-outline-danger btn-table-cancel"
                                          onclick="openCancelModal('${appt.id}', '${appt.appointmentDate} (${appt.timeSlot})', '${appt.fee}')">
                                          <i class="bi bi-x-circle me-1"></i>Hủy lịch hẹn
                                        </button>
                                      </c:when>
                                      <c:when test="${appt.cancellationRequested}">
                                        <span
                                          class="badge bg-warning-subtle text-warning-emphasis border border-warning-subtle px-2 py-1"
                                          style="font-size: 12px; font-weight: 500; font-family: inherit;">
                                          <i class="bi bi-hourglass-split me-1"></i>Chờ nhân viên duyệt
                                        </span>
                                      </c:when>
                                      <c:when test="${appt.awaitingPayment}">
                                        <div class="d-flex justify-content-center align-items-center gap-2" id="apptActionBox_${appt.id}">
                                          <a href="${pageContext.request.contextPath}/book-appointment?step=payment&id=${appt.id}"
                                            class="btn btn-sm btn-primary countdown-pay-btn d-inline-flex align-items-center btn-table-cancel"
                                            id="payBtn_${appt.id}"
                                            data-appt-id="${appt.id}"
                                            data-remaining="${appt.remainingSeconds}"
                                            style="background: #0d9488; border-color: #0d9488; color: #fff;">
                                            <i class="bi bi-qr-code me-1"></i>Thanh toán <span class="badge bg-white text-dark ms-1 font-monospace" id="countdownBadge_${appt.id}">--:--</span>
                                          </a>
                                          <button type="button" class="btn btn-sm btn-outline-secondary btn-table-cancel"
                                            onclick="openDirectCancelModal('${appt.id}', '${appt.appointmentDate} (${appt.timeSlot})')">
                                            <i class="bi bi-x me-1"></i>Hủy
                                          </button>
                                        </div>
                                      </c:when>
                                      <c:otherwise>
                                        <span class="text-muted small">-</span>
                                      </c:otherwise>
                                    </c:choose>
                                  </td>
                                </tr>
                              </c:forEach>
                            </c:when>
                            <c:otherwise>
                              <tr>
                                <td colspan="6" class="text-center py-4 text-muted">Chưa có dữ liệu</td>
                              </tr>
                            </c:otherwise>
                          </c:choose>
                        </tbody>
                      </table>
                    </div>
                  </div>

                </div>
              </div>
            </div>
          </div>
        </section>

        <!-- Modal Hủy Lịch Hẹn Đã Xác Nhận (Hoàn cọc) -->
        <div class="modal fade" id="cancelModal" tabindex="-1" aria-labelledby="cancelModalLabel" aria-hidden="true">
          <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content" style="border-radius: 12px; border: none; padding: 10px;">
              <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold" id="cancelModalLabel" style="color: #ef4444;"><i
                    class="bi bi-exclamation-triangle me-2"></i>Yêu cầu hủy lịch hẹn</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
              </div>
              <div class="modal-body pt-3 pb-4">
                <p class="text-muted mb-3">Bạn đang gửi yêu cầu hủy lịch khám <strong id="cancelApptLabel"
                    class="text-dark">#APT-00000</strong>. Vui lòng nhập lý do:</p>
                <form action="${pageContext.request.contextPath}/appointment/cancel" method="POST">
                  <input type="hidden" name="appointmentId" id="cancelAppointmentId" value="">
                  <div class="mb-3">
                    <label class="form-label small fw-bold">Lý do hủy lịch <span class="text-danger">*</span></label>
                    <textarea class="form-control" name="reason" rows="3"
                      placeholder="Nhập lý do hủy lịch của bạn (ví dụ: bận việc đột xuất)..." required></textarea>
                  </div>
                  <div class="p-3 bg-light rounded-3 mb-3 border">
                    <div class="d-flex align-items-center text-teal fw-bold mb-1" style="color: #0d9488;">
                      <i class="bi bi-info-circle me-2"></i>Quy trình xử lý hoàn tiền cọc (<span id="cancelFeeDisplay">200.000 ₫</span>)
                    </div>
                    <div class="text-muted small" style="font-size: 0.825rem; line-height: 1.5;">
                      Sau khi bạn gửi, trạng thái lịch hẹn sẽ chuyển sang <strong>Chờ duyệt hủy</strong> và được gửi tới
                      Nhân viên (Staff). Khi nhân viên đồng ý, lịch hẹn sẽ được hủy chính thức. Sau đó bạn mới có thể tạo yêu cầu hoàn tiền.
                    </div>
                  </div>
                  <div class="d-flex justify-content-end gap-2 mt-4">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn btn-danger">Gửi yêu cầu hủy</button>
                  </div>
                </form>
              </div>
            </div>
          </div>
        </div>

        <!-- Modal Hủy Lịch Hẹn Chưa Thanh Toán -->
        <div class="modal fade" id="directCancelModal" tabindex="-1" aria-labelledby="directCancelModalLabel" aria-hidden="true">
          <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content" style="border-radius: 12px; border: none; padding: 10px;">
              <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold" id="directCancelModalLabel" style="color: #64748b;"><i
                    class="bi bi-trash3 me-2"></i>Hủy lịch hẹn chưa thanh toán</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
              </div>
              <div class="modal-body pt-3 pb-4">
                <p class="text-muted mb-3">Bạn có chắc chắn muốn hủy lịch khám chưa thanh toán <strong id="directCancelApptLabel"
                    class="text-dark">#APT-00000</strong>? Khung giờ sẽ được giải phóng cho bệnh nhân khác.</p>
                <form action="${pageContext.request.contextPath}/appointment/cancel" method="POST">
                  <input type="hidden" name="appointmentId" id="directCancelAppointmentId" value="">
                  <div class="mb-3">
                    <label class="form-label small fw-bold">Lý do hủy lịch <span class="text-danger">*</span></label>
                    <textarea class="form-control" name="reason" id="directCancelReason" rows="3"
                      placeholder="Nhập lý do hủy lịch hẹn của bạn..." required></textarea>
                  </div>
                  <div class="d-flex justify-content-end gap-2 mt-4">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Không hủy</button>
                    <button type="submit" class="btn btn-secondary">Xác nhận hủy</button>
                  </div>
                </form>
              </div>
            </div>
          </div>
        </div>

        <script>
          function openCancelModal(id, timeText, fee) {
            document.getElementById('cancelAppointmentId').value = id;
            document.getElementById('cancelApptLabel').innerText = '#APT-' + id + ' (' + timeText + ')';
            const feeNum = parseInt(fee) || 200000;
            const feeEl = document.getElementById('cancelFeeDisplay');
            if (feeEl) feeEl.innerText = feeNum.toLocaleString('vi-VN') + ' ₫';
            const cancelModal = new bootstrap.Modal(document.getElementById('cancelModal'));
            cancelModal.show();
          }

          function openDirectCancelModal(id, timeText) {
            document.getElementById('directCancelAppointmentId').value = id;
            document.getElementById('directCancelApptLabel').innerText = '#APT-' + id + ' (' + timeText + ')';
            const reasonEl = document.getElementById('directCancelReason');
            if (reasonEl) reasonEl.value = '';
            const directModal = new bootstrap.Modal(document.getElementById('directCancelModal'));
            directModal.show();
          }

          // Real-time Countdown Timer & Auto-cancel when expired
          document.addEventListener('DOMContentLoaded', function() {
            const payButtons = document.querySelectorAll('.countdown-pay-btn');
            if (payButtons.length === 0) return;

            payButtons.forEach(function(btn) {
              const apptId = btn.getAttribute('data-appt-id');
              const remainingFromServer = parseInt(btn.getAttribute('data-remaining')) || 0;
              const storageKey = 'vc_pay_expire_' + apptId;
              const now = Date.now();

              let expireTimestamp = sessionStorage.getItem(storageKey);
              if (!expireTimestamp || isNaN(expireTimestamp)) {
                expireTimestamp = now + (remainingFromServer * 1000);
                sessionStorage.setItem(storageKey, expireTimestamp);
              } else {
                expireTimestamp = parseInt(expireTimestamp);
                const expectedDiff = Math.abs(expireTimestamp - (now + (remainingFromServer * 1000)));
                if (expectedDiff > 60000) {
                  expireTimestamp = now + (remainingFromServer * 1000);
                  sessionStorage.setItem(storageKey, expireTimestamp);
                }
              }

              const badge = document.getElementById('countdownBadge_' + apptId);

              function tick() {
                const remainingMs = expireTimestamp - Date.now();
                const remainingSec = Math.max(0, Math.floor(remainingMs / 1000));
                const m = Math.floor(remainingSec / 60);
                const s = remainingSec % 60;
                const formatted = (m < 10 ? '0' : '') + m + ':' + (s < 10 ? '0' : '') + s;

                if (badge) {
                  badge.textContent = formatted;
                  if (remainingSec <= 120) {
                    badge.className = 'badge bg-danger text-white ms-1 font-monospace';
                  } else if (remainingSec <= 300) {
                    badge.className = 'badge bg-warning text-dark ms-1 font-monospace';
                  } else {
                    badge.className = 'badge bg-white text-dark ms-1 font-monospace';
                  }
                }

                if (remainingSec <= 0) {
                  clearInterval(intervalId);
                  sessionStorage.removeItem(storageKey);
                  if (badge) badge.textContent = '00:00 (Hết hạn)';
                  btn.classList.add('disabled', 'opacity-50');
                  btn.style.pointerEvents = 'none';

                  // Tự động gọi API hủy lịch do hết giờ
                  fetch('${pageContext.request.contextPath}/appointment/cancel', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'appointmentId=' + encodeURIComponent(apptId) + '&reason=' + encodeURIComponent('Hết hạn thời gian thanh toán (15 phút)')
                  }).then(function() {
                    setTimeout(function() {
                      window.location.reload();
                    }, 1000);
                  }).catch(function(err) {
                    console.error('Auto-cancel failed:', err);
                  });
                }
              }

              tick();
              const intervalId = setInterval(tick, 1000);
            });
          });
        </script>

      </main>

      <%-- Include Footer --%>
        <jsp:include page="/views/common/footer.jsp" />
