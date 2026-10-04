<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Include Header --%>
<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Quản lý hồ sơ" />
  <jsp:param name="pageDescription" value="Quản lý hồ sơ cá nhân VisionCare" />
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
            <li class="current">Hồ sơ cá nhân</li>
          </ol>
        </div>
      </nav>
    </div>

    <section class="section pt-4">
      <div class="container">
        <div class="row">
          <div class="col-lg-4">
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
                  <a class="nav-link active py-3" style="background: transparent; color: #0d9488; font-weight: 500;" href="${pageContext.request.contextPath}/views/profile/manage.jsp"><i class="bi bi-person me-3"></i> Thông tin chung</a>
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
                  <a class="nav-link py-3 text-dark" href="${pageContext.request.contextPath}/views/profile/change-password.jsp"><i class="bi bi-key me-3 text-muted"></i> Đổi mật khẩu</a>
                </li>
                <li class="nav-item mt-3">
                  <a class="nav-link py-3 text-danger fw-500" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-3"></i> Đăng xuất</a>
                </li>
              </ul>
            </div>
          </div>
          
          <div class="col-lg-8 ps-lg-5">
            <div class="pt-2">
              <h4 class="fw-bold" style="color: #1c355e;">Thông tin chung</h4>
              <p class="text-muted small mb-4">Quản lý và cập nhật thông tin cá nhân của bạn</p>
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
              
              <form method="post" action="${pageContext.request.contextPath}/profile/update">
                <div class="row mb-4">
                  <div class="col-md-6">
                    <label class="form-label text-muted small fw-bold">Họ và tên</label>
                    <input type="text" class="form-control" name="fullName" value="${not empty sessionScope.user.fullName ? sessionScope.user.fullName : ''}">
                  </div>
                  <div class="col-md-6 mt-3 mt-md-0">
                    <label class="form-label text-muted small fw-bold">Số điện thoại</label>
                    <input type="text" class="form-control" name="phone" value="${not empty sessionScope.user.phone ? sessionScope.user.phone : ''}">
                  </div>
                </div>
                
                <div class="row mb-4">
                  <div class="col-md-6">
                    <label class="form-label text-muted small fw-bold">Email (Không thể thay đổi)</label>
                    <input type="email" class="form-control bg-light" name="email" value="${not empty sessionScope.user.email ? sessionScope.user.email : ''}" readonly>
                  </div>
                  <div class="col-md-6 mt-3 mt-md-0">
                    <label class="form-label text-muted small fw-bold">Ngày sinh</label>
                    <input type="date" class="form-control" name="dob" value="${not empty sessionScope.user.dob ? sessionScope.user.dob : ''}">
                  </div>
                </div>

                <div class="mb-4">
                  <label class="form-label text-muted small fw-bold">Địa chỉ liên hệ</label>
                  <input type="text" class="form-control" name="address" value="${not empty sessionScope.user.address ? sessionScope.user.address : ''}">
                </div>

                <div class="text-end mt-4 pt-2">
                  <button type="submit" class="btn text-white px-4 py-2" style="background-color: #0d9488; border-color: #0d9488; border-radius: 6px;">
                    Lưu thay đổi
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
