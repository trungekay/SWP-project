<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Include Header --%>
<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Quên mật khẩu" />
  <jsp:param name="pageDescription" value="Khôi phục mật khẩu tài khoản VisionCare" />
  <jsp:param name="bodyClass" value="starter-page-page" />
  <jsp:param name="activeNav" value="login" />
</jsp:include>

  <style>
    .auth-container {
      max-width: 480px;
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
              <h1>Quên mật khẩu</h1>
            </div>
          </div>
        </div>
      </div>
    </div>

    <section class="section pt-4 pb-5">
      <div class="container">
        <div class="auth-container">
          <div class="auth-card">
            <div class="text-center">
              <div class="logo-icon"><i class="bi bi-key"></i></div>
              <h3 class="mb-2" style="color: #0d9488;">Khôi phục mật khẩu</h3>
              <p class="text-muted mb-4">Nhập email của bạn, chúng tôi sẽ gửi liên kết để đặt lại mật khẩu.</p>
            </div>

            <form method="post" action="${pageContext.request.contextPath}/forgot-password">
              <div class="mb-4">
                <label for="email" class="form-label fw-bold">Email đăng ký</label>
                <div class="input-group">
                  <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                  <input type="email" class="form-control" id="email" name="email" required placeholder="Nhập email...">
                </div>
              </div>

              <button type="submit" class="btn btn-primary-custom mb-3">
                Gửi yêu cầu khôi phục
              </button>
            </form>

            <div class="text-center mt-3">
              <a href="${pageContext.request.contextPath}/login" class="text-decoration-none" style="color: #6c757d;"><i class="bi bi-arrow-left me-1"></i>Quay lại Đăng nhập</a>
            </div>

          </div>
        </div>
      </div>
    </section>
  </main>

<%-- Include Footer --%>
<jsp:include page="/views/common/footer.jsp" />
