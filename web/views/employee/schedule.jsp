<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

    <jsp:include page="/views/common/header.jsp">
      <jsp:param name="pageTitle" value="Lịch làm việc của tôi" />
      <jsp:param name="pageDescription" value="Xem và quản lý lịch làm việc của Bác sĩ, Chuyên viên và Nhân viên" />
      <jsp:param name="bodyClass" value="starter-page-page" />
      <jsp:param name="activeNav" value="schedule" />
    </jsp:include>


    <link href="${pageContext.request.contextPath}/assets/css/schedule.css" rel="stylesheet">

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
                  <h5 class="mb-0 fw-bold text-dark">
                    <c:out value="${currentUser.fullName != null ? currentUser.fullName : 'Bác sĩ'}" />
                  </h5>
                  <span class="badge-code">Mã: BS-0
                    <c:out value="${currentUser.id}" />
                  </span>
                </div>
                <div class="text-muted small mt-1">
                  <i class="bi bi-geo-alt-fill text-danger me-1"></i>Khoa Khúc xạ &amp; Nhãn khoa &bull; Buồng khám
                  chính: <strong>P.101 (Tầng 1)</strong>
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
                <button class="btn btn-outline-secondary dropdown-toggle btn-sm rounded-pill px-3 py-2 fw-semibold"
                  type="button" data-bs-toggle="dropdown">
                  <c:out value="${currentUser.fullName != null ? currentUser.fullName : 'Tài khoản'}" /> (Tôi)
                </button>
                <ul class="dropdown-menu dropdown-menu-end shadow-sm">
                  <li>
                    <h6 class="dropdown-header">Chuyển đối tượng xem</h6>
                  </li>
                  <li><a class="dropdown-item active" href="#">
                      <c:out value="${currentUser.fullName}" /> (Tôi)
                    </a></li>
                  <c:if test="${currentUser.role == 'staff' || currentUser.role == 'admin'}">
                    <li>
                      <hr class="dropdown-divider">
                    </li>
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

          <!-- Cụm chọn Năm & Tuần Trong Năm -->
          <div class="week-selector-group">
            <span class="small fw-bold text-muted d-none d-sm-inline"><i class="bi bi-calendar3 me-1"></i>Thời
              gian:</span>

            <!-- 1. Dropdown Chọn Năm (Tối đa đến năm hiện tại + 1) -->
            <select class="select-year-dropdown" title="Chọn năm"
              onchange="window.location.href='${pageContext.request.contextPath}/employee/schedule?year=' + this.value + '&week=1&session=${sessionFilter}'">
              <c:forEach var="y" items="${availableYears}">
                <option value="${y}" ${y==selectedYear ? 'selected' : '' }>
                  ${y}
                </option>
              </c:forEach>
            </select>

            <!-- 2. Nút mũi tên tuần trước -->
            <a href="${pageContext.request.contextPath}/employee/schedule?year=${prevYear}&week=${prevWeek}&session=${sessionFilter}"
              class="btn-nav-arrow" title="Tuần trước">
              <i class="bi bi-chevron-left"></i>
            </a>

            <!-- 3. Dropdown Chọn Tất Cả Các Tuần Trong Năm (Tuần 01 -> Tuần 52/53) -->
            <select class="select-week-dropdown" title="Chọn tuần cụ thể trong năm"
              onchange="window.location.href='${pageContext.request.contextPath}/employee/schedule?year=${selectedYear}&week=' + this.value + '&session=${sessionFilter}'">
              <c:forEach var="w" items="${weekOptions}">
                <option value="${w.weekNumber}" ${w.weekNumber==selectedWeek ? 'selected' : '' }>
                  ${w.label}
                </option>
              </c:forEach>
            </select>

            <!-- 4. Nút mũi tên tuần sau -->
            <a href="${pageContext.request.contextPath}/employee/schedule?year=${nextYear}&week=${nextWeek}&session=${sessionFilter}"
              class="btn-nav-arrow" title="Tuần sau">
              <i class="bi bi-chevron-right"></i>
            </a>

            <!-- 5. Nút về tuần hiện tại nếu đang xem tuần khác -->
            <c:if test="${!isViewingCurrentWeek}">
              <a href="${pageContext.request.contextPath}/employee/schedule?year=${currentYear}&week=${currentWeekOfThisYear}&session=${sessionFilter}"
                class="btn btn-outline-primary btn-sm rounded-pill ms-1 px-2 py-1" style="font-size: 11.5px;">
                Về tuần hiện tại
              </a>
            </c:if>
          </div>

          <!-- Ca Filter Buttons (Sáng / Chiều / Tất cả) -->
          <div class="d-flex align-items-center gap-2">
            <span class="small fw-bold text-muted me-1 d-none d-md-inline">Khung ca:</span>
            <a href="${pageContext.request.contextPath}/employee/schedule?year=${selectedYear}&week=${selectedWeek}&session=all"
              class="btn-session-filter ${sessionFilter == 'all' ? 'active' : ''}">Tất cả (30p)</a>
            <a href="${pageContext.request.contextPath}/employee/schedule?year=${selectedYear}&week=${selectedWeek}&session=Morning"
              class="btn-session-filter ${sessionFilter == 'Morning' ? 'active' : ''}">Ca Sáng (08:00 - 11:30)</a>
            <a href="${pageContext.request.contextPath}/employee/schedule?year=${selectedYear}&week=${selectedWeek}&session=Afternoon"
              class="btn-session-filter ${sessionFilter == 'Afternoon' ? 'active' : ''}">Ca Chiều (13:30 - 17:00)</a>
          </div>
        </div>

        <!-- Schedule Matrix Card (Fixed Grid Layout - Cột dọc Ngày, Cột ngang Slot 30p đều 100%) -->
        <div class="schedule-card">
          <div class="table-responsive">
            <table class="table table-schedule">
              <thead>
                <tr>
                  <th class="col-day-header">NGÀY</th>

                  <!-- Render Header các Slot 30 phút theo Filter -->
                  <c:forEach var="slot" items="${slots}">
                    <c:if test="${sessionFilter == 'all' || slot.session == sessionFilter}">
                      <th class="col-slot-header">
                        <c:out value="${slot.id}" />
                        <span class="time-sub">
                          <c:out value="${slot.timeRange}" />
                        </span>
                      </th>
                    </c:if>
                  </c:forEach>

                  <th class="col-total-header">TỔNG CA</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="day" items="${weekDays}" varStatus="loop">
                  <tr class="${day.today ? 'row-today' : ''}">

                    <!-- Cột Chiều Dọc: Ngày trong tuần -->
                    <td class="day-cell">
                      <div class="d-flex align-items-center flex-wrap">
                        <span class="day-name">
                          <c:out value="${day.dayName}" />
                        </span>
                        <span class="day-date">
                          <c:out value="${day.dateStr}" />
                        </span>
                      </div>
                      <c:if test="${day.today}">
                        <span class="today-badge"><i class="bi bi-clock-history me-1"></i>Hôm nay</span>
                      </c:if>
                    </td>

                    <!-- Các Cột Chiều Ngang: Các Slot 30 phút (Chiều cao & kích thước đồng đều 100%) -->
                    <c:forEach var="slot" items="${slots}">
                      <c:if test="${sessionFilter == 'all' || slot.session == sessionFilter}">
                        <td class="text-center">

                          <!-- Demo Data Logic: Minh họa các trạng thái nghiệp vụ chuẩn -->
                          <c:choose>

                            <%-- 1. Ca có khách khám (Booked) --%>
                              <c:when
                                test="${(loop.index == 0 && slot.id == 'Slot 2') || (loop.index == 2 && slot.id == 'Slot 3')}">
                                <div class="slot-btn slot-booked" title="Có khách khám: Nguyễn Văn A">
                                  <span class="slot-title"><i class="bi bi-person-fill me-1"></i>Nguyễn Văn A</span>
                                  <span class="slot-sub">P.101 &bull; 08:30</span>
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
                                    <span class="slot-title"><i class="bi bi-check2-circle me-1"></i>Làm việc</span>
                                    <span class="slot-sub">P.101</span>
                                  </div>
                                </c:when>

                                <%-- 3. Ca xin nghỉ đã duyệt (On Leave) --%>
                                  <c:when test="${loop.index == 4 && slot.id == 'Slot 2'}">
                                    <div class="slot-btn slot-onleave" title="Ca nghỉ phép đã duyệt">
                                      <span class="slot-title"><i class="bi bi-x-circle me-1"></i>Nghỉ phép</span>
                                      <span class="slot-sub">Đã duyệt</span>
                                    </div>
                                  </c:when>

                                  <%-- 4. Ca trống không đi làm / Nghỉ mặc định --%>
                                    <c:otherwise>
                                      <div class="slot-btn slot-off" title="Không có lịch trực">
                                        <span class="slot-title">Nghỉ</span>
                                        <span class="slot-sub">-</span>
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
                        <c:when test="${loop.index == 2}"><span
                            class="total-badge ${day.today ? 'total-badge-today' : ''}">3 ca</span></c:when>
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
              <i class="bi bi-arrow-repeat me-1"></i>Dữ liệu đồng bộ: <strong>
                <c:out value="${todayStr}" />
              </strong>
            </div>
          </div>

        </div>

      </div>
    </main>

    <jsp:include page="/views/common/footer.jsp" />