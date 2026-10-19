<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

    <%-- Include Header --%>
      <jsp:include page="/views/common/header.jsp">
        <jsp:param name="pageTitle" value="Yêu cầu hoàn tiền" />
        <jsp:param name="pageDescription" value="Yêu cầu hoàn tiền VisionCare" />
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
          padding: 14px 20px;
          border-bottom: 1px solid #e2e8f0;
        }

        .custom-table td {
          padding: 14px 20px;
          vertical-align: middle;
          border-bottom: 1px solid #f1f5f9;
          color: #334155;
          font-size: 14px;
          font-weight: 400;
        }

        .custom-table tbody tr {
          transition: background-color 0.15s ease;
        }

        .custom-table tbody tr:hover {
          background-color: #f8fafc;
        }

        .refund-code {
          color: #0d9488;
          font-weight: 600;
          font-size: 14px;
        }

        .invoice-link {
          color: #334155;
          font-weight: 500;
          text-decoration: none;
          font-size: 14px;
          transition: color 0.2s;
        }

        .invoice-link:hover {
          color: #0d9488;
          text-decoration: underline;
        }

        .appt-subtle-badge {
          font-size: 11px;
          padding: 2px 7px;
          border-radius: 4px;
          background-color: #fef3c7;
          color: #92400e;
          border: 1px solid #fde68a;
          font-weight: 500;
          margin-left: 6px;
          display: inline-block;
        }

        .badge-status {
          padding: 5px 12px;
          border-radius: 20px;
          font-size: 12px;
          font-weight: 500;
          display: inline-flex;
          align-items: center;
          gap: 5px;
          white-space: nowrap;
        }

        .badge-pending {
          background-color: #fef3c7;
          color: #92400e;
        }

        .badge-approved {
          background-color: #dcfce7;
          color: #166534;
        }

        .badge-rejected {
          background-color: #fee2e2;
          color: #991b1b;
        }

        .action-icon-btn {
          width: 32px;
          height: 32px;
          border-radius: 6px;
          border: 1px solid #e2e8f0;
          background: #ffffff;
          color: #64748b;
          display: inline-flex;
          align-items: center;
          justify-content: center;
          transition: all 0.2s ease;
          cursor: pointer;
          font-size: 15px;
        }

        .action-icon-btn:hover {
          border-color: #0d9488;
          color: #0d9488;
          background: #f0fdfa;
        }

        /* Detail Table & Card (Kiểu theo hàng) */
        .custom-detail-card {
          border: 1px solid #e2e8f0;
          border-radius: 10px;
          overflow: hidden;
          background: #ffffff;
        }

        .custom-detail-table {
          width: 100%;
          border-collapse: separate;
          border-spacing: 0;
          margin: 0;
        }

        .custom-detail-table tr {
          border-bottom: 1px solid #f1f5f9;
          transition: background-color 0.15s ease;
        }

        .custom-detail-table tr:last-child {
          border-bottom: none;
        }

        .custom-detail-table tr:hover {
          background-color: #fafbfc;
        }

        .custom-detail-table .detail-label {
          width: 30%;
          padding: 13px 18px;
          font-size: 13px;
          font-weight: 500;
          color: #64748b;
          background-color: #f8fafc;
          border-right: 1px solid #f1f5f9;
          vertical-align: middle;
          white-space: nowrap;
        }

        .custom-detail-table .detail-value {
          padding: 13px 18px;
          font-size: 14px;
          color: #1e293b;
          font-weight: 400;
          vertical-align: middle;
        }
      </style>

      <main class="main bg-light pb-5">

        <div class="page-title">
          <div class="heading">
            <div class="container">
              <div class="row d-flex justify-content-center text-center">
                <div class="col-lg-8">
                  <h1>Hồ sơ cá nhân</h1>
                  <p class="mb-0">Quản lý yêu cầu hoàn tiền của bạn.</p>
                </div>
              </div>
            </div>
          </div>
          <nav class="breadcrumbs">
            <div class="container">
              <ol>
                <li><a href="${pageContext.request.contextPath}/home">Trang chủ</a></li>
                <li class="current">Yêu cầu hoàn tiền</li>
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
                        <a href="${pageContext.request.contextPath}/views/profile/appointment-history.jsp" class=""><i
                            class="bi bi-calendar-check"></i> Lịch sử hẹn khám</a>
                      </li>
                      <li>
                        <a href="${pageContext.request.contextPath}/views/profile/medical-history.jsp" class=""><i
                            class="bi bi-journal-medical"></i> Lịch sử khám bệnh</a>
                      </li>
                      <li>
                        <a href="${pageContext.request.contextPath}/views/profile/refund-request.jsp" class="active"><i
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
                  <div class="d-flex justify-content-between align-items-center mb-4">
                    <div>
                      <h4 class="fw-bold" style="color: #1c355e;">Yêu cầu hoàn tiền</h4>
                      <p class="text-muted small mb-0">Theo dõi tiến trình các yêu cầu hoàn tiền của bạn</p>
                    </div>
                    <button type="button" class="btn text-white" style="background-color: #0d9488;"
                      data-bs-toggle="modal" data-bs-target="#refundModal">
                      <i class="bi bi-plus-circle me-2"></i>Tạo yêu cầu
                    </button>
                  </div>
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

                  <div class="content-card mb-5">
                    <div class="table-responsive">
                      <table class="custom-table mb-0">
                        <thead>
                          <tr>
                            <th>Mã yêu cầu</th>
                            <th>Mã hóa đơn</th>
                            <th>Số tiền hoàn</th>
                            <th class="text-center">Trạng thái</th>
                            <th class="text-center">Chi tiết</th>
                          </tr>
                        </thead>
                        <tbody>
                          <c:choose>
                            <c:when test="${not empty refunds}">
                              <c:forEach var="refund" items="${refunds}">
                                <tr>
                                  <td>
                                    <span class="refund-code">${not empty refund.formattedId ? refund.formattedId :
                                      '#REF-'.concat(refund.id)}</span>
                                  </td>
                                  <td>
                                    <a href="${pageContext.request.contextPath}/profile/invoice-detail?id=${refund.invoiceId}"
                                      class="invoice-link" title="Xem chi tiết hóa đơn">
                                      ${not empty refund.formattedInvoiceId ? refund.formattedInvoiceId :
                                      '#INV-'.concat(refund.invoiceId)}
                                    </a>
                                    <c:if test="${not empty refund.formattedApptId && refund.formattedApptId != 'N/A'}">
                                      <span class="appt-subtle-badge" title="Lịch hẹn liên kết">
                                        <i class="bi bi-calendar-x me-1"></i>${refund.formattedApptId}
                                      </span>
                                    </c:if>
                                  </td>
                                  <td>
                                    <span class="text-danger fw-semibold">${not empty refund.amountFmt ?
                                      refund.amountFmt : refund.amount.concat(' đ')}</span>
                                  </td>
                                  <td class="text-center">
                                    <c:choose>
                                      <c:when
                                        test="${refund.status == 'Pending' || refund.status == 'Đang chờ' || refund.statusVn == 'Chờ duyệt' || refund.statusVn == 'Đang chờ'}">
                                        <span class="badge-status badge-pending">
                                          <i class="bi bi-circle-fill" style="font-size: 6px;"></i> Chờ duyệt
                                        </span>
                                      </c:when>
                                      <c:when
                                        test="${refund.status == 'Approved' || refund.status == 'Đã hoàn tiền' || refund.statusVn == 'Đã hoàn tiền' || refund.status == 'Đã xác nhận' || refund.statusVn == 'Đã xác nhận'}">
                                        <span class="badge-status badge-approved">
                                          <i class="bi bi-circle-fill" style="font-size: 6px;"></i> Đã xác nhận
                                        </span>
                                      </c:when>
                                      <c:otherwise>
                                        <span class="badge-status badge-rejected">
                                          <i class="bi bi-circle-fill" style="font-size: 6px;"></i> Đã từ chối
                                        </span>
                                      </c:otherwise>
                                    </c:choose>
                                  </td>
                                  <td class="text-center">
                                    <button type="button" class="action-icon-btn"
                                      data-code="${not empty refund.formattedId ? refund.formattedId : '#REF-'.concat(refund.id)}"
                                      data-invoice-id="${refund.invoiceId}"
                                      data-invoice-code="${not empty refund.formattedInvoiceId ? refund.formattedInvoiceId : '#INV-'.concat(refund.invoiceId)}"
                                      data-appt-code="${refund.formattedApptId}" data-patient-name="<c:out value=" ${not
                                      empty refund.patientName ? refund.patientName : sessionScope.user.fullName}" />"
                                    data-patient-phone="
                                    <c:out
                                      value="${not empty refund.patientPhone ? refund.patientPhone : sessionScope.user.phone}" />
                                    "
                                    data-amount="${not empty refund.amountFmt ? refund.amountFmt :
                                    refund.amount.concat(' đ')}"
                                    data-reason="
                                    <c:out value="${refund.reason}" />"
                                    data-status="${refund.status}"
                                    data-status-vn="${not empty refund.statusVn ? refund.statusVn : refund.status}"
                                    data-created-at="${refund.createdAt}"
                                    onclick="showPatientRefundDetail(this)"
                                    title="Xem chi tiết">
                                    <i class="bi bi-eye"></i>
                                    </button>
                                  </td>
                                </tr>
                              </c:forEach>
                            </c:when>
                            <c:otherwise>
                              <tr>
                                <td colspan="5" class="text-center py-5 text-muted">
                                  <i class="bi bi-inbox fs-1 d-block mb-2 text-secondary"></i>
                                  Chưa có yêu cầu hoàn tiền nào.
                                </td>
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

        <!-- Modal Tạo Yêu Cầu Hoàn Tiền -->
        <div class="modal fade" id="refundModal" tabindex="-1" aria-labelledby="refundModalLabel" aria-hidden="true">
          <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content" style="border-radius: 12px; border: none; padding: 10px;">
              <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold" id="refundModalLabel" style="color: #0d9488;"><i
                    class="bi bi-cash-coin me-2"></i>Gửi yêu cầu hoàn tiền</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
              </div>
              <div class="modal-body pt-3 pb-4">
                <p class="text-muted mb-3 small">Vui lòng chọn hóa đơn và cung cấp lý do để chúng tôi tiến hành xác minh
                  và hoàn tiền cho bạn.</p>

                <c:set var="eligibleCount" value="0" />
                <c:forEach var="pi" items="${paidInvoices}">
                  <c:if test="${pi.isEligible}">
                    <c:set var="eligibleCount" value="${eligibleCount + 1}" />
                  </c:if>
                </c:forEach>

                <c:if test="${eligibleCount == 0}">
                  <div id="noEligibleAlert" class="alert alert-warning py-2 px-3 small mb-3">
                    <i class="bi bi-info-circle me-1"></i>Hiện không có hóa đơn nào đủ điều kiện yêu cầu hoàn tiền (hóa đơn chưa thanh toán hoặc đã gửi yêu cầu trước đó).
                  </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/refund/request" method="POST" id="refundRequestForm">

                  <div class="mb-3">
                    <label class="form-label small fw-bold">Chọn hóa đơn đã thanh toán <span
                        class="text-danger">*</span></label>
                    <select class="form-select" name="invoiceId" id="refundInvoiceSelect"
                      onchange="updateMaxRefundAmount()" required>
                      <option value="" disabled selected>-- Chọn hóa đơn --</option>
                      <c:choose>
                        <c:when test="${eligibleCount > 0}">
                          <c:forEach var="pi" items="${paidInvoices}">
                            <c:if test="${pi.isEligible}">
                              <option value="${pi.id}" 
                                      data-amount="${pi.depositAmount != null ? pi.depositAmount : pi.amount}"
                                      data-amount-fmt="${pi.amountFmt}">
                                ${pi.formattedId} - ${pi.date} - ${pi.amountFmt}
                              </option>
                            </c:if>
                          </c:forEach>
                        </c:when>
                        <c:otherwise>
                          <option value="" disabled>Không có hóa đơn hợp lệ</option>
                        </c:otherwise>
                      </c:choose>
                    </select>
                  </div>

                  <div class="mb-3">
                    <label class="form-label small fw-bold">Số tiền yêu cầu hoàn (VNĐ) <span
                        class="text-danger">*</span></label>
                    <input type="text" class="form-control bg-light" id="refundAmountDisplay"
                      placeholder="Tự động cập nhật theo hóa đơn" readonly
                      style="cursor: not-allowed; font-weight: 600; color: #0d9488;">
                    <input type="hidden" name="amount" id="refundAmountInput" required>
                  </div>

                  <div class="mb-3">
                    <label class="form-label small fw-bold">Lý do hoàn tiền <span class="text-danger">*</span></label>
                    <textarea class="form-control" name="reason" rows="3" placeholder="Nhập lý do chi tiết..."
                      required></textarea>
                  </div>

                  <div class="d-flex justify-content-end gap-2 mt-4">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn text-white" style="background-color: #0d9488;" ${eligibleCount == 0 ? 'disabled' : ''}>Gửi yêu cầu</button>
                  </div>
                </form>
              </div>
            </div>
          </div>
        </div>

        <!-- Modal Xem Chi Tiết Yêu Cầu Hoàn Tiền (Patient Detail Modal) -->
        <div class="modal fade" id="patientRefundDetailModal" tabindex="-1" aria-hidden="true">
          <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content"
              style="border-radius: 14px; border: none; box-shadow: 0 10px 25px rgba(0,0,0,0.1);">
              <div class="modal-header border-bottom py-3 px-4">
                <div class="d-flex align-items-center gap-2">
                  <div class="text-white d-flex align-items-center justify-content-center"
                    style="background-color: #0d9488; width: 36px; height: 36px; font-size: 18px; border-radius: 8px;">
                    <i class="bi bi-receipt-cutoff"></i>
                  </div>
                  <div>
                    <h5 class="modal-title fw-bold mb-0 text-dark">
                      Chi tiết yêu cầu hoàn tiền <span id="patDetailModalRefundCode" class="text-teal ms-1"
                        style="color: #0d9488;">#REF-000</span>
                    </h5>
                    <small class="text-muted">Xem thông tin chi tiết và tiến trình xử lý yêu cầu hoàn tiền</small>
                  </div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
              </div>
              <div class="modal-body p-4">
                <div class="custom-detail-card">
                  <table class="custom-detail-table mb-0">
                    <tbody>
                      <tr>
                        <td class="detail-label"><i class="bi bi-hash me-2 text-teal" style="color: #0d9488;"></i>Mã yêu
                          cầu</td>
                        <td class="detail-value">
                          <span id="patDetailModalRefundCodeVal" class="refund-code">#REF-000</span>
                        </td>
                      </tr>
                      <tr>
                        <td class="detail-label"><i class="bi bi-receipt me-2 text-teal" style="color: #0d9488;"></i>Mã
                          hóa đơn liên quan</td>
                        <td class="detail-value">
                          <div class="d-flex align-items-center gap-2">
                            <a id="patDetailModalInvoiceLink" href="#" class="invoice-link"
                              title="Xem hóa đơn chi tiết">#INV-00000</a>
                            <span id="patDetailModalApptBadge"></span>
                          </div>
                        </td>
                      </tr>
                      <tr>
                        <td class="detail-label"><i class="bi bi-person me-2 text-teal" style="color: #0d9488;"></i>Bệnh
                          nhân</td>
                        <td class="detail-value">
                          <div class="d-flex align-items-center gap-3">
                            <span id="patDetailModalPatientName" class="patient-name fw-medium">--</span>
                            <span id="patDetailModalPatientPhone" class="text-muted small"><i
                                class="bi bi-telephone me-1"></i>--</span>
                          </div>
                        </td>
                      </tr>
                      <tr>
                        <td class="detail-label"><i class="bi bi-clock-history me-2 text-teal"
                            style="color: #0d9488;"></i>Thời gian gửi</td>
                        <td class="detail-value" id="patDetailModalCreatedAt">--</td>
                      </tr>
                      <tr>
                        <td class="detail-label"><i class="bi bi-cash-stack me-2 text-teal"
                            style="color: #0d9488;"></i>Giá tiền hoàn</td>
                        <td class="detail-value">
                          <span id="patDetailModalAmount" class="fw-semibold text-danger">0 đ</span>
                        </td>
                      </tr>
                      <tr>
                        <td class="detail-label"><i class="bi bi-chat-left-text me-2 text-teal"
                            style="color: #0d9488;"></i>Lý do hủy</td>
                        <td class="detail-value" id="patDetailModalReason"
                          style="white-space: pre-wrap; line-height: 1.5;">--</td>
                      </tr>
                      <tr>
                        <td class="detail-label"><i class="bi bi-shield-check me-2 text-teal"
                            style="color: #0d9488;"></i>Tình trạng xét duyệt</td>
                        <td class="detail-value" id="patDetailModalStatusSection">
                          <!-- Dynamic status badge & message -->
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
              <div class="modal-footer border-top py-3 px-4 justify-content-end">
                <button type="button" class="btn btn-light px-4" data-bs-dismiss="modal">Đóng</button>
              </div>
            </div>
          </div>
        </div>

        <script>
          function updateMaxRefundAmount() {
            const sel = document.getElementById('refundInvoiceSelect');
            const opt = sel.options[sel.selectedIndex];
            if (opt && opt.dataset.amount) {
              const rawAmt = opt.dataset.amount;
              const fmtAmt = opt.dataset.amountFmt || (new Intl.NumberFormat('vi-VN').format(rawAmt) + ' đ');
              const displayInput = document.getElementById('refundAmountDisplay');
              const hiddenInput = document.getElementById('refundAmountInput');
              if (displayInput) displayInput.value = fmtAmt;
              if (hiddenInput) hiddenInput.value = rawAmt;
            } else {
              const displayInput = document.getElementById('refundAmountDisplay');
              const hiddenInput = document.getElementById('refundAmountInput');
              if (displayInput) displayInput.value = '';
              if (hiddenInput) hiddenInput.value = '';
            }
          }

          function showPatientRefundDetail(btn) {
            const code = btn.getAttribute('data-code');
            const invoiceId = btn.getAttribute('data-invoice-id');
            const invoiceCode = btn.getAttribute('data-invoice-code');
            const apptCode = btn.getAttribute('data-appt-code');
            const patientName = btn.getAttribute('data-patient-name');
            const patientPhone = btn.getAttribute('data-patient-phone');
            const amount = btn.getAttribute('data-amount');
            const reason = btn.getAttribute('data-reason');
            const status = btn.getAttribute('data-status');
            const createdAt = btn.getAttribute('data-created-at');

            document.getElementById('patDetailModalRefundCode').innerText = code;
            document.getElementById('patDetailModalRefundCodeVal').innerText = code;

            const invLink = document.getElementById('patDetailModalInvoiceLink');
            invLink.innerText = invoiceCode;
            invLink.href = '${pageContext.request.contextPath}/profile/invoice-detail?id=' + invoiceId;

            const apptContainer = document.getElementById('patDetailModalApptBadge');
            if (apptCode && apptCode !== 'N/A') {
              apptContainer.innerHTML = '<span class="appt-subtle-badge ms-1" title="Lịch hẹn liên kết"><i class="bi bi-calendar-x me-1"></i>' + apptCode + '</span>';
            } else {
              apptContainer.innerHTML = '';
            }

            document.getElementById('patDetailModalPatientName').innerText = patientName || '--';
            document.getElementById('patDetailModalPatientPhone').innerHTML = '<i class="bi bi-telephone me-1"></i>' + (patientPhone || 'Chưa cập nhật');
            document.getElementById('patDetailModalCreatedAt').innerText = createdAt || 'N/A';
            document.getElementById('patDetailModalAmount').innerText = amount;
            document.getElementById('patDetailModalReason').innerText = reason || 'Không có lý do';

            const statusSection = document.getElementById('patDetailModalStatusSection');
            if (status === 'Pending' || status === 'Đang chờ') {
              statusSection.innerHTML =
                '<div class="d-flex align-items-center gap-2 flex-wrap">' +
                '<span class="badge-status badge-pending">' +
                '<i class="bi bi-circle-fill" style="font-size: 6px;"></i> Chưa duyệt (Chờ duyệt)' +
                '</span>' +
                '<span class="text-muted small">Yêu cầu hoàn tiền đang chờ nhân viên kiểm tra và xử lý.</span>' +
                '</div>';
            } else if (status === 'Approved' || status === 'Đã hoàn tiền' || status === 'Đã xác nhận') {
              statusSection.innerHTML =
                '<div class="d-flex align-items-center gap-2 flex-wrap">' +
                '<span class="badge-status badge-approved">' +
                '<i class="bi bi-circle-fill" style="font-size: 6px;"></i> Đã xác nhận' +
                '</span>' +
                '<span class="text-muted small">Yêu cầu hoàn tiền đã được nhân viên xác nhận và đang tiến hành xử lý hoàn cọc.</span>' +
                '</div>';
            } else {
              statusSection.innerHTML =
                '<div class="d-flex align-items-center gap-2 flex-wrap">' +
                '<span class="badge-status badge-rejected">' +
                '<i class="bi bi-circle-fill" style="font-size: 6px;"></i> Đã từ chối' +
                '</span>' +
                '<span class="text-muted small">Yêu cầu hoàn tiền đã bị từ chối do không đáp ứng điều kiện.</span>' +
                '</div>';
            }

            const modal = new bootstrap.Modal(document.getElementById('patientRefundDetailModal'));
            modal.show();
          }
        </script>

      </main>

      <%-- Include Footer --%>
        <jsp:include page="/views/common/footer.jsp" />