<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Đăng ký lịch làm việc" />
  <jsp:param name="pageDescription" value="Đăng ký ca làm việc hàng tuần cho Bác sĩ, Chuyên viên và Nhân viên" />
  <jsp:param name="bodyClass" value="starter-page-page" />
  <jsp:param name="activeNav" value="register-schedule" />
</jsp:include>

<link href="${pageContext.request.contextPath}/assets/css/register-schedule.css" rel="stylesheet">

<main class="main">
  <div class="register-container">

    <!-- Flash Messages (Neu co) -->
    <c:if test="${not empty sessionScope.errorMessage}">
      <div class="alert alert-danger alert-dismissible fade show rounded-3 mb-3 shadow-sm" role="alert">
        <i class="bi bi-exclamation-triangle-fill me-2"></i>
        <c:out value="${sessionScope.errorMessage}" />
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
      </div>
      <c:remove var="errorMessage" scope="session" />
    </c:if>

    <!-- Top Card: Profile & Context -->
    <div class="register-header-card">
      <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
        
        <!-- Left: User Info -->
        <div class="d-flex align-items-center gap-3">
          <div class="avatar-badge">
            <i class="bi bi-calendar-plus-fill fs-3"></i>
          </div>
          <div>
            <div class="d-flex align-items-center flex-wrap">
              <h5 class="mb-0 fw-bold text-dark">
                Đăng ký lịch: <c:out value="${actorProfile.fullName != null ? actorProfile.fullName : 'Nhân sự'}" />
              </h5>
              <span class="badge-code">
                <c:choose>
                  <c:when test="${actorProfile.role == 'doctor'}">Bác sĩ</c:when>
                  <c:when test="${actorProfile.role == 'medical_specialist'}">Chuyên viên khúc xạ</c:when>
                  <c:otherwise>Nhân viên</c:otherwise>
                </c:choose>
              </span>
            </div>
            <div class="text-muted small mt-1">
              <i class="bi bi-info-circle me-1"></i>Tích chọn các khung giờ 30 phút bạn có thể làm việc trong tuần này.
            </div>
          </div>
        </div>

        <!-- Right: Stats -->
        <div class="d-flex align-items-center flex-wrap gap-2">
          <div>
            <div class="stat-label text-md-end">Đã có sẵn</div>
            <div class="stat-value text-md-end text-teal" style="color: var(--vc-primary);">${registeredCount} ca</div>
          </div>
          <div class="stat-divider d-none d-sm-block"></div>
          <div>
            <div class="stat-label text-md-end">Đang chọn thêm</div>
            <div class="stat-value text-md-end text-primary" id="headerSelectedCount">0 ca</div>
          </div>
          <div class="stat-divider d-none d-sm-block"></div>
          <div>
            <div class="stat-label text-md-end">Tổng giờ dự kiến</div>
            <div class="stat-value text-md-end" id="headerTotalHours">${registeredHours} giờ</div>
          </div>
        </div>

      </div>
    </div>

    <!-- Form Submit Lịch Làm Việc -->
    <form id="registerScheduleForm" method="POST" action="${pageContext.request.contextPath}/employee/register-schedule">
      <input type="hidden" name="year" value="${selectedYear}">
      <input type="hidden" name="week" value="${selectedWeek}">

      <!-- Toolbar: Chọn Tuần & Công cụ Chọn Nhanh -->
      <div class="register-toolbar">
        
        <!-- Left: Year & Week Selector -->
        <div class="week-selector-group">
          <!-- Dropdown Năm -->
          <select id="yearSelect" class="form-select select-year-dropdown" onchange="changeWeekOrYear()">
            <c:forEach var="yr" items="${availableYears}">
              <option value="${yr}" ${yr == selectedYear ? 'selected' : ''}>Năm ${yr}</option>
            </c:forEach>
          </select>

          <!-- Nút tuần trước -->
          <c:choose>
            <c:when test="${hasPrevWeek}">
              <a href="${pageContext.request.contextPath}/employee/register-schedule?year=${prevYear}&week=${prevWeek}"
                class="btn-nav-arrow" title="Tuần trước">
                <i class="bi bi-chevron-left"></i>
              </a>
            </c:when>
            <c:otherwise>
              <button type="button" class="btn-nav-arrow" disabled style="opacity: 0.35; cursor: not-allowed;" title="Chỉ được phép đăng ký từ tuần tiếp theo">
                <i class="bi bi-chevron-left"></i>
              </button>
            </c:otherwise>
          </c:choose>

          <!-- Dropdown Chọn Tuần -->
          <select id="weekSelect" class="form-select select-week-dropdown" onchange="changeWeekOrYear()">
            <c:forEach var="w" items="${weekOptions}">
              <option value="${w.weekNumber}" ${w.weekNumber == selectedWeek ? 'selected' : ''}>
                ${w.label}
              </option>
            </c:forEach>
          </select>

          <!-- Nút tuần sau -->
          <c:choose>
            <c:when test="${hasNextWeek}">
              <a href="${pageContext.request.contextPath}/employee/register-schedule?year=${nextYear}&week=${nextWeek}"
                class="btn-nav-arrow" title="Tuần sau">
                <i class="bi bi-chevron-right"></i>
              </a>
            </c:when>
            <c:otherwise>
              <button type="button" class="btn-nav-arrow" disabled style="opacity: 0.35; cursor: not-allowed;" title="Không còn tuần tiếp theo">
                <i class="bi bi-chevron-right"></i>
              </button>
            </c:otherwise>
          </c:choose>
        </div>

        <!-- Right: Quick Select Helpers -->
        <div class="quick-select-group">
          <span class="text-muted small fw-semibold me-1 d-none d-lg-inline">Chọn nhanh:</span>
          <button type="button" class="btn-quick-select" onclick="selectMorning()">
            <i class="bi bi-sun"></i> Ca Sáng (8h-11h30)
          </button>
          <button type="button" class="btn-quick-select" onclick="selectAfternoon()">
            <i class="bi bi-sunset"></i> Ca Chiều (13h30-17h)
          </button>
          <button type="button" class="btn-quick-select" onclick="selectAllWeek()">
            <i class="bi bi-check-all"></i> Cả Tuần
          </button>
          <button type="button" class="btn-quick-select text-danger" onclick="deselectAll()">
            <i class="bi bi-x-circle"></i> Bỏ chọn
          </button>
        </div>

      </div>

      <!-- Main Schedule Registration Matrix Table -->
      <div class="register-card">
        <div class="table-responsive">
          <table class="table table-register align-middle">
            <thead>
              <tr>
                <th class="col-day-header">Thứ / Ngày</th>
                <c:forEach var="slot" items="${slots}">
                  <th class="col-slot-header">
                    <div>${slot.id}</div>
                    <span class="time-sub">${slot.timeRange}</span>
                  </th>
                </c:forEach>
                <th class="col-action-header text-center">Chọn ngày</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="day" items="${weekDays}">
                <tr class="${day.today ? 'row-today' : ''}">
                  
                  <!-- Cột Ngày Trong Tuần -->
                  <td class="day-cell">
                    <div class="d-flex align-items-center flex-wrap">
                      <span class="day-name">${day.dayName}</span>
                      <span class="day-date">${day.dayDate}</span>
                    </div>
                    <c:if test="${day.today}">
                      <span class="today-badge">Hôm nay</span>
                    </c:if>
                  </td>

                  <!-- 14 Cột Slot 30 phút -->
                  <c:forEach var="slot" items="${slots}">
                    <c:set var="cellKey" value="${day.fullDate}_${slot.id}" />
                    <c:set var="isRegistered" value="${registeredMap[cellKey]}" />

                    <td>
                      <c:choose>
                        
                        <%-- 1. Trường hợp: Ngày trong quá khứ --%>
                        <c:when test="${day.past}">
                          <div class="slot-past" title="Thời gian này đã qua">
                            <span class="text-muted"><i class="bi bi-clock-history me-1"></i>Đã qua</span>
                          </div>
                        </c:when>

                        <%-- 2. Trường hợp: Đã đăng ký trước đó trong Database --%>
                        <c:when test="${isRegistered}">
                          <div class="slot-registered" title="Bạn đã có lịch làm việc ở ca này">
                            <span class="slot-title"><i class="bi bi-check-circle-fill me-1"></i>Đã đăng ký</span>
                            <span class="slot-sub">30 phút</span>
                          </div>
                        </c:when>

                        <%-- 3. Trường hợp: Có thể chọn đăng ký mới --%>
                        <c:otherwise>
                          <div class="slot-check-wrapper">
                            <input type="checkbox" 
                                   name="selectedSlots" 
                                   value="${day.fullDate}|${slot.id}|${slot.startTime}:00|${slot.endTime}:00|${slot.session}"
                                   data-session="${slot.session}"
                                   data-date="${day.fullDate}"
                                   id="chk_${cellKey}" 
                                   class="slot-check-input">
                            <label for="chk_${cellKey}" class="slot-check-label">
                              <span class="slot-title"><i class="bi bi-plus-lg me-1"></i>Chọn ca</span>
                              <span class="slot-sub">30 phút</span>
                            </label>
                          </div>
                        </c:otherwise>

                      </c:choose>
                    </td>
                  </c:forEach>

                  <!-- Cột Nút Chọn Nhanh Cả Ngày -->
                  <td class="text-center">
                    <c:choose>
                      <c:when test="${day.past}">
                        <span class="text-muted small">-</span>
                      </c:when>
                      <c:otherwise>
                        <button type="button" class="btn-select-day" onclick="toggleDay('${day.fullDate}')" title="Chọn/Bỏ chọn cả ngày">
                          Tất cả
                        </button>
                      </c:otherwise>
                    </c:choose>
                  </td>

                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Sticky Bottom Summary & Submission Bar -->
      <div class="sticky-submit-bar">
        <div class="sticky-bar-content">
          
          <!-- Left: Count Summary -->
          <div class="d-flex align-items-center flex-wrap gap-2">
            <i class="bi bi-calendar-check fs-4 text-teal" style="color: var(--vc-primary);"></i>
            <div>
              <span class="fw-bold text-dark">Đã chọn:</span>
              <span class="selected-count-badge" id="barSelectedCount">0 ca (0.0 giờ)</span>
              <span class="text-muted small ms-2 d-none d-md-inline">• Tuần ${selectedWeek} / ${selectedYear}</span>
            </div>
          </div>

          <!-- Right: Actions -->
          <div class="d-flex align-items-center gap-2">
            <a href="${pageContext.request.contextPath}/employee/schedule?year=${selectedYear}&week=${selectedWeek}" 
               class="btn btn-outline-secondary btn-sm px-3 py-2 fw-semibold rounded-pill">
              <i class="bi bi-arrow-left me-1"></i> Xem lịch
            </a>

            <button type="submit" id="btnSubmitSchedule" class="btn-submit-schedule" disabled>
              <i class="bi bi-check-circle-fill"></i> Xác nhận đăng ký
            </button>
          </div>

        </div>
      </div>

    </form>

  </div>
</main>

<script>
  // Chuyen doi tuan va nam
  function changeWeekOrYear() {
    var year = document.getElementById("yearSelect").value;
    var week = document.getElementById("weekSelect").value;
    window.location.href = "${pageContext.request.contextPath}/employee/register-schedule?year=" + year + "&week=" + week;
  }

  // Cap nhat bo dem so ca da chon
  function updateSelectionCount() {
    var checkboxes = document.querySelectorAll('.slot-check-input:checked');
    var count = checkboxes.length;
    var hours = (count * 0.5).toFixed(1);
    var baseHours = ${registeredHours};
    var totalHours = (baseHours + (count * 0.5)).toFixed(1);

    document.getElementById('headerSelectedCount').innerText = count + " ca";
    document.getElementById('headerTotalHours').innerText = totalHours + " giờ";
    document.getElementById('barSelectedCount').innerText = count + " ca (" + hours + " giờ)";

    var submitBtn = document.getElementById('btnSubmitSchedule');
    if (count > 0) {
      submitBtn.disabled = false;
    } else {
      submitBtn.disabled = true;
    }
  }

  // Lang nghe su kien click checkbox
  document.addEventListener('DOMContentLoaded', function() {
    var checkboxes = document.querySelectorAll('.slot-check-input');
    checkboxes.forEach(function(cb) {
      cb.addEventListener('change', updateSelectionCount);
    });
    updateSelectionCount();
  });

  // Chon tat ca ca Sang (Morning)
  function selectMorning() {
    var checkboxes = document.querySelectorAll('.slot-check-input[data-session="Morning"]');
    checkboxes.forEach(function(cb) {
      cb.checked = true;
    });
    updateSelectionCount();
  }

  // Chon tat ca ca Chieu (Afternoon)
  function selectAfternoon() {
    var checkboxes = document.querySelectorAll('.slot-check-input[data-session="Afternoon"]');
    checkboxes.forEach(function(cb) {
      cb.checked = true;
    });
    updateSelectionCount();
  }

  // Chon ca tuan
  function selectAllWeek() {
    var checkboxes = document.querySelectorAll('.slot-check-input');
    checkboxes.forEach(function(cb) {
      cb.checked = true;
    });
    updateSelectionCount();
  }

  // Bo chon tat ca
  function deselectAll() {
    var checkboxes = document.querySelectorAll('.slot-check-input');
    checkboxes.forEach(function(cb) {
      cb.checked = false;
    });
    updateSelectionCount();
  }

  // Toggle chon ca theo tung ngay
  function toggleDay(dateStr) {
    var checkboxes = document.querySelectorAll('.slot-check-input[data-date="' + dateStr + '"]');
    if (checkboxes.length === 0) return;

    var allChecked = true;
    checkboxes.forEach(function(cb) {
      if (!cb.checked) allChecked = false;
    });

    checkboxes.forEach(function(cb) {
      cb.checked = !allChecked;
    });
    updateSelectionCount();
  }
</script>

<jsp:include page="/views/common/footer.jsp" />
