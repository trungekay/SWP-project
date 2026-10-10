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
            <div class="profile-card text-center border-0 shadow-sm" style="border-right: 1px solid #eee !important; border-radius: 0;">
              <div class="mb-3">
                <span class="badge bg-light text-dark rounded-pill border px-3 py-1">Avatar</span>
              </div>
              <h4 class="fw-bold" style="color: #1c355e;">${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Nguyễn Văn A'}</h4>
              <p class="text-muted small">Bệnh nhân</p>
              
              <hr class="mt-4 mb-0">
              <ul class="nav nav-pills flex-column text-start" id="profile-nav">
                <li class="nav-item">
                  <a class="nav-link py-3 text-dark" href="${pageContext.request.contextPath}/views/profile/manage.jsp"><i class="bi bi-person me-3 text-muted"></i> Thông tin chung</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link py-3 text-dark" href="${pageContext.request.contextPath}/views/profile/appointment-history.jsp"><i class="bi bi-calendar-check me-3 text-muted"></i> Lịch sử hẹn khám</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link active py-3" style="background: transparent; color: #0d9488; font-weight: 500;" href="${pageContext.request.contextPath}/views/profile/medical-history.jsp"><i class="bi bi-journal-medical me-3"></i> Hồ sơ y tế & Thanh toán</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link py-3 text-dark" href="${pageContext.request.contextPath}/views/profile/refund-request.jsp"><i class="bi bi-cash-coin me-3 text-muted"></i> Yêu cầu hoàn tiền</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link py-3 text-dark" href="${pageContext.request.contextPath}/views/profile/change-password.jsp"><i class="bi bi-key me-3 text-muted"></i> Đổi mật khẩu</a>
                </li>
                <li class="nav-item mt-3">
                  <a class="nav-link py-3 text-danger fw-500" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-3"></i> Đăng xuất</a>
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
                            <td class="py-3"><span class="badge-success-custom">Hoàn thành</span></td>
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
                            <td class="py-3">${invoice.date}</td>
                            <td class="py-3">#INV-${invoice.id}</td>
                            <td class="py-3">${invoice.description}</td>
                            <td class="py-3">${invoice.amount} VNĐ</td>
                            <td class="py-3">${invoice.method}</td>
                            <td class="py-3"><span class="badge-success-custom">${invoice.status}</span></td>
                            <td class="py-3">
                              <a href="${pageContext.request.contextPath}/views/profile/invoice-detail.jsp" class="btn btn-sm btn-outline-primary" style="color: #0d9488; border-color: #0d9488;"><i class="bi bi-eye"></i> Xem</a>
                            </td>
                          </tr>
                        </c:forEach>
                      </c:when>
                      <c:otherwise>
                        <tr>
                          <td colspan="7" class="text-center py-4 text-muted">Chưa có dữ liệu</td>
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

  </main>

<%-- Include Footer --%>
<jsp:include page="/views/common/footer.jsp" />
