<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff Patient Reschedule Form Screen - Đổi Lịch Khám Cho Bệnh Nhân</title>

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <!-- Employee / Staff Unified Layout CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/employee.css">

    <style>
        .reschedule-card {
            background: #ffffff;
            border-radius: 14px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.04);
            padding: 24px;
            margin-bottom: 24px;
        }

        .reschedule-card-title {
            font-size: 16px;
            font-weight: 700;
            color: #0f172a;
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 18px;
            padding-bottom: 12px;
            border-bottom: 1px solid #f1f5f9;
        }

        .reschedule-card-title i {
            color: #0d9488;
            font-size: 20px;
        }

        .slot-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(130px, 1fr));
            gap: 10px;
        }

        .slot-pill {
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            padding: 10px 8px;
            text-align: center;
            cursor: pointer;
            background: #ffffff;
            transition: all 0.2s ease;
            position: relative;
        }

        .slot-pill:hover:not(.disabled) {
            border-color: #0d9488;
            background: #f0fdfa;
            transform: translateY(-2px);
        }

        .slot-pill.selected {
            border-color: #0d9488;
            background: #0d9488;
            color: #ffffff;
            font-weight: 700;
            box-shadow: 0 4px 12px rgba(13, 148, 136, 0.35);
        }

        .slot-pill.disabled {
            background: #f8fafc;
            border-color: #e2e8f0;
            color: #94a3b8;
            cursor: not-allowed;
            opacity: 0.6;
            text-decoration: line-through;
        }

        .summary-sticky-card {
            background: #ffffff;
            border-radius: 14px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.04);
            overflow: hidden;
            position: sticky;
            top: 20px;
        }

        .summary-sticky-header {
            background: linear-gradient(135deg, #0d9488 0%, #0f766e 100%);
            color: #ffffff;
            padding: 18px 20px;
        }

        .quick-reason-btn {
            font-size: 12px;
            padding: 5px 12px;
            border-radius: 20px;
            border: 1px solid #e2e8f0;
            background: #f8fafc;
            color: #475569;
            cursor: pointer;
            transition: all 0.15s;
            user-select: none;
        }

        .quick-reason-btn:hover {
            background: #0d9488;
            color: #ffffff;
            border-color: #0d9488;
        }
    </style>
</head>
<body>

    <!-- Employee Unified Sidebar -->
    <jsp:include page="/views/employee/layout/employee-sidebar.jsp">
        <jsp:param name="activeNav" value="appointments" />
    </jsp:include>

    <!-- Main Wrapper -->
    <main class="main-wrapper">
        <!-- Top Header -->
        <jsp:include page="/views/employee/layout/employee-header.jsp" />

        <!-- Page Content -->
        <div class="page-content">

            <!-- Breadcrumbs -->
            <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
                <div>
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb mb-1">
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/staff/appointments" class="text-teal text-decoration-none">Quản lý lịch hẹn</a></li>
                            <li class="breadcrumb-item active" aria-current="page">Đổi lịch khám cho bệnh nhân</li>
                        </ol>
                    </nav>
                    <h4 class="fw-bold mb-0 text-dark">Staff Patient Reschedule Form Screen</h4>
                    <p class="text-muted small mb-0">Hỗ trợ dời ngày, giờ hoặc bác sĩ khám cho ca hẹn của bệnh nhân</p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/staff/appointments" class="btn btn-light border text-muted">
                        <i class="bi bi-arrow-left me-1"></i>Quay lại danh sách
                    </a>
                </div>
            </div>

            <!-- Flash Messages -->
            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="flash-alert flash-alert-danger alert-dismissible fade show" role="alert">
                    <div class="flash-alert-icon"><i class="bi bi-exclamation-triangle-fill"></i></div>
                    <div class="flash-alert-content"><span class="alert-title">Thông báo:</span>${sessionScope.errorMessage}</div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="errorMessage" scope="session" />
            </c:if>

            <!-- Form Container -->
            <form action="${pageContext.request.contextPath}/staff/reschedule" method="POST" id="rescheduleForm" onsubmit="return validateForm();">
                <input type="hidden" name="appointmentId" value="${appointment.id}">
                <input type="hidden" name="newScheduleId" id="newScheduleIdInput" value="">

                <div class="row g-4">
                    <!-- Left Column: Selection Steps -->
                    <div class="col-lg-7 col-xl-8">

                        <!-- Step 1: Chọn Bác sĩ -->
                        <div class="reschedule-card">
                            <div class="reschedule-card-title">
                                <i class="bi bi-person-badge"></i>
                                <span>1. Chọn Bác Sĩ Khám</span>
                            </div>

                            <div class="mb-2">
                                <label for="doctorSelect" class="form-label small fw-bold text-dark">Bác sĩ phụ trách <span class="text-danger">*</span></label>
                                <select class="form-select form-select-lg" id="doctorSelect" name="doctorId" onchange="onDoctorOrDateChange()" required>
                                    <c:forEach var="doc" items="${doctors}">
                                        <c:set var="isCurrentDoctor" value="${doc.id == appointment.employeeId || doc.fullName == appointment.doctorName}" />
                                        <option value="${doc.id}" 
                                                data-doctor-name="${doc.fullName}" 
                                                data-specialty="${doc.specialty}"
                                                ${isCurrentDoctor ? 'selected' : ''}>
                                            ${doc.fullName} — ${doc.specialty} ${isCurrentDoctor ? '(Bác sĩ hiện tại)' : ''}
                                        </option>
                                    </c:forEach>
                                </select>
                                <div class="form-text small text-muted">
                                    Có thể giữ nguyên bác sĩ hiện tại hoặc chuyển sang bác sĩ khác cùng chuyên khoa mắt.
                                </div>
                            </div>
                        </div>

                        <!-- Step 2: Chọn Ngày khám mới -->
                        <div class="reschedule-card">
                            <div class="reschedule-card-title">
                                <i class="bi bi-calendar-event"></i>
                                <span>2. Chọn Ngày Khám Mới</span>
                            </div>

                            <div class="mb-2">
                                <label for="dateInput" class="form-label small fw-bold text-dark">Ngày hẹn mới <span class="text-danger">*</span></label>
                                <input type="date" class="form-control form-control-lg fw-semibold" id="dateInput" name="newDate" 
                                       min="${minDate}" max="${maxDate}" onchange="onDoctorOrDateChange()" required>
                                <div class="form-text small text-muted">
                                    Hỗ trợ dời lịch trong vòng 30 ngày tới. Phòng khám làm việc từ Thứ 2 đến Chủ nhật.
                                </div>
                            </div>
                        </div>

                        <!-- Step 3: Chọn Khung giờ (Slots) -->
                        <div class="reschedule-card">
                            <div class="reschedule-card-title d-flex justify-content-between align-items-center">
                                <div>
                                    <i class="bi bi-clock-history"></i>
                                    <span>3. Chọn Khung Giờ Khám Còn Trống</span>
                                </div>
                                <span id="shiftBadge" class="badge bg-light text-teal border" style="font-size: 11px;">Chờ chọn ngày</span>
                            </div>

                            <div id="slotsContainer">
                                <div class="text-center py-4 text-muted" id="slotsPlaceholder">
                                    <i class="bi bi-calendar4-week fs-2 text-teal opacity-50 mb-2 d-block"></i>
                                    Vui lòng chọn ngày khám để tải danh sách các ca/khung giờ còn trống của bác sĩ.
                                </div>
                            </div>

                            <div class="mt-3 small text-muted d-flex align-items-center gap-3">
                                <div class="d-flex align-items-center gap-1">
                                    <span class="d-inline-block rounded" style="width: 14px; height: 14px; border: 2px solid #0d9488; background: #f0fdfa;"></span>
                                    <span>Có thể chọn</span>
                                </div>
                                <div class="d-flex align-items-center gap-1">
                                    <span class="d-inline-block rounded" style="width: 14px; height: 14px; background: #0d9488;"></span>
                                    <span>Đang chọn</span>
                                </div>
                                <div class="d-flex align-items-center gap-1">
                                    <span class="d-inline-block rounded" style="width: 14px; height: 14px; background: #f1f5f9; border: 1px solid #e2e8f0;"></span>
                                    <span>Đã kín chỗ / Nghỉ</span>
                                </div>
                            </div>
                        </div>

                        <!-- Step 4: Lý do đổi lịch -->
                        <div class="reschedule-card">
                            <div class="reschedule-card-title">
                                <i class="bi bi-chat-left-text"></i>
                                <span>4. Lý Do Đổi Lịch Khám</span>
                            </div>

                            <div class="mb-3">
                                <div class="d-flex flex-wrap gap-2 mb-2">
                                    <span class="quick-reason-btn" onclick="setReason('Bệnh nhân bận việc đột xuất')">Bệnh nhân bận đột xuất</span>
                                    <span class="quick-reason-btn" onclick="setReason('Bệnh nhân xin đổi sang ngày phù hợp hơn')">Đổi ngày phù hợp hơn</span>
                                    <span class="quick-reason-btn" onclick="setReason('Bệnh nhân có việc gia đình / công tác')">Việc gia đình / công tác</span>
                                    <span class="quick-reason-btn" onclick="setReason('Bác sĩ có lịch mổ đột xuất / đổi ca trực')">Bác sĩ đổi ca trực</span>
                                </div>
                                <textarea class="form-control" name="reason" id="reasonInput" rows="3" 
                                          placeholder="Nhập lý do dời lịch khám của bệnh nhân..." required>Bệnh nhân yêu cầu đổi ngày khám</textarea>
                            </div>

                            <!-- Action Buttons -->
                            <div class="d-flex align-items-center gap-3 pt-2">
                                <button type="submit" class="btn btn-teal btn-lg px-4 shadow-sm fw-semibold" id="confirmBtn">
                                    <i class="bi bi-calendar2-check me-2"></i>Xác Nhận Đổi Lịch Khám
                                </button>
                                <a href="${pageContext.request.contextPath}/staff/appointments" class="btn btn-light btn-lg px-4 border text-muted">
                                    Hủy bỏ
                                </a>
                            </div>
                        </div>

                    </div>

                    <!-- Right Column: Comparison Card -->
                    <div class="col-lg-5 col-xl-4">
                        <div class="summary-sticky-card">
                            <div class="summary-sticky-header">
                                <h6 class="fw-bold mb-1 d-flex align-items-center gap-2">
                                    <i class="bi bi-arrow-left-right"></i>
                                    <span>Đối Chiếu Lịch Khám</span>
                                </h6>
                                <div class="small opacity-75">Ca khám #APT-${appointment.id}</div>
                            </div>

                            <div class="p-3">
                                <!-- Thông tin bệnh nhân -->
                                <div class="mb-3 pb-3 border-bottom">
                                    <div class="small text-muted mb-1">Bệnh nhân:</div>
                                    <div class="fw-bold text-dark fs-6">${appointment.patientName}</div>
                                    <div class="small text-muted"><i class="bi bi-telephone me-1"></i>${appointment.phone}</div>
                                    <div class="mt-2">
                                        <span class="badge ${empty appointment.checkinTime ? 'bg-primary-subtle text-primary border' : 'bg-success-subtle text-success border'}">
                                            <i class="bi bi-info-circle me-1"></i>${empty appointment.checkinTime ? 'Chờ tiếp đón' : 'Chờ khám'}
                                        </span>
                                    </div>
                                </div>

                                <!-- Lịch hẹn CŨ -->
                                <div class="p-3 rounded-3 mb-3" style="background-color: #fef2f2; border: 1px solid #fecaca;">
                                    <div class="fw-bold text-danger mb-2 small d-flex align-items-center gap-1">
                                        <i class="bi bi-x-circle-fill"></i>
                                        <span>Lịch Hẹn Hiện Tại (Cũ)</span>
                                    </div>
                                    <div class="small mb-1">
                                        <strong class="text-dark">Bác sĩ:</strong> ${appointment.doctorName}
                                    </div>
                                    <div class="small mb-1">
                                        <strong class="text-dark">Ngày khám:</strong> ${appointment.appointmentDate}
                                    </div>
                                    <div class="small mb-1">
                                        <strong class="text-dark">Khung giờ:</strong> ${appointment.timeSlot}
                                    </div>
                                    <div class="small">
                                        <strong class="text-dark">Dịch vụ:</strong> ${not empty appointment.serviceName ? appointment.serviceName : 'Khám chuyên khoa mắt'}
                                    </div>
                                </div>

                                <!-- Mũi tên chuyển tiếp -->
                                <div class="text-center my-2 text-teal">
                                    <i class="bi bi-arrow-down-circle-fill fs-4"></i>
                                </div>

                                <!-- Lịch hẹn MỚI -->
                                <div class="p-3 rounded-3 mb-3" style="background-color: #f0fdf4; border: 1px solid #bbf7d0;">
                                    <div class="fw-bold text-success mb-2 small d-flex align-items-center gap-1">
                                        <i class="bi bi-check-circle-fill"></i>
                                        <span>Lịch Hẹn Mới Dự Kiến</span>
                                    </div>
                                    <div class="small mb-1">
                                        <strong class="text-dark">Bác sĩ mới:</strong> <span id="summaryNewDoctor" class="text-muted">Chưa chọn</span>
                                    </div>
                                    <div class="small mb-1">
                                        <strong class="text-dark">Ngày mới:</strong> <span id="summaryNewDate" class="text-muted">Chưa chọn</span>
                                    </div>
                                    <div class="small mb-1">
                                        <strong class="text-dark">Khung giờ mới:</strong> <span id="summaryNewSlot" class="text-muted">Chưa chọn</span>
                                    </div>
                                </div>

                                <!-- Lưu ý điều kiện -->
                                <div class="alert alert-info py-2 px-3 small mb-0 border-0" style="background-color: #f0fdfa; color: #0f766e;">
                                    <i class="bi bi-info-circle-fill me-1"></i>
                                    <strong>Quy định:</strong> Chỉ đổi lịch cho ca khám đang ở trạng thái <strong>Chờ tiếp đón</strong> (chưa check-in tại quầy lễ tân). Sau khi dời lịch thành công, hệ thống sẽ tự động cập nhật lịch làm việc của bác sĩ và thông báo đến bệnh nhân.
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </form>

        </div>
    </main>

    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        let selectedScheduleId = null;
        let selectedSlotLabel = null;

        function setReason(text) {
            document.getElementById('reasonInput').value = text;
        }

        function onDoctorOrDateChange() {
            const doctorSelect = document.getElementById('doctorSelect');
            const selectedDocOption = doctorSelect.options[doctorSelect.selectedIndex];
            const doctorId = doctorSelect.value;
            const doctorName = selectedDocOption ? selectedDocOption.getAttribute('data-doctor-name') : '';

            const dateInput = document.getElementById('dateInput');
            const dateStr = dateInput.value;

            // Reset selection
            selectedScheduleId = null;
            selectedSlotLabel = null;
            document.getElementById('newScheduleIdInput').value = '';
            document.getElementById('summaryNewDoctor').innerText = doctorName || 'Chưa chọn';
            document.getElementById('summaryNewDate').innerText = dateStr ? formatDateVN(dateStr) : 'Chưa chọn';
            document.getElementById('summaryNewSlot').innerText = 'Chưa chọn';

            if (!dateStr || !doctorId) {
                return;
            }

            loadSlots(doctorId, dateStr);
        }

        function formatDateVN(dateStr) {
            if (!dateStr) return '';
            const parts = dateStr.split('-');
            if (parts.length === 3) {
                return parts[2] + '/' + parts[1] + '/' + parts[0];
            }
            return dateStr;
        }

        function loadSlots(doctorId, dateStr) {
            const container = document.getElementById('slotsContainer');
            const shiftBadge = document.getElementById('shiftBadge');

            container.innerHTML = '<div class="text-center py-4 text-muted"><div class="spinner-border spinner-border-sm text-teal me-2" role="status"></div>Đang tải lịch làm việc của bác sĩ...</div>';
            shiftBadge.innerText = 'Đang tải...';

            fetch('${pageContext.request.contextPath}/staff/reschedule?action=getSlots&doctorId=' + doctorId + '&date=' + dateStr)
                .then(res => res.json())
                .then(data => {
                    const shift = data.shiftSummary || 'OFF';
                    if (shift === 'OFF') {
                        shiftBadge.className = 'badge bg-danger-subtle text-danger border border-danger-subtle';
                        shiftBadge.innerText = 'Bác sĩ không có lịch trực ngày này';
                        container.innerHTML = '<div class="alert alert-warning py-3 text-center small mb-0"><i class="bi bi-calendar-x fs-4 d-block mb-1"></i>Bác sĩ không có ca trực trong ngày đã chọn. Vui lòng chọn ngày khác hoặc chọn bác sĩ khác.</div>';
                        return;
                    }

                    shiftBadge.className = 'badge bg-success-subtle text-success border border-success-subtle';
                    shiftBadge.innerText = 'Ca trực: ' + shift;

                    const slots = data.slots || [];
                    if (slots.length === 0) {
                        container.innerHTML = '<div class="alert alert-warning py-3 text-center small mb-0"><i class="bi bi-clock-history fs-4 d-block mb-1"></i>Không có khung giờ nào còn trống cho ngày này. Vui lòng chọn ngày khác.</div>';
                        return;
                    }

                    let html = '<div class="slot-grid">';
                    let availableCount = 0;
                    slots.forEach(s => {
                        const isAvail = s.isAvailable === true;
                        if (isAvail) availableCount++;
                        const disabledClass = isAvail ? '' : 'disabled';
                        const timeText = (s.startTime || '') + ' - ' + (s.endTime || '');
                        const slotName = s.slotName ? ('Ca ' + s.slotName + ': ') : '';

                        html += '<div class="slot-pill ' + disabledClass + '" '
                              + (isAvail ? 'onclick="selectSlot(' + s.scheduleId + ', \'' + slotName + timeText + '\', this)"' : 'title="Khung giờ này đã có người đặt"')
                              + ' data-schedule-id="' + s.scheduleId + '">'
                              + '<div class="fw-bold" style="font-size: 13px;">' + (s.slotName ? ('Ca ' + s.slotName) : 'Khung giờ') + '</div>'
                              + '<div style="font-size: 11px;">' + timeText + '</div>'
                              + '</div>';
                    });
                    html += '</div>';

                    if (availableCount === 0) {
                        html += '<div class="alert alert-warning mt-3 py-2 small mb-0 text-center">Tất cả khung giờ trong ngày này đã kín chỗ. Vui lòng chọn ngày khác.</div>';
                    }

                    container.innerHTML = html;
                })
                .catch(err => {
                    shiftBadge.className = 'badge bg-danger-subtle text-danger border border-danger-subtle';
                    shiftBadge.innerText = 'Lỗi kết nối';
                    container.innerHTML = '<div class="alert alert-danger py-3 text-center small mb-0"><i class="bi bi-exclamation-triangle fs-4 d-block mb-1"></i>Không thể tải khung giờ. Vui lòng thử lại.</div>';
                });
        }

        function selectSlot(scheduleId, slotLabel, element) {
            document.querySelectorAll('.slot-pill').forEach(el => el.classList.remove('selected'));
            element.classList.add('selected');

            selectedScheduleId = scheduleId;
            selectedSlotLabel = slotLabel;

            document.getElementById('newScheduleIdInput').value = scheduleId;
            document.getElementById('summaryNewSlot').innerText = slotLabel;
            document.getElementById('summaryNewSlot').className = 'text-success fw-bold';
        }

        function validateForm() {
            const scheduleId = document.getElementById('newScheduleIdInput').value;
            if (!scheduleId) {
                alert('Vui lòng chọn một khung giờ khám còn trống (Bước 3).');
                return false;
            }

            const reason = document.getElementById('reasonInput').value.trim();
            if (!reason) {
                alert('Vui lòng nhập lý do đổi lịch khám.');
                return false;
            }

            return confirm('Xác nhận dời lịch khám sang ngày ' + document.getElementById('summaryNewDate').innerText + ' (' + selectedSlotLabel + ')?');
        }

        document.addEventListener('DOMContentLoaded', function() {
            const dateInput = document.getElementById('dateInput');
            if (dateInput && dateInput.value) {
                onDoctorOrDateChange();
            }
        });
    </script>
</body>
</html>
