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

            <form method="post" action="${pageContext.request.contextPath}/forgot-password/verify" id="otpForm">
              <input type="hidden" name="otp1" id="otp1">
              <input type="hidden" name="otp2" id="otp2">
              <input type="hidden" name="otp3" id="otp3">
              <input type="hidden" name="otp4" id="otp4">
              <input type="hidden" name="otp5" id="otp5">
              <input type="hidden" name="otp6" id="otp6">
              <div class="d-flex justify-content-center mb-4 otp-container" style="gap: 10px; position: relative;">
                <input type="text" class="otp-input" maxlength="1" readonly style="pointer-events: none;">
                <input type="text" class="otp-input" maxlength="1" readonly style="pointer-events: none;">
                <input type="text" class="otp-input" maxlength="1" readonly style="pointer-events: none;">
                <input type="text" class="otp-input" maxlength="1" readonly style="pointer-events: none;">
                <input type="text" class="otp-input" maxlength="1" readonly style="pointer-events: none;">
                <input type="text" class="otp-input" maxlength="1" readonly style="pointer-events: none;">
                
                <input type="text" id="realOtpInput" maxlength="6" style="position: absolute; width: 100%; height: 100%; opacity: 0; cursor: text; z-index: 10; font-size: 1px;" autocomplete="one-time-code">
              </div>

              <button type="submit" class="btn w-100 py-2 mb-4 text-white" style="border-radius: 8px; font-size: 16px; font-weight: 500; background-color: #0d9488; border-color: #0d9488;" id="btnSubmit">
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
    document.addEventListener("DOMContentLoaded", function() {
      const realInput = document.getElementById('realOtpInput');
      const fakeInputs = document.querySelectorAll('.otp-input');
      
      // Auto focus
      realInput.focus();

      // Setup hidden inputs on submit
      document.getElementById('otpForm').addEventListener('submit', function() {
          const val = realInput.value;
          for(let i=1; i<=6; i++) {
              document.getElementById('otp'+i).value = val[i-1] || '';
          }
      });

      // Update fake inputs when typing
      realInput.addEventListener('input', function(e) {
          const val = this.value.replace(/[^0-9]/g, '');
          this.value = val;
          
          fakeInputs.forEach((input, index) => {
              if (index < val.length) {
                  input.value = val[index];
                  input.style.borderColor = '#0d9488';
              } else {
                  input.value = '';
                  input.style.borderColor = '#e2e8f0';
              }
          });
          
          // Highlight active box
          fakeInputs.forEach(i => i.style.boxShadow = 'none');
          if (val.length < 6) {
              fakeInputs[val.length].style.boxShadow = '0 0 0 3px rgba(13, 148, 136, 0.2)';
              fakeInputs[val.length].style.borderColor = '#0d9488';
          }
      });

      realInput.addEventListener('focus', function() {
          const val = this.value;
          fakeInputs.forEach(i => i.style.boxShadow = 'none');
          if (val.length < 6) {
              fakeInputs[val.length].style.boxShadow = '0 0 0 3px rgba(13, 148, 136, 0.2)';
              fakeInputs[val.length].style.borderColor = '#0d9488';
          } else {
              fakeInputs[5].style.boxShadow = '0 0 0 3px rgba(13, 148, 136, 0.2)';
          }
      });

      realInput.addEventListener('blur', function() {
          fakeInputs.forEach(i => i.style.boxShadow = 'none');
      });

      // Timer logic
      let timeLeft = 59;
      const timerElement = document.getElementById("resendTimer");
      const resendContainer = document.getElementById("resendContainer");
      
      const countdownInterval = setInterval(function() {
        timeLeft--;
        if (timeLeft <= 0) {
          clearInterval(countdownInterval);
          resendContainer.innerHTML = 'Chưa nhận được mã? <a href="${pageContext.request.contextPath}/forgot-password" style="color: #0d9488; font-weight: 500;" class="text-decoration-none">Nhập lại Email</a>';
        } else {
          timerElement.innerText = "Gửi lại (" + timeLeft + "s)";
        }
      }, 1000);
    });
  </script>

<%-- Include Footer --%>
<jsp:include page="/views/common/footer.jsp" />
