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
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label for="fullName" class="form-label fw-bold">Họ và tên</label>
                  <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-person"></i></span>
                    <input type="text" class="form-control" id="fullName" name="fullName"
                           placeholder="Nguyễn Văn A" required>
                  </div>
                </div>
                <div class="col-md-6 mb-3">
                  <label for="phone" class="form-label fw-bold">Số điện thoại</label>
                  <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-telephone"></i></span>
                    <input type="text" class="form-control" id="phone" name="phone"
                           placeholder="0901234567" required>
                  </div>
                </div>
              </div>

              <div class="mb-3">
                <label for="email" class="form-label fw-bold">Email</label>
                <div class="input-group">
                  <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                  <input type="email" class="form-control" id="email" name="email"
                         placeholder="email@example.com" required>
                </div>
              </div>

              <div class="row">
                <div class="col-md-6 mb-3">
                  <label for="password" class="form-label fw-bold">Mật khẩu</label>
                  <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-lock"></i></span>
                    <input type="password" class="form-control" id="password" name="password"
                           placeholder="••••••••" required>
                  </div>
                </div>
                <div class="col-md-6 mb-3">
                  <label for="confirmPassword" class="form-label fw-bold">Xác nhận mật khẩu</label>
                  <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-lock-fill"></i></span>
                    <input type="password" class="form-control" id="confirmPassword" name="confirmPassword"
                           placeholder="••••••••" required>
                  </div>
                </div>
              </div>

              <div class="mb-4">
                <div class="form-check">
                  <input class="form-check-input" type="checkbox" id="terms" name="terms" required>
                  <label class="form-check-label small" for="terms">
                    Tôi đồng ý với các <a href="#" style="color: #0d9488;">điều khoản & dịch vụ</a> của VisionCare
                  </label>
                </div>
              </div>

              <button type="submit" class="btn btn-primary-custom">
                <i class="bi bi-person-plus-fill me-2"></i>Đăng ký ngay
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
