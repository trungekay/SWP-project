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
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        border: 1px solid rgba(0,0,0,0.05);
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
    .form-control, .form-select {
        border-radius: 8px;
        border: 1px solid #e2e8f0;
        padding: 10px 16px;
        font-size: 14px;
    }
    .form-control:focus, .form-select:focus {
        border-color: #0d9488;
        box-shadow: 0 0 0 3px rgba(13,148,136,0.1);
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
    .status-active { background-color: #dcfce7; color: #166534; }
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
              <h4 class="fw-bold" style="color: #1e293b; font-size: 18px;">${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Nguyễn Văn A'}</h4>
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
                  <a href="${pageContext.request.contextPath}/views/profile/manage.jsp" class=""><i class="bi bi-person"></i> Thông tin chung</a>
                </li>
                <c:if test="${sessionScope.user.role == 'patient'}">
                    <li>
                    <a href="${pageContext.request.contextPath}/views/profile/appointment-history.jsp" class=""><i class="bi bi-calendar-check"></i> Lịch sử hẹn khám</a>
                    </li>
                    <li>
                    <a href="${pageContext.request.contextPath}/views/profile/medical-history.jsp" class=""><i class="bi bi-journal-medical"></i> Lịch sử khám bệnh</a>
                    </li>
                    <li>
                    <a href="${pageContext.request.contextPath}/views/profile/refund-request.jsp" class="active"><i class="bi bi-cash-coin"></i> Yêu cầu hoàn tiền</a>
                    </li>
                </c:if>
                <li>
                  <a href="${pageContext.request.contextPath}/views/profile/change-password.jsp" class=""><i class="bi bi-key"></i> Đổi mật khẩu</a>
                </li>
                <li class="mt-3 pt-3" style="border-top: 1px solid #f1f5f9;">
                  <a href="${pageContext.request.contextPath}/logout" class="text-danger"><i class="bi bi-box-arrow-right"></i> Đăng xuất</a>
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
                <button type="button" class="btn text-white" style="background-color: #0d9488;" data-bs-toggle="modal" data-bs-target="#refundModal">
                  <i class="bi bi-plus-circle me-2"></i>Tạo yêu cầu
                </button>
              </div>
              <hr class="mb-4">

              <div class="table-responsive mb-5">
                <table class="custom-table">
                  <thead>
                    <tr>
                      <th class="py-3">Mã Y/C</th>
                      <th class="py-3">Mã Hóa Đơn</th>
                      <th class="py-3">Số tiền hoàn</th>
                      <th class="py-3">Lý do</th>
                      <th class="py-3">Trạng thái</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:choose>
                      <c:when test="${not empty refunds}">
                        <c:forEach var="refund" items="${refunds}">
                          <tr>
                            <td class="py-3 fw-bold">#REF-${refund.id}</td>
                            <td class="py-3">#INV-${refund.invoiceId}</td>
                            <td class="py-3 text-danger fw-bold">${refund.amount} đ</td>
                            <td class="py-3">${refund.reason}</td>
                            <td class="py-3">
                              <c:choose>
                                <c:when test="${refund.status == 'Đang chờ'}">
                                  <span class="badge-warning-custom">${refund.status}</span>
                                </c:when>
                                <c:when test="${refund.status == 'Đã hoàn tiền'}">
                                  <span class="badge-success-custom">${refund.status}</span>
                                </c:when>
                                <c:otherwise>
                                  <span class="badge-danger-custom">${refund.status}</span>
                                </c:otherwise>
                              </c:choose>
                            </td>
                          </tr>
                        </c:forEach>
                      </c:when>
                      <c:otherwise>
                        <tr>
                          <td colspan="5" class="text-center py-4 text-muted">Chưa có dữ liệu</td>
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
    </section>

    <!-- Modal Tạo Yêu Cầu Hoàn Tiền -->
    <div class="modal fade" id="refundModal" tabindex="-1" aria-labelledby="refundModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 12px; border: none; padding: 10px;">
          <div class="modal-header border-0 pb-0">
            <h5 class="modal-title fw-bold" id="refundModalLabel" style="color: #0d9488;"><i class="bi bi-cash-coin me-2"></i>Gửi yêu cầu hoàn tiền</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body pt-3 pb-4">
            <p class="text-muted mb-4 small">Vui lòng chọn hóa đơn và cung cấp lý do để chúng tôi tiến hành xác minh và hoàn tiền cho bạn.</p>
            <form action="${pageContext.request.contextPath}/refund/request" method="POST">
              
              <div class="mb-3">
                <label class="form-label small fw-bold">Chọn hóa đơn cần hoàn tiền <span class="text-danger">*</span></label>
                <select class="form-select" name="invoiceId" required>
                  <option value="" disabled selected>-- Chọn hóa đơn --</option>
                  <option value="INV-00215">#INV-00215 - Khám mắt (500,000 đ)</option>
                  <option value="INV-00300">#INV-00300 - Cắt kính (1,000,000 đ)</option>
                </select>
              </div>

              <div class="mb-3">
                <label class="form-label small fw-bold">Số tiền yêu cầu hoàn (VNĐ) <span class="text-danger">*</span></label>
                <input type="number" class="form-control" name="amount" placeholder="VD: 500000" required>
              </div>

              <div class="mb-3">
                <label class="form-label small fw-bold">Lý do hoàn tiền <span class="text-danger">*</span></label>
                <textarea class="form-control" name="reason" rows="3" placeholder="Nhập lý do chi tiết..." required></textarea>
              </div>

              <div class="d-flex justify-content-end gap-2 mt-4">
                <button type="button" class="btn btn-light" data-bs-dismiss="modal">Đóng</button>
                <button type="submit" class="btn text-white" style="background-color: #0d9488;">Gửi yêu cầu</button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>

  </main>

<%-- Include Footer --%>
<jsp:include page="/views/common/footer.jsp" />
