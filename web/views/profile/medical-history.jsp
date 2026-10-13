<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Include Header --%>
<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Hồ sơ y tế & Thanh toán" />
  <jsp:param name="pageDescription" value="Hồ sơ y tế & Thanh toán VisionCare" />
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
    .nav-pills .nav-link.active {
      background-color: #0d9488;
    }
    .nav-pills .nav-link {
      color: #333;
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
    /* Admin UI Sync */
    .content-card {
        background: white;
        border-radius: 12px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        border: 1px solid rgba(0,0,0,0.05);
        overflow: hidden;
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
    
    .action-btns {
        display: flex;
        gap: 12px;
        align-items: center;
    }
    .action-btn {
        color: #64748b;
        font-size: 16px;
        text-decoration: none;
        background: none;
        border: none;
        padding: 0;
        cursor: pointer;
        transition: color 0.2s;
    }
    .action-btn:hover { color: #0d9488; }
      /* Admin UI Sync */
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
  </style>

  <main class="main bg-light pb-5">

    <div class="page-title">
      <div class="heading">
        <div class="container">
          <div class="row d-flex justify-content-center text-center">
            <div class="col-lg-8">
              <h1>Lịch sử khám bệnh</h1>
              <p class="mb-0">Xem chi tiết hồ sơ y tế của bạn.</p>
            </div>
          </div>
        </div>
      </div>
      <nav class="breadcrumbs">
        <div class="container">
          <ol>
            <li><a href="${pageContext.request.contextPath}/home">Trang chủ</a></li>
            <li><a href="${pageContext.request.contextPath}/profile/manage">Hồ sơ cá nhân</a></li>
            <li class="current">Lịch sử khám bệnh</li>
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
                    <a href="${pageContext.request.contextPath}/views/profile/medical-history.jsp" class="active"><i class="bi bi-journal-medical"></i> Lịch sử khám bệnh</a>
                    </li>
                    <li>
                    <a href="${pageContext.request.contextPath}/views/profile/refund-request.jsp" class=""><i class="bi bi-cash-coin"></i> Yêu cầu hoàn tiền</a>
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
              <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
                <div>
                  <h4 class="fw-bold mb-1" style="color: #1c355e;">Hồ sơ y tế &amp; Thanh toán</h4>
                  <p class="text-muted small mb-0">Xem chi tiết lịch sử khám bệnh và các hóa đơn thanh toán của bạn</p>
                </div>
                <a href="${pageContext.request.contextPath}/book-appointment" class="btn btn-primary rounded-pill px-4 shadow-sm" style="background:#0d9488; border-color:#0d9488;">
                  <i class="bi bi-calendar-plus me-1"></i>Đặt lịch khám mới
                </a>
              </div>
              <hr class="mb-4">

              <h6 class="fw-bold mb-3" style="color: #0d9488;"><i class="bi bi-journal-medical me-2"></i>Lịch sử khám bệnh</h6>
              <div class="table-responsive mb-5">
                <table class="table table-borderless table-striped align-middle">
                  <thead class="table-light">
                    <tr>
                      <th class="py-3">Ngày khám</th>
                      <th class="py-3">Bác sĩ</th>
                      <th class="py-3">Dịch vụ</th>
                      <th class="py-3">Trạng thái</th>
                      <th class="py-3">Chi tiết</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:choose>
                      <c:when test="${not empty records}">
                        <c:forEach var="record" items="${records}">
                          <tr>
                            <td class="py-3">${record.date}</td>
                            <td class="py-3">BS. ${record.doctorName}</td>
                            <td class="py-3">${record.serviceName}</td>
                            <td class="py-3">
                              <c:choose>
                                <c:when test="${record.status == 'Completed'}">
                                  <span class="badge-success-custom">Đã hoàn thành</span>
                                </c:when>
                                <c:when test="${record.status == 'Confirmed'}">
                                  <span class="badge-status" style="background-color: #e0f2fe; color: #0369a1; padding: 6px 12px; border-radius: 20px; font-weight: 500; font-size: 12px;">Chưa hoàn thành (Chờ khám)</span>
                                </c:when>
                                <c:when test="${record.status == 'In_Progress'}">
                                  <span class="badge-status" style="background-color: #f3e8ff; color: #7e22ce; padding: 6px 12px; border-radius: 20px; font-weight: 500; font-size: 12px;">Đang khám</span>
                                </c:when>
                                <c:otherwise>
                                  <span class="badge-status" style="background-color: #fef3c7; color: #b45309; padding: 6px 12px; border-radius: 20px; font-weight: 500; font-size: 12px;">Chưa hoàn thành</span>
                                </c:otherwise>
                              </c:choose>
                            </td>
                            <td class="py-3">
                              <a href="${pageContext.request.contextPath}/profile/medical-record?id=${record.id}" class="btn btn-sm btn-outline-primary" style="color: #0d9488; border-color: #0d9488;">
                                <i class="bi bi-eye"></i> Xem
                              </a>
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

              <h6 class="fw-bold mb-3" style="color: #0d9488;"><i class="bi bi-receipt me-2"></i>Lịch sử thanh toán</h6>
              <div class="table-responsive">
                <table class="table table-borderless table-striped align-middle">
                  <thead class="table-light">
                    <tr>
                      <th class="py-3">Ngày thanh toán</th>
                      <th class="py-3">Mã hóa đơn</th>
                      <th class="py-3">Nội dung (Dịch vụ/Thuốc/Kính)</th>
                      <th class="py-3">Tổng tiền</th>
                      <th class="py-3">Phương thức</th>
                      <th class="py-3">Trạng thái</th>
                      <th class="py-3">Chi tiết</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:choose>
                      <c:when test="${not empty invoices}">
                        <c:forEach var="invoice" items="${invoices}">
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
      </div>
    </section>

  </main>

<%-- Include Footer --%>
<jsp:include page="/views/common/footer.jsp" />
