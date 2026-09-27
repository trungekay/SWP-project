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
      box-shadow: 0 10px 20px rgba(0,0,0,0.05);
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
      margin-bottom: 40px;
    }
  </style>

  <main class="main">

    <div class="page-title" data-aos="fade">
      <div class="heading">
        <div class="container">
          <div class="row d-flex justify-content-center text-center">
            <div class="col-lg-8">
              <h1>Danh sách bác sĩ nhãn khoa</h1>
              <p class="mb-0">Tìm bác sĩ theo chuyên khoa nhãn khoa, xem khung giờ trống và đặt lịch khám mắt trực tuyến.</p>
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
          <form class="row g-3 align-items-end" method="get" action="${pageContext.request.contextPath}/doctor-schedules">
            <div class="col-md-4">
              <label for="specialty" class="form-label fw-bold">Chuyên khoa</label>
              <select id="specialty" name="specialty" class="form-select">
                <option value="all" ${selectedSpecialty == 'all' ? 'selected' : ''}>Tất cả chuyên khoa</option>
                <c:forEach var="dept" items="${departments}">
                  <option value="${dept.key}" ${selectedSpecialty == dept.key ? 'selected' : ''}>${dept.name}</option>
                </c:forEach>
              </select>
            </div>
            <div class="col-md-4">
              <label for="date" class="form-label fw-bold">Ngày khám</label>
              <input type="date" class="form-control" id="date" name="date" value="${selectedDate}" required>
            </div>
            <div class="col-md-4">
              <button type="submit" class="btn btn-primary w-100"><i class="bi bi-search me-2"></i>Tìm bác sĩ</button>
            </div>
          </form>
        </div>

        <!-- Doctor List -->
        <div class="row gy-4" id="doctorList">

          <c:forEach var="doc" items="${doctors}">
            <div class="col-lg-12 doctor-row" data-specialty="${doc.departmentKey}">
              <div class="schedule-card bg-white p-4">
                <div class="row">
                  <div class="col-md-3 text-center border-end">
                    <img src="${pageContext.request.contextPath}/assets/img/${doc.image}" alt="${doc.name}" class="doctor-avatar mb-3">
                    <h4 class="mb-1 text-primary">${doc.name}</h4>
                    <p class="text-muted small mb-2">${doc.specialty}</p>
                    <div class="d-flex justify-content-center gap-1 text-warning mb-3">
                      <%-- Render stars based on rating --%>
                      <c:forEach begin="1" end="5" var="star">
                        <c:choose>
                          <c:when test="${star <= doc.rating}">
                            <i class="bi bi-star-fill"></i>
                          </c:when>
                          <c:when test="${star - 0.5 <= doc.rating}">
                            <i class="bi bi-star-half"></i>
                          </c:when>
                          <c:otherwise>
                            <i class="bi bi-star"></i>
                          </c:otherwise>
                        </c:choose>
                      </c:forEach>
                    </div>
                    <a href="${pageContext.request.contextPath}/book-appointment?doc=${doc.id}" class="btn btn-outline-primary btn-sm rounded-pill px-4">Đặt lịch</a>
                  </div>
                  <div class="col-md-9 px-4">
                    <h5 class="mb-3 border-bottom pb-2">Khung giờ trống — <span class="text-muted">${selectedDate}</span></h5>

                    <%-- Buổi sáng --%>
                    <div class="mb-4">
                      <h6 class="text-primary mb-2"><i class="bi bi-brightness-alt-high me-2"></i>Buổi sáng</h6>
                      <div class="d-flex flex-wrap">
                        <c:forEach var="slot" items="${doctorSlots[doc.id]}">
                          <c:if test="${slot.startTime < '12:00'}">
                            <c:choose>
                              <c:when test="${slot.booked}">
                                <span class="time-slot booked">${slot.startTime} (Đã đặt)</span>
                              </c:when>
                              <c:otherwise>
                                <a href="${pageContext.request.contextPath}/book-appointment?doc=${doc.id}&time=${slot.startTime}" class="time-slot">${slot.startTime}</a>
                              </c:otherwise>
                            </c:choose>
                          </c:if>
                        </c:forEach>
                      </div>
                    </div>

                    <%-- Buổi chiều --%>
                    <div>
                      <h6 class="text-primary mb-2"><i class="bi bi-sun me-2"></i>Buổi chiều</h6>
                      <div class="d-flex flex-wrap">
                        <c:forEach var="slot" items="${doctorSlots[doc.id]}">
                          <c:if test="${slot.startTime >= '12:00'}">
                            <c:choose>
                              <c:when test="${slot.booked}">
                                <span class="time-slot booked">${slot.startTime} (Đã đặt)</span>
                              </c:when>
                              <c:otherwise>
                                <a href="${pageContext.request.contextPath}/book-appointment?doc=${doc.id}&time=${slot.startTime}" class="time-slot">${slot.startTime}</a>
                              </c:otherwise>
                            </c:choose>
                          </c:if>
                        </c:forEach>
                      </div>
                    </div>

                  </div>
                </div>
              </div>
            </div>
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
