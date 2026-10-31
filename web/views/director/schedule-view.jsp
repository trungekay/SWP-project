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
      <c:when test="${viewMode == 'schedule'}">
        Lịch trực chi tiết: ${selectedEmployee.fullName} - VisionCare
      </c:when>
      <c:otherwise>
        <c:choose>
          <c:when test="${employeeType == 'doctor'}">Đội ngũ Bác sĩ & Lịch trực</c:when>
          <c:when test="${employeeType == 'specialist'}">Đội ngũ KTV / Chuyên viên & Lịch</c:when>
          <c:otherwise>Đội ngũ Nhân viên & Lịch làm việc</c:otherwise>
        </c:choose>
        - Ban Giám Đốc VisionCare
      </c:otherwise>
    </c:choose>
  </title>

  <!-- Google Fonts: Inter -->
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
  <!-- Bootstrap 5 CSS & Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <!-- Layout Styles -->
  <link href="${pageContext.request.contextPath}/assets/css/employee.css" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/assets/css/schedule.css?v=3.5" rel="stylesheet">

  <style>
    :root {
      --vc-primary: #0d9488;
      --vc-primary-dark: #0f766e;
      --vc-primary-light: #ccfbf1;
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

    /* ========================================================= */
    /* VIEW 1: PERSONNEL DIRECTORY GRID CARDS                     */
    /* ========================================================= */
    .personnel-grid-card {
      background: #ffffff;
      border: 1px solid var(--vc-slate-200);
      border-radius: 18px;
      padding: 22px;
      transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
      position: relative;
      display: flex;
      flex-direction: column;
      height: 100%;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.02);
    }
    .personnel-grid-card:hover {
      transform: translateY(-4px);
      box-shadow: 0 12px 24px rgba(13, 148, 136, 0.09);
      border-color: #0d9488;
    }

    .emp-avatar-box {
      width: 56px;
      height: 56px;
      min-width: 56px;
      border-radius: 16px;
      font-weight: 800;
      font-size: 20px;
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
    }
    .emp-avatar-box.doctor {
      background: linear-gradient(135deg, #ccfbf1 0%, #99f6e4 100%);
      color: #0f766e;
      border: 1px solid #5eead4;
    }
    .emp-avatar-box.specialist {
      background: linear-gradient(135deg, #e0e7ff 0%, #c7d2fe 100%);
      color: #3730a3;
      border: 1px solid #a5b4fc;
    }
    .emp-avatar-box.staff {
      background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
      color: #92400e;
      border: 1px solid #fcd34d;
    }

    .emp-stat-pill {
      background: var(--vc-slate-50);
      border: 1px solid var(--vc-slate-200);
      border-radius: 10px;
      padding: 6px 10px;
      font-size: 11.5px;
      text-align: center;
      flex: 1;
    }

    /* ========================================================= */
    /* VIEW 2: FULL-WIDTH CALENDAR MATRIX                         */
    /* ========================================================= */
    .schedule-full-card {
      background: #ffffff;
      border-radius: 18px;
      border: 1px solid var(--vc-slate-200);
      box-shadow: 0 2px 14px rgba(0, 0, 0, 0.03);
      padding: 24px;
      overflow: hidden;
    }

    /* Horizontal Calendar Table - Full Width with Horizontal Scroll */
    .table-responsive {
      border-radius: 14px;
      border: 1px solid var(--vc-slate-200);
      background: #ffffff;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.02);
      overflow-x: auto;
      -webkit-overflow-scrolling: touch;
    }
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
      padding: 10px 4px;
      text-align: center;
      border-bottom: 2px solid var(--vc-slate-200);
      border-right: 1px solid #f1f5f9;
      vertical-align: middle;
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
      padding: 6px 4px;
      vertical-align: middle;
      border-bottom: 1px solid #f1f5f9;
      border-right: 1px solid #f1f5f9;
      background: #ffffff;
      height: 64px;
    }
    .director-schedule-table tbody td:last-child {
      border-right: none;
    }

    /* Day Column cell */
    .day-info-cell {
      background: #ffffff !important;
      padding-left: 14px !important;
      padding-right: 10px !important;
      width: 130px;
      min-width: 130px;
      max-width: 130px;
    }
    .day-row-today td {
      background-color: #f0fdfa !important;
    }
    .day-row-today .day-info-cell {
      border-left: 4px solid #0d9488 !important;
    }

    /* Slot Column Header Box (Ca ở trên, giờ ở dưới có nền nhỏ, không chồng chéo) */
    .slot-header-box {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      gap: 3px;
      padding: 2px 0;
    }
    .slot-header-title {
      font-weight: 800;
      font-size: 13px;
      color: #0f172a;
      white-space: nowrap;
      line-height: 1.2;
    }
    .slot-header-time {
      font-size: 10px;
      font-weight: 500;
      color: #64748b;
      white-space: nowrap;
      line-height: 1.1;
      display: inline-block;
      padding: 2px 5px;
      border-radius: 4px;
      background: rgba(100, 116, 139, 0.08);
    }

    /* Slot Chips (Interactive & Legible) */
    .chip-slot {
      width: 100%;
      height: 52px;
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
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
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
      font-size: 11.5px;
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

    /* Executive Top Card & KPI Boxes */
    .executive-card {
      background: #ffffff;
      border-radius: 18px;
      border: 1px solid var(--vc-slate-200);
      box-shadow: 0 2px 12px rgba(0, 0, 0, 0.03);
      padding: 22px 26px;
      margin-bottom: 22px;
    }
    .executive-avatar {
      width: 58px;
      height: 58px;
      min-width: 58px;
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
      padding: 10px 16px;
      min-width: 125px;
      text-align: center;
      transition: all 0.2s;
    }
    .kpi-mini-box:hover {
      background: #ffffff;
      border-color: #0d9488;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.04);
    }
    .kpi-mini-label {
      font-size: 11px;
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

      <!-- ==================================================================== -->
      <!-- TOP NAVIGATION BAR (Clean, no redundant role pills)                  -->
      <!-- ==================================================================== -->
      <div class="d-flex flex-column flex-xl-row justify-content-between align-items-xl-center gap-3 mb-4">
        <div>
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-1 small">
              <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/director/revenue" class="text-teal text-decoration-none" style="color: #0d9488;"><i class="bi bi-graph-up me-1"></i>Giám đốc</a></li>
              <c:choose>
                <c:when test="${viewMode == 'schedule'}">
                  <li class="breadcrumb-item">
                    <a href="${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?view=list" class="text-teal text-decoration-none">
                      <c:choose>
                        <c:when test="${employeeType == 'doctor'}">Đội ngũ Bác sĩ</c:when>
                        <c:when test="${employeeType == 'specialist'}">Đội ngũ KTV / Chuyên viên</c:when>
                        <c:otherwise>Đội ngũ Nhân viên</c:otherwise>
                      </c:choose>
                    </a>
                  </li>
                  <li class="breadcrumb-item active" aria-current="page">Lịch trực: ${selectedEmployee.fullName}</li>
                </c:when>
                <c:otherwise>
                  <li class="breadcrumb-item active" aria-current="page">
                    <c:choose>
                      <c:when test="${employeeType == 'doctor'}">Đội ngũ Bác sĩ chuyên khoa</c:when>
                      <c:when test="${employeeType == 'specialist'}">Đội ngũ Kỹ thuật viên / Chuyên viên</c:when>
                      <c:otherwise>Đội ngũ Nhân viên tiếp đón &amp; thu ngân</c:otherwise>
                    </c:choose>
                  </li>
                </c:otherwise>
              </c:choose>
            </ol>
          </nav>

          <h2 class="fw-bold mb-1 text-dark">
            <c:choose>
              <c:when test="${viewMode == 'schedule'}">
                <i class="bi bi-calendar-check text-teal me-2" style="color: #0d9488;"></i>Lịch trực chi tiết: ${selectedEmployee.fullName}
              </c:when>
              <c:otherwise>
                <c:choose>
                  <c:when test="${employeeType == 'doctor'}"><i class="bi bi-person-badge text-teal me-2" style="color: #0d9488;"></i>Đội ngũ Bác sĩ &amp; Quản trị Lịch trực</c:when>
                  <c:when test="${employeeType == 'specialist'}"><i class="bi bi-clipboard2-pulse text-primary me-2"></i>Đội ngũ Kỹ thuật viên / Chuyên viên</c:when>
                  <c:otherwise><i class="bi bi-people text-warning me-2"></i>Đội ngũ Nhân viên tiếp đón &amp; thu ngân</c:otherwise>
                </c:choose>
              </c:otherwise>
            </c:choose>
          </h2>
          <p class="text-muted mb-0 small">
            <c:choose>
              <c:when test="${viewMode == 'schedule'}">
                Ma trận 14 ca trực trong tuần theo dõi chi tiết mật độ ca, lịch khám bệnh nhân và tình trạng phòng
              </c:when>
              <c:otherwise>
                Ban Giám đốc theo dõi tổng quan đội ngũ nhân sự, định mức ca trực và chọn cá nhân để xem lịch chi tiết
              </c:otherwise>
            </c:choose>
          </p>
        </div>
      </div>

      <c:choose>
        <%-- ==================================================================== --%>
        <%-- SCREEN 1: DANH SÁCH ĐỘI NGŨ NHÂN SỰ (FULL-WIDTH GRID CARDS)          --%>
        <%-- ==================================================================== --%>
        <c:when test="${viewMode != 'schedule'}">

          <!-- Directory Toolbar: Search & Filter Summary -->
          <div class="card border-0 shadow-sm rounded-4 p-3 mb-4 bg-white">
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
              <div class="d-flex align-items-center gap-2">
                <span class="fw-bold text-dark fs-5">
                  <i class="bi bi-people-fill text-teal me-1.5" style="color: #0d9488;"></i> 
                  <c:choose>
                    <c:when test="${employeeType == 'doctor'}">Đội ngũ Bác sĩ</c:when>
                    <c:when test="${employeeType == 'specialist'}">Đội ngũ KTV / Chuyên viên</c:when>
                    <c:otherwise>Đội ngũ Nhân viên</c:otherwise>
                  </c:choose>
                </span>
                <span class="badge rounded-pill fw-bold" style="font-size: 12.5px; background: #ccfbf1; color: #0f766e; border: 1px solid #99f6e4; padding: 6px 12px;">
                  <c:out value="${fn:length(employeeList)}" /> nhân sự
                </span>
              </div>

              <!-- Search Box (Spacious, placeholder fits completely) -->
              <div class="position-relative" style="min-width: 320px; max-width: 440px; width: 100%;">
                <i class="bi bi-search position-absolute text-muted" style="left: 14px; top: 50%; transform: translateY(-50%); font-size: 14px; z-index: 5;"></i>
                <input type="text" id="personnelSearchInput" class="form-control bg-light border"
                       style="padding-left: 38px; padding-right: 36px; border-radius: 10px; font-size: 13.5px; height: 42px;"
                       placeholder="Tìm kiếm theo họ tên, chuyên môn, phòng, SĐT, CCHN..." onkeyup="filterPersonnelGrid()">
                <button class="btn btn-link position-absolute text-muted p-0 border-0" type="button" 
                        style="right: 12px; top: 50%; transform: translateY(-50%); font-size: 16px; text-decoration: none;"
                        onclick="clearPersonnelSearch()" title="Xóa tìm kiếm">
                  <i class="bi bi-x-circle-fill"></i>
                </button>
              </div>
            </div>
          </div>

          <!-- Cards Grid (Spacious 3 columns on desktop, 2 on tablet, 1 on mobile) -->
          <div class="row g-4" id="personnelGridContainer">
            <c:choose>
              <c:when test="${not empty employeeList}">
                <c:forEach var="emp" items="${employeeList}">
                  <c:set var="stats" value="${employeeSlotStats[emp.actorId]}" />
                  <c:set var="empSlots" value="${not empty stats ? stats[0] : 0}" />
                  <c:set var="empBooked" value="${not empty stats ? stats[1] : 0}" />

                  <div class="col-md-6 col-xl-4 personnel-grid-col"
                       data-search="${not empty emp.fullName ? fn:toLowerCase(emp.fullName) : ''} ${not empty emp.specialty ? fn:toLowerCase(emp.specialty) : ''} ${not empty emp.phone ? emp.phone : ''} ${not empty emp.roomName ? fn:toLowerCase(emp.roomName) : ''} ${not empty emp.licenseNumber ? fn:toLowerCase(emp.licenseNumber) : ''}">
                    <div class="personnel-grid-card">
                      
                      <!-- Card Top Header: Avatar & Main Identifiers -->
                      <div class="d-flex align-items-start gap-3 mb-3">
                        <div class="emp-avatar-box ${employeeType}">
                          ${fn:substring(emp.fullName, 0, 1)}
                        </div>
                        <div class="flex-grow-1 overflow-hidden">
                          <div class="d-flex align-items-center justify-content-between mb-1">
                            <h5 class="fw-bold text-dark text-truncate mb-0" style="font-size: 16px;" title="${emp.fullName}">
                              ${emp.fullName}
                            </h5>
                            <span class="badge bg-light text-muted border font-monospace" style="font-size: 11px;">#${emp.actorId}</span>
                          </div>
                          <div class="text-teal small fw-semibold text-truncate mb-1" style="color: #0d9488;" title="${emp.specialty}">
                            <i class="bi bi-award me-1"></i>${emp.specialty}
                          </div>
                          <c:if test="${not empty emp.roomName && emp.roomName != 'Chưa xếp phòng'}">
                            <span class="badge bg-success bg-opacity-10 text-success border border-success-subtle px-2 py-0.5 small">
                              <i class="bi bi-door-open me-1"></i>${emp.roomName}
                            </span>
                          </c:if>
                        </div>
                      </div>

                      <!-- Contact & License Details -->
                      <div class="bg-light bg-opacity-50 rounded-3 p-2.5 mb-3 small">
                        <div class="row g-1 text-muted" style="font-size: 12px;">
                          <div class="col-12 text-truncate">
                            <i class="bi bi-telephone text-primary me-1.5"></i>
                            <span class="text-dark">${not empty emp.phone && emp.phone != 'Chưa có' ? emp.phone : 'Chưa cập nhật SĐT'}</span>
                          </div>
                          <c:if test="${not empty emp.licenseNumber}">
                            <div class="col-12 text-truncate mt-1">
                              <i class="bi bi-file-medical text-teal me-1.5" style="color: #0d9488;"></i>
                              <span>CCHN: <b class="text-dark">${emp.licenseNumber}</b></span>
                            </div>
                          </c:if>
                        </div>
                      </div>

                      <!-- Weekly Slot Statistics -->
                      <div class="d-flex align-items-center gap-2 mb-3">
                        <div class="emp-stat-pill">
                          <span class="text-muted d-block" style="font-size: 10.5px;">Ca trực tuần này</span>
                          <strong class="text-teal" style="font-size: 14px; color: #0d9488;">${empSlots} ca</strong>
                        </div>
                        <div class="emp-stat-pill">
                          <span class="text-muted d-block" style="font-size: 10.5px;">Đã có lịch hẹn</span>
                          <strong class="text-primary" style="font-size: 14px;">${empBooked} lịch</strong>
                        </div>
                        <div class="emp-stat-pill">
                          <span class="text-muted d-block" style="font-size: 10.5px;">Thời lượng</span>
                          <strong class="text-dark" style="font-size: 14px;">${empSlots * 0.5}h</strong>
                        </div>
                      </div>

                      <!-- Action Button -->
                      <div class="mt-auto pt-2 border-top">
                        <a href="${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?view=schedule&empId=${emp.actorId}&year=${selectedYear}&week=${selectedWeek}&session=${sessionFilter}"
                           class="btn w-100 fw-semibold rounded-3 py-2 d-flex align-items-center justify-content-center gap-2"
                           style="background: #0d9488; color: #ffffff; border: none; font-size: 13.5px; transition: all 0.2s;">
                          <i class="bi bi-calendar3"></i>
                          <span>Xem lịch chi tiết</span>
                          <i class="bi bi-arrow-right ms-auto"></i>
                        </a>
                      </div>

                    </div>
                  </div>
                </c:forEach>
              </c:when>
              <c:otherwise>
                <div class="col-12">
                  <div class="card border-0 shadow-sm rounded-4 p-5 text-center bg-white">
                    <i class="bi bi-person-x fs-1 text-muted d-block mb-3"></i>
                    <h5 class="fw-bold text-dark">Chưa có dữ liệu nhân sự</h5>
                    <p class="text-muted mb-0">Hệ thống chưa tìm thấy nhân sự nào thuộc danh mục này.</p>
                  </div>
                </div>
              </c:otherwise>
            </c:choose>
          </div>

        </c:when>

        <%-- ==================================================================== --%>
        <%-- SCREEN 2: MA TRẬN LỊCH TRỰC CHI TIẾT (FULL-WIDTH 14 SLOTS)           --%>
        <%-- ==================================================================== --%>
        <c:otherwise>

          <!-- Top Executive Banner: Back Button + Doctor Info + Quick Switcher + KPIs -->
          <div class="executive-card">
            <div class="d-flex flex-column flex-xxl-row justify-content-between align-items-xxl-center gap-3">
              
              <!-- Back to list & Current Doctor Info -->
              <div class="d-flex align-items-center gap-3">
                <a href="${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?view=list&year=${selectedYear}&week=${selectedWeek}&session=${sessionFilter}"
                   class="btn btn-outline-secondary d-flex align-items-center gap-2 fw-semibold px-3 py-2 rounded-3 shadow-sm"
                   title="Quay lại danh sách nhân sự">
                  <i class="bi bi-arrow-left fs-6"></i>
                  <span>Danh sách</span>
                </a>

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
                    <span><i class="bi bi-award-fill text-teal me-1" style="color: #0d9488;"></i><b>Chuyên môn:</b> ${selectedEmployee.specialty}</span>
                    <c:if test="${not empty selectedEmployee.licenseNumber}">
                      <span><i class="bi bi-file-medical text-primary me-1"></i><b>CCHN:</b> ${selectedEmployee.licenseNumber}</span>
                    </c:if>
                    <c:if test="${not empty selectedEmployee.phone}">
                      <span><i class="bi bi-telephone-fill text-muted me-1"></i>${selectedEmployee.phone}</span>
                    </c:if>
                  </div>
                </div>
              </div>

              <!-- Quick Switcher Dropdown & 4 Executive KPI Stat Cards -->
              <div class="d-flex align-items-center flex-wrap gap-3 justify-content-start justify-content-xxl-end">
                
                <!-- Quick Personnel Switcher -->
                <div class="d-flex align-items-center gap-2 bg-light p-1.5 rounded-3 border">
                  <span class="small text-muted ps-2 fw-semibold"><i class="bi bi-person-switch me-1"></i>Đổi:</span>
                  <select class="form-select form-select-sm border-0 fw-semibold bg-white shadow-sm" style="min-width: 200px; font-size: 13px;"
                          onchange="location.href='${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?view=schedule&empId=' + this.value + '&year=${selectedYear}&week=${selectedWeek}&session=${sessionFilter}'">
                    <c:forEach var="emp" items="${employeeList}">
                      <option value="${emp.actorId}" ${emp.actorId == selectedEmpId ? 'selected' : ''}>
                        ${emp.fullName} (#${emp.actorId})
                      </option>
                    </c:forEach>
                  </select>
                </div>

                <!-- 4 KPI Stat Boxes -->
                <div class="d-flex align-items-center flex-wrap gap-2">
                  <div class="kpi-mini-box">
                    <div class="kpi-mini-label">Tổng ca trực</div>
                    <div class="kpi-mini-value" style="color: #0d9488;">${totalWeeklySlots} ca</div>
                  </div>
                  <div class="kpi-mini-box">
                    <div class="kpi-mini-label">Thời lượng</div>
                    <div class="kpi-mini-value text-primary">${totalWeeklyHours} giờ</div>
                  </div>
                  <div class="kpi-mini-box">
                    <div class="kpi-mini-label">Có lịch hẹn</div>
                    <div class="kpi-mini-value" style="color: #2563eb;">${totalBookedSlots} lịch</div>
                  </div>
                  <div class="kpi-mini-box">
                    <div class="kpi-mini-label">Sẵn sàng</div>
                    <div class="kpi-mini-value text-success">${totalAvailableSlots} ca</div>
                  </div>
                </div>

              </div>
            </div>
          </div>

          <!-- Full Width Schedule Calendar Board -->
          <div class="schedule-full-card">

            <!-- Control Toolbar: Week / Year Navigator & Session Filters -->
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4 pb-3 border-bottom">
              
              <!-- Week & Year Selector (Spacious, full text displayed) -->
              <div class="d-flex align-items-center flex-wrap gap-2">
                <div class="btn-group btn-group-sm shadow-sm">
                  <a href="${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?view=schedule&empId=${selectedEmpId}&year=${prevYear}&week=${prevWeek}&session=${sessionFilter}"
                     class="btn btn-outline-secondary px-2.5 py-1.5" title="Tuần trước">
                    <i class="bi bi-chevron-left"></i>
                  </a>
                  <a href="${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?view=schedule&empId=${selectedEmpId}&year=${nextYear}&week=${nextWeek}&session=${sessionFilter}"
                     class="btn btn-outline-secondary px-2.5 py-1.5" title="Tuần sau">
                    <i class="bi bi-chevron-right"></i>
                  </a>
                </div>

                <!-- Week Dropdown (Min width 300px so full label is visible) -->
                <select class="form-select form-select-sm fw-semibold shadow-sm" style="min-width: 300px; height: 36px; font-size: 13px;"
                        onchange="location.href='${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?view=schedule&empId=${selectedEmpId}&year=${selectedYear}&week=' + this.value + '&session=${sessionFilter}'">
                  <c:forEach var="w" items="${weekOptions}">
                    <option value="${w.weekNumber}" ${w.weekNumber == selectedWeek ? 'selected' : ''}>
                      ${w.label}
                    </option>
                  </c:forEach>
                </select>

                <!-- Year Dropdown (Min width 130px so 'Năm 2026' is never cut off) -->
                <select class="form-select form-select-sm fw-bold shadow-sm" style="width: 130px; min-width: 130px; height: 36px; font-size: 13px;"
                        onchange="location.href='${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?view=schedule&empId=${selectedEmpId}&year=' + this.value + '&week=1&session=${sessionFilter}'">
                  <c:forEach var="y" items="${availableYears}">
                    <option value="${y}" ${y == selectedYear ? 'selected' : ''}>Năm ${y}</option>
                  </c:forEach>
                </select>

                <c:if test="${!isViewingCurrentWeek}">
                  <a href="${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?view=schedule&empId=${selectedEmpId}&year=${currentYear}&week=1&session=${sessionFilter}"
                     class="btn btn-outline-teal btn-sm rounded-pill px-3 py-1.5 shadow-sm small text-decoration-none fw-semibold"
                     style="border-color: #0d9488; color: #0d9488;">
                    <i class="bi bi-arrow-counterclockwise me-1"></i>Tuần hiện tại
                  </a>
                </c:if>
              </div>

              <!-- Session Shift Filters (All, Morning, Afternoon) -->
              <div class="btn-group btn-group-sm shadow-sm" role="group">
                <a href="${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?view=schedule&empId=${selectedEmpId}&year=${selectedYear}&week=${selectedWeek}&session=all"
                   class="btn ${sessionFilter == 'all' ? 'text-white' : 'btn-outline-secondary'}" style="${sessionFilter == 'all' ? 'background:#0d9488; border-color:#0d9488;' : ''}">
                  <i class="bi bi-grid-fill me-1"></i>Tất cả ca (14 ca)
                </a>
                <a href="${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?view=schedule&empId=${selectedEmpId}&year=${selectedYear}&week=${selectedWeek}&session=Morning"
                   class="btn ${sessionFilter == 'Morning' ? 'text-white' : 'btn-outline-secondary'}" style="${sessionFilter == 'Morning' ? 'background:#0d9488; border-color:#0d9488;' : ''}">
                  🌅 Ca Sáng
                </a>
                <a href="${pageContext.request.contextPath}/director/${employeeType == 'doctor' ? 'doctors' : (employeeType == 'specialist' ? 'specialists' : 'staffs')}?view=schedule&empId=${selectedEmpId}&year=${selectedYear}&week=${selectedWeek}&session=Afternoon"
                   class="btn ${sessionFilter == 'Afternoon' ? 'text-white' : 'btn-outline-secondary'}" style="${sessionFilter == 'Afternoon' ? 'background:#0d9488; border-color:#0d9488;' : ''}">
                  🌇 Ca Chiều
                </a>
              </div>
            </div>

            <!-- Main Horizontal Calendar Matrix (Min-width 1550px ensures zero overlapping text) -->
            <div class="table-responsive">
              <table class="director-schedule-table" style="${sessionFilter == 'all' ? 'min-width: 1550px;' : 'min-width: 950px;'}">
                <thead>
                  <tr>
                    <th style="min-width: 130px; width: 130px; text-align: left; padding-left: 16px;">
                      <div class="fw-bold text-uppercase" style="font-size: 11.5px; letter-spacing: 0.5px;">Thứ / Ngày</div>
                    </th>
                    <c:forEach var="slot" items="${slots}">
                      <c:if test="${sessionFilter == 'all' || slot.session == sessionFilter}">
                        <c:set var="rawSlotName" value="${not empty slot.displayName ? slot.displayName : slot.id}" />
                        <c:set var="cleanSlotName" value="${fn:contains(rawSlotName, ' (') ? fn:substringBefore(rawSlotName, ' (') : rawSlotName}" />
                        <c:set var="cleanSlotName" value="${fn:startsWith(cleanSlotName, 'Slot ') ? fn:replace(cleanSlotName, 'Slot ', 'Ca ') : cleanSlotName}" />
                        <th style="min-width: 95px; width: 95px; text-align: center;">
                          <div class="slot-header-box">
                            <span class="slot-header-title">${cleanSlotName}</span>
                            <span class="slot-header-time">${slot.timeRange}</span>
                          </div>
                        </th>
                      </c:if>
                    </c:forEach>
                    <th style="width: 90px; min-width: 90px; text-align: center;">
                      <div class="fw-bold text-uppercase" style="font-size: 11.5px; letter-spacing: 0.5px;">Tổng ca</div>
                    </th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="day" items="${weekDays}">
                    <tr class="${day.today ? 'day-row-today' : ''}">
                      <!-- Day Header Column -->
                      <td class="day-info-cell">
                        <div class="d-flex align-items-center flex-wrap gap-1">
                          <span class="fw-bold text-dark" style="font-size: 14px;">${day.dayName}</span>
                          <span class="badge bg-light text-muted border font-monospace" style="font-size: 11px;">${day.dateStr}</span>
                        </div>
                        <c:if test="${day.today}">
                          <span class="badge text-white rounded-pill mt-1" style="font-size: 9.5px; background: #0d9488;">
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

                          <td class="text-center p-1" style="height: 64px;">
                            <c:choose>
                              <c:when test="${not empty cell}">
                                <c:choose>
                                  <%-- 1. Booked (Có khách đặt hẹn) --%>
                                  <c:when test="${cell.booked}">
                                    <div class="chip-slot chip-booked"
                                         title="Nhấn để xem chi tiết cuộc hẹn: ${cell.patientName}"
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
                                      <span class="chip-title"><i class="bi bi-check2-circle text-teal me-0.5" style="color: #0d9488;"></i>Làm việc</span>
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
                            <span class="badge ${day.today ? 'text-white' : 'bg-light text-dark border'} rounded-pill px-2.5 py-1.5 fw-bold"
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
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-center gap-3 mt-4 pt-3 border-top small text-muted">
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
                <a href="${pageContext.request.contextPath}/director/leave-requests" class="text-teal text-decoration-none fw-semibold" style="color: #0d9488;">
                  <i class="bi bi-calendar-x me-1"></i>Duyệt yêu cầu nghỉ phép &rarr;
                </a>
              </div>
            </div>

          </div>

        </c:otherwise>
      </c:choose>

    </div>
  </div>

  <!-- ==================================================================== -->
  <!-- APPOINTMENT DETAIL MODAL (Pop up on click)                           -->
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
              <div class="avatar-badge d-flex align-items-center justify-content-center rounded-3" style="width: 48px; height: 48px; min-width: 48px; font-size: 20px; background: #eff6ff; color: #2563eb; border: 2px solid #bfdbfe;">
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
              <i class="bi bi-calendar-event text-teal me-1" style="color: #0d9488;"></i> Thông tin buổi khám
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
    // 1. Live Filter for Personnel Grid (Search input in List View)
    function filterPersonnelGrid() {
      const input = document.getElementById('personnelSearchInput');
      const filter = (input ? input.value : '').toLowerCase().trim();
      const cards = document.querySelectorAll('.personnel-grid-col');

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
        filterPersonnelGrid();
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
      document.getElementById('modalSlotTime').innerText = slotName + (timeRange ? ' (' + timeRange + ')' : '');
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
