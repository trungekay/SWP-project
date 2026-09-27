<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Include Header --%>
<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Đổi mật khẩu" />
  <jsp:param name="pageDescription" value="Đổi mật khẩu tài khoản VisionCare" />
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
  </style>

  <main class="main bg-light pb-5">

    <div class="page-title">
      <div class="heading">
        <div class="container">
          <div class="row d-flex justify-content-center text-center">
            <div class="col-lg-8">
              <h1>Đổi mật khẩu</h1>
              <p class="mb-0">Bảo mật tài khoản của bạn bằng mật khẩu mạnh.</p>
            </div>
          </div>
        </div>
      </div>
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
          <div class="col-lg-4">
            <div class="profile-card text-center">
              <img src="${pageContext.request.contextPath}/assets/img/testimonials/testimonials-1.jpg" alt="Avatar" class="profile-avatar">
              <h4>${sessionScope.user.fullName != null ? sessionScope.user.fullName : 'Nguyễn Văn A'}</h4>
              <p class="text-muted">Bệnh nhân</p>
              
              <ul class="nav nav-pills flex-column text-start mt-4">
                <li class="nav-item mb-2">
                  <a class="nav-link" href="${pageContext.request.contextPath}/profile/manage"><i class="bi bi-person me-2"></i> Thông tin cá nhân</a>
                </li>
                <li class="nav-item mb-2">
                  <a class="nav-link active" href="${pageContext.request.contextPath}/profile/change-password"><i class="bi bi-lock me-2"></i> Đổi mật khẩu</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-2"></i> Đăng xuất</a>
                </li>
              </ul>
            </div>
          </div>
          
          <div class="col-lg-8">
            <div class="profile-card">
              <h4 class="mb-4">Thay đổi mật khẩu</h4>
              
              <%-- Thông báo --%>
              <c:if test="${not empty message}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                  <i class="bi bi-check-circle me-2"></i>${message}
                  <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
              </c:if>
              
              <form method="post" action="${pageContext.request.contextPath}/profile/change-password">
                <div class="mb-3">
                  <label class="form-label fw-bold">Mật khẩu hiện tại</label>
                  <input type="password" class="form-control" name="oldPassword" required>
                </div>
                
                <div class="mb-3">
                  <label class="form-label fw-bold">Mật khẩu mới</label>
                  <input type="password" class="form-control" name="newPassword" required>
                </div>

                <div class="mb-4">
                  <label class="form-label fw-bold">Xác nhận mật khẩu mới</label>
                  <input type="password" class="form-control" name="confirmPassword" required>
                </div>

                <button type="submit" class="btn btn-custom px-4 py-2"><i class="bi bi-shield-lock me-2"></i>Lưu mật khẩu mới</button>
              </form>
            </div>
          </div>
        </div>
      </div>
    </section>

  </main>

<%-- Include Footer --%>
<jsp:include page="/views/common/footer.jsp" />
