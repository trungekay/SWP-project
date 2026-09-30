<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Lịch làm việc của tôi" />
  <jsp:param name="pageDescription" value="Xem và quản lý lịch làm việc của Bác sĩ, Chuyên viên và Nhân viên" />
  <jsp:param name="bodyClass" value="starter-page-page" />
  <jsp:param name="activeNav" value="schedule" />
</jsp:include>

<style>
  :root {
    --vc-primary: #0d9488;
    --vc-primary-dark: #0f766e;
    --vc-primary-light: #ccfbf1;
    --vc-primary-subtle: #f0fdfa;
    --vc-booked: #2563eb;
    --vc-booked-bg: #eff6ff;
    --vc-gray-bg: #f8fafc;
    --vc-border: #e2e8f0;
  }

  body {
    background-color: #f1f5f9;
  }

  .schedule-container {
    max-width: 1380px;
    margin: 0 auto;
    padding: 24px 16px;
  }

  /* Profile Card Top */
  .profile-header-card {
    background: #ffffff;
    border-radius: 16px;
    padding: 20px 24px;
    border: 1px solid var(--vc-border);
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04);
    margin-bottom: 24px;
  }

  .avatar-badge {
    width: 54px;
    height: 54px;
    border-radius: 50%;
    background: #e6fffa;
    color: var(--vc-primary);
    font-weight: 700;
    font-size: 20px;
    display: flex;
    align-items: center;
    justify-content: center;
    border: 2px solid #99f6e4;
  }

  .badge-code {
    background: #e0f2fe;
    color: #0369a1;
    font-size: 12px;
    font-weight: 600;
    padding: 3px 8px;
    border-radius: 6px;
    margin-left: 8px;
  }

  .stat-divider {
    border-left: 1px solid #e2e8f0;
    height: 40px;
    margin: 0 20px;
  }

  .stat-label {
    font-size: 12px;
    color: #64748b;
    margin-bottom: 2px;
  }

  .stat-value {
    font-size: 16px;
    font-weight: 700;
    color: #0f172a;
  }

  /* Toolbar */
  .schedule-toolbar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 12px;
    margin-bottom: 16px;
  }

  .btn-nav-week {
    background: #ffffff;
    border: 1px solid var(--vc-border);
    color: #334155;
    font-weight: 500;
    padding: 6px 14px;
    border-radius: 8px;
    transition: all 0.2s;
    text-decoration: none;
  }

  .btn-nav-week:hover {
    background: #f8fafc;
    border-color: #cbd5e1;
    color: #0f172a;
  }

  .btn-session-filter {
    padding: 6px 16px;
    border-radius: 8px;
    font-size: 13px;
    font-weight: 600;
    border: 1px solid var(--vc-border);
    background: #fff;
    color: #64748b;
    text-decoration: none;
    transition: all 0.2s;
  }

  .btn-session-filter.active {
    background: var(--vc-primary);
    color: #fff;
    border-color: var(--vc-primary);
  }

  /* Schedule Table Grid */
  .schedule-card {
    background: #ffffff;
    border-radius: 16px;
    border: 1px solid var(--vc-border);
    box-shadow: 0 4px 24px rgba(0, 0, 0, 0.04);
    overflow: hidden;
  }

  .table-schedule {
    margin-bottom: 0;
    border-collapse: separate;
    border-spacing: 0;
    width: 100%;
  }

  .table-schedule thead th {
    background: #f8fafc;
    color: #475569;
    font-size: 13px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    padding: 14px 10px;
    text-align: center;
    border-bottom: 2px solid var(--vc-border);
    border-right: 1px solid var(--vc-border);
    white-space: nowrap;
  }

  .table-schedule thead th:last-child {
    border-right: none;
  }

  .table-schedule thead th .time-sub {
    font-size: 11px;
    color: #94a3b8;
    font-weight: 500;
    display: block;
    margin-top: 2px;
    text-transform: none;
  }

  .table-schedule tbody td {
    padding: 12px 8px;
    vertical-align: middle;
    border-bottom: 1px solid #f1f5f9;
    border-right: 1px solid #f1f5f9;
    background: #ffffff;
    transition: background 0.15s;
  }

  .table-schedule tbody td:last-child {
    border-right: none;
  }

  .table-schedule tbody tr:hover td {
    background-color: #fafbfc;
  }

  /* Row Day Info Column (Chiều dọc) */
  .day-cell {
    background: #ffffff !important;
    font-weight: 600;
    color: #1e293b;
    min-width: 130px;
    padding-left: 16px !important;
  }

  .day-name {
    font-size: 14px;
    color: #0f172a;
    font-weight: 700;
  }

  .day-date {
    font-size: 12px;
    color: #64748b;
    display: inline-block;
    padding: 2px 8px;
    background: #f1f5f9;
    border-radius: 6px;
    margin-left: 6px;
    font-weight: 500;
  }

  /* Highlight Today */
  .row-today td {
    background-color: #f0fdfa !important;
  }

  .row-today .day-cell .day-name {
    color: var(--vc-primary-dark);
  }

  .today-badge {
    background: var(--vc-primary);
    color: #ffffff;
    font-size: 11px;
    font-weight: 700;
    padding: 3px 8px;
    border-radius: 6px;
    display: inline-block;
    margin-top: 4px;
  }

  /* Slot States */
  .slot-btn {
    width: 100%;
    padding: 8px 6px;
    border-radius: 8px;
    font-size: 12px;
    font-weight: 600;
    text-align: center;
    border: none;
    transition: all 0.2s ease;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 2px;
    min-height: 44px;
    text-decoration: none;
  }

  /* State 1: Làm việc (Available) */
  .slot-available {
    background: #0d9488;
    color: #ffffff;
    border: 1px solid #0f766e;
    box-shadow: 0 2px 6px rgba(13, 148, 136, 0.2);
  }

  .slot-available:hover {
    background: #0f766e;
    color: #ffffff;
    transform: translateY(-1px);
  }

  /* State 2: Có khách đến khám (Booked) */
  .slot-booked {
    background: #2563eb;
    color: #ffffff;
    border: 1px solid #1d4ed8;
    box-shadow: 0 2px 6px rgba(37, 99, 235, 0.2);
  }

  .slot-booked:hover {
    background: #1d4ed8;
    color: #ffffff;
    transform: translateY(-1px);
  }

  /* State 3: Nghỉ / Không có ca */
  .slot-off {
    background: #ffffff;
    color: #94a3b8;
    border: 1px dashed #cbd5e1;
    font-weight: 500;
    cursor: default;
  }

  /* State 4: Ca đang nghỉ phép đã duyệt */
  .slot-onleave {
    background: #fee2e2;
    color: #b91c1c;
    border: 1px solid #fca5a5;
    font-weight: 600;
  }

  .total-cell {
    text-align: center;
    font-weight: 700;
    color: var(--vc-primary-dark);
    font-size: 13px;
    min-width: 90px;
  }

  .total-badge {
    background: #ccfbf1;
    color: #0f766e;
    padding: 6px 12px;
    border-radius: 20px;
    display: inline-block;
    border: 1px solid #99f6e4;
  }

  .total-badge-today {
    background: var(--vc-primary);
    color: #ffffff;
    border-color: var(--vc-primary-dark);
  }

  /* Footer Legend */
  .schedule-legend {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 20px;
    padding: 16px 24px;
    background: #f8fafc;
    border-top: 1px solid var(--vc-border);
    font-size: 13px;
    color: #475569;
  }

  .legend-item {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .legend-box {
    width: 16px;
    height: 16px;
    border-radius: 4px;
  }
</style>

<main class="main">
  <div class="schedule-container">

    <!-- Top Card: Profile & Stats -->
    <div class="profile-header-card">
      <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
        
        <!-- Left: User Info -->
        <div class="d-flex align-items-center gap-3">
          <div class="avatar-badge">
            <i class="bi bi-person-circle fs-2"></i>
          </div>
          <div>
            <div class="d-flex align-items-center flex-wrap">
              <h5 class="mb-0 fw-bold text-dark"><c:out value="${currentUser.fullName != null ? currentUser.fullName : 'Bác sĩ'}" /></h5>
              <span class="badge-code">Mã: BS-0<c:out value="${currentUser.id}" /></span>
            </div>
            <div class="text-muted small mt-1">
              <i class="bi bi-geo-alt-fill text-danger me-1"></i>Khoa Khúc xạ &amp; Nhãn khoa &bull; Buồng khám chính: <strong>P.101 (Tầng 1)</strong>
            </div>
          </div>
        </div>

        <!-- Right: Stats & Switcher -->
        <div class="d-flex align-items-center flex-wrap gap-2">
          <div>
            <div class="stat-label text-md-end">Tổng ca tuần này</div>
            <div class="stat-value text-md-end text-teal" style="color: var(--vc-primary);">7 ca làm việc</div>
          </div>
          <div class="stat-divider d-none d-sm-block"></div>
          <div>
            <div class="stat-label text-md-end">Giờ làm dự kiến</div>
            <div class="stat-value text-md-end">14 giờ</div>
          </div>
          <div class="stat-divider d-none d-sm-block"></div>
          
          <!-- Dropdown Switcher (cho Doctor / Staff / Specialist) -->
          <div class="dropdown">
            <button class="btn btn-outline-secondary dropdown-toggle btn-sm rounded-pill px-3 py-2 fw-semibold" type="button" data-bs-toggle="dropdown">
              <c:out value="${currentUser.fullName != null ? currentUser.fullName : 'Tài khoản'}" /> (Tôi)
            </button>
            <ul class="dropdown-menu dropdown-menu-end shadow-sm">
              <li><h6 class="dropdown-header">Chuyển đối tượng xem</h6></li>
              <li><a class="dropdown-item active" href="#"><c:out value="${currentUser.fullName}" /> (Tôi)</a></li>
              <c:if test="${currentUser.role == 'staff' || currentUser.role == 'admin'}">
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item" href="#">BS. Trần Văn Nam (P.101)</a></li>
                <li><a class="dropdown-item" href="#">TS.BS. Nguyễn Xuân Tịnh (P.102)</a></li>
                <li><a class="dropdown-item" href="#">KTV. Lê Thị Hoa (OCT)</a></li>
              </c:if>
            </ul>
          </div>

        </div>

      </div>
    </div>

    <!-- Toolbar: Date range & Filters -->
    <div class="schedule-toolbar">
      <div class="d-flex align-items-center gap-2">
        <div class="btn-group shadow-sm">
          <a href="${pageContext.request.contextPath}/employee/schedule?weekOffset=${weekOffset - 1}&session=${sessionFilter}" class="btn-nav-week">
            <i class="bi bi-chevron-left"></i> Tuần trước
          </a>
          <a href="${pageContext.request.contextPath}/employee/schedule?weekOffset=0&session=${sessionFilter}" class="btn-nav-week ${weekOffset == 0 ? 'fw-bold text-teal' : ''}">
            Tuần này
          </a>
          <a href="${pageContext.request.contextPath}/employee/schedule?weekOffset=${weekOffset + 1}&session=${sessionFilter}" class="btn-nav-week">
            Tuần sau <i class="bi bi-chevron-right"></i>
          </a>
        </div>
      </div>

      <!-- Ca Filter Buttons -->
      <div class="d-flex align-items-center gap-2">
        <span class="small fw-bold text-muted me-1">Khung ca:</span>
        <a href="${pageContext.request.contextPath}/employee/schedule?weekOffset=${weekOffset}&session=all" 
           class="btn-session-filter ${sessionFilter == 'all' ? 'active' : ''}">Tất cả (30p)</a>
        <a href="${pageContext.request.contextPath}/employee/schedule?weekOffset=${weekOffset}&session=Morning" 
           class="btn-session-filter ${sessionFilter == 'Morning' ? 'active' : ''}">Ca Sáng (08:00 - 11:30)</a>
        <a href="${pageContext.request.contextPath}/employee/schedule?weekOffset=${weekOffset}&session=Afternoon" 
           class="btn-session-filter ${sessionFilter == 'Afternoon' ? 'active' : ''}">Ca Chiều (13:30 - 17:00)</a>
      </div>
    </div>

    <!-- Schedule Matrix Card (Chiều dọc: Ngày trong tuần | Chiều ngang: Các ca 30p) -->
    <div class="schedule-card">
      <div class="table-responsive">
        <table class="table table-schedule">
          <thead>
            <tr>
              <th style="min-width: 140px; text-align: left; padding-left: 16px;">NGÀY</th>
              
              <!-- Render Header các Slot 30 phút theo Filter -->
              <c:forEach var="slot" items="${slots}">
                <c:if test="${sessionFilter == 'all' || slot.session == sessionFilter}">
                  <th>
                    <c:out value="${slot.id}" />
                    <span class="time-sub"><c:out value="${slot.timeRange}" /></span>
                  </th>
                </c:if>
              </c:forEach>

              <th style="min-width: 100px;">TỔNG CA</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="day" items="${weekDays}" varStatus="loop">
              <tr class="${day.today ? 'row-today' : ''}">
                
                <!-- Cột Chiều Dọc: Ngày trong tuần -->
                <td class="day-cell">
                  <div class="d-flex align-items-center flex-wrap">
                    <span class="day-name"><c:out value="${day.dayName}" /></span>
                    <span class="day-date"><c:out value="${day.dateStr}" /></span>
                  </div>
                  <c:if test="${day.today}">
                    <span class="today-badge"><i class="bi bi-clock-history me-1"></i>Hôm nay</span>
                  </c:if>
                </td>

                <!-- Các Cột Chiều Ngang: Các Slot 30 phút -->
                <c:forEach var="slot" items="${slots}">
                  <c:if test="${sessionFilter == 'all' || slot.session == sessionFilter}">
                    <td class="text-center" style="min-width: 110px;">
                      
                      <!-- Demo Data Logic: Minh họa các trạng thái nghiệp vụ chuẩn -->
                      <c:choose>
                        
                        <%-- 1. Ca có khách khám (Booked) --%>
                        <c:when test="${(loop.index == 0 && slot.id == 'Slot 2') || (loop.index == 2 && slot.id == 'Slot 3')}">
                          <div class="slot-btn slot-booked" title="Có khách khám">
                            <span><i class="bi bi-person-check-fill me-1"></i>Nguyễn Văn A</span>
                            <small style="font-size: 10px; opacity: 0.9;">P.101 &bull; 08:30</small>
                          </div>
                        </c:when>

                        <%-- 2. Ca làm việc trống (Available) --%>
                        <c:when test="${(loop.index == 0 && (slot.id == 'Slot 1' || slot.id == 'Slot 3')) 
                                     || (loop.index == 1 && (slot.id == 'Slot 8' || slot.id == 'Slot 9'))
                                     || (day.today && (slot.id == 'Slot 1' || slot.id == 'Slot 2'))
                                     || (loop.index == 3 && slot.id == 'Slot 1')
                                     || (loop.index == 4 && slot.id == 'Slot 8')
                                     || (loop.index == 5 && slot.id == 'Slot 1')}">
                          <div class="slot-btn slot-available" title="Ca làm việc sẵn sàng tiếp nhận">
                            <span><i class="bi bi-check2-circle me-1"></i>Làm việc</span>
                            <small style="font-size: 10px; opacity: 0.9;">P.101</small>
                          </div>
                        </c:when>

                        <%-- 3. Ca xin nghỉ đã duyệt (On Leave) --%>
                        <c:when test="${loop.index == 4 && slot.id == 'Slot 2'}">
                          <div class="slot-btn slot-onleave" title="Ca nghỉ phép đã duyệt">
                            <span><i class="bi bi-x-circle me-1"></i>Nghỉ phép</span>
                          </div>
                        </c:when>

                        <%-- 4. Ca trống không đi làm / Nghỉ mặc định --%>
                        <c:otherwise>
                          <div class="slot-btn slot-off">
                            <span>Nghỉ</span>
                          </div>
                        </c:otherwise>

                      </c:choose>

                    </td>
                  </c:if>
                </c:forEach>

                <!-- Cột TỔNG CA -->
                <td class="total-cell">
                  <c:choose>
                    <c:when test="${loop.index == 0}"><span class="total-badge">3 ca</span></c:when>
                    <c:when test="${loop.index == 1}"><span class="total-badge">2 ca</span></c:when>
                    <c:when test="${loop.index == 2}"><span class="total-badge ${day.today ? 'total-badge-today' : ''}">3 ca (Trực)</span></c:when>
                    <c:when test="${loop.index == 3}"><span class="total-badge">1 ca</span></c:when>
                    <c:when test="${loop.index == 4}"><span class="total-badge">2 ca</span></c:when>
                    <c:when test="${loop.index == 5}"><span class="total-badge">1 ca</span></c:when>
                    <c:otherwise><span class="text-muted small">0 ca</span></c:otherwise>
                  </c:choose>
                </td>

              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>

      <!-- Footer Chú Thích Legend -->
      <div class="schedule-legend d-flex justify-content-between flex-wrap">
        <div class="d-flex align-items-center flex-wrap gap-3">
          <div class="legend-item">
            <div class="legend-box" style="background: #0d9488;"></div>
            <span><strong>Làm việc</strong> (Sẵn sàng tiếp nhận / Đã phân phòng)</span>
          </div>
          <div class="legend-item">
            <div class="legend-box" style="background: #2563eb;"></div>
            <span><strong>Có khách khám</strong> (Bệnh nhân đã đặt lịch)</span>
          </div>
          <div class="legend-item">
            <div class="legend-box" style="background: #fee2e2; border: 1px solid #fca5a5;"></div>
            <span><strong>Nghỉ phép</strong> (Đã duyệt nghỉ)</span>
          </div>
          <div class="legend-item">
            <div class="legend-box" style="background: #fff; border: 1px dashed #cbd5e1;"></div>
            <span><strong>Nghỉ</strong> (Không có lịch trực)</span>
          </div>
        </div>

        <div class="text-muted small">
          <i class="bi bi-arrow-repeat me-1"></i>Dữ liệu đồng bộ: <strong><c:out value="${todayStr}" /></strong>
        </div>
      </div>

    </div>

  </div>
</main>

<jsp:include page="/views/common/footer.jsp" />
