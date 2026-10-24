<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>
    <c:choose>
      <c:when test="${employeeType == 'doctor'}">Lịch trực Bác sĩ</c:when>
      <c:when test="${employeeType == 'specialist'}">Lịch trực KTV / Chuyên viên</c:when>
      <c:otherwise>Lịch làm việc Nhân viên</c:otherwise>
    </c:choose>
    - Ban Giám Đốc VisionCare
  </title>
  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <!-- Bootstrap 5 CSS & Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <!-- Layout & Custom Schedule CSS -->
  <link href="${pageContext.request.contextPath}/assets/css/employee.css" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/assets/css/schedule.css?v=3.0" rel="stylesheet">
  <style>
    body {
      font-family: 'Inter', sans-serif;
      background-color: #f8fafc;
      color: #1e293b;
    }
    .director-nav-pills {
      background: #ffffff;
      padding: 6px;
      border-radius: 12px;
      border: 1px solid #e2e8f0;
      display: inline-flex;
      gap: 6px;
    }
    .director-nav-link {
      padding: 8px 18px;
      border-radius: 8px;
      font-weight: 600;
      font-size: 0.9rem;
      text-decoration: none;
      color: #64748b;
      transition: all 0.2s;
      display: inline-flex;
      align-items: center;
      gap: 8px;
    }
    .director-nav-link:hover {
      background-color: #f1f5f9;
      color: #0f172a;
    }
    .director-nav-link.active {
      background-color: #0d9488;
      color: #ffffff !important;
      box-shadow: 0 2px 6px rgba(13, 148, 136, 0.25);
    }
    .emp-item-card {
      background: #ffffff;
      border: 1px solid #e2e8f0;
      border-radius: 12px;
      padding: 14px 16px;
      margin-bottom: 10px;
      cursor: pointer;
      transition: all 0.2s ease;
      text-decoration: none;
      display: block;
      color: inherit;
    }
    .emp-item-card:hover {
      border-color: #0d9488;
      transform: translateX(3px);
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
    }
    .emp-item-card.active {
      border-color: #0d9488;
      background-color: #f0fdfa;
      box-shadow: 0 4px 12px rgba(13, 148, 136, 0.12);
    }
    .emp-list-container {
      max-height: 720px;
      overflow-y: auto;
      padding-right: 4px;
    }
    .emp-list-container::-webkit-scrollbar {
      width: 6px;
    }
    .emp-list-container::-webkit-scrollbar-thumb {
      background: #cbd5e1;
      border-radius: 4px;
    }
    .badge-soft-teal { background-color: #ccfbf1; color: #0d9488; }
    .badge-soft-blue { background-color: #dbeafe; color: #1d4ed8; }
    .badge-soft-amber { background-color: #fef3c7; color: #d97706; }
    .badge-soft-purple { background-color: #f3e8ff; color: #7e22ce; }
  </style>
</head>
<body>

  <!-- Director Sidebar -->
  <jsp:include page="/views/director/layout/director-sidebar.jsp">
    <jsp:param name="activeNav" value="${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}" />
  </jsp:include>

  <!-- Main Wrapper -->
  <div class="main-wrapper">
    <!-- Top Header -->
    <jsp:include page="/views/employee/layout/employee-header.jsp" />

    <!-- Page Content -->
    <div class="page-content">

      <!-- Top Title & Navigation Tabs -->
      <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
        <div>
          <h2 class="fw-bold mb-1">
            <c:choose>
              <c:when test="${employeeType == 'doctor'}"><i class="bi bi-person-badge text-primary me-2"></i>Lịch trực Bác sĩ</c:when>
              <c:when test="${employeeType == 'specialist'}"><i class="bi bi-clipboard2-pulse text-success me-2"></i>Lịch trực Kỹ thuật viên / Chuyên viên</c:when>
              <c:otherwise><i class="bi bi-people text-info me-2"></i>Lịch làm việc Nhân viên lễ tân & thu ngân</c:otherwise>
            </c:choose>
          </h2>
          <p class="text-muted mb-0">Ban Giám đốc theo dõi phân ca, kiểm tra mật độ lịch trực và tiếp nhận yêu cầu điều phối nhân sự</p>
        </div>

        <!-- 3 Role Tabs -->
        <div class="director-nav-pills">
          <a href="${pageContext.request.contextPath}/director/doctors" class="director-nav-link ${employeeType == 'doctor' ? 'active' : ''}">
            <i class="bi bi-person-badge"></i> Bác sĩ (${employeeType == 'doctor' ? fn:length(employeeList) : 'Xem'})
          </a>
          <a href="${pageContext.request.contextPath}/director/specialists" class="director-nav-link ${employeeType == 'specialist' ? 'active' : ''}">
            <i class="bi bi-clipboard2-pulse"></i> KTV / Chuyên viên (${employeeType == 'specialist' ? fn:length(employeeList) : 'Xem'})
          </a>
          <a href="${pageContext.request.contextPath}/director/staffs" class="director-nav-link ${employeeType == 'staff' ? 'active' : ''}">
            <i class="bi bi-people"></i> Nhân viên (${employeeType == 'staff' ? fn:length(employeeList) : 'Xem'})
          </a>
        </div>
      </div>

      <!-- Main Layout: Left = Employee List | Right = Schedule Calendar -->
      <div class="row g-4">
        <!-- LEFT: Employee Directory -->
        <div class="col-lg-4 col-xl-3">
          <div class="card border-0 shadow-sm rounded-4 p-3 bg-white h-100">
            <div class="d-flex align-items-center justify-content-between mb-3">
              <span class="fw-bold text-dark fs-6">
                <i class="bi bi-card-list text-teal me-1"></i> Danh sách nhân sự
              </span>
              <span class="badge bg-light text-dark border">${fn:length(employeeList)} người</span>
            </div>

            <!-- Search box -->
            <div class="input-group input-group-sm mb-3">
              <span class="input-group-text bg-light border-end-0"><i class="bi bi-search text-muted"></i></span>
              <input type="text" id="employeeSearchInput" class="form-control bg-light border-start-0" placeholder="Tìm tên, SĐT, chuyên khoa..." onkeyup="filterEmployees()">
            </div>

            <!-- Employee List Cards -->
            <div class="emp-list-container" id="employeeListArea">
              <c:choose>
                <c:when test="${not empty employeeList}">
                  <c:forEach var="emp" items="${employeeList}">
                    <a href="${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?empId=${emp.actorId}&year=${selectedYear}&week=${selectedWeek}&session=${sessionFilter}"
                       class="emp-item-card ${emp.actorId == selectedEmpId ? 'active' : ''}"
                       data-search="${emp.fullName.toLowerCase()} ${emp.specialty.toLowerCase()} ${emp.phone}">
                      <div class="d-flex align-items-start gap-2">
                        <div class="avatar-badge" style="width: 42px; height: 42px; min-width: 42px; font-size: 15px;">
                          ${fn:substring(emp.fullName, 0, 1)}
                        </div>
                        <div class="flex-grow-1 overflow-hidden">
                          <div class="d-flex align-items-center justify-content-between">
                            <span class="fw-bold text-dark text-truncate" style="max-width: 130px;" title="${emp.fullName}">${emp.fullName}</span>
                            <c:if test="${emp.actorId == selectedEmpId}">
                              <span class="badge bg-teal text-white rounded-pill" style="font-size: 10px;">Đang xem</span>
                            </c:if>
                          </div>
                          <small class="text-muted d-block text-truncate" title="${emp.specialty}">
                            <i class="bi bi-star me-1 text-warning"></i>${emp.specialty}
                          </small>
                          <c:if test="${not empty emp.roomName && emp.roomName != 'Chưa xếp phòng'}">
                            <small class="text-success d-block text-truncate">
                              <i class="bi bi-door-open me-1"></i>${emp.roomName}
                            </small>
                          </c:if>
                          <small class="text-muted d-block mt-1">
                            <i class="bi bi-telephone me-1"></i>${not empty emp.phone ? emp.phone : 'Chưa có SĐT'}
                          </small>
                        </div>
                      </div>
                    </a>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <div class="text-center py-4 text-muted">
                    <i class="bi bi-person-x fs-2 d-block mb-1"></i>
                    Không có nhân sự nào thuộc phân loại này.
                  </div>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </div>

        <!-- RIGHT: Selected Employee Profile & Weekly Schedule Grid -->
        <div class="col-lg-8 col-xl-9">
          <c:choose>
            <c:when test="${not empty selectedEmployee}">
              <!-- Employee Profile Top Card -->
              <div class="profile-header-card mb-3">
                <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
                  <div class="d-flex align-items-center gap-3">
                    <div class="avatar-badge">
                      ${fn:substring(selectedEmployee.fullName, 0, 1)}
                    </div>
                    <div>
                      <div class="d-flex align-items-center flex-wrap gap-2">
                        <h4 class="mb-0 fw-bold text-dark">${selectedEmployee.fullName}</h4>
                        <span class="badge-code">ID: #${selectedEmployee.actorId}</span>
                        <c:if test="${not empty selectedEmployee.roomName}">
                          <span class="badge-room"><i class="bi bi-geo-alt-fill text-success"></i> ${selectedEmployee.roomName}</span>
                        </c:if>
                      </div>
                      <div class="text-muted small mt-1">
                        <span class="me-3"><i class="bi bi-briefcase me-1 text-teal"></i><b>Chuyên môn:</b> ${selectedEmployee.specialty}</span>
                        <c:if test="${not empty selectedEmployee.licenseNumber}">
                          <span class="me-3"><i class="bi bi-award me-1 text-primary"></i><b>CCHN:</b> ${selectedEmployee.licenseNumber}</span>
                        </c:if>
                        <c:if test="${not empty selectedEmployee.phone}">
                          <span><i class="bi bi-telephone me-1 text-muted"></i>${selectedEmployee.phone}</span>
                        </c:if>
                      </div>
                    </div>
                  </div>

                  <!-- Weekly Slots Stats -->
                  <div class="d-flex align-items-center justify-content-end">
                    <div class="text-center px-3 border-start">
                      <div class="stat-label">Tổng ca tuần này</div>
                      <div class="stat-value text-teal">${totalWeeklySlots} ca</div>
                    </div>
                    <div class="text-center px-3 border-start">
                      <div class="stat-label">Tổng thời gian</div>
                      <div class="stat-value text-primary">${totalWeeklyHours} giờ</div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Schedule Grid Container -->
              <div class="card border-0 shadow-sm rounded-4 p-3 bg-white">
                <!-- Toolbar: Week / Year / Session Filters -->
                <div class="schedule-toolbar mb-3">
                  <!-- Prev / Next & Week Selector -->
                  <div class="d-flex align-items-center gap-2 flex-wrap">
                    <div class="btn-group btn-group-sm">
                      <a href="${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?empId=${selectedEmpId}&year=${prevYear}&week=${prevWeek}&session=${sessionFilter}"
                         class="btn btn-outline-secondary" title="Tuần trước">
                        <i class="bi bi-chevron-left"></i>
                      </a>
                      <a href="${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?empId=${selectedEmpId}&year=${nextYear}&week=${nextWeek}&session=${sessionFilter}"
                         class="btn btn-outline-secondary" title="Tuần sau">
                        <i class="bi bi-chevron-right"></i>
                      </a>
                    </div>

                    <!-- Week Selector -->
                    <select class="form-select form-select-sm" style="min-width: 250px;"
                            onchange="location.href='${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?empId=${selectedEmpId}&year=${selectedYear}&week=' + this.value + '&session=${sessionFilter}'">
                      <c:forEach var="w" items="${weekOptions}">
                        <option value="${w.weekNumber}" ${w.weekNumber == selectedWeek ? 'selected' : ''}>
                          ${w.label}
                        </option>
                      </c:forEach>
                    </select>

                    <!-- Year Selector -->
                    <select class="form-select form-select-sm" style="width: 100px;"
                            onchange="location.href='${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?empId=${selectedEmpId}&year=' + this.value + '&week=1&session=${sessionFilter}'">
                      <c:forEach var="y" items="${availableYears}">
                        <option value="${y}" ${y == selectedYear ? 'selected' : ''}>Năm ${y}</option>
                      </c:forEach>
                    </select>

                    <c:if test="${isViewingCurrentWeek}">
                      <span class="badge bg-success bg-opacity-10 text-success border border-success-subtle px-2 py-1">
                        <i class="bi bi-clock-history me-1"></i> Tuần hiện tại
                      </span>
                    </c:if>
                  </div>

                  <!-- Session Filter (Morning, Afternoon, All) -->
                  <div class="session-filters mt-2 mt-md-0">
                    <a href="${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?empId=${selectedEmpId}&year=${selectedYear}&week=${selectedWeek}&session=all"
                       class="session-btn ${sessionFilter == 'all' ? 'active' : ''}">Tất cả</a>
                    <a href="${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?empId=${selectedEmpId}&year=${selectedYear}&week=${selectedWeek}&session=morning"
                       class="session-btn ${sessionFilter == 'morning' ? 'active' : ''}">Ca Sáng</a>
                    <a href="${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?empId=${selectedEmpId}&year=${selectedYear}&week=${selectedWeek}&session=afternoon"
                       class="session-btn ${sessionFilter == 'afternoon' ? 'active' : ''}">Ca Chiều</a>
                  </div>
                </div>

                <!-- Calendar Matrix -->
                <div class="table-responsive">
                  <table class="schedule-grid w-100">
                    <thead>
                      <tr>
                        <th class="time-header text-center" style="width: 110px;">Khung giờ</th>
                        <c:forEach var="day" items="${weekDays}">
                          <th class="day-header ${day.today ? 'today-header' : ''}">
                            <div class="day-name fw-bold">${day.dayName}</div>
                            <div class="day-date">${day.date}</div>
                            <div class="badge bg-light text-muted fw-normal mt-1" style="font-size: 10px;">
                              ${day.totalSlotsCount} ca trực
                            </div>
                          </th>
                        </c:forEach>
                      </tr>
                    </thead>
                    <tbody>
                      <c:forEach var="slot" items="${slots}">
                        <c:if test="${sessionFilter == 'all' || (sessionFilter == 'morning' && slot.session == 'Morning') || (sessionFilter == 'afternoon' && slot.session == 'Afternoon')}">
                          <tr>
                            <!-- Slot Column -->
                            <td class="time-slot-cell text-center p-2">
                              <span class="slot-badge">${slot.id}</span>
                              <div class="time-range text-muted small">${slot.timeRange}</div>
                            </td>

                            <!-- 7 Days Columns -->
                            <c:forEach var="day" items="${weekDays}">
                              <c:set var="key" value="${day.fullDate}_${slot.id}" />
                              <c:set var="cell" value="${scheduleMatrix[key]}" />
                              
                              <td class="slot-cell ${day.today ? 'today-column' : ''}">
                                <c:choose>
                                  <c:when test="${not empty cell}">
                                    <c:choose>
                                      <%-- Ca có bệnh nhân đặt hẹn --%>
                                      <c:when test="${cell.appointmentId > 0}">
                                        <div class="cell-card booked shadow-sm p-2 rounded-3 text-start">
                                          <div class="d-flex align-items-center justify-content-between mb-1">
                                            <span class="badge bg-primary px-2 py-1" style="font-size: 10px;">
                                              <i class="bi bi-person-fill"></i> Có hẹn
                                            </span>
                                            <span class="font-monospace text-muted" style="font-size: 10px;">#APT-${cell.appointmentId}</span>
                                          </div>
                                          <div class="fw-bold text-dark text-truncate" style="font-size: 12px;" title="${cell.patientName}">
                                            ${cell.patientName}
                                          </div>
                                          <div class="text-muted" style="font-size: 11px;">
                                            <i class="bi bi-telephone"></i> ${cell.patientPhone}
                                          </div>
                                          <div class="mt-1">
                                            <span class="badge bg-success bg-opacity-10 text-success border border-success-subtle" style="font-size: 10px;">
                                              ${cell.appointmentStatus}
                                            </span>
                                          </div>
                                        </div>
                                      </c:when>

                                      <%-- Nghỉ phép / Đã duyệt nghỉ --%>
                                      <c:when test="${cell.onLeave}">
                                        <div class="cell-card on-leave p-2 rounded-3 text-center">
                                          <i class="bi bi-calendar-x text-warning d-block mb-1"></i>
                                          <span class="badge bg-warning bg-opacity-10 text-warning border border-warning-subtle" style="font-size: 11px;">
                                            Nghỉ phép
                                          </span>
                                        </div>
                                      </c:when>

                                      <%-- Bị đóng hoặc hủy --%>
                                      <c:when test="${cell.closed || cell.status == 'Canceled'}">
                                        <div class="cell-card closed p-2 rounded-3 text-center">
                                          <span class="text-muted small text-decoration-line-through">Đã đóng/Hủy</span>
                                        </div>
                                      </c:when>

                                      <%-- Ca trống đang trực sẵn sàng --%>
                                      <c:otherwise>
                                        <div class="cell-card available shadow-sm p-2 rounded-3 text-center">
                                          <span class="badge bg-teal bg-opacity-10 text-teal border border-teal-subtle" style="font-size: 11px;">
                                            <i class="bi bi-check-circle me-1"></i> Sẵn sàng
                                          </span>
                                          <div class="text-muted mt-1" style="font-size: 10px;">Trực tiếp nhận</div>
                                        </div>
                                      </c:otherwise>
                                    </c:choose>
                                  </c:when>
                                  <c:otherwise>
                                    <div class="cell-card off text-center p-2 text-muted" style="font-size: 12px;">
                                      —
                                    </div>
                                  </c:otherwise>
                                </c:choose>
                              </td>
                            </c:forEach>
                          </tr>
                        </c:if>
                      </c:forEach>
                    </tbody>
                  </table>
                </div>

                <!-- Legend / Status Guide -->
                <div class="d-flex flex-wrap gap-4 align-items-center justify-content-center mt-3 pt-3 border-top" style="font-size: 12px;">
                  <div class="d-flex align-items-center gap-1">
                    <span class="badge bg-teal bg-opacity-10 text-teal border border-teal-subtle p-1 px-2">Sẵn sàng</span>
                    <span class="text-muted">Đang trực khám / nhận bệnh</span>
                  </div>
                  <div class="d-flex align-items-center gap-1">
                    <span class="badge bg-primary p-1 px-2">Có hẹn</span>
                    <span class="text-muted">Đã có bệnh nhân đặt lịch</span>
                  </div>
                  <div class="d-flex align-items-center gap-1">
                    <span class="badge bg-warning bg-opacity-10 text-warning border border-warning-subtle p-1 px-2">Nghỉ phép</span>
                    <span class="text-muted">Ca trực đã được giám đốc duyệt nghỉ</span>
                  </div>
                  <div class="d-flex align-items-center gap-1">
                    <span class="badge bg-light text-muted border p-1 px-2 text-decoration-line-through">Đã đóng</span>
                    <span class="text-muted">Ca bị hủy hoặc khóa</span>
                  </div>
                </div>

              </div>
            </c:when>
            <c:otherwise>
              <div class="card border-0 shadow-sm rounded-4 p-5 text-center bg-white">
                <i class="bi bi-person-x fs-1 text-muted mb-2"></i>
                <h5 class="fw-bold text-dark">Chưa chọn nhân sự</h5>
                <p class="text-muted mb-0">Vui lòng chọn một nhân sự từ danh sách bên trái để xem lịch trực chi tiết.</p>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>

    </div>
  </div>

  <!-- Bootstrap JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

  <!-- Live Search for Employee List -->
  <script>
    function filterEmployees() {
      const input = document.getElementById('employeeSearchInput');
      const filter = input.value.toLowerCase().trim();
      const cards = document.querySelectorAll('.emp-item-card');

      cards.forEach(card => {
        const searchData = card.getAttribute('data-search') || '';
        if (searchData.includes(filter)) {
          card.style.display = 'block';
        } else {
          card.style.display = 'none';
        }
      });
    }
  </script>
</body>
</html>
