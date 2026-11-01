<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý lịch làm việc bác sĩ - VisionCare</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/employee.css" rel="stylesheet">
    <style>
        .doctor-card { background:#fff; border:1px solid #e2e8f0; border-radius:14px; padding:24px; margin-bottom:24px; box-shadow:0 4px 16px rgba(0,0,0,.04); }
        .doctor-card-title { display:flex; align-items:center; gap:10px; border-bottom:1px solid #f1f5f9; padding-bottom:12px; margin-bottom:18px; font-size:16px; font-weight:700; color:#0f172a; }
        .doctor-card-title i { color:#008B74; font-size:20px; }
        .doctor-summary { overflow:hidden; padding:0; }
        .doctor-summary-header { background:linear-gradient(135deg,#008B74,#0f766e); color:white; padding:18px 20px; }
        .doctor-summary-body { padding:20px; }
        .summary-grid { display:grid; grid-template-columns:repeat(3,minmax(0,1fr)); gap:12px; }
        .summary-line { display:flex; flex-direction:column; gap:4px; padding:12px 14px; border:1px solid #e2e8f0; border-radius:10px; background:#f8fafc; font-size:14px; }
        .summary-line span:first-child { color:#64748b; }
        .summary-line strong { color:#0f172a; }
        .schedule-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(135px,1fr)); gap:10px; }
        .schedule-slot { border:2px solid #d1fae5; background:#f0fdfa; border-radius:10px; text-align:center; padding:12px 8px; color:#115e59; cursor:pointer; }
        .schedule-slot.booked { border-color:#e2e8f0; background:#f8fafc; color:#475569; }
        .schedule-slot.past { opacity:.6; cursor:not-allowed; }
        .schedule-slot:has(input:checked) { border-color:#008B74; background:#ccfbf1; box-shadow:0 0 0 1px #008B74; }
        .schedule-slot input { margin-bottom:5px; accent-color:#008B74; }
        .schedule-slot small { display:block; font-size:12px; margin-top:2px; }
        .plan-preview { background:#f0fdfa; border:1px solid #99f6e4; border-radius:10px; padding:16px; }
        .appointment-row { display:grid; grid-template-columns:minmax(100px,130px) minmax(150px,1fr) minmax(140px,1fr) auto; gap:14px; align-items:center; padding:16px 0; border-top:1px solid #edf2f7; }
        .appointment-row:first-of-type { border-top:0; }
        .appointment-row small { display:block; color:#64748b; }
        .appointment-row strong { color:#0f172a; }
        .btn-teal { background:#008B74; border-color:#008B74; color:#fff; }
        .btn-teal:hover { background:#0f766e; border-color:#0f766e; color:#fff; }
        @media(max-width:767px) { .summary-grid { grid-template-columns:repeat(2,minmax(0,1fr)); } .appointment-row { grid-template-columns:1fr 1fr; } .appointment-row .appointment-action { grid-column:1/-1; } .appointment-action .btn { width:100%; } }
        @media(max-width:480px) { .summary-grid { grid-template-columns:1fr; } }
    </style>
</head>
<body>
<jsp:include page="/views/employee/layout/employee-sidebar.jsp">
    <jsp:param name="activeNav" value="doctor-reschedule" />
</jsp:include>
<main class="main-wrapper">
    <jsp:include page="/views/employee/layout/employee-header.jsp" />
    <div class="page-content">
        <div class="d-flex justify-content-between align-items-start flex-wrap gap-3 mb-4">
            <div>
                <h4 class="fw-bold mb-1 text-dark">Quản lý lịch làm việc bác sĩ</h4>
                <p class="text-muted mb-0">Xem lịch bác sĩ, chọn ca cần điều chỉnh và rà soát lịch hẹn bị ảnh hưởng.</p>
            </div>
            <a class="btn btn-light border" href="${pageContext.request.contextPath}/staff/appointments"><i class="bi bi-arrow-left me-1"></i>Danh sách lịch hẹn</a>
        </div>

        <c:if test="${not empty filterError}"><div class="alert alert-warning" role="alert"><c:out value="${filterError}"/></div></c:if>
        <div class="row g-4">
            <div class="col-12">
                <section class="doctor-card" aria-labelledby="filterTitle">
                    <h2 id="filterTitle" class="doctor-card-title"><i class="bi bi-person-badge"></i>1. Chọn bác sĩ và ngày làm việc</h2>
                    <form method="get" action="${pageContext.request.contextPath}/staff/doctor-reschedule" class="row g-3 align-items-end">
                        <div class="col-md-6"><label class="form-label fw-semibold" for="doctorId">Bác sĩ</label><select class="form-select" id="doctorId" name="doctorId" required>
                            <c:forEach var="doctor" items="${doctors}"><option value="${doctor.id}" <c:if test="${not empty selectedDoctor && doctor.id == selectedDoctor.id}">selected</c:if>><c:out value="${doctor.fullName}"/> — <c:out value="${doctor.specialty}"/></option></c:forEach>
                        </select></div>
                        <div class="col-md-4"><label class="form-label fw-semibold" for="date">Ngày làm việc</label><input class="form-control" type="date" id="date" name="date" value="${selectedDate}" required></div>
                        <div class="col-md-2"><button class="btn btn-teal w-100" type="submit">Xem lịch</button></div>
                    </form>
                </section>

                <aside class="doctor-card doctor-summary" aria-label="Tóm tắt lịch bác sĩ">
                    <div class="doctor-summary-header"><strong><i class="bi bi-clipboard2-check me-2"></i>Tóm tắt ngày làm việc</strong></div>
                    <div class="doctor-summary-body">
                        <div class="summary-grid">
                            <div class="summary-line"><span>Bác sĩ</span><strong><c:out value="${selectedDoctor.fullName}" default="Chưa chọn"/></strong></div>
                            <div class="summary-line"><span>Chuyên khoa</span><strong><c:out value="${selectedDoctor.specialty}" default="—"/></strong></div>
                            <div class="summary-line"><span>Ngày</span><strong><c:out value="${selectedDate}"/></strong></div>
                            <div class="summary-line"><span>Ca làm việc</span><strong><c:out value="${shiftSummary}"/></strong></div>
                            <div class="summary-line"><span>Khung giờ còn trống</span><strong>${availableCount}</strong></div>
                            <div class="summary-line"><span>Lịch hẹn</span><strong>${fn:length(appointments)}</strong></div>
                        </div>
                        <div class="alert alert-info small mt-3 mb-0"><i class="bi bi-info-circle me-1"></i>Chọn ca làm việc cần điều chỉnh, xem trước phương án và rà soát các lịch hẹn bị ảnh hưởng bên dưới.</div>
                    </div>
                </aside>

                <section class="doctor-card" aria-labelledby="scheduleTitle">
                    <h2 id="scheduleTitle" class="doctor-card-title"><i class="bi bi-calendar3"></i>2. Chọn ca làm việc cần điều chỉnh</h2>
                    <c:choose><c:when test="${empty selectedDoctor}"><p class="text-muted mb-0">Chưa có bác sĩ để hiển thị.</p></c:when>
                    <c:when test="${empty slots}"><div class="text-center py-4 text-muted"><i class="bi bi-calendar-x fs-2 d-block mb-2"></i>Không có khung giờ khám khả dụng trong lịch làm việc ngày này.</div></c:when>
                    <c:otherwise><div class="schedule-grid"><c:forEach var="slot" items="${slots}"><label class="schedule-slot ${slot.booked ? 'booked' : ''} ${slot.past ? 'past' : ''}"><input type="radio" name="sourceSlot" class="shift-slot" value="${slot.id}" data-time="${slot.startTime}–${slot.endTime}" data-booked="${slot.booked}" ${slot.past ? 'disabled' : ''} aria-label="Chọn ca ${slot.startTime} đến ${slot.endTime}"><strong class="d-block"><c:out value="${slot.startTime}"/>–<c:out value="${slot.endTime}"/></strong><small><c:choose><c:when test="${slot.past}">Đã qua</c:when><c:when test="${slot.booked}">Đã có lịch hẹn</c:when><c:otherwise>Chưa có lịch hẹn</c:otherwise></c:choose></small></label></c:forEach></div></c:otherwise></c:choose>
                    <p class="small text-muted mt-3 mb-0">Chọn một khung giờ chưa qua để xem phương án chuyển sang khung giờ khác trong lịch bác sĩ đã đăng ký.</p>
                </section>

                <section class="doctor-card" aria-labelledby="planTitle">
                    <h2 id="planTitle" class="doctor-card-title"><i class="bi bi-calendar2-range"></i>3. Dự kiến lịch làm việc mới</h2>
                    <div class="row g-3">
                        <div class="col-md-6"><label class="form-label fw-semibold" for="newDate">Ngày dự kiến</label><input class="form-control" type="date" id="newDate" min="${today}"></div>
                        <div class="col-12"><div class="form-label fw-semibold">Khung giờ đã đăng ký ở ngày dự kiến</div><p id="targetSlotHint" class="form-text mb-2">Chọn ngày dự kiến để xem các khung giờ bác sĩ đã đăng ký.</p><div id="targetSlotGrid" class="schedule-grid" role="radiogroup" aria-label="Chọn khung giờ dự kiến"></div></div>
                        <div class="col-12"><label class="form-label fw-semibold" for="changeReason">Lý do điều chỉnh</label><textarea class="form-control" id="changeReason" rows="2" maxlength="500" placeholder="Ví dụ: bác sĩ đổi ca trực hoặc có lịch công tác"></textarea></div>
                        <div class="col-12"><button class="btn btn-teal" type="button" id="previewPlan"><i class="bi bi-eye me-1"></i>Xem trước phương án</button></div>
                    </div>
                    <div id="planFeedback" class="mt-3" role="status" aria-live="polite"></div>
                    <div class="alert alert-warning small mt-3 mb-0"><i class="bi bi-exclamation-triangle me-1"></i>Phương án chỉ để rà soát. Hệ thống hiện chưa có chức năng lưu thay đổi ca làm việc của bác sĩ.</div>
                </section>

                <section class="doctor-card" aria-labelledby="appointmentsTitle">
                    <h2 id="appointmentsTitle" class="doctor-card-title"><i class="bi bi-people"></i>4. Lịch hẹn cần rà soát <span class="badge bg-light text-dark border ms-auto">${fn:length(appointments)}</span></h2>
                    <p class="small text-muted">Danh sách toàn bộ lịch hẹn trong ngày đã chọn. Với ca có bệnh nhân, hãy đổi lịch từng cuộc hẹn trước khi điều chỉnh ca làm việc của bác sĩ.</p>
                    <c:choose><c:when test="${empty appointments}"><div class="text-center py-4 text-muted"><i class="bi bi-inbox fs-2 d-block mb-2"></i>Chưa có lịch hẹn của bác sĩ trong ngày này.</div></c:when>
                    <c:otherwise><c:forEach var="appt" items="${appointments}">
                        <div class="appointment-row">
                            <div><small>Giờ khám</small><strong><c:out value="${appt.timeSlot}"/></strong></div>
                            <div><small>Mã #APT-${appt.id}</small><strong><c:out value="${appt.patientName}"/></strong><small><c:out value="${appt.phone}"/></small></div>
                            <div><small>Trạng thái</small><strong><c:out value="${appt.status}"/></strong></div>
                            <div class="appointment-action"><c:choose><c:when test="${appt.canReschedule}"><a class="btn btn-teal btn-sm" href="${pageContext.request.contextPath}/staff/reschedule?appointmentId=${appt.id}"><i class="bi bi-calendar2-range me-1"></i>Đổi lịch</a></c:when><c:otherwise><span class="small text-muted">Không đủ điều kiện đổi lịch</span></c:otherwise></c:choose></div>
                        </div>
                    </c:forEach></c:otherwise></c:choose>
                </section>
            </div>
        </div>
    </div>
</main>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
const targetDateInput = document.getElementById('newDate');
const targetSlotGrid = document.getElementById('targetSlotGrid');
const targetSlotHint = document.getElementById('targetSlotHint');
let targetRequestId = 0;
const minDate = targetDateInput.min || new Date().toISOString().slice(0, 10);
const dateParts = minDate.split('-').map(Number);
targetDateInput.min = minDate;
targetDateInput.max = new Date(Date.UTC(dateParts[0], dateParts[1] - 1, dateParts[2] + 30)).toISOString().slice(0, 10);

targetDateInput.addEventListener('change', async function () {
    const requestId = ++targetRequestId;
    const date = targetDateInput.value;
    targetSlotGrid.replaceChildren();
    targetSlotHint.textContent = 'Chọn ngày dự kiến để xem các khung giờ bác sĩ đã đăng ký.';
    document.getElementById('planFeedback').replaceChildren();
    if (!date) return;
    if (date < targetDateInput.min || date > targetDateInput.max) {
        targetSlotHint.textContent = 'Chọn ngày từ ' + targetDateInput.min + ' đến ' + targetDateInput.max + '. Ngày đang chọn: ' + date + '.';
        return;
    }
    targetSlotHint.textContent = 'Đang tải lịch đã đăng ký…';
    try {
        const params = new URLSearchParams({
            action: 'getSlots',
            doctorId: '${selectedDoctor.id}',
            date: date
        });
        const response = await fetch('${pageContext.request.contextPath}/staff/reschedule?' + params, {credentials: 'same-origin'});
        if (!response.ok) throw new Error('Không tải được lịch');
        const data = await response.json();
        if (requestId !== targetRequestId) return;
        const slots = data.slots || [];
        slots.forEach(slot => {
            const label = document.createElement('label');
            label.className = 'schedule-slot' + (slot.isAvailable ? '' : ' booked');
            const radio = document.createElement('input');
            radio.type = 'radio';
            radio.name = 'targetSlot';
            radio.className = 'target-slot';
            radio.value = String(slot.scheduleId);
            radio.dataset.time = slot.startTime + '–' + slot.endTime;
            radio.disabled = !slot.isAvailable;
            radio.setAttribute('aria-label', 'Chọn khung giờ ' + radio.dataset.time);
            const time = document.createElement('strong');
            time.className = 'd-block';
            time.textContent = radio.dataset.time;
            const status = document.createElement('small');
            status.textContent = slot.isAvailable ? 'Còn trống' : 'Đã có lịch hẹn / đã qua';
            label.append(radio, time, status);
            targetSlotGrid.appendChild(label);
        });
        const availableCount = slots.filter(slot => slot.isAvailable).length;
        targetSlotHint.textContent = slots.length
            ? slots.length + ' khung giờ đã đăng ký; ' + availableCount + ' khung giờ còn trống để chọn.'
            : 'Bác sĩ không có khung giờ đã đăng ký trong ngày này.';
    } catch (error) {
        if (requestId !== targetRequestId) return;
        targetSlotHint.textContent = 'Không tải được lịch đã đăng ký. Vui lòng chọn lại ngày.';
    }
});

document.getElementById('previewPlan').addEventListener('click', function () {
    const source = document.querySelector('.shift-slot:checked');
    const date = targetDateInput.value;
    const target = document.querySelector('.target-slot:checked');
    const feedback = document.getElementById('planFeedback');
    feedback.replaceChildren();
    if (!source || !date || !target) {
        feedback.className = 'alert alert-danger mt-3';
        feedback.textContent = 'Hãy chọn ca hiện tại, ngày dự kiến và khung giờ đã đăng ký còn trống.';
        return;
    }
    if (date < targetDateInput.min || date > targetDateInput.max) {
        feedback.className = 'alert alert-danger mt-3';
        feedback.textContent = 'Ngày dự kiến phải nằm trong 30 ngày tới.';
        return;
    }
    if (source.value === target.value) {
        feedback.className = 'alert alert-danger mt-3';
        feedback.textContent = 'Khung giờ dự kiến phải khác khung giờ hiện tại.';
        return;
    }
    const reason = document.getElementById('changeReason').value.trim();
    feedback.className = 'plan-preview mt-3';
    const heading = document.createElement('strong');
    heading.textContent = 'Bản xem trước — chưa lưu';
    feedback.appendChild(heading);
    const details = document.createElement('p');
    details.className = 'mb-0 mt-2';
    details.textContent = 'Khung giờ ' + source.dataset.time + ' → ' + target.dataset.time + ', ngày ' + date + '. ' + (source.dataset.booked === 'true' ? 'Khung giờ hiện tại có lịch hẹn cần rà soát.' : 'Khung giờ hiện tại chưa có lịch hẹn.') + (reason ? ' Lý do: ' + reason : '');
    feedback.appendChild(details);
});
</script>
</body>
</html>
