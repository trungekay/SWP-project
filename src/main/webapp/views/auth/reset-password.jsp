<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Include Header --%>
<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Đặt lại mật khẩu" />
  <jsp:param name="pageDescription" value="Đặt lại mật khẩu tài khoản VisionCare" />
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
              <h1>Đặt lại mật khẩu mới</h1>
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
              <div class="logo-icon"><i class="bi bi-shield-lock"></i></div>
              <h3 class="mb-2" style="color: #0d9488;">Mật khẩu mới</h3>
              <p class="text-muted mb-4">Nhập mật khẩu mới cho tài khoản của bạn.</p>
            </div>

            <form method="post" action="${pageContext.request.contextPath}/reset-password">
              <input type="hidden" name="token" value="${param.token}">
              
              <div class="mb-3">
                <label class="form-label fw-bold">Mật khẩu mới</label>
                <div class="input-group">
                  <span class="input-group-text"><i class="bi bi-lock"></i></span>
                  <input type="password" class="form-control" name="newPassword" required placeholder="••••••••">
                </div>
              </div>

              <div class="mb-4">
                <label class="form-label fw-bold">Xác nhận mật khẩu</label>
                <div class="input-group">
                  <span class="input-group-text"><i class="bi bi-lock-fill"></i></span>
                  <input type="password" class="form-control" name="confirmPassword" required placeholder="••••••••">
                </div>
              </div>

              <button type="submit" class="btn btn-primary-custom mb-3">
                Xác nhận
              </button>
            </form>

          </div>
        </div>
      </div>
    </section>
  </main>

<%-- Include Footer --%>
<jsp:include page="/views/common/footer.jsp" />
