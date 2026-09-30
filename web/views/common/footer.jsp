<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

  <footer id="footer" class="footer light-background">

    <div class="container footer-top">
      <div class="row gy-4">
        <div class="col-lg-4 col-md-6 footer-about">
          <a href="${pageContext.request.contextPath}/home" class="logo d-flex align-items-center">
            <span class="sitename dentalcare-brand-text">VisionCare</span>
          </a>
          <div class="footer-contact pt-3">
            <p>456 Lê Thị Riêng, Quận 10</p>
            <p>TP. Hồ Chí Minh</p>
            <p class="mt-3"><strong>Hotline:</strong> <span>1800 599 988</span></p>
            <p><strong>Email:</strong> <span>hotro@visioncare.vn</span></p>
          </div>
          <div class="social-links d-flex mt-4">
            <a href=""><i class="bi bi-twitter-x"></i></a>
            <a href=""><i class="bi bi-facebook"></i></a>
            <a href=""><i class="bi bi-instagram"></i></a>
            <a href=""><i class="bi bi-linkedin"></i></a>
          </div>
        </div>

        <div class="col-lg-2 col-md-3 footer-links">
          <h4>Liên kết</h4>
          <ul>
            <li><a href="${pageContext.request.contextPath}/home">Trang chủ</a></li>
            <li><a href="${pageContext.request.contextPath}/home#about">Giới thiệu</a></li>
            <li><a href="${pageContext.request.contextPath}/doctor-schedules">Danh sách bác sĩ</a></li>
            <li><a href="${pageContext.request.contextPath}/book-appointment">Đặt lịch</a></li>
            <li><a href="${pageContext.request.contextPath}/login">Đăng nhập</a></li>
          </ul>
        </div>

        <div class="col-lg-2 col-md-3 footer-links">
          <h4>Dịch vụ</h4>
          <ul>
            <li><a href="${pageContext.request.contextPath}/home#services">Nhãn khoa tổng quát</a></li>
            <li><a href="${pageContext.request.contextPath}/home#services">Khúc xạ &amp; Kính</a></li>
            <li><a href="${pageContext.request.contextPath}/home#services">Phẫu thuật LASIK</a></li>
            <li><a href="${pageContext.request.contextPath}/home#services">Nhãn khoa trẻ em</a></li>
            <li><a href="${pageContext.request.contextPath}/home#services">Glaucoma &amp; Võng mạc</a></li>
          </ul>
        </div>

      </div>
    </div>

    <div class="container copyright text-center mt-4">
      <p>© <span>Bản quyền</span> <strong class="px-1 sitename">VisionCare</strong> <span>— Phòng khám Mắt</span></p>
    </div>

  </footer>

  <!-- Scroll Top -->
  <a href="#" id="scroll-top" class="scroll-top d-flex align-items-center justify-content-center"><i class="bi bi-arrow-up-short"></i></a>

  <!-- Preloader -->
  <div id="preloader"></div>

  <!-- Vendor JS Files -->
  <script src="${pageContext.request.contextPath}/assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
  <script src="${pageContext.request.contextPath}/assets/vendor/php-email-form/validate.js"></script>
  <script src="${pageContext.request.contextPath}/assets/vendor/aos/aos.js"></script>
  <script src="${pageContext.request.contextPath}/assets/vendor/glightbox/js/glightbox.min.js"></script>
  <script src="${pageContext.request.contextPath}/assets/vendor/purecounter/purecounter_vanilla.js"></script>
  <script src="${pageContext.request.contextPath}/assets/vendor/swiper/swiper-bundle.min.js"></script>

  <!-- Main JS File -->
  <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>

</body>
</html>
