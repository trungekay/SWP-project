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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/doctor-waiting-list.css?v=11">
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
            </header>

            <c:if test="${not empty sessionScope.doctorQueueMessage}">
                <div class="doctor-queue-notice" role="status">
                    <i class="bi bi-info-circle" aria-hidden="true"></i>
                    <c:out value="${sessionScope.doctorQueueMessage}" />
                </div>
                <c:remove var="doctorQueueMessage" scope="session" />
            </c:if>

            <c:url var="allUrl" value="/doctor/waiting-list"><c:param name="date" value="${selectedDate}" /><c:param name="keyword" value="${keyword}" /><c:param name="status" value="all_day" /><c:param name="sort" value="${selectedSort}" /></c:url>
            <c:url var="waitingUrl" value="/doctor/waiting-list"><c:param name="date" value="${selectedDate}" /><c:param name="keyword" value="${keyword}" /><c:param name="status" value="Confirmed" /><c:param name="sort" value="${selectedSort}" /></c:url>
            <c:url var="examiningUrl" value="/doctor/waiting-list"><c:param name="date" value="${selectedDate}" /><c:param name="keyword" value="${keyword}" /><c:param name="status" value="In_Progress" /><c:param name="sort" value="${selectedSort}" /></c:url>
            <c:url var="completedUrl" value="/doctor/waiting-list"><c:param name="date" value="${selectedDate}" /><c:param name="keyword" value="${keyword}" /><c:param name="status" value="Completed" /><c:param name="sort" value="${selectedSort}" /></c:url>
            <c:url var="canceledUrl" value="/doctor/waiting-list"><c:param name="date" value="${selectedDate}" /><c:param name="keyword" value="${keyword}" /><c:param name="status" value="Canceled" /><c:param name="sort" value="${selectedSort}" /></c:url>
            <nav class="doctor-queue-stats" aria-label="Lọc ca khám theo trạng thái">
                <a class="doctor-queue-stat ${selectedStatus eq 'all_day' ? 'active' : ''}" href="<c:out value='${allUrl}' />" aria-current="${selectedStatus eq 'all_day' ? 'page' : 'false'}">
                    <span class="doctor-queue-stat-icon total"><i class="bi bi-people" aria-hidden="true"></i></span>
                    <div><strong><c:out value="${totalCount}" default="0" /></strong><span>Tổng ca phù hợp</span></div>
                </a>
                <a class="doctor-queue-stat ${selectedStatus eq 'Confirmed' ? 'active' : ''}" href="<c:out value='${waitingUrl}' />" aria-current="${selectedStatus eq 'Confirmed' ? 'page' : 'false'}">
                    <span class="doctor-queue-stat-icon waiting"><i class="bi bi-hourglass-split" aria-hidden="true"></i></span>
                    <div><strong><c:out value="${waitingCount}" default="0" /></strong><span>Chờ khám</span></div>
                </a>
                <a class="doctor-queue-stat ${selectedStatus eq 'In_Progress' ? 'active' : ''}" href="<c:out value='${examiningUrl}' />" aria-current="${selectedStatus eq 'In_Progress' ? 'page' : 'false'}">
                    <span class="doctor-queue-stat-icon examining"><i class="bi bi-activity" aria-hidden="true"></i></span>
                    <div><strong><c:out value="${examiningCount}" default="0" /></strong><span>Đang khám</span></div>
                </a>
                <a class="doctor-queue-stat ${selectedStatus eq 'Completed' ? 'active' : ''}" href="<c:out value='${completedUrl}' />" aria-current="${selectedStatus eq 'Completed' ? 'page' : 'false'}">
                    <span class="doctor-queue-stat-icon completed"><i class="bi bi-check2-circle" aria-hidden="true"></i></span>
                    <div><strong><c:out value="${completedCount}" default="0" /></strong><span>Hoàn tất</span></div>
                </a>
                <a class="doctor-queue-stat ${selectedStatus eq 'Canceled' ? 'active' : ''}" href="<c:out value='${canceledUrl}' />" aria-current="${selectedStatus eq 'Canceled' ? 'page' : 'false'}">
                    <span class="doctor-queue-stat-icon canceled"><i class="bi bi-x-circle" aria-hidden="true"></i></span>
                    <div><strong><c:out value="${canceledCount}" default="0" /></strong><span>Đã hủy</span></div>
                </a>
            </nav>

            <c:if test="${overdueCount > 0}">
                <div class="doctor-queue-overdue-notice" role="alert">
                    <i class="bi bi-exclamation-triangle-fill" aria-hidden="true"></i>
                    <span><strong><c:out value="${overdueCount}" /> ca chưa hoàn tất đã quá 1 giờ sau giờ hẹn.</strong>
                        Bác sĩ có thể hủy các ca quá giờ tại cột Thao tác.</span>
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

                <c:url var="previousUrl" value="/doctor/waiting-list"><c:param name="date" value="${previousDate}" /><c:param name="status" value="${selectedStatus}" /><c:param name="keyword" value="${keyword}" /><c:param name="sort" value="${selectedSort}" /></c:url>
                <c:url var="nextUrl" value="/doctor/waiting-list"><c:param name="date" value="${nextDate}" /><c:param name="status" value="${selectedStatus}" /><c:param name="keyword" value="${keyword}" /><c:param name="sort" value="${selectedSort}" /></c:url>
                <c:url var="todayUrl" value="/doctor/waiting-list"><c:param name="date" value="${todayDate}" /><c:param name="status" value="${selectedStatus}" /><c:param name="keyword" value="${keyword}" /><c:param name="sort" value="${selectedSort}" /></c:url>
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
                    <details class="doctor-queue-sort ${selectedSort ne 'default' ? 'active' : ''}">
                        <summary><i class="bi bi-funnel" aria-hidden="true"></i> Bộ lọc <i class="bi bi-chevron-down doctor-queue-sort-chevron" aria-hidden="true"></i></summary>
                        <div class="doctor-queue-sort-menu">
                            <fieldset>
                                <legend>Sắp xếp theo</legend>
                                <label><input type="radio" name="sort" value="default" ${selectedSort eq 'default' ? 'checked' : ''} onchange="this.form.requestSubmit()"> Mặc định</label>
                                <label><input type="radio" name="sort" value="time_asc" ${selectedSort eq 'time_asc' ? 'checked' : ''} onchange="this.form.requestSubmit()"> Khung giờ: sớm đến muộn</label>
                                <label><input type="radio" name="sort" value="id_asc" ${selectedSort eq 'id_asc' ? 'checked' : ''} onchange="this.form.requestSubmit()"> Mã hẹn: thấp đến cao</label>
                                <label><input type="radio" name="sort" value="name_asc" ${selectedSort eq 'name_asc' ? 'checked' : ''} onchange="this.form.requestSubmit()"> Tên bệnh nhân: A–Z</label>
                            </fieldset>
                        </div>
                    </details>
                    <button class="doctor-queue-filter-button" type="submit">Áp dụng</button>
                    <c:if test="${not empty keyword}">
                        <c:url var="clearSearchUrl" value="/doctor/waiting-list"><c:param name="date" value="${selectedDate}" /><c:param name="status" value="${selectedStatus}" /><c:param name="sort" value="${selectedSort}" /></c:url>
                        <a class="doctor-queue-clear" href="<c:out value='${clearSearchUrl}' />">Xóa tìm kiếm</a>
                    </c:if>
                </form>

                <c:choose>
                    <c:when test="${empty appointments}">
                        <div class="doctor-queue-empty" role="status">
                            <span><i class="bi bi-person-check" aria-hidden="true"></i></span>
                            <h3><c:choose><c:when test="${not empty keyword || selectedStatus ne 'all_day'}">Không có bệnh nhân phù hợp</c:when><c:otherwise>Chưa có bệnh nhân trong hàng đợi</c:otherwise></c:choose></h3>
                            <p><c:choose><c:when test="${not empty keyword || selectedStatus ne 'all_day'}">Hãy đổi trạng thái hoặc từ khóa tìm kiếm.</c:when><c:otherwise>Danh sách sẽ xuất hiện khi lễ tân check-in bệnh nhân trong ngày này.</c:otherwise></c:choose></p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-container doctor-queue-table-wrap">
                        <table class="custom-table doctor-queue-table">
                            <colgroup><col style="width: 8%"><col style="width: 15%"><col style="width: 13%"><col style="width: 15%"><col style="width: 23%"><col style="width: 14%"><col style="width: 12%"></colgroup>
                            <thead><tr><th class="text-center">Mã Hẹn</th><th>Bệnh Nhân</th><th>Khung Giờ &amp; Ngày</th><th>Bác Sĩ Phụ Trách</th><th>Phòng Khám</th><th class="text-center">Trạng Thái</th><th class="text-center">Thao Tác</th></tr></thead>
                            <tbody>
                            <c:forEach var="item" items="${appointments}">
                                <c:set var="startWindowState" value="${startWindowStates[item.id]}" />
                                <tr>
                                    <td class="text-center text-nowrap"><a class="badge bg-light text-dark border px-2 py-1 fw-bold text-decoration-none doctor-queue-link" href="${pageContext.request.contextPath}/doctor/patient-detail?id=${item.id}">#APT-<c:out value="${item.id}" /></a></td>
                                    <td class="text-nowrap text-truncate">
                                        <a class="fw-semibold text-dark text-decoration-none doctor-queue-link" href="${pageContext.request.contextPath}/doctor/patient-detail?id=${item.id}" title="<c:out value='${item.patientName}' />"><c:out value="${item.patientName}" default="Chưa có tên" /></a>
                                    </td>
                                    <td class="text-nowrap">
                                        <div class="fw-semibold text-dark doctor-queue-time"><i class="bi bi-clock text-teal me-1" aria-hidden="true"></i><c:out value="${item.timeSlot}" default="--:--" /><c:if test="${not empty item.endTime}"> - <c:out value="${item.endTime}" /></c:if></div>
                                        <div class="text-muted small"><i class="bi bi-calendar3 me-1" aria-hidden="true"></i><c:out value="${item.appointmentDate}" /></div>
                                        <div class="text-muted small">Check-in <c:out value="${fn:substring(item.checkinTime, 11, 16)}" default="--:--" /></div>
                                        <c:if test="${startWindowState eq 'late' && (item.status eq 'Confirmed' || item.status eq 'In_Progress')}">
                                            <div class="small doctor-queue-overdue-label">Quá giờ hẹn</div>
                                        </c:if>
                                    </td>
                                    <td class="text-nowrap text-truncate"><span class="fw-semibold text-dark" title="<c:out value='${item.doctorName}' />"><c:out value="${item.doctorName}" default="Chưa phân công" /></span></td>
                                    <td class="text-nowrap">
                                        <span class="badge bg-light text-dark border px-2 py-1 fw-medium doctor-queue-room" title="<c:out value='${item.roomName}' />"><i class="bi bi-door-open text-success" aria-hidden="true"></i><span class="text-truncate"><c:out value="${item.roomName}" default="Chưa phân phòng" /></span></span>
                                    </td>
                                    <td class="text-center text-nowrap">
                                        <c:choose>
                                            <c:when test="${item.status eq 'Confirmed'}"><span class="badge-status badge-confirmed">Chờ khám</span></c:when>
                                            <c:when test="${item.status eq 'In_Progress'}"><span class="badge-status badge-in-progress">Đang khám</span></c:when>
                                            <c:when test="${item.status eq 'Completed'}"><span class="badge-status badge-completed">Hoàn tất</span></c:when>
                                            <c:when test="${item.status eq 'Canceled'}"><span class="badge-status badge-canceled">Đã hủy</span></c:when>
                                            <c:otherwise><span class="badge-status badge-pending"><c:out value="${item.status}" /></span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center text-nowrap"><div class="action-btns doctor-queue-actions">
                                        <a class="action-btn" title="Xem hồ sơ" aria-label="Xem hồ sơ"
                                           href="${pageContext.request.contextPath}/doctor/patient-detail?id=${item.id}">
                                            <i class="bi bi-pencil" aria-hidden="true"></i>
                                        </a>
                                        <c:if test="${item.status eq 'Confirmed'}">
                                            <form action="${pageContext.request.contextPath}/doctor/waiting-list" method="post">
                                                <input type="hidden" name="action" value="start">
                                                <input type="hidden" name="appointmentId" value="${item.id}">
                                                <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}' />">
                                                <input type="hidden" name="date" value="<c:out value='${selectedDate}' />">
                                                <input type="hidden" name="status" value="<c:out value='${selectedStatus}' />">
                                                <input type="hidden" name="keyword" value="<c:out value='${keyword}' />">
                                                <input type="hidden" name="sort" value="<c:out value='${selectedSort}' />">
                                                <c:choose>
                                                    <c:when test="${doctorBusy}">
                                                        <button class="action-btn checkin" type="button" disabled title="Hãy hoàn tất ca đang khám trước" aria-label="Gọi vào khám: bác sĩ đang bận">
                                                            <i class="bi bi-play-fill" aria-hidden="true"></i>
                                                        </button>
                                                    </c:when>
                                                    <c:when test="${startWindowState eq 'early'}">
                                                        <button class="action-btn warning" type="button" title="Chưa đến giờ gọi vào khám" aria-label="Chưa đến giờ gọi vào khám"
                                                                data-bs-toggle="modal" data-bs-target="#examWindowModal" data-window-state="early"
                                                                data-appointment-id="${item.id}" data-exam-status="Confirmed" data-patient-name="<c:out value='${item.patientName}' />">
                                                            <i class="bi bi-play-fill" aria-hidden="true"></i>
                                                        </button>
                                                    </c:when>
                                                    <c:when test="${startWindowState eq 'late'}">
                                                        <button class="action-btn warning" type="button" title="Đã quá giờ gọi vào khám" aria-label="Đã quá giờ gọi vào khám"
                                                                data-bs-toggle="modal" data-bs-target="#examWindowModal" data-window-state="late"
                                                                data-appointment-id="${item.id}" data-exam-status="Confirmed" data-patient-name="<c:out value='${item.patientName}' />">
                                                            <i class="bi bi-play-fill" aria-hidden="true"></i>
                                                        </button>
                                                    </c:when>
                                                    <c:when test="${startWindowState ne 'open'}">
                                                        <button class="action-btn warning" type="button" title="Không xác định được giờ hẹn" aria-label="Không xác định được giờ hẹn"
                                                                data-bs-toggle="modal" data-bs-target="#examWindowModal" data-window-state="invalid"
                                                                data-appointment-id="${item.id}" data-exam-status="Confirmed" data-patient-name="<c:out value='${item.patientName}' />">
                                                            <i class="bi bi-play-fill" aria-hidden="true"></i>
                                                        </button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button class="action-btn checkin" type="submit" title="Gọi vào khám" aria-label="Gọi vào khám">
                                                            <i class="bi bi-play-fill" aria-hidden="true"></i>
                                                        </button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </form>
                                        </c:if>
                                        <c:if test="${item.status eq 'In_Progress'}">
                                            <c:if test="${not completionReadyIds.contains(item.id)}">
                                                <a class="action-btn" href="${pageContext.request.contextPath}/doctor/examination?id=${item.id}" title="Điền kết quả khám, chẩn đoán và kết luận" aria-label="Điền phiếu khám">
                                                    <i class="bi bi-clipboard2-pulse" aria-hidden="true"></i>
                                                </a>
                                            </c:if>
                                            <c:if test="${completionReadyIds.contains(item.id)}">
                                            <form action="${pageContext.request.contextPath}/doctor/waiting-list" method="post">
                                                <input type="hidden" name="action" value="complete">
                                                <input type="hidden" name="appointmentId" value="${item.id}">
                                                <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}' />">
                                                <input type="hidden" name="date" value="<c:out value='${selectedDate}' />">
                                                <input type="hidden" name="status" value="<c:out value='${selectedStatus}' />">
                                                <input type="hidden" name="keyword" value="<c:out value='${keyword}' />">
                                                <input type="hidden" name="sort" value="<c:out value='${selectedSort}' />">
                                                <c:choose>
                                                    <c:when test="${not isToday}">
                                                        <button class="action-btn complete" type="button" disabled title="Chỉ có thể hoàn tất ca khám trong ngày hôm nay" aria-label="Không thể hoàn tất ca ngoài ngày hôm nay">
                                                            <i class="bi bi-check2" aria-hidden="true"></i>
                                                        </button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button class="action-btn complete" type="submit" title="Hoàn tất ca khám" aria-label="Hoàn tất ca khám">
                                                            <i class="bi bi-check2" aria-hidden="true"></i>
                                                        </button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </form>
                                            </c:if>
                                        </c:if>
                                        <c:if test="${item.status eq 'In_Progress' || (item.status eq 'Confirmed' && startWindowState eq 'late')}">
                                            <button class="action-btn delete" type="button" title="${item.status eq 'In_Progress' ? 'Dừng khám' : 'Hủy khám'}" aria-label="${item.status eq 'In_Progress' ? 'Dừng khám' : 'Hủy khám'}"
                                                    data-bs-toggle="modal" data-bs-target="#cancelExamModal" data-appointment-id="${item.id}"
                                                    data-exam-status="${item.status}" data-patient-name="<c:out value='${item.patientName}' />">
                                                <i class="bi bi-trash" aria-hidden="true"></i>
                                            </button>
                                        </c:if>
                                    </div></td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>
    </div>
</main>
<div class="modal fade doctor-queue-modal" id="cancelExamModal" tabindex="-1"
     aria-labelledby="cancelExamModalTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
            </div>
            <div class="modal-body">
                <div class="modal-icon-danger"><i class="bi bi-x-circle" aria-hidden="true"></i></div>
                <h3 class="modal-title-custom" id="cancelExamModalTitle">Xác nhận hủy khám?</h3>
                <p class="modal-text">Ca khám <strong id="cancelExamCode">#APT-</strong> của
                    <strong id="cancelExamPatient">bệnh nhân</strong> <span id="cancelExamDescription"></span>
                    Ca này sẽ được lưu với trạng thái <strong>Đã hủy</strong>; thông tin khám đã ghi vẫn được giữ lại.</p>
                <form action="${pageContext.request.contextPath}/doctor/waiting-list" method="post" class="m-0">
                    <input type="hidden" name="action" value="cancel">
                    <input type="hidden" name="appointmentId" id="cancelExamAppointmentId">
                    <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}' />">
                    <input type="hidden" name="date" value="<c:out value='${selectedDate}' />">
                    <input type="hidden" name="status" value="<c:out value='${selectedStatus}' />">
                    <input type="hidden" name="keyword" value="<c:out value='${keyword}' />">
                    <input type="hidden" name="sort" value="<c:out value='${selectedSort}' />">
                    <label for="cancelExamReason" class="form-label fw-semibold">Lý do dừng/hủy ca khám</label>
                    <textarea id="cancelExamReason" name="reason" class="form-control" rows="3" maxlength="500" required></textarea>
                    <div class="modal-actions">
                        <button type="button" class="btn btn-modal-cancel" data-bs-dismiss="modal">Đóng</button>
                        <button type="submit" class="btn btn-modal-danger"><i class="bi bi-x-circle me-1" aria-hidden="true"></i> Hủy khám</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
<div class="modal fade doctor-queue-modal" id="examWindowModal" tabindex="-1"
     aria-labelledby="examWindowModalTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
            </div>
            <div class="modal-body">
                <div class="modal-icon-warning"><i class="bi bi-clock-history" aria-hidden="true"></i></div>
                <h3 class="modal-title-custom" id="examWindowModalTitle">Chưa đến giờ khám</h3>
                <p class="modal-text" id="examWindowModalText"></p>
                <div class="modal-actions">
                    <button type="button" class="btn btn-modal-danger" id="cancelFromWindowButton">Hủy khám</button>
                    <button type="button" class="btn btn-modal-warning d-none" id="continueExamButton">Tiếp tục khám</button>
                </div>
            </div>
        </div>
    </div>
</div>
<c:if test="${isToday}">
    <script>
        setInterval(function () {
            var active = document.activeElement;
            if (document.visibilityState === 'visible'
                    && !(active && active.closest('.doctor-queue-search'))
                    && !document.querySelector('.doctor-queue-modal.show')) {
                window.location.reload();
            }
        }, 60000);
    </script>
</c:if>
<script src="${pageContext.request.contextPath}/assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script>
    document.getElementById('cancelExamModal').addEventListener('show.bs.modal', function (event) {
        var trigger = event.relatedTarget;
        var id = trigger.getAttribute('data-appointment-id');
        var active = trigger.getAttribute('data-exam-status') === 'In_Progress';
        var patient = trigger.getAttribute('data-patient-name') || 'bệnh nhân';
        document.getElementById('cancelExamAppointmentId').value = id;
        document.getElementById('cancelExamCode').textContent = '#APT-' + id;
        document.getElementById('cancelExamPatient').textContent = patient;
        document.getElementById('cancelExamModalTitle').textContent = active ? 'Xác nhận dừng ca đang khám?' : 'Xác nhận hủy ca chờ khám?';
        document.getElementById('cancelExamDescription').textContent = active
                ? 'đang được khám. Chỉ bác sĩ phụ trách có thể dừng ca này.'
                : 'đang chờ khám.';
        document.getElementById('cancelExamReason').value = '';
    });

    var examStartForm = null;
    var examWindowTrigger = null;
    document.getElementById('examWindowModal').addEventListener('show.bs.modal', function (event) {
        examWindowTrigger = event.relatedTarget;
        var state = event.relatedTarget.getAttribute('data-window-state');
        var messages = {
            early: ['Chưa đến giờ khám', 'Ca này còn hơn 1 giờ mới đến giờ hẹn. Bạn vẫn có thể tiếp tục khám.'],
            late: ['Đã quá giờ khám', 'Ca này đã quá 1 giờ sau giờ hẹn. Bạn vẫn có thể tiếp tục khám.'],
            invalid: ['Không xác định được giờ hẹn', 'Vui lòng liên hệ bộ phận tiếp nhận để kiểm tra lịch hẹn.']
        };
        var message = messages[state] || messages.invalid;
        examStartForm = state === 'early' || state === 'late' ? event.relatedTarget.closest('form') : null;
        document.getElementById('continueExamButton').classList.toggle('d-none', !examStartForm);
        document.getElementById('examWindowModalTitle').textContent = message[0];
        document.getElementById('examWindowModalText').textContent = message[1];
    });
    document.getElementById('continueExamButton').addEventListener('click', function () {
        if (examStartForm) examStartForm.requestSubmit();
    });
    document.getElementById('cancelFromWindowButton').addEventListener('click', function () {
        if (!examWindowTrigger) return;
        var trigger = examWindowTrigger;
        var windowModal = document.getElementById('examWindowModal');
        windowModal.addEventListener('hidden.bs.modal', function () {
            bootstrap.Modal.getOrCreateInstance(document.getElementById('cancelExamModal')).show(trigger);
        }, { once: true });
        bootstrap.Modal.getOrCreateInstance(windowModal).hide();
    });
</script>
</body>
</html>
