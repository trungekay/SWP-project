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
            <div class="profile-card text-center border-0 shadow-sm" style="border-right: 1px solid #eee !important; border-radius: 0;">
              <div class="mb-3">
                <span class="badge bg-light text-dark rounded-pill border px-3 py-1">Avatar</span>
              </div>
              <h4 class="fw-bold" style="color: #1c355e;">${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Nguyễn Văn A'}</h4>
              <p class="text-muted small">
                <c:choose>
                    <c:when test="${sessionScope.user.role == 'admin'}">Super Admin</c:when>
                    <c:when test="${sessionScope.user.role == 'manager'}">Manager</c:when>
                    <c:when test="${sessionScope.user.role == 'doctor'}">Bác sĩ</c:when>
                    <c:when test="${sessionScope.user.role == 'medical_specialist'}">Bác sĩ Chuyên khoa</c:when>
                    <c:when test="${sessionScope.user.role == 'staff'}">Nhân viên</c:when>
                    <c:otherwise>Bệnh nhân</c:otherwise>
                </c:choose>
              </p>
              
              <hr class="mt-4 mb-0">
              <ul class="nav nav-pills flex-column text-start" id="profile-nav">
                <li class="nav-item">
                  <a class="nav-link py-3 text-dark" href="${pageContext.request.contextPath}/views/profile/manage.jsp"><i class="bi bi-person me-3 text-muted"></i> Thông tin chung</a>
                </li>
                <c:if test="${sessionScope.user.role == 'patient'}">
                    <li class="nav-item">
                    <a class="nav-link py-3 text-dark" href="${pageContext.request.contextPath}/views/profile/appointment-history.jsp"><i class="bi bi-calendar-check me-3 text-muted"></i> Lịch sử hẹn khám</a>
                    </li>
                    <li class="nav-item">
                    <a class="nav-link py-3 text-dark" href="${pageContext.request.contextPath}/views/profile/medical-history.jsp"><i class="bi bi-journal-medical me-3 text-muted"></i> Hồ sơ y tế & Thanh toán</a>
                    </li>
                    <li class="nav-item">
                    <a class="nav-link py-3 text-dark" href="${pageContext.request.contextPath}/views/profile/refund-request.jsp"><i class="bi bi-cash-coin me-3 text-muted"></i> Yêu cầu hoàn tiền</a>
                    </li>
                </c:if>
                <li class="nav-item">
                  <a class="nav-link active py-3" style="background: transparent; color: #0d9488; font-weight: 500;" href="${pageContext.request.contextPath}/views/profile/change-password.jsp"><i class="bi bi-key me-3"></i> Đổi mật khẩu</a>
                </li>
                <li class="nav-item mt-3">
                  <a class="nav-link py-3 text-danger fw-500" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-3"></i> Đăng xuất</a>
                </li>
              </ul>
            </div>
          </div>
          
          <div class="col-lg-9 ps-lg-5">
            <div class="pt-2">
              <h4 class="fw-bold" style="color: #1c355e;">Đổi mật khẩu</h4>
              <p class="text-muted small mb-4">Đảm bảo tài khoản của bạn đang sử dụng mật khẩu an toàn</p>
              <hr class="mb-4">
              
              <c:if test="${param.force == 'true' || sessionScope.user.firstLogin}">
                <div class="alert alert-warning alert-dismissible fade show small" role="alert">
                  <i class="bi bi-shield-lock me-2"></i>Vì lý do bảo mật, bạn bắt buộc phải đổi mật khẩu trong lần đăng nhập đầu tiên.
                </div>
              </c:if>
              
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
