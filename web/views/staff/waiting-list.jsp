<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Danh Sách Chờ - VisionCare Lễ Tân</title>
                <!-- Google Fonts -->
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                    rel="stylesheet">
                <!-- Bootstrap 5 CSS -->
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
                <!-- Bootstrap Icons -->
                <link rel="stylesheet"
                    href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

                <!-- Employee / Staff Unified Layout CSS -->
                <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/employee.css">
                <style>
                    .action-btn.medical-notes {
                        background-color: #f0fdfa !important;
                        color: #0d9488 !important;
                        border: 1px solid #99f6e4 !important;
                    }

                    .action-btn.medical-notes:hover {
                        background-color: #0d9488 !important;
                        color: #ffffff !important;
                        border-color: #0d9488 !important;
                    }
                </style>
            </head>

            <body>

                <!-- Employee Unified Sidebar -->
                <jsp:include page="/views/employee/layout/employee-sidebar.jsp">
                    <jsp:param name="activeNav" value="waiting-list" />
                </jsp:include>

                <!-- Main Wrapper -->
                <main class="main-wrapper">
                    <!-- Top Header -->
                    <jsp:include page="/views/employee/layout/employee-header.jsp" />

                    <!-- Page Content -->
                    <div class="page-content">

                        <!-- Flash Messages -->
                        <c:if test="${not empty sessionScope.successMessage}">
                            <div class="flash-alert flash-alert-success alert-dismissible fade show" role="alert">
                                <div class="flash-alert-icon">
                                    <i class="bi bi-check-lg"></i>
                                </div>
                                <div class="flash-alert-content">
                                    <span class="alert-title">Thành công!</span>${sessionScope.successMessage}
                                </div>
                                <button type="button" class="btn-close" data-bs-dismiss="alert"
                                    aria-label="Close"></button>
                            </div>
                            <c:remove var="successMessage" scope="session" />
                        </c:if>
                        <c:if test="${not empty sessionScope.errorMessage}">
                            <div class="flash-alert flash-alert-danger alert-dismissible fade show" role="alert">
                                <div class="flash-alert-icon">
                                    <i class="bi bi-exclamation-triangle-fill"></i>
                                </div>
                                <div class="flash-alert-content">
                                    <span class="alert-title">Thông báo:</span>${sessionScope.errorMessage}
                                </div>
                                <button type="button" class="btn-close" data-bs-dismiss="alert"
                                    aria-label="Close"></button>
                            </div>
                            <c:remove var="errorMessage" scope="session" />
                        </c:if>

                        <!-- Page Header -->
                        <div class="page-header d-flex align-items-center justify-content-between mb-3">
                            <div class="page-title">
                                <h2 class="mb-0">Danh Sách Chờ</h2>
                            </div>
                        </div>

                        <!-- KPI Queue Summary Cards (Bấm để lọc theo trạng thái) -->
                        <div class="row g-3 mb-4 align-items-stretch">
                            <!-- 1. Tổng trong hàng đợi -->
                            <div class="col-sm-6 col-xl-3 d-flex">
                                <a href="${pageContext.request.contextPath}/staff/waiting-list?date=${selectedDate}&status=all&doctorId=${selectedDoctorId}&keyword=${param.keyword}"
                                    class="metric-card w-100 text-decoration-none ${selectedStatus == 'all' || empty selectedStatus ? 'border border-2 border-primary shadow-sm bg-light' : ''}">
                                    <div class="metric-icon-box metric-icon-teal">
                                        <i class="bi bi-people-fill"></i>
                                    </div>
                                    <div class="metric-info">
                                        <div class="metric-num">${totalQueue}</div>
                                        <div class="metric-title text-secondary">Tổng trong hàng đợi</div>
                                    </div>
                                </a>
                            </div>

                            <!-- 2. Chờ khám -->
                            <div class="col-sm-6 col-xl-3 d-flex">
                                <a href="${pageContext.request.contextPath}/staff/waiting-list?date=${selectedDate}&status=Confirmed&doctorId=${selectedDoctorId}&keyword=${param.keyword}"
                                    class="metric-card w-100 text-decoration-none ${selectedStatus == 'Confirmed' ? 'border border-2 border-warning shadow-sm' : ''}"
                                    style="${selectedStatus == 'Confirmed' ? 'background-color: #fffdf5;' : ''}">
                                    <div class="metric-icon-box metric-icon-warning">
                                        <i class="bi bi-hourglass-split"></i>
                                    </div>
                                    <div class="metric-info">
                                        <div class="metric-num">${totalWaiting}</div>
                                        <div class="metric-title text-secondary">Chờ khám</div>
                                    </div>
                                </a>
                            </div>

                            <!-- 3. Đang khám trong phòng -->
                            <div class="col-sm-6 col-xl-3 d-flex">
                                <a href="${pageContext.request.contextPath}/staff/waiting-list?date=${selectedDate}&status=In_Progress&doctorId=${selectedDoctorId}&keyword=${param.keyword}"
                                    class="metric-card w-100 text-decoration-none ${selectedStatus == 'In_Progress' ? 'border border-2 border-purple shadow-sm' : ''}"
                                    style="${selectedStatus == 'In_Progress' ? 'background-color: #faf5ff;' : ''}">
                                    <div class="metric-icon-box metric-icon-purple">
                                        <i class="bi bi-heart-pulse-fill"></i>
                                    </div>
                                    <div class="metric-info">
                                        <div class="metric-num">${totalExamining}</div>
                                        <div class="metric-title text-secondary">Đang khám trong phòng</div>
                                    </div>
                                </a>
                            </div>

                            <!-- 4. Đã khám xong -->
                            <div class="col-sm-6 col-xl-3 d-flex">
                                <a href="${pageContext.request.contextPath}/staff/waiting-list?date=${selectedDate}&status=Completed&doctorId=${selectedDoctorId}&keyword=${param.keyword}"
                                    class="metric-card w-100 text-decoration-none ${selectedStatus == 'Completed' ? 'border border-2 border-success shadow-sm' : ''}"
                                    style="${selectedStatus == 'Completed' ? 'background-color: #f0fdf4;' : ''}">
                                    <div class="metric-icon-box metric-icon-success">
                                        <i class="bi bi-check2-circle"></i>
                                    </div>
                                    <div class="metric-info">
                                        <div class="metric-num">${totalCompleted}</div>
                                        <div class="metric-title text-secondary">Đã khám xong</div>
                                    </div>
                                </a>
                            </div>
                        </div>

                        <!-- Waiting List Card -->
                        <div class="content-card">
                            <!-- Queue Toolbar: Tìm kiếm bệnh nhân & Chọn ngày -->
                            <form action="${pageContext.request.contextPath}/staff/waiting-list" method="get"
                                class="p-3 border-bottom bg-white">
                                <input type="hidden" name="status" value="${selectedStatus}">
                                <div
                                    class="d-flex flex-column flex-md-row align-items-stretch align-items-md-center justify-content-between gap-3">
                                    <!-- 1. Thanh tìm kiếm nhanh (Tên, SĐT, Mã hẹn) -->
                                    <div class="search-filter-input flex-grow-1" style="max-width: 520px;">
                                        <i class="bi bi-search"></i>
                                        <input type="text" name="keyword" value="${param.keyword}" class="w-100"
                                            style="height: 40px; font-size: 14px; border-radius: 8px;">
                                    </div>

                                    <!-- 2. Chọn ngày & Nút Tra cứu -->
                                    <div class="d-flex align-items-center gap-3 flex-wrap flex-md-nowrap">
                                        <!-- Hộp chọn ngày khám -->
                                        <div class="d-flex align-items-center gap-2">
                                            <label for="dateFilterInput"
                                                class="text-secondary small fw-semibold mb-0 text-nowrap d-flex align-items-center"
                                                style="font-size: 13.5px; gap: 6px;">
                                                <i class="bi bi-calendar3"
                                                    style="color: var(--primary-color); font-size: 15px;"></i>
                                                <span>Ngày:</span>
                                            </label>
                                            <input type="date" id="dateFilterInput" name="date"
                                                class="form-control fw-semibold text-dark shadow-none"
                                                style="height: 40px; font-size: 13.5px; width: 145px; cursor: pointer; border-radius: 8px; border: 1px solid #cbd5e1; background-color: #f8fafc;"
                                                value="${selectedDate != 'all' ? selectedDate : ''}"
                                                title="Chọn ngày khám">
                                        </div>

                                        <!-- Nút Tra cứu & Nút Tải lại -->
                                        <div class="d-flex align-items-center gap-2">
                                            <button type="submit"
                                                class="btn btn-teal px-3.5 text-nowrap d-flex align-items-center justify-content-center gap-1.5 shadow-sm"
                                                style="height: 40px; font-weight: 600;">
                                                <i class="bi bi-search"></i>
                                                <span>Tra cứu</span>
                                            </button>
                                            <a href="${pageContext.request.contextPath}/staff/waiting-list"
                                                class="btn btn-outline-secondary px-3 text-nowrap d-flex align-items-center justify-content-center gap-1.5 shadow-sm"
                                                style="height: 40px; font-weight: 500; border-radius: 8px;"
                                                title="Tải lại danh sách">
                                                <i class="bi bi-arrow-clockwise"></i>
                                                <span>Tải lại</span>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </form>

                            <!-- Thanh điều hướng Tab trạng thái -->
                            <div
                                class="px-3 pt-3 pb-2 bg-light border-bottom d-flex align-items-center justify-content-between flex-wrap gap-2">
                                <div class="d-flex align-items-center gap-2 flex-wrap">
                                    <a href="${pageContext.request.contextPath}/staff/waiting-list?date=${selectedDate}&status=all&doctorId=${selectedDoctorId}&keyword=${param.keyword}"
                                        class="btn btn-sm ${selectedStatus == 'all' || empty selectedStatus ? 'btn-dark fw-bold shadow-sm' : 'btn-white border text-secondary'} rounded-pill px-3">
                                        <i class="bi bi-people-fill me-1"></i> Tất cả hàng đợi (${totalQueue})
                                    </a>
                                    <a href="${pageContext.request.contextPath}/staff/waiting-list?date=${selectedDate}&status=Confirmed&doctorId=${selectedDoctorId}&keyword=${param.keyword}"
                                        class="btn btn-sm ${selectedStatus == 'Confirmed' ? 'btn-warning text-dark fw-bold shadow-sm' : 'btn-white border text-secondary'} rounded-pill px-3">
                                        <i class="bi bi-hourglass-split me-1"></i> Chờ khám (${totalWaiting})
                                    </a>
                                    <a href="${pageContext.request.contextPath}/staff/waiting-list?date=${selectedDate}&status=In_Progress&doctorId=${selectedDoctorId}&keyword=${param.keyword}"
                                        class="btn btn-sm ${selectedStatus == 'In_Progress' ? 'btn-primary fw-bold shadow-sm' : 'btn-white border text-secondary'} rounded-pill px-3">
                                        <i class="bi bi-heart-pulse-fill me-1"></i> Đang khám (${totalExamining})
                                    </a>
                                    <a href="${pageContext.request.contextPath}/staff/waiting-list?date=${selectedDate}&status=Completed&doctorId=${selectedDoctorId}&keyword=${param.keyword}"
                                        class="btn btn-sm ${selectedStatus == 'Completed' ? 'btn-success fw-bold shadow-sm' : 'btn-white border text-secondary'} rounded-pill px-3">
                                        <i class="bi bi-check2-circle me-1"></i> Đã khám xong (${totalCompleted})
                                    </a>
                                </div>
                            </div>

                            <!-- Queue Table -->
                            <div class="table-container">
                                <table class="custom-table" style="table-layout: fixed; width: 100%;">
                                    <colgroup>
                                        <col style="width: 55px;">
                                        <col style="width: 105px;">
                                        <col style="width: 17%;">
                                        <col style="width: 13%;">
                                        <col style="width: 16%;">
                                        <col style="width: 16%;">
                                        <col style="width: 120px;">
                                        <col style="width: 175px;">
                                    </colgroup>
                                    <thead>
                                        <tr>
                                            <th class="text-center text-nowrap" style="width: 55px;">STT</th>
                                            <th class="text-center text-nowrap" style="width: 105px;" data-appointment-id-sort aria-sort="none">
                                                <button type="button" class="btn btn-link p-0 text-reset text-decoration-none fw-semibold text-nowrap" style="font: inherit;" title="Sắp xếp theo mã hẹn">
                                                    Mã Hẹn <i class="bi bi-arrow-down-up" aria-hidden="true"></i>
                                                </button>
                                            </th>
                                            <th class="text-nowrap" style="width: 17%;">Bệnh Nhân</th>
                                            <th class="text-nowrap" style="width: 13%;">Ca Khám</th>
                                            <th class="text-nowrap" style="width: 16%;">Bác Sĩ</th>
                                            <th class="text-nowrap" style="width: 16%;">Phòng Khám</th>
                                            <th class="text-center text-nowrap" style="width: 120px;">Trạng Thái</th>
                                            <th class="text-center text-nowrap" style="width: 175px;">Thao Tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${not empty waitingList}">
                                                <c:set var="currentDateStr">
                                                    <%= java.time.LocalDate.now().toString() %>
                                                </c:set>
                                                <c:forEach var="appt" items="${waitingList}">
                                                    <c:set var="apptDateStr">${appt.appointmentDate}</c:set>
                                                    <c:set var="isPastAppt"
                                                        value="${not empty apptDateStr && apptDateStr < currentDateStr}" />
                                                    <tr data-appointment-id="${appt.id}" class="${appt.status == 'In_Progress' ? 'row-examining' : ''}">
                                                        <!-- STT / Queue Number -->
                                                        <td class="text-center">
                                                            <div
                                                                class="queue-badge ${appt.status == 'In_Progress' ? 'queue-badge-active' : ''}">
                                                                #${appt.queueNumber}
                                                            </div>
                                                        </td>

                                                        <!-- Mã Hẹn -->
                                                        <td class="text-center text-nowrap">
                                                            <span class="fw-bold text-dark">#APT-${appt.id}</span>
                                                        </td>

                                                        <!-- Bệnh Nhân -->
                                                        <td>
                                                            <div class="patient-name-title text-truncate">
                                                                <a href="${pageContext.request.contextPath}/staff/appointment-detail?id=${appt.id}"
                                                                    class="text-decoration-none text-dark hover-teal"
                                                                    title="${appt.patientName}">
                                                                    ${appt.patientName}
                                                                </a>
                                                            </div>
                                                            <div class="patient-sub-text">
                                                                <i
                                                                    class="bi bi-telephone text-muted me-1"></i>${appt.phone}
                                                            </div>
                                                        </td>

                                                        <!-- Ca Khám (Thời gian từ mấy giờ đến mấy giờ) -->
                                                        <td class="text-nowrap">
                                                            <div class="fw-semibold text-dark d-flex align-items-center gap-1.5"
                                                                style="font-size: 13px;">
                                                                <i class="bi bi-clock-fill"
                                                                    style="color: var(--primary-color, #0d9488); font-size: 13px;"></i>
                                                                <span>
                                                                    <c:choose>
                                                                        <c:when
                                                                            test="${not empty appt.timeSlot && not empty appt.endTime}">
                                                                            ${appt.timeSlot} - ${appt.endTime}
                                                                        </c:when>
                                                                        <c:when test="${not empty appt.timeSlot}">
                                                                            ${appt.timeSlot}
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            --:--
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </span>
                                                            </div>
                                                            <c:if
                                                                test="${not empty appt.slotName && !fn:containsIgnoreCase(appt.slotName, 'Slot Khám')}">
                                                                <div class="text-muted small mt-0.5"
                                                                    style="font-size: 11px; padding-left: 17px;">
                                                                    ${appt.slotName}
                                                                </div>
                                                            </c:if>
                                                        </td>

                                                        <!-- Bác Sĩ -->
                                                        <td>
                                                            <div class="fw-semibold text-dark text-truncate"
                                                                title="${not empty appt.doctorName ? appt.doctorName : 'Chưa phân công'}">
                                                                ${not empty appt.doctorName ? appt.doctorName : 'Chưa
                                                                phân công'}
                                                            </div>
                                                            <c:if test="${not empty appt.department}">
                                                                <div class="text-muted small text-truncate"
                                                                    style="font-size: 11.5px;"
                                                                    title="${appt.department}">
                                                                    ${appt.department}
                                                                </div>
                                                            </c:if>
                                                        </td>

                                                        <!-- Phòng Khám -->
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${not empty appt.roomName}">
                                                                    <span
                                                                        class="badge bg-light text-dark border px-2 py-1 fw-semibold text-wrap text-start"
                                                                        style="font-size: 12px; line-height: 1.35;"
                                                                        title="${appt.roomName}">
                                                                        <i
                                                                            class="bi bi-door-open text-success me-1"></i>${appt.roomName}
                                                                    </span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="text-muted small">Chưa xếp phòng</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>


                                                        <!-- Trạng Thái Hiện Tại (Thống nhất tiếng Việt & màu sắc) -->
                                                        <td class="text-center text-nowrap">
                                                            <c:choose>
                                                                <c:when test="${appt.status == 'Pending'}">
                                                                    <span class="badge-status badge-pending"
                                                                        title="Chờ tiếp đón tại quầy lễ tân">
                                                                        Chờ tiếp đón
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${appt.status == 'Confirmed'}">
                                                                    <span class="badge-status badge-confirmed"
                                                                        title="Đã tiếp đón, đang chờ vào khám">
                                                                        Chờ khám
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${appt.status == 'In_Progress' || (appt.status == 'Completed' && appt.hasSurgery && !appt.surgeryPaid)}">
                                                                    <span class="badge-status badge-in-progress"
                                                                        title="${appt.status == 'Completed' ? 'Được chỉ định phẫu thuật - Đang chờ xác nhận thanh toán tại Quản lý thanh toán' : 'Bác sĩ đang thực hiện khám'}">
                                                                        Đang khám
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${appt.status == 'Completed'}">
                                                                    <span class="badge-status badge-completed"
                                                                        title="Ca khám đã hoàn thành">
                                                                        <i class="bi bi-check2-circle me-1"></i>Hoàn thành
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${appt.status == 'Canceled'}">
                                                                    <span class="badge-status badge-canceled"
                                                                        title="${not empty appt.reason ? appt.reason : 'Lịch hẹn đã hủy'}">
                                                                        Đã hủy
                                                                    </span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge-status badge-pending">
                                                                        ${appt.status}
                                                                    </span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>

                                                        <!-- Thao Tác (Khi đã qua ngày: chỉ cho phép xem thông tin hồ sơ chi tiết) -->
                                                        <td class="text-center text-nowrap">
                                                            <div class="action-btns justify-content-center">
                                                                <!-- 1. Xem chi tiết / Hồ sơ bệnh nhân -->
                                                                <a href="${pageContext.request.contextPath}/staff/appointment-detail?id=${appt.id}"
                                                                    class="action-btn"
                                                                    title="Xem chi tiết & ghi chú y tế "
                                                                    data-bs-toggle="tooltip">
                                                                    <i class="bi bi-pencil"></i>
                                                                </a>

                                                                <!-- 2. Khi ca đang chờ khám (Confirmed) và chưa qua ngày: Nút Bỏ qua lượt -->
                                                                <c:if test="${!isPastAppt && appt.status == 'Confirmed'}">
                                                                    <button type="button"
                                                                        class="action-btn warning btn-trigger-skip"
                                                                        title="Bỏ qua lượt: Đổi ca khám với lượt tiếp theo sau mình"
                                                                        data-bs-toggle="tooltip" data-id="${appt.id}"
                                                                        data-name="${appt.patientName}">
                                                                        <i class="bi bi-arrow-down-circle"></i>
                                                                    </button>
                                                                </c:if>

                                                            </div>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr>
                                                    <td colspan="8" class="text-center py-5">
                                                        <div class="text-muted">
                                                            <c:choose>
                                                                <c:when test="${selectedStatus == 'Confirmed'}">
                                                                    <i
                                                                        class="bi bi-hourglass-split fs-1 d-block mb-2 text-warning"></i>
                                                                    <p class="mb-1 fw-semibold text-dark">Không có bệnh
                                                                        nhân nào đang chờ khám!</p>
                                                                    <p class="small text-muted">Tất cả bệnh nhân đã được
                                                                        gọi vào phòng khám hoặc chưa có ca tiếp đón mới.
                                                                    </p>
                                                                </c:when>
                                                                <c:when test="${selectedStatus == 'In_Progress'}">
                                                                    <i
                                                                        class="bi bi-heart-pulse fs-1 d-block mb-2 text-primary"></i>
                                                                    <p class="mb-1 fw-semibold text-dark">Hiện không có
                                                                        ca nào đang khám trong phòng!</p>
                                                                    <p class="small text-muted">Bác sĩ chưa gọi bệnh
                                                                        nhân nào vào phòng khám.</p>
                                                                </c:when>
                                                                <c:when test="${selectedStatus == 'Completed'}">
                                                                    <i
                                                                        class="bi bi-check2-circle fs-1 d-block mb-2 text-success"></i>
                                                                    <p class="mb-1 fw-semibold text-dark">Chưa có ca
                                                                        khám nào hoàn tất!</p>
                                                                    <p class="small text-muted">Các ca sau khi hoàn tất
                                                                        khám hôm nay sẽ được hiển thị tại đây.</p>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <i
                                                                        class="bi bi-people fs-1 d-block mb-2 text-secondary"></i>
                                                                    <p class="mb-1 fw-semibold text-dark">Hiện tại hàng
                                                                        đợi đang trống</p>
                                                                    <p class="small text-muted">Chưa có bệnh nhân nào
                                                                        được check-in trong ngày hôm nay.</p>
                                                                    <a href="${pageContext.request.contextPath}/staff/appointments"
                                                                        class="btn btn-teal btn-sm mt-3 px-3.5 py-2 text-nowrap d-inline-flex align-items-center gap-2 shadow-sm"
                                                                        style="width: auto; text-decoration: none;">
                                                                        <i class="bi bi-search"></i>
                                                                        <span>Kiểm tra Danh sách Lịch hẹn</span>
                                                                    </a>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                            </div>

                            <!-- Footer Info -->
                            <div
                                class="p-3 border-top bg-light d-flex justify-content-between align-items-center small text-muted">
                                <div>Tổng số trong hàng đợi: <strong>${waitingList.size()}</strong> bệnh nhân</div>
                                <div>Tự động tải lại: <strong>Bật</strong></div>
                            </div>
                        </div>

                    </div>
                </main>




                <!-- Modal Bỏ Qua Lượt / Đổi lượt với ca tiếp theo sau mình -->
                <div class="modal fade" id="skipModal" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered" style="max-width: 440px;">
                        <div class="modal-content">
                            <div class="modal-header">
                                <button type="button" class="btn-close" data-bs-dismiss="modal"
                                    aria-label="Close"></button>
                            </div>
                            <div class="modal-body">
                                <div class="modal-icon-warning">
                                    <i class="bi bi-arrow-down-circle"></i>
                                </div>
                                <h3 class="modal-title-custom">Bỏ qua lượt khám?</h3>
                                <p class="modal-text mb-3">
                                    Bệnh nhân <strong id="skipModalPatientName" class="text-dark">---</strong> (<span id="skipModalApptCode" class="fw-bold text-secondary">#APT-0</span>) sẽ <strong>chuyển đổi ca khám với lượt tiếp theo sau mình</strong> để nhường lượt cho bệnh nhân kế tiếp vào phòng khám.
                                </p>
                                <form action="${pageContext.request.contextPath}/staff/waiting-list" method="post"
                                    id="skipForm" class="m-0">
                                    <input type="hidden" name="action" value="skip">
                                    <input type="hidden" name="appointmentId" id="skipModalAppointmentId">
                                    <input type="hidden" name="returnUrl"
                                        value="${pageContext.request.contextPath}/staff/waiting-list${not empty pageContext.request.queryString ? '?'.concat(pageContext.request.queryString) : ''}">
                                    <div class="modal-actions">
                                        <button type="button" class="btn btn-modal-cancel"
                                            data-bs-dismiss="modal">Hủy</button>
                                        <button type="submit" class="btn btn-modal-warning">
                                            <i class="bi bi-arrow-down-circle me-1"></i> Đổi lượt ca sau
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Bootstrap 5 JS -->
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
                <script src="${pageContext.request.contextPath}/assets/js/appointment-id-sort.js"></script>
                <script>


                    function openSkipModal(id, name) {
                        var idInput = document.getElementById('skipModalAppointmentId');
                        if (idInput) idInput.value = id;
                        var nameElem = document.getElementById('skipModalPatientName');
                        if (nameElem) nameElem.textContent = name || 'này';
                        var codeElem = document.getElementById('skipModalApptCode');
                        if (codeElem) codeElem.textContent = '#APT-' + id;
                        var modalElem = document.getElementById('skipModal');
                        if (modalElem) {
                            var modal = bootstrap.Modal.getInstance(modalElem) || new bootstrap.Modal(modalElem);
                            modal.show();
                        }
                    }


                    function showToast(message, type) {
                        var container = document.getElementById('toastNotificationContainer');
                        if (!container) return;
                        var isSuccess = (type === 'success');
                        var toastId = 'toast_' + Date.now();
                        var bgClass = isSuccess ? 'bg-success text-white' : 'bg-danger text-white';
                        var icon = isSuccess ? 'bi-check-circle-fill' : 'bi-exclamation-circle-fill';
                        var html = '<div id="' + toastId + '" class="toast align-items-center ' + bgClass + ' border-0 shadow-lg" role="alert" aria-live="assertive" aria-atomic="true">'
                            + '  <div class="d-flex">'
                            + '    <div class="toast-body d-flex align-items-center gap-2 fs-6 py-2.5 px-3">'
                            + '      <i class="bi ' + icon + ' fs-5"></i>'
                            + '      <span>' + message + '</span>'
                            + '    </div>'
                            + '    <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>'
                            + '  </div>'
                            + '</div>';
                        container.insertAdjacentHTML('beforeend', html);
                        var toastElem = document.getElementById(toastId);
                        if (toastElem && window.bootstrap && bootstrap.Toast) {
                            var bsToast = new bootstrap.Toast(toastElem, { delay: 4500 });
                            bsToast.show();
                            toastElem.addEventListener('hidden.bs.toast', function () {
                                toastElem.remove();
                            });
                        }
                    }

                    document.addEventListener('click', function (e) {
                        var btnSkip = e.target.closest('.btn-trigger-skip');
                        if (btnSkip) {
                            var id = btnSkip.getAttribute('data-id');
                            var name = btnSkip.getAttribute('data-name');
                            openSkipModal(id, name);
                            return;
                        }
                    });

                    // Smart auto-refresh waiting list every 15 seconds when on current day and no modal is active
                    setInterval(function () {
                        var isModalOpen = document.querySelector('.modal.show');
                        var isInputFocused = document.activeElement && (document.activeElement.tagName === 'INPUT' || document.activeElement.tagName === 'TEXTAREA');
                        if (document.visibilityState === 'visible' && !isModalOpen && !isInputFocused) {
                            window.location.reload();
                        }
                    }, 15000);
                </script>

                <!-- Toast Container for Clean Notifications -->
                <div id="toastNotificationContainer" class="toast-container position-fixed top-0 end-0 p-3"
                    style="z-index: 2050;"></div>
            </body>

            </html>