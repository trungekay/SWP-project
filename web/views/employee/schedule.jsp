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

        <!-- Flash Messages (Sau khi dang ky hoac cap nhat lich) -->
        <c:if test="${not empty sessionScope.successMessage}">
          <div class="alert alert-success alert-dismissible fade show rounded-3 mb-3 shadow-sm" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i>
            <c:out value="${sessionScope.successMessage}" />
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
          </div>
          <c:remove var="successMessage" scope="session" />
        </c:if>

        <!-- Top Card: Profile & Stats (Dữ liệu Động từ DB) -->
        <div class="profile-header-card">
          <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">

            <!-- Left: User Info -->
            <div class="d-flex align-items-center gap-3">
              <div class="avatar-badge">
                <i class="bi bi-person-circle fs-2"></i>
              </div>
              <div>
                <div class="d-flex align-items-center flex-wrap gap-1">
                  <h5 class="mb-0 fw-bold text-dark">
                    <c:out value="${viewedActor.fullName != null ? viewedActor.fullName : 'Nhân sự'}" />
                  </h5>
                  <span class="badge-code">
                    Mã:
                    <c:choose>
                      <c:when test="${viewedActor.role == 'doctor'}">BS-0${viewedActor.actorId}</c:when>
                      <c:when test="${viewedActor.role == 'medical_specialist'}">KTV-0${viewedActor.actorId}</c:when>
                      <c:otherwise>NV-0${viewedActor.actorId}</c:otherwise>
                    </c:choose>
                  </span>
                  <span class="badge-room">
                    <i class="bi bi-door-open-fill text-success"></i>
                    <c:out value="${viewedActor.roomName != null ? viewedActor.roomName : 'Chưa xếp phòng'}" />
                  </span>
                </div>
                <c:if test="${not empty viewedActor.specialty}">
                  <div class="text-muted small mt-1">
                    <i class="bi bi-briefcase me-1"></i>Chuyên môn: <strong>
                      <c:out value="${viewedActor.specialty}" />
                    </strong>
                  </div>
                </c:if>
              </div>
            </div>

            <!-- Right: Stats & Register CTA -->
            <div class="d-flex align-items-center flex-wrap gap-2">
              <div>
                <div class="stat-label text-md-end">Tổng ca tuần này</div>
                <div class="stat-value text-md-end text-teal" style="color: var(--vc-primary);">${totalWeeklySlots} ca
                  làm việc</div>
              </div>
              <div class="stat-divider d-none d-sm-block"></div>
              <div>
                <div class="stat-label text-md-end">Giờ làm dự kiến</div>
                <div class="stat-value text-md-end">${totalWeeklyHours} giờ</div>
              </div>
              <div class="stat-divider d-none d-sm-block"></div>

              <!-- Nút Đăng Ký Lịch Làm Việc -->
              <a href="${pageContext.request.contextPath}/employee/register-schedule?year=${selectedYear}&week=${selectedWeek}"
                class="btn btn-primary btn-sm rounded-pill px-3 py-2 fw-semibold"
                style="background: var(--vc-primary); border-color: var(--vc-primary);">
                <i class="bi bi-calendar-plus me-1"></i> Đăng ký lịch
              </a>

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
                  Năm ${y}
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

          <!-- Ca Filter Buttons  -->
          <div class="d-flex align-items-center gap-2">
            <span class="small fw-bold text-muted me-1 d-none d-md-inline">Khung ca:</span>
            <a href="${pageContext.request.contextPath}/employee/schedule?year=${selectedYear}&week=${selectedWeek}&session=all"
              class="btn-session-filter ${sessionFilter == 'all' ? 'active' : ''}">Tất cả</a>
            <a href="${pageContext.request.contextPath}/employee/schedule?year=${selectedYear}&week=${selectedWeek}&session=Morning"
              class="btn-session-filter ${sessionFilter == 'Morning' ? 'active' : ''}">Ca Sáng (08:00 - 11:30)</a>
            <a href="${pageContext.request.contextPath}/employee/schedule?year=${selectedYear}&week=${selectedWeek}&session=Afternoon"
              class="btn-session-filter ${sessionFilter == 'Afternoon' ? 'active' : ''}">Ca Chiều (13:30 - 17:00)</a>
          </div>
        </div>

        <!-- Schedule Matrix Card  -->
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

                    <!-- Các Cột Chiều Ngang: Các Slot 30 phút (Render theo Dữ liệu Thật Database) -->
                    <c:forEach var="slot" items="${slots}">
                      <c:if test="${sessionFilter == 'all' || slot.session == sessionFilter}">
                        <td class="text-center">

                          <!-- Lấy cell tương ứng từ Map DB theo key: "yyyy-MM-dd_SlotId" -->
                          <c:set var="cellKey" value="${day.fullDate}_${slot.id}" />
                          <c:set var="cell" value="${scheduleMatrix[cellKey]}" />
                          <c:set var="isSlotGloballyClosed"
                            value="${slotStatusMap[slot.id] == 'Canceled' || slotStatusMap[slot.id] == 'Inactive' || slotStatusMap[slot.id] == 'Disabled'}" />

                          <c:choose>

                            <%-- 1. Ca tạm dừng / Đóng bởi Admin (Toàn viện hoặc ca cụ thể) -> Sky Blue --%>
                              <c:when test="${isSlotGloballyClosed || (cell != null && cell.closed)}">
                                <div class="slot-btn slot-closed"
                                  title="Khung giờ khám này đã bị đóng bởi Quản trị viên">
                                  <span class="slot-title"><i class="bi bi-slash-circle me-1"></i>Đóng ca</span>

                                </div>
                              </c:when>

                              <%-- 2. Ca có khách khám (Booked) --%>
                                <c:when test="${cell != null && cell.booked}">
                                  <div class="slot-btn slot-booked"
                                    title="Có khách khám: ${cell.patientName} (${cell.patientPhone})">
                                    <span class="slot-title"><i class="bi bi-person-fill me-1"></i>
                                      <c:out value="${cell.patientName}" />
                                    </span>
                                    <span class="slot-sub">
                                      <c:out value="${cell.roomName}" /> &bull;
                                      <c:out
                                        value="${cell.startTime.length() >= 5 ? cell.startTime.substring(0, 5) : cell.startTime}" />
                                    </span>
                                  </div>
                                </c:when>

                                <%-- 3. Ca làm việc trống (Available) --%>
                                  <c:when test="${cell != null && cell.available}">
                                    <div class="slot-btn slot-available" title="Ca làm việc sẵn sàng tiếp nhận">
                                      <span class="slot-title"><i class="bi bi-check2-circle me-1"></i>Làm việc</span>
                                      <span class="slot-sub">
                                        <c:out value="${cell.roomName}" />
                                      </span>
                                    </div>
                                  </c:when>

                                  <%-- 4. Ca xin nghỉ đã duyệt (On Leave) --%>
                                    <c:when test="${cell != null && cell.onLeave}">
                                      <div class="slot-btn slot-onleave" title="Ca nghỉ phép đã duyệt">
                                        <span class="slot-title"><i class="bi bi-x-circle me-1"></i>Nghỉ phép</span>
                                        <span class="slot-sub">Đã duyệt</span>
                                      </div>
                                    </c:when>

                                    <%-- 5. Ca trống không có lịch / Nghỉ mặc định --%>
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

                    <!-- Cột TỔNG CA (Đếm động theo số ca thật trong ngày từ DB) -->
                    <td class="total-cell">
                      <c:choose>
                        <c:when test="${day.totalSlotsCount > 0}">
                          <span class="total-badge ${day.today ? 'total-badge-today' : ''}">${day.totalSlotsCount}
                            ca</span>
                        </c:when>
                        <c:otherwise>
                          <span class="text-muted small">0 ca</span>
                        </c:otherwise>
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
                <div class="legend-box" style="background: #e0f2fe; border: 1px solid #7dd3fc;"></div>
                <span><strong>Đóng ca</strong> (Tạm dừng khung giờ)</span>
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