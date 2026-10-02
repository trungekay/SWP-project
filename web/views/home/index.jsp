<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%-- Include Header --%>
<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Trang chủ" />
  <jsp:param name="pageDescription" value="VisionCare — Hệ thống đặt lịch khám mắt trực tuyến" />
  <jsp:param name="bodyClass" value="index-page" />
  <jsp:param name="activeNav" value="home" />
</jsp:include>

  <main class="main">

    <!-- Hero Section -->
    <section id="hero" class="hero section light-background">

      <img src="${pageContext.request.contextPath}/assets/img/hero-bg.jpg" alt="" data-aos="fade-in">

      <div class="container position-relative">

        <div class="welcome position-relative" data-aos="fade-down" data-aos-delay="100">
          <h2>CHÀO MỪNG ĐẾN VISIONCARE</h2>
          <p>Phòng khám mắt chuyên sâu — đặt lịch khám trực tuyến, trang thiết bị hiện đại, đội ngũ bác sĩ nhãn khoa giàu kinh nghiệm</p>
        </div><!-- End Welcome -->

        <div class="content row gy-4">
          <div class="col-lg-4 d-flex align-items-stretch">
            <div class="why-box" data-aos="zoom-out" data-aos-delay="200">
              <h3>Vì sao chọn VisionCare?</h3>
              <p>
                Trang thiết bị nhãn khoa hiện đại nhập khẩu, quy trình khám chuẩn quốc tế và lộ trình điều trị rõ ràng.
                Bạn có thể xem lịch bác sĩ, chọn khung giờ phù hợp và đặt lịch chỉ trong vài phút — không cần gọi điện chờ đợi.
              </p>
              <div class="text-center hero-booking-cta">
                <a href="#about" class="more-btn"><span>Tìm hiểu thêm</span> <i class="bi bi-chevron-right"></i></a>
                <a href="${pageContext.request.contextPath}/book-appointment" class="btn btn-dental ms-2 mt-2 mt-md-0 d-inline-block">Đặt lịch ngay</a>
              </div>
            </div>
          </div><!-- End Why Box -->

          <div class="col-lg-8 d-flex align-items-stretch">
            <div class="d-flex flex-column justify-content-center">
              <div class="row gy-4">

                <div class="col-xl-4 d-flex align-items-stretch">
                  <div class="icon-box" data-aos="zoom-out" data-aos-delay="300">
                    <i class="bi bi-calendar2-check"></i>
                    <h4>Đặt lịch trực tuyến 24/7</h4>
                    <p>Chọn bác sĩ nhãn khoa, ngày và khung giờ phù hợp mọi lúc trên website hoặc sau khi đăng nhập.</p>
                  </div>
                </div><!-- End Icon Box -->

                <div class="col-xl-4 d-flex align-items-stretch">
                  <div class="icon-box" data-aos="zoom-out" data-aos-delay="400">
                    <i class="bi bi-shield-check"></i>
                    <h4>Thiết bị chuẩn quốc tế</h4>
                    <p>Máy đo khúc xạ, OCT, máy phẫu thuật LASIK nhập khẩu, đảm bảo kết quả chính xác.</p>
                  </div>
                </div><!-- End Icon Box -->

                <div class="col-xl-4 d-flex align-items-stretch">
                  <div class="icon-box" data-aos="zoom-out" data-aos-delay="500">
                    <i class="bi bi-credit-card"></i>
                    <h4>Thanh toán linh hoạt</h4>
                    <p>Hỗ trợ VNPay, MoMo hoặc thanh toán trực tiếp tại phòng khám, hợp tác bảo hiểm y tế.</p>
                  </div>
                </div><!-- End Icon Box -->

              </div>
            </div>
          </div>
        </div><!-- End  Content-->

      </div>

    </section><!-- /Hero Section -->

    <!-- About Section -->
    <section id="about" class="about section">

      <div class="container">

        <div class="row gy-4 gx-5">

          <div class="col-lg-6 position-relative align-self-start" data-aos="fade-up" data-aos-delay="200">
            <img src="${pageContext.request.contextPath}/assets/img/about.jpg" class="img-fluid" alt="">
            <a href="https://www.youtube.com/watch?v=Y7f98aduVJ8" class="glightbox pulsating-play-btn"></a>
          </div>

          <div class="col-lg-6 content" data-aos="fade-up" data-aos-delay="100">
            <h3>Về VisionCare</h3>
            <p>
              VisionCare là phòng khám mắt chuyên sâu hàng đầu, quy tụ đội ngũ bác sĩ nhãn khoa giàu kinh nghiệm cùng hệ thống trang thiết bị hiện đại nhập khẩu. Chúng tôi cam kết mang lại trải nghiệm khám chữa bệnh minh bạch, an toàn và hiệu quả.
            </p>
            <ul>
              <li>
                <i class="fa-solid fa-eye"></i>
                <div>
                  <h5>Khám mắt toàn diện</h5>
                  <p>Đo thị lực, áp lực nhãn cầu, soi đáy mắt và tư vấn lộ trình điều trị rõ ràng cho từng bệnh nhân.</p>
                </div>
              </li>
              <li>
                <i class="fa-solid fa-microscope"></i>
                <div>
                  <h5>Thiết bị chẩn đoán hiện đại</h5>
                  <p>Hệ thống OCT, máy đo khúc xạ tự động, máy chụp đáy mắt kỹ thuật số cho kết quả chính xác.</p>
                </div>
              </li>
              <li>
                <i class="fa-solid fa-user-doctor"></i>
                <div>
                  <h5>Bác sĩ chuyên khoa giàu kinh nghiệm</h5>
                  <p>Đội ngũ bác sĩ được đào tạo chuyên sâu trong và ngoài nước, nhiều năm kinh nghiệm thực tiễn.</p>
                </div>
              </li>
            </ul>
          </div>

        </div>

      </div>

      <!-- Gallery Section (Moved inside About) -->
      <div class="gallery pt-0 mt-5">
        <!-- Section Title -->
        <div class="container section-title" data-aos="fade-up">
          <h2>Hình ảnh phòng khám</h2>
          <p>Không gian hiện đại, sạch sẽ và thân thiện tại VisionCare — nơi bạn an tâm chăm sóc đôi mắt</p>
        </div><!-- End Section Title -->

        <div class="container-fluid" data-aos="fade-up" data-aos-delay="100">
          <div class="row g-0">
            <c:forEach var="i" begin="1" end="8">
              <div class="col-lg-3 col-md-4">
                <div class="gallery-item">
                  <a href="${pageContext.request.contextPath}/assets/img/gallery/gallery-${i}.jpg" class="glightbox" data-gallery="images-gallery">
                    <img src="${pageContext.request.contextPath}/assets/img/gallery/gallery-${i}.jpg" alt="" class="img-fluid">
                  </a>
                </div>
              </div><!-- End Gallery Item -->
            </c:forEach>
          </div>
        </div>
      </div>

    </section><!-- /About Section -->

    <!-- Stats Section -->
    <section id="stats" class="stats section light-background">

      <div class="container" data-aos="fade-up" data-aos-delay="100">

        <div class="row gy-4">

          <div class="col-lg-3 col-md-6 d-flex flex-column align-items-center">
            <i class="fa-solid fa-user-doctor"></i>
            <div class="stats-item">
              <span data-purecounter-start="0" data-purecounter-end="85" data-purecounter-duration="1" class="purecounter"></span>
              <p>Bác sĩ</p>
            </div>
          </div><!-- End Stats Item -->

          <div class="col-lg-3 col-md-6 d-flex flex-column align-items-center">
            <i class="fa-regular fa-hospital"></i>
            <div class="stats-item">
              <span data-purecounter-start="0" data-purecounter-end="18" data-purecounter-duration="1" class="purecounter"></span>
              <p>Chuyên khoa</p>
            </div>
          </div><!-- End Stats Item -->

          <div class="col-lg-3 col-md-6 d-flex flex-column align-items-center">
            <i class="fas fa-flask"></i>
            <div class="stats-item">
              <span data-purecounter-start="0" data-purecounter-end="12" data-purecounter-duration="1" class="purecounter"></span>
              <p>Ca khám / ngày</p>
            </div>
          </div><!-- End Stats Item -->

          <div class="col-lg-3 col-md-6 d-flex flex-column align-items-center">
            <i class="fas fa-award"></i>
            <div class="stats-item">
              <span data-purecounter-start="0" data-purecounter-end="150" data-purecounter-duration="1" class="purecounter"></span>
              <p>Năm kinh nghiệm</p>
            </div>
          </div><!-- End Stats Item -->

        </div>

      </div>

    </section><!-- /Stats Section -->

    <!-- Services Section: same Service_Catalog rows as the admin page -->
    <section id="services" class="services section light-background">
      <span id="service"></span>
      <div class="container section-title" data-aos="fade-up">
        <h2>Dịch vụ nhãn khoa</h2>
        <p>Các dịch vụ thăm khám và điều trị mắt tại VisionCare</p>
      </div>
      <div class="container"><div class="row gy-4">
        <c:forEach items="${catalogServices}" var="service">
          <div class="col-lg-4 col-md-6" data-aos="fade-up">
            <div class="card service-card border-0 shadow-sm h-100">
              <c:choose>
                <c:when test="${service.uploadedImage}">
                  <img src="${pageContext.request.contextPath}/catalog-image?kind=service&amp;id=${service.id}" class="card-img-top" alt="${fn:escapeXml(service.name)}" style="height: 200px; object-fit: cover;">
                </c:when>
                <c:otherwise>
                  <img src="${pageContext.request.contextPath}/assets/img/${empty service.image ? 'departments-1.jpg' : fn:escapeXml(service.image)}" class="card-img-top" alt="${fn:escapeXml(service.name)}" style="height: 200px; object-fit: cover;">
                </c:otherwise>
              </c:choose>
              <div class="card-body p-4 text-center">
                <h4 class="card-title fw-bold mb-3"><c:out value="${service.name}" /></h4>
                <p class="card-text text-muted mb-2"><c:out value="${service.summary}" /></p>
                <p class="fw-semibold mb-4"><c:out value="${service.price}" /> VNĐ</p>
                <a href="#departments" onclick="document.getElementById('department-link-${service.id}').click();" class="btn btn-outline-primary rounded-pill px-4">Tìm hiểu thêm</a>
              </div>
            </div>
          </div>
        </c:forEach>
      </div></div>
    </section><!-- /Services Section -->

    <!-- Appointment Section -->
    <section id="appointment" class="appointment section">

      <!-- Section Title -->
      <div class="container section-title" data-aos="fade-up">
        <h2>Đặt lịch khám mắt</h2>
        <p>Hoàn tất đặt lịch qua form nhiều bước: chọn chuyên khoa, bác sĩ nhãn khoa, thời gian và phương thức thanh toán</p>
      </div><!-- End Section Title -->

      <div class="container" data-aos="fade-up" data-aos-delay="100">
        <div class="booking-promo text-center">
          <h3 class="mb-3">Sẵn sàng đặt lịch khám mắt?</h3>
          <p class="text-muted mb-4">Xem <a href="${pageContext.request.contextPath}/doctor-schedules">danh sách bác sĩ nhãn khoa &amp; lịch trống</a> hoặc bắt đầu form đặt lịch ngay bên dưới.</p>
          <a href="${pageContext.request.contextPath}/book-appointment" class="btn btn-dental btn-lg">Bắt đầu đặt lịch <i class="bi bi-arrow-right ms-2"></i></a>
        </div>
      </div>

    </section><!-- /Appointment Section -->

    <!-- Departments Section: details from Service_Catalog -->
    <section id="departments" class="departments section">
      <div class="container section-title" data-aos="fade-up">
        <h2>Chuyên khoa</h2>
        <p>Thông tin chi tiết các dịch vụ và chuyên khoa tại VisionCare</p>
      </div>
      <div class="container" data-aos="fade-up" data-aos-delay="100">
        <div class="row">
          <div class="col-lg-3"><ul class="nav nav-tabs flex-column">
            <c:forEach items="${catalogServices}" var="service" varStatus="status">
              <li class="nav-item"><a id="department-link-${service.id}" class="nav-link ${status.first ? 'active show' : ''}" data-bs-toggle="tab" href="#departments-tab-${service.id}"><c:out value="${service.name}" /></a></li>
            </c:forEach>
          </ul></div>
          <div class="col-lg-9 mt-4 mt-lg-0"><div class="tab-content">
            <c:forEach items="${catalogServices}" var="service" varStatus="status">
              <div class="tab-pane ${status.first ? 'active show' : ''}" id="departments-tab-${service.id}">
                <div class="row">
                  <div class="col-lg-8 details order-2 order-lg-1">
                    <h3><c:out value="${service.name}" /></h3>
                    <c:if test="${not empty service.specialty}"><p class="fw-semibold"><c:out value="${service.specialty}" /></p></c:if>
                    <p class="fst-italic"><c:out value="${service.summary}" /></p>
                    <p><c:out value="${service.description}" /></p>
                  </div>
                  <div class="col-lg-4 text-center order-1 order-lg-2">
                    <c:choose>
                      <c:when test="${service.uploadedImage}"><img src="${pageContext.request.contextPath}/catalog-image?kind=service&amp;id=${service.id}" alt="${fn:escapeXml(service.name)}" class="img-fluid"></c:when>
                      <c:otherwise><img src="${pageContext.request.contextPath}/assets/img/${empty service.image ? 'departments-1.jpg' : fn:escapeXml(service.image)}" alt="${fn:escapeXml(service.name)}" class="img-fluid"></c:otherwise>
                    </c:choose>
                  </div>
                </div>
              </div>
            </c:forEach>
          </div></div>
        </div>
      </div>
    </section><!-- /Departments Section -->

    <!-- Doctors Section -->
    <section id="doctors" class="doctors section">

      <!-- Section Title -->
      <div class="container section-title" data-aos="fade-up">
        <h2>Đội ngũ bác sĩ nhãn khoa</h2>
        <p>Một số bác sĩ tiêu biểu — xem đầy đủ lịch và đặt khám tại trang danh sách bác sĩ</p>
      </div><!-- End Section Title -->

      <div class="container">

        <div class="row gy-4">

          <%-- Render bác sĩ từ database (Sử dụng cấu trúc Card hiện đại) --%>
          <c:forEach var="doc" items="${doctors}" varStatus="loop">
            <div class="col-lg-4 col-md-6" data-aos="fade-up" data-aos-delay="${(loop.index + 1) * 100}">
              <div class="card doctor-card border-0 shadow-sm h-100 text-center">
                <div class="card-img-top overflow-hidden mt-4 mx-auto" style="width: 180px; height: 180px; border-radius: 50%; box-shadow: 0px 4px 10px rgba(0,0,0,0.1);">
                  <img src="${pageContext.request.contextPath}/assets/img/${not empty doc.image ? doc.image : 'doctors/doctors-1.jpg'}" class="img-fluid w-100 h-100" style="object-fit: cover;" alt="${doc.name}">
                </div>
                <div class="card-body p-4">
                  <h4 class="card-title fw-bold mb-1" style="color: var(--heading-color);">${doc.name}</h4>
                  <p class="text-primary small fw-semibold mb-3"><i class="bi bi-award me-1"></i> ${doc.specialty}</p>
                  <p class="card-text mb-4 text-muted" style="font-size: 0.95rem;">${doc.description}</p>
                  <div class="d-flex justify-content-center gap-2">
                    <a href="${pageContext.request.contextPath}/book-appointment?doc=${doc.id}" class="btn btn-primary rounded-pill px-4 shadow-sm">Đặt lịch</a>
                    <button type="button" class="btn btn-outline-info rounded-pill px-4 shadow-sm" data-bs-toggle="modal" data-bs-target="#homeDoctorModal${doc.id}">Xem chi tiết</button>
                  </div>
                </div>
              </div>
            </div><!-- End Team Member -->

            <!-- Doctor Detail Modal (Home) -->
            <div class="modal fade" id="homeDoctorModal${doc.id}" tabindex="-1" aria-labelledby="homeDoctorModalLabel${doc.id}" aria-hidden="true">
              <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content border-0 shadow">
                  <div class="modal-header border-0 pb-0">
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                  </div>
                  <div class="modal-body p-4 pt-0">
                    <div class="row">
                      <div class="col-md-4 text-center border-end">
                        <img src="${pageContext.request.contextPath}/assets/img/${not empty doc.image ? doc.image : 'doctors/doctors-1.jpg'}" class="img-fluid rounded-circle shadow-sm mb-3" style="width: 180px; height: 180px; object-fit: cover;" alt="${doc.name}">
                        <h4 class="fw-bold text-primary mb-1">${doc.name}</h4>
                        <p class="text-muted mb-3"><i class="bi bi-award me-1"></i> ${doc.specialty}</p>
                        <a href="${pageContext.request.contextPath}/book-appointment?doc=${doc.id}" class="btn btn-primary rounded-pill w-100 mt-2">Đặt lịch ngay</a>
                        <a href="${pageContext.request.contextPath}/doctor-schedules?specialty=all" class="btn btn-outline-primary rounded-pill w-100 mt-2">Xem lịch khám</a>
                      </div>
                      <div class="col-md-8 px-4 text-start">
                        <h5 class="fw-bold text-dark border-bottom pb-2 mb-3">Tiểu sử chuyên môn</h5>
                        <p class="text-muted mb-4" style="line-height: 1.6;">${not empty doc.biography ? doc.biography : doc.description}</p>
                        
                        <h5 class="fw-bold text-dark border-bottom pb-2 mb-3">Thành tích & Học vấn</h5>
                        <div class="text-muted" style="line-height: 1.8;">
                          ${not empty doc.achievements ? doc.achievements : 'Đang cập nhật...'}
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <!-- End Modal -->
          </c:forEach>

        </div>

      </div>

    </section><!-- /Doctors Section -->

    <!-- Faq Section -->
    <section id="faq" class="faq section light-background">

      <!-- Section Title -->
      <div class="container section-title" data-aos="fade-up">
        <h2>Câu hỏi thường gặp</h2>
        <p>Những câu hỏi phổ biến về khám mắt, đặt lịch và các dịch vụ tại VisionCare</p>
      </div><!-- End Section Title -->

      <div class="container">

        <div class="row justify-content-center">

          <div class="col-lg-10" data-aos="fade-up" data-aos-delay="100">

            <div class="faq-container">

              <div class="faq-item faq-active">
                <h3>Tôi cần chuẩn bị gì trước khi khám mắt tại VisionCare?</h3>
                <div class="faq-content">
                  <p>Bạn nên mang theo kính đang đeo (nếu có), sổ khám bệnh cũ và thẻ bảo hiểm y tế. Nếu khám để phẫu thuật LASIK, cần ngừng đeo kính áp tròng ít nhất 1 tuần trước ngày thăm khám tiền phẫu.</p>
                </div>
                <i class="faq-toggle bi bi-chevron-right"></i>
              </div><!-- End Faq item-->

              <div class="faq-item">
                <h3>Phẫu thuật LASIK có đau không? Bao lâu thì hồi phục?</h3>
                <div class="faq-content">
                  <p>Phẫu thuật LASIK thực hiện dưới gây tê nhỏ mắt, hầu như không đau. Thị lực cải thiện rõ rệt sau 24–48 giờ. Bạn có thể quay lại làm việc văn phòng sau 2–3 ngày và lái xe sau khoảng 1 tuần.</p>
                </div>
                <i class="faq-toggle bi bi-chevron-right"></i>
              </div><!-- End Faq item-->

              <div class="faq-item">
                <h3>Bảo hiểm y tế có được áp dụng tại VisionCare không?</h3>
                <div class="faq-content">
                  <p>VisionCare hỗ trợ thanh toán bảo hiểm y tế cho các dịch vụ khám tổng quát và điều trị nội khoa. Một số dịch vụ thẩm mỹ hoặc phẫu thuật khúc xạ chưa được BHYT chi trả — vui lòng liên hệ lễ tân để được tư vấn cụ thể.</p>
                </div>
                <i class="faq-toggle bi bi-chevron-right"></i>
              </div><!-- End Faq item-->

              <div class="faq-item">
                <h3>Trẻ bao nhiêu tuổi có thể đưa đến khám mắt?</h3>
                <div class="faq-content">
                  <p>VisionCare khám mắt cho trẻ từ 6 tháng tuổi trở lên. Khuyến nghị khám sàng lọc lần đầu khi trẻ 3 tuổi để phát hiện sớm nhược thị, lác mắt và tật khúc xạ.</p>
                </div>
                <i class="faq-toggle bi bi-chevron-right"></i>
              </div><!-- End Faq item-->

              <div class="faq-item">
                <h3>Làm thế nào để đặt lịch khám tại VisionCare?</h3>
                <div class="faq-content">
                  <p>Bạn có thể đặt lịch trực tuyến 24/7 qua nút "Đặt lịch ngay" trên website, gọi hotline 1800 599 988 hoặc nhắn tin qua Zalo/Facebook. Lịch hẹn sẽ được xác nhận qua SMS/email trong vòng 15 phút.</p>
                </div>
                <i class="faq-toggle bi bi-chevron-right"></i>
              </div><!-- End Faq item-->

              <div class="faq-item">
                <h3>Tôi có thể huỷ hoặc đổi lịch hẹn không?</h3>
                <div class="faq-content">
                  <p>Có, bạn có thể hủy hoặc đổi lịch hẹn miễn phí trước giờ khám ít nhất 2 tiếng, bằng cách đăng nhập tài khoản hoặc gọi hotline. Vui lòng thông báo sớm để bác sĩ có thể sắp xếp cho bệnh nhân khác.</p>
                </div>
                <i class="faq-toggle bi bi-chevron-right"></i>
              </div><!-- End Faq item-->

            </div>

          </div><!-- End Faq Column-->

        </div>

      </div>

    </section><!-- /Faq Section -->



    <!-- Contact Section -->
    <!-- Contact Section -->
    <section id="contact" class="contact section light-background">
      <style>
        .contact-card {
          transition: all 0.3s ease;
          border-bottom: 3px solid transparent;
        }
        .contact-card:hover {
          transform: translateY(-10px);
          box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1) !important;
          border-bottom: 3px solid var(--accent-color);
        }
        .contact-card .icon-circle {
          transition: all 0.3s ease;
          background-color: color-mix(in srgb, var(--accent-color), transparent 90%);
        }
        .contact-card .icon-circle i {
          color: var(--accent-color);
          transition: all 0.3s ease;
        }
        .contact-card:hover .icon-circle {
          background-color: var(--accent-color);
        }
        .contact-card:hover .icon-circle i {
          color: #ffffff;
        }
      </style>

      <!-- Section Title -->
      <div class="container section-title" data-aos="fade-up">
        <h2>Liên hệ</h2>
        <p>Thông tin liên hệ của VisionCare — chúng tôi luôn sẵn sàng hỗ trợ bạn</p>
      </div><!-- End Section Title -->

      <div class="container" data-aos="fade-up" data-aos-delay="100">
        <div class="row gy-4 justify-content-center">

          <div class="col-lg-4 col-md-6" data-aos="fade-up" data-aos-delay="200">
            <div class="contact-card info-box text-center p-5 shadow-sm rounded-4 h-100 bg-white">
              <div class="icon-circle mb-4 mx-auto d-flex align-items-center justify-content-center" style="width: 80px; height: 80px; border-radius: 50%;">
                <i class="bi bi-geo-alt fs-1"></i>
              </div>
              <h4 class="fw-bold mb-3" style="color: var(--heading-color);">Địa chỉ</h4>
              <p class="text-muted mb-0">456 Lê Thị Riêng<br>Quận 10, TP.HCM</p>
            </div>
          </div>

          <div class="col-lg-4 col-md-6" data-aos="fade-up" data-aos-delay="300">
            <div class="contact-card info-box text-center p-5 shadow-sm rounded-4 h-100 bg-white">
              <div class="icon-circle mb-4 mx-auto d-flex align-items-center justify-content-center" style="width: 80px; height: 80px; border-radius: 50%;">
                <i class="bi bi-telephone fs-1"></i>
              </div>
              <h4 class="fw-bold mb-3" style="color: var(--heading-color);">Hotline</h4>
              <p class="text-muted mb-0">1800 599 988<br>Tư vấn 24/7</p>
            </div>
          </div>

          <div class="col-lg-4 col-md-6" data-aos="fade-up" data-aos-delay="400">
            <div class="contact-card info-box text-center p-5 shadow-sm rounded-4 h-100 bg-white">
              <div class="icon-circle mb-4 mx-auto d-flex align-items-center justify-content-center" style="width: 80px; height: 80px; border-radius: 50%;">
                <i class="bi bi-envelope fs-1"></i>
              </div>
              <h4 class="fw-bold mb-3" style="color: var(--heading-color);">Email</h4>
              <p class="text-muted mb-0"><a href="mailto:hotro@visioncare.vn" class="text-muted text-decoration-none">hotro@visioncare.vn</a><br><a href="mailto:contact@visioncare.vn" class="text-muted text-decoration-none">contact@visioncare.vn</a></p>
            </div>
          </div>

        </div>
      </div>

    </section><!-- /Contact Section -->

  </main>

<%-- Include Footer --%>
<jsp:include page="/views/common/footer.jsp" />
