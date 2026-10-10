<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Include Header --%>
<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Đổi mật khẩu" />
  <jsp:param name="pageDescription" value="Đổi mật khẩu tài khoản VisionCare" />
  <jsp:param name="bodyClass" value="starter-page-page" />
  <jsp:param name="activeNav" value="" />
  <jsp:param name="hideHeaderForAdmin" value="true" />
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
  </style>

  <main class="main bg-light pb-5">

    <div class="page-title">

      <nav class="breadcrumbs">
        <div class="container">
          <ol>
            <li><a href="${pageContext.request.contextPath}/home">Trang chủ</a></li>
            <li><a href="${pageContext.request.contextPath}/profile/manage">Hồ sơ cá nhân</a></li>
            <li class="current">Đổi mật khẩu</li>
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
                    <a href="${pageContext.request.contextPath}/views/profile/refund-request.jsp" class=""><i class="bi bi-cash-coin"></i> Yêu cầu hoàn tiền</a>
                    </li>
                </c:if>
                <li>
                  <a href="${pageContext.request.contextPath}/views/profile/change-password.jsp" class="active"><i class="bi bi-key"></i> Đổi mật khẩu</a>
                </li>
                <li class="mt-3 pt-3" style="border-top: 1px solid #f1f5f9;">
                  <a href="${pageContext.request.contextPath}/logout" class="text-danger"><i class="bi bi-box-arrow-right"></i> Đăng xuất</a>
                </li>
              </ul>
            </div>
          </div>
          <div class="col-lg-9 ps-lg-5">
            <div class="pt-2">
              <h4 class="fw-bold" style="color: #1c355e;">Đổi mật khẩu</h4>
              <p class="text-muted small mb-4">Đảm bảo tài khoản của bạn đang sử dụng mật khẩu an toàn</p>
              <hr class="mb-4">
              
              <c:if test="${not empty sessionScope.success}">
                <div class="alert alert-success alert-dismissible fade show small" role="alert">
                  <i class="bi bi-check-circle me-2"></i>${sessionScope.success}
                  <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="success" scope="session" />
              </c:if>
              
              <c:if test="${not empty sessionScope.error}">
                <div class="alert alert-danger alert-dismissible fade show small" role="alert">
                  <i class="bi bi-exclamation-triangle me-2"></i>${sessionScope.error}
                  <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="error" scope="session" />
              </c:if>
              
              <form method="post" action="${pageContext.request.contextPath}/profile/change-password">
                <div class="mb-4">
                  <label class="form-label text-muted small fw-bold">Mật khẩu hiện tại</label>
                  <input type="password" class="form-control" name="oldPassword" placeholder="Nhập mật khẩu hiện tại" required>
                </div>
                
                <div class="mb-4">
                  <label class="form-label text-muted small fw-bold">Mật khẩu mới</label>
                  <input type="password" class="form-control" name="newPassword" placeholder="Nhập mật khẩu mới" required>
                </div>

                <div class="mb-4">
                  <label class="form-label text-muted small fw-bold">Xác nhận mật khẩu mới</label>
                  <input type="password" class="form-control" name="confirmPassword" placeholder="Nhập lại mật khẩu mới" required>
                </div>

                <div class="text-end mt-4 pt-2">
                  <button type="submit" class="btn text-white px-4 py-2" style="background-color: #0d9488; border-color: #0d9488; border-radius: 6px;">
                    Cập nhật mật khẩu
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </section>

  </main>

<%-- Include Footer --%>
<jsp:include page="/views/common/footer.jsp" />
