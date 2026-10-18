<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Danh sách Lịch hẹn - VisionCare Tiếp Đón</title>
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
                    <jsp:param name="activeNav" value="${not empty navActive ? navActive : 'appointments'}" />
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
                        <div
                            class="page-header d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
                            <div class="page-title">
                                <h2 class="mb-0">Danh sách Lịch Hẹn</h2>
                            </div>
                            <div class="d-flex align-items-center gap-2">
                                <a href="${pageContext.request.contextPath}/staff/waiting-list" class="btn btn-teal">
                                    <i class="bi bi-people-fill"></i> Xem Hàng đợi phòng khám
                                </a>
                            </div>
                        </div>

                        <!-- KPI Summary Cards (Bấm để lọc theo trạng thái) -->
                        <div class="row g-3 mb-4 align-items-stretch">
                            <!-- 1. Tổng lịch hẹn -->
                            <div class="col-sm-6 col-xl-3 d-flex">
                                <a href="${pageContext.request.contextPath}/staff/appointments?date=${selectedDate}&status=all&doctorId=${selectedDoctorId}&keyword=${param.keyword}"
                                    class="metric-card w-100 text-decoration-none ${selectedStatus == 'all' ? 'border border-2 border-primary shadow-sm bg-light' : ''}">
                                    <div class="metric-icon-box metric-icon-teal">
                                        <i class="bi bi-calendar4-event"></i>
                                    </div>
                                    <div class="metric-info">
                                        <div class="metric-num">${totalCount}</div>
                                        <div class="metric-title text-secondary">Tổng lịch hẹn</div>
                                    </div>
                                </a>
                            </div>

                            <!-- 2. Chờ tiếp đón -->
                            <div class="col-sm-6 col-xl-3 d-flex">
                                <a href="${pageContext.request.contextPath}/staff/appointments?date=${selectedDate}&status=Pending&doctorId=${selectedDoctorId}&keyword=${param.keyword}"
                                    class="metric-card w-100 text-decoration-none ${selectedStatus == 'Pending' ? 'border border-2 border-warning shadow-sm' : ''}"
                                    style="${selectedStatus == 'Pending' ? 'background-color: #fffdf5;' : ''}">
                                    <div class="metric-icon-box metric-icon-warning">
                                        <i class="bi bi-hourglass-split"></i>
                                    </div>
                                    <div class="metric-info">
                                        <div class="metric-num">${pendingCount}</div>
                                        <div class="metric-title text-secondary">Chờ tiếp đón</div>
                                    </div>
                                </a>
                            </div>

                            <!-- 3. Đã tiếp đón -->
                            <div class="col-sm-6 col-xl-3 d-flex">
                                <a href="${pageContext.request.contextPath}/staff/appointments?date=${selectedDate}&status=CheckedIn&doctorId=${selectedDoctorId}&keyword=${param.keyword}"
                                    class="metric-card w-100 text-decoration-none ${selectedStatus == 'CheckedIn' ? 'border border-2 border-purple shadow-sm' : ''}"
                                    style="${selectedStatus == 'CheckedIn' ? 'background-color: #faf5ff;' : ''}">
                                    <div class="metric-icon-box metric-icon-purple">
                                        <i class="bi bi-person-check-fill"></i>
                                    </div>
                                    <div class="metric-info">
                                        <div class="metric-num">${checkedInCount}</div>
                                        <div class="metric-title text-secondary">Đã tiếp đón</div>
                                    </div>
                                </a>
                            </div>

                            <!-- 4. Vắng mặt / Đã hủy -->
                            <div class="col-sm-6 col-xl-3 d-flex">
                                <a href="${pageContext.request.contextPath}/staff/appointments?date=${selectedDate}&status=Canceled&doctorId=${selectedDoctorId}&keyword=${param.keyword}"
                                    class="metric-card w-100 text-decoration-none ${selectedStatus == 'Canceled' ? 'border border-2 border-danger shadow-sm' : ''}"
                                    style="${selectedStatus == 'Canceled' ? 'background-color: #fff5f5;' : ''}">
                                    <div class="metric-icon-box metric-icon-danger">
                                        <i class="bi bi-person-x-fill"></i>
                                    </div>
                                    <div class="metric-info">
                                        <div class="metric-num">${canceledCount}</div>
                                        <div class="metric-title text-secondary">Vắng mặt / Đã huỷ</div>
                                    </div>
                                </a>
                            </div>
                        </div>

                        <!-- Content Card -->
                        <div class="content-card">
                            <!-- Receptionist Toolbar: Tìm kiếm bệnh nhân & Chọn ngày hẹn -->
                            <form action="${pageContext.request.contextPath}/staff/appointments" method="get"
                                class="p-3 border-bottom bg-white">
                                <input type="hidden" name="status" value="${selectedStatus}">
                                <div
                                    class="d-flex flex-column flex-md-row align-items-stretch align-items-md-center justify-content-between gap-3">
                                    <!-- 1. Thanh tìm kiếm nhanh (Tên, SĐT, Mã hẹn) -->
                                    <div class="search-filter-input flex-grow-1" style="max-width: 520px;">
                                        <i class="bi bi-search"></i>
                                        <input type="text" name="keyword" value="${param.keyword}"
                                            placeholder="Nhập SĐT, tên hoặc mã hẹn (#APPT-3)..." class="w-100"
                                            style="height: 40px; font-size: 14px; border-radius: 8px;">
                                    </div>

                                    <!-- 2. Chọn ngày & Nút Tra cứu -->
                                    <div class="d-flex align-items-center gap-3 flex-wrap flex-md-nowrap">
                                        <!-- Hộp chọn ngày hẹn -->
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
                                                title="Chọn ngày hẹn">
                                        </div>

                                        <!-- Nút Tra cứu -->
                                        <div class="d-flex align-items-center gap-2">
                                            <button type="submit"
                                                class="btn btn-teal px-3.5 text-nowrap d-flex align-items-center justify-content-center gap-1.5 shadow-sm"
                                                style="height: 40px; font-weight: 600;">
                                                <i class="bi bi-search"></i>
                                                <span>Tra cứu</span>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </form>

                            <!-- Thanh điều hướng Tab trạng thái -->
                            <div class="px-3 pt-3 pb-2 bg-light border-bottom d-flex align-items-center justify-content-between flex-wrap gap-2">
                                <div class="d-flex align-items-center gap-2 flex-wrap">
                                    <a href="${pageContext.request.contextPath}/staff/appointments?date=${selectedDate}&status=all&doctorId=${selectedDoctorId}&keyword=${param.keyword}"
                                        class="btn btn-sm ${selectedStatus == 'all' ? 'btn-dark fw-bold shadow-sm' : 'btn-white border text-secondary'} rounded-pill px-3">
                                        <i class="bi bi-calendar4-event me-1"></i> Tất cả (${totalCount})
                                    </a>
                                    <a href="${pageContext.request.contextPath}/staff/appointments?date=${selectedDate}&status=Pending&doctorId=${selectedDoctorId}&keyword=${param.keyword}"
                                        class="btn btn-sm ${selectedStatus == 'Pending' ? 'btn-warning text-dark fw-bold shadow-sm' : 'btn-white border text-secondary'} rounded-pill px-3">
                                        <i class="bi bi-hourglass-split me-1"></i> Chờ tiếp đón (${pendingCount})
                                    </a>
                                    <a href="${pageContext.request.contextPath}/staff/appointments?date=${selectedDate}&status=CheckedIn&doctorId=${selectedDoctorId}&keyword=${param.keyword}"
                                        class="btn btn-sm ${selectedStatus == 'CheckedIn' ? 'btn-primary fw-bold shadow-sm' : 'btn-white border text-secondary'} rounded-pill px-3">
                                        <i class="bi bi-person-check-fill me-1"></i> Đã tiếp đón (${checkedInCount})
                                    </a>
                                    <a href="${pageContext.request.contextPath}/staff/appointments?date=${selectedDate}&status=Canceled&doctorId=${selectedDoctorId}&keyword=${param.keyword}"
                                        class="btn btn-sm ${selectedStatus == 'Canceled' ? 'btn-danger fw-bold shadow-sm' : 'btn-white border text-secondary'} rounded-pill px-3">
                                        <i class="bi bi-person-x-fill me-1"></i> Vắng mặt / Đã hủy (${canceledCount})
                                    </a>
                                </div>
                            </div>

                            <!-- Table: Danh sách bệnh nhân -->
                            <div class="table-container">
                                <table class="custom-table" style="table-layout: fixed; width: 100%;">
                                    <colgroup>
                                        <col style="width: 8%;">
                                        <col style="width: 15%;">
                                        <col style="width: 13%;">
                                        <col style="width: 15%;">
                                        <col style="width: 23%;">
                                        <col style="width: 14%;">
                                        <col style="width: 12%;">
                                    </colgroup>
                                    <thead>
                                        <tr>
                                            <th class="text-center text-nowrap" style="width: 8%;">Mã Hẹn</th>
                                            <th class="text-nowrap" style="width: 15%;">Bệnh Nhân</th>
                                            <th class="text-nowrap" style="width: 13%;">Khung Giờ & Ngày</th>
                                            <th class="text-nowrap" style="width: 15%;">Bác Sĩ Phụ Trách</th>
                                            <th class="text-nowrap" style="width: 23%;">Phòng Khám</th>
                                            <th class="text-center text-nowrap" style="width: 14%;">Trạng Thái</th>
                                            <th class="text-center text-nowrap" style="width: 12%;">Thao Tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${not empty appointments}">
                                                <c:forEach var="appt" items="${appointments}">
                                                    <tr>
                                                        <!-- Mã Hẹn -->
                                                        <td class="text-center text-nowrap">
                                                            <a href="${pageContext.request.contextPath}/staff/appointment-detail?id=${appt.id}"
                                                                class="badge bg-light text-dark border px-2 py-1 fw-bold text-decoration-none hover-teal"
                                                                style="font-size: 13px; font-family: 'SFMono-Regular', Consolas, monospace; letter-spacing: 0.3px;">
                                                                #APPT-${appt.id}
                                                            </a>
                                                        </td>

                                                        <!-- Bệnh Nhân (Chỉ để tên) -->
                                                        <td class="text-nowrap text-truncate">
                                                            <a href="${pageContext.request.contextPath}/staff/appointment-detail?id=${appt.id}"
                                                                class="fw-semibold text-dark hover-teal text-decoration-none"
                                                                style="font-size: 14px;"
                                                                title="${appt.patientName}">
                                                                ${appt.patientName}
                                                            </a>
                                                        </td>

                                                        <!-- Thời Gian -->
                                                        <td class="text-nowrap">
                                                            <div class="fw-semibold text-dark" style="font-size: 13px;">
                                                                <i class="bi bi-clock text-teal me-1"
                                                                    style="color: var(--primary-color);"></i>
                                                                ${appt.timeSlot}
                                                            </div>
                                                            <div class="text-muted small mt-0.5" style="font-size: 12px;">
                                                                <i class="bi bi-calendar3 me-1"></i>${appt.appointmentDate}
                                                            </div>
                                                        </td>

                                                        <!-- Bác Sĩ -->
                                                        <td class="text-nowrap text-truncate">
                                                            <span class="fw-semibold text-dark"
                                                                style="font-size: 13.5px;"
                                                                title="${not empty appt.doctorName ? appt.doctorName : 'Chưa phân công'}">
                                                                ${not empty appt.doctorName ? appt.doctorName : 'Chưa phân công'}
                                                            </span>
                                                        </td>

                                                        <!-- Phòng Khám -->
                                                        <td class="text-nowrap">
                                                            <c:choose>
                                                                <c:when test="${not empty appt.roomName}">
                                                                    <span
                                                                        class="badge bg-light text-dark border px-2.5 py-1.5 fw-medium text-truncate"
                                                                        style="font-size: 12.5px; display: inline-flex; align-items: center; gap: 5px; max-width: 100%;"
                                                                        title="${appt.roomName}">
                                                                        <i class="bi bi-door-open text-success flex-shrink-0"></i>
                                                                        <span class="text-truncate">${appt.roomName}</span>
                                                                    </span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="text-muted small">--</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>

                                                        <!-- Trạng Thái (Thống nhất tiếng Việt & màu sắc) -->
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
                                                                    <span class="badge-status badge-canceled"
                                                                        title="${not empty appt.medicalNotes ? appt.medicalNotes : 'Lịch hẹn đã hủy / vắng mặt'}">
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

                                                        <!-- Thao Tác (Đồng bộ kiểu Quản lý người dùng) -->
                                                        <td class="text-center text-nowrap">
                                                            <div class="action-btns justify-content-center">
                                                                <!-- 1. Xem chi tiết (Xanh pastel - icon bút chì giống Quản lý người dùng) -->
                                                                <a href="${pageContext.request.contextPath}/staff/appointment-detail?id=${appt.id}"
                                                                    class="action-btn"
                                                                    title="Xem chi tiết & Ghi chú y tế" data-bs-toggle="tooltip">
                                                                    <i class="bi bi-pencil"></i>
                                                                </a>

                                                                <!-- Chỉ hiển thị Check-in và Hủy đối với ca đang Chờ tiếp đón -->
                                                                <c:if test="${appt.status == 'Pending' || (empty appt.checkinTime && appt.status != 'Canceled' && appt.status != 'Completed')}">
                                                                    <!-- 2. Check-in tiếp đón -->
                                                                    <button type="button"
                                                                        class="action-btn checkin btn-trigger-checkin"
                                                                        title="Check-in tiếp đón" data-bs-toggle="tooltip"
                                                                        data-id="${appt.id}"
                                                                        data-name="${appt.patientName}"
                                                                        data-phone="${appt.phone}"
                                                                        data-doctor="${appt.doctorName}"
                                                                        data-room="${appt.roomName}"
                                                                        data-doctor-id="${appt.doctorId > 0 ? appt.doctorId : 0}"
                                                                        data-time="${appt.timeSlot}">
                                                                        <i class="bi bi-box-arrow-in-right"></i>
                                                                    </button>

                                                                    <!-- 3. Hủy lịch hẹn (Đỏ pastel - icon thùng rác giống Quản lý người dùng) -->
                                                                    <button type="button"
                                                                        class="action-btn delete btn-trigger-cancel"
                                                                        title="Hủy lịch hẹn" data-bs-toggle="tooltip"
                                                                        data-id="${appt.id}"
                                                                        data-name="${appt.patientName}"
                                                                        data-doctor="${appt.doctorName}"
                                                                        data-time="${appt.timeSlot}"
                                                                        data-date="${appt.appointmentDate}">
                                                                        <i class="bi bi-trash"></i>
                                                                    </button>
                                                                </c:if>

                                                                <!-- Ca Đã tiếp đón / Đang khám: Nút Vàng pastel dẫn sang Hàng đợi phòng khám -->
                                                                <c:if test="${appt.status == 'Confirmed' || appt.status == 'In_Progress'}">
                                                                    <a href="${pageContext.request.contextPath}/staff/waiting-list"
                                                                        class="action-btn warning"
                                                                        title="Xem trong Hàng đợi phòng khám" data-bs-toggle="tooltip">
                                                                        <i class="bi bi-people-fill"></i>
                                                                    </a>
                                                                </c:if>


                                                            </div>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr>
                                                    <td colspan="7" class="text-center py-5">
                                                        <div class="text-muted">
                                                            <c:choose>
                                                                <c:when test="${selectedStatus == 'Canceled'}">
                                                                    <i class="bi bi-check-circle fs-1 d-block mb-2 text-secondary"></i>
                                                                    <p class="mb-1 fw-semibold text-dark">Không có ca khám nào bị hủy hoặc báo vắng mặt!</p>
                                                                    <p class="small text-muted">Tất cả bệnh nhân đều đến đúng hẹn hoặc chưa phát sinh vắng mặt.</p>
                                                                </c:when>
                                                                <c:when test="${selectedStatus == 'CheckedIn'}">
                                                                    <i class="bi bi-inbox fs-1 d-block mb-2 text-secondary"></i>
                                                                    <p class="mb-1 fw-semibold text-dark">Chưa có bệnh nhân nào được tiếp đón trong ngày này.</p>
                                                                    <p class="small text-muted">Vui lòng tiếp đón bệnh nhân ở mục "Chờ tiếp đón".</p>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <i class="bi bi-check2-circle fs-1 d-block mb-2 text-success"></i>
                                                                    <p class="mb-1 fw-semibold text-dark">Hiện không có lịch hẹn nào đang chờ tiếp đón!</p>
                                                                    <p class="small text-muted">Tất cả bệnh nhân hôm nay đã được check-in hoặc chưa có lịch hẹn mới.</p>
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
                                <div>Hiển thị <strong>${appointments.size()}</strong> lịch hẹn</div>
                                <div>Cập nhật lúc: <span id="currentTimeSpan"></span></div>
                            </div>
                        </div>

                    </div>
                </main>

                <!-- Modal Xác nhận Check-in (Thiết kế đồng bộ với hệ thống theo hình ảnh) -->
                <div class="modal fade" id="checkinModal" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered" style="max-width: 420px;">
                        <div class="modal-content">
                            <div class="modal-header">
                                <button type="button" class="btn-close" data-bs-dismiss="modal"
                                    aria-label="Close"></button>
                            </div>
                            <div class="modal-body">
                                <div class="modal-icon-warning">
                                    <i class="bi bi-box-arrow-in-right"></i>
                                </div>
                                <h3 class="modal-title-custom">Xác nhận check-in?</h3>
                                <p class="modal-text">
                                    Bệnh nhân <strong id="modalPatientName" class="text-dark">---</strong> sẽ được xác
                                    nhận tiếp đón và chuyển vào hàng đợi phòng khám.
                                </p>
                                <form action="${pageContext.request.contextPath}/staff/check-in" method="post"
                                    id="checkinForm" class="m-0">
                                    <input type="hidden" name="action" value="checkin">
                                    <input type="hidden" name="appointmentId" id="modalAppointmentId">
                                    <input type="hidden" name="doctorId" id="modalDoctorId">
                                    <input type="hidden" name="returnUrl"
                                        value="${pageContext.request.contextPath}/staff/appointments${not empty pageContext.request.queryString ? '?'.concat(pageContext.request.queryString) : ''}">
                                    <div class="modal-actions">
                                        <button type="button" class="btn btn-modal-cancel"
                                            data-bs-dismiss="modal">Hủy</button>
                                        <button type="submit" class="btn btn-modal-warning">Check-in</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Modal Xác nhận Hủy Lịch Hẹn -->
                <div class="modal fade" id="cancelModal" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered" style="max-width: 430px;">
                        <div class="modal-content">
                            <div class="modal-header">
                                <button type="button" class="btn-close" data-bs-dismiss="modal"
                                    aria-label="Close"></button>
                            </div>
                            <div class="modal-body">
                                <div class="modal-icon-danger">
                                    <i class="bi bi-calendar-x"></i>
                                </div>
                                <h3 class="modal-title-custom">Xác nhận hủy lịch hẹn?</h3>
                                <p class="modal-text mb-3">
                                    Bệnh nhân <strong id="modalCancelPatientName" class="text-dark">---</strong> (<span
                                        id="modalCancelApptCode" class="fw-bold text-secondary">#APPT-0</span>) sẽ được
                                    hủy lịch khám và giải phóng ca cho bác sĩ.
                                </p>
                                <form action="${pageContext.request.contextPath}/staff/appointments" method="post"
                                    id="cancelForm" class="m-0 text-start">
                                    <input type="hidden" name="action" value="cancel">
                                    <input type="hidden" name="appointmentId" id="modalCancelAppointmentId">
                                    <input type="hidden" name="returnUrl"
                                        value="${pageContext.request.contextPath}/staff/appointments${not empty pageContext.request.queryString ? '?'.concat(pageContext.request.queryString) : ''}">

                                    <div class="mb-3">
                                        <label class="form-label small fw-semibold text-dark mb-1.5">
                                            Lý do hủy lịch <span class="text-danger">*</span>
                                        </label>
                                        <select name="cancelReasonSelect" id="cancelReasonSelect"
                                            class="form-select form-select-sm shadow-none mb-2"
                                            style="border-radius: 8px; font-size: 13.5px;"
                                            onchange="toggleCustomReason(this)">
                                            <option value="Liên hệ nhưng bệnh nhân báo bận không đến khám">Liên hệ nhưng bệnh nhân báo bận không đến khám</option>
                                            <option value="Bệnh nhân báo bận, yêu cầu đổi lịch sang ngày khác">Bệnh nhân
                                                báo bận, yêu cầu đổi lịch sang ngày khác</option>
                                            <option value="Bệnh nhân không có nhu cầu khám nữa">Bệnh nhân không có nhu
                                                cầu khám nữa</option>
                                            <option value="Bệnh nhân đặt trùng / sai thông tin">Bệnh nhân đặt trùng /
                                                sai thông tin</option>
                                            <option value="other">Lý do khác (Nhập ghi chú)...</option>
                                        </select>
                                        <textarea name="cancelReasonCustom" id="cancelReasonCustom"
                                            class="form-control form-control-sm shadow-none d-none" rows="2"
                                            placeholder="Nhập lý do hủy chi tiết..."
                                            style="border-radius: 8px; font-size: 13px;"></textarea>
                                    </div>

                                    <div class="modal-actions">
                                        <button type="button" class="btn btn-modal-cancel"
                                            data-bs-dismiss="modal">Đóng</button>
                                        <button type="submit" class="btn btn-modal-danger">
                                            <i class="bi bi-x-circle me-1"></i> Hủy lịch
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>


                <!-- Bootstrap 5 JS -->
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
                <script>
                    function openCheckinModal(id, patientName, phone, doctorName, roomName, doctorId, timeSlot) {
                        var idInput = document.getElementById('modalAppointmentId');
                        if (idInput) idInput.value = id;
                        var docInput = document.getElementById('modalDoctorId');
                        if (docInput) docInput.value = doctorId || '';
                        var nameElem = document.getElementById('modalPatientName');
                        if (nameElem) nameElem.textContent = patientName || 'này';

                        var modalElem = document.getElementById('checkinModal');
                        if (modalElem) {
                            var modal = bootstrap.Modal.getInstance(modalElem) || new bootstrap.Modal(modalElem);
                            modal.show();
                        }
                    }

                    // Bắt sự kiện click nút Check-in
                    document.addEventListener('click', function (e) {
                        var btn = e.target.closest('.btn-trigger-checkin');
                        if (btn) {
                            var id = btn.getAttribute('data-id');
                            var name = btn.getAttribute('data-name');
                            var phone = btn.getAttribute('data-phone');
                            var doctor = btn.getAttribute('data-doctor');
                            var room = btn.getAttribute('data-room');
                            var doctorId = btn.getAttribute('data-doctor-id');
                            var time = btn.getAttribute('data-time');
                            openCheckinModal(id, name, phone, doctor, room, doctorId, time);
                        }
                    });

                    // Bật/tắt ô nhập lý do khác khi hủy lịch
                    function toggleCustomReason(select) {
                        var custom = document.getElementById('cancelReasonCustom');
                        if (custom) {
                            if (select.value === 'other') {
                                custom.classList.remove('d-none');
                                custom.focus();
                            } else {
                                custom.classList.add('d-none');
                                custom.value = '';
                            }
                        }
                    }

                    // Bắt sự kiện click nút Hủy lịch
                    document.addEventListener('click', function (e) {
                        var btn = e.target.closest('.btn-trigger-cancel');
                        if (btn) {
                            var id = btn.getAttribute('data-id');
                            var name = btn.getAttribute('data-name');

                            var idInput = document.getElementById('modalCancelAppointmentId');
                            if (idInput) idInput.value = id;

                            var nameElem = document.getElementById('modalCancelPatientName');
                            if (nameElem) nameElem.textContent = name || 'này';

                            var codeElem = document.getElementById('modalCancelApptCode');
                            if (codeElem) codeElem.textContent = '#APPT-' + id;

                            var selectElem = document.getElementById('cancelReasonSelect');
                            if (selectElem) selectElem.value = 'Bệnh nhân báo bận, yêu cầu đổi lịch sang ngày khác';

                            var customElem = document.getElementById('cancelReasonCustom');
                            if (customElem) {
                                customElem.classList.add('d-none');
                                customElem.value = '';
                            }

                            var modalElem = document.getElementById('cancelModal');
                            if (modalElem) {
                                var modal = bootstrap.Modal.getInstance(modalElem) || new bootstrap.Modal(modalElem);
                                modal.show();
                            }
                        }
                    });


                    // Live clock
                    function updateClock() {
                        var now = new Date();
                        var str = now.toLocaleTimeString('vi-VN') + ' ' + now.toLocaleDateString('vi-VN');
                        var elem = document.getElementById('currentTimeSpan');
                        if (elem) elem.textContent = str;
                    }
                    updateClock();
                    setInterval(updateClock, 1000);
                </script>
            </body>

            </html>