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
                            <div class="d-flex align-items-center gap-2">
                                <a href="${pageContext.request.contextPath}/staff/appointments" class="btn btn-teal-outline">
                                    <i class="bi bi-calendar4-event me-1"></i> Quản lý lịch hẹn
                                </a>
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
                                        <input type="text" name="keyword" value="${param.keyword}"
                                            placeholder="Nhập SĐT, tên hoặc mã hẹn (#APPT-3)..." class="w-100"
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
                                <table class="custom-table">
                                    <thead>
                                        <tr>
                                            <th style="width: 70px;">STT</th>
                                            <th>Mã Hẹn</th>
                                            <th>Bệnh Nhân</th>
                                            <th>Bác Sĩ</th>
                                            <th>Phòng Khám</th>
                                            <th>Trạng Thái</th>
                                            <th class="text-center" style="width: 170px;">Thao Tác</th>
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
                                                        <td>
                                                            <div
                                                                class="queue-badge ${appt.status == 'In_Progress' ? 'queue-badge-active' : ''}">
                                                                #${appt.queueNumber}
                                                            </div>
                                                        </td>

                                                        <!-- Mã Hẹn -->
                                                        <td>
                                                            <span class="fw-bold text-dark">#APPT-${appt.id}</span>
                                                        </td>

                                                        <!-- Bệnh Nhân -->
                                                        <td>
                                                            <div class="patient-name-title">
                                                                <a href="${pageContext.request.contextPath}/staff/appointment-detail?id=${appt.id}"
                                                                    class="text-decoration-none text-dark hover-teal">
                                                                    ${appt.patientName}
                                                                </a>
                                                            </div>
                                                            <div class="patient-sub-text">
                                                                <i
                                                                    class="bi bi-telephone text-muted me-1"></i>${appt.phone}
                                                            </div>
                                                        </td>

                                                        <!-- Bác Sĩ -->
                                                        <td>
                                                            <div class="fw-semibold text-dark">${not empty
                                                                appt.doctorName ? appt.doctorName : 'Chưa phân công'}
                                                            </div>
                                                        </td>

                                                        <!-- Phòng Khám -->
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${not empty appt.roomName}">
                                                                    <span
                                                                        class="badge bg-light text-dark border px-2 py-1 fw-semibold">
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
                                                                                <c:otherwise>
                                                                                    <button type="button"
                                                                                        class="action-btn checkin btn-trigger-start"
                                                                                        title="Gọi bệnh nhân vào phòng khám" data-bs-toggle="tooltip"
                                                                                        data-id="${appt.id}"
                                                                                        data-name="${appt.patientName}">
                                                                                        <i class="bi bi-box-arrow-in-right"></i>
                                                                                    </button>
                                                                                </c:otherwise>
                                                                            </c:choose>

                                                                            <!-- 3. Bỏ qua lượt (Vàng pastel - Xếp xuống cuối hàng đợi) -->
                                                                            <button type="button"
                                                                                class="action-btn warning btn-trigger-skip"
                                                                                title="Bỏ qua lượt: Chuyển bệnh nhân xuống cuối hàng đợi hôm nay nếu tạm vắng mặt" data-bs-toggle="tooltip"
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
                                                                            <!-- Hoàn tất khám -->
                                                                            <button type="button"
                                                                                class="action-btn checkin btn-trigger-complete"
                                                                                title="Đánh dấu bệnh nhân đã khám xong" data-bs-toggle="tooltip"
                                                                                data-id="${appt.id}"
                                                                                data-name="${appt.patientName}">
                                                                                <i class="bi bi-check2-circle"></i>
                                                                            </button>

                                                                            <!-- Báo vắng mặt / Hủy ca giữa chừng (Đỏ pastel - icon thùng rác) -->
                                                                            <button type="button"
                                                                                class="action-btn delete btn-trigger-absent"
                                                                                title="Báo vắng mặt / Hủy ca giữa chừng" data-bs-toggle="tooltip"
                                                                                data-id="${appt.id}"
                                                                                data-name="${appt.patientName}">
                                                                                <i class="bi bi-trash"></i>
                                                                            </button>
                                                                        </c:when>

                                                                        <c:when test="${appt.status == 'Completed'}">
                                                                            <!-- Đã khám xong: chỉ xem chi tiết bằng nút bút chì ở trên -->
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
                                                    <td colspan="7" class="text-center py-5">
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

                <!-- Modal Xác nhận Hoàn tất khám (Thiết kế đồng bộ chuẩn theo hình ảnh) -->
                <div class="modal fade" id="completeModal" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered" style="max-width: 420px;">
                        <div class="modal-content">
                            <div class="modal-header">
                                <button type="button" class="btn-close" data-bs-dismiss="modal"
                                    aria-label="Close"></button>
                            </div>
                            <div class="modal-body">
                                <div class="modal-icon-success">
                                    <i class="bi bi-check2-circle"></i>
                                </div>
                                <h3 class="modal-title-custom">Xác nhận hoàn tất khám?</h3>
                                <p class="modal-text">
                                    Bệnh nhân <strong id="completeModalPatientName" class="text-dark">---</strong> sẽ
                                    được xác nhận hoàn thành ca khám và rời khỏi hàng đợi.
                                </p>
                                <form action="${pageContext.request.contextPath}/staff/waiting-list" method="post"
                                    id="completeForm" class="m-0">
                                    <input type="hidden" name="action" value="updateStatus">
                                    <input type="hidden" name="appointmentId" id="completeModalAppointmentId">
                                    <input type="hidden" name="status" value="Completed">
                                    <div class="modal-actions">
                                        <button type="button" class="btn btn-modal-cancel"
                                            data-bs-dismiss="modal">Hủy</button>
                                        <button type="submit" class="btn btn-modal-success">Hoàn tất khám</button>
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

                <!-- Modal Bỏ Qua Lượt / Xếp cuối hàng đợi -->
                <div class="modal fade" id="skipModal" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered" style="max-width: 430px;">
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
                                    Bệnh nhân <strong id="skipModalPatientName" class="text-dark">---</strong> (<span id="skipModalApptCode" class="fw-bold text-secondary">#APPT-0</span>) sẽ được <strong>chuyển xuống cuối hàng đợi hôm nay</strong> để gọi bệnh nhân kế tiếp vào phòng khám.
                                </p>
                                <form action="${pageContext.request.contextPath}/staff/waiting-list" method="post" id="skipForm" class="m-0">
                                    <input type="hidden" name="action" value="skip">
                                    <input type="hidden" name="appointmentId" id="skipModalAppointmentId">
                                    <input type="hidden" name="returnUrl" value="${pageContext.request.contextPath}/staff/waiting-list${not empty pageContext.request.queryString ? '?'.concat(pageContext.request.queryString) : ''}">
                                    <div class="modal-actions">
                                        <button type="button" class="btn btn-modal-cancel" data-bs-dismiss="modal">Hủy</button>
                                        <button type="submit" class="btn btn-modal-warning">
                                            <i class="bi bi-arrow-down-circle me-1"></i> Xếp cuối hàng
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

                    function openCompleteModal(id, name) {
                        var idInput = document.getElementById('completeModalAppointmentId');
                        if (idInput) idInput.value = id;
                        var nameElem = document.getElementById('completeModalPatientName');
                        if (nameElem) nameElem.textContent = name || 'này';
                        var modalElem = document.getElementById('completeModal');
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

                    document.addEventListener('click', function (e) {
                        var btnStart = e.target.closest('.btn-trigger-start');
                        if (btnStart) {
                            var id = btnStart.getAttribute('data-id');
                            var name = btnStart.getAttribute('data-name');
                            openStartExamModal(id, name);
                            return;
                        }

                        var btnComplete = e.target.closest('.btn-trigger-complete');
                        if (btnComplete) {
                            var id = btnComplete.getAttribute('data-id');
                            var name = btnComplete.getAttribute('data-name');
                            openCompleteModal(id, name);
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

                    // Auto refresh waiting list every 60 seconds
                    setTimeout(function () {
                        window.location.reload();
                    }, 60000);
                </script>
            </body>

            </html>