<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Include Header --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
              <h1>Đặt lại mật khẩu</h1>
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
              <h3 class="mb-2" style="color: #0d9488;">Mật khẩu mới</h3>
              <p class="text-muted mb-4">Vui lòng nhập mật khẩu mới cho tài khoản của bạn.</p>
            </div>

            <c:if test="${not empty error}">
              <div class="alert alert-danger alert-dismissible fade show small" role="alert">
                <i class="bi bi-exclamation-triangle me-2"></i>${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
              </div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/forgot-password/reset">
              <div class="mb-3">
                <label for="newPassword" class="form-label fw-bold">Mật khẩu mới</label>
                <div class="input-group">
                  <input type="password" class="form-control" id="newPassword" name="newPassword" required placeholder="Nhập mật khẩu mới...">
                </div>
              </div>
              <div class="mb-4">
                <label for="confirmPassword" class="form-label fw-bold">Xác nhận mật khẩu</label>
                <div class="input-group">
                  <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required placeholder="Nhập lại mật khẩu mới...">
                </div>
              </div>

              <button type="submit" class="btn w-100 py-2 mb-3 text-white" style="border-radius: 8px; font-size: 16px; font-weight: 500; background-color: #0d9488; border-color: #0d9488;">
                Xác nhận
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
