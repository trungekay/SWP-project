<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Include Header --%>
<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Đăng nhập" />
  <jsp:param name="pageDescription" value="Đăng nhập vào hệ thống VisionCare" />
  <jsp:param name="bodyClass" value="starter-page-page" />
  <jsp:param name="activeNav" value="login" />
</jsp:include>

  <style>
    .login-container {
      max-width: 480px;
      margin: 0 auto;
    }
    .login-card {
      background: #fff;
      border-radius: 15px;
      box-shadow: 0 5px 30px rgba(0, 0, 0, 0.08);
      padding: 40px;
    }
    .login-card .logo-icon {
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
    .login-card .form-control:focus {
      border-color: #0d9488;
      box-shadow: 0 0 0 0.2rem rgba(13, 148, 136, 0.25);
    }
    .btn-login {
      background: #0d9488;
      border-color: #0d9488;
      color: #fff;
      padding: 12px;
      font-weight: 600;
      border-radius: 8px;
      width: 100%;
    }
    .btn-login:hover {
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
              <h1>Đăng nhập</h1>
              <p class="mb-0">Đăng nhập để quản lý lịch hẹn và thông tin cá nhân.</p>
            </div>
          </div>
        </div>
      </div>
      <nav class="breadcrumbs">
        <div class="container">
          <ol>
            <li><a href="${pageContext.request.contextPath}/home">Trang chủ</a></li>
            <li class="current">Đăng nhập</li>
          </ol>
        </div>
      </nav>
    </div>

    <section class="section pt-4 pb-5">
      <div class="container">
        <div class="login-container">
          <div class="login-card">
            <div class="text-center">
              <div class="logo-icon"><i class="bi bi-eye"></i></div>
              <h3 class="mb-1" style="color: #0d9488;">VisionCare</h3>
              <p class="text-muted mb-4">Đăng nhập vào tài khoản của bạn</p>
            </div>

            <%-- Thông báo lỗi --%>
            <c:if test="${not empty error}">
              <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-triangle me-2"></i>${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
              </div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/login">
              <div class="mb-3">
                <label for="email" class="form-label fw-bold">Email</label>
                <div class="input-group">
                  <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                  <input type="email" class="form-control" id="email" name="email"
                         placeholder="email@example.com" value="${email}" required autofocus>
                </div>
              </div>

              <div class="mb-3">
                <label for="password" class="form-label fw-bold">Mật khẩu</label>
                <div class="input-group">
                  <span class="input-group-text"><i class="bi bi-lock"></i></span>
                  <input type="password" class="form-control" id="password" name="password"
                         placeholder="••••••••" required>
                </div>
              </div>

              <div class="d-flex justify-content-between align-items-center mb-4">
                <div class="form-check">
                  <input class="form-check-input" type="checkbox" id="remember" name="remember">
                  <label class="form-check-label small" for="remember">Ghi nhớ đăng nhập</label>
                </div>
                <a href="#" class="small text-decoration-none" style="color: #0d9488;">Quên mật khẩu?</a>
              </div>

              <button type="submit" class="btn btn-login">
                <i class="bi bi-box-arrow-in-right me-2"></i>Đăng nhập
              </button>
            </form>

            <div class="text-center mt-4">
              <p class="text-muted small mb-0">Chưa có tài khoản? <a href="#" style="color: #0d9488; font-weight: 600;">Đăng ký ngay</a></p>
            </div>

          </div>
        </div>
      </div>
    </section>

  </main>

<%-- Include Footer --%>
<jsp:include page="/views/common/footer.jsp" />
