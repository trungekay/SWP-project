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

  <!-- Google Fonts: Inter -->
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
  <!-- Bootstrap 5 CSS & Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <!-- Layout Styles -->
  <link href="${pageContext.request.contextPath}/assets/css/employee.css" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/assets/css/schedule.css?v=3.2" rel="stylesheet">

  <style>
    :root {
      --vc-primary: #0d9488;
      --vc-primary-dark: #0f766e;
      --vc-primary-light: #ccfbf1;
      --vc-primary-subtle: #f0fdfa;
      --vc-slate-900: #0f172a;
      --vc-slate-800: #1e293b;
      --vc-slate-600: #475569;
      --vc-slate-400: #94a3b8;
      --vc-slate-200: #e2e8f0;
      --vc-slate-100: #f1f5f9;
      --vc-slate-50: #f8fafc;
    }

    body {
      font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
      background-color: #f8fafc;
      color: var(--vc-slate-800);
      letter-spacing: -0.01em;
    }

    /* Role Pills at Top */
    .director-role-tabs {
      background: #ffffff;
      padding: 6px;
      border-radius: 14px;
      border: 1px solid var(--vc-slate-200);
      display: inline-flex;
      gap: 6px;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
    }
    .director-role-tab {
      padding: 8px 18px;
      border-radius: 10px;
      font-weight: 600;
      font-size: 0.88rem;
      text-decoration: none;
      color: var(--vc-slate-600);
      transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
      display: inline-flex;
      align-items: center;
      gap: 8px;
    }
    .director-role-tab:hover {
      background-color: var(--vc-slate-100);
      color: var(--vc-slate-900);
    }
    .director-role-tab.active {
      background: linear-gradient(135deg, #0d9488 0%, #0f766e 100%);
      color: #ffffff !important;
      box-shadow: 0 4px 12px rgba(13, 148, 136, 0.3);
    }
    .director-role-tab .count-badge {
      background: rgba(0, 0, 0, 0.08);
      font-size: 11px;
      padding: 2px 7px;
      border-radius: 20px;
      font-weight: 700;
    }
    .director-role-tab.active .count-badge {
      background: rgba(255, 255, 255, 0.25);
      color: #ffffff;
    }

    /* Left Sidebar: Personnel Directory */
    .personnel-panel {
      background: #ffffff;
      border: 1px solid var(--vc-slate-200);
      border-radius: 18px;
      padding: 18px;
      box-shadow: 0 2px 10px rgba(0, 0, 0, 0.02);
      position: sticky;
      top: 86px;
    }
    .personnel-list-scroll {
      max-height: calc(100vh - 270px);
      min-height: 480px;
      overflow-y: auto;
      padding-right: 4px;
    }
    .personnel-list-scroll::-webkit-scrollbar {
      width: 5px;
    }
    .personnel-list-scroll::-webkit-scrollbar-track {
      background: transparent;
    }
    .personnel-list-scroll::-webkit-scrollbar-thumb {
      background: #cbd5e1;
      border-radius: 10px;
    }

    .personnel-item-card {
      background: #ffffff;
      border: 1px solid var(--vc-slate-200);
      border-radius: 14px;
      padding: 12px 14px;
      margin-bottom: 9px;
      cursor: pointer;
      transition: all 0.2s ease;
      text-decoration: none;
      display: block;
      color: inherit;
      position: relative;
    }
    .personnel-item-card:hover {
      border-color: #0d9488;
      transform: translateY(-1px);
      box-shadow: 0 4px 14px rgba(13, 148, 136, 0.08);
    }
    .personnel-item-card.active {
      border-color: #0d9488;
      background: linear-gradient(135deg, #f0fdfa 0%, #ffffff 100%);
      box-shadow: 0 4px 14px rgba(13, 148, 136, 0.15);
      border-left: 4px solid #0d9488;
    }

    .avatar-initial {
      width: 44px;
      height: 44px;
      min-width: 44px;
      border-radius: 12px;
      font-weight: 700;
      font-size: 16px;
      display: flex;
      align-items: center;
      justify-content: center;
      background: linear-gradient(135deg, #ccfbf1 0%, #99f6e4 100%);
      color: #0f766e;
      border: 1px solid #5eead4;
    }
    .avatar-initial.specialist {
      background: linear-gradient(135deg, #e0e7ff 0%, #c7d2fe 100%);
      color: #3730a3;
      border-color: #a5b4fc;
    }
    .avatar-initial.staff {
      background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
      color: #92400e;
      border-color: #fcd34d;
    }

    /* Executive Top Card */
    .executive-card {
      background: #ffffff;
      border-radius: 18px;
      border: 1px solid var(--vc-slate-200);
      box-shadow: 0 2px 12px rgba(0, 0, 0, 0.03);
      padding: 20px 24px;
      margin-bottom: 20px;
    }
    .executive-avatar {
      width: 58px;
      height: 58px;
      border-radius: 16px;
      font-weight: 800;
      font-size: 22px;
      display: flex;
      align-items: center;
      justify-content: center;
      background: linear-gradient(135deg, #0d9488 0%, #0f766e 100%);
      color: #ffffff;
      box-shadow: 0 4px 12px rgba(13, 148, 136, 0.25);
    }
    .kpi-mini-box {
      background: var(--vc-slate-50);
      border: 1px solid var(--vc-slate-200);
      border-radius: 14px;
      padding: 12px 16px;
      min-width: 130px;
      text-align: center;
      transition: all 0.2s;
    }
    .kpi-mini-box:hover {
      background: #ffffff;
      border-color: #0d9488;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.04);
    }
    .kpi-mini-label {
      font-size: 11.5px;
      color: var(--vc-slate-600);
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.3px;
      margin-bottom: 2px;
    }
    .kpi-mini-value {
      font-size: 18px;
      font-weight: 800;
      color: var(--vc-slate-900);
      line-height: 1.2;
    }

    /* Schedule Board & Grid */
    .schedule-board-card {
      background: #ffffff;
      border-radius: 18px;
      border: 1px solid var(--vc-slate-200);
      box-shadow: 0 2px 12px rgba(0, 0, 0, 0.03);
      overflow: hidden;
      padding: 20px;
    }

    /* Horizontal Calendar Table */
    .director-schedule-table {
      width: 100%;
      border-collapse: separate;
      border-spacing: 0;
      table-layout: fixed;
    }
    .director-schedule-table thead th {
      background: #f8fafc;
      color: #475569;
      font-size: 11.5px;
      font-weight: 700;
      padding: 12px 6px;
      text-align: center;
      border-bottom: 2px solid var(--vc-slate-200);
      border-right: 1px solid #f1f5f9;
      letter-spacing: 0.2px;
    }
    .director-schedule-table thead th:last-child {
      border-right: none;
    }
    .director-schedule-table tbody tr {
      transition: background-color 0.15s;
    }
    .director-schedule-table tbody tr:hover {
      background-color: #f8fafc;
    }
    .director-schedule-table tbody td {
      padding: 7px 5px;
      vertical-align: middle;
      border-bottom: 1px solid #f1f5f9;
      border-right: 1px solid #f1f5f9;
      background: #ffffff;
      height: 62px;
    }
    .director-schedule-table tbody td:last-child {
      border-right: none;
    }

    /* Day Column cell */
    .day-info-cell {
      background: #ffffff !important;
      padding-left: 14px !important;
      padding-right: 10px !important;
    }
    .day-row-today td {
      background-color: #f0fdfa !important;
    }
    .day-row-today .day-info-cell {
      border-left: 3px solid #0d9488 !important;
    }

    /* Slot Chips (Interactive & Legible) */
    .chip-slot {
      width: 100%;
      height: 48px;
      border-radius: 10px;
      padding: 5px 6px;
      font-size: 11.5px;
      font-weight: 600;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      text-align: center;
      border: 1px solid transparent;
      transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
      text-decoration: none;
      cursor: pointer;
      line-height: 1.25;
      overflow: hidden;
    }
    .chip-slot:hover {
      transform: scale(1.02);
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.08);
      z-index: 2;
    }

    /* Available Slot: Clean Teal */
    .chip-available {
      background: #f0fdfa;
      border-color: #99f6e4;
      color: #0f766e;
    }
    .chip-available:hover {
      background: #ccfbf1;
      border-color: #0d9488;
      color: #042f2e;
    }

    /* Booked Slot: Professional Indigo / Blue */
    .chip-booked {
      background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%);
      border-color: #93c5fd;
      color: #1e40af;
      box-shadow: 0 1px 3px rgba(37, 99, 235, 0.08);
    }
    .chip-booked:hover {
      background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
      border-color: #3b82f6;
      color: #172554;
    }

    /* On Leave: Soft Amber */
    .chip-onleave {
      background: #fefce8;
      border-color: #fde047;
      color: #854d0e;
    }

    /* Closed: Gray */
    .chip-closed {
      background: #f8fafc;
      border-color: #e2e8f0;
      color: #94a3b8;
      cursor: default;
    }

    /* Off / No Schedule: Muted Dashed */
    .chip-off {
      background: transparent;
      border: 1px dashed #e2e8f0;
      color: #cbd5e1;
      cursor: default;
    }
    .chip-off:hover {
      transform: none;
      box-shadow: none;
    }

    .chip-title {
      font-weight: 700;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
      width: 100%;
      font-size: 11px;
    }
    .chip-sub {
      font-size: 10px;
      opacity: 0.85;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
      width: 100%;
      margin-top: 2px;
      font-weight: 500;
    }

    /* Legend */
    .legend-indicator {
      width: 12px;
      height: 12px;
      border-radius: 4px;
      display: inline-block;
      margin-right: 6px;
    }
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

      <!-- Top Header & Role Navigation Strip -->
      <div class="d-flex flex-column flex-xl-row justify-content-between align-items-xl-center gap-3 mb-4">
        <div>
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-1 small">
              <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/director/dashboard" class="text-teal text-decoration-none"><i class="bi bi-speedometer2 me-1"></i>Giám đốc</a></li>
              <li class="breadcrumb-item active" aria-current="page">Lịch trực &amp; Phân ca nhân sự</li>
            </ol>
          </nav>
          <h2 class="fw-bold mb-1 text-dark">
            <c:choose>
              <c:when test="${employeeType == 'doctor'}"><i class="bi bi-person-badge text-teal me-2"></i>Lịch trực Bác sĩ chuyên khoa</c:when>
              <c:when test="${employeeType == 'specialist'}"><i class="bi bi-clipboard2-pulse text-primary me-2"></i>Lịch trực Kỹ thuật viên / Chuyên viên</c:when>
              <c:otherwise><i class="bi bi-people text-warning me-2"></i>Lịch làm việc Nhân viên tiếp đón &amp; thu ngân</c:otherwise>
            </c:choose>
          </h2>
          <p class="text-muted mb-0 small">Ban Giám đốc theo dõi phân ca, kiểm tra mật độ lịch trực và tiếp nhận yêu cầu điều phối nhân sự toàn viện</p>
        </div>

        <!-- 3 Role Tabs with dynamic count badges -->
        <div class="director-role-tabs">
          <a href="${pageContext.request.contextPath}/director/doctors?year=${selectedYear}&week=${selectedWeek}&session=${sessionFilter}"
             class="director-role-tab ${employeeType == 'doctor' ? 'active' : ''}">
            <i class="bi bi-person-badge"></i>
            <span>Bác sĩ</span>
            <span class="count-badge">${doctorCount > 0 ? doctorCount : fn:length(employeeList)}</span>
          </a>
          <a href="${pageContext.request.contextPath}/director/specialists?year=${selectedYear}&week=${selectedWeek}&session=${sessionFilter}"
             class="director-role-tab ${employeeType == 'specialist' ? 'active' : ''}">
            <i class="bi bi-clipboard2-pulse"></i>
            <span>KTV / Chuyên viên</span>
            <span class="count-badge">${specialistCount > 0 ? specialistCount : '0'}</span>
          </a>
          <a href="${pageContext.request.contextPath}/director/staffs?year=${selectedYear}&week=${selectedWeek}&session=${sessionFilter}"
             class="director-role-tab ${employeeType == 'staff' ? 'active' : ''}">
            <i class="bi bi-people"></i>
            <span>Nhân viên</span>
            <span class="count-badge">${staffCount > 0 ? staffCount : '0'}</span>
          </a>
        </div>
      </div>

      <!-- Main Layout: 3 Columns Left (Personnel List) + 9 Columns Right (Schedule Calendar) -->
      <div class="row g-4">

        <!-- ==================================================================== -->
        <!-- LEFT PANEL: PERSONNEL DIRECTORY -->
        <!-- ==================================================================== -->
        <div class="col-lg-4 col-xl-3">
          <div class="personnel-panel">
            <div class="d-flex align-items-center justify-content-between mb-3 pb-2 border-bottom">
              <div>
                <span class="fw-bold text-dark fs-6 d-block">
                  <i class="bi bi-person-lines-fill text-teal me-1"></i> Đội ngũ nhân sự
                </span>
                <small class="text-muted" style="font-size: 11px;">Chọn nhân sự để xem lịch chi tiết</small>
              </div>
              <span class="badge bg-teal bg-opacity-10 text-teal border border-teal-subtle px-2 py-1 rounded-pill fw-bold">
                ${fn:length(employeeList)} người
              </span>
            </div>

            <!-- Live Search Box -->
            <div class="input-group input-group-sm mb-3">
              <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-search"></i></span>
              <input type="text" id="personnelSearchInput" class="form-control bg-light border-start-0"
                     placeholder="Tìm tên, CCHN, SĐT, chuyên môn..." onkeyup="filterPersonnelList()">
              <button class="btn btn-light border border-start-0 text-muted" type="button" onclick="clearPersonnelSearch()" title="Xóa tìm kiếm">
                <i class="bi bi-x-circle"></i>
              </button>
            </div>

            <!-- Scrollable Personnel Cards -->
            <div class="personnel-list-scroll" id="personnelCardsArea">
              <c:choose>
                <c:when test="${not empty employeeList}">
                  <c:forEach var="emp" items="${employeeList}">
                    <a href="${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?empId=${emp.actorId}&year=${selectedYear}&week=${selectedWeek}&session=${sessionFilter}"
                       class="personnel-item-card ${emp.actorId == selectedEmpId ? 'active' : ''}"
                       data-search="${not empty emp.fullName ? fn:toLowerCase(emp.fullName) : ''} ${not empty emp.specialty ? fn:toLowerCase(emp.specialty) : ''} ${not empty emp.phone ? emp.phone : ''} ${not empty emp.roomName ? fn:toLowerCase(emp.roomName) : ''}">
                      <div class="d-flex align-items-start gap-2.5">
                        <!-- Avatar Initials -->
                        <div class="avatar-initial ${employeeType}">
                          ${fn:substring(emp.fullName, 0, 1)}
                        </div>

                        <!-- Card Body -->
                        <div class="flex-grow-1 overflow-hidden">
                          <div class="d-flex align-items-center justify-content-between mb-0.5">
                            <span class="fw-bold text-dark text-truncate" style="font-size: 13.5px;" title="${emp.fullName}">
                              ${emp.fullName}
                            </span>
                            <c:if test="${emp.actorId == selectedEmpId}">
                              <span class="badge bg-teal text-white rounded-pill px-2 py-0.5" style="font-size: 9.5px;">Đang xem</span>
                            </c:if>
                          </div>

                          <div class="text-truncate text-muted small" style="font-size: 11.5px;" title="${emp.specialty}">
                            <i class="bi bi-award text-teal me-1"></i>${emp.specialty}
                          </div>

                          <c:if test="${not empty emp.roomName && emp.roomName != 'Chưa xếp phòng'}">
                            <div class="text-truncate text-success small mt-0.5" style="font-size: 11px;">
                              <i class="bi bi-door-open me-1"></i>${emp.roomName}
                            </div>
                          </c:if>

                          <div class="text-muted mt-1 d-flex align-items-center justify-content-between" style="font-size: 10.5px;">
                            <span><i class="bi bi-telephone me-1"></i>${not empty emp.phone ? emp.phone : 'Chưa có SĐT'}</span>
                            <span class="text-secondary font-monospace">#${emp.actorId}</span>
                          </div>
                        </div>
                      </div>
                    </a>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <div class="text-center py-5 text-muted">
                    <i class="bi bi-person-slash fs-1 d-block mb-2 text-secondary"></i>
                    <p class="small mb-0">Không có nhân sự nào trong danh mục này.</p>
                  </div>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </div>

        <!-- ==================================================================== -->
        <!-- RIGHT PANEL: SCHEDULE MATRIX BOARD -->
        <!-- ==================================================================== -->
        <div class="col-lg-8 col-xl-9">
          <c:choose>
            <c:when test="${not empty selectedEmployee}">

              <!-- Executive Header Card & Live Metrics -->
              <div class="executive-card">
                <div class="d-flex flex-column flex-xxl-row justify-content-between align-items-xxl-center gap-3">
                  <!-- Personnel Profile Summary -->
                  <div class="d-flex align-items-center gap-3">
                    <div class="executive-avatar">
                      ${fn:substring(selectedEmployee.fullName, 0, 1)}
                    </div>
                    <div>
                      <div class="d-flex align-items-center flex-wrap gap-2 mb-1">
                        <h4 class="mb-0 fw-bold text-dark">${selectedEmployee.fullName}</h4>
                        <span class="badge bg-light text-dark border px-2 py-1 font-monospace" style="font-size: 11.5px;">
                          MÃ: #${selectedEmployee.actorId}
                        </span>
                        <c:if test="${not empty selectedEmployee.roomName && selectedEmployee.roomName != 'Chưa xếp phòng'}">
                          <span class="badge bg-success bg-opacity-10 text-success border border-success-subtle px-2 py-1" style="font-size: 11.5px;">
                            <i class="bi bi-door-open-fill me-1"></i>${selectedEmployee.roomName}
                          </span>
                        </c:if>
                      </div>

                      <div class="text-muted small d-flex flex-wrap align-items-center gap-3">
                        <span><i class="bi bi-award-fill text-teal me-1"></i><b>Chuyên môn:</b> ${selectedEmployee.specialty}</span>
                        <c:if test="${not empty selectedEmployee.licenseNumber}">
                          <span><i class="bi bi-file-medical text-primary me-1"></i><b>CCHN:</b> ${selectedEmployee.licenseNumber}</span>
                        </c:if>
                        <c:if test="${not empty selectedEmployee.phone}">
                          <span><i class="bi bi-telephone-fill text-muted me-1"></i>${selectedEmployee.phone}</span>
                        </c:if>
                      </div>
                    </div>
                  </div>

                  <!-- 4 Executive KPI Boxes -->
                  <div class="d-flex align-items-center flex-wrap gap-2 justify-content-start justify-content-xxl-end">
                    <div class="kpi-mini-box">
                      <div class="kpi-mini-label">Tổng ca trực</div>
                      <div class="kpi-mini-value text-teal" style="color: #0d9488;">${totalWeeklySlots} ca</div>
                    </div>
                    <div class="kpi-mini-box">
                      <div class="kpi-mini-label">Thời lượng</div>
                      <div class="kpi-mini-value text-primary">${totalWeeklyHours} giờ</div>
                    </div>
                    <div class="kpi-mini-box">
                      <div class="kpi-mini-label">Có lịch hẹn</div>
                      <div class="kpi-mini-value text-indigo" style="color: #2563eb;">${totalBookedSlots} lịch</div>
                    </div>
                    <div class="kpi-mini-box">
                      <div class="kpi-mini-label">Sẵn sàng</div>
                      <div class="kpi-mini-value text-success">${totalAvailableSlots} ca</div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Schedule Grid Board -->
              <div class="schedule-board-card">

                <!-- Control Toolbar: Week / Year Navigator & Session Filters -->
                <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-3 pb-3 border-bottom">
                  <!-- Week & Year Selector -->
                  <div class="d-flex align-items-center flex-wrap gap-2">
                    <div class="btn-group btn-group-sm shadow-sm">
                      <a href="${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?empId=${selectedEmpId}&year=${prevYear}&week=${prevWeek}&session=${sessionFilter}"
                         class="btn btn-outline-secondary px-2" title="Tuần trước">
                        <i class="bi bi-chevron-left"></i>
                      </a>
                      <a href="${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?empId=${selectedEmpId}&year=${nextYear}&week=${nextWeek}&session=${sessionFilter}"
                         class="btn btn-outline-secondary px-2" title="Tuần sau">
                        <i class="bi bi-chevron-right"></i>
                      </a>
                    </div>

                    <!-- Week Dropdown -->
                    <select class="form-select form-select-sm fw-semibold shadow-sm" style="min-width: 260px;"
                            onchange="location.href='${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?empId=${selectedEmpId}&year=${selectedYear}&week=' + this.value + '&session=${sessionFilter}'">
                      <c:forEach var="w" items="${weekOptions}">
                        <option value="${w.weekNumber}" ${w.weekNumber == selectedWeek ? 'selected' : ''}>
                          ${w.label}
                        </option>
                      </c:forEach>
                    </select>

                    <!-- Year Dropdown -->
                    <select class="form-select form-select-sm fw-bold shadow-sm" style="width: 105px;"
                            onchange="location.href='${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?empId=${selectedEmpId}&year=' + this.value + '&week=1&session=${sessionFilter}'">
                      <c:forEach var="y" items="${availableYears}">
                        <option value="${y}" ${y == selectedYear ? 'selected' : ''}>Năm ${y}</option>
                      </c:forEach>
                    </select>

                    <c:if test="${!isViewingCurrentWeek}">
                      <a href="${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?empId=${selectedEmpId}&year=${currentYear}&week=1&session=${sessionFilter}"
                         class="btn btn-outline-teal btn-sm rounded-pill px-2.5 py-1 shadow-sm small text-decoration-none fw-semibold"
                         style="border-color: #0d9488; color: #0d9488;">
                        <i class="bi bi-arrow-counterclockwise me-1"></i>Tuần hiện tại
                      </a>
                    </c:if>
                  </div>

                  <!-- Session Shift Filters (All, Morning, Afternoon) -->
                  <div class="btn-group btn-group-sm shadow-sm" role="group">
                    <a href="${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?empId=${selectedEmpId}&year=${selectedYear}&week=${selectedWeek}&session=all"
                       class="btn ${sessionFilter == 'all' ? 'btn-teal text-white' : 'btn-outline-secondary'}" style="${sessionFilter == 'all' ? 'background:#0d9488; border-color:#0d9488;' : ''}">
                      <i class="bi bi-grid-fill me-1"></i>Tất cả ca
                    </a>
                    <a href="${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?empId=${selectedEmpId}&year=${selectedYear}&week=${selectedWeek}&session=Morning"
                       class="btn ${sessionFilter == 'Morning' ? 'btn-teal text-white' : 'btn-outline-secondary'}" style="${sessionFilter == 'Morning' ? 'background:#0d9488; border-color:#0d9488;' : ''}">
                      🌅 Ca Sáng
                    </a>
                    <a href="${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?empId=${selectedEmpId}&year=${selectedYear}&week=${selectedWeek}&session=Afternoon"
                       class="btn ${sessionFilter == 'Afternoon' ? 'btn-teal text-white' : 'btn-outline-secondary'}" style="${sessionFilter == 'Afternoon' ? 'background:#0d9488; border-color:#0d9488;' : ''}">
                      🌇 Ca Chiều
                    </a>
                  </div>
                </div>

                <!-- Main Horizontal Calendar Matrix (Days as Rows, Slots as Columns) -->
                <div class="table-responsive">
                  <table class="director-schedule-table">
                    <thead>
                      <tr>
                        <th style="width: 135px; text-align: left; padding-left: 14px;">NGÀY TRONG TUẦN</th>
                        <c:forEach var="slot" items="${slots}">
                          <c:if test="${sessionFilter == 'all' || slot.session == sessionFilter}">
                            <c:set var="rawSlotName" value="${not empty slot.displayName ? slot.displayName : slot.id}" />
                            <c:set var="cleanSlotName" value="${fn:contains(rawSlotName, ' (') ? fn:substringBefore(rawSlotName, ' (') : rawSlotName}" />
                            <c:set var="cleanSlotName" value="${fn:startsWith(cleanSlotName, 'Slot ') ? fn:replace(cleanSlotName, 'Slot ', 'Ca ') : cleanSlotName}" />
                            <th style="min-width: 90px; text-align: center;">
                              <div class="fw-bold fs-6">${cleanSlotName}</div>
                            </th>
                          </c:if>
                        </c:forEach>
                        <th style="width: 90px; text-align: center;">TỔNG CA</th>
                      </tr>
                    </thead>
                    <tbody>
                      <c:forEach var="day" items="${weekDays}">
                        <tr class="${day.today ? 'day-row-today' : ''}">
                          <!-- Day Header Column -->
                          <td class="day-info-cell">
                            <div class="d-flex align-items-center flex-wrap gap-1">
                              <span class="fw-bold text-dark" style="font-size: 13.5px;">${day.dayName}</span>
                              <span class="badge bg-light text-muted border font-monospace" style="font-size: 10.5px;">${day.dateStr}</span>
                            </div>
                            <c:if test="${day.today}">
                              <span class="badge bg-teal text-white rounded-pill mt-1" style="font-size: 9.5px; background: #0d9488;">
                                <i class="bi bi-clock-history me-1"></i>Hôm nay
                              </span>
                            </c:if>
                          </td>

                          <!-- Slot Columns -->
                          <c:forEach var="slot" items="${slots}">
                            <c:if test="${sessionFilter == 'all' || slot.session == sessionFilter}">
                              <c:set var="key" value="${day.fullDate}_${slot.id}" />
                              <c:set var="cell" value="${scheduleMatrix[key]}" />
                              <c:set var="rawSlotName" value="${not empty slot.displayName ? slot.displayName : slot.id}" />
                              <c:set var="cleanSlotName" value="${fn:contains(rawSlotName, ' (') ? fn:substringBefore(rawSlotName, ' (') : rawSlotName}" />
                              <c:set var="cleanSlotName" value="${fn:startsWith(cleanSlotName, 'Slot ') ? fn:replace(cleanSlotName, 'Slot ', 'Ca ') : cleanSlotName}" />

                              <td class="text-center p-1">
                                <c:choose>
                                  <c:when test="${not empty cell}">
                                    <c:choose>
                                      <%-- 1. Booked (Có khách đặt hẹn) --%>
                                      <c:when test="${cell.booked}">
                                        <div class="chip-slot chip-booked"
                                             title="Nhấn để xem chi tiết cuộc hẹn"
                                             onclick="openAppointmentModal('${cell.appointmentId}', '${cell.patientName}', '${cell.patientPhone}', '${cell.appointmentStatus}', '${cleanSlotName}', '${slot.timeRange}', '${cell.roomName}', '${day.dayName}, ${day.dateStr}')">
                                          <span class="chip-title"><i class="bi bi-person-fill text-primary me-0.5"></i>${cell.patientName}</span>
                                          <span class="chip-sub">
                                            <i class="bi bi-clock"></i> ${cell.startTime.length() >= 5 ? cell.startTime.substring(0, 5) : cell.startTime}
                                          </span>
                                        </div>
                                      </c:when>

                                      <%-- 2. On Leave (Nghỉ phép) --%>
                                      <c:when test="${cell.onLeave}">
                                        <div class="chip-slot chip-onleave" title="Ca trực đã được duyệt nghỉ phép">
                                          <span class="chip-title"><i class="bi bi-calendar-x me-0.5"></i>Nghỉ phép</span>
                                          <span class="chip-sub">Đã duyệt</span>
                                        </div>
                                      </c:when>

                                      <%-- 3. Closed (Đóng ca) --%>
                                      <c:when test="${cell.closed}">
                                        <div class="chip-slot chip-closed" title="Khung giờ này đã bị đóng">
                                          <span class="chip-title"><i class="bi bi-slash-circle me-0.5"></i>Đóng ca</span>
                                          <span class="chip-sub">Tạm dừng</span>
                                        </div>
                                      </c:when>

                                      <%-- 4. Available (Đang trực sẵn sàng) --%>
                                      <c:when test="${cell.available}">
                                        <div class="chip-slot chip-available" title="Ca làm việc sẵn sàng tiếp nhận bệnh nhân">
                                          <span class="chip-title"><i class="bi bi-check2-circle text-teal me-0.5"></i>Làm việc</span>
                                          <span class="chip-sub">
                                            <c:out value="${not empty cell.roomName && cell.roomName != 'Chưa xếp phòng' ? cell.roomName : 'Sẵn sàng'}" />
                                          </span>
                                        </div>
                                      </c:when>

                                      <%-- Default Off --%>
                                      <c:otherwise>
                                        <div class="chip-slot chip-off" title="Không có lịch trực">—</div>
                                      </c:otherwise>
                                    </c:choose>
                                  </c:when>
                                  <c:otherwise>
                                    <div class="chip-slot chip-off" title="Không có lịch trực">—</div>
                                  </c:otherwise>
                                </c:choose>
                              </td>
                            </c:if>
                          </c:forEach>

                          <!-- Total Column -->
                          <td class="text-center">
                            <c:choose>
                              <c:when test="${day.totalSlotsCount > 0}">
                                <span class="badge ${day.today ? 'bg-teal text-white' : 'bg-light text-dark border'} rounded-pill px-2.5 py-1.5 fw-bold"
                                      style="${day.today ? 'background:#0d9488;' : ''}">
                                  ${day.totalSlotsCount} ca
                                </span>
                              </c:when>
                              <c:otherwise>
                                <span class="text-muted small">Nghỉ</span>
                              </c:otherwise>
                            </c:choose>
                          </td>
                        </tr>
                      </c:forEach>
                    </tbody>
                  </table>
                </div>

                <!-- Footer Status Legend & Quick Info -->
                <div class="d-flex flex-column flex-md-row justify-content-between align-items-center gap-3 mt-3 pt-3 border-top small text-muted">
                  <div class="d-flex align-items-center flex-wrap gap-3">
                    <span class="fw-semibold text-dark"><i class="bi bi-info-circle me-1"></i>Chú thích:</span>
                    <div class="d-flex align-items-center">
                      <span class="legend-indicator" style="background: #99f6e4; border: 1px solid #0d9488;"></span>
                      <span><b>Làm việc:</b> Ca trực sẵn sàng tiếp nhận</span>
                    </div>
                    <div class="d-flex align-items-center">
                      <span class="legend-indicator" style="background: #93c5fd; border: 1px solid #2563eb;"></span>
                      <span><b>Có khách khám:</b> Đã có bệnh nhân đặt hẹn (bấm vào xem chi tiết)</span>
                    </div>
                    <div class="d-flex align-items-center">
                      <span class="legend-indicator" style="background: #fde047; border: 1px solid #ca8a04;"></span>
                      <span><b>Nghỉ phép:</b> Ca trực đã duyệt nghỉ</span>
                    </div>
                    <div class="d-flex align-items-center">
                      <span class="legend-indicator" style="background: #ffffff; border: 1px dashed #cbd5e1;"></span>
                      <span><b>Nghỉ:</b> Không có ca</span>
                    </div>
                  </div>

                  <div>
                    <a href="${pageContext.request.contextPath}/director/leave-requests" class="text-teal text-decoration-none fw-semibold">
                      <i class="bi bi-calendar-x me-1"></i>Duyệt yêu cầu nghỉ phép &rarr;
                    </a>
                  </div>
                </div>

              </div>
            </c:when>
            <c:otherwise>
              <!-- Empty State: No Employee Selected -->
              <div class="card border-0 shadow-sm rounded-4 p-5 text-center bg-white">
                <div class="avatar-initial mx-auto mb-3" style="width: 70px; height: 70px; font-size: 28px;">
                  <i class="bi bi-person-x"></i>
                </div>
                <h4 class="fw-bold text-dark">Chưa chọn nhân sự</h4>
                <p class="text-muted mb-0">Vui lòng chọn một nhân sự từ danh sách bên trái để theo dõi lịch trực và mật độ ca chi tiết.</p>
              </div>
            </c:otherwise>
          </c:choose>
        </div>

      </div>

    </div>
  </div>

  <!-- ==================================================================== -->
  <!-- APPOINTMENT DETAIL MODAL (Pop up on click) -->
  <!-- ==================================================================== -->
  <div class="modal fade" id="appointmentDetailModal" tabindex="-1" aria-labelledby="aptModalTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content border-0 shadow rounded-4 overflow-hidden">
        <div class="modal-header text-white" style="background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);">
          <div class="d-flex align-items-center gap-2">
            <i class="bi bi-person-vcard fs-4"></i>
            <div>
              <h6 class="modal-title fw-bold mb-0" id="aptModalTitle">Chi tiết lịch hẹn khám bệnh</h6>
              <small class="opacity-75" id="modalAptIdBadge">Mã lịch hẹn: #APT-00</small>
            </div>
          </div>
          <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>

        <div class="modal-body p-4 bg-light">
          <!-- Patient Info Card -->
          <div class="card border-0 shadow-sm rounded-3 p-3 bg-white mb-3">
            <div class="d-flex align-items-center gap-3">
              <div class="avatar-badge" style="width: 48px; height: 48px; min-width: 48px; font-size: 18px; background: #eff6ff; color: #2563eb; border: 2px solid #bfdbfe;">
                <i class="bi bi-person"></i>
              </div>
              <div class="flex-grow-1">
                <h6 class="fw-bold text-dark mb-1" id="modalPatientName">Nguyễn Văn A</h6>
                <div class="text-muted small d-flex align-items-center gap-2">
                  <i class="bi bi-telephone text-primary"></i>
                  <span id="modalPatientPhone">0912 345 678</span>
                </div>
              </div>
              <span class="badge bg-success bg-opacity-10 text-success border border-success-subtle px-2.5 py-1" id="modalAptStatus">
                Confirmed
              </span>
            </div>
          </div>

          <!-- Appointment Timing & Location Details -->
          <div class="card border-0 shadow-sm rounded-3 p-3 bg-white">
            <h6 class="fw-bold text-dark mb-3 small text-uppercase" style="letter-spacing: 0.5px;">
              <i class="bi bi-calendar-event text-teal me-1"></i> Thông tin buổi khám
            </h6>

            <div class="row g-2 small">
              <div class="col-6">
                <span class="text-muted d-block">Ngày khám:</span>
                <strong class="text-dark" id="modalWorkDate">Thứ Hai, 26/10/2026</strong>
              </div>
              <div class="col-6">
                <span class="text-muted d-block">Ca trực:</span>
                <strong class="text-primary" id="modalSlotTime">Ca 1</strong>
              </div>
              <div class="col-6 mt-3">
                <span class="text-muted d-block">Nhân sự phụ trách:</span>
                <strong class="text-dark">${selectedEmployee.fullName}</strong>
              </div>
              <div class="col-6 mt-3">
                <span class="text-muted d-block">Địa điểm / Phòng khám:</span>
                <strong class="text-success" id="modalRoomName">Phòng Khám Chuyên Khoa</strong>
              </div>
            </div>
          </div>
        </div>

        <div class="modal-footer bg-white border-0 py-3">
          <button type="button" class="btn btn-secondary px-4 rounded-3" data-bs-dismiss="modal">Đóng</button>
        </div>
      </div>
    </div>
  </div>

  <!-- Bootstrap JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

  <!-- Interactive Scripts -->
  <script>
    // 1. Live Filter for Personnel Directory (Search input)
    function filterPersonnelList() {
      const input = document.getElementById('personnelSearchInput');
      const filter = (input ? input.value : '').toLowerCase().trim();
      const cards = document.querySelectorAll('.personnel-item-card');

      cards.forEach(card => {
        const searchData = card.getAttribute('data-search') || '';
        if (searchData.includes(filter)) {
          card.style.display = 'block';
        } else {
          card.style.display = 'none';
        }
      });
    }

    function clearPersonnelSearch() {
      const input = document.getElementById('personnelSearchInput');
      if (input) {
        input.value = '';
        filterPersonnelList();
        input.focus();
      }
    }

    // 2. Open Appointment Detail Modal on Click
    function openAppointmentModal(aptId, patientName, patientPhone, status, slotName, timeRange, roomName, workDate) {
      document.getElementById('modalAptIdBadge').innerText = 'Mã lịch hẹn: #APT-' + (aptId || 'N/A');
      document.getElementById('modalPatientName').innerText = patientName || 'Bệnh nhân';
      document.getElementById('modalPatientPhone').innerText = patientPhone || 'Chưa cung cấp SĐT';
      document.getElementById('modalAptStatus').innerText = status || 'Confirmed';
      document.getElementById('modalWorkDate').innerText = workDate || '';
      document.getElementById('modalSlotTime').innerText = slotName;
      document.getElementById('modalRoomName').innerText = roomName || 'Phòng khám chuyên khoa';

      const modalEl = document.getElementById('appointmentDetailModal');
      if (modalEl) {
        const modal = new bootstrap.Modal(modalEl);
        modal.show();
      }
    }
  </script>
</body>
</html>
