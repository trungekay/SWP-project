<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Include Header --%>
<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Đăng ký" />
  <jsp:param name="pageDescription" value="Đăng ký tài khoản VisionCare" />
  <jsp:param name="bodyClass" value="starter-page-page" />
  <jsp:param name="activeNav" value="login" />
</jsp:include>

  <style>
    .auth-container {
      max-width: 600px;
      margin: 0 auto;
    }
    .auth-card {
      background: #fff;
      border-radius: 15px;
      box-shadow: 0 5px 30px rgba(0, 0, 0, 0.08);
      padding: 40px;
    }
    .auth-card .logo-icon {
      width: 60px;
      height: 60px;
      border-radius: 50%;
      background: linear-gradient(135deg, #14b8a6, #0d9488);
      display: flex;
      align-items: center;
      justify-content: center;
      color: #fff;
      font-size: 28px;
      margin: 0 auto 20px;
    }
    .auth-card .form-control:focus {
      border-color: #0d9488;
      box-shadow: 0 0 0 0.2rem rgba(13, 148, 136, 0.25);
    }
    .btn-primary-custom {
      background: #0d9488;
      border-color: #0d9488;
      color: #fff;
      padding: 12px;
      font-weight: 600;
      border-radius: 8px;
      width: 100%;
    }
    .btn-primary-custom:hover {
      background: #0f766e;
      border-color: #0f766e;
      color: #fff;
    }
  </style>

  <main class="main bg-light">

    <div class="page-title">
      <div class="heading">
        <div class="container">
          <div class="row d-flex justify-content-center text-center">
            <div class="col-lg-8">
              <h1>Đăng ký tài khoản</h1>
              <p class="mb-0">Tạo tài khoản để dễ dàng quản lý hồ sơ khám bệnh và đặt lịch.</p>
            </div>
          </div>
        </div>
      </div>
      <nav class="breadcrumbs">
        <div class="container">
          <ol>
            <li><a href="${pageContext.request.contextPath}/home">Trang chủ</a></li>
            <li class="current">Đăng ký</li>
          </ol>
        </div>
      </nav>
    </div>

    <section class="section pt-4 pb-5">
      <div class="container">
        <div class="auth-container">
          <div class="auth-card">
            <div class="text-center">
              <div class="logo-icon"><i class="bi bi-person-plus"></i></div>
              <h3 class="mb-1" style="color: #0d9488;">Đăng Ký</h3>
              <p class="text-muted mb-4">Tham gia cùng VisionCare</p>
            </div>

            <%-- Thông báo lỗi --%>
            <c:if test="${not empty error}">
              <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-triangle me-2"></i>${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
              </div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/register">
              <div class="mb-3">
                <label for="fullName" class="form-label fw-bold">Họ và tên</label>
                <div class="input-group">
                  <input type="text" class="form-control" id="fullName" name="fullName"
                         placeholder="Nhập họ và tên" required>
                </div>
              </div>

              <div class="mb-3">
                <label for="phone" class="form-label fw-bold">Số điện thoại</label>
                <div class="input-group">
                  <input type="text" class="form-control" id="phone" name="phone"
                         placeholder="Nhập số điện thoại" required>
                </div>
              </div>

              <div class="mb-3">
                <label for="email" class="form-label fw-bold">Email</label>
                <div class="input-group">
                  <input type="email" class="form-control" id="email" name="email"
                         placeholder="Nhập email của bạn" required>
                </div>
              </div>

              <div class="mb-3">
                <label for="password" class="form-label fw-bold">Mật khẩu</label>
                <div class="input-group">
                  <input type="password" class="form-control" id="password" name="password"
                         placeholder="Tạo mật khẩu" required>
                </div>
              </div>

              <div class="mb-3">
                <label for="confirmPassword" class="form-label fw-bold">Nhập lại mật khẩu</label>
                <div class="input-group">
                  <input type="password" class="form-control" id="confirmPassword" name="confirmPassword"
                         placeholder="Nhập lại mật khẩu" required>
                </div>
              </div>

              <div class="mb-4">
                <div class="form-check">
                  <input class="form-check-input" type="checkbox" id="terms" name="terms">
                  <label class="form-check-label small text-muted" for="terms">
                    Tôi đồng ý nhận thông tin chăm sóc khách hàng và khuyến mãi
                  </label>
                </div>
              </div>

              <button type="submit" class="btn w-100 py-2 mt-3 text-white" style="border-radius: 8px; font-size: 16px; font-weight: 500; background-color: #0d9488; border-color: #0d9488;">
                Đăng ký
              </button>
            </form>

            <div class="text-center mt-4">
              <p class="text-muted small mb-0">Đã có tài khoản? <a href="${pageContext.request.contextPath}/login" style="color: #0d9488; font-weight: 600;">Đăng nhập</a></p>
            </div>

          </div>
        </div>
      </div>
    </section>

  </main>

<%-- Include Footer --%>
<jsp:include page="/views/common/footer.jsp" />
