<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Hàng đợi khám bệnh - VisionCare</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/vendor/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/vendor/bootstrap-icons/bootstrap-icons.css">
    <jsp:include page="/views/admin/layout/admin-css.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/doctor-waiting-list.css?v=5">
</head>
<body class="doctor-queue-body">
<jsp:include page="/views/employee/layout/employee-sidebar.jsp">
    <jsp:param name="activeNav" value="doctor-waiting" />
</jsp:include>

<main class="main-wrapper">
    <jsp:include page="/views/employee/layout/employee-header.jsp" />
    <div class="page-content doctor-queue-page">
            <header class="doctor-queue-heading">
                <div>
                    <span class="doctor-queue-eyebrow">KHU VỰC BÁC SĨ</span>
                    <h1>Hàng đợi khám bệnh</h1>
                    <p>Danh sách bệnh nhân đã check-in theo lịch làm việc của bạn.</p>
                </div>
                <c:url var="refreshUrl" value="/doctor/waiting-list"><c:param name="date" value="${selectedDate}" /><c:param name="status" value="${selectedStatus}" /><c:param name="keyword" value="${keyword}" /></c:url>
                <a class="doctor-queue-refresh" href="<c:out value='${refreshUrl}' />">
                    <i class="bi bi-arrow-clockwise" aria-hidden="true"></i> Làm mới
                </a>
            </header>

            <c:if test="${not empty sessionScope.doctorQueueMessage}">
                <div class="doctor-queue-notice" role="status">
                    <i class="bi bi-info-circle" aria-hidden="true"></i>
                    <c:out value="${sessionScope.doctorQueueMessage}" />
                </div>
                <c:remove var="doctorQueueMessage" scope="session" />
            </c:if>

            <section class="doctor-queue-stats" aria-label="Tổng quan ca khám">
                <div class="doctor-queue-stat">
                    <span class="doctor-queue-stat-icon waiting"><i class="bi bi-hourglass-split" aria-hidden="true"></i></span>
                    <div><strong><c:out value="${waitingCount}" default="0" /></strong><span>Chờ khám</span></div>
                </div>
                <div class="doctor-queue-stat">
                    <span class="doctor-queue-stat-icon examining"><i class="bi bi-activity" aria-hidden="true"></i></span>
                    <div><strong><c:out value="${examiningCount}" default="0" /></strong><span>Đang khám</span></div>
                </div>
                <div class="doctor-queue-stat">
                    <span class="doctor-queue-stat-icon completed"><i class="bi bi-check2-circle" aria-hidden="true"></i></span>
                    <div><strong><c:out value="${completedCount}" default="0" /></strong><span>Hoàn tất</span></div>
                </div>
                <div class="doctor-queue-stat">
                    <span class="doctor-queue-stat-icon total"><i class="bi bi-people" aria-hidden="true"></i></span>
                    <div><strong><c:out value="${totalCount}" default="0" /></strong><span>Tổng ca phù hợp</span></div>
                </div>
            </section>

            <c:if test="${overdueCount > 0}">
                <div class="doctor-queue-overdue-notice" role="alert">
                    <i class="bi bi-exclamation-triangle-fill" aria-hidden="true"></i>
                    <span><strong><c:out value="${overdueCount}" /> ca chưa hoàn tất đã quá 1 giờ sau giờ hẹn.</strong>
                        Vui lòng kiểm tra và liên hệ bộ phận tiếp nhận để xử lý.</span>
                </div>
            </c:if>

            <section class="doctor-queue-panel" aria-labelledby="queue-heading">
                <div class="doctor-queue-panel-top">
                    <div>
                        <h2 id="queue-heading">Danh sách bệnh nhân</h2>
                        <p>Ca đã check-in và được phân công cho bác sĩ đang đăng nhập.</p>
                    </div>
                    <span class="doctor-queue-date-chip"><i class="bi bi-calendar3" aria-hidden="true"></i> <c:out value="${displayDate}" /></span>
                </div>

                <c:url var="previousUrl" value="/doctor/waiting-list"><c:param name="date" value="${previousDate}" /><c:param name="status" value="${selectedStatus}" /><c:param name="keyword" value="${keyword}" /></c:url>
                <c:url var="nextUrl" value="/doctor/waiting-list"><c:param name="date" value="${nextDate}" /><c:param name="status" value="${selectedStatus}" /><c:param name="keyword" value="${keyword}" /></c:url>
                <c:url var="todayUrl" value="/doctor/waiting-list"><c:param name="date" value="${todayDate}" /><c:param name="status" value="${selectedStatus}" /><c:param name="keyword" value="${keyword}" /></c:url>
                <form class="doctor-queue-search" action="${pageContext.request.contextPath}/doctor/waiting-list" method="get" role="search">
                    <input type="hidden" name="status" value="<c:out value='${selectedStatus}' />">
                    <div class="doctor-queue-date-controls" aria-label="Chọn ngày khám">
                        <a href="<c:out value='${previousUrl}' />" aria-label="Ngày trước" title="Ngày trước"><i class="bi bi-chevron-left" aria-hidden="true"></i></a>
                        <label class="doctor-queue-date-field">
                            <i class="bi bi-calendar-event" aria-hidden="true"></i>
                            <span class="visually-hidden">Ngày khám</span>
                            <input type="date" name="date" value="<c:out value='${selectedDate}' />">
                        </label>
                        <a href="<c:out value='${nextUrl}' />" aria-label="Ngày sau" title="Ngày sau"><i class="bi bi-chevron-right" aria-hidden="true"></i></a>
                        <c:if test="${not isToday}"><a class="doctor-queue-today" href="<c:out value='${todayUrl}' />">Hôm nay</a></c:if>
                    </div>
                    <label class="doctor-queue-search-field">
                        <i class="bi bi-search" aria-hidden="true"></i>
                        <span class="visually-hidden">Tìm bệnh nhân</span>
                        <input type="search" name="keyword" maxlength="100" placeholder="Tên bệnh nhân, SĐT hoặc mã lịch hẹn"
                               value="<c:out value='${keyword}' />">
                    </label>
                    <button class="doctor-queue-filter-button" type="submit">Áp dụng</button>
                    <c:if test="${not empty keyword}"><a class="doctor-queue-clear" href="${pageContext.request.contextPath}/doctor/waiting-list?date=${selectedDate}&amp;status=${selectedStatus}">Xóa tìm kiếm</a></c:if>
                </form>

                <c:url var="allUrl" value="/doctor/waiting-list"><c:param name="date" value="${selectedDate}" /><c:param name="keyword" value="${keyword}" /><c:param name="status" value="all_day" /></c:url>
                <c:url var="waitingUrl" value="/doctor/waiting-list"><c:param name="date" value="${selectedDate}" /><c:param name="keyword" value="${keyword}" /><c:param name="status" value="Confirmed" /></c:url>
                <c:url var="examiningUrl" value="/doctor/waiting-list"><c:param name="date" value="${selectedDate}" /><c:param name="keyword" value="${keyword}" /><c:param name="status" value="In_Progress" /></c:url>
                <c:url var="completedUrl" value="/doctor/waiting-list"><c:param name="date" value="${selectedDate}" /><c:param name="keyword" value="${keyword}" /><c:param name="status" value="Completed" /></c:url>
                <nav class="doctor-queue-tabs" aria-label="Lọc theo trạng thái">
                    <a class="${selectedStatus eq 'all_day' ? 'active' : ''}" href="<c:out value='${allUrl}' />">Tất cả <span><c:out value="${totalCount}" default="0" /></span></a>
                    <a class="${selectedStatus eq 'Confirmed' ? 'active' : ''}" href="<c:out value='${waitingUrl}' />">Chờ khám <span><c:out value="${waitingCount}" default="0" /></span></a>
                    <a class="${selectedStatus eq 'In_Progress' ? 'active' : ''}" href="<c:out value='${examiningUrl}' />">Đang khám <span><c:out value="${examiningCount}" default="0" /></span></a>
                    <a class="${selectedStatus eq 'Completed' ? 'active' : ''}" href="<c:out value='${completedUrl}' />">Hoàn tất <span><c:out value="${completedCount}" default="0" /></span></a>
                </nav>

                <c:choose>
                    <c:when test="${empty appointments}">
                        <div class="doctor-queue-empty" role="status">
                            <span><i class="bi bi-person-check" aria-hidden="true"></i></span>
                            <h3><c:choose><c:when test="${not empty keyword || selectedStatus ne 'all_day'}">Không có bệnh nhân phù hợp</c:when><c:otherwise>Chưa có bệnh nhân trong hàng đợi</c:otherwise></c:choose></h3>
                            <p><c:choose><c:when test="${not empty keyword || selectedStatus ne 'all_day'}">Hãy đổi trạng thái hoặc từ khóa tìm kiếm.</c:when><c:otherwise>Danh sách sẽ xuất hiện khi lễ tân check-in bệnh nhân trong ngày này.</c:otherwise></c:choose></p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="doctor-queue-list-header" aria-hidden="true">
                            <span>BỆNH NHÂN</span><span>GIỜ HẸN / CHECK-IN</span><span>PHÒNG KHÁM</span><span>TRẠNG THÁI</span><span>THAO TÁC</span>
                        </div>
                        <div class="doctor-queue-list" role="list">
                            <c:forEach var="item" items="${appointments}">
                                <c:set var="startWindowState" value="${startWindowStates[item.id]}" />
                                <article class="doctor-queue-item" role="listitem">
                                    <div class="doctor-queue-patient">
                                        <div class="doctor-queue-avatar" aria-hidden="true"><c:out value="${fn:substring(item.patientName, 0, 1)}" default="BN" /></div>
                                        <div class="doctor-queue-patient-copy">
                                            <h3><c:out value="${item.patientName}" default="Chưa có tên" /></h3>
                                            <span>#APPT-<c:out value="${item.id}" /> <span class="doctor-queue-separator">·</span> <c:out value="${item.phone}" default="Chưa có SĐT" /></span>
                                        </div>
                                    </div>
                                    <div class="doctor-queue-cell">
                                        <span class="doctor-queue-mobile-label">Giờ hẹn / check-in</span>
                                        <strong><c:out value="${item.timeSlot}" default="--:--" /></strong>
                                        <small>Check-in <c:out value="${fn:substring(item.checkinTime, 11, 16)}" default="--:--" /></small>
                                        <c:if test="${startWindowState eq 'late' && item.status ne 'Completed'}">
                                            <small class="doctor-queue-overdue-label">Quá giờ hẹn, chưa hoàn tất khám</small>
                                        </c:if>
                                    </div>
                                    <div class="doctor-queue-cell">
                                        <span class="doctor-queue-mobile-label">Phòng khám</span>
                                        <strong><c:out value="${item.roomName}" default="Chưa phân phòng" /></strong>
                                    </div>
                                    <div class="doctor-queue-cell">
                                        <span class="doctor-queue-mobile-label">Trạng thái</span>
                                        <c:choose>
                                            <c:when test="${item.status eq 'Confirmed'}"><span class="doctor-queue-status waiting"><i class="bi bi-hourglass-split" aria-hidden="true"></i> Chờ khám</span></c:when>
                                            <c:when test="${item.status eq 'In_Progress'}"><span class="doctor-queue-status examining"><i class="bi bi-activity" aria-hidden="true"></i> Đang khám</span></c:when>
                                            <c:when test="${item.status eq 'Completed'}"><span class="doctor-queue-status completed"><i class="bi bi-check-circle" aria-hidden="true"></i> Hoàn tất</span></c:when>
                                            <c:otherwise><span class="doctor-queue-status neutral"><c:out value="${item.status}" /></span></c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="doctor-queue-actions">
                                        <a class="doctor-queue-button doctor-queue-button-outline"
                                           href="${pageContext.request.contextPath}/doctor/patient-detail?id=${item.id}">
                                            <i class="bi bi-person-vcard" aria-hidden="true"></i> Xem hồ sơ
                                        </a>
                                        <c:if test="${item.status eq 'Confirmed'}">
                                            <form action="${pageContext.request.contextPath}/doctor/waiting-list" method="post">
                                                <input type="hidden" name="action" value="start">
                                                <input type="hidden" name="appointmentId" value="${item.id}">
                                                <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}' />">
                                                <input type="hidden" name="date" value="<c:out value='${selectedDate}' />">
                                                <input type="hidden" name="status" value="<c:out value='${selectedStatus}' />">
                                                <input type="hidden" name="keyword" value="<c:out value='${keyword}' />">
                                                <c:choose>
                                                    <c:when test="${startWindowState eq 'early'}">
                                                        <button class="doctor-queue-button doctor-queue-button-primary doctor-queue-button-unavailable" type="button"
                                                                onclick="alert('Chưa đến giờ khám. Chỉ có thể bắt đầu trong vòng 1 giờ trước giờ hẹn.')">
                                                            <i class="bi bi-play-fill" aria-hidden="true"></i> Gọi vào khám
                                                        </button>
                                                    </c:when>
                                                    <c:when test="${startWindowState eq 'late'}">
                                                        <button class="doctor-queue-button doctor-queue-button-primary doctor-queue-button-unavailable" type="button"
                                                                onclick="alert('Đã quá giờ khám. Chỉ có thể bắt đầu trong vòng 1 giờ sau giờ hẹn.')">
                                                            <i class="bi bi-play-fill" aria-hidden="true"></i> Gọi vào khám
                                                        </button>
                                                    </c:when>
                                                    <c:when test="${startWindowState ne 'open'}">
                                                        <button class="doctor-queue-button doctor-queue-button-primary doctor-queue-button-unavailable" type="button"
                                                                onclick="alert('Không xác định được giờ hẹn. Vui lòng liên hệ bộ phận tiếp nhận.')">
                                                            <i class="bi bi-play-fill" aria-hidden="true"></i> Gọi vào khám
                                                        </button>
                                                    </c:when>
                                                    <c:when test="${doctorBusy}">
                                                        <button class="doctor-queue-button doctor-queue-button-primary" type="button" disabled
                                                                title="Hãy hoàn tất ca đang khám trước">
                                                            <i class="bi bi-play-fill" aria-hidden="true"></i> Gọi vào khám
                                                        </button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button class="doctor-queue-button doctor-queue-button-primary" type="submit">
                                                            <i class="bi bi-play-fill" aria-hidden="true"></i> Gọi vào khám
                                                        </button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </form>
                                        </c:if>
                                        <c:if test="${item.status eq 'In_Progress'}">
                                            <form action="${pageContext.request.contextPath}/doctor/waiting-list" method="post">
                                                <input type="hidden" name="action" value="complete">
                                                <input type="hidden" name="appointmentId" value="${item.id}">
                                                <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}' />">
                                                <input type="hidden" name="date" value="<c:out value='${selectedDate}' />">
                                                <input type="hidden" name="status" value="<c:out value='${selectedStatus}' />">
                                                <input type="hidden" name="keyword" value="<c:out value='${keyword}' />">
                                                <c:choose>
                                                    <c:when test="${not isToday}">
                                                        <button class="doctor-queue-button doctor-queue-button-primary" type="button" disabled
                                                                title="Chỉ có thể hoàn tất ca khám trong ngày hôm nay">
                                                            <i class="bi bi-check2" aria-hidden="true"></i> Hoàn tất
                                                        </button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button class="doctor-queue-button doctor-queue-button-primary" type="submit">
                                                            <i class="bi bi-check2" aria-hidden="true"></i> Hoàn tất
                                                        </button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </form>
                                        </c:if>
                                    </div>
                                </article>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>
    </div>
</main>
<c:if test="${isToday}">
    <script>
        setInterval(function () {
            var active = document.activeElement;
            if (document.visibilityState === 'visible'
                    && !(active && active.closest('.doctor-queue-search'))) {
                window.location.reload();
            }
        }, 60000);
    </script>
</c:if>
<script src="${pageContext.request.contextPath}/assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
</body>
</html>
