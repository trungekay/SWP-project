<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
                                <button type="button" class="btn btn-teal shadow-sm d-flex align-items-center gap-2"
                                    data-bs-toggle="modal" data-bs-target="#walkinModal">
                                    <i class="bi bi-person-plus-fill"></i>
                                    <span>Tiếp đón khách vãng lai</span>
                                </button>
                                <a href="${pageContext.request.contextPath}/staff/waiting-list" class="btn btn-teal-outline">
                                    <i class="bi bi-people-fill"></i> Xem Hàng đợi phòng khám
                                </a>
                            </div>
                        </div>

                        <!-- KPI Summary Cards (Bấm để lọc theo trạng thái) -->
                        <div class="row g-3 mb-4 align-items-stretch">
                            <!-- 1. Tổng lịch hẹn -->
                            <div class="col-sm-6 col-xl-3 d-flex">
                                <a href="${pageContext.request.contextPath}/staff/appointments?date=${selectedDate}&status=all&doctorId=${selectedDoctorId}&keyword=${param.keyword}"
                                    class="metric-card w-100 text-decoration-none ${selectedStatus == 'all' || empty selectedStatus ? 'border border-2 border-primary shadow-sm bg-light' : ''}">
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
                                    <!-- 1. Thanh tìm kiếm nhanh (Tên, SĐT) -->
                                    <div class="search-filter-input flex-grow-1" style="max-width: 520px;">
                                        <i class="bi bi-search"></i>
                                        <input type="text" name="keyword" value="${param.keyword}" class="w-100"
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

                                        <!-- Nút Tra cứu & Nút Tải lại -->
                                        <div class="d-flex align-items-center gap-2">
                                            <button type="submit"
                                                class="btn btn-teal px-3.5 text-nowrap d-flex align-items-center justify-content-center gap-1.5 shadow-sm"
                                                style="height: 40px; font-weight: 600;">
                                                <i class="bi bi-search"></i>
                                                <span>Tra cứu</span>
                                            </button>
                                            <a href="${pageContext.request.contextPath}/staff/appointments?status=all"
                                                class="btn btn-outline-secondary px-3 text-nowrap d-flex align-items-center justify-content-center gap-1.5 shadow-sm"
                                                style="height: 40px; font-weight: 500; border-radius: 8px;"
                                                title="Tải lại danh sách (Tất cả lịch hẹn)">
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
                                    <a href="${pageContext.request.contextPath}/staff/appointments?date=${selectedDate}&status=all&doctorId=${selectedDoctorId}&keyword=${param.keyword}"
                                        class="btn btn-sm ${selectedStatus == 'all' || empty selectedStatus ? 'btn-dark fw-bold shadow-sm' : 'btn-white border text-secondary'} rounded-pill px-3">
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
                                                    <tr class="${appt.status == 'In_Progress' ? 'row-examining' : ''}">
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
                                                                <c:choose>
                                                                    <c:when test="${not empty appt.timeSlot && not empty appt.endTime}">
                                                                        ${appt.timeSlot} - ${appt.endTime}
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        ${appt.timeSlot}
                                                                    </c:otherwise>
                                                                </c:choose>
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

                                                        <c:set var="currentDateStr"><%= java.time.LocalDate.now().toString() %></c:set>
                                                        <c:set var="apptDateStr">${appt.appointmentDate}</c:set>
                                                        <c:set var="isPastAppt" value="${not empty apptDateStr && apptDateStr < currentDateStr}" />

                                                        <!-- Trạng Thái (Thống nhất tiếng Việt & màu sắc) -->
                                                        <td class="text-center text-nowrap">
                                                            <c:choose>
                                                                <c:when test="${appt.status == 'Pending' && isPastAppt}">
                                                                    <span class="badge-status badge-canceled" title="Đã qua ngày khám - Bệnh nhân không đến tiếp đón">
                                                                        Đã qua ngày
                                                                    </span>
                                                                </c:when>
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

                                                        <!-- Thao Tác (Khi đã qua ngày: chỉ cho phép xem chi tiết & ghi chú y tế) -->
                                                        <td class="text-center text-nowrap">
                                                            <div class="action-btns justify-content-center">
                                                                <!-- 1. Xem chi tiết & Ghi chú y tế: Luôn hiển thị cho tất cả các ca khám -->
                                                                <a href="${pageContext.request.contextPath}/staff/appointment-detail?id=${appt.id}"
                                                                    class="action-btn"
                                                                    title="Xem chi tiết & Ghi chú y tế" data-bs-toggle="tooltip">
                                                                    <i class="bi bi-pencil"></i>
                                                                </a>

                                                                <!-- Các thao tác tiếp đón & hủy: Chỉ hiển thị khi ca khám CHƯA qua ngày -->
                                                                <c:if test="${!isPastAppt}">
                                                                    <!-- 2. Check-in tiếp đón -->
                                                                    <c:if test="${appt.status == 'Pending' || (empty appt.checkinTime && appt.status != 'Canceled' && appt.status != 'Completed')}">
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

                                                                        <!-- 3. Hủy lịch hẹn -->
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

                                                                    <!-- 4. Ca Đã tiếp đón / Đang khám hôm nay: Nút sang Hàng đợi phòng khám -->
                                                                    <c:if test="${appt.status == 'Confirmed' || appt.status == 'In_Progress'}">
                                                                        <a href="${pageContext.request.contextPath}/staff/waiting-list"
                                                                            class="action-btn warning"
                                                                            title="Xem trong Hàng đợi phòng khám" data-bs-toggle="tooltip">
                                                                            <i class="bi bi-people-fill"></i>
                                                                        </a>
                                                                    </c:if>
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

                <!-- Modal Tiếp Đón Khách Vãng Lai (Walk-in Patient Check-in) -->
                <div class="modal fade" id="walkinModal" tabindex="-1" aria-labelledby="walkinModalLabel" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered" style="max-width: 620px;">
                        <div class="modal-content shadow-lg border-0" style="border-radius: 16px; overflow: hidden;">
                            <div class="modal-header border-bottom px-4 py-3 bg-light">
                                <div class="d-flex align-items-center gap-2">
                                    <div style="width: 38px; height: 38px; border-radius: 10px; background: rgba(0, 139, 116, 0.12); color: var(--primary-color); display: flex; align-items: center; justify-content: center; font-size: 19px;">
                                        <i class="bi bi-person-plus-fill"></i>
                                    </div>
                                    <div>
                                        <h5 class="modal-title fw-bold text-dark mb-0" id="walkinModalLabel" style="font-size: 17px;">Tiếp đón Khách vãng lai</h5>
                                        <small class="text-secondary" style="font-size: 12.5px;">Tạo hồ sơ và chuyển thẳng vào hàng đợi khám hôm nay</small>
                                    </div>
                                </div>
                                <button type="button" class="btn-close shadow-none" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>

                            <form action="${pageContext.request.contextPath}/staff/appointments" method="post" id="walkinForm" class="m-0">
                                <input type="hidden" name="action" value="walkin">
                                <input type="hidden" name="returnUrl" value="${pageContext.request.contextPath}/staff/waiting-list">

                                <div class="modal-body p-4 text-start">
                                    <!-- Banner hướng dẫn -->
                                    <div class="p-2.5 px-3 mb-3 rounded-3 d-flex align-items-start gap-2.5" style="background-color: #f0fdfa; border: 1px solid #ccfbf1;">
                                        <i class="bi bi-info-circle-fill text-teal mt-0.5" style="font-size: 15px;"></i>
                                        <div style="font-size: 13px; color: #0f766e; line-height: 1.45;">
                                            Bệnh nhân đến trực tiếp quầy tiếp đón chưa đặt trước sẽ được tạo lịch, tự động check-in và cấp số thứ tự vào phòng khám ngay.
                                        </div>
                                    </div>

                                    <div class="row g-3">
                                        <!-- Họ và tên -->
                                        <div class="col-md-7">
                                            <label class="form-label small fw-semibold text-dark mb-1">
                                                Họ và tên bệnh nhân <span class="text-danger">*</span>
                                            </label>
                                            <input type="text" name="patientName" id="walkinPatientName" required autocomplete="off"
                                                class="form-control form-control-sm shadow-none"
                                                placeholder="Ví dụ: Nguyễn Văn An"
                                                style="border-radius: 8px; font-size: 13.5px; padding: 7px 12px;"
                                                oninput="this.value = this.value.replace(/[0-9]/g, ''); validateWalkinName();"
                                                onblur="validateWalkinName();">
                                            <div id="walkinNameFeedback" class="small mt-1" style="min-height: 18px;"></div>
                                        </div>

                                        <!-- Số điện thoại -->
                                        <div class="col-md-5">
                                            <label class="form-label small fw-semibold text-dark mb-1">
                                                Số điện thoại <span class="text-danger">*</span>
                                            </label>
                                            <input type="tel" name="phone" id="walkinPhone" required pattern="0[0-9]{9}"
                                                class="form-control form-control-sm shadow-none"
                                                placeholder="0901234567 (10 số)"
                                                style="border-radius: 8px; font-size: 13.5px; padding: 7px 12px;"
                                                oninput="checkWalkinPhone(this.value)"
                                                onchange="checkWalkinPhone(this.value)"
                                                onblur="checkWalkinPhone(this.value)">
                                            <div id="phoneCheckFeedback" class="mt-1" style="min-height: 18px;"></div>
                                        </div>

                                        <!-- Dịch vụ khám ban đầu -->
                                        <div class="col-md-7">
                                            <label class="form-label small fw-semibold text-dark mb-1">
                                                Dịch vụ khám ban đầu <span class="text-danger">*</span>
                                            </label>
                                            <select name="serviceId" id="walkinServiceId" required class="form-select form-select-sm shadow-none"
                                                style="border-radius: 8px; font-size: 13px; padding: 7px 12px;"
                                                onchange="onWalkinServiceChange(this)">
                                                <option value="">-- Chọn gói dịch vụ khám mắt --</option>
                                                <c:forEach items="${services}" var="svc">
                                                    <option value="${svc.id}" 
                                                            data-price="${svc.price}" 
                                                            data-specialty="${svc.specialty}" 
                                                            data-name="${svc.name}"
                                                            data-code="${svc.code}"
                                                            ${svc.id == 1 ? 'selected' : ''}>
                                                        ${not empty svc.code ? svc.code : 'DV'} - ${svc.name} (<fmt:formatNumber value="${svc.price}" type="number" groupingUsed="true" /> ₫)
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>

                                        <!-- Ngày sinh -->
                                        <div class="col-md-5">
                                            <label class="form-label small fw-semibold text-dark mb-1">
                                                Ngày sinh <span class="text-muted fw-normal">(dd/mm/yyyy)</span>
                                            </label>
                                            <div class="input-group input-group-sm position-relative">
                                                <input type="text" name="dob" id="walkinDob" autocomplete="off"
                                                    class="form-control form-control-sm shadow-none"
                                                    placeholder="dd/mm/yyyy" maxlength="10"
                                                    style="border-radius: 8px 0 0 8px; font-size: 13.5px; padding: 7px 12px;"
                                                    oninput="formatDobInput(this); validateWalkinDob();"
                                                    onblur="validateWalkinDob();">
                                                <button type="button" class="btn btn-outline-secondary px-2.5" id="btnPickWalkinDob"
                                                    style="border-radius: 0 8px 8px 0; border-color: #cbd5e1; background: #f8fafc;"
                                                    title="Mở lịch chọn ngày sinh"
                                                    onclick="triggerNativeDobPicker()">
                                                    <i class="bi bi-calendar-event text-secondary"></i>
                                                </button>
                                                <input type="date" id="nativeDobPicker" tabindex="-1"
                                                    min="1900-01-01" max="${not empty todayStr ? todayStr : '2026-10-20'}"
                                                    style="position: absolute; right: 0; bottom: 0; opacity: 0; pointer-events: none; width: 0; height: 0;"
                                                    onchange="onNativeDobChange(this.value)">
                                            </div>
                                            <div id="walkinDobFeedback" class="small mt-1" style="min-height: 18px;"></div>
                                        </div>

                                        <!-- Bác sĩ phụ trách -->
                                        <div class="col-md-7">
                                            <label class="form-label small fw-semibold text-dark mb-1">
                                                Bác sĩ khám <span class="text-danger">*</span>
                                            </label>
                                            <select name="doctorId" id="walkinDoctorId" required class="form-select form-select-sm shadow-none"
                                                style="border-radius: 8px; font-size: 13px; padding: 7px 12px;"
                                                onchange="onWalkinDoctorChange(this.value)">
                                                <option value="">-- Chọn bác sĩ khám --</option>
                                                <c:forEach items="${doctors}" var="doc">
                                                    <option value="${doc.id}" 
                                                            data-dept="${doc.departmentKey}" 
                                                            data-specialty="${doc.specialty}"
                                                            data-name="${doc.name}">
                                                        ${doc.name} - ${not empty doc.specialty ? doc.specialty : 'Chuyên khoa Mắt'}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>

                                        <!-- Khung giờ khám hôm nay -->
                                        <div class="col-md-5">
                                            <div class="d-flex align-items-center justify-content-between mb-1">
                                                <label class="form-label small fw-semibold text-dark mb-0">
                                                    Khung giờ khám <span class="text-danger">*</span>
                                                </label>
                                                <span id="slotAvailabilityHint" class="text-muted small" style="font-size: 11px;"></span>
                                            </div>
                                            <select name="timeSlot" id="walkinTimeSlot" class="form-select form-select-sm shadow-none"
                                                style="border-radius: 8px; font-size: 13px; padding: 7px 12px;">
                                                <option value="08:00" data-orig="08:00 - 08:30 (Sáng)">08:00 - 08:30 (Sáng)</option>
                                                <option value="08:30" data-orig="08:30 - 09:00 (Sáng)">08:30 - 09:00 (Sáng)</option>
                                                <option value="09:00" data-orig="09:00 - 09:30 (Sáng)">09:00 - 09:30 (Sáng)</option>
                                                <option value="09:30" data-orig="09:30 - 10:00 (Sáng)">09:30 - 10:00 (Sáng)</option>
                                                <option value="10:00" data-orig="10:00 - 10:30 (Sáng)">10:00 - 10:30 (Sáng)</option>
                                                <option value="10:30" data-orig="10:30 - 11:00 (Sáng)">10:30 - 11:00 (Sáng)</option>
                                                <option value="11:00" data-orig="11:00 - 11:30 (Sáng)">11:00 - 11:30 (Sáng)</option>
                                                <option value="13:30" data-orig="13:30 - 14:00 (Chiều)">13:30 - 14:00 (Chiều)</option>
                                                <option value="14:00" data-orig="14:00 - 14:30 (Chiều)">14:00 - 14:30 (Chiều)</option>
                                                <option value="14:30" data-orig="14:30 - 15:00 (Chiều)">14:30 - 15:00 (Chiều)</option>
                                                <option value="15:00" data-orig="15:00 - 15:30 (Chiều)">15:00 - 15:30 (Chiều)</option>
                                                <option value="15:30" data-orig="15:30 - 16:00 (Chiều)">15:30 - 16:00 (Chiều)</option>
                                                <option value="16:00" data-orig="16:00 - 16:30 (Chiều)">16:00 - 16:30 (Chiều)</option>
                                                <option value="16:30" data-orig="16:30 - 17:00 (Chiều)">16:30 - 17:00 (Chiều)</option>
                                            </select>
                                        </div>

                                        <!-- Thẻ Phí khám ban đầu & Phương thức thanh toán (Gọn gàng & Phù hợp) -->
                                        <div class="col-12">
                                            <div class="py-2 px-3 rounded-3 border" style="background: #f8fafc; border-color: #cbd5e1;">
                                                <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-1.5">
                                                    <div class="d-flex align-items-center gap-2">
                                                        <div class="rounded-circle d-flex align-items-center justify-content-center flex-shrink-0"
                                                            style="width: 30px; height: 30px; background: #e0f2fe; color: #0284c7;">
                                                            <i class="bi bi-wallet2 fs-6"></i>
                                                        </div>
                                                        <div>
                                                            <span class="text-secondary small d-block" style="font-size: 11px; line-height: 1.1;">
                                                                Phí khám ban đầu:
                                                            </span>
                                                            <span class="fw-bold fs-6 text-dark" id="walkinFeeDisplay" style="line-height: 1.2;">200.000 ₫</span>
                                                        </div>
                                                    </div>

                                                    <!-- Chọn hình thức thanh toán -->
                                                    <div class="btn-group p-0.5 rounded-3 bg-white border" role="group">
                                                        <input type="radio" class="btn-check" name="paymentMethod" id="payMethodCash" value="Cash_At_Counter" checked onchange="toggleWalkinPayMode('Cash_At_Counter')">
                                                        <label class="btn btn-sm btn-outline-success border-0 px-2.5 py-1 fw-semibold" for="payMethodCash" style="font-size: 12px; border-radius: 6px;">
                                                            <i class="bi bi-cash me-1"></i>Tiền mặt tại quầy
                                                        </label>

                                                        <input type="radio" class="btn-check" name="paymentMethod" id="payMethodQR" value="VietQR_Banking" onchange="toggleWalkinPayMode('VietQR_Banking')">
                                                        <label class="btn btn-sm btn-outline-primary border-0 px-2.5 py-1 fw-semibold" for="payMethodQR" style="font-size: 12px; border-radius: 6px;">
                                                            <i class="bi bi-qr-code-scan me-1"></i>Chuyển khoản VietQR
                                                        </label>
                                                    </div>
                                                </div>

                                                <!-- Ghi chú động theo hình thức đã chọn -->
                                                <div id="walkinPayCashNotice" class="d-flex align-items-center justify-content-between small text-success pt-1 border-top" style="font-size: 11px;">
                                                    <span><i class="bi bi-check2-circle me-1"></i>Thu tiền mặt trực tiếp tại quầy lễ tân (Hóa đơn Paid tự động)</span>
                                                    <span class="badge bg-success-subtle text-success border border-success-subtle py-0.5">Vào thẳng hàng đợi</span>
                                                </div>
                                                <div id="walkinPayQRNotice" class="d-none align-items-center justify-content-between small text-primary pt-1 border-top" style="font-size: 11px;">
                                                    <span><i class="bi bi-qr-code me-1"></i>Bệnh nhân quét mã VietQR MB Bank theo đúng giá dịch vụ đã chọn</span>
                                                    <span class="badge bg-primary-subtle text-primary border border-primary-subtle py-0.5">Cần thanh toán QR</span>
                                                </div>
                                            </div>
                                            <span id="walkinSvcTag" class="d-none"></span>
                                        </div>

                                        <!-- Lý do khám / Triệu chứng ban đầu -->
                                        <div class="col-12">
                                            <label class="form-label small fw-semibold text-dark mb-1">
                                                Triệu chứng / Lý do khám <span class="text-muted fw-normal">(Ghi chú ban đầu)</span>
                                            </label>
                                            <textarea name="reason" id="walkinReasonText" rows="2"
                                                class="form-control form-control-sm shadow-none mb-1.5"
                                                placeholder="Ví dụ: Đau cộm mắt phải 2 ngày nay, nhìn mờ dần..."
                                                style="border-radius: 8px; font-size: 13px;"></textarea>

                                            <!-- Gợi ý triệu chứng nhanh -->
                                            <div class="d-flex align-items-center gap-1.5 flex-wrap">
                                                <span class="text-secondary small" style="font-size: 12px;">Gợi ý nhanh:</span>
                                                <button type="button" class="btn btn-sm btn-light border py-0 px-2 rounded-pill text-secondary" style="font-size: 11.5px;" onclick="addWalkinTag('Khám mắt tổng quát')">+ Khám tổng quát</button>
                                                <button type="button" class="btn btn-sm btn-light border py-0 px-2 rounded-pill text-secondary" style="font-size: 11.5px;" onclick="addWalkinTag('Đau mắt đỏ / Cộm xốn')">+ Đau mắt đỏ</button>
                                                <button type="button" class="btn btn-sm btn-light border py-0 px-2 rounded-pill text-secondary" style="font-size: 11.5px;" onclick="addWalkinTag('Dị vật vào mắt')">+ Dị vật mắt</button>
                                                <button type="button" class="btn btn-sm btn-light border py-0 px-2 rounded-pill text-secondary" style="font-size: 11.5px;" onclick="addWalkinTag('Nhìn mờ đột ngột')">+ Nhìn mờ</button>
                                                <button type="button" class="btn btn-sm btn-light border py-0 px-2 rounded-pill text-secondary" style="font-size: 11.5px;" onclick="addWalkinTag('Đo khúc xạ / Cận loạn')">+ Đo khúc xạ</button>
                                            </div>
                                        </div>


                                    </div>

                                    <!-- Modal Actions -->
                                    <div class="d-flex align-items-center justify-content-end gap-2 mt-4 pt-3 border-top">
                                        <button type="button" class="btn btn-modal-cancel" data-bs-dismiss="modal">Đóng</button>
                                        <button type="submit" id="walkinSubmitBtn" class="btn btn-teal px-3.5 shadow-sm">
                                            <i class="bi bi-check2-circle me-1"></i> Xác nhận & Đưa vào hàng đợi
                                        </button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Modal Quét Mã VietQR Cho Khách Vãng Lai (Đồng bộ với Đặt lịch Bệnh nhân) -->
                <div class="modal fade" id="walkinQrModal" tabindex="-1" aria-labelledby="walkinQrModalLabel" aria-hidden="true" data-bs-backdrop="static">
                    <div class="modal-dialog modal-dialog-centered" style="max-width: 500px;">
                        <div class="modal-content shadow-lg border-0" style="border-radius: 16px; overflow: hidden;">
                            <div class="modal-header border-bottom px-4 py-3 bg-light">
                                <div class="d-flex align-items-center gap-2">
                                    <div style="width: 36px; height: 36px; border-radius: 10px; background: rgba(13, 148, 136, 0.12); color: #0d9488; display: flex; align-items: center; justify-content: center; font-size: 18px;">
                                        <i class="bi bi-qr-code-scan"></i>
                                    </div>
                                    <div>
                                        <h5 class="modal-title fw-bold text-dark mb-0" id="walkinQrModalLabel" style="font-size: 16px;">Quét mã VietQR thanh toán</h5>
                                        <small class="text-secondary" style="font-size: 12px;" id="qrPatientSubtitle">Bệnh nhân: Khách vãng lai</small>
                                    </div>
                                </div>
                                <button type="button" class="btn-close shadow-none" onclick="cancelWalkinQR()"></button>
                            </div>

                            <div class="modal-body p-4 text-center">
                                <!-- Banner trạng thái thanh toán tự động -->
                                <div class="alert alert-info py-2 px-3 small rounded-3 mb-3 d-flex align-items-center justify-content-center gap-2" id="qrStatusAlert" style="font-size: 12px;">
                                    <span class="spinner-grow spinner-grow-sm text-primary" role="status" id="qrSpinner"></span>
                                    <span id="qrStatusText">Đang chờ bệnh nhân quét mã và chuyển khoản...</span>
                                </div>

                                <!-- Khung ảnh VietQR động -->
                                <div class="position-relative d-inline-block p-2 bg-white rounded-3 border shadow-sm mb-3">
                                    <img id="walkinQrImg" src="" alt="VietQR VisionCare" class="img-fluid rounded" style="max-width: 240px; min-height: 240px;">
                                    <div id="qrPaidOverlay" class="position-absolute top-0 start-0 w-100 h-100 d-none flex-column align-items-center justify-content-center rounded" style="background: rgba(240, 253, 244, 0.95); z-index: 10;">
                                        <div class="rounded-circle bg-success text-white d-flex align-items-center justify-content-center mb-2" style="width: 52px; height: 52px; font-size: 26px;">
                                            <i class="bi bi-check-lg"></i>
                                        </div>
                                        <h6 class="fw-bold text-success mb-1">Thanh toán thành công!</h6>
                                        <small class="text-secondary">Đang chuyển bệnh nhân vào hàng đợi...</small>
                                    </div>
                                </div>

                                <!-- Bảng thông tin thanh toán chuyển khoản -->
                                <div class="bg-light p-3 rounded-3 text-start small border mb-3" style="font-size: 12.5px;">
                                    <div class="d-flex justify-content-between py-1 border-bottom">
                                        <span class="text-muted">Số tiền thanh toán:</span>
                                        <span class="fw-bold fs-6 text-success" id="qrFeeAmount">200.000 ₫</span>
                                    </div>
                                    <div class="d-flex justify-content-between py-1 border-bottom">
                                        <span class="text-muted">Ngân hàng thụ hưởng:</span>
                                        <span class="fw-semibold text-dark" id="qrBankName">MB Bank (Quân Đội)</span>
                                    </div>
                                    <div class="d-flex justify-content-between py-1 border-bottom">
                                        <span class="text-muted">Số tài khoản:</span>
                                        <span class="fw-bold text-dark font-monospace" id="qrAccountNumber">0877757889</span>
                                    </div>
                                    <div class="d-flex justify-content-between py-1 border-bottom">
                                        <span class="text-muted">Chủ tài khoản:</span>
                                        <span class="fw-semibold text-dark" id="qrAccountHolder">NGUYEN DINH TRUNG</span>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center py-1">
                                        <span class="text-muted">Nội dung chuyển khoản:</span>
                                        <span class="fw-bold text-danger font-monospace px-1.5 py-0.5 bg-white border rounded" id="qrTransferDesc">VC...</span>
                                    </div>
                                </div>

                                <p class="text-muted small mb-0" style="font-size: 11.5px;">
                                    <i class="bi bi-shield-check text-success me-1"></i>Hệ thống tự động đồng bộ qua PayOS &amp; VietQR NAPAS 247.
                                </p>
                            </div>

                            <div class="modal-footer px-4 py-3 bg-light border-top d-flex justify-content-between">
                                <button type="button" class="btn btn-outline-secondary btn-sm px-3" onclick="cancelWalkinQR()">
                                    <i class="bi bi-arrow-left me-1"></i>Hủy / Quay lại
                                </button>
                                <button type="button" class="btn btn-success btn-sm px-3 fw-semibold shadow-sm" id="btnManualConfirmQR" onclick="manualConfirmWalkinQR()">
                                    <i class="bi bi-check2-circle me-1"></i>Lễ tân xác nhận đã nhận tiền
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Modal Xác Nhận Thu Tiền Mặt Cho Khách Vãng Lai -->
                <div class="modal fade" id="walkinCashModal" tabindex="-1" aria-labelledby="walkinCashModalLabel" aria-hidden="true" data-bs-backdrop="static">
                    <div class="modal-dialog modal-dialog-centered" style="max-width: 480px;">
                        <div class="modal-content shadow-lg border-0" style="border-radius: 16px; overflow: hidden; position: relative;">
                            
                            <!-- Success Overlay khi thu tiền mặt thành công -->
                            <div id="cashSuccessOverlay" class="position-absolute top-0 start-0 w-100 h-100 d-none flex-column align-items-center justify-content-center" style="background: rgba(240, 253, 244, 0.96); z-index: 1055;">
                                <div class="rounded-circle bg-success text-white d-flex align-items-center justify-content-center mb-2 shadow" style="width: 56px; height: 56px; font-size: 28px;">
                                    <i class="bi bi-check-lg"></i>
                                </div>
                                <h5 class="fw-bold text-success mb-1">Thu tiền mặt thành công!</h5>
                                <p class="text-secondary small mb-0">Đang chuyển bệnh nhân vào hàng đợi khám...</p>
                            </div>

                            <div class="modal-header border-bottom px-4 py-3 bg-light">
                                <div class="d-flex align-items-center gap-2">
                                    <div style="width: 38px; height: 38px; border-radius: 10px; background: rgba(16, 185, 129, 0.14); color: #059669; display: flex; align-items: center; justify-content: center; font-size: 20px;">
                                        <i class="bi bi-cash-stack"></i>
                                    </div>
                                    <div>
                                        <h5 class="modal-title fw-bold text-dark mb-0" id="walkinCashModalLabel" style="font-size: 16px;">Xác nhận thu tiền mặt tại quầy</h5>
                                        <small class="text-secondary" style="font-size: 12px;" id="cashPatientSubtitle">Bệnh nhân: Khách vãng lai</small>
                                    </div>
                                </div>
                                <button type="button" class="btn-close shadow-none" onclick="cancelWalkinCash()"></button>
                            </div>

                            <div class="modal-body p-4 text-start">
                                <!-- Banner thông báo lỗi nếu có -->
                                <div id="cashErrorAlert" class="alert alert-danger py-2 px-3 small rounded-3 mb-3 d-none align-items-center gap-2" style="font-size: 12.5px;">
                                    <i class="bi bi-exclamation-triangle-fill flex-shrink-0"></i>
                                    <span id="cashErrorText"></span>
                                </div>

                                <!-- Thẻ số tiền cần thu to rõ ràng -->
                                <div class="p-3 rounded-3 text-center mb-3" style="background: linear-gradient(135deg, #ecfdf5 0%, #f0fdf4 100%); border: 1.5px solid #a7f3d0;">
                                    <div class="text-secondary small fw-semibold text-uppercase" style="letter-spacing: 0.5px; font-size: 11px;">Số tiền cần thu từ bệnh nhân</div>
                                    <div class="fw-bold text-success display-6 my-1" style="font-size: 28px;" id="cashTotalFee">200.000 ₫</div>
                                    <span class="badge bg-success-subtle text-success border border-success-subtle py-1 px-2" style="font-size: 11.5px;">
                                        <i class="bi bi-shield-check me-1"></i>Hóa đơn sẽ tự động chuyển: ĐÃ THANH TOÁN (PAID)
                                    </span>
                                </div>

                                <!-- Bảng tóm tắt thông tin tiếp đón -->
                                <div class="bg-light p-3 rounded-3 small border mb-3" style="font-size: 12.5px;">
                                    <div class="d-flex justify-content-between py-1 border-bottom">
                                        <span class="text-muted">Họ và tên bệnh nhân:</span>
                                        <strong class="text-dark" id="cashModalPatientName">---</strong>
                                    </div>
                                    <div class="d-flex justify-content-between py-1 border-bottom">
                                        <span class="text-muted">Số điện thoại:</span>
                                        <strong class="text-dark font-monospace" id="cashModalPhone">---</strong>
                                    </div>
                                    <div class="d-flex justify-content-between py-1 border-bottom">
                                        <span class="text-muted">Gói dịch vụ:</span>
                                        <span class="fw-semibold text-dark text-end" id="cashModalServiceName" style="max-width: 60%;">---</span>
                                    </div>
                                    <div class="d-flex justify-content-between py-1 border-bottom">
                                        <span class="text-muted">Bác sĩ tiếp đón:</span>
                                        <span class="fw-semibold text-primary" id="cashModalDoctorName">---</span>
                                    </div>
                                    <div class="d-flex justify-content-between py-1">
                                        <span class="text-muted">Khung giờ khám:</span>
                                        <span class="badge bg-secondary-subtle text-secondary border py-0.5 px-2" id="cashModalTimeSlot">---</span>
                                    </div>
                                </div>

                                <!-- Tiện ích tính tiền thối lại cho lễ tân -->
                                <div class="border rounded-3 p-3" style="background: #ffffff;">
                                    <label class="form-label small fw-semibold text-dark mb-1.5 d-flex justify-content-between">
                                        <span>Tiền khách đưa:</span>
                                        <span class="text-muted fw-normal" style="font-size: 11.5px;">(Không bắt buộc)</span>
                                    </label>
                                    <div class="input-group input-group-sm mb-2">
                                        <input type="text" id="cashGivenInput" class="form-control form-control-sm text-end fw-bold shadow-none" placeholder="Nhập số tiền..." style="font-size: 14px; border-radius: 6px 0 0 6px;" oninput="onCashGivenChange(this.value)">
                                        <span class="input-group-text bg-light text-muted">₫</span>
                                    </div>

                                    <!-- Nút chọn nhanh mệnh giá -->
                                    <div class="d-flex gap-1.5 flex-wrap mb-2">
                                        <button type="button" class="btn btn-sm btn-outline-secondary py-0 px-2" style="font-size: 11.5px; border-radius: 6px;" onclick="setCashGivenPreset('exact')">Đưa đủ tiền</button>
                                        <button type="button" class="btn btn-sm btn-outline-secondary py-0 px-2" style="font-size: 11.5px; border-radius: 6px;" onclick="setCashGivenPreset(200000)">200.000 ₫</button>
                                        <button type="button" class="btn btn-sm btn-outline-secondary py-0 px-2" style="font-size: 11.5px; border-radius: 6px;" onclick="setCashGivenPreset(500000)">500.000 ₫</button>
                                    </div>

                                    <div class="d-flex justify-content-between align-items-center pt-2 border-top small" style="font-size: 12.5px;">
                                        <span class="text-secondary">Tiền thối lại cho khách:</span>
                                        <strong class="fs-6 text-primary" id="cashChangeAmount">0 ₫</strong>
                                    </div>
                                </div>
                            </div>

                            <div class="modal-footer px-4 py-3 bg-light border-top d-flex justify-content-between">
                                <button type="button" class="btn btn-outline-secondary btn-sm px-3" onclick="cancelWalkinCash()">
                                    <i class="bi bi-arrow-left me-1"></i>Hủy / Quay lại
                                </button>
                                <button type="button" class="btn btn-success btn-sm px-3.5 py-1.5 fw-semibold shadow-sm" id="btnConfirmCashPayment" onclick="submitWalkinCashPayment()">
                                    <i class="bi bi-check2-circle me-1"></i>Xác nhận đã nhận tiền & Đưa vào hàng đợi
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Bootstrap 5 JS -->
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
                <script>
                    function validateWalkinName() {
                        var nameInput = document.getElementById('walkinPatientName');
                        var feedback = document.getElementById('walkinNameFeedback');
                        if (!nameInput) return true;
                        var rawVal = nameInput.value || '';
                        // Tự động loại bỏ chữ số nếu người dùng gõ hoặc paste vào
                        if (/\d/.test(rawVal)) {
                            nameInput.value = rawVal.replace(/[0-9]/g, '');
                        }
                        var val = nameInput.value.trim();

                        if (!val) {
                            nameInput.classList.remove('is-valid');
                            nameInput.classList.add('is-invalid');
                            if (feedback) {
                                feedback.innerHTML = '<span class="text-danger"><i class="bi bi-x-circle me-1"></i>Vui lòng nhập họ và tên bệnh nhân!</span>';
                            }
                            return false;
                        }

                        // Họ tên chỉ được chứa chữ cái tiếng Việt/tiếng Anh và khoảng trắng, không chứa số hay ký tự đặc biệt
                        var nameRegex = /^[a-zA-ZàáảãạăắằẳẵặâấầẩẫậèéẻẽẹêếềểễệđìíỉĩịòóỏõọôốồổỗộơớờởỡợùúủũụưứừửữựỳýỷỹỵÀÁẢÃẠĂẮẰẲẴẶÂẤẦẨẪẬÈÉẺẼẸÊẾỀỂỄỆĐÌÍỈĨỊÒÓỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢÙÚỦŨỤƯỨỪỬỮỰỲÝỶỸỴ\s'-]+$/;
                        if (!nameRegex.test(val)) {
                            nameInput.classList.remove('is-valid');
                            nameInput.classList.add('is-invalid');
                            if (feedback) {
                                feedback.innerHTML = '<span class="text-danger"><i class="bi bi-x-circle me-1"></i>Họ và tên chỉ được ghi chữ, không được chứa chữ số hoặc ký tự đặc biệt!</span>';
                            }
                            return false;
                        }

                        if (val.length < 2) {
                            nameInput.classList.remove('is-valid');
                            nameInput.classList.add('is-invalid');
                            if (feedback) {
                                feedback.innerHTML = '<span class="text-danger"><i class="bi bi-x-circle me-1"></i>Họ và tên bệnh nhân phải có từ 2 ký tự trở lên!</span>';
                            }
                            return false;
                        }

                        nameInput.classList.remove('is-invalid');
                        nameInput.classList.add('is-valid');
                        if (feedback) {
                            feedback.innerHTML = '<span class="text-success"><i class="bi bi-check-circle me-1"></i>Họ và tên hợp lệ</span>';
                        }
                        return true;
                    }

                    function validateWalkinDob() {
                        var dobInput = document.getElementById('walkinDob');
                        var feedback = document.getElementById('walkinDobFeedback');
                        if (!dobInput) return true;
                        var val = (dobInput.value || '').trim();

                        if (!val) {
                            dobInput.classList.remove('is-invalid');
                            dobInput.classList.remove('is-valid');
                            if (feedback) feedback.innerHTML = '';
                            return true;
                        }

                        var parts = val.split('/');
                        if (parts.length !== 3 || parts[0].length !== 2 || parts[1].length !== 2 || parts[2].length !== 4) {
                            dobInput.classList.remove('is-valid');
                            dobInput.classList.add('is-invalid');
                            if (feedback) {
                                feedback.innerHTML = '<span class="text-danger"><i class="bi bi-x-circle me-1"></i>Ngày sinh phải đúng định dạng ngày/tháng/năm: dd/mm/yyyy!</span>';
                            }
                            return false;
                        }

                        var d = parseInt(parts[0], 10);
                        var m = parseInt(parts[1], 10);
                        var y = parseInt(parts[2], 10);

                        if (isNaN(d) || isNaN(m) || isNaN(y)) {
                            dobInput.classList.remove('is-valid');
                            dobInput.classList.add('is-invalid');
                            if (feedback) {
                                feedback.innerHTML = '<span class="text-danger"><i class="bi bi-x-circle me-1"></i>Ngày sinh không hợp lệ!</span>';
                            }
                            return false;
                        }

                        var now = new Date();
                        var currentYear = now.getFullYear();

                        // 1. Kiểm tra năm: Không được vượt quá năm hiện tại và phải từ 1900 trở lên
                        if (y > currentYear) {
                            dobInput.classList.remove('is-valid');
                            dobInput.classList.add('is-invalid');
                            if (feedback) {
                                feedback.innerHTML = '<span class="text-danger"><i class="bi bi-x-circle me-1"></i>Năm sinh (' + y + ') không được vượt quá năm hiện tại (' + currentYear + ')!</span>';
                            }
                            return false;
                        }
                        if (y < 1900) {
                            dobInput.classList.remove('is-valid');
                            dobInput.classList.add('is-invalid');
                            if (feedback) {
                                feedback.innerHTML = '<span class="text-danger"><i class="bi bi-x-circle me-1"></i>Năm sinh phải từ năm 1900 trở lên!</span>';
                            }
                            return false;
                        }

                        // 2. Kiểm tra tháng: 1 năm chỉ có 12 tháng (01 - 12)
                        if (m < 1 || m > 12) {
                            dobInput.classList.remove('is-valid');
                            dobInput.classList.add('is-invalid');
                            if (feedback) {
                                feedback.innerHTML = '<span class="text-danger"><i class="bi bi-x-circle me-1"></i>Tháng sinh (' + parts[1] + ') không hợp lệ! Một năm chỉ có 12 tháng (từ 01 đến 12).</span>';
                            }
                            return false;
                        }

                        // 3. Kiểm tra ngày: 1 tháng có 31 hoặc 30 ngày (riêng tháng 2 có 28 hoặc 29 ngày)
                        var isLeap = (y % 4 === 0 && y % 100 !== 0) || (y % 400 === 0);
                        var maxDays = 31;
                        if (m === 4 || m === 6 || m === 9 || m === 11) {
                            maxDays = 30;
                        } else if (m === 2) {
                            maxDays = isLeap ? 29 : 28;
                        }

                        if (d < 1 || d > maxDays) {
                            dobInput.classList.remove('is-valid');
                            dobInput.classList.add('is-invalid');
                            if (feedback) {
                                if (m === 2) {
                                    feedback.innerHTML = '<span class="text-danger"><i class="bi bi-x-circle me-1"></i>Tháng 2 năm ' + y + (isLeap ? ' (năm nhuận) chỉ có tối đa 29 ngày!' : ' chỉ có tối đa 28 ngày!') + '</span>';
                                } else {
                                    feedback.innerHTML = '<span class="text-danger"><i class="bi bi-x-circle me-1"></i>Tháng ' + m + ' chỉ có tối đa ' + maxDays + ' ngày! Ngày ' + d + ' không hợp lệ.</span>';
                                }
                            }
                            return false;
                        }

                        // 4. Kiểm tra ngày sinh không được ở tương lai (so với ngày hiện tại)
                        var dobDate = new Date(y, m - 1, d, 0, 0, 0);
                        var todayEnd = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59);
                        if (dobDate > todayEnd) {
                            dobInput.classList.remove('is-valid');
                            dobInput.classList.add('is-invalid');
                            if (feedback) {
                                feedback.innerHTML = '<span class="text-danger"><i class="bi bi-x-circle me-1"></i>Ngày sinh không được lớn hơn ngày hiện tại!</span>';
                            }
                            return false;
                        }

                        // Hợp lệ!
                        dobInput.classList.remove('is-invalid');
                        dobInput.classList.add('is-valid');
                        var nativePicker = document.getElementById('nativeDobPicker');
                        if (nativePicker) {
                            var mm = m < 10 ? '0' + m : m;
                            var dd = d < 10 ? '0' + d : d;
                            nativePicker.value = y + '-' + mm + '-' + dd;
                        }
                        if (feedback) {
                            var age = now.getFullYear() - y;
                            feedback.innerHTML = '<span class="text-success"><i class="bi bi-check-circle me-1"></i>Ngày sinh hợp lệ (' + age + ' tuổi)</span>';
                        }
                        return true;
                    }

                    function formatDobInput(input) {
                        var v = (input.value || '').replace(/[^0-9]/g, '');
                        if (v.length > 8) v = v.substring(0, 8);
                        var formatted = '';
                        if (v.length > 0) {
                            formatted = v.substring(0, Math.min(2, v.length));
                        }
                        if (v.length >= 3) {
                            formatted += '/' + v.substring(2, Math.min(4, v.length));
                        }
                        if (v.length >= 5) {
                            formatted += '/' + v.substring(4, 8);
                        }
                        input.value = formatted;

                        if (v.length === 8) {
                            validateWalkinDob();
                        } else if (v.length === 0) {
                            var feedback = document.getElementById('walkinDobFeedback');
                            if (feedback) feedback.innerHTML = '';
                            input.classList.remove('is-invalid');
                            input.classList.remove('is-valid');
                        }
                    }

                    function triggerNativeDobPicker() {
                        var nativePicker = document.getElementById('nativeDobPicker');
                        if (nativePicker) {
                            if (typeof nativePicker.showPicker === 'function') {
                                nativePicker.showPicker();
                            } else {
                                nativePicker.focus();
                                nativePicker.click();
                            }
                        }
                    }

                    function onNativeDobChange(val) {
                        if (!val) return;
                        var parts = val.split('-');
                        if (parts.length === 3) {
                            var dobInput = document.getElementById('walkinDob');
                            if (dobInput) {
                                dobInput.value = parts[2] + '/' + parts[1] + '/' + parts[0];
                                validateWalkinDob();
                            }
                        }
                    }

                    var phoneTimer = null;
                    function checkWalkinPhone(phone) {
                        clearTimeout(phoneTimer);
                        var feedback = document.getElementById('phoneCheckFeedback');
                        var submitBtn = document.getElementById('walkinSubmitBtn');
                        var nameInput = document.getElementById('walkinPatientName');
                        var dobInput = document.getElementById('walkinDob');
                        if (!feedback) return;

                        var cleanPhone = (phone || '').replace(/[^0-9]/g, '');
                        if (cleanPhone.length < 10) {
                            feedback.innerHTML = '';
                            if (submitBtn) submitBtn.disabled = false;
                            if (nameInput) nameInput.classList.remove('is-valid');
                            if (dobInput) dobInput.classList.remove('is-valid');
                            return;
                        }

                        feedback.innerHTML = '<span class="text-muted" style="font-size: 12px;"><i class="spinner-border spinner-border-sm me-1" style="width: 11px; height: 11px;"></i>Đang kiểm tra hồ sơ...</span>';

                        phoneTimer = setTimeout(function() {
                            fetch('${pageContext.request.contextPath}/staff/appointments?ajax=checkPhone&phone=' + encodeURIComponent(cleanPhone))
                                .then(function(res) {
                                    if (!res.ok) throw new Error("HTTP " + res.status);
                                    return res.text();
                                })
                                .then(function(text) {
                                    var data;
                                    try {
                                        data = JSON.parse(text);
                                    } catch (e) {
                                        console.warn("Máy chủ trả về HTML thay vì JSON. Cần Clean & Build / restart Tomcat trên NetBeans.", text);
                                        feedback.innerHTML = '<span class="text-warning small" style="font-size: 11.5px;"><i class="bi bi-exclamation-triangle me-1"></i>Chưa nhận servlet mới (Vui lòng Clean & Build lại dự án trên NetBeans)</span>';
                                        return;
                                    }

                                    if (data.found) {
                                        if (nameInput) {
                                            nameInput.value = data.name || '';
                                            nameInput.classList.add('is-valid');
                                        }
                                        if (dobInput) {
                                            if (data.dob && data.dob.indexOf('-') !== -1) {
                                                var p = data.dob.split('-');
                                                if (p.length === 3) {
                                                    dobInput.value = p[2] + '/' + p[1] + '/' + p[0];
                                                    var nativePicker = document.getElementById('nativeDobPicker');
                                                    if (nativePicker) nativePicker.value = data.dob;
                                                } else {
                                                    dobInput.value = data.dob;
                                                }
                                            } else {
                                                dobInput.value = data.dob || '';
                                            }
                                            if (dobInput.value) {
                                                dobInput.classList.add('is-valid');
                                            } else {
                                                dobInput.classList.remove('is-valid');
                                            }
                                        }

                                        if (data.hasApptToday) {
                                            var statusLabel = data.apptStatus === 'Pending' ? 'Chờ tiếp đón' : (data.apptStatus === 'Confirmed' ? 'Chờ khám' : data.apptStatus);
                                            var isPending = data.apptStatus === 'Pending';
                                            feedback.innerHTML = '<div class="alert alert-warning py-1 px-2 mb-0 mt-1 d-flex align-items-center justify-content-between" style="font-size: 11.5px; border-radius: 6px;">' +
                                                '<div><i class="bi bi-exclamation-triangle-fill text-warning me-1"></i>' +
                                                'Đã có hẹn <strong>#APPT-' + data.apptId + '</strong> (' + (data.apptTime || '') + ' - ' + (data.doctorName || '') + ' - ' + statusLabel + ')</div>' +
                                                (isPending ? '<button type="button" class="btn btn-warning py-0 px-2 fw-semibold ms-2 text-nowrap" style="font-size: 11px;" onclick="quickCheckinFromWalkin(' + data.apptId + ', \'' + (data.name || '').replace(/'/g, "\\'") + '\')">Check-in ngay</button>' : '') +
                                                '</div>';
                                            if (submitBtn) submitBtn.disabled = true;
                                        } else {
                                            feedback.innerHTML = '<span class="badge bg-success-subtle text-success border border-success-subtle py-1 px-2" style="font-size: 11.5px;"><i class="bi bi-person-check-fill me-1"></i>Đã tìm thấy: <strong>' + (data.name || '') + '</strong> (Đã tự động điền)</span>';
                                            if (submitBtn) submitBtn.disabled = false;
                                        }
                                    } else {
                                        if (nameInput) nameInput.classList.remove('is-valid');
                                        if (dobInput) dobInput.classList.remove('is-valid');
                                        feedback.innerHTML = '<span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle py-1 px-2" style="font-size: 11.5px;"><i class="bi bi-person-plus me-1"></i>SĐT mới (Khách hàng lần đầu)</span>';
                                        if (submitBtn) submitBtn.disabled = false;
                                    }
                                })
                                .catch(function(err) {
                                    console.error("Lỗi khi kiểm tra SĐT:", err);
                                    feedback.innerHTML = '';
                                    if (submitBtn) submitBtn.disabled = false;
                                });
                        }, 250);
                    }

                    function quickCheckinFromWalkin(apptId, name) {
                        var walkinModalEl = document.getElementById('walkinModal');
                        if (walkinModalEl) {
                            var modal = bootstrap.Modal.getInstance(walkinModalEl);
                            if (modal) modal.hide();
                        }
                        setTimeout(function() {
                            openCheckinModal(apptId, name);
                        }, 400);
                    }

                    function onWalkinServiceChange(selectElem) {
                        if (!selectElem) return;
                        var opt = selectElem.options[selectElem.selectedIndex];
                        if (!opt) return;

                        var price = parseFloat(opt.getAttribute('data-price') || 0);
                        var name = opt.getAttribute('data-name') || '';
                        var specialty = (opt.getAttribute('data-specialty') || '').toLowerCase().trim();

                        // 1. Cập nhật số tiền và tên dịch vụ trên thẻ Thu cọc / Phí khám
                        var feeDisplay = document.getElementById('walkinFeeDisplay');
                        if (feeDisplay) {
                            feeDisplay.textContent = price > 0 ? (price.toLocaleString('vi-VN') + ' ₫') : '200.000 ₫';
                        }
                        var btnFee = document.getElementById('btnFeeDisplay');
                        if (btnFee) {
                            btnFee.textContent = price > 0 ? (price.toLocaleString('vi-VN') + ' ₫') : '200.000 ₫';
                        }
                        var tag = document.getElementById('walkinSvcTag');
                        if (tag) {
                            tag.textContent = name || 'Khám chuyên khoa';
                        }

                        // 2. Tự động gợi ý Bác sĩ đúng chuyên khoa nếu bác sĩ hiện tại chưa phù hợp
                        if (specialty) {
                            var docSel = document.getElementById('walkinDoctorId');
                            if (docSel) {
                                var curOpt = docSel.options[docSel.selectedIndex];
                                var curDept = curOpt ? (curOpt.getAttribute('data-dept') || '').toLowerCase().trim() : '';
                                var curSpec = curOpt ? (curOpt.getAttribute('data-specialty') || '').toLowerCase().trim() : '';

                                var matchCurrent = (curDept === specialty || curSpec.includes(specialty) ||
                                    (specialty === 'refraction' && (curDept === 'refraction' || curSpec.includes('khúc xạ'))) ||
                                    (specialty === 'lasik' && (curDept === 'lasik' || curSpec.includes('lasik'))) ||
                                    (specialty === 'children' && (curDept === 'children' || curSpec.includes('trẻ em'))) ||
                                    (specialty === 'cataract' && (curDept === 'cataract' || curSpec.includes('thủy tinh thể') || curSpec.includes('phaco'))) ||
                                    (specialty === 'retina' && (curDept === 'retina' || curSpec.includes('glaucoma') || curSpec.includes('võng mạc'))));

                                if (!matchCurrent) {
                                    for (var i = 1; i < docSel.options.length; i++) {
                                        var dOpt = docSel.options[i];
                                        var dept = (dOpt.getAttribute('data-dept') || '').toLowerCase().trim();
                                        var spec = (dOpt.getAttribute('data-specialty') || '').toLowerCase().trim();
                                        if (dept === specialty || spec.includes(specialty) ||
                                            (specialty === 'refraction' && (dept === 'refraction' || spec.includes('khúc xạ'))) ||
                                            (specialty === 'lasik' && (dept === 'lasik' || spec.includes('lasik'))) ||
                                            (specialty === 'children' && (dept === 'children' || spec.includes('trẻ em'))) ||
                                            (specialty === 'cataract' && (dept === 'cataract' || spec.includes('thủy tinh thể') || spec.includes('phaco'))) ||
                                            (specialty === 'retina' && (dept === 'retina' || spec.includes('glaucoma') || spec.includes('võng mạc')))) {
                                            docSel.selectedIndex = i;
                                            onWalkinDoctorChange(dOpt.value, true);
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }

                    function onWalkinDoctorChange(doctorId, skipServiceSync) {
                        // Tự động đồng bộ sang dịch vụ tương ứng với Bác sĩ nếu chưa đồng bộ
                        if (!skipServiceSync && doctorId) {
                            var docSel = document.getElementById('walkinDoctorId');
                            var curOpt = docSel ? docSel.options[docSel.selectedIndex] : null;
                            if (curOpt) {
                                var docDept = (curOpt.getAttribute('data-dept') || '').toLowerCase().trim();
                                var docSpec = (curOpt.getAttribute('data-specialty') || '').toLowerCase().trim();
                                var svcSel = document.getElementById('walkinServiceId');
                                if (svcSel) {
                                    for (var j = 1; j < svcSel.options.length; j++) {
                                        var sOpt = svcSel.options[j];
                                        var sSpec = (sOpt.getAttribute('data-specialty') || '').toLowerCase().trim();
                                        if (sSpec === docDept || docSpec.includes(sSpec) ||
                                            (docDept === 'refraction' && sSpec === 'refraction') ||
                                            (docDept === 'lasik' && sSpec === 'lasik') ||
                                            (docDept === 'children' && sSpec === 'children') ||
                                            (docDept === 'cataract' && sSpec === 'cataract') ||
                                            (docDept === 'retina' && sSpec === 'retina')) {
                                            svcSel.selectedIndex = j;
                                            // Cập nhật giá dịch vụ tương ứng
                                            var price = parseFloat(sOpt.getAttribute('data-price') || 0);
                                            var name = sOpt.getAttribute('data-name') || '';
                                            var feeDisplay = document.getElementById('walkinFeeDisplay');
                                            if (feeDisplay) feeDisplay.textContent = price > 0 ? (price.toLocaleString('vi-VN') + ' ₫') : '200.000 ₫';
                                            var btnFee = document.getElementById('btnFeeDisplay');
                                            if (btnFee) btnFee.textContent = price > 0 ? (price.toLocaleString('vi-VN') + ' ₫') : '200.000 ₫';
                                            var tag = document.getElementById('walkinSvcTag');
                                            if (tag) tag.textContent = name;
                                            break;
                                        }
                                    }
                                }
                            }
                        }

                        var sel = document.getElementById('walkinTimeSlot');
                        var hint = document.getElementById('slotAvailabilityHint');
                        if (!sel) return;

                        if (!doctorId) {
                            if (hint) hint.textContent = '';
                            for (var i = 0; i < sel.options.length; i++) {
                                var opt = sel.options[i];
                                var orig = opt.getAttribute('data-orig') || opt.value;
                                opt.textContent = orig;
                                opt.disabled = false;
                                opt.style.color = '';
                            }
                            return;
                        }

                        if (hint) hint.innerHTML = '<i class="spinner-border spinner-border-sm me-1" style="width: 10px; height: 10px;"></i>Đang tải ca bận...';

                        fetch('${pageContext.request.contextPath}/staff/appointments?ajax=checkDoctorSlots&doctorId=' + encodeURIComponent(doctorId))
                            .then(function(res) { return res.json(); })
                            .then(function(data) {
                                var booked = data.bookedSlots || [];
                                var bookedCount = 0;
                                var firstAvailableIdx = -1;

                                for (var i = 0; i < sel.options.length; i++) {
                                    var opt = sel.options[i];
                                    var orig = opt.getAttribute('data-orig') || opt.value;
                                    var val = opt.value;
                                    var isOccupied = booked.indexOf(val) !== -1;

                                    if (isOccupied) {
                                        opt.disabled = true;
                                        opt.textContent = orig + ' - [ĐÃ KÍN]';
                                        opt.style.color = '#94a3b8';
                                        bookedCount++;
                                    } else {
                                        opt.disabled = false;
                                        opt.textContent = orig;
                                        opt.style.color = '';
                                        if (firstAvailableIdx === -1) {
                                            firstAvailableIdx = i;
                                        }
                                    }
                                }

                                if (hint) {
                                    var total = sel.options.length;
                                    var free = total - bookedCount;
                                    hint.innerHTML = '<span class="text-success fw-semibold" style="font-size: 11.5px;">' + free + '/' + total + ' ca còn trống</span>';
                                }

                                if (sel.selectedIndex >= 0 && sel.options[sel.selectedIndex].disabled && firstAvailableIdx !== -1) {
                                    sel.selectedIndex = firstAvailableIdx;
                                }
                            })
                            .catch(function(err) {
                                if (hint) hint.textContent = '';
                            });
                    }

                    function addWalkinTag(tag) {
                        var ta = document.getElementById('walkinReasonText');
                        if (!ta) return;
                        if (ta.value.trim() === '') {
                            ta.value = tag;
                        } else if (!ta.value.includes(tag)) {
                            ta.value = ta.value + ', ' + tag;
                        }
                        ta.focus();
                    }

                    function autoSelectWalkinTime() {
                        var sel = document.getElementById('walkinTimeSlot');
                        if (!sel) return;
                        var now = new Date();
                        var h = now.getHours();
                        var m = now.getMinutes();
                        var target = (m >= 30) ? (String(h).padStart(2, '0') + ':30') : (String(h).padStart(2, '0') + ':00');
                        for (var i = 0; i < sel.options.length; i++) {
                            if (sel.options[i].value === target) {
                                sel.selectedIndex = i;
                                break;
                            }
                        }
                    }

                    var walkinModalElem = document.getElementById('walkinModal');
                    if (walkinModalElem) {
                        walkinModalElem.addEventListener('show.bs.modal', function () {
                            autoSelectWalkinTime();
                            var svcSelect = document.getElementById('walkinServiceId');
                            if (svcSelect) {
                                onWalkinServiceChange(svcSelect);
                            }
                            var docSelect = document.getElementById('walkinDoctorId');
                            if (docSelect) {
                                if (docSelect.selectedIndex <= 0 && docSelect.options.length > 1) {
                                    docSelect.selectedIndex = 1;
                                }
                                onWalkinDoctorChange(docSelect.value, true);
                            }
                        });
                    }

                    function toggleWalkinPayMode(mode) {
                        var cashNotice = document.getElementById('walkinPayCashNotice');
                        var qrNotice = document.getElementById('walkinPayQRNotice');
                        var submitBtn = document.getElementById('walkinSubmitBtn');
                        var feeDisplay = document.getElementById('walkinFeeDisplay');
                        var currentFeeText = feeDisplay ? feeDisplay.textContent : '200.000 ₫';

                        if (mode === 'VietQR_Banking') {
                            if (cashNotice) { cashNotice.classList.remove('d-flex'); cashNotice.classList.add('d-none'); }
                            if (qrNotice) { qrNotice.classList.remove('d-none'); qrNotice.classList.add('d-flex'); }
                            if (submitBtn) {
                                submitBtn.className = 'btn btn-primary px-3.5 shadow-sm';
                                submitBtn.style.background = '#0284c7';
                                submitBtn.style.borderColor = '#0284c7';
                                submitBtn.innerHTML = '<i class="bi bi-qr-code-scan me-1"></i> Quét mã VietQR (<span id="btnFeeDisplay">' + currentFeeText + '</span>)';
                            }
                        } else {
                            if (qrNotice) { qrNotice.classList.remove('d-flex'); qrNotice.classList.add('d-none'); }
                            if (cashNotice) { cashNotice.classList.remove('d-none'); cashNotice.classList.add('d-flex'); }
                            if (submitBtn) {
                                submitBtn.className = 'btn btn-teal px-3.5 shadow-sm';
                                submitBtn.style.background = '';
                                submitBtn.style.borderColor = '';
                                submitBtn.innerHTML = '<i class="bi bi-check2-circle me-1"></i> Xác nhận & Đưa vào hàng đợi';
                            }
                        }
                    }

                    var walkinPollTimer = null;
                    var currentWalkinApptId = null;
                    var currentWalkinOrderCode = null;

                    function initiateWalkinQR() {
                        var form = document.getElementById('walkinForm');
                        if (!form) return;
                        if (form.checkValidity && !form.checkValidity()) {
                            form.reportValidity();
                            return;
                        }

                        var submitBtn = document.getElementById('walkinSubmitBtn');
                        if (submitBtn) {
                            submitBtn.disabled = true;
                            submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Đang tạo mã VietQR...';
                        }

                        var formData = new FormData(form);
                        formData.append('ajax', '1');

                        fetch('${pageContext.request.contextPath}/staff/appointments', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                                'X-Requested-With': 'XMLHttpRequest'
                            },
                            body: new URLSearchParams(formData)
                        })
                        .then(function(res) {
                            return res.text().then(function(text) {
                                try {
                                    return JSON.parse(text);
                                } catch (e) {
                                    console.error("Phản hồi không phải JSON:", text);
                                    throw new Error("Máy chủ phản hồi HTML thay vì JSON (Code: " + res.status + ")");
                                }
                            });
                        })
                        .then(function(data) {
                            if (submitBtn) {
                                submitBtn.disabled = false;
                                toggleWalkinPayMode('VietQR_Banking');
                            }

                            if (data.success) {
                                var walkinModalEl = document.getElementById('walkinModal');
                                if (walkinModalEl) {
                                    var modal = bootstrap.Modal.getInstance(walkinModalEl);
                                    if (modal) modal.hide();
                                }

                                currentWalkinApptId = data.appointmentId;
                                currentWalkinOrderCode = data.orderCode || null;
                                var pSub = document.getElementById('qrPatientSubtitle');
                                if (pSub) pSub.textContent = 'Bệnh nhân: ' + data.patientName + ' (' + data.phone + ')';
                                var qrImg = document.getElementById('walkinQrImg');
                                if (qrImg) qrImg.src = data.qrUrl;
                                var feeEl = document.getElementById('qrFeeAmount');
                                if (feeEl) feeEl.textContent = data.formattedFee;
                                var bankEl = document.getElementById('qrBankName');
                                if (bankEl) bankEl.textContent = data.bankName;
                                var accEl = document.getElementById('qrAccountNumber');
                                if (accEl) accEl.textContent = data.accountNumber;
                                var holderEl = document.getElementById('qrAccountHolder');
                                if (holderEl) holderEl.textContent = data.accountHolder;
                                var descEl = document.getElementById('qrTransferDesc');
                                if (descEl) descEl.textContent = data.paymentDesc;

                                var statusAlert = document.getElementById('qrStatusAlert');
                                if (statusAlert) statusAlert.className = 'alert alert-info py-2 px-3 small rounded-3 mb-3 d-flex align-items-center justify-content-center gap-2';
                                var statusText = document.getElementById('qrStatusText');
                                if (statusText) statusText.textContent = 'Đang chờ bệnh nhân quét mã và chuyển khoản...';
                                var overlay = document.getElementById('qrPaidOverlay');
                                if (overlay) {
                                    overlay.classList.add('d-none');
                                    overlay.classList.remove('d-flex');
                                }
                                var btnConfirm = document.getElementById('btnManualConfirmQR');
                                if (btnConfirm) {
                                    btnConfirm.disabled = false;
                                    btnConfirm.innerHTML = '<i class="bi bi-check2-circle me-1"></i>Lễ tân xác nhận đã nhận tiền';
                                }

                                var qrModalEl = document.getElementById('walkinQrModal');
                                if (qrModalEl) {
                                    var qrModal = bootstrap.Modal.getInstance(qrModalEl) || new bootstrap.Modal(qrModalEl);
                                    qrModal.show();
                                }

                                startWalkinQrPolling(data.appointmentId, data.orderCode || null);
                            } else {
                                alert(data.message || 'Không thể tạo mã VietQR lúc này. Vui lòng thử lại!');
                            }
                        })
                        .catch(function(err) {
                            if (submitBtn) {
                                submitBtn.disabled = false;
                                toggleWalkinPayMode('VietQR_Banking');
                            }
                            alert('Lỗi tạo mã QR: ' + err.message);
                        });
                    }

                    function startWalkinQrPolling(apptId, orderCode) {
                        clearInterval(walkinPollTimer);
                        var attempts = 0;
                        walkinPollTimer = setInterval(function() {
                            attempts++;
                            if (attempts > 180) {
                                clearInterval(walkinPollTimer);
                                var statusText = document.getElementById('qrStatusText');
                                if (statusText) statusText.textContent = 'Hết thời gian chờ thanh toán (15 phút). Vui lòng thử lại.';
                                return;
                            }

                            var pollUrl = '${pageContext.request.contextPath}/staff/appointments?ajax=checkPayment&appointmentId=' + apptId;
                            if (orderCode) pollUrl += '&orderCode=' + orderCode;
                            fetch(pollUrl)
                                .then(function(res) { return res.json(); })
                                .then(function(data) {
                                    if (data && data.isPaid) {
                                        clearInterval(walkinPollTimer);
                                        onWalkinPaymentSuccess();
                                    }
                                })
                                .catch(function(err) {
                                    console.log('Polling walkin payment...', err);
                                });
                        }, 2500);
                    }

                    function onWalkinPaymentSuccess() {
                        var overlay = document.getElementById('qrPaidOverlay');
                        if (overlay) {
                            overlay.classList.remove('d-none');
                            overlay.classList.add('d-flex');
                        }
                        var alertEl = document.getElementById('qrStatusAlert');
                        if (alertEl) {
                            alertEl.className = 'alert alert-success py-2 px-3 small rounded-3 mb-3 d-flex align-items-center justify-content-center gap-2';
                        }
                        var statusText = document.getElementById('qrStatusText');
                        if (statusText) {
                            statusText.textContent = 'Đã nhận thanh toán VietQR thành công!';
                        }
                        var btnConfirm = document.getElementById('btnManualConfirmQR');
                        if (btnConfirm) btnConfirm.disabled = true;

                        setTimeout(function() {
                            window.location.href = '${pageContext.request.contextPath}/staff/waiting-list';
                        }, 1500);
                    }

                    function manualConfirmWalkinQR() {
                        if (!currentWalkinApptId) return;
                        var btn = document.getElementById('btnManualConfirmQR');
                        if (btn) {
                            btn.disabled = true;
                            btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Đang kiểm tra thanh toán...';
                        }

                        var body = 'action=confirmWalkinPayment&appointmentId=' + currentWalkinApptId;
                        if (currentWalkinOrderCode) body += '&orderCode=' + currentWalkinOrderCode;

                        fetch('${pageContext.request.contextPath}/staff/appointments', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                            body: body
                        })
                        .then(function(res) { return res.json(); })
                        .then(function(data) {
                            if (data && data.success) {
                                clearInterval(walkinPollTimer);
                                onWalkinPaymentSuccess();
                            } else {
                                var msg = (data && data.message) ? data.message : 'Chưa nhận được tiền từ ngân hàng. Vui lòng đợi bệnh nhân quét mã!';
                                showQrToast(msg, 'error');
                                if (btn) {
                                    btn.disabled = false;
                                    btn.innerHTML = '<i class="bi bi-check2-circle me-1"></i>Lễ tân xác nhận đã nhận tiền';
                                }
                            }
                        })
                        .catch(function(err) {
                            showQrToast('Lỗi kết nối khi xác nhận thanh toán. Vui lòng thử lại!', 'error');
                            if (btn) {
                                btn.disabled = false;
                                btn.innerHTML = '<i class="bi bi-check2-circle me-1"></i>Lễ tân xác nhận đã nhận tiền';
                            }
                        });
                    }

                    // Toast notification đẹp cho QR modal
                    function showQrToast(message, type) {
                        var toast = document.getElementById('qrPayToast');
                        var toastIcon = document.getElementById('qrToastIcon');
                        var toastMsg = document.getElementById('qrToastMsg');
                        if (!toast || !toastMsg) return;

                        var isError = (type === 'error');
                        toast.className = 'qr-toast-notify ' + (isError ? 'qr-toast-error' : 'qr-toast-success');
                        if (toastIcon) toastIcon.className = 'bi ' + (isError ? 'bi-exclamation-circle-fill' : 'bi-check-circle-fill');
                        toastMsg.textContent = message;

                        toast.classList.add('show');
                        clearTimeout(toast._hideTimer);
                        toast._hideTimer = setTimeout(function() {
                            toast.classList.remove('show');
                        }, 4000);
                    }

                    function cancelWalkinQR() {
                        clearInterval(walkinPollTimer);
                        var apptIdToAbort = currentWalkinApptId;
                        currentWalkinApptId = null;
                        currentWalkinOrderCode = null;

                        var qrModalEl = document.getElementById('walkinQrModal');
                        if (qrModalEl) {
                            var modal = bootstrap.Modal.getInstance(qrModalEl);
                            if (modal) modal.hide();
                        }

                        // Mở lại modal đón tiếp ban đầu để lễ tân có thể chọn tiền mặt hoặc chỉnh sửa/hủy
                        var walkinModalEl = document.getElementById('walkinModal');
                        if (walkinModalEl) {
                            var submitBtn = document.getElementById('walkinSubmitBtn');
                            if (submitBtn) {
                                submitBtn.disabled = false;
                                var payMode = document.querySelector('input[name="paymentMethod"]:checked');
                                toggleWalkinPayMode(payMode ? payMode.value : 'VietQR_Banking');
                            }
                            var walkinModal = bootstrap.Modal.getInstance(walkinModalEl) || new bootstrap.Modal(walkinModalEl);
                            walkinModal.show();
                        }

                        // Gửi yêu cầu xóa/hủy lịch hẹn chưa thanh toán về server để không bị lọt vào danh sách 'Chờ tiếp đón'
                        if (apptIdToAbort) {
                            fetch('${pageContext.request.contextPath}/staff/appointments', {
                                method: 'POST',
                                headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
                                body: 'action=abortWalkinQR&appointmentId=' + apptIdToAbort
                            })
                            .then(function(res) { return res.json(); })
                            .then(function(data) {
                                console.log('Đã dọn dẹp lịch hẹn chưa thanh toán #' + apptIdToAbort, data);
                            })
                            .catch(function(err) {
                                console.error('Lỗi khi dọn dẹp lịch hẹn QR:', err);
                            });
                        }
                    }

                    // Tự động giải phóng nếu người dùng tắt trang hoặc reload khi đang ở modal QR
                    window.addEventListener('beforeunload', function() {
                        if (currentWalkinApptId) {
                            var data = new URLSearchParams();
                            data.append('action', 'abortWalkinQR');
                            data.append('appointmentId', currentWalkinApptId);
                            navigator.sendBeacon('${pageContext.request.contextPath}/staff/appointments', data);
                        }
                    });

                    function initiateWalkinCash() {
                        var form = document.getElementById('walkinForm');
                        if (!form) return;
                        if (form.checkValidity && !form.checkValidity()) {
                            form.reportValidity();
                            return;
                        }

                        var name = (document.getElementById('walkinPatientName') || {}).value || '';
                        var phone = (document.getElementById('walkinPhone') || {}).value || '';
                        var feeDisplay = document.getElementById('walkinFeeDisplay');
                        var feeText = feeDisplay ? feeDisplay.textContent : '200.000 ₫';

                        var svcSelect = document.getElementById('walkinServiceId');
                        var svcName = (svcSelect && svcSelect.selectedIndex > 0) ? svcSelect.options[svcSelect.selectedIndex].text : 'Khám mắt tổng quát';

                        var docSelect = document.getElementById('walkinDoctorId');
                        var docName = (docSelect && docSelect.selectedIndex > 0) ? docSelect.options[docSelect.selectedIndex].text : 'Bác sĩ trực';

                        var timeSelect = document.getElementById('walkinTimeSlot');
                        var timeSlot = (timeSelect && timeSelect.selectedIndex >= 0) ? timeSelect.options[timeSelect.selectedIndex].text : '';

                        var subEl = document.getElementById('cashPatientSubtitle');
                        if (subEl) subEl.textContent = 'Bệnh nhân: ' + name + ' (' + phone + ')';
                        var pNameEl = document.getElementById('cashModalPatientName');
                        if (pNameEl) pNameEl.textContent = name;
                        var pPhoneEl = document.getElementById('cashModalPhone');
                        if (pPhoneEl) pPhoneEl.textContent = phone;
                        var feeEl = document.getElementById('cashTotalFee');
                        if (feeEl) feeEl.textContent = feeText;
                        var sNameEl = document.getElementById('cashModalServiceName');
                        if (sNameEl) sNameEl.textContent = svcName;
                        var dNameEl = document.getElementById('cashModalDoctorName');
                        if (dNameEl) dNameEl.textContent = docName;
                        var tSlotEl = document.getElementById('cashModalTimeSlot');
                        if (tSlotEl) tSlotEl.textContent = timeSlot;

                        var overlay = document.getElementById('cashSuccessOverlay');
                        if (overlay) {
                            overlay.classList.add('d-none');
                            overlay.classList.remove('d-flex');
                        }
                        var errAlert = document.getElementById('cashErrorAlert');
                        if (errAlert) {
                            errAlert.classList.add('d-none');
                            errAlert.classList.remove('d-flex');
                        }

                        var cleanFee = parseInt(feeText.replace(/[^0-9]/g, '')) || 200000;
                        window._currentWalkinCashFee = cleanFee;
                        var givenInput = document.getElementById('cashGivenInput');
                        if (givenInput) givenInput.value = String(cleanFee).replace(/\B(?=(\d{3})+(?!\d))/g, '.');
                        var changeEl = document.getElementById('cashChangeAmount');
                        if (changeEl) {
                            changeEl.className = 'fs-6 text-primary';
                            changeEl.textContent = '0 ₫';
                        }

                        var btnConfirm = document.getElementById('btnConfirmCashPayment');
                        if (btnConfirm) {
                            btnConfirm.disabled = false;
                            btnConfirm.innerHTML = '<i class="bi bi-check2-circle me-1"></i>Xác nhận đã nhận tiền & Đưa vào hàng đợi';
                        }

                        var walkinModalEl = document.getElementById('walkinModal');
                        if (walkinModalEl) {
                            var m = bootstrap.Modal.getInstance(walkinModalEl);
                            if (m) m.hide();
                        }
                        var cashModalEl = document.getElementById('walkinCashModal');
                        if (cashModalEl) {
                            var cashModal = bootstrap.Modal.getInstance(cashModalEl) || new bootstrap.Modal(cashModalEl);
                            cashModal.show();
                        }
                    }

                    function submitWalkinCashPayment() {
                        var form = document.getElementById('walkinForm');
                        if (!form) return;

                        var btnConfirm = document.getElementById('btnConfirmCashPayment');
                        if (btnConfirm) {
                            btnConfirm.disabled = true;
                            btnConfirm.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Đang xử lý...';
                        }

                        var errAlert = document.getElementById('cashErrorAlert');
                        var errText = document.getElementById('cashErrorText');
                        if (errAlert) {
                            errAlert.classList.add('d-none');
                            errAlert.classList.remove('d-flex');
                        }

                        var formData = new FormData(form);
                        formData.append('ajax', '1');

                        fetch('${pageContext.request.contextPath}/staff/appointments', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                                'X-Requested-With': 'XMLHttpRequest'
                            },
                            body: new URLSearchParams(formData)
                        })
                        .then(function(res) {
                            return res.text().then(function(text) {
                                try {
                                    return JSON.parse(text);
                                } catch (e) {
                                    console.error("Phản hồi không phải JSON:", text);
                                    throw new Error("Lỗi máy chủ (" + res.status + ")");
                                }
                            });
                        })
                        .then(function(data) {
                            if (data && data.success) {
                                var overlay = document.getElementById('cashSuccessOverlay');
                                if (overlay) {
                                    overlay.classList.remove('d-none');
                                    overlay.classList.add('d-flex');
                                }
                                setTimeout(function() {
                                    window.location.href = '${pageContext.request.contextPath}/staff/waiting-list';
                                }, 1200);
                            } else {
                                if (btnConfirm) {
                                    btnConfirm.disabled = false;
                                    btnConfirm.innerHTML = '<i class="bi bi-check2-circle me-1"></i>Xác nhận đã nhận tiền & Đưa vào hàng đợi';
                                }
                                if (errAlert && errText) {
                                    errText.textContent = (data && data.message) ? data.message : 'Không thể tiếp đón khách vãng lai lúc này.';
                                    errAlert.classList.remove('d-none');
                                    errAlert.classList.add('d-flex');
                                }
                            }
                        })
                        .catch(function(err) {
                            if (btnConfirm) {
                                btnConfirm.disabled = false;
                                btnConfirm.innerHTML = '<i class="bi bi-check2-circle me-1"></i>Xác nhận đã nhận tiền & Đưa vào hàng đợi';
                            }
                            if (errAlert && errText) {
                                errText.textContent = 'Lỗi kết nối: ' + err.message;
                                errAlert.classList.remove('d-none');
                                errAlert.classList.add('d-flex');
                            }
                        });
                    }

                    function cancelWalkinCash() {
                        var cashModalEl = document.getElementById('walkinCashModal');
                        if (cashModalEl) {
                            var m = bootstrap.Modal.getInstance(cashModalEl);
                            if (m) m.hide();
                        }
                        var walkinModalEl = document.getElementById('walkinModal');
                        if (walkinModalEl) {
                            setTimeout(function() {
                                var walkinModal = bootstrap.Modal.getInstance(walkinModalEl) || new bootstrap.Modal(walkinModalEl);
                                walkinModal.show();
                            }, 350);
                        }
                    }

                    function onCashGivenChange(val) {
                        var num = parseInt((val || '').replace(/[^0-9]/g, '')) || 0;
                        var fee = window._currentWalkinCashFee || 200000;
                        var change = num - fee;
                        var changeEl = document.getElementById('cashChangeAmount');
                        if (changeEl) {
                            if (change < 0) {
                                changeEl.className = 'fs-6 text-danger';
                                changeEl.textContent = 'Còn thiếu ' + String(Math.abs(change)).replace(/\B(?=(\d{3})+(?!\d))/g, '.') + ' ₫';
                            } else {
                                changeEl.className = 'fs-6 text-success';
                                changeEl.textContent = String(change).replace(/\B(?=(\d{3})+(?!\d))/g, '.') + ' ₫';
                            }
                        }
                    }

                    function setCashGivenPreset(amount) {
                        var fee = window._currentWalkinCashFee || 200000;
                        var target = (amount === 'exact') ? fee : amount;
                        var givenInput = document.getElementById('cashGivenInput');
                        if (givenInput) {
                            givenInput.value = String(target).replace(/\B(?=(\d{3})+(?!\d))/g, '.');
                            onCashGivenChange(givenInput.value);
                        }
                    }

                    var walkinFormEl = document.getElementById('walkinForm');
                    if (walkinFormEl) {
                        walkinFormEl.addEventListener('submit', function(e) {
                            e.preventDefault();
                            var selectedMethod = document.querySelector('input[name="paymentMethod"]:checked');
                            if (selectedMethod && selectedMethod.value === 'VietQR_Banking') {
                                initiateWalkinQR();
                            } else {
                                initiateWalkinCash();
                            }
                        });
                    }

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
            <!-- QR Payment Toast Notification -->
            <div id="qrPayToast" class="qr-toast-notify" role="alert" aria-live="assertive">
                <i id="qrToastIcon" class="bi bi-exclamation-circle-fill"></i>
                <span id="qrToastMsg"></span>
                <button type="button" onclick="document.getElementById('qrPayToast').classList.remove('show')" class="qr-toast-close" aria-label="Đóng">&times;</button>
            </div>

            <style>
                .qr-toast-notify {
                    position: fixed;
                    top: 24px;
                    right: 24px;
                    z-index: 99999;
                    display: flex;
                    align-items: flex-start;
                    gap: 10px;
                    min-width: 300px;
                    max-width: 420px;
                    padding: 14px 16px;
                    border-radius: 12px;
                    box-shadow: 0 8px 32px rgba(0,0,0,0.18), 0 2px 8px rgba(0,0,0,0.10);
                    font-size: 14px;
                    font-weight: 500;
                    opacity: 0;
                    transform: translateX(120%);
                    transition: opacity 0.35s ease, transform 0.35s cubic-bezier(.22,.68,0,1.2);
                    pointer-events: none;
                    backdrop-filter: blur(6px);
                }
                .qr-toast-notify.show {
                    opacity: 1;
                    transform: translateX(0);
                    pointer-events: auto;
                }
                .qr-toast-error {
                    background: linear-gradient(135deg, #ff4757ee 0%, #c0392bee 100%);
                    color: #fff;
                    border-left: 4px solid #ff1744;
                }
                .qr-toast-success {
                    background: linear-gradient(135deg, #2ed573ee 0%, #0abf53ee 100%);
                    color: #fff;
                    border-left: 4px solid #00e676;
                }
                .qr-toast-notify i {
                    font-size: 20px;
                    flex-shrink: 0;
                    margin-top: 1px;
                }
                .qr-toast-notify span {
                    flex: 1;
                    line-height: 1.45;
                }
                .qr-toast-close {
                    background: none;
                    border: none;
                    color: rgba(255,255,255,0.8);
                    font-size: 18px;
                    line-height: 1;
                    cursor: pointer;
                    padding: 0 0 0 4px;
                    flex-shrink: 0;
                    transition: color 0.2s;
                }
                .qr-toast-close:hover { color: #fff; }
            </style>

            </body>
            </html>