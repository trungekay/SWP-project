<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">

<head>
  <meta charset="utf-8">
  <meta content="width=device-width, initial-scale=1.0" name="viewport">
  <title>${param.pageTitle} — VisionCare</title>
  <meta name="description" content="${param.pageDescription}">
  <meta name="keywords" content="phòng khám mắt, nhãn khoa, đặt lịch, VisionCare, khám mắt">

  <!-- Favicons -->
  <link href="${pageContext.request.contextPath}/assets/img/favicon.png" rel="icon">
  <link href="${pageContext.request.contextPath}/assets/img/apple-touch-icon.png" rel="apple-touch-icon">

  <!-- Fonts -->
  <link href="https://fonts.googleapis.com" rel="preconnect">
  <link href="https://fonts.gstatic.com" rel="preconnect" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100;0,300;0,400;0,500;0,700;0,900;1,100;1,300;1,400;1,500;1,700;1,900&family=Poppins:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&family=Raleway:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap" rel="stylesheet">

  <!-- Vendor CSS Files -->
  <link href="${pageContext.request.contextPath}/assets/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/assets/vendor/bootstrap-icons/bootstrap-icons.css" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/assets/vendor/aos/aos.css" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/assets/vendor/glightbox/css/glightbox.min.css" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/assets/vendor/swiper/swiper-bundle.min.css" rel="stylesheet">

  <!-- Main CSS File -->
  <link href="${pageContext.request.contextPath}/assets/css/main.css" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/assets/css/dentalcare-public.css" rel="stylesheet">
</head>

<body class="${param.bodyClass}">

  <header id="header" class="header sticky-top">

    <div class="topbar d-flex align-items-center">
      <div class="container d-flex justify-content-center justify-content-md-between">
        <div class="contact-info d-flex align-items-center">
          <i class="bi bi-envelope d-flex align-items-center"><a href="mailto:hotro@visioncare.vn">hotro@visioncare.vn</a></i>
          <i class="bi bi-phone d-flex align-items-center ms-4"><span>1800 599 988</span></i>
        </div>
        <div class="social-links d-none d-md-flex align-items-center">
          <a href="#" class="twitter"><i class="bi bi-twitter-x"></i></a>
          <a href="#" class="facebook"><i class="bi bi-facebook"></i></a>
          <a href="#" class="instagram"><i class="bi bi-instagram"></i></a>
          <a href="#" class="linkedin"><i class="bi bi-linkedin"></i></a>
        </div>
      </div>
    </div><!-- End Top Bar -->

    <div class="branding d-flex align-items-center">

      <div class="container position-relative d-flex align-items-center justify-content-between">
        <a href="${pageContext.request.contextPath}/home" class="logo d-flex align-items-center me-auto gap-2">
          <span class="dentalcare-logo-mark"><i class="bi bi-eye"></i></span>
          <h1 class="sitename dentalcare-brand-text mb-0">VisionCare</h1>
        </a>

        <nav id="navmenu" class="navmenu">
          <ul>
            <li><a href="${pageContext.request.contextPath}/home" class="${param.activeNav == 'home' ? 'active' : ''}">Trang chủ</a></li>
            <li><a href="${pageContext.request.contextPath}/home#about">Giới thiệu</a></li>
            <li><a href="${pageContext.request.contextPath}/home#services">Dịch vụ</a></li>
            <li><a href="${pageContext.request.contextPath}/doctor-schedules" class="${param.activeNav == 'doctors' ? 'active' : ''}">Bác sĩ</a></li>
            <li><a href="${pageContext.request.contextPath}/home#contact">Liên hệ</a></li>

            <c:choose>
              <c:when test="${not empty sessionScope.user}">
                <!-- Admin Dropdown -->
                <li class="dropdown">
                  <a href="#"><span>Quản lý (Admin)</span> <i class="bi bi-chevron-down toggle-dropdown"></i></a>
                  <ul>
                    <li><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard Doanh thu</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/users">Quản lý Người dùng</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/clinic-config">Cấu hình Phòng Khám</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/catalog">Quản lý Danh mục (Dịch vụ/Vật tư)</a></li>
                  </ul>
                </li>
                
                <!-- Employee Dropdown -->
                <li class="dropdown">
                  <a href="#"><span>Nhân viên</span> <i class="bi bi-chevron-down toggle-dropdown"></i></a>
                  <ul>
                    <li><a href="${pageContext.request.contextPath}/employee/schedule">Lịch làm việc</a></li>
                  </ul>
                </li>

                <!-- User Profile Dropdown -->
                <li class="dropdown">
                  <a href="#"><span><i class="bi bi-person-circle me-1"></i>${sessionScope.user.fullName != null ? sessionScope.user.fullName : 'Tài khoản'}</span> <i class="bi bi-chevron-down toggle-dropdown"></i></a>
                  <ul>
                    <li><a href="${pageContext.request.contextPath}/profile/manage">Hồ sơ cá nhân</a></li>
                    <li><a href="${pageContext.request.contextPath}/profile/change-password">Đổi mật khẩu</a></li>
                    <li><a href="${pageContext.request.contextPath}/my-appointments">Lịch hẹn của tôi</a></li>
                    <li><a href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
                  </ul>
                </li>
              </c:when>
              <c:otherwise>
                <li><a href="${pageContext.request.contextPath}/login" class="${param.activeNav == 'login' ? 'active' : ''}">Đăng nhập</a></li>
              </c:otherwise>
            </c:choose>
          </ul>
          <i class="mobile-nav-toggle d-xl-none bi bi-list"></i>
        </nav>

        <a class="cta-btn d-none d-sm-block" href="${pageContext.request.contextPath}/book-appointment">Đặt lịch ngay</a>

      </div>

    </div>

  </header>
