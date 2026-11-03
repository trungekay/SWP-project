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
        <c:if test="${not empty sessionScope.successMessage}"><div class="alert alert-success" role="status"><c:out value="${sessionScope.successMessage}"/></div><c:remove var="successMessage" scope="session"/></c:if>
        <c:if test="${not empty sessionScope.errorMessage}"><div class="alert alert-danger" role="alert"><c:out value="${sessionScope.errorMessage}"/></div><c:remove var="errorMessage" scope="session"/></c:if>
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
                        <div class="alert alert-info small mt-3 mb-0"><i class="bi bi-info-circle me-1"></i>Chọn ca cần điều chỉnh. Ca có lịch hẹn sẽ được chuyển sang bác sĩ thay thế; ca trống sẽ được đóng.</div>
                    </div>
                </aside>

                <section class="doctor-card" aria-labelledby="scheduleTitle">
                    <h2 id="scheduleTitle" class="doctor-card-title"><i class="bi bi-calendar3"></i>2. Chọn ca làm việc cần điều chỉnh</h2>
                    <c:choose><c:when test="${empty selectedDoctor}"><p class="text-muted mb-0">Chưa có bác sĩ để hiển thị.</p></c:when>
                    <c:when test="${empty slots}"><div class="text-center py-4 text-muted"><i class="bi bi-calendar-x fs-2 d-block mb-2"></i>Không có khung giờ khám khả dụng trong lịch làm việc ngày này.</div></c:when>
                    <c:otherwise>
                        <div id="sourceSlots" hidden><c:forEach var="slot" items="${slots}"><span data-session="${slot.session}" data-start="${slot.startTime}" data-end="${slot.endTime}" data-booked="${slot.booked}" data-past="${slot.past}"></span></c:forEach></div>
                        <div class="schedule-grid">
                            <label id="morningCard" class="schedule-slot" hidden><input type="radio" name="sourceSlot" class="shift-slot" value="Morning"><strong class="d-block">Ca Sáng (08:00–11:30)</strong><small></small></label>
                            <label id="afternoonCard" class="schedule-slot" hidden><input type="radio" name="sourceSlot" class="shift-slot" value="Afternoon"><strong class="d-block">Ca Chiều (13:30–17:00)</strong><small></small></label>
                        </div>
                    </c:otherwise></c:choose>
                    <p class="small text-muted mt-3 mb-0">Chọn cả buổi như khi đăng ký lịch. Ca đã bắt đầu không thể điều chỉnh; lịch hẹn trong ca cần bác sĩ thay thế có khung giờ tương ứng.</p>
                </section>

                <section class="doctor-card" aria-labelledby="planTitle">
                    <h2 id="planTitle" class="doctor-card-title"><i class="bi bi-calendar2-range"></i>3. Phương án điều chỉnh</h2>
                    <form id="doctorChangeForm" action="${pageContext.request.contextPath}/staff/doctor-reschedule" method="post">
                        <input type="hidden" name="csrfToken" value="${csrfToken}">
                        <input type="hidden" name="doctorId" value="${selectedDoctor.id}">
                        <input type="hidden" name="viewDate" value="${selectedDate}">
                        <input type="hidden" name="sourceSession" id="sourceSession">
                        <div class="row g-3">
                            <div class="col-12"><div id="sourceHint" class="alert alert-light border mb-0">Chọn một ca làm việc ở mục 2 để tiếp tục.</div></div>
                            <div id="replacementFields" class="col-12" hidden>
                                <div class="row g-3">
                                    <div class="col-md-6"><label class="form-label fw-semibold" for="replacementDoctorId">Bác sĩ thay thế</label><select class="form-select" id="replacementDoctorId" name="replacementDoctorId"><option value="">Chọn bác sĩ thay thế</option><c:forEach var="doctor" items="${doctors}"><c:if test="${empty selectedDoctor || doctor.id != selectedDoctor.id}"><option value="${doctor.id}"><c:out value="${doctor.fullName}"/> — <c:out value="${doctor.specialty}"/></option></c:if></c:forEach></select></div>
                                    <div class="col-md-6"><label class="form-label fw-semibold" for="newDate">Ngày dự kiến</label><input class="form-control" type="date" id="newDate" name="targetDate" min="${today}"></div>
                                    <div class="col-12"><div class="form-label fw-semibold">Khung giờ tương ứng của bác sĩ thay thế</div><p id="targetSlotHint" class="form-text mb-2">Chọn bác sĩ thay thế và ngày dự kiến để kiểm tra các lịch hẹn.</p><div id="targetSlotGrid" class="schedule-grid"></div></div>
                                </div>
                            </div>
                            <div class="col-12"><label class="form-label fw-semibold" for="changeReason">Lý do điều chỉnh <span class="text-danger">*</span></label><textarea class="form-control" id="changeReason" name="reason" rows="2" minlength="10" maxlength="500" required placeholder="Ví dụ: bác sĩ đổi ca trực hoặc có lịch công tác"></textarea></div>
                            <div class="col-12 d-flex flex-wrap gap-2"><button class="btn btn-light border" type="button" id="previewPlan"><i class="bi bi-eye me-1"></i>Xem trước phương án</button><button class="btn btn-teal" type="submit" id="saveDoctorChange"><i class="bi bi-check2-circle me-1"></i>Xác nhận điều chỉnh</button></div>
                        </div>
                    </form>
                    <div id="planFeedback" class="mt-3" role="status" aria-live="polite"></div>
                    <div class="alert alert-warning small mt-3 mb-0"><i class="bi bi-exclamation-triangle me-1"></i>Khi xác nhận, ca cũ sẽ đóng. Nếu ca đã có lịch hẹn, hệ thống sẽ chuyển lịch hẹn sang bác sĩ và khung giờ mới, sau đó gửi email cho bệnh nhân nếu có địa chỉ email.</div>
                </section>

                <section class="doctor-card" aria-labelledby="appointmentsTitle">
                    <h2 id="appointmentsTitle" class="doctor-card-title"><i class="bi bi-people"></i>4. Lịch hẹn cần rà soát <span class="badge bg-light text-dark border ms-auto">${fn:length(appointments)}</span></h2>
                    <p class="small text-muted">Danh sách toàn bộ lịch hẹn trong ngày đã chọn. Lịch hẹn ở ca được chọn sẽ tự chuyển sang bác sĩ thay thế khi xác nhận.</p>
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
const replacementDoctorSelect = document.getElementById('replacementDoctorId');
const targetSlotGrid = document.getElementById('targetSlotGrid');
const targetSlotHint = document.getElementById('targetSlotHint');
const sourceHint = document.getElementById('sourceHint');
const replacementFields = document.getElementById('replacementFields');
const sourceSessionInput = document.getElementById('sourceSession');
const changeForm = document.getElementById('doctorChangeForm');
const sourceSlots = [...document.querySelectorAll('#sourceSlots span')].map(el => ({
    session: el.dataset.session,
    start: el.dataset.start,
    end: el.dataset.end,
    booked: el.dataset.booked === 'true',
    past: el.dataset.past === 'true'
}));
let targetRequestId = 0;
let targetReady = false;
const minDate = targetDateInput.min || new Date().toISOString().slice(0, 10);
const dateParts = minDate.split('-').map(Number);
targetDateInput.min = minDate;
targetDateInput.max = new Date(Date.UTC(dateParts[0], dateParts[1] - 1, dateParts[2] + 30)).toISOString().slice(0, 10);

function selectedShift() {
    return document.querySelector('.shift-slot:checked');
}
function bookedSlots() {
    const selected = selectedShift();
    return selected ? sourceSlots.filter(slot => slot.session === selected.value && slot.booked) : [];
}
for (const [session, cardId] of [['Morning', 'morningCard'], ['Afternoon', 'afternoonCard']]) {
    const card = document.getElementById(cardId);
    if (!card) continue;
    const slots = sourceSlots.filter(slot => slot.session === session);
    if (!slots.length) continue;
    card.hidden = false;
    const booked = slots.filter(slot => slot.booked).length;
    const past = slots.some(slot => slot.past);
    card.classList.toggle('booked', booked > 0);
    card.classList.toggle('past', past);
    card.querySelector('input').disabled = past;
    card.querySelector('small').textContent = past
        ? 'Ca đã bắt đầu hoặc đã qua'
        : slots.length + ' khung giờ · ' + booked + ' lịch hẹn';
}
document.querySelectorAll('.shift-slot').forEach(radio => radio.addEventListener('change', function () {
    sourceSessionInput.value = radio.value;
    const booked = bookedSlots().length;
    replacementFields.hidden = booked === 0;
    sourceHint.textContent = booked
        ? 'Ca ' + (radio.value === 'Morning' ? 'Sáng' : 'Chiều') + ' có ' + booked + ' lịch hẹn. Chọn bác sĩ thay thế có đủ khung giờ tương ứng.'
        : 'Ca ' + (radio.value === 'Morning' ? 'Sáng' : 'Chiều') + ' chưa có lịch hẹn. Xác nhận sẽ đóng toàn bộ khung giờ của ca.';
    document.getElementById('planFeedback').replaceChildren();
    loadTargetSlots();
}));

async function loadTargetSlots() {
    const requestId = ++targetRequestId;
    targetReady = false;
    targetSlotGrid.replaceChildren();
    targetSlotHint.textContent = 'Chọn bác sĩ thay thế và ngày dự kiến để kiểm tra các lịch hẹn.';
    const date = targetDateInput.value;
    const doctorId = replacementDoctorSelect.value;
    const required = bookedSlots();
    if (!required.length || !date || !doctorId) return;
    if (date < targetDateInput.min || date > targetDateInput.max) {
        targetSlotHint.textContent = 'Ngày thay thế phải nằm trong 30 ngày tới.';
        return;
    }
    targetSlotHint.textContent = 'Đang kiểm tra lịch đã đăng ký…';
    try {
        const params = new URLSearchParams({action: 'slots', doctorId, date});
        const response = await fetch('${pageContext.request.contextPath}/staff/doctor-reschedule?' + params, {credentials: 'same-origin'});
        if (!response.ok) throw new Error('Không tải được lịch');
        const data = await response.json();
        if (requestId !== targetRequestId) return;
        const available = (data.slots || []).filter(slot => slot.isAvailable);
        const missing = required.filter(source => !available.some(target =>
            target.startTime === source.start && target.endTime === source.end));
        targetReady = missing.length === 0;
        for (const source of required) {
            const ready = !missing.includes(source);
            const line = document.createElement('div');
            line.className = 'schedule-slot' + (ready ? '' : ' booked');
            line.textContent = source.start + '–' + source.end + (ready ? ' · Còn trống' : ' · Không có khung giờ trống');
            targetSlotGrid.appendChild(line);
        }
        targetSlotHint.textContent = targetReady
            ? 'Đủ ' + required.length + ' khung giờ tương ứng để chuyển lịch hẹn.'
            : 'Thiếu ' + missing.length + ' khung giờ tương ứng. Chọn bác sĩ hoặc ngày khác.';
    } catch (error) {
        if (requestId !== targetRequestId) return;
        targetSlotHint.textContent = 'Không tải được lịch đã đăng ký. Vui lòng chọn lại ngày.';
    }
}
targetDateInput.addEventListener('change', loadTargetSlots);
replacementDoctorSelect.addEventListener('change', loadTargetSlots);

function showPlanError(message) {
    const feedback = document.getElementById('planFeedback');
    feedback.className = 'alert alert-danger mt-3';
    feedback.textContent = message;
}
function validatePlan() {
    const source = selectedShift();
    if (!source) return 'Hãy chọn ca làm việc cần điều chỉnh ở mục 2.';
    if (bookedSlots().length && (!replacementDoctorSelect.value || !targetDateInput.value || !targetReady)) {
        return 'Hãy chọn bác sĩ thay thế và ngày có đủ khung giờ tương ứng.';
    }
    const reason = document.getElementById('changeReason').value.trim();
    if (reason.length < 10 || reason.length > 500) return 'Lý do điều chỉnh cần từ 10 đến 500 ký tự.';
    return null;
}
document.getElementById('previewPlan').addEventListener('click', function () {
    const error = validatePlan();
    if (error) return showPlanError(error);
    const source = selectedShift();
    const count = sourceSlots.filter(slot => slot.session === source.value).length;
    const booked = bookedSlots().length;
    const feedback = document.getElementById('planFeedback');
    feedback.className = 'plan-preview mt-3';
    feedback.textContent = 'Bản xem trước — chưa lưu: Đóng ' + count + ' khung giờ ca '
        + (source.value === 'Morning' ? 'Sáng' : 'Chiều') + '; chuyển ' + booked
        + ' lịch hẹn' + (booked ? ' sang ' + replacementDoctorSelect.selectedOptions[0].textContent
        + ' ngày ' + targetDateInput.value + ' ở cùng giờ' : '') + '.';
});
changeForm.addEventListener('submit', function (event) {
    const error = validatePlan();
    if (error) {
        event.preventDefault();
        showPlanError(error);
    }
});
</script>
</body>
</html>
