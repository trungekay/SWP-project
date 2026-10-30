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
      <link
        href="https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100;0,300;0,400;0,500;0,700;0,900;1,100;1,300;1,400;1,500;1,700;1,900&family=Poppins:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&family=Raleway:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap"
        rel="stylesheet">

      <!-- Vendor CSS Files -->
      <link href="${pageContext.request.contextPath}/assets/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
      <link href="${pageContext.request.contextPath}/assets/vendor/bootstrap-icons/bootstrap-icons.css"
        rel="stylesheet">
      <link href="${pageContext.request.contextPath}/assets/vendor/aos/aos.css" rel="stylesheet">
      <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">
      <link href="${pageContext.request.contextPath}/assets/vendor/glightbox/css/glightbox.min.css" rel="stylesheet">
      <link href="${pageContext.request.contextPath}/assets/vendor/swiper/swiper-bundle.min.css" rel="stylesheet">

      <!-- Main CSS File -->
      <link href="${pageContext.request.contextPath}/assets/css/main.css" rel="stylesheet">
      <link href="${pageContext.request.contextPath}/assets/css/dentalcare-public.css" rel="stylesheet">
      <c:if test="${param.fullWidth == 'true'}"><link href="${pageContext.request.contextPath}/assets/css/screen-layout.css?v=20261030-wide" rel="stylesheet"></c:if>
      <c:if test="${param.bodyClass == 'admin-catalog-page'}">
        <link href="${pageContext.request.contextPath}/assets/css/admin-catalog.css" rel="stylesheet">
      </c:if>

      <style>
        .custom-dropdown-menu {
            border: none !important;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08) !important;
            border-radius: 10px !important;
            padding: 8px 0 !important;
            min-width: 200px !important;
            margin-top: 5px !important;
            background-color: #fff !important;
        }
        .custom-dropdown-menu li {
            padding: 0;
            margin: 0;
        }
        .custom-dropdown-menu li a {
            padding: 10px 20px !important;
            color: #1e293b !important;
            font-size: 15px !important;
            font-weight: 500 !important;
            transition: all 0.2s !important;
            display: flex !important;
            align-items: center !important;
            justify-content: flex-start !important;
            text-align: left !important;
            width: 100% !important;
        }
        .custom-dropdown-menu li a:hover {
            background-color: #f8fafc !important;
            color: #008b74 !important;
        }
        .custom-dropdown-menu li a.text-danger {
            color: #ef4444 !important;
        }
        .custom-dropdown-menu li a.text-danger:hover {
            background-color: #fef2f2 !important;
            color: #dc2626 !important;
        }
      </style>
    </head>

    <body class="${param.bodyClass}">

      <c:set var="shouldHideHeader" value="${param.hideHeaderForAdmin == 'true' && sessionScope.user.role != 'patient' && not empty sessionScope.user}" />
      <c:if test="${not shouldHideHeader}">
      <header id="header" class="header sticky-top">

        <div class="topbar d-flex align-items-center">
          <div class="container d-flex justify-content-center justify-content-md-between">
            <div class="contact-info d-flex align-items-center">
              <i class="bi bi-envelope d-flex align-items-center"><a
                  href="mailto:hotro.visioncare@gmail.com">hotro.visioncare@gmail.com</a></i>
              <i class="bi bi-phone d-flex align-items-center ms-4"><span>1800 599 988</span></i>
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
                <c:choose>
                  <%-- Cho Patient và Khách vãng lai (Guest) --%>
                  <c:when test="${empty sessionScope.user || sessionScope.user.role == 'patient'}">
                    <li><a href="${pageContext.request.contextPath}/home"
                        class="${param.activeNav == 'home' ? 'active' : ''}">Trang chủ</a></li>
                    <li><a href="${pageContext.request.contextPath}/home#about">Giới thiệu</a></li>
                    <li><a href="${pageContext.request.contextPath}/home#services">Dịch vụ</a></li>
                    <li><a href="${pageContext.request.contextPath}/home#doctors"
                        class="${param.activeNav == 'doctors' ? 'active' : ''}">Bác sĩ</a></li>
                    <li><a href="${pageContext.request.contextPath}/doctor-schedules"
                        class="${param.activeNav == 'schedules' ? 'active' : ''}">Lịch khám bác sĩ</a></li>
                    <li><a href="${pageContext.request.contextPath}/home#contact">Liên hệ</a></li>

                    <c:choose>
                      <c:when test="${not empty sessionScope.user}">
                        <!-- Patient Profile Dropdown -->
                        <li class="dropdown">
                          <a href="#"><span><i class="bi bi-person-circle me-1"></i>${sessionScope.user.fullName != null ?
                              sessionScope.user.fullName : 'Tài khoản'}</span> <i
                              class="bi bi-chevron-down toggle-dropdown"></i></a>
                          <ul class="custom-dropdown-menu">
                            <li><a href="${pageContext.request.contextPath}/views/profile/manage.jsp"><i class="bi bi-person me-2" style="font-size: 16px;"></i> Hồ sơ cá nhân</a></li>
                            <li><a href="${pageContext.request.contextPath}/views/profile/change-password.jsp"><i class="bi bi-key me-2" style="font-size: 16px;"></i> Đổi mật khẩu</a></li>
                            <li><a href="${pageContext.request.contextPath}/views/profile/medical-history.jsp"><i class="bi bi-journal-medical me-2" style="font-size: 16px;"></i> Lịch sử khám bệnh</a></li>
                            <li><a href="${pageContext.request.contextPath}/logout" class="text-danger"><i class="bi bi-box-arrow-right me-2" style="font-size: 16px;"></i> Đăng xuất</a></li>
                          </ul>
                        </li>
                      </c:when>
                      <c:otherwise>
                        <li><a href="${pageContext.request.contextPath}/login"
                            class="${param.activeNav == 'login' ? 'active' : ''}">Đăng nhập</a></li>
                      </c:otherwise>
                    </c:choose>
                  </c:when>

                  <%-- Cho các Actor không phải Patient và Guest (Bác sĩ, Chuyên viên, Nhân viên, Giám đốc, Admin) --%>
                  <c:otherwise>
                    <%-- Menu riêng hiển thị trực tiếp trên thanh điều hướng cho Giám đốc --%>
                    <c:if test="${sessionScope.user.role == 'director' || sessionScope.user.roleId == 2}">
                      <li><a href="${pageContext.request.contextPath}/director/dashboard" class="${param.activeNav == 'dashboard' ? 'active' : ''}"><i class="bi bi-speedometer2 me-1"></i>Bàn làm việc</a></li>
                      <li class="dropdown">
                        <a href="#" class="${param.activeNav == 'doctors' || param.activeNav == 'specialists' || param.activeNav == 'staffs' ? 'active' : ''}">
                          <span><i class="bi bi-calendar3 me-1"></i>Lịch nhân sự</span> <i class="bi bi-chevron-down toggle-dropdown"></i>
                        </a>
                        <ul class="custom-dropdown-menu">
                          <li><a href="${pageContext.request.contextPath}/director/doctors"><i class="bi bi-person-badge me-2" style="font-size: 16px;"></i> Bác sĩ & Lịch trực</a></li>
                          <li><a href="${pageContext.request.contextPath}/director/specialists"><i class="bi bi-clipboard2-pulse me-2" style="font-size: 16px;"></i> KTV / Chuyên viên & Lịch</a></li>
                          <li><a href="${pageContext.request.contextPath}/director/staffs"><i class="bi bi-people me-2" style="font-size: 16px;"></i> Nhân viên & Lịch làm việc</a></li>
                        </ul>
                      </li>
                      <li><a href="${pageContext.request.contextPath}/director/leave-requests" class="${param.activeNav == 'leave-requests' ? 'active' : ''}"><i class="bi bi-calendar-x me-1"></i>Duyệt hủy lịch</a></li>
                      <li><a href="${pageContext.request.contextPath}/director/refunds" class="${param.activeNav == 'refunds' ? 'active' : ''}"><i class="bi bi-cash-coin me-1"></i>Duyệt hoàn tiền</a></li>
                    </c:if>

                    <!-- Employee Profile Dropdown (Chứa Lịch làm việc, Đăng ký lịch, Hồ sơ...) -->
                    <li class="dropdown">
                      <a href="#"><span><i class="bi bi-person-circle me-1"></i>${sessionScope.user.fullName != null ?
                          sessionScope.user.fullName : 'Tài khoản'}</span> <i
                          class="bi bi-chevron-down toggle-dropdown"></i></a>
                      <ul class="custom-dropdown-menu">
                        <c:if test="${sessionScope.user.role == 'staff'}">
                          <li><a href="${pageContext.request.contextPath}/staff/appointments"><i class="bi bi-calendar-check me-2" style="font-size: 16px;"></i> Xem danh sách lịch hẹn</a></li>
                          <li><a href="${pageContext.request.contextPath}/staff/waiting-list"><i class="bi bi-people me-2" style="font-size: 16px;"></i> Hàng đợi phòng khám</a></li>
                        </c:if>
                        <c:if test="${sessionScope.user.role == 'director' || sessionScope.user.roleId == 2}">
                          <li><a href="${pageContext.request.contextPath}/director/dashboard"><i class="bi bi-speedometer2 me-2" style="font-size: 16px;"></i> Bàn làm việc Giám đốc</a></li>
                          <li><a href="${pageContext.request.contextPath}/director/doctors"><i class="bi bi-person-badge me-2" style="font-size: 16px;"></i> Bác sĩ & Lịch trực</a></li>
                          <li><a href="${pageContext.request.contextPath}/director/specialists"><i class="bi bi-clipboard2-pulse me-2" style="font-size: 16px;"></i> KTV / Chuyên viên & Lịch</a></li>
                          <li><a href="${pageContext.request.contextPath}/director/staffs"><i class="bi bi-people me-2" style="font-size: 16px;"></i> Nhân viên & Lịch làm việc</a></li>
                          <li><a href="${pageContext.request.contextPath}/director/leave-requests"><i class="bi bi-calendar-x me-2" style="font-size: 16px;"></i> Duyệt hủy lịch trực</a></li>
                          <li><a href="${pageContext.request.contextPath}/director/refunds"><i class="bi bi-cash-coin me-2" style="font-size: 16px;"></i> Duyệt hoàn tiền</a></li>
                        </c:if>
                        <c:if test="${sessionScope.user.role == 'doctor' || sessionScope.user.role == 'medical_specialist' || sessionScope.user.role == 'specialist' || sessionScope.user.role == 'staff' || sessionScope.user.role == 'director' || sessionScope.user.roleId == 2}">
                          <li><a href="${pageContext.request.contextPath}/employee/schedule"><i class="bi bi-calendar-week me-2" style="font-size: 16px;"></i> Lịch trực cá nhân</a></li>
                          <li><a href="${pageContext.request.contextPath}/employee/register-schedule"><i class="bi bi-calendar-plus me-2" style="font-size: 16px;"></i> Đăng ký lịch</a></li>
                        </c:if>
                        <c:if test="${sessionScope.user.role == 'doctor'}">
                          <li><a href="${pageContext.request.contextPath}/doctor/waiting-list"><i class="bi bi-people me-2" style="font-size: 16px;"></i> Hàng đợi khám bệnh</a></li>
                        </c:if>
                        <li><a href="${pageContext.request.contextPath}/views/profile/manage.jsp"><i class="bi bi-person me-2" style="font-size: 16px;"></i> Hồ sơ cá nhân</a></li>
                        <li><a href="${pageContext.request.contextPath}/views/profile/change-password.jsp"><i class="bi bi-key me-2" style="font-size: 16px;"></i> Đổi mật khẩu</a></li>
                        <li><a href="${pageContext.request.contextPath}/logout" class="text-danger"><i class="bi bi-box-arrow-right me-2" style="font-size: 16px;"></i> Đăng xuất</a></li>
                      </ul>
                    </li>
                  </c:otherwise>
                </c:choose>
              </ul>
              <i class="mobile-nav-toggle d-xl-none bi bi-list"></i>
            </nav>

            <c:choose>
              <c:when test="${sessionScope.user.role == 'director' || sessionScope.user.roleId == 2}">
                <a class="cta-btn d-none d-sm-block bg-teal text-white shadow-sm" href="${pageContext.request.contextPath}/director/dashboard">
                  <i class="bi bi-speedometer2 me-1"></i>Bàn Giám Đốc
                </a>
              </c:when>
              <c:when test="${empty sessionScope.user || sessionScope.user.role == 'patient'}">
                <a class="cta-btn d-none d-sm-block" href="${pageContext.request.contextPath}/book-appointment">Đặt lịch ngay</a>
              </c:when>
            </c:choose>

          </div>

        </div>

      </header>
      </c:if>
