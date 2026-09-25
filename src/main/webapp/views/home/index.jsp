<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

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

    <!-- Services Section -->
    <section id="services" class="services section">

      <!-- Section Title -->
      <div class="container section-title" data-aos="fade-up">
        <h2>Dịch vụ nhãn khoa</h2>
        <p>Các dịch vụ thăm khám và điều trị mắt tại VisionCare — đặt lịch tư vấn để được bác sĩ thăm khám cụ thể</p>
      </div><!-- End Section Title -->

      <div class="container">

        <div class="row gy-4">

          <div class="col-lg-4 col-md-6" data-aos="fade-up" data-aos-delay="100">
            <div class="service-item  position-relative">
              <div class="icon">
                <i class="fas fa-eye"></i>
              </div>
              <a href="${pageContext.request.contextPath}/book-appointment" class="stretched-link">
                <h3>Khám mắt tổng quát</h3>
              </a>
              <p>Đo thị lực, kiểm tra áp lực nhãn cầu, soi đáy mắt và tư vấn chăm sóc mắt định kỳ.</p>
            </div>
          </div><!-- End Service Item -->

          <div class="col-lg-4 col-md-6" data-aos="fade-up" data-aos-delay="200">
            <div class="service-item position-relative">
              <div class="icon">
                <i class="fas fa-glasses"></i>
              </div>
              <a href="${pageContext.request.contextPath}/book-appointment" class="stretched-link">
                <h3>Đo khúc xạ &amp; Kính</h3>
              </a>
              <p>Đo khúc xạ chính xác, tư vấn kính cận/viễn/loạn, kính áp tròng phù hợp từng bệnh nhân.</p>
            </div>
          </div><!-- End Service Item -->

          <div class="col-lg-4 col-md-6" data-aos="fade-up" data-aos-delay="300">
            <div class="service-item position-relative">
              <div class="icon">
                <i class="fas fa-child"></i>
              </div>
              <a href="${pageContext.request.contextPath}/book-appointment" class="stretched-link">
                <h3>Nhãn khoa trẻ em</h3>
              </a>
              <p>Sàng lọc cận thị sớm, điều trị nhược thị, lác mắt — phòng khám thân thiện cho bé.</p>
            </div>
          </div><!-- End Service Item -->

          <div class="col-lg-4 col-md-6" data-aos="fade-up" data-aos-delay="400">
            <div class="service-item position-relative">
              <div class="icon">
                <i class="fas fa-laser-pointer"></i>
              </div>
              <a href="${pageContext.request.contextPath}/book-appointment" class="stretched-link">
                <h3>Phẫu thuật LASIK</h3>
              </a>
              <p>Phẫu thuật khúc xạ laser LASIK/SMILE điều trị cận thị, viễn thị, loạn thị vĩnh viễn.</p>
            </div>
          </div><!-- End Service Item -->

          <div class="col-lg-4 col-md-6" data-aos="fade-up" data-aos-delay="500">
            <div class="service-item position-relative">
              <div class="icon">
                <i class="fas fa-cloud-sun"></i>
              </div>
              <a href="${pageContext.request.contextPath}/book-appointment" class="stretched-link">
                <h3>Đục thủy tinh thể</h3>
              </a>
              <p>Phẫu thuật thay thể thủy tinh nhân tạo (IOL) điều trị đục thủy tinh thể an toàn, hiệu quả.</p>
            </div>
          </div><!-- End Service Item -->

          <div class="col-lg-4 col-md-6" data-aos="fade-up" data-aos-delay="600">
            <div class="service-item position-relative">
              <div class="icon">
                <i class="fas fa-notes-medical"></i>
              </div>
              <a href="${pageContext.request.contextPath}/book-appointment" class="stretched-link">
                <h3>Glaucoma &amp; Võng mạc</h3>
              </a>
              <p>Chẩn đoán và điều trị glaucoma, bệnh võng mạc tiểu đường — can thiệp sớm bảo vệ thị lực.</p>
            </div>
          </div><!-- End Service Item -->

        </div>

      </div>

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

    <!-- Departments Section -->
    <section id="departments" class="departments section">

      <!-- Section Title -->
      <div class="container section-title" data-aos="fade-up">
        <h2>Chuyên khoa</h2>
        <p>Các chuyên khoa nhãn khoa chuyên sâu tại VisionCare — đội ngũ bác sĩ được đào tạo bài bản trong và ngoài nước</p>
      </div><!-- End Section Title -->

      <div class="container" data-aos="fade-up" data-aos-delay="100">

        <div class="row">
          <div class="col-lg-3">
            <ul class="nav nav-tabs flex-column">
              <li class="nav-item">
                <a class="nav-link active show" data-bs-toggle="tab" href="#departments-tab-1">Nhãn khoa tổng quát</a>
              </li>
              <li class="nav-item">
                <a class="nav-link" data-bs-toggle="tab" href="#departments-tab-2">Khúc xạ &amp; Kính</a>
              </li>
              <li class="nav-item">
                <a class="nav-link" data-bs-toggle="tab" href="#departments-tab-3">Phẫu thuật LASIK</a>
              </li>
              <li class="nav-item">
                <a class="nav-link" data-bs-toggle="tab" href="#departments-tab-4">Nhãn khoa trẻ em</a>
              </li>
              <li class="nav-item">
                <a class="nav-link" data-bs-toggle="tab" href="#departments-tab-5">Glaucoma &amp; Võng mạc</a>
              </li>
            </ul>
          </div>
          <div class="col-lg-9 mt-4 mt-lg-0">
            <div class="tab-content">
              <div class="tab-pane active show" id="departments-tab-1">
                <div class="row">
                  <div class="col-lg-8 details order-2 order-lg-1">
                    <h3>Nhãn khoa tổng quát</h3>
                    <p class="fst-italic">Khám và chẩn đoán toàn diện các bệnh lý về mắt, phù hợp với mọi lứa tuổi.</p>
                    <p>Bao gồm đo thị lực, kiểm tra áp lực nhãn cầu, soi đáy mắt, đánh giá tình trạng giác mạc và thủy tinh thể. Bác sĩ sẽ tư vấn lộ trình điều trị phù hợp, minh bạch chi phí trước khi thực hiện.</p>
                  </div>
                  <div class="col-lg-4 text-center order-1 order-lg-2">
                    <img src="${pageContext.request.contextPath}/assets/img/departments-1.jpg" alt="Nhãn khoa tổng quát" class="img-fluid">
                  </div>
                </div>
              </div>
              <div class="tab-pane" id="departments-tab-2">
                <div class="row">
                  <div class="col-lg-8 details order-2 order-lg-1">
                    <h3>Khúc xạ &amp; Kính</h3>
                    <p class="fst-italic">Đo khúc xạ chính xác bằng máy tự động, tư vấn kính phù hợp với từng nhu cầu.</p>
                    <p>Dịch vụ đo và cắt kính cận, viễn, loạn thị; tư vấn kính áp tròng hàng ngày, hàng tháng. Hỗ trợ chương trình Ortho-K kiểm soát cận thị cho trẻ em.</p>
                  </div>
                  <div class="col-lg-4 text-center order-1 order-lg-2">
                    <img src="${pageContext.request.contextPath}/assets/img/departments-2.jpg" alt="Khúc xạ và Kính" class="img-fluid">
                  </div>
                </div>
              </div>
              <div class="tab-pane" id="departments-tab-3">
                <div class="row">
                  <div class="col-lg-8 details order-2 order-lg-1">
                    <h3>Phẫu thuật LASIK &amp; SMILE</h3>
                    <p class="fst-italic">Phẫu thuật khúc xạ laser hiện đại, điều trị dứt điểm cận thị, viễn thị, loạn thị.</p>
                    <p>VisionCare trang bị hệ thống laser Excimer thế hệ mới nhất. Quy trình thăm khám tiền phẫu kỹ lưỡng, theo dõi hậu phẫu miễn phí trong 12 tháng, cam kết hoàn tiền nếu không đạt kết quả.</p>
                  </div>
                  <div class="col-lg-4 text-center order-1 order-lg-2">
                    <img src="${pageContext.request.contextPath}/assets/img/departments-3.jpg" alt="Phẫu thuật LASIK" class="img-fluid">
                  </div>
                </div>
              </div>
              <div class="tab-pane" id="departments-tab-4">
                <div class="row">
                  <div class="col-lg-8 details order-2 order-lg-1">
                    <h3>Nhãn khoa trẻ em</h3>
                    <p class="fst-italic">Sàng lọc, phát hiện và điều trị sớm các bệnh mắt ở trẻ em.</p>
                    <p>Khám tật khúc xạ, nhược thị, lác mắt cho trẻ từ 6 tháng tuổi. Phòng khám thiết kế thân thiện, nhẹ nhàng, giúp bé thoải mái trong suốt quá trình thăm khám và điều trị.</p>
                  </div>
                  <div class="col-lg-4 text-center order-1 order-lg-2">
                    <img src="${pageContext.request.contextPath}/assets/img/departments-4.jpg" alt="Nhãn khoa trẻ em" class="img-fluid">
                  </div>
                </div>
              </div>
              <div class="tab-pane" id="departments-tab-5">
                <div class="row">
                  <div class="col-lg-8 details order-2 order-lg-1">
                    <h3>Glaucoma &amp; Bệnh lý Võng mạc</h3>
                    <p class="fst-italic">Chẩn đoán và điều trị chuyên sâu glaucoma, bệnh võng mạc tiểu đường và thoái hóa điểm vàng.</p>
                    <p>Sử dụng OCT và máy phân tích lớp sợi thần kinh thị giác để phát hiện sớm glaucoma. Điều trị bằng thuốc, laser hoặc phẫu thuật tùy giai đoạn bệnh, theo dõi định kỳ bảo vệ thị lực lâu dài.</p>
                  </div>
                  <div class="col-lg-4 text-center order-1 order-lg-2">
                    <img src="${pageContext.request.contextPath}/assets/img/departments-5.jpg" alt="Glaucoma và Võng mạc" class="img-fluid">
                  </div>
                </div>
              </div>
            </div>
          </div>
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

          <%-- Render bác sĩ từ database --%>
          <c:forEach var="doc" items="${doctors}" varStatus="loop">
            <div class="col-lg-6" data-aos="fade-up" data-aos-delay="${(loop.index + 1) * 100}">
              <div class="team-member d-flex align-items-start">
                <div class="pic"><img src="${pageContext.request.contextPath}/assets/img/${doc.image}" class="img-fluid" alt="${doc.name}"></div>
                <div class="member-info">
                  <h4>${doc.name}</h4>
                  <span>${doc.specialty}</span>
                  <p>${doc.description}</p>
                  <p class="mb-0"><a href="${pageContext.request.contextPath}/book-appointment?doc=${doc.id}" class="btn btn-sm btn-outline-primary rounded-pill">Đặt lịch</a>
                    <a href="${pageContext.request.contextPath}/doctor-schedules" class="ms-2 small">Xem lịch</a></p>
                </div>
              </div>
            </div><!-- End Team Member -->
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

    <!-- Gallery Section -->
    <section id="gallery" class="gallery section">

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

    </section><!-- /Gallery Section -->

    <!-- Contact Section -->
    <section id="contact" class="contact section">

      <!-- Section Title -->
      <div class="container section-title" data-aos="fade-up">
        <h2>Liên hệ</h2>
        <p>Gửi câu hỏi hoặc phản hồi cho VisionCare — chúng tôi luôn sẵn sàng hỗ trợ bạn</p>
      </div><!-- End Section Title -->

      <div class="mb-5" data-aos="fade-up" data-aos-delay="200">
        <iframe style="border:0; width: 100%; height: 270px;" src="https://www.google.com/maps/embed?pb=!1m14!1m8!1m3!1d48389.78314118045!2d-74.006138!3d40.710059!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x89c25a22a3bda30d%3A0xb89d1fe6bc499443!2sDowntown%20Conference%20Center!5e0!3m2!1sen!2sus!4v1676961268712!5m2!1sen!2sus" frameborder="0" allowfullscreen="" loading="lazy" referrerpolicy="no-referrer-when-downgrade"></iframe>
      </div><!-- End Google Maps -->

      <div class="container" data-aos="fade-up" data-aos-delay="100">

        <div class="row gy-4">

          <div class="col-lg-4">
            <div class="info-item d-flex" data-aos="fade-up" data-aos-delay="300">
              <i class="bi bi-geo-alt flex-shrink-0"></i>
              <div>
                <h3>Địa chỉ</h3>
                <p>456 Lê Thị Riêng, Quận 10, TP.HCM</p>
              </div>
            </div><!-- End Info Item -->

            <div class="info-item d-flex" data-aos="fade-up" data-aos-delay="400">
              <i class="bi bi-telephone flex-shrink-0"></i>
              <div>
                <h3>Hotline</h3>
                <p>1800 599 988</p>
              </div>
            </div><!-- End Info Item -->

            <div class="info-item d-flex" data-aos="fade-up" data-aos-delay="500">
              <i class="bi bi-envelope flex-shrink-0"></i>
              <div>
                <h3>Email</h3>
                <p>hotro@visioncare.vn</p>
              </div>
            </div><!-- End Info Item -->

          </div>

          <div class="col-lg-8">
            <form action="${pageContext.request.contextPath}/contact" method="post" class="php-email-form" data-aos="fade-up" data-aos-delay="200">
              <div class="row gy-4">

                <div class="col-md-6">
                  <input type="text" name="name" class="form-control" placeholder="Họ và tên" required="">
                </div>

                <div class="col-md-6 ">
                  <input type="email" class="form-control" name="email" placeholder="Email" required="">
                </div>

                <div class="col-md-12">
                  <input type="text" class="form-control" name="subject" placeholder="Tiêu đề" required="">
                </div>

                <div class="col-md-12">
                  <textarea class="form-control" name="message" rows="6" placeholder="Nội dung tin nhắn" required=""></textarea>
                </div>

                <div class="col-md-12 text-center">
                  <button type="submit">Gửi tin nhắn</button>
                </div>

              </div>
            </form>
          </div><!-- End Contact Form -->

        </div>

      </div>

    </section><!-- /Contact Section -->

  </main>

<%-- Include Footer --%>
<jsp:include page="/views/common/footer.jsp" />
