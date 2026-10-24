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
                                            <th class="text-center text-nowrap" style="width: 105px;">Mã Hẹn</th>
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
                                                    <tr class="${appt.status == 'In_Progress' ? 'row-examining' : ''}">
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
                                                                <c:when test="${appt.status == 'In_Progress'}">
                                                                    <span class="badge-status badge-in-progress"
                                                                        title="Bác sĩ đang thực hiện khám">
                                                                        Đang khám
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${appt.status == 'Completed'}">
                                                                    <span class="badge-status badge-completed"
                                                                        title="Ca khám đã hoàn thành">
                                                                        Đã khám xong
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${appt.status == 'Canceled'}">
                                                                    <span class="badge-status badge-canceled"
                                                                        title="${not empty appt.reason ? appt.reason : 'Lịch hẹn đã hủy / vắng mặt'}">
                                                                        Đã hủy / Vắng mặt
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

                                                                <!-- 3. Khi Bác sĩ / Bác sĩ tiểu phẫu đã hoàn tất ca khám & in phiếu khám (Completed): Hiển thị nút Xem phiếu khám để Lễ tân kiểm tra -->
                                                                <c:if test="${appt.status == 'Completed'}">
                                                                    <!-- Xem phiếu khám & đơn thuốc -->
                                                                    <button type="button"
                                                                        class="action-btn medical-notes btn-trigger-post-exam"
                                                                        title="Bác sĩ đã hoàn tất ca khám. Bấm để xem phiếu khám & đơn thuốc"
                                                                        data-bs-toggle="tooltip"
                                                                        data-id="${appt.id}"
                                                                        data-name="${appt.patientName}">
                                                                        <i class="bi bi-file-earmark-medical"></i>
                                                                    </button>

                                                                    <!-- Nếu còn nợ viện phí / thuốc / thủ thuật: Nút thu phí nhanh -->
                                                                    <c:if test="${appt.balanceDue > 0}">
                                                                        <button type="button"
                                                                            class="action-btn warning btn-trigger-post-exam"
                                                                            title="Còn nợ viện phí. Bấm để thu viện phí còn lại & hoàn tất lịch hẹn."
                                                                            data-bs-toggle="tooltip" data-id="${appt.id}"
                                                                            data-name="${appt.patientName}">
                                                                            <i class="bi bi-cash-coin"></i>
                                                                        </button>
                                                                    </c:if>
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


                <!-- Modal Báo Vắng Mặt / Hủy ca khỏi hàng đợi -->
                <div class="modal fade" id="absentModal" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered" style="max-width: 440px;">
                        <div class="modal-content">
                            <div class="modal-header">
                                <button type="button" class="btn-close" data-bs-dismiss="modal"
                                    aria-label="Close"></button>
                            </div>
                            <div class="modal-body">
                                <div class="modal-icon-danger">
                                    <i class="bi bi-person-x"></i>
                                </div>
                                <h3 class="modal-title-custom">Xác nhận báo vắng mặt?</h3>
                                <p class="modal-text mb-3">
                                    Bệnh nhân <strong id="absentModalPatientName" class="text-dark">---</strong> (<span id="absentModalApptCode" class="fw-bold text-secondary">#APT-0</span>) sẽ được ghi nhận vắng mặt và gỡ khỏi hàng đợi hôm nay.
                                </p>
                                <form action="${pageContext.request.contextPath}/staff/waiting-list" method="post" id="absentForm" class="m-0 text-start">
                                    <input type="hidden" name="action" value="absent">
                                    <input type="hidden" name="appointmentId" id="absentModalAppointmentId">
                                    <input type="hidden" name="returnUrl" value="${pageContext.request.contextPath}/staff/waiting-list${not empty pageContext.request.queryString ? '?'.concat(pageContext.request.queryString) : ''}">
                                    
                                    <div class="mb-3">
                                        <label class="form-label small fw-semibold text-dark mb-1.5">
                                            Lý do vắng mặt <span class="text-danger">*</span>
                                        </label>
                                        <select name="cancelReasonSelect" id="absentReasonSelect" class="form-select form-select-sm shadow-none mb-2" style="border-radius: 8px; font-size: 13.5px;" onchange="toggleAbsentReason(this)">
                                            <option value="Gọi tên nhiều lần không có mặt / Không vào phòng khám">Gọi tên nhiều lần không có mặt / Không vào phòng khám</option>
                                            <option value="Bệnh nhân tự ý bỏ về trước khi đến lượt khám">Bệnh nhân tự ý bỏ về trước khi đến lượt khám</option>
                                            <option value="Bệnh nhân báo bận đột xuất, xin dời sang ngày khác">Bệnh nhân báo bận đột xuất, xin dời sang ngày khác</option>
                                            <option value="other">Lý do khác (Nhập ghi chú)...</option>
                                        </select>
                                        <textarea name="cancelReasonCustom" id="absentReasonCustom" class="form-control form-control-sm shadow-none d-none" rows="2" placeholder="Nhập lý do chi tiết..." style="border-radius: 8px; font-size: 13px;"></textarea>
                                    </div>


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

                <!-- Modal Xem Phiếu Khám Bệnh & Ghi Chú Y Tế -->
                <div class="modal fade" id="postExamModal" tabindex="-1" aria-labelledby="postExamModalLabel"
                    aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered modal-lg" style="max-width: 760px;">
                        <div class="modal-content shadow border-0" style="border-radius: 16px; overflow: hidden;">
                            <div class="modal-header border-bottom px-4 py-3 bg-light">
                                <div class="d-flex align-items-center gap-2.5">
                                    <div
                                        style="width: 40px; height: 40px; border-radius: 10px; background: rgba(13, 148, 136, 0.12); color: #0d9488; display: flex; align-items: center; justify-content: center; font-size: 20px;">
                                        <i class="bi bi-file-earmark-medical"></i>
                                    </div>
                                    <div>
                                        <h5 class="modal-title fw-bold text-dark mb-0" id="postExamModalLabel"
                                            style="font-size: 16.5px;">Phiếu Khám Bệnh & Ghi Chú Y Tế</h5>
                                        <small class="text-secondary" style="font-size: 12px;"
                                            id="postExamSubtitle">Bệnh nhân: --- | BS: ---</small>
                                    </div>
                                </div>
                                <button type="button" class="btn-close shadow-none" data-bs-dismiss="modal"
                                    aria-label="Close"></button>
                            </div>

                            <div class="modal-body p-4" id="postExamModalBody">
                                <!-- Hộp thông báo / cảnh báo trong modal -->
                                <div id="postExamAlertBox"
                                    class="alert alert-danger py-2.5 px-3 small rounded-3 mb-3 d-flex align-items-center gap-2 shadow-sm d-none"
                                    style="font-size: 13px;"></div>

                                <!-- Loading State -->
                                <div id="postExamLoading" class="text-center py-5">
                                    <div class="spinner-border text-teal mb-2" role="status"
                                        style="width: 2.5rem; height: 2.5rem; color: #0d9488;"></div>
                                    <p class="text-secondary small mb-0">Đang tải thông tin phiếu khám và kết quả từ bác
                                        sĩ...</p>
                                </div>

                                <!-- Content State -->
                                <div id="postExamContent" class="d-none">
                                    <!-- Banner trạng thái ca khám -->
                                    <div class="alert alert-success py-2.5 px-3 rounded-3 mb-3 d-flex align-items-center justify-content-between"
                                        style="font-size: 13px;" id="postExamStatusBanner">
                                        <div class="d-flex align-items-center gap-2">
                                            <i class="bi bi-check-circle-fill fs-5 text-success"
                                                id="postExamBannerIcon"></i>
                                            <div>
                                                <strong class="text-success" id="postExamBannerText">Bác sĩ đã hoàn tất
                                                    ca khám</strong>
                                                <div class="text-secondary" style="font-size: 11.5px;"
                                                    id="postExamBannerSub">Đã có kết luận khám bệnh và đơn thuốc. Sẵn
                                                    sàng thanh toán và hoàn tất lịch hẹn.</div>
                                            </div>
                                        </div>
                                        <span class="badge bg-success px-2.5 py-1.5 fw-semibold"
                                            style="font-size: 11.5px;" id="postExamBannerBadge">Đã khám xong</span>
                                    </div>

                                    <!-- 1. Ghi chú y tế ban đầu (Lễ tân ghi nhận khi tiếp đón) -->
                                    <div class="card border rounded-3 mb-3 shadow-none bg-light"
                                        id="postExamInitialNotesCard">
                                        <div class="card-body p-3">
                                            <h6 class="fw-bold text-dark mb-1.5 d-flex align-items-center gap-1.5"
                                                style="font-size: 13.5px;">
                                                <i class="bi bi-journal-medical text-teal" style="color: #0d9488;"></i>
                                                Ghi chú y tế ban đầu (Lễ tân ghi nhận khi tiếp đón)
                                            </h6>
                                            <div id="postExamInitialNotes"
                                                class="bg-white p-2.5 rounded border mt-1 text-dark small"
                                                style="font-size: 12.5px; line-height: 1.5;">
                                                Chưa có ghi chú y tế ban đầu.
                                            </div>
                                        </div>
                                    </div>

                                    <!-- 2. Chẩn đoán & Kết luận của Bác sĩ -->
                                    <div class="card border rounded-3 mb-3 shadow-none bg-light">
                                        <div class="card-body p-3">
                                            <h6 class="fw-bold text-dark mb-2 d-flex align-items-center gap-1.5"
                                                style="font-size: 13.5px;">
                                                <i class="bi bi-activity text-teal" style="color: #0d9488;"></i> Chẩn
                                                đoán & Lời dặn của Bác sĩ
                                            </h6>
                                            <div class="row g-2 text-dark small" style="font-size: 12.5px;">
                                                <div class="col-sm-6">
                                                    <span class="text-muted d-block" style="font-size: 11.5px;">Chẩn
                                                        đoán lâm sàng:</span>
                                                    <strong id="postExamDiagnosis" class="text-primary">---</strong>
                                                </div>
                                                <div class="col-sm-6">
                                                    <span class="text-muted d-block" style="font-size: 11.5px;">Bác sĩ
                                                        phụ trách:</span>
                                                    <span id="postExamDoctor" class="fw-semibold">---</span>
                                                </div>
                                                <div class="col-12 mt-2 pt-2 border-top">
                                                    <span class="text-muted d-block" style="font-size: 11.5px;">Lời dặn
                                                        của bác sĩ:</span>
                                                    <div id="postExamDoctorNotes"
                                                        class="fst-italic text-secondary bg-white p-2 rounded border mt-1">
                                                        ---</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- 3. Danh sách đơn thuốc do Bác sĩ kê -->
                                    <div class="card border rounded-3 mb-3 shadow-none">
                                        <div
                                            class="card-header bg-white py-2.5 px-3 border-bottom d-flex align-items-center justify-content-between">
                                            <span class="fw-bold text-dark small d-flex align-items-center gap-1.5"
                                                style="font-size: 13.5px;">
                                                <i class="bi bi-capsule text-primary"></i> Đơn thuốc do Bác sĩ kê
                                            </span>
                                            <span
                                                class="badge bg-primary-subtle text-primary border border-primary-subtle"
                                                id="postExamMedCount">0 loại thuốc</span>
                                        </div>
                                        <div class="table-responsive">
                                            <table class="table table-sm table-hover mb-0 align-middle"
                                                style="font-size: 12.5px;">
                                                <thead class="table-light">
                                                    <tr>
                                                        <th style="width: 40px;" class="text-center">#</th>
                                                        <th>Tên thuốc</th>
                                                        <th style="width: 100px;" class="text-center">Số lượng</th>
                                                        <th>Hướng dẫn dùng thuốc</th>
                                                    </tr>
                                                </thead>
                                                <tbody id="postExamMedicineList">
                                                    <tr>
                                                        <td colspan="4" class="text-center text-muted py-2">Bác sĩ chưa
                                                            kê đơn thuốc cho ca khám này</td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>

                                    <!-- 4. Cận lâm sàng / Thủ thuật (nếu có) -->
                                    <div id="postExamProceduresBox"
                                        class="card border rounded-3 mb-3 shadow-none d-none">
                                        <div class="card-header bg-white py-2 px-3 border-bottom">
                                            <span class="fw-bold text-dark small d-flex align-items-center gap-1.5"
                                                style="font-size: 13px;">
                                                <i class="bi bi-tools text-warning"></i> Cận lâm sàng & Dịch vụ đã thực
                                                hiện
                                            </span>
                                        </div>
                                        <div class="table-responsive">
                                            <table class="table table-sm mb-0 align-middle" style="font-size: 12px;">
                                                <tbody id="postExamProcedureList"></tbody>
                                            </table>
                                        </div>
                                    </div>

                                    <!-- 5. Tình trạng viện phí & Thanh toán phần còn lại tại quầy Lễ tân -->
                                    <div class="card border rounded-3 mb-3 shadow-none bg-light">
                                        <div
                                            class="card-header bg-white py-2 px-3 border-bottom d-flex align-items-center justify-content-between">
                                            <span class="fw-bold text-dark small d-flex align-items-center gap-1.5"
                                                style="font-size: 13px;">
                                                <i class="bi bi-receipt text-teal" style="color: #0d9488;"></i> Viện Phí
                                                & Thanh Toán Tại Quầy Lễ Tân
                                            </span>
                                            <span
                                                class="badge bg-success-subtle text-success border border-success-subtle py-1 px-2 fw-semibold"
                                                id="postExamInvoiceStatus">
                                                <i class="bi bi-check-circle me-1"></i>Đã thanh toán (Paid)
                                            </span>
                                        </div>
                                        <div class="card-body p-3">
                                            <!-- Bảng 3 ô tổng quan viện phí -->
                                            <div class="row g-2 mb-3">
                                                <div class="col-4">
                                                    <div class="bg-white p-2.5 rounded-2 border text-center">
                                                        <div class="text-secondary small" style="font-size: 11.5px;">
                                                            Tổng chi phí:</div>
                                                        <strong class="text-dark fs-6" id="postExamTotalAmount">200.000
                                                            ₫</strong>
                                                    </div>
                                                </div>
                                                <div class="col-4">
                                                    <div class="bg-white p-2.5 rounded-2 border text-center">
                                                        <div class="text-secondary small" style="font-size: 11.5px;">Đã
                                                            thanh toán (Cọc):</div>
                                                        <strong class="text-success fs-6"
                                                            id="postExamDepositAmount">200.000 ₫</strong>
                                                    </div>
                                                </div>
                                                <div class="col-4">
                                                    <div class="bg-white p-2.5 rounded-2 border text-center"
                                                        id="postExamBalanceDueBox">
                                                        <div class="text-secondary small" style="font-size: 11.5px;">
                                                            Phần còn lại phải thu:</div>
                                                        <strong class="text-danger fs-6" id="postExamBalanceDue">0
                                                            ₫</strong>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Khung chọn hình thức thanh toán khi Balance Due > 0 -->
                                            <div id="postExamPaymentSelectionBox"
                                                class="p-2.5 rounded-2 border bg-warning-subtle text-dark small d-none"
                                                style="font-size: 12.5px;">
                                                <div class="d-flex align-items-center justify-content-between mb-2">
                                                    <span
                                                        class="fw-bold text-warning-emphasis d-flex align-items-center gap-1">
                                                        <i class="bi bi-exclamation-triangle-fill text-warning"></i> Cần
                                                        thu phần còn lại:
                                                    </span>
                                                    <strong class="text-danger fs-6" id="postExamBalanceDueNotice">0
                                                        ₫</strong>
                                                </div>
                                                <div class="text-secondary small mb-2">Chọn phương thức thanh toán tại
                                                    quầy lễ tân:</div>
                                                <div class="d-flex align-items-center gap-3">
                                                    <div class="form-check">
                                                        <input class="form-check-input" type="radio"
                                                            name="postExamPaymentGateway" id="payMethodCash"
                                                            value="Cash" checked>
                                                        <label class="form-check-label fw-semibold" for="payMethodCash">
                                                            <i class="bi bi-cash-stack text-success me-1"></i> Tiền mặt
                                                            tại quầy (Cash)
                                                        </label>
                                                    </div>
                                                    <div class="form-check">
                                                        <input class="form-check-input" type="radio"
                                                            name="postExamPaymentGateway" id="payMethodVietQR"
                                                            value="VietQR_Banking">
                                                        <label class="form-check-label fw-semibold"
                                                            for="payMethodVietQR">
                                                            <i class="bi bi-qr-code text-primary me-1"></i> Quét mã QR
                                                            (VietQR Banking)
                                                        </label>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Thông báo khi đã thanh toán đủ -->
                                            <div id="postExamFullyPaidNotice"
                                                class="text-success small d-flex align-items-center gap-1.5 py-1">
                                                <i class="bi bi-check-circle-fill"></i>
                                                <span>Bệnh nhân đã thanh toán đầy đủ viện phí. Không còn khoản thu phát
                                                    sinh.</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="modal-footer px-4 py-3 bg-light border-top d-flex justify-content-between">
                                <div>
                                    <small class="text-muted" style="font-size: 12px;" id="postExamFooterNote">
                                        <i class="bi bi-info-circle me-1"></i>Lễ tân kiểm tra phiếu khám và xác nhận
                                        hoàn tất sau khi thu viện phí.
                                    </small>
                                </div>
                                <div class="d-flex align-items-center gap-2">
                                    <button type="button" class="btn btn-light btn-sm px-3.5 py-1.5 border"
                                        data-bs-dismiss="modal">Đóng</button>
                                    <button type="button"
                                        class="btn btn-teal btn-sm px-3.5 py-1.5 fw-semibold shadow-sm"
                                        id="btnCompleteAppointment" onclick="submitCompleteAppointment()">
                                        <i class="bi bi-check2-circle me-1.5"></i> Hoàn tất lịch hẹn
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Bootstrap 5 JS -->
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
                <script>

                    function openAbsentModal(id, name) {
                        var idInput = document.getElementById('absentModalAppointmentId');
                        if (idInput) idInput.value = id;
                        var nameElem = document.getElementById('absentModalPatientName');
                        if (nameElem) nameElem.textContent = name || 'này';
                        var codeElem = document.getElementById('absentModalApptCode');
                        if (codeElem) codeElem.textContent = '#APT-' + id;
                        var selectElem = document.getElementById('absentReasonSelect');
                        if (selectElem) selectElem.value = 'Gọi tên nhiều lần không có mặt / Không vào phòng khám';
                        var customElem = document.getElementById('absentReasonCustom');
                        if (customElem) {
                            customElem.classList.add('d-none');
                            customElem.value = '';
                        }
                        var modalElem = document.getElementById('absentModal');
                        if (modalElem) {
                            var modal = bootstrap.Modal.getInstance(modalElem) || new bootstrap.Modal(modalElem);
                            modal.show();
                        }
                    }

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

                    var currentPostExamId = null;
                    function openPostExamModal(id, name) {
                        currentPostExamId = id;
                        var subElem = document.getElementById('postExamSubtitle');
                        if (subElem) subElem.textContent = 'Bệnh nhân: ' + (name || '---') + ' (#APT-' + id + ')';

                        var alertBox = document.getElementById('postExamAlertBox');
                        if (alertBox) {
                            alertBox.classList.add('d-none');
                            alertBox.innerHTML = '';
                        }

                        var loading = document.getElementById('postExamLoading');
                        var content = document.getElementById('postExamContent');
                        if (loading) loading.classList.remove('d-none');
                        if (content) content.classList.add('d-none');

                        var modalElem = document.getElementById('postExamModal');
                        if (modalElem) {
                            var modal = bootstrap.Modal.getInstance(modalElem) || new bootstrap.Modal(modalElem);
                            modal.show();
                        }

                        fetch('${pageContext.request.contextPath}/staff/waiting-list?ajax=postExamDetail&appointmentId=' + id)
                            .then(function (res) { return res.json(); })
                            .then(function (data) {
                                if (data && data.success) {
                                    window._currentPostExamData = data;

                                    // 1. Cập nhật Banner trạng thái
                                    var bannerElem = document.getElementById('postExamStatusBanner');
                                    var bannerText = document.getElementById('postExamBannerText');
                                    var bannerSub = document.getElementById('postExamBannerSub');
                                    var bannerBadge = document.getElementById('postExamBannerBadge');
                                    var bannerIcon = document.getElementById('postExamBannerIcon');
                                    if (data.status === 'Completed') {
                                        if (bannerElem) bannerElem.className = 'alert alert-success py-2.5 px-3 rounded-3 mb-3 d-flex align-items-center justify-content-between';
                                        if (bannerIcon) bannerIcon.className = 'bi bi-check-circle-fill fs-5 text-success';
                                        if (bannerText) {
                                            bannerText.className = 'text-success';
                                            bannerText.textContent = 'Bác sĩ đã hoàn tất ca khám';
                                        }
                                        if (bannerSub) bannerSub.textContent = (data.balanceDue > 0) ? 'Đã có kết luận khám bệnh và đơn thuốc. Cần thu phần viện phí còn lại để hoàn tất lịch hẹn.' : 'Đã có kết luận khám bệnh và đơn thuốc. Viện phí đã thanh toán đủ.';
                                        if (bannerBadge) {
                                            bannerBadge.className = 'badge bg-success px-2.5 py-1.5 fw-semibold';
                                            bannerBadge.textContent = 'Đã khám xong';
                                        }
                                    } else if (data.status === 'In_Progress') {
                                        if (bannerElem) bannerElem.className = 'alert alert-primary py-2.5 px-3 rounded-3 mb-3 d-flex align-items-center justify-content-between';
                                        if (bannerIcon) bannerIcon.className = 'bi bi-heart-pulse-fill fs-5 text-primary';
                                        if (bannerText) {
                                            bannerText.className = 'text-primary';
                                            bannerText.textContent = 'Bác sĩ đang thực hiện ca khám';
                                        }
                                        if (bannerSub) bannerSub.textContent = (data.medicines && data.medicines.length > 0) ? 'Bác sĩ đã kê đơn thuốc cho bệnh nhân.' : 'Đang trong quá trình khám và kê đơn thuốc.';
                                        if (bannerBadge) {
                                            bannerBadge.className = 'badge bg-primary px-2.5 py-1.5 fw-semibold';
                                            bannerBadge.textContent = 'Đang khám';
                                        }
                                    } else {
                                        if (bannerElem) bannerElem.className = 'alert alert-secondary py-2.5 px-3 rounded-3 mb-3 d-flex align-items-center justify-content-between';
                                        if (bannerIcon) bannerIcon.className = 'bi bi-hourglass-split fs-5 text-secondary';
                                        if (bannerText) {
                                            bannerText.className = 'text-secondary';
                                            bannerText.textContent = 'Bệnh nhân đang chờ khám';
                                        }
                                        if (bannerSub) bannerSub.textContent = 'Ghi nhận ghi chú y tế ban đầu chuẩn bị cho bác sĩ tiếp nhận.';
                                        if (bannerBadge) {
                                            bannerBadge.className = 'badge bg-secondary px-2.5 py-1.5 fw-semibold';
                                            bannerBadge.textContent = 'Chờ khám';
                                        }
                                    }

                                    // 2. Ghi chú y tế ban đầu (tiếp đón)
                                    var initialNotesElem = document.getElementById('postExamInitialNotes');
                                    if (initialNotesElem) {
                                        if (data.medicalNotes && data.medicalNotes.trim().length > 0) {
                                            initialNotesElem.textContent = data.medicalNotes;
                                            initialNotesElem.className = 'bg-white p-2.5 rounded border mt-1 text-dark small';
                                        } else {
                                            initialNotesElem.textContent = 'Chưa có ghi chú y tế ban đầu khi tiếp đón.';
                                            initialNotesElem.className = 'bg-white p-2.5 rounded border mt-1 text-muted fst-italic small';
                                        }
                                    }

                                    // 3. Chẩn đoán & Lời dặn của bác sĩ
                                    var diagElem = document.getElementById('postExamDiagnosis');
                                    if (diagElem) diagElem.textContent = data.clinicalDiagnosis || 'Khám mắt tổng quát';

                                    var docElem = document.getElementById('postExamDoctor');
                                    if (docElem) docElem.textContent = (data.doctorName || 'Bác sĩ') + ' (' + (data.roomName || '') + ')';

                                    var notesElem = document.getElementById('postExamDoctorNotes');
                                    if (notesElem) notesElem.textContent = data.doctorNotes || 'Uống và nhỏ thuốc theo đúng hướng dẫn.';

                                    // 4. Danh sách đơn thuốc
                                    var medTbody = document.getElementById('postExamMedicineList');
                                    var medCount = document.getElementById('postExamMedCount');
                                    var hasPrescription = false;
                                    if (medTbody) {
                                        if (data.medicines && data.medicines.length > 0) {
                                            hasPrescription = true;
                                            if (medCount) medCount.textContent = data.medicines.length + ' loại thuốc';
                                            var rows = '';
                                            data.medicines.forEach(function (m, idx) {
                                                rows += '<tr>'
                                                    + '<td class="text-center text-muted fw-semibold">' + (idx + 1) + '</td>'
                                                    + '<td><strong class="text-dark">' + (m.name || '') + '</strong></td>'
                                                    + '<td class="text-center"><span class="badge bg-secondary-subtle text-secondary border px-2 py-1">' + (m.quantity || 1) + '</span></td>'
                                                    + '<td><span class="text-secondary">' + (m.dosageInstruction || 'Chưa cập nhật') + '</span></td>'
                                                    + '</tr>';
                                            });
                                            medTbody.innerHTML = rows;
                                        } else {
                                            if (medCount) medCount.textContent = '0 loại thuốc';
                                            medTbody.innerHTML = '<tr><td colspan="4" class="text-center text-muted py-3 fst-italic">Bác sĩ chưa kê đơn thuốc cho ca khám này.</td></tr>';
                                        }
                                    }

                                    // 5. Cận lâm sàng & Thủ thuật
                                    var procBox = document.getElementById('postExamProceduresBox');
                                    var procTbody = document.getElementById('postExamProcedureList');
                                    if (procBox && procTbody) {
                                        if (data.procedures && data.procedures.length > 0) {
                                            var pRows = '';
                                            data.procedures.forEach(function (p) {
                                                pRows += '<tr>'
                                                    + '<td class="ps-3"><strong class="text-dark">' + (p.serviceName || '') + '</strong></td>'
                                                    + '<td class="text-end fw-semibold text-primary">' + (p.priceFmt || '') + '</td>'
                                                    + '<td class="text-end pe-3"><span class="badge bg-success-subtle text-success border border-success-subtle">' + (p.status || 'Hoàn tất') + '</span></td>'
                                                    + '</tr>';
                                            });
                                            procTbody.innerHTML = pRows;
                                            procBox.classList.remove('d-none');
                                        } else {
                                            procBox.classList.add('d-none');
                                        }
                                    }

                                    // 6. Viện phí & Thanh toán phần còn lại
                                    var totElem = document.getElementById('postExamTotalAmount');
                                    if (totElem) totElem.textContent = data.totalAmountFmt || '200.000 ₫';

                                    var depElem = document.getElementById('postExamDepositAmount');
                                    if (depElem) depElem.textContent = data.depositAmountFmt || '200.000 ₫';

                                    var balElem = document.getElementById('postExamBalanceDue');
                                    if (balElem) balElem.textContent = data.balanceDueFmt || '0 ₫';

                                    var payBox = document.getElementById('postExamPaymentSelectionBox');
                                    var noticeBox = document.getElementById('postExamFullyPaidNotice');
                                    var balNotice = document.getElementById('postExamBalanceDueNotice');

                                    var invStatElem = document.getElementById('postExamInvoiceStatus');
                                    if (invStatElem) {
                                        if (data.isFullyPaid) {
                                            invStatElem.className = 'badge bg-success-subtle text-success border border-success-subtle py-1 px-2 fw-semibold';
                                            invStatElem.innerHTML = '<i class="bi bi-check-circle me-1"></i>Đã thanh toán (Paid)';
                                        } else {
                                            invStatElem.className = 'badge bg-warning-subtle text-warning-emphasis border border-warning-subtle py-1 px-2 fw-semibold';
                                            invStatElem.innerHTML = '<i class="bi bi-clock me-1"></i>' + (data.invoiceStatus || 'Còn phần chưa thanh toán');
                                        }
                                    }

                                    var completeBtn = document.getElementById('btnCompleteAppointment');
                                    var footerNote = document.getElementById('postExamFooterNote');

                                    if (data.status === 'In_Progress') {
                                        if (payBox) payBox.classList.add('d-none');
                                        if (noticeBox) noticeBox.classList.add('d-none');

                                        if (completeBtn) {
                                            completeBtn.disabled = true;
                                            completeBtn.className = 'btn btn-secondary btn-sm px-3.5 py-1.5 fw-semibold shadow-sm opacity-75';
                                            completeBtn.innerHTML = '<i class="bi bi-heart-pulse me-1.5"></i> Bác sĩ đang khám (Chưa thể hoàn tất)';
                                        }
                                        if (footerNote) {
                                            footerNote.innerHTML = '<i class="bi bi-info-circle text-primary me-1"></i>Bác sĩ đang thực hiện ca khám trong phòng. Sau khi bác sĩ bấm hoàn tất chẩn đoán và đơn thuốc, lễ tân mới có thể thu viện phí và đóng lịch hẹn.';
                                        }
                                    } else if (data.status === 'Confirmed') {
                                        if (payBox) payBox.classList.add('d-none');
                                        if (noticeBox) noticeBox.classList.add('d-none');

                                        if (completeBtn) {
                                            completeBtn.disabled = true;
                                            completeBtn.className = 'btn btn-secondary btn-sm px-3.5 py-1.5 fw-semibold shadow-sm opacity-75';
                                            completeBtn.innerHTML = '<i class="bi bi-clock me-1.5"></i> Chờ bác sĩ tiếp nhận khám';
                                        }
                                        if (footerNote) {
                                            footerNote.innerHTML = '<i class="bi bi-info-circle text-secondary me-1"></i>Bệnh nhân đang chờ gọi vào phòng khám.';
                                        }
                                    } else if (data.status === 'Completed') {
                                        if (data.balanceDue > 0) {
                                            if (payBox) payBox.classList.remove('d-none');
                                            if (noticeBox) noticeBox.classList.add('d-none');
                                            if (balNotice) balNotice.textContent = data.balanceDueFmt || (data.balanceDue + ' ₫');

                                            if (completeBtn) {
                                                completeBtn.disabled = false;
                                                completeBtn.className = 'btn btn-warning btn-sm px-3.5 py-1.5 fw-semibold shadow-sm text-dark';
                                                completeBtn.innerHTML = '<i class="bi bi-cash-coin me-1.5"></i> Thu ' + (data.balanceDueFmt || '') + ' & Hoàn tất lịch hẹn';
                                            }
                                            if (footerNote) {
                                                footerNote.innerHTML = '<i class="bi bi-exclamation-circle text-warning me-1"></i>Bác sĩ đã khám xong. Vui lòng thu phần còn lại <strong>' + (data.balanceDueFmt || '') + '</strong> và bấm hoàn tất.';
                                            }
                                        } else {
                                            if (payBox) payBox.classList.add('d-none');
                                            if (noticeBox) noticeBox.classList.remove('d-none');

                                            if (completeBtn) {
                                                completeBtn.disabled = true;
                                                completeBtn.className = 'btn btn-success btn-sm px-3.5 py-1.5 fw-semibold shadow-sm';
                                                completeBtn.innerHTML = '<i class="bi bi-check2-circle me-1.5"></i> Lịch hẹn đã hoàn tất';
                                            }
                                            if (footerNote) {
                                                footerNote.innerHTML = '<i class="bi bi-check-circle text-success me-1"></i>Ca khám và viện phí đã hoàn tất toàn bộ.';
                                            }
                                        }
                                    }

                                    if (loading) loading.classList.add('d-none');
                                    if (content) content.classList.remove('d-none');
                                } else {
                                    showToast(data && data.message ? data.message : 'Không thể tải chi tiết ca khám.', 'danger');
                                }
                            })
                            .catch(function (err) {
                                console.error('Error fetching post exam details', err);
                                showToast('Lỗi kết nối tải dữ liệu phiếu khám: ' + err.message, 'danger');
                            });
                    }

                    function showPostExamAlert(msg, type) {
                        var box = document.getElementById('postExamAlertBox');
                        if (!box) return;
                        var isSuccess = (type === 'success');
                        box.className = 'alert ' + (isSuccess ? 'alert-success' : 'alert-danger') + ' py-2.5 px-3 small rounded-3 mb-3 d-flex align-items-center gap-2 shadow-sm';
                        var icon = isSuccess ? 'bi-check-circle-fill text-success' : 'bi-exclamation-triangle-fill text-danger';
                        box.innerHTML = '<i class="bi ' + icon + ' fs-5 flex-shrink-0"></i><div>' + msg + '</div>';
                        box.classList.remove('d-none');
                        box.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
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

                    function submitCompleteAppointment() {
                        if (!currentPostExamId) return;
                        var data = window._currentPostExamData;
                        if (data && data.status !== 'Completed') {
                            showPostExamAlert('Không thể hoàn tất lịch hẹn (#APT-' + currentPostExamId + ') do Bác sĩ đang khám trong phòng và chưa kết thúc ca khám!', 'danger');
                            showToast('Không thể hoàn tất lịch hẹn: Ca khám đang diễn ra trong phòng bác sĩ!', 'danger');
                            return;
                        }

                        var balanceDue = (data && data.balanceDue) ? data.balanceDue : 0;
                        var selectedGateway = 'Cash';
                        var payRadio = document.querySelector('input[name="postExamPaymentGateway"]:checked');
                        if (payRadio) {
                            selectedGateway = payRadio.value;
                        }

                        var btn = document.getElementById('btnCompleteAppointment');
                        if (btn) {
                            btn.disabled = true;
                            btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Đang xử lý...';
                        }

                        fetch('${pageContext.request.contextPath}/staff/waiting-list', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                            body: 'action=completeAppointment&appointmentId=' + currentPostExamId + '&paymentGateway=' + encodeURIComponent(selectedGateway) + '&ajax=1'
                        })
                            .then(function (res) { return res.json(); })
                            .then(function (result) {
                                if (result && result.success) {
                                    var modalElem = document.getElementById('postExamModal');
                                    if (modalElem) {
                                        var modal = bootstrap.Modal.getInstance(modalElem);
                                        if (modal) modal.hide();
                                    }
                                    showToast(result.message || 'Đã hoàn tất lịch hẹn thành công!', 'success');
                                    setTimeout(function () {
                                        window.location.reload();
                                    }, 1200);
                                } else {
                                    var msg = (result && result.message) ? result.message : 'Không thể hoàn tất lịch hẹn.';
                                    if (btn) {
                                        btn.disabled = false;
                                        btn.innerHTML = balanceDue > 0
                                            ? '<i class="bi bi-cash-coin me-1.5"></i> Thu ' + (data.balanceDueFmt || '') + ' & Hoàn tất lịch hẹn'
                                            : '<i class="bi bi-check2-circle me-1.5"></i> Hoàn tất lịch hẹn';
                                    }
                                    showPostExamAlert(msg, 'danger');
                                    showToast(msg, 'danger');
                                }
                            })
                            .catch(function (err) {
                                var errMsg = 'Lỗi kết nối khi hoàn tất: ' + err.message;
                                if (btn) {
                                    btn.disabled = false;
                                    btn.innerHTML = balanceDue > 0
                                        ? '<i class="bi bi-cash-coin me-1.5"></i> Thu ' + (data.balanceDueFmt || '') + ' & Hoàn tất lịch hẹn'
                                        : '<i class="bi bi-check2-circle me-1.5"></i> Hoàn tất lịch hẹn';
                                }
                                showPostExamAlert(errMsg, 'danger');
                                showToast(errMsg, 'danger');
                            });
                    }

                    document.addEventListener('click', function (e) {
                        var btnPostExam = e.target.closest('.btn-trigger-post-exam');
                        if (btnPostExam) {
                            var id = btnPostExam.getAttribute('data-id');
                            var name = btnPostExam.getAttribute('data-name');
                            openPostExamModal(id, name);
                            return;
                        }

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