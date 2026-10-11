<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

    <%-- Include Header --%>
      <jsp:include page="/views/common/header.jsp">
        <jsp:param name="pageTitle" value="Danh sách bác sĩ" />
        <jsp:param name="pageDescription" value="Xem lịch bác sĩ nhãn khoa và đặt lịch khám mắt trực tuyến" />
        <jsp:param name="bodyClass" value="starter-page-page" />
        <jsp:param name="activeNav" value="doctors" />
      </jsp:include>

      <style>
        .schedule-card {
          transition: all 0.3s ease;
          border: 1px solid #e1e6f1;
          border-radius: 10px;
        }

        .schedule-card:hover {
          box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05);
          transform: translateY(-5px);
        }

        .time-slot {
          display: inline-block;
          padding: 5px 15px;
          margin: 5px;
          border-radius: 20px;
          border: 1px solid #0d9488;
          color: #0d9488;
          font-size: 14px;
          text-decoration: none;
          transition: 0.3s;
        }

        .time-slot:hover {
          background: #0d9488;
          color: #fff;
        }

        .time-slot.booked {
          border-color: #dee2e6;
          color: #adb5bd;
          background: #f8f9fa;
          pointer-events: none;
        }

        .doctor-avatar {
          width: 100px;
          height: 100px;
          object-fit: cover;
          border-radius: 50%;
          border: 3px solid #0d9488;
        }

        .filter-section {
          background: #f0fdfa;
          padding: 30px;
          border-radius: 10px;
          border-radius: 10px;
          margin-bottom: 40px;
        }

        .time-slot-hover:hover {
          background-color: #0d9488 !important;
          color: white !important;
        }

        .doctor-card:hover {
          transform: translateY(-5px);
          box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1) !important;
        }
      </style>

      <main class="main">

        <div class="page-title" data-aos="fade">
          <div class="heading">
            <div class="container">
              <div class="row d-flex justify-content-center text-center">
                <div class="col-lg-8">
                  <h1>Danh sách bác sĩ nhãn khoa</h1>
                  <p class="mb-0">Tìm bác sĩ theo chuyên khoa nhãn khoa, xem khung giờ trống và đặt lịch khám mắt trực
                    tuyến.</p>
                </div>
              </div>
            </div>
          </div>
          <nav class="breadcrumbs">
            <div class="container">
              <ol>
                <li><a href="${pageContext.request.contextPath}/home">Trang chủ</a></li>
                <li class="current">Danh sách bác sĩ</li>
              </ol>
            </div>
          </nav>
        </div>

        <section id="schedules" class="section">
          <div class="container" data-aos="fade-up">

            <!-- Filter Form -->
            <div class="filter-section">
              <form class="row g-3 align-items-end" method="get"
                action="${pageContext.request.contextPath}/doctor-schedules">
                <div class="col-md-4">
                  <label for="specialty" class="form-label fw-bold">Dịch vụ / Khoa</label>
                  <select id="specialty" name="specialty" class="form-select">
                    <option value="all" ${selectedSpecialty=='all' ? 'selected' : '' }>Tất cả Dịch vụ / Khoa</option>
                    <c:forEach var="dept" items="${departments}">
                      <option value="${dept.key}" ${selectedSpecialty==dept.key ? 'selected' : '' }>${dept.name}
                      </option>
                    </c:forEach>
                  </select>
                </div>
                <div class="col-md-3">
                  <label for="title" class="form-label fw-bold">Chức danh</label>
                  <select id="title" name="title" class="form-select">
                    <option value="all" ${param.title=='all' ? 'selected' : '' }>Tất cả chức danh</option>
                    <option value="ts" ${param.title=='ts' ? 'selected' : '' }>Tiến sĩ</option>
                    <option value="ths" ${param.title=='ths' ? 'selected' : '' }>Thạc sĩ</option>
                    <option value="bs" ${param.title=='bs' ? 'selected' : '' }>Bác sĩ</option>
                  </select>
                </div>
                <div class="col-md-3">
                  <label for="date" class="form-label fw-bold">Ngày khám</label>
                  <input type="date" class="form-control" id="date" name="date" value="${selectedDate}" required>
                </div>
                <div class="col-md-2">
                  <button type="submit" class="btn btn-primary w-100"><i class="bi bi-search me-2"></i>Lọc</button>
                </div>
              </form>
            </div>

            <!-- Doctor List -->
            <div class="row gy-4" id="doctorList">

              <c:forEach var="doc" items="${doctors}">
                <div class="col-lg-4 col-md-6 doctor-row" data-specialty="${doc.departmentKey}">
                  <div class="card doctor-card border-0 shadow-sm h-100 text-center" style="transition: all 0.3s ease;">
                    <div class="card-img-top overflow-hidden mt-4 mx-auto"
                      style="width: 150px; height: 150px; border-radius: 50%; box-shadow: 0px 4px 10px rgba(0,0,0,0.1);">
                      <img
                        src="${pageContext.request.contextPath}/assets/img/${not empty doc.image ? doc.image : 'doctors/doctors-1.jpg'}"
                        class="img-fluid w-100 h-100" style="object-fit: cover;" alt="${doc.name}">
                    </div>
                    <div class="card-body p-4 d-flex flex-column">
                      <h4 class="card-title fw-bold mb-1" style="color: var(--heading-color);">${doc.name}</h4>
                      <p class="text-primary small fw-semibold mb-3"><i class="bi bi-award me-1"></i> ${doc.specialty}
                      </p>

                      <div class="text-start mt-auto">
                        <h6 class="text-secondary mb-2 border-bottom pb-1" style="font-size: 0.9rem;"><i
                            class="bi bi-clock me-1"></i> Lịch trống (${selectedDate})</h6>
                        <div class="d-flex flex-wrap gap-2 mb-4 justify-content-center">
                          <c:forEach var="slot" items="${doctorSlots[doc.id]}">
                            <c:choose>
                              <c:when test="${slot.booked}">
                                <span
                                  class="badge bg-light text-muted border p-2 text-decoration-line-through">${slot.startTime}</span>
                              </c:when>
                              <c:otherwise>
                                <a href="${pageContext.request.contextPath}/book-appointment?doc=${doc.id}&time=${slot.startTime}"
                                  class="badge bg-white border border-primary text-primary p-2 text-decoration-none time-slot-hover"
                                  style="transition: 0.2s;">${slot.startTime}</a>
                              </c:otherwise>
                            </c:choose>
                          </c:forEach>
                          <c:if test="${empty doctorSlots[doc.id]}">
                            <span class="text-muted small">Không có lịch trống</span>
                          </c:if>
                        </div>
                      </div>

                      <a href="${pageContext.request.contextPath}/book-appointment?doc=${doc.id}"
                        class="btn btn-primary rounded-pill px-4 shadow-sm w-100 mt-2">Đặt lịch khám</a>
                      <button type="button" class="btn btn-outline-info rounded-pill px-4 shadow-sm w-100 mt-2"
                        data-bs-toggle="modal" data-bs-target="#doctorModal${doc.id}">Xem thông tin chi tiết</button>
                    </div>
                  </div>
                </div>

                <!-- Doctor Detail Modal -->
                <div class="modal fade" id="doctorModal${doc.id}" tabindex="-1"
                  aria-labelledby="doctorModalLabel${doc.id}" aria-hidden="true">
                  <div class="modal-dialog modal-lg modal-dialog-centered">
                    <div class="modal-content border-0 shadow">
                      <div class="modal-header border-0 pb-0">
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                      </div>
                      <div class="modal-body p-4 pt-0">
                        <div class="row">
                          <div class="col-md-4 text-center border-end">
                            <img
                              src="${pageContext.request.contextPath}/assets/img/${not empty doc.image ? doc.image : 'doctors/doctors-1.jpg'}"
                              class="img-fluid rounded-circle shadow-sm mb-3"
                              style="width: 180px; height: 180px; object-fit: cover;" alt="${doc.name}">
                            <h4 class="fw-bold text-primary mb-1">${doc.name}</h4>
                            <p class="text-muted mb-3"><i class="bi bi-award me-1"></i> ${doc.specialty}</p>
                            <a href="${pageContext.request.contextPath}/book-appointment?doc=${doc.id}"
                              class="btn btn-primary rounded-pill w-100 mt-2">Đặt lịch ngay</a>
                          </div>
                          <div class="col-md-8 px-4">
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

              <%-- Khi không tìm thấy bác sĩ --%>
                <c:if test="${empty doctors}">
                  <div class="col-12 text-center py-5">
                    <i class="bi bi-search" style="font-size: 60px; color: #dee2e6;"></i>
                    <h4 class="mt-3 text-muted">Không tìm thấy bác sĩ phù hợp</h4>
                    <p class="text-muted">Vui lòng thử chọn chuyên khoa hoặc ngày khác.</p>
                  </div>
                </c:if>

            </div>
          </div>
        </section>

      </main>

      <%-- Include Footer --%>
        <jsp:include page="/views/common/footer.jsp" />