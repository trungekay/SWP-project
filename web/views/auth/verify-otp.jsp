<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Include Header --%>
<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Xác minh mã OTP" />
  <jsp:param name="pageDescription" value="Xác minh mã OTP" />
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
      background: #eef2f6;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #0d9488;
      font-size: 28px;
      margin: 0 auto 20px;
    }
    .otp-input {
      width: 50px;
      height: 60px;
      text-align: center;
      font-size: 24px;
      border: 1px solid #dee2e6;
      border-radius: 8px;
      margin: 0 5px;
    }
    .otp-input:focus {
      border-color: #0d9488;
      box-shadow: 0 0 0 0.2rem rgba(13, 148, 136, 0.25);
      outline: none;
    }
  </style>

  <main class="main bg-light">
    <section class="section pt-5 pb-5">
      <div class="container">
        <div class="auth-container">
          <div class="auth-card">
            <div class="text-center">
              <div class="logo-icon"><i class="bi bi-chat-dots"></i></div>
              <h3 class="mb-2 fw-bold" style="color: #1c355e;">Xác minh mã OTP</h3>
              <p class="text-muted mb-4 small">Vui lòng nhập mã OTP gồm 6 chữ số vừa được gửi đến số điện thoại / email của bạn.</p>
            </div>

            <%-- Thông báo lỗi --%>
            <c:if test="${not empty error}">
              <div class="alert alert-danger alert-dismissible fade show small" role="alert">
                <i class="bi bi-exclamation-triangle me-2"></i>${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
              </div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/verify-otp">
              <div class="d-flex justify-content-center mb-4">
                <input type="text" class="otp-input" name="otp1" maxlength="1" required>
                <input type="text" class="otp-input" name="otp2" maxlength="1" required>
                <input type="text" class="otp-input" name="otp3" maxlength="1" required>
                <input type="text" class="otp-input" name="otp4" maxlength="1" required>
                <input type="text" class="otp-input" name="otp5" maxlength="1" required>
                <input type="text" class="otp-input" name="otp6" maxlength="1" required>
              </div>

              <button type="submit" class="btn w-100 py-2 mb-4 text-white" style="border-radius: 8px; font-size: 16px; font-weight: 500; background-color: #0d9488; border-color: #0d9488;">
                Xác thực
              </button>
            </form>

            <div class="text-center mt-3">
              <p class="small text-muted mb-3" id="resendContainer">Chưa nhận được mã? <span style="color: #6c757d; font-weight: 500;" id="resendTimer">Gửi lại (59s)</span></p>
              <a href="${pageContext.request.contextPath}/login" class="text-decoration-none small" style="color: #0d9488; font-weight: 500;"><i class="bi bi-arrow-left me-1"></i>Quay lại Đăng nhập</a>
            </div>
          </div>
        </div>
      </div>
    </section>
  </main>

  <script>
    // OTP Countdown Script
    document.addEventListener("DOMContentLoaded", function() {
      let timeLeft = 59;
      const timerElement = document.getElementById("resendTimer");
      const resendContainer = document.getElementById("resendContainer");
      
      const countdownInterval = setInterval(function() {
        timeLeft--;
        if (timeLeft <= 0) {
          clearInterval(countdownInterval);
          resendContainer.innerHTML = 'Chưa nhận được mã? <a href="${pageContext.request.contextPath}/resend-otp" style="color: #0d9488; font-weight: 500;" class="text-decoration-none">Gửi lại mã</a>';
        } else {
          timerElement.innerText = "Gửi lại (" + timeLeft + "s)";
        }
      }, 1000);
      
      // Auto move focus and handle paste
      const inputs = document.querySelectorAll(".otp-input");
      
      inputs.forEach((input, index) => {
        // Handle normal typing
        input.addEventListener("input", function(e) {
          if (this.value.length === 1 && index < inputs.length - 1) {
            inputs[index + 1].focus();
          }
        });
        
        // Handle backspace
        input.addEventListener("keydown", function(e) {
          if (e.key === "Backspace" && index > 0 && this.value.length === 0) {
            inputs[index - 1].focus();
            inputs[index - 1].value = '';
          }
        });
        
        // Handle paste
        input.addEventListener("paste", function(e) {
          e.preventDefault();
          const pastedData = (e.clipboardData || window.clipboardData).getData("text").trim();
          if (/^\d{1,6}$/.test(pastedData)) {
            for (let i = 0; i < pastedData.length; i++) {
              if (index + i < inputs.length) {
                inputs[index + i].value = pastedData[i];
                if (index + i < inputs.length - 1) {
                  inputs[index + i + 1].focus();
                }
              }
            }
          }
        });
      });
    });
  </script>

<%-- Include Footer --%>
<jsp:include page="/views/common/footer.jsp" />
