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
                            <div class="px-3 pt-3 pb-2 bg-light border-bottom d-flex align-items-center justify-content-between flex-wrap gap-2">
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
                                        <col style="width: 65px;">
                                        <col style="width: 110px;">
                                        <col style="width: 17%;">
                                        <col style="width: 14%;">
                                        <col style="width: 17%;">
                                        <col style="width: 17%;">
                                        <col style="width: 125px;">
                                        <col style="width: 155px;">
                                    </colgroup>
                                    <thead>
                                        <tr>
                                            <th class="text-center text-nowrap" style="width: 65px;">STT</th>
                                            <th class="text-center text-nowrap" style="width: 110px;">Mã Hẹn</th>
                                            <th class="text-nowrap" style="width: 17%;">Bệnh Nhân</th>
                                            <th class="text-nowrap" style="width: 14%;">Ca Khám</th>
                                            <th class="text-nowrap" style="width: 17%;">Bác Sĩ</th>
                                            <th class="text-nowrap" style="width: 17%;">Phòng Khám</th>
                                            <th class="text-center text-nowrap" style="width: 125px;">Trạng Thái</th>
                                            <th class="text-center text-nowrap" style="width: 155px;">Thao Tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${not empty waitingList}">
                                                <c:set var="currentDateStr"><%= java.time.LocalDate.now().toString() %></c:set>
                                                <c:forEach var="appt" items="${waitingList}">
                                                    <c:set var="apptDateStr">${appt.appointmentDate}</c:set>
                                                    <c:set var="isPastAppt" value="${not empty apptDateStr && apptDateStr < currentDateStr}" />
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
                                                            <span class="fw-bold text-dark">#APPT-${appt.id}</span>
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
                                                            <div class="fw-semibold text-dark d-flex align-items-center gap-1.5" style="font-size: 13px;">
                                                                <i class="bi bi-clock-fill" style="color: var(--primary-color, #0d9488); font-size: 13px;"></i>
                                                                <span>
                                                                    <c:choose>
                                                                        <c:when test="${not empty appt.timeSlot && not empty appt.endTime}">
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
                                                            <c:if test="${not empty appt.slotName && !fn:containsIgnoreCase(appt.slotName, 'Slot Khám')}">
                                                                <div class="text-muted small mt-0.5" style="font-size: 11px; padding-left: 17px;">
                                                                    ${appt.slotName}
                                                                </div>
                                                            </c:if>
                                                        </td>

                                                        <!-- Bác Sĩ -->
                                                        <td>
                                                            <div class="fw-semibold text-dark text-truncate" title="${not empty appt.doctorName ? appt.doctorName : 'Chưa phân công'}">
                                                                ${not empty appt.doctorName ? appt.doctorName : 'Chưa phân công'}
                                                            </div>
                                                            <c:if test="${not empty appt.department}">
                                                                <div class="text-muted small text-truncate" style="font-size: 11.5px;" title="${appt.department}">
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
                                                                    <span class="badge-status badge-pending" title="Chờ tiếp đón tại quầy lễ tân">
                                                                        Chờ tiếp đón
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${appt.status == 'Confirmed'}">
                                                                    <span class="badge-status badge-confirmed" title="Đã tiếp đón, đang chờ vào khám">
                                                                        Chờ khám
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${appt.status == 'In_Progress'}">
                                                                    <span class="badge-status badge-in-progress" title="Bác sĩ đang thực hiện khám">
                                                                        Đang khám
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${appt.status == 'Completed'}">
                                                                    <span class="badge-status badge-completed" title="Ca khám đã hoàn thành">
                                                                        Đã khám xong
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${appt.status == 'Canceled'}">
                                                                    <span class="badge-status badge-canceled" title="${not empty appt.reason ? appt.reason : 'Lịch hẹn đã hủy / vắng mặt'}">
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
                                                                <!-- 1. Xem chi tiết / Hồ sơ bệnh nhân (Luôn hiển thị) -->
                                                                <a href="${pageContext.request.contextPath}/staff/appointment-detail?id=${appt.id}"
                                                                    class="action-btn"
                                                                    title="Xem hồ sơ / Chi tiết ca khám & Ghi chú y tế" data-bs-toggle="tooltip">
                                                                    <i class="bi bi-pencil"></i>
                                                                </a>

                                                                <!-- Các thao tác khám: Chỉ hiển thị khi ca khám CHƯA qua ngày -->
                                                                <c:if test="${!isPastAppt}">
                                                                    <c:choose>
                                                                        <c:when test="${appt.status == 'Confirmed'}">
                                                                            <!-- 2. Gọi vào khám -->
                                                                            <c:choose>
                                                                                <c:when test="${busyDoctorIds != null && busyDoctorIds.contains(appt.doctorId)}">
                                                                                    <button type="button" class="action-btn"
                                                                                        disabled
                                                                                        title="Bác sĩ hiện đang khám cho ca trước. Vui lòng đợi hoàn tất ca hiện tại."
                                                                                        data-bs-toggle="tooltip">
                                                                                        <i class="bi bi-hourglass-split"></i>
                                                                                    </button>
                                                                                </c:when>
                                                                                <c:when test="${callableApptIds != null && !callableApptIds.contains(appt.id)}">
                                                                                    <button type="button" class="action-btn"
                                                                                        disabled
                                                                                        title="Chưa đến lượt: Bác sĩ vẫn còn ca khám trước đó chưa khám. Bắt buộc phải gọi ca trước theo đúng thứ tự slot!"
                                                                                        data-bs-toggle="tooltip">
                                                                                        <i class="bi bi-lock-fill text-muted"></i>
                                                                                    </button>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <button type="button"
                                                                                        class="action-btn checkin btn-trigger-start"
                                                                                        title="Gọi bệnh nhân vào phòng khám (Đúng lượt ca khám)" data-bs-toggle="tooltip"
                                                                                        data-id="${appt.id}"
                                                                                        data-name="${appt.patientName}">
                                                                                        <i class="bi bi-box-arrow-in-right"></i>
                                                                                    </button>
                                                                                </c:otherwise>
                                                                            </c:choose>

                                                                            <!-- 3. Bỏ qua lượt (Vàng pastel - Hoán đổi lượt với ca tiếp theo sau mình) -->
                                                                            <button type="button"
                                                                                class="action-btn warning btn-trigger-skip"
                                                                                title="Bỏ qua lượt: Đổi ca khám với lượt tiếp theo sau mình để nhường lượt vào khám" data-bs-toggle="tooltip"
                                                                                data-id="${appt.id}"
                                                                                data-name="${appt.patientName}">
                                                                                <i class="bi bi-arrow-down-circle"></i>
                                                                            </button>

                                                                            <!-- 4. Báo vắng mặt / Hủy ca (Đỏ pastel - icon thùng rác giống Quản lý người dùng) -->
                                                                            <button type="button"
                                                                                class="action-btn delete btn-trigger-absent"
                                                                                title="Báo vắng mặt: Gọi tên nhiều lần không có mặt / Tự ý bỏ về" data-bs-toggle="tooltip"
                                                                                data-id="${appt.id}"
                                                                                data-name="${appt.patientName}">
                                                                                <i class="bi bi-trash"></i>
                                                                            </button>
                                                                        </c:when>

                                                                        <c:when test="${appt.status == 'In_Progress'}">
                                                                            <!-- Đang trong phòng khám: Chỉ Bác sĩ mới có quyền hoàn thành ca khám -->
                                                                            <button type="button"
                                                                                class="action-btn disabled"
                                                                                style="cursor: not-allowed; background-color: #f1f5f9; color: #64748b; border: 1px dashed #cbd5e1;"
                                                                                title="Bác sĩ đang thực hiện ca khám trong phòng. Chỉ Bác sĩ mới có quyền hoàn tất ca khám này!" data-bs-toggle="tooltip">
                                                                                <i class="bi bi-hourglass-split"></i>
                                                                            </button>

                                                                            <!-- Báo vắng mặt / Hủy ca giữa chừng (Đỏ pastel - icon thùng rác) -->
                                                                            <button type="button"
                                                                                class="action-btn delete btn-trigger-absent"
                                                                                title="Báo vắng mặt / Bệnh nhân tự ý bỏ về giữa chừng" data-bs-toggle="tooltip"
                                                                                data-id="${appt.id}"
                                                                                data-name="${appt.patientName}">
                                                                                <i class="bi bi-trash"></i>
                                                                            </button>
                                                                        </c:when>

                                                                        <c:when test="${appt.status == 'Completed'}">
                                                                            <!-- Đã khám xong: Bàn giao đơn thuốc & Hoàn tất thủ tục -->
                                                                            <button type="button"
                                                                                class="action-btn checkin btn-trigger-post-exam"
                                                                                title="Tiếp nhận sau khám: Xem kết quả, đơn thuốc & Bàn giao cho bệnh nhân" data-bs-toggle="tooltip"
                                                                                data-id="${appt.id}"
                                                                                data-name="${appt.patientName}">
                                                                                <i class="bi bi-clipboard2-check"></i>
                                                                            </button>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                        </c:otherwise>
                                                                    </c:choose>
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
                                                                    <i class="bi bi-hourglass-split fs-1 d-block mb-2 text-warning"></i>
                                                                    <p class="mb-1 fw-semibold text-dark">Không có bệnh nhân nào đang chờ khám!</p>
                                                                    <p class="small text-muted">Tất cả bệnh nhân đã được gọi vào phòng khám hoặc chưa có ca tiếp đón mới.</p>
                                                                </c:when>
                                                                <c:when test="${selectedStatus == 'In_Progress'}">
                                                                    <i class="bi bi-heart-pulse fs-1 d-block mb-2 text-primary"></i>
                                                                    <p class="mb-1 fw-semibold text-dark">Hiện không có ca nào đang khám trong phòng!</p>
                                                                    <p class="small text-muted">Vui lòng gọi bệnh nhân ở danh sách "Chờ khám" vào phòng khám.</p>
                                                                </c:when>
                                                                <c:when test="${selectedStatus == 'Completed'}">
                                                                    <i class="bi bi-check2-circle fs-1 d-block mb-2 text-success"></i>
                                                                    <p class="mb-1 fw-semibold text-dark">Chưa có ca khám nào hoàn tất!</p>
                                                                    <p class="small text-muted">Các ca sau khi hoàn tất khám hôm nay sẽ được hiển thị tại đây.</p>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <i class="bi bi-people fs-1 d-block mb-2 text-secondary"></i>
                                                                    <p class="mb-1 fw-semibold text-dark">Hiện tại hàng đợi đang trống</p>
                                                                    <p class="small text-muted">Chưa có bệnh nhân nào được check-in trong ngày hôm nay.</p>
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

                <!-- Modal Xác nhận Bệnh nhân Vào khám (Chuyển trạng thái sang Đang khám) -->
                <div class="modal fade" id="startExamModal" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered" style="max-width: 420px;">
                        <div class="modal-content">
                            <div class="modal-header">
                                <button type="button" class="btn-close" data-bs-dismiss="modal"
                                    aria-label="Close"></button>
                            </div>
                            <div class="modal-body">
                                <div class="modal-icon-teal">
                                    <i class="bi bi-box-arrow-in-right"></i>
                                </div>
                                <h3 class="modal-title-custom">Xác nhận vào khám?</h3>
                                <p class="modal-text">
                                    Gọi bệnh nhân <strong id="startExamModalPatientName" class="text-dark">---</strong>
                                    vào phòng khám. Trạng thái ca khám sẽ được chuyển thành <strong>Đang khám</strong>.
                                </p>
                                <form action="${pageContext.request.contextPath}/staff/waiting-list" method="post"
                                    id="startExamForm" class="m-0">
                                    <input type="hidden" name="action" value="updateStatus">
                                    <input type="hidden" name="appointmentId" id="startExamModalAppointmentId">
                                    <input type="hidden" name="status" value="In_Progress">
                                    <div class="modal-actions">
                                        <button type="button" class="btn btn-modal-cancel"
                                            data-bs-dismiss="modal">Hủy</button>
                                        <button type="submit" class="btn btn-modal-teal">Vào khám</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>


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
                                    Bệnh nhân <strong id="absentModalPatientName" class="text-dark">---</strong> (<span id="absentModalApptCode" class="fw-bold text-secondary">#APPT-0</span>) sẽ được ghi nhận vắng mặt và gỡ khỏi hàng đợi hôm nay.
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

                                    <div class="modal-actions">
                                        <button type="button" class="btn btn-modal-cancel" data-bs-dismiss="modal">Đóng</button>
                                        <button type="submit" class="btn btn-modal-danger">
                                            <i class="bi bi-person-x me-1"></i> Báo vắng mặt
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
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
                                    Bệnh nhân <strong id="skipModalPatientName" class="text-dark">---</strong> (<span id="skipModalApptCode" class="fw-bold text-secondary">#APPT-0</span>) sẽ <strong>chuyển đổi ca khám với lượt tiếp theo sau mình</strong> để nhường lượt cho bệnh nhân kế tiếp vào phòng khám.
                                </p>
                                <form action="${pageContext.request.contextPath}/staff/waiting-list" method="post" id="skipForm" class="m-0">
                                    <input type="hidden" name="action" value="skip">
                                    <input type="hidden" name="appointmentId" id="skipModalAppointmentId">
                                    <input type="hidden" name="returnUrl" value="${pageContext.request.contextPath}/staff/waiting-list${not empty pageContext.request.queryString ? '?'.concat(pageContext.request.queryString) : ''}">
                                    <div class="modal-actions">
                                        <button type="button" class="btn btn-modal-cancel" data-bs-dismiss="modal">Hủy</button>
                                        <button type="submit" class="btn btn-modal-warning">
                                            <i class="bi bi-arrow-down-circle me-1"></i> Đổi lượt ca sau
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Modal Tiếp nhận Bệnh nhân Sau Khám & Bàn giao Đơn thuốc -->
                <div class="modal fade" id="postExamModal" tabindex="-1" aria-labelledby="postExamModalLabel" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered modal-lg" style="max-width: 720px;">
                        <div class="modal-content shadow border-0" style="border-radius: 16px; overflow: hidden;">
                            <div class="modal-header border-bottom px-4 py-3 bg-light">
                                <div class="d-flex align-items-center gap-2.5">
                                    <div style="width: 40px; height: 40px; border-radius: 10px; background: rgba(13, 148, 136, 0.12); color: #0d9488; display: flex; align-items: center; justify-content: center; font-size: 20px;">
                                        <i class="bi bi-clipboard2-check"></i>
                                    </div>
                                    <div>
                                        <h5 class="modal-title fw-bold text-dark mb-0" id="postExamModalLabel" style="font-size: 16.5px;">Tiếp nhận sau khám & Bàn giao đơn thuốc</h5>
                                        <small class="text-secondary" style="font-size: 12px;" id="postExamSubtitle">Bệnh nhân: --- | BS: ---</small>
                                    </div>
                                </div>
                                <button type="button" class="btn-close shadow-none" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>

                            <div class="modal-body p-4" id="postExamModalBody">
                                <!-- Loading State -->
                                <div id="postExamLoading" class="text-center py-5">
                                    <div class="spinner-border text-teal mb-2" role="status" style="width: 2.5rem; height: 2.5rem; color: #0d9488;"></div>
                                    <p class="text-secondary small mb-0">Đang tải kết quả khám và đơn thuốc từ bác sĩ...</p>
                                </div>

                                <!-- Content State -->
                                <div id="postExamContent" class="d-none">
                                    <!-- Banner trạng thái hoàn tất -->
                                    <div class="alert alert-success py-2.5 px-3 rounded-3 mb-3 d-flex align-items-center justify-content-between" style="font-size: 13px;">
                                        <div class="d-flex align-items-center gap-2">
                                            <i class="bi bi-check-circle-fill fs-5 text-success"></i>
                                            <div>
                                                <strong class="text-success">Bác sĩ đã hoàn tất ca khám</strong>
                                                <div class="text-secondary" style="font-size: 11.5px;" id="postExamHeaderTime">Thời gian hoàn thành: Hôm nay</div>
                                            </div>
                                        </div>
                                        <span class="badge bg-success px-2.5 py-1.5 fw-semibold" style="font-size: 11.5px;">Sẵn sàng xuất viện</span>
                                    </div>

                                    <!-- 1. Tóm tắt kết quả chẩn đoán y khoa -->
                                    <div class="card border rounded-3 mb-3 shadow-none bg-light">
                                        <div class="card-body p-3">
                                            <h6 class="fw-bold text-dark mb-2 d-flex align-items-center gap-1.5" style="font-size: 13.5px;">
                                                <i class="bi bi-activity text-teal" style="color: #0d9488;"></i> Chẩn đoán & Kết luận của Bác sĩ
                                            </h6>
                                            <div class="row g-2 text-dark small" style="font-size: 12.5px;">
                                                <div class="col-sm-6">
                                                    <span class="text-muted d-block" style="font-size: 11.5px;">Chẩn đoán lâm sàng:</span>
                                                    <strong id="postExamDiagnosis" class="text-primary">---</strong>
                                                </div>
                                                <div class="col-sm-6">
                                                    <span class="text-muted d-block" style="font-size: 11.5px;">Bác sĩ phụ trách:</span>
                                                    <span id="postExamDoctor" class="fw-semibold">---</span>
                                                </div>
                                                <div class="col-12 mt-2 pt-2 border-top">
                                                    <span class="text-muted d-block" style="font-size: 11.5px;">Lời dặn của bác sĩ:</span>
                                                    <div id="postExamDoctorNotes" class="fst-italic text-secondary bg-white p-2 rounded border mt-1">---</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- 2. Danh sách đơn thuốc -->
                                    <div class="card border rounded-3 mb-3 shadow-none">
                                        <div class="card-header bg-white py-2.5 px-3 border-bottom d-flex align-items-center justify-content-between">
                                            <span class="fw-bold text-dark small d-flex align-items-center gap-1.5" style="font-size: 13.5px;">
                                                <i class="bi bi-capsule text-primary"></i> Đơn thuốc xuất viện
                                            </span>
                                            <span class="badge bg-primary-subtle text-primary border border-primary-subtle" id="postExamMedCount">0 loại thuốc</span>
                                        </div>
                                        <div class="table-responsive">
                                            <table class="table table-sm table-hover mb-0 align-middle" style="font-size: 12.5px;">
                                                <thead class="table-light">
                                                    <tr>
                                                        <th style="width: 40px;" class="text-center">#</th>
                                                        <th>Tên thuốc</th>
                                                        <th style="width: 100px;" class="text-center">Số lượng</th>
                                                        <th>Hướng dẫn dùng thuốc</th>
                                                    </tr>
                                                </thead>
                                                <tbody id="postExamMedicineList">
                                                    <tr><td colspan="4" class="text-center text-muted py-2">Không có đơn thuốc kê theo ca khám này</td></tr>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>

                                    <!-- 3. Cận lâm sàng / Thủ thuật (nếu có) -->
                                    <div id="postExamProceduresBox" class="card border rounded-3 mb-3 shadow-none d-none">
                                        <div class="card-header bg-white py-2 px-3 border-bottom">
                                            <span class="fw-bold text-dark small d-flex align-items-center gap-1.5" style="font-size: 13px;">
                                                <i class="bi bi-tools text-warning"></i> Cận lâm sàng & Thủ thuật đã thực hiện
                                            </span>
                                        </div>
                                        <div class="table-responsive">
                                            <table class="table table-sm mb-0 align-middle" style="font-size: 12px;">
                                                <tbody id="postExamProcedureList"></tbody>
                                            </table>
                                        </div>
                                    </div>

                                    <!-- 4. Tình trạng viện phí -->
                                    <div class="p-2.5 rounded-3 bg-light border d-flex align-items-center justify-content-between flex-wrap gap-2 text-dark small" style="font-size: 12.5px;">
                                        <div class="d-flex align-items-center gap-2">
                                            <div class="rounded-circle bg-success-subtle text-success d-flex align-items-center justify-content-center" style="width: 28px; height: 28px;">
                                                <i class="bi bi-credit-card"></i>
                                            </div>
                                            <div>
                                                <span class="text-muted d-block" style="font-size: 11px;">Phí khám & Dịch vụ:</span>
                                                <strong id="postExamInvoiceAmount">200.000 ₫</strong>
                                            </div>
                                        </div>
                                        <div>
                                            <span class="badge bg-success-subtle text-success border border-success-subtle py-1 px-2 fw-semibold" id="postExamInvoiceStatus">
                                                <i class="bi bi-check-circle me-1"></i>Đã thanh toán (Paid)
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="modal-footer px-4 py-3 bg-light border-top d-flex justify-content-between">
                                <div>
                                    <button type="button" class="btn btn-outline-secondary btn-sm px-3" onclick="printPostExamSheet()">
                                        <i class="bi bi-printer me-1"></i> In đơn thuốc & Phiếu khám
                                    </button>
                                </div>
                                <div class="d-flex align-items-center gap-2">
                                    <button type="button" class="btn btn-light btn-sm px-3 border" data-bs-dismiss="modal">Đóng</button>
                                    <button type="button" class="btn btn-teal btn-sm px-3.5 py-1.5 fw-semibold shadow-sm" id="btnConfirmHandover" onclick="confirmPostExamHandover()">
                                        <i class="bi bi-check2-all me-1"></i> Xác nhận đã bàn giao & Hoàn tất
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Bootstrap 5 JS -->
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
                <script>
                    function toggleAbsentReason(selectElem) {
                        var customText = document.getElementById('absentReasonCustom');
                        if (!customText) return;
                        if (selectElem.value === 'other') {
                            customText.classList.remove('d-none');
                            customText.focus();
                        } else {
                            customText.classList.add('d-none');
                            customText.value = '';
                        }
                    }

                    function openStartExamModal(id, name) {
                        var idInput = document.getElementById('startExamModalAppointmentId');
                        if (idInput) idInput.value = id;
                        var nameElem = document.getElementById('startExamModalPatientName');
                        if (nameElem) nameElem.textContent = name || 'này';
                        var modalElem = document.getElementById('startExamModal');
                        if (modalElem) {
                            var modal = bootstrap.Modal.getInstance(modalElem) || new bootstrap.Modal(modalElem);
                            modal.show();
                        }
                    }


                    function openAbsentModal(id, name) {
                        var idInput = document.getElementById('absentModalAppointmentId');
                        if (idInput) idInput.value = id;
                        var nameElem = document.getElementById('absentModalPatientName');
                        if (nameElem) nameElem.textContent = name || 'này';
                        var codeElem = document.getElementById('absentModalApptCode');
                        if (codeElem) codeElem.textContent = '#APPT-' + id;
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
                        if (codeElem) codeElem.textContent = '#APPT-' + id;
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
                        if (subElem) subElem.textContent = 'Bệnh nhân: ' + (name || '---') + ' (#APPT-' + id + ')';

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
                            .then(function(res) { return res.json(); })
                            .then(function(data) {
                                if (data && data.success) {
                                    window._currentPostExamData = data;
                                    var diagElem = document.getElementById('postExamDiagnosis');
                                    if (diagElem) diagElem.textContent = data.clinicalDiagnosis || 'Khám mắt tổng quát';

                                    var docElem = document.getElementById('postExamDoctor');
                                    if (docElem) docElem.textContent = (data.doctorName || 'Bác sĩ') + ' (' + (data.roomName || '') + ')';

                                    var notesElem = document.getElementById('postExamDoctorNotes');
                                    if (notesElem) notesElem.textContent = data.doctorNotes || 'Uống và nhỏ thuốc theo đúng hướng dẫn.';

                                    var timeElem = document.getElementById('postExamHeaderTime');
                                    if (timeElem) timeElem.textContent = 'Giờ khám: ' + (data.timeSlot || '--:--') + ' · Ngày: ' + (data.appointmentDate || '');

                                    var medTbody = document.getElementById('postExamMedicineList');
                                    var medCount = document.getElementById('postExamMedCount');
                                    if (medTbody) {
                                        if (data.medicines && data.medicines.length > 0) {
                                            if (medCount) medCount.textContent = data.medicines.length + ' loại thuốc';
                                            var rows = '';
                                            data.medicines.forEach(function(m, idx) {
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
                                            medTbody.innerHTML = '<tr><td colspan="4" class="text-center text-muted py-3 fst-italic">Bác sĩ không kê đơn thuốc cho ca khám này.</td></tr>';
                                        }
                                    }

                                    var procBox = document.getElementById('postExamProceduresBox');
                                    var procTbody = document.getElementById('postExamProcedureList');
                                    if (procBox && procTbody) {
                                        if (data.procedures && data.procedures.length > 0) {
                                            var pRows = '';
                                            data.procedures.forEach(function(p) {
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

                                    var feeElem = document.getElementById('postExamInvoiceAmount');
                                    if (feeElem) feeElem.textContent = data.invoiceAmountFmt || '200.000 ₫';

                                    var invStatElem = document.getElementById('postExamInvoiceStatus');
                                    if (invStatElem) {
                                        if (data.invoiceStatus === 'Paid') {
                                            invStatElem.className = 'badge bg-success-subtle text-success border border-success-subtle py-1 px-2 fw-semibold';
                                            invStatElem.innerHTML = '<i class="bi bi-check-circle me-1"></i>Đã thanh toán (Paid)';
                                        } else {
                                            invStatElem.className = 'badge bg-warning-subtle text-warning border border-warning-subtle py-1 px-2 fw-semibold';
                                            invStatElem.innerHTML = '<i class="bi bi-clock me-1"></i>' + (data.invoiceStatus || 'Chờ đối soát');
                                        }
                                    }

                                    if (loading) loading.classList.add('d-none');
                                    if (content) content.classList.remove('d-none');
                                } else {
                                    alert(data && data.message ? data.message : 'Không thể tải chi tiết ca khám.');
                                }
                            })
                            .catch(function(err) {
                                console.error('Error fetching post exam details', err);
                                alert('Lỗi kết nối tải dữ liệu sau khám: ' + err.message);
                            });
                    }

                    function printPostExamSheet() {
                        var data = window._currentPostExamData;
                        if (!data) {
                            alert('Không có dữ liệu ca khám để in.');
                            return;
                        }

                        var medRowsHtml = '';
                        if (data.medicines && data.medicines.length > 0) {
                            data.medicines.forEach(function(m, idx) {
                                medRowsHtml += '<tr>'
                                    + '<td style="border: 1px solid #cbd5e1; padding: 8px; text-align: center;">' + (idx + 1) + '</td>'
                                    + '<td style="border: 1px solid #cbd5e1; padding: 8px;"><strong>' + (m.name || '') + '</strong></td>'
                                    + '<td style="border: 1px solid #cbd5e1; padding: 8px; text-align: center;">' + (m.quantity || 1) + '</td>'
                                    + '<td style="border: 1px solid #cbd5e1; padding: 8px;">' + (m.dosageInstruction || 'Theo chỉ định') + '</td>'
                                    + '</tr>';
                            });
                        } else {
                            medRowsHtml = '<tr><td colspan="4" style="border: 1px solid #cbd5e1; padding: 12px; text-align: center; color: #64748b;">Không có đơn thuốc chỉ định theo ca khám</td></tr>';
                        }

                        var printContent = '<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Phiếu kết quả & Đơn thuốc - ' + (data.patientName || '') + '</title>'
                            + '<style>'
                            + 'body { font-family: "Segoe UI", Arial, sans-serif; padding: 30px; color: #0f172a; line-height: 1.5; font-size: 13.5px; }'
                            + '.header { display: flex; justify-content: space-between; border-bottom: 2px solid #0d9488; padding-bottom: 12px; margin-bottom: 20px; }'
                            + '.clinic-name { font-size: 17px; font-weight: bold; color: #0d9488; text-transform: uppercase; }'
                            + '.title { text-align: center; font-size: 19px; font-weight: bold; margin: 15px 0; text-transform: uppercase; color: #0f172a; letter-spacing: 0.5px; }'
                            + '.info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-bottom: 20px; background: #f8fafc; padding: 14px; border-radius: 8px; border: 1px solid #e2e8f0; }'
                            + 'table { width: 100%; border-collapse: collapse; margin-top: 10px; margin-bottom: 20px; }'
                            + 'th { background: #f1f5f9; border: 1px solid #cbd5e1; padding: 8px; font-weight: 600; text-align: left; font-size: 13px; }'
                            + '.footer { display: flex; justify-content: space-between; margin-top: 40px; text-align: center; }'
                            + '@media print { body { padding: 0; } }'
                            + '</style></head><body>'
                            + '<div class="header">'
                            + '<div><div class="clinic-name">BỆNH VIỆN MẮT QUỐC TẾ VISIONCARE</div><div>Địa chỉ: Khu Công nghệ cao Hòa Lạc, Hà Nội</div><div>Hotline: 1900 8888 · Email: contact@visioncare.vn</div></div>'
                            + '<div style="text-align: right;"><div>Mã ca khám: <strong>#APPT-' + data.appointmentId + '</strong></div><div>Mã hồ sơ: <strong>' + (data.recordId || '#MR-' + data.appointmentId) + '</strong></div><div>Ngày khám: ' + (data.appointmentDate || '') + '</div></div>'
                            + '</div>'
                            + '<div class="title">PHIẾU KẾT QUẢ KHÁM & ĐƠN THUỐC</div>'
                            + '<div class="info-grid">'
                            + '<div><strong>Họ và tên:</strong> ' + (data.patientName || '') + '</div>'
                            + '<div><strong>Số điện thoại:</strong> ' + (data.phone || '') + '</div>'
                            + '<div><strong>Bác sĩ phụ trách:</strong> ' + (data.doctorName || '') + '</div>'
                            + '<div><strong>Phòng khám:</strong> ' + (data.roomName || '') + '</div>'
                            + '<div style="grid-column: span 2;"><strong>Chẩn đoán lâm sàng:</strong> ' + (data.clinicalDiagnosis || 'Khám mắt tổng quát') + '</div>'
                            + '<div style="grid-column: span 2;"><strong>Lời dặn của Bác sĩ:</strong> ' + (data.doctorNotes || 'Uống thuốc đúng giờ, tái khám khi có dấu hiệu bất thường.') + '</div>'
                            + '</div>'
                            + '<h4 style="margin-bottom: 8px; font-size: 14px; color: #0d9488; text-transform: uppercase;">DANH MỤC THUỐC ĐIỀU TRỊ</h4>'
                            + '<table><thead><tr><th style="width: 40px; text-align: center;">STT</th><th>Tên thuốc</th><th style="width: 90px; text-align: center;">Số lượng</th><th>Hướng dẫn sử dụng</th></tr></thead><tbody>'
                            + medRowsHtml
                            + '</tbody></table>'
                            + '<div class="footer">'
                            + '<div><strong>BỆNH NHÂN</strong><br><small style="color: #64748b;">(Ký và ghi rõ họ tên)</small></div>'
                            + '<div><strong>BÁC SĨ KHÁM BỆNH</strong><br><small style="color: #64748b;">(Ký và ghi rõ họ tên)</small><br><br><br><strong>' + (data.doctorName || '') + '</strong></div>'
                            + '</div>'
                            + '</body></html>';

                        var printWin = window.open('', '_blank', 'width=850,height=700');
                        if (printWin) {
                            printWin.document.open();
                            printWin.document.write(printContent);
                            printWin.document.close();
                            printWin.focus();
                            setTimeout(function() {
                                printWin.print();
                            }, 350);
                        }
                    }

                    function confirmPostExamHandover() {
                        if (!currentPostExamId) return;
                        var btn = document.getElementById('btnConfirmHandover');
                        if (btn) {
                            btn.disabled = true;
                            btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Đang xử lý...';
                        }

                        fetch('${pageContext.request.contextPath}/staff/waiting-list', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                            body: 'action=confirmHandover&appointmentId=' + currentPostExamId + '&ajax=1'
                        })
                        .then(function(res) { return res.json(); })
                        .then(function(data) {
                            if (btn) {
                                btn.disabled = false;
                                btn.innerHTML = '<i class="bi bi-check2-all me-1"></i> Xác nhận đã bàn giao & Hoàn tất';
                            }
                            var modalElem = document.getElementById('postExamModal');
                            if (modalElem) {
                                var modal = bootstrap.Modal.getInstance(modalElem);
                                if (modal) modal.hide();
                            }
                            alert('Đã hoàn tất bàn giao đơn thuốc và hướng dẫn xuất viện cho bệnh nhân!');
                            window.location.reload();
                        })
                        .catch(function(err) {
                            if (btn) {
                                btn.disabled = false;
                                btn.innerHTML = '<i class="bi bi-check2-all me-1"></i> Xác nhận đã bàn giao & Hoàn tất';
                            }
                            alert('Lỗi xác nhận bàn giao: ' + err.message);
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

                        var btnStart = e.target.closest('.btn-trigger-start');
                        if (btnStart) {
                            var id = btnStart.getAttribute('data-id');
                            var name = btnStart.getAttribute('data-name');
                            openStartExamModal(id, name);
                            return;
                        }


                        var btnSkip = e.target.closest('.btn-trigger-skip');
                        if (btnSkip) {
                            var id = btnSkip.getAttribute('data-id');
                            var name = btnSkip.getAttribute('data-name');
                            openSkipModal(id, name);
                            return;
                        }

                        var btnAbsent = e.target.closest('.btn-trigger-absent');
                        if (btnAbsent) {
                            var id = btnAbsent.getAttribute('data-id');
                            var name = btnAbsent.getAttribute('data-name');
                            openAbsentModal(id, name);
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
            </body>

            </html>