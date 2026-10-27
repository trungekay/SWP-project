<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
      <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
        <fmt:setLocale value="vi_VN" scope="page" />

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

              <img src="${pageContext.request.contextPath}/clinic-banner-image?key=HERO_BANNER" alt="VisionCare" data-aos="fade-in">

              <div class="container position-relative">

                <div class="welcome position-relative" data-aos="fade-down" data-aos-delay="100">
                  <h2>CHÀO MỪNG ĐẾN VISIONCARE</h2>
                  <p>Phòng khám mắt chuyên sâu — đặt lịch khám trực tuyến, trang thiết bị hiện đại, đội ngũ bác sĩ nhãn
                    khoa giàu kinh nghiệm</p>
                </div><!-- End Welcome -->

                <div class="content row gy-4">
                  <div class="col-lg-4 d-flex align-items-stretch">
                    <div class="why-box" data-aos="zoom-out" data-aos-delay="200">
                      <h3>Vì sao chọn VisionCare?</h3>
                      <p>
                        Trang thiết bị nhãn khoa hiện đại nhập khẩu, quy trình khám chuẩn quốc tế và lộ trình điều trị
                        rõ ràng.
                        Bạn có thể xem lịch bác sĩ, chọn khung giờ phù hợp và đặt lịch chỉ trong vài phút — không cần
                        gọi điện chờ đợi.
                      </p>
                      <div class="text-center hero-booking-cta d-flex flex-wrap justify-content-center gap-2">
                        <a href="#about" class="more-btn"><span>Tìm hiểu thêm</span> <i
                            class="bi bi-chevron-right"></i></a>
                        <a href="${pageContext.request.contextPath}/book-appointment"
                          class="btn btn-dental d-inline-block"><i class="bi bi-calendar-plus me-1"></i>Đặt lịch ngay</a>
                        <a href="${pageContext.request.contextPath}/doctor-schedules"
                          class="btn btn-outline-light d-inline-block"><i class="bi bi-calendar3 me-1"></i>Xem lịch bác sĩ</a>
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
                            <p>Chọn bác sĩ nhãn khoa, ngày và khung giờ phù hợp mọi lúc trên website hoặc sau khi đăng
                              nhập.</p>
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
                            <p>Hỗ trợ chuyển khoản QR hoặc thanh toán tiền mặt trực tiếp tại phòng khám.</p>
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
                    <img src="${pageContext.request.contextPath}/clinic-banner-image?key=ABOUT_IMAGE" class="img-fluid rounded shadow"
                      alt="VisionCare Clinic">
                  </div>

                  <div class="col-lg-6 content" data-aos="fade-up" data-aos-delay="100">
                    <h3>Về VisionCare</h3>
                    <p>
                      VisionCare là phòng khám mắt chuyên sâu hàng đầu, quy tụ đội ngũ bác sĩ nhãn khoa giàu kinh nghiệm
                      cùng hệ thống trang thiết bị hiện đại nhập khẩu. Chúng tôi cam kết mang lại trải nghiệm khám chữa
                      bệnh minh bạch, an toàn và hiệu quả.
                    </p>
                    <ul>
                      <li>
                        <i class="fa-solid fa-eye"></i>
                        <div>
                          <h5>Khám mắt toàn diện</h5>
                          <p>Đo thị lực, áp lực nhãn cầu, soi đáy mắt và tư vấn lộ trình điều trị rõ ràng cho từng bệnh
                            nhân.</p>
                        </div>
                      </li>
                      <li>
                        <i class="fa-solid fa-microscope"></i>
                        <div>
                          <h5>Thiết bị chẩn đoán hiện đại</h5>
                          <p>Hệ thống OCT, máy đo khúc xạ tự động, máy chụp đáy mắt kỹ thuật số cho kết quả chính xác.
                          </p>
                        </div>
                      </li>
                      <li>
                        <i class="fa-solid fa-user-doctor"></i>
                        <div>
                          <h5>Bác sĩ chuyên khoa giàu kinh nghiệm</h5>
                          <p>Đội ngũ bác sĩ được đào tạo chuyên sâu trong và ngoài nước, nhiều năm kinh nghiệm thực
                            tiễn.</p>
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
                    <c:choose>
                      <c:when test="${not empty galleryItems}">
                        <c:forEach var="item" items="${galleryItems}">
                          <c:set var="imgUrl" value="${pageContext.request.contextPath}/clinic-gallery-image?id=${item.id}&t=${item.updatedAt}" />
                          <div class="col-lg-3 col-md-4">
                            <div class="gallery-item">
                              <a href="${imgUrl}" class="glightbox" data-gallery="images-gallery" title="${not empty item.title ? item.title : 'VisionCare Gallery'}">
                                <img src="${imgUrl}" alt="${item.title}" class="img-fluid" style="width: 100%; height: 260px; object-fit: cover;">
                              </a>
                            </div>
                          </div><!-- End Gallery Item -->
                        </c:forEach>
                      </c:when>
                      <c:otherwise>
                        <c:forEach var="i" begin="1" end="8">
                          <div class="col-lg-3 col-md-4">
                            <div class="gallery-item">
                              <a href="${pageContext.request.contextPath}/assets/img/gallery/gallery-${i}.jpg"
                                class="glightbox" data-gallery="images-gallery">
                                <img src="${pageContext.request.contextPath}/assets/img/gallery/gallery-${i}.jpg" alt=""
                                  class="img-fluid" style="width: 100%; height: 260px; object-fit: cover;">
                              </a>
                            </div>
                          </div><!-- End Gallery Item -->
                        </c:forEach>
                      </c:otherwise>
                    </c:choose>
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
                      <span data-purecounter-start="0" data-purecounter-end="${fn:length(doctors)}"
                        data-purecounter-duration="1" class="purecounter"></span>
                      <p>Bác sĩ</p>
                    </div>
                  </div><!-- End Stats Item -->

                  <div class="col-lg-3 col-md-6 d-flex flex-column align-items-center">
                    <i class="fa-regular fa-hospital"></i>
                    <div class="stats-item">
                      <span data-purecounter-start="0" data-purecounter-end="${fn:length(catalogServices)}"
                        data-purecounter-duration="1" class="purecounter"></span>
                      <p>Chuyên khoa</p>
                    </div>
                  </div><!-- End Stats Item -->

                  <div class="col-lg-3 col-md-6 d-flex flex-column align-items-center">
                    <i class="fas fa-calendar-check"></i>
                    <div class="stats-item">
                      <span data-purecounter-start="0" data-purecounter-end="${fn:length(doctors) * 12}"
                        data-purecounter-duration="1" class="purecounter"></span>
                      <p>Ca khám / ngày</p>
                    </div>
                  </div><!-- End Stats Item -->

                  <div class="col-lg-3 col-md-6 d-flex flex-column align-items-center">
                    <i class="fas fa-award"></i>
                    <div class="stats-item">
                      <span data-purecounter-start="0" data-purecounter-end="15" data-purecounter-duration="1"
                        class="purecounter"></span>
                      <p>Năm hoạt động</p>
                    </div>
                  </div><!-- End Stats Item -->

                </div>

              </div>

            </section><!-- /Stats Section -->

            <!-- Services Section: Categorized Service_Catalog -->
            <section id="services" class="services section light-background">
              <span id="service"></span>
              <style>
                .svc-filter-btn {
                  border: 1.5px solid #cbd5e1;
                  background: #ffffff;
                  color: #475569;
                  border-radius: 50px;
                  padding: 8px 22px;
                  font-weight: 600;
                  font-size: 14px;
                  transition: all 0.25s ease;
                  box-shadow: 0 1px 3px rgba(0,0,0,0.04);
                }
                .svc-filter-btn:hover {
                  border-color: #0d9488;
                  color: #0d9488;
                  background: #f0fdfa;
                  transform: translateY(-2px);
                }
                .svc-filter-btn.active {
                  background: #0d9488 !important;
                  border-color: #0d9488 !important;
                  color: #ffffff !important;
                  box-shadow: 0 4px 14px rgba(13, 148, 136, 0.28);
                }
                .svc-filter-btn.active .badge {
                  background: rgba(255, 255, 255, 0.25) !important;
                  color: #ffffff !important;
                }
                .service-card-col {
                  transition: opacity 0.3s ease, transform 0.3s ease;
                }
                .service-card-modern {
                  border-radius: 16px;
                  transition: transform 0.25s ease, box-shadow 0.25s ease;
                  overflow: hidden;
                }
                .service-card-modern:hover {
                  transform: translateY(-5px);
                  box-shadow: 0 12px 24px rgba(13, 148, 136, 0.12) !important;
                }
              </style>

              <c:set var="countKham" value="0" />
              <c:set var="countChandoan" value="0" />
              <c:set var="countDieutri" value="0" />
              <c:set var="lasikPreopId" value="3" />
              <c:set var="phacoPreopId" value="5" />
              <c:forEach items="${catalogServices}" var="s">
                <c:choose>
                  <c:when test="${s.category == 'Kiểm tra và chẩn đoán'}">
                    <c:set var="countChandoan" value="${countChandoan + 1}" />
                  </c:when>
                  <c:when test="${s.category == 'Điều trị và thủ thuật'}">
                    <c:set var="countDieutri" value="${countDieutri + 1}" />
                  </c:when>
                  <c:otherwise>
                    <c:set var="countKham" value="${countKham + 1}" />
                  </c:otherwise>
                </c:choose>
                <c:if test="${s.code == 'LS-03'}"><c:set var="lasikPreopId" value="${s.id}" /></c:if>
                <c:if test="${s.code == 'TT-05'}"><c:set var="phacoPreopId" value="${s.id}" /></c:if>
              </c:forEach>

              <div class="container section-title" data-aos="fade-up">
                <h2>Dịch vụ nhãn khoa</h2>
                <p>Khám chữa mắt toàn diện, trang thiết bị hiện đại và phẫu thuật kỹ thuật cao tại VisionCare (${catalogServices.size()} dịch vụ)</p>
              </div>

              <div class="container" data-aos="fade-up" data-aos-delay="100">
                <!-- Bộ lọc phân loại dịch vụ -->
                <div class="d-flex justify-content-center flex-wrap gap-2 mb-4">
                  <button type="button" class="btn svc-filter-btn active" data-filter="all" onclick="filterServices('all', this)">
                    <i class="bi bi-grid-fill me-1"></i> Tất cả dịch vụ
                    <span class="badge rounded-pill bg-light text-secondary ms-1">${fn:length(catalogServices)}</span>
                  </button>
                  <button type="button" class="btn svc-filter-btn" data-filter="kham" onclick="filterServices('kham', this)">
                    <i class="bi bi-person-check-fill me-1"></i> Khám &amp; Tư vấn
                    <span class="badge rounded-pill bg-light text-secondary ms-1">${countKham}</span>
                  </button>
                  <button type="button" class="btn svc-filter-btn" data-filter="chandoan" onclick="filterServices('chandoan', this)">
                    <i class="bi bi-clipboard2-pulse-fill me-1"></i> Kiểm tra &amp; Chẩn đoán
                    <span class="badge rounded-pill bg-light text-secondary ms-1">${countChandoan}</span>
                  </button>
                  <button type="button" class="btn svc-filter-btn" data-filter="dieutri" onclick="filterServices('dieutri', this)">
                    <i class="bi bi-hospital-fill me-1"></i> Phẫu thuật &amp; Thủ thuật
                    <span class="badge rounded-pill bg-light text-secondary ms-1">${countDieutri}</span>
                  </button>
                </div>

                <div class="row gy-4" id="homeServicesGrid">
                  <c:forEach items="${catalogServices}" var="service">
                    <c:set var="svcCatGroup" value="kham" />
                    <c:choose>
                      <c:when test="${service.category == 'Kiểm tra và chẩn đoán'}">
                        <c:set var="svcCatGroup" value="chandoan" />
                      </c:when>
                      <c:when test="${service.category == 'Điều trị và thủ thuật'}">
                        <c:set var="svcCatGroup" value="dieutri" />
                      </c:when>
                      <c:otherwise>
                        <c:set var="svcCatGroup" value="kham" />
                      </c:otherwise>
                    </c:choose>

                    <div class="col-lg-4 col-md-6 service-card-col" data-cat-group="${svcCatGroup}">
                      <div class="card service-card-modern border-0 shadow-sm h-100 bg-white">
                        <div class="position-relative">
                          <c:choose>
                            <c:when test="${service.uploadedImage}">
                              <img
                                src="${pageContext.request.contextPath}/catalog-image?kind=service&amp;id=${service.id}"
                                class="card-img-top" alt="${fn:escapeXml(service.name)}"
                                style="height: 200px; object-fit: cover;">
                            </c:when>
                            <c:otherwise>
                              <img
                                src="${pageContext.request.contextPath}/assets/img/${service.defaultImagePath}"
                                class="card-img-top" alt="${fn:escapeXml(service.name)}"
                                style="height: 200px; object-fit: cover;">
                            </c:otherwise>
                          </c:choose>

                          <!-- Badge Phân loại nổi bật trên ảnh -->
                          <div class="position-absolute top-0 start-0 m-3">
                            <c:choose>
                              <c:when test="${svcCatGroup == 'dieutri'}">
                                <span class="badge rounded-pill px-3 py-2 fw-semibold shadow-sm" style="background: rgba(239, 68, 68, 0.9); color: #ffffff;">
                                  <i class="bi bi-shield-plus me-1"></i>${service.category}
                                </span>
                              </c:when>
                              <c:when test="${svcCatGroup == 'chandoan'}">
                                <span class="badge rounded-pill px-3 py-2 fw-semibold shadow-sm" style="background: rgba(59, 130, 246, 0.9); color: #ffffff;">
                                  <i class="bi bi-clipboard2-pulse me-1"></i>${service.category}
                                </span>
                              </c:when>
                              <c:otherwise>
                                <span class="badge rounded-pill px-3 py-2 fw-semibold shadow-sm" style="background: rgba(13, 148, 136, 0.9); color: #ffffff;">
                                  <i class="bi bi-eye me-1"></i>${service.category}
                                </span>
                              </c:otherwise>
                            </c:choose>
                          </div>

                          <div class="position-absolute top-0 end-0 m-3">
                            <span class="badge bg-dark bg-opacity-75 text-white px-2 py-1 small rounded-pill">
                              ${service.code != null ? service.code : 'DV'}
                            </span>
                          </div>
                        </div>

                        <div class="card-body p-4 d-flex flex-column justify-content-between">
                          <div>
                            <h5 class="card-title fw-bold mb-2 text-dark">
                              <c:out value="${service.name}" />
                            </h5>
                            <p class="card-text text-muted mb-2 small" style="display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; min-height: 38px;">
                              <c:out value="${service.summary}" />
                            </p>

                            <!-- Ghi chú đặc quyền / Tiền phẫu hoàn trừ phí -->
                            <c:if test="${service.code == 'LS-03' or service.code == 'TT-05' or fn:contains(service.name, 'tiền phẫu') or fn:contains(service.name, 'tầm soát')}">
                              <div class="mb-3">
                                <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill py-1 px-2 small">
                                  <i class="bi bi-gift-fill me-1"></i>Trừ 100% vào chi phí mổ
                                </span>
                              </div>
                            </c:if>
                            <c:if test="${service.code == 'PT-LASIK' or service.code == 'PT-SMILE' or service.code == 'PT-PHACO'}">
                              <div class="mb-3">
                                <span class="badge bg-warning-subtle text-dark border border-warning-subtle rounded-pill py-1 px-2 small">
                                  <i class="bi bi-info-circle-fill me-1 text-warning"></i>Chỉ định sau khám chuyên sâu
                                </span>
                              </div>
                            </c:if>
                          </div>

                          <div>
                            <div class="d-flex justify-content-between align-items-center mb-3 pt-2 border-top">
                              <span class="text-muted small">Chi phí dịch vụ:</span>
                              <span class="fs-5 fw-bold" style="color: #0d9488;">
                                <fmt:formatNumber value="${service.price}" pattern="#,##0" /> VNĐ
                              </span>
                            </div>

                            <div class="d-flex justify-content-center gap-2 flex-wrap">
                              <button type="button"
                                class="btn btn-outline-secondary rounded-pill px-3 btn-sm"
                                data-bs-toggle="modal" data-bs-target="#homeServiceModal${service.id}"
                                title="Xem thông tin chi tiết và lưu ý quy trình y khoa">
                                <i class="bi bi-info-circle me-1"></i>Chi tiết
                              </button>
                              <c:choose>
                                <c:when test="${service.code == 'PT-LASIK' or service.code == 'PT-SMILE'}">
                                  <a href="${pageContext.request.contextPath}/book-appointment?serviceId=${lasikPreopId != null ? lasikPreopId : 3}"
                                    class="btn btn-dental rounded-pill px-3 btn-sm shadow-sm" title="Đăng ký khám tiền phẫu để đánh giá điều kiện xóa cận">
                                    <i class="bi bi-calendar-check me-1"></i>Đăng ký khám tiền phẫu
                                  </a>
                                </c:when>
                                <c:when test="${service.code == 'PT-PHACO'}">
                                  <a href="${pageContext.request.contextPath}/book-appointment?serviceId=${phacoPreopId != null ? phacoPreopId : 5}"
                                    class="btn btn-dental rounded-pill px-3 btn-sm shadow-sm" title="Đăng ký khám tầm soát đục thủy tinh thể">
                                    <i class="bi bi-calendar-check me-1"></i>Đăng ký tầm soát Phaco
                                  </a>
                                </c:when>
                                <c:otherwise>
                                  <a href="${pageContext.request.contextPath}/book-appointment?serviceId=${service.id}"
                                    class="btn btn-dental rounded-pill px-3 btn-sm shadow-sm">
                                    <i class="bi bi-calendar-check me-1"></i>Đặt lịch khám
                                  </a>
                                </c:otherwise>
                              </c:choose>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </c:forEach>
                </div>

                <%-- MODAL CHI TIẾT DỊCH VỤ & LƯU Ý QUY TRÌNH Y KHOA CHO TỪNG GÓI --%>
                <c:forEach items="${catalogServices}" var="service">
                  <div class="modal fade" id="homeServiceModal${service.id}" tabindex="-1" aria-labelledby="homeServiceModalLabel${service.id}" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered modal-lg">
                      <div class="modal-content rounded-4 border-0 shadow">
                        <div class="modal-header border-bottom-0 pb-0 pt-4 px-4">
                          <div class="d-flex align-items-center gap-2 flex-wrap">
                            <span class="badge bg-dark bg-opacity-75 rounded-pill px-2 py-1 small">${service.code != null ? service.code : 'DV'}</span>
                            <span class="badge rounded-pill px-3 py-1 small fw-semibold" style="color: #0d9488; background: #ccfbf1; border: 1px solid #99f6e4;">
                              ${service.category}
                            </span>
                          </div>
                          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body pt-2 px-4 pb-3">
                          <h4 class="fw-bold text-dark mt-2 mb-2" id="homeServiceModalLabel${service.id}">${service.name}</h4>
                          
                          <div class="d-flex align-items-center justify-content-between p-3 rounded-3 mb-3" style="background: #f8fafc; border: 1px solid #e2e8f0;">
                            <span class="text-muted small">Chi phí dịch vụ niêm yết:</span>
                            <span class="fs-4 fw-bold text-teal" style="color: #0d9488;">
                              <fmt:formatNumber value="${service.price}" pattern="#,##0" /> VNĐ
                            </span>
                          </div>

                          <c:if test="${not empty service.summary}">
                            <p class="text-secondary fw-semibold mb-2">${service.summary}</p>
                          </c:if>

                          <c:if test="${not empty service.description}">
                            <p class="text-muted small mb-3">${service.description}</p>
                          </c:if>

                          <%-- CẢNH BÁO QUY TRÌNH Y KHOA BẮT BUỘC --%>
                          <c:choose>
                            <c:when test="${service.surgery}">
                              <div class="alert alert-warning border border-warning rounded-4 p-3 mb-2 shadow-sm" style="background: #fffbeb;">
                                <div class="d-flex align-items-start">
                                  <i class="bi bi-exclamation-triangle-fill fs-3 text-warning me-3 flex-shrink-0 mt-1"></i>
                                  <div>
                                    <h6 class="fw-bold text-dark mb-1">⚠️ LƯU Ý QUY TRÌNH BẮT BUỘC: PHẢI KHÁM TIỀN PHẪU TRƯỚC</h6>
                                    <p class="small text-secondary mb-2">
                                      Theo quy chuẩn an toàn y khoa, bệnh nhân <strong>bắt buộc phải thực hiện gói Khám tiền phẫu chuyên sâu trước</strong> để Bác sĩ đo đạc các chỉ số sinh học mắt (đo khúc xạ liệt điều tiết, bản đồ giác mạc Pentacam, độ dày giác mạc, soi đáy mắt...) và kết luận mắt có đủ điều kiện phẫu thuật hay không. Sau khi có kết luận chính thức và chỉ định từ Bác sĩ, bệnh viện mới xếp lịch phẫu thuật.
                                    </p>
                                    <div class="d-flex align-items-center gap-2 text-success small fw-semibold">
                                      <i class="bi bi-gift-fill"></i>
                                      <span>Toàn bộ chi phí khám tiền phẫu sẽ được khấu trừ 100% vào giá gói mổ nếu tiến hành phẫu thuật.</span>
                                    </div>
                                  </div>
                                </div>
                              </div>
                            </c:when>
                            <c:when test="${service.procedure}">
                              <div class="alert alert-info border border-info rounded-4 p-3 mb-2 shadow-sm" style="background: #f0fdfa; border-color: #99f6e4 !important;">
                                <div class="d-flex align-items-start">
                                  <i class="bi bi-shield-exclamation fs-3 text-teal me-3 flex-shrink-0 mt-1" style="color: #0d9488;"></i>
                                  <div>
                                    <h6 class="fw-bold text-dark mb-1">⚠️ LƯU Ý QUY TRÌNH THỦ THUẬT / TIỂU PHẪU: BẮT BUỘC KHÁM TRƯỚC</h6>
                                    <p class="small text-secondary mb-0">
                                      Để đảm bảo an toàn y tế và vô trùng tuyệt đối, đối với thủ thuật / tiểu phẫu, bệnh nhân <strong>vẫn bắt buộc phải qua bước Thăm khám lâm sàng trực tiếp với Bác sĩ chuyên khoa trước</strong>. Bác sĩ sẽ dùng đèn sinh hiển vi đánh giá chính xác mức độ tổn thương, giai đoạn ổ viêm và chỉ định thời điểm làm thủ thuật thích hợp, an toàn nhất.
                                    </p>
                                  </div>
                                </div>
                              </div>
                            </c:when>
                            <c:when test="${service.preOp}">
                              <div class="alert alert-success border border-success rounded-4 p-3 mb-2 shadow-sm" style="background: #f0fdf4;">
                                <div class="d-flex align-items-start">
                                  <i class="bi bi-check-circle-fill fs-3 text-success me-3 flex-shrink-0 mt-1"></i>
                                  <div>
                                    <h6 class="fw-bold text-success mb-1">ĐIỀU KIỆN TIÊN QUYẾT TRƯỚC PHẪU THUẬT &amp; HOÀN PHÍ 100%</h6>
                                    <p class="small text-secondary mb-0">
                                      Đây là gói khám chuyên sâu đánh giá toàn diện điều kiện mắt trước can thiệp phẫu thuật khúc xạ / Phaco. Toàn bộ chi phí của gói khám này được <strong>hoàn trừ 100% vào chi phí ca mổ</strong> nếu quý khách phẫu thuật tại VisionCare.
                                    </p>
                                  </div>
                                </div>
                              </div>
                            </c:when>
                          </c:choose>
                        </div>
                        <div class="modal-footer border-top-0 pt-0 px-4 pb-4 d-flex justify-content-between">
                          <button type="button" class="btn btn-outline-secondary rounded-pill px-4" data-bs-dismiss="modal">Đóng</button>
                          <c:choose>
                            <c:when test="${service.code == 'PT-LASIK' or service.code == 'PT-SMILE'}">
                              <a href="${pageContext.request.contextPath}/book-appointment?serviceId=${lasikPreopId != null ? lasikPreopId : 3}" class="btn btn-dental rounded-pill px-4 shadow-sm">
                                <i class="bi bi-calendar-check me-2"></i>Đăng ký khám tiền phẫu LASIK/SMILE
                              </a>
                            </c:when>
                            <c:when test="${service.code == 'PT-PHACO'}">
                              <a href="${pageContext.request.contextPath}/book-appointment?serviceId=${phacoPreopId != null ? phacoPreopId : 5}" class="btn btn-dental rounded-pill px-4 shadow-sm">
                                <i class="bi bi-calendar-check me-2"></i>Đăng ký tầm soát Phaco
                              </a>
                            </c:when>
                            <c:otherwise>
                              <a href="${pageContext.request.contextPath}/book-appointment?serviceId=${service.id}" class="btn btn-dental rounded-pill px-4 shadow-sm">
                                <i class="bi bi-calendar-check me-2"></i>Đặt lịch khám dịch vụ này
                              </a>
                            </c:otherwise>
                          </c:choose>
                        </div>
                      </div>
                    </div>
                  </div>
                </c:forEach>

              </div>

              <script>
                function filterServices(group, btn) {
                  document.querySelectorAll('.svc-filter-btn').forEach(b => b.classList.remove('active'));
                  if (btn) btn.classList.add('active');

                  const cols = document.querySelectorAll('.service-card-col');
                  cols.forEach(col => {
                    if (group === 'all' || col.getAttribute('data-cat-group') === group) {
                      col.style.display = '';
                      col.style.opacity = '1';
                    } else {
                      col.style.display = 'none';
                      col.style.opacity = '0';
                    }
                  });
                }
              </script>
            </section><!-- /Services Section -->

            <!-- Appointment Section -->
            <section id="appointment" class="appointment section">

              <!-- Section Title -->
              <div class="container section-title" data-aos="fade-up">
                <h2>Đặt lịch khám mắt</h2>
                <p>Hoàn tất đặt lịch qua form nhiều bước: chọn chuyên khoa, bác sĩ nhãn khoa, thời gian và phương thức
                  thanh toán</p>
              </div><!-- End Section Title -->

              <div class="container" data-aos="fade-up" data-aos-delay="100">
                <div class="booking-promo text-center">
                  <h3 class="mb-3">Sẵn sàng đặt lịch khám mắt?</h3>
                  <p class="text-muted mb-4">Xem <a href="${pageContext.request.contextPath}/doctor-schedules">danh sách
                      bác sĩ nhãn khoa &amp; lịch trống</a> hoặc bắt đầu form đặt lịch ngay bên dưới.</p>
                  <a href="${pageContext.request.contextPath}/book-appointment" class="btn btn-dental btn-lg">Bắt đầu
                    đặt lịch <i class="bi bi-arrow-right ms-2"></i></a>
                </div>
              </div>

            </section><!-- /Appointment Section -->

            <!-- Departments Section: details from Service_Catalog -->
            <section id="departments" class="departments section">
              <div class="container section-title" data-aos="fade-up">
                <h2>Chi tiết dịch vụ</h2>
                <p>Thông tin chi tiết các dịch vụ tại VisionCare</p>
              </div>
              <div class="container" data-aos="fade-up" data-aos-delay="100">
                <div class="row">
                  <div class="col-lg-3">
                    <ul class="nav nav-tabs flex-column">
                      <c:forEach items="${catalogServices}" var="service" varStatus="status">
                        <li class="nav-item"><a id="department-link-${service.id}"
                            class="nav-link ${status.first ? 'active show' : ''}" data-bs-toggle="tab"
                            href="#departments-tab-${service.id}">
                            <c:out value="${service.name}" />
                          </a></li>
                      </c:forEach>
                    </ul>
                  </div>
                  <div class="col-lg-9 mt-4 mt-lg-0">
                    <div class="tab-content">
                      <c:forEach items="${catalogServices}" var="service" varStatus="status">
                        <div class="tab-pane ${status.first ? 'active show' : ''}" id="departments-tab-${service.id}">
                          <div class="row">
                            <div class="col-lg-8 details order-2 order-lg-1">
                              <h3>
                                <c:out value="${service.name}" />
                              </h3>
                              <c:if test="${not empty service.categoryName}">
                                <p class="fw-semibold">
                                  <c:out value="${service.categoryName}" />
                                </p>
                              </c:if>
                              <p class="fst-italic">
                                <c:out value="${service.summary}" />
                              </p>
                              <p>
                                <c:out value="${service.description}" />
                              </p>

                              <%-- CẢNH BÁO QUY TRÌNH Y KHOA BẮT BUỘC TRONG TAB CHI TIẾT --%>
                              <c:choose>
                                <c:when test="${service.surgery}">
                                  <div class="alert alert-warning border border-warning rounded-4 p-3 mb-3 shadow-sm" style="background: #fffbeb;">
                                    <div class="d-flex align-items-start">
                                      <i class="bi bi-exclamation-triangle-fill fs-3 text-warning me-3 flex-shrink-0 mt-1"></i>
                                      <div>
                                        <h6 class="fw-bold text-dark mb-1">⚠️ LƯU Ý QUY TRÌNH PHẪU THUẬT BẮT BUỘC</h6>
                                        <p class="small text-secondary mb-2">
                                          Theo quy chuẩn an toàn y khoa, bệnh nhân <strong>bắt buộc phải thực hiện gói Khám tiền phẫu chuyên sâu trước</strong> để Bác sĩ đo đạc các chỉ số sinh học mắt (đo khúc xạ liệt điều tiết, bản đồ giác mạc Pentacam, độ dày giác mạc, soi đáy mắt...) và kết luận mắt có đủ điều kiện phẫu thuật hay không. Sau khi có kết luận chính thức và chỉ định từ Bác sĩ, bệnh viện mới xếp lịch phẫu thuật.
                                        </p>
                                        <div class="d-flex align-items-center gap-2 text-success small fw-semibold">
                                          <i class="bi bi-gift-fill"></i>
                                          <span>Toàn bộ chi phí khám tiền phẫu sẽ được khấu trừ 100% vào giá gói mổ nếu tiến hành phẫu thuật.</span>
                                        </div>
                                      </div>
                                    </div>
                                  </div>
                                </c:when>
                                <c:when test="${service.procedure}">
                                  <div class="alert alert-info border border-info rounded-4 p-3 mb-3 shadow-sm" style="background: #f0fdfa; border-color: #99f6e4 !important;">
                                    <div class="d-flex align-items-start">
                                      <i class="bi bi-shield-exclamation fs-3 text-teal me-3 flex-shrink-0 mt-1" style="color: #0d9488;"></i>
                                      <div>
                                        <h6 class="fw-bold text-dark mb-1">⚠️ LƯU Ý QUY TRÌNH THỦ THUẬT / TIỂU PHẪU: BẮT BUỘC KHÁM TRƯỚC</h6>
                                        <p class="small text-secondary mb-0">
                                          Để đảm bảo an toàn y tế và vô trùng tuyệt đối, đối với thủ thuật / tiểu phẫu, bệnh nhân <strong>vẫn bắt buộc phải qua bước Thăm khám lâm sàng trực tiếp với Bác sĩ chuyên khoa trước</strong>. Bác sĩ sẽ dùng đèn sinh hiển vi đánh giá chính xác mức độ tổn thương, giai đoạn ổ viêm và chỉ định thời điểm làm thủ thuật thích hợp, an toàn nhất.
                                        </p>
                                      </div>
                                    </div>
                                  </div>
                                </c:when>
                                <c:when test="${service.preOp}">
                                  <div class="alert alert-success border border-success rounded-4 p-3 mb-3 shadow-sm" style="background: #f0fdf4;">
                                    <div class="d-flex align-items-start">
                                      <i class="bi bi-check-circle-fill fs-3 text-success me-3 flex-shrink-0 mt-1"></i>
                                      <div>
                                        <h6 class="fw-bold text-success mb-1">ĐIỀU KIỆN TIÊN QUYẾT TRƯỚC PHẪU THUẬT &amp; HOÀN PHÍ 100%</h6>
                                        <p class="small text-secondary mb-0">
                                          Đây là gói khám chuyên sâu đánh giá toàn diện điều kiện mắt trước can thiệp phẫu thuật khúc xạ / Phaco. Toàn bộ chi phí của gói khám này được <strong>hoàn trừ 100% vào chi phí ca mổ</strong> nếu quý khách phẫu thuật tại VisionCare.
                                        </p>
                                      </div>
                                    </div>
                                  </div>
                                </c:when>
                              </c:choose>

                              <div class="mt-4">
                                <c:choose>
                                  <c:when test="${service.code == 'PT-LASIK' or service.code == 'PT-SMILE'}">
                                    <a href="${pageContext.request.contextPath}/book-appointment?serviceId=${lasikPreopId != null ? lasikPreopId : 3}"
                                       class="btn btn-dental rounded-pill px-4 py-2 shadow-sm">
                                      <i class="bi bi-calendar-check me-2"></i>Đăng ký khám tiền phẫu LASIK/SMILE
                                    </a>
                                  </c:when>
                                  <c:when test="${service.code == 'PT-PHACO'}">
                                    <a href="${pageContext.request.contextPath}/book-appointment?serviceId=${phacoPreopId != null ? phacoPreopId : 5}"
                                       class="btn btn-dental rounded-pill px-4 py-2 shadow-sm">
                                      <i class="bi bi-calendar-check me-2"></i>Đăng ký tầm soát Phaco
                                    </a>
                                  </c:when>
                                  <c:when test="${service.procedure}">
                                    <a href="${pageContext.request.contextPath}/book-appointment?serviceId=${service.id}"
                                       class="btn btn-dental rounded-pill px-4 py-2 shadow-sm">
                                      <i class="bi bi-calendar-check me-2"></i>Đặt lịch khám chỉ định thủ thuật
                                    </a>
                                  </c:when>
                                  <c:otherwise>
                                    <a href="${pageContext.request.contextPath}/book-appointment?serviceId=${service.id}"
                                       class="btn btn-dental rounded-pill px-4 py-2 shadow-sm">
                                      <i class="bi bi-calendar-check me-2"></i>Đặt lịch khám chuyên khoa này
                                    </a>
                                  </c:otherwise>
                                </c:choose>
                              </div>
                            </div>

                            <div class="col-lg-4 text-center order-1 order-lg-2">
                              <c:choose>
                                <c:when test="${service.uploadedImage}"><img
                                    src="${pageContext.request.contextPath}/catalog-image?kind=service&amp;id=${service.id}"
                                    alt="${fn:escapeXml(service.name)}" class="img-fluid rounded-4 shadow-sm"
                                    style="max-height: 280px; width: 100%; object-fit: cover;"></c:when>
                                <c:otherwise><img
                                    src="${pageContext.request.contextPath}/assets/img/${service.defaultImagePath}"
                                    alt="${fn:escapeXml(service.name)}" class="img-fluid rounded-4 shadow-sm"
                                    style="max-height: 280px; width: 100%; object-fit: cover;"></c:otherwise>
                              </c:choose>
                            </div>
                          </div>
                        </div>
                      </c:forEach>
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

                  <%-- Render bác sĩ từ database (Sử dụng cấu trúc Card hiện đại) --%>
                    <c:forEach var="doc" items="${doctors}" varStatus="loop">
                      <c:choose>
                        <c:when test="${not empty doc.image && (fn:startsWith(doc.image, 'http') || fn:startsWith(doc.image, '/'))}">
                          <c:set var="docImgUrl" value="${doc.image}" />
                        </c:when>
                        <c:when test="${not empty doc.image && fn:startsWith(doc.image, 'assets/')}">
                          <c:set var="docImgUrl" value="${pageContext.request.contextPath}/${doc.image}" />
                        </c:when>
                        <c:otherwise>
                          <c:set var="docImgUrl" value="${pageContext.request.contextPath}/assets/img/${not empty doc.image ? doc.image : 'doctors/doctors-1.jpg'}" />
                        </c:otherwise>
                      </c:choose>
                      <div class="col-lg-4 col-md-6" data-aos="fade-up" data-aos-delay="${(loop.index + 1) * 100}">
                        <div class="card doctor-card border-0 shadow-sm h-100 text-center">
                          <div class="card-img-top overflow-hidden mt-4 mx-auto"
                            style="width: 180px; height: 180px; border-radius: 50%; box-shadow: 0px 4px 10px rgba(0,0,0,0.1);">
                            <img
                              src="${docImgUrl}"
                              class="img-fluid w-100 h-100" style="object-fit: cover; object-position: top center;" alt="${doc.name}">
                          </div>
                          <div class="card-body p-4">
                            <h4 class="card-title fw-bold mb-1" style="color: var(--heading-color);">${doc.name}</h4>
                            <p class="text-primary small fw-semibold mb-3"><i class="bi bi-award me-1"></i>
                              ${doc.specialty}</p>
                            <p class="card-text mb-4 text-muted" style="font-size: 0.95rem;">${doc.description}</p>
                            <div class="d-flex justify-content-center gap-2">
                              <a href="${pageContext.request.contextPath}/book-appointment?doc=${doc.id}"
                                class="btn btn-primary rounded-pill px-4 shadow-sm">Đặt lịch</a>
                              <button type="button" class="btn btn-outline-info rounded-pill px-4 shadow-sm"
                                data-bs-toggle="modal" data-bs-target="#homeDoctorModal${doc.id}">Xem chi tiết</button>
                            </div>
                          </div>
                        </div>
                      </div><!-- End Team Member -->

                      <!-- Doctor Detail Modal (Home) -->
                      <div class="modal fade" id="homeDoctorModal${doc.id}" tabindex="-1"
                        aria-labelledby="homeDoctorModalLabel${doc.id}" aria-hidden="true">
                        <div class="modal-dialog modal-lg modal-dialog-centered">
                          <div class="modal-content border-0 shadow">
                            <div class="modal-header border-0 pb-0">
                              <button type="button" class="btn-close" data-bs-dismiss="modal"
                                aria-label="Close"></button>
                            </div>
                            <div class="modal-body p-4 pt-0">
                              <div class="row">
                                <div class="col-md-4 text-center border-end">
                                  <img
                                    src="${docImgUrl}"
                                    class="img-fluid rounded-circle shadow-sm mb-3"
                                    style="width: 180px; height: 180px; object-fit: cover; object-position: top center;" alt="${doc.name}">
                                  <h4 class="fw-bold text-primary mb-1">${doc.name}</h4>
                                  <p class="text-muted mb-3"><i class="bi bi-award me-1"></i> ${doc.specialty}</p>
                                  <a href="${pageContext.request.contextPath}/book-appointment?doc=${doc.id}"
                                    class="btn btn-primary rounded-pill w-100 mt-2"><i class="bi bi-calendar-check me-1"></i>Đặt lịch với bác sĩ</a>
                                  <a href="${pageContext.request.contextPath}/doctor-schedules?specialty=${doc.departmentKey}"
                                    class="btn btn-outline-primary rounded-pill w-100 mt-2"><i class="bi bi-clock-history me-1"></i>Xem ca trực bác sĩ</a>
                                </div>
                                <div class="col-md-8 px-4 text-start">
                                  <h5 class="fw-bold text-dark border-bottom pb-2 mb-3">Tiểu sử chuyên môn</h5>
                                  <p class="text-muted mb-4" style="line-height: 1.6;">${not empty doc.biography ?
                                    doc.biography : 'Đang cập nhật...'}</p>

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
                          <p>Bạn nên mang theo kính đang đeo (nếu có), sổ khám bệnh cũ và thẻ bảo hiểm y tế. Nếu khám để
                            phẫu thuật LASIK, cần ngừng đeo kính áp tròng ít nhất 1 tuần trước ngày thăm khám tiền phẫu.
                          </p>
                        </div>
                        <i class="faq-toggle bi bi-chevron-right"></i>
                      </div><!-- End Faq item-->

                      <div class="faq-item">
                        <h3>Phẫu thuật LASIK có đau không? Bao lâu thì hồi phục?</h3>
                        <div class="faq-content">
                          <p>Phẫu thuật LASIK thực hiện dưới gây tê nhỏ mắt, hầu như không đau. Thị lực cải thiện rõ rệt
                            sau 24–48 giờ. Bạn có thể quay lại làm việc văn phòng sau 2–3 ngày và lái xe sau khoảng 1
                            tuần.</p>
                        </div>
                        <i class="faq-toggle bi bi-chevron-right"></i>
                      </div><!-- End Faq item-->

                      <div class="faq-item">
                        <h3>Bảo hiểm y tế có được áp dụng tại VisionCare không?</h3>
                        <div class="faq-content">
                          <p>VisionCare hỗ trợ thanh toán bảo hiểm y tế cho các dịch vụ khám tổng quát và điều trị nội
                            khoa. Một số dịch vụ thẩm mỹ hoặc phẫu thuật khúc xạ chưa được BHYT chi trả — vui lòng liên
                            hệ lễ tân để được tư vấn cụ thể.</p>
                        </div>
                        <i class="faq-toggle bi bi-chevron-right"></i>
                      </div><!-- End Faq item-->

                      <div class="faq-item">
                        <h3>Trẻ bao nhiêu tuổi có thể đưa đến khám mắt?</h3>
                        <div class="faq-content">
                          <p>VisionCare khám mắt cho trẻ từ 6 tháng tuổi trở lên. Khuyến nghị khám sàng lọc lần đầu khi
                            trẻ 3 tuổi để phát hiện sớm nhược thị, lác mắt và tật khúc xạ.</p>
                        </div>
                        <i class="faq-toggle bi bi-chevron-right"></i>
                      </div><!-- End Faq item-->

                      <div class="faq-item">
                        <h3>Làm thế nào để đặt lịch khám tại VisionCare?</h3>
                        <div class="faq-content">
                          <p>Bạn có thể đặt lịch trực tuyến 24/7 qua nút "Đặt lịch ngay" trên website, gọi hotline 1800
                            599 988 hoặc nhắn tin qua Zalo/Facebook. Lịch hẹn sẽ được xác nhận qua SMS/email trong vòng
                            15 phút.</p>
                        </div>
                        <i class="faq-toggle bi bi-chevron-right"></i>
                      </div><!-- End Faq item-->

                      <div class="faq-item">
                        <h3>Tôi có thể huỷ hoặc đổi lịch hẹn không?</h3>
                        <div class="faq-content">
                          <p>Có, bạn có thể hủy hoặc đổi lịch hẹn miễn phí trước giờ khám ít nhất 2 tiếng, bằng cách
                            đăng nhập tài khoản hoặc gọi hotline. Vui lòng thông báo sớm để bác sĩ có thể sắp xếp cho
                            bệnh nhân khác.</p>
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
                      <div class="icon-circle mb-4 mx-auto d-flex align-items-center justify-content-center"
                        style="width: 80px; height: 80px; border-radius: 50%;">
                        <i class="bi bi-geo-alt fs-1"></i>
                      </div>
                      <h4 class="fw-bold mb-3" style="color: var(--heading-color);">Địa chỉ</h4>
                      <p class="text-muted mb-0">456 Lê Thị Riêng<br>Quận 10, TP.HCM</p>
                    </div>
                  </div>

                  <div class="col-lg-4 col-md-6" data-aos="fade-up" data-aos-delay="300">
                    <div class="contact-card info-box text-center p-5 shadow-sm rounded-4 h-100 bg-white">
                      <div class="icon-circle mb-4 mx-auto d-flex align-items-center justify-content-center"
                        style="width: 80px; height: 80px; border-radius: 50%;">
                        <i class="bi bi-telephone fs-1"></i>
                      </div>
                      <h4 class="fw-bold mb-3" style="color: var(--heading-color);">Hotline</h4>
                      <p class="text-muted mb-0">1800 599 988<br>Tư vấn 24/7</p>
                    </div>
                  </div>

                  <div class="col-lg-4 col-md-6" data-aos="fade-up" data-aos-delay="400">
                    <div class="contact-card info-box text-center p-5 shadow-sm rounded-4 h-100 bg-white">
                      <div class="icon-circle mb-4 mx-auto d-flex align-items-center justify-content-center"
                        style="width: 80px; height: 80px; border-radius: 50%;">
                        <i class="bi bi-envelope fs-1"></i>
                      </div>
                      <h4 class="fw-bold mb-3" style="color: var(--heading-color);">Email</h4>
                      <p class="text-muted mb-0"><a href="mailto:hotro.visioncare@gmail.com"
                          class="text-muted text-decoration-none">hotro.visioncare@gmail.com</a></p>
                    </div>
                  </div>

                </div>
              </div>

              <!-- Bản đồ chỉ đường Google Maps -->
              <div class="container mt-4" data-aos="fade-up" data-aos-delay="200">
                <div class="card border-0 shadow-sm rounded-4 overflow-hidden bg-white">
                  <div class="p-3 bg-light border-bottom d-flex align-items-center justify-content-between flex-wrap gap-2">
                    <div class="d-flex align-items-center gap-2">
                      <span class="badge rounded-circle p-2" style="background: rgba(13, 148, 136, 0.1); color: #0d9488;">
                        <i class="bi bi-geo-alt-fill fs-5"></i>
                      </span>
                      <div>
                        <strong class="d-block text-dark">Phòng khám Chuyên khoa Mắt VisionCare</strong>
                        <span class="text-muted small">456 Lê Thị Riêng, Quận 10, TP. Hồ Chí Minh &bull; Giờ khám: Thứ 2 – Thứ 7 (07:30 – 17:00)</span>
                      </div>
                    </div>
                    <a href="https://maps.google.com/?q=456+L%C3%AA+Th%E1%BB%8B+Ri%C3%AAng,+Qu%E1%BA%ADn+10,+TP.HCM"
                       target="_blank" rel="noopener noreferrer"
                       class="btn btn-sm rounded-pill px-3 py-1 fw-semibold"
                       style="color: #0d9488; border: 1.5px solid #0d9488; background: #ffffff;">
                      <i class="bi bi-box-arrow-up-right me-1"></i> Mở bản đồ chỉ đường
                    </a>
                  </div>
                  <div class="position-relative" style="height: 380px; width: 100%;">
                    <iframe
                      title="Bản đồ chỉ đường đến Phòng khám Chuyên khoa Mắt VisionCare"
                      src="https://maps.google.com/maps?q=456+L%C3%AA+Th%E1%BB%8B+Ri%C3%AAng%2C+Qu%E1%BA%ADn+10%2C+TP.HCM&amp;t=&amp;z=16&amp;ie=UTF8&amp;iwloc=&amp;output=embed"
                      width="100%"
                      height="100%"
                      style="border:0;"
                      allowfullscreen=""
                      loading="lazy"
                      referrerpolicy="no-referrer-when-downgrade">
                    </iframe>
                  </div>
                </div>
              </div>

            </section><!-- /Contact Section -->

          </main>

          <%-- Include Footer --%>
            <jsp:include page="/views/common/footer.jsp" />
