<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Yêu cầu nghỉ buổi làm việc - VisionCare</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<link href="${pageContext.request.contextPath}/assets/css/employee.css" rel="stylesheet">
<style>
.leave-page{max-width:1600px;margin:auto;color:#243746}.leave-hero{display:flex;justify-content:space-between;gap:20px;align-items:start;margin-bottom:26px}.leave-kicker{color:#008b74;font-size:12px;letter-spacing:.1em;text-transform:uppercase;font-weight:700;margin-bottom:8px}.leave-hero h1{font-size:28px;font-weight:700;letter-spacing:-.6px;margin:0 0 8px}.leave-subtitle{color:#64748b;max-width:720px;font-size:14px;line-height:1.6;margin:0}.leave-role{padding:8px 14px;background:#e8f6f2;border:1px solid #cfebe4;border-radius:30px;font-size:13px;color:#00725f;white-space:nowrap}.leave-stats{display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin-bottom:24px}.leave-stat{background:white;border:1px solid #e3eaf0;border-radius:14px;padding:18px 22px;display:flex;align-items:center;gap:15px}.leave-stat i{font-size:22px;padding:11px;border-radius:12px;background:#f0f7f6;color:#008b74}.leave-stat strong{display:block;font-size:25px;line-height:1.2}.leave-stat span{font-size:13px;color:#64748b}.leave-columns{display:grid;grid-template-columns:minmax(0,1.35fr) minmax(300px,1fr);gap:22px;align-items:start}.leave-panel{background:white;border:1px solid #e3eaf0;border-radius:16px;overflow:hidden}.leave-panel-head{padding:22px 24px;border-bottom:1px solid #edf1f5;display:flex;align-items:center;justify-content:space-between;gap:10px}.leave-panel-head h2{font-size:17px;font-weight:700;margin:0}.leave-panel-head small{font-size:12px;color:#64748b}.leave-panel-body{padding:24px}.leave-panel .form-label{font-weight:600;font-size:13px;margin-bottom:8px}.leave-panel .form-control,.leave-panel .form-select{border-color:#dce5ec;border-radius:9px;padding:11px 13px;font-size:14px}.leave-panel textarea{resize:vertical;min-height:132px}.leave-hint{font-size:12px;color:#64748b;line-height:1.6;margin-top:8px}.leave-step{font-size:11px;background:#edf7f4;color:#00725f;border-radius:6px;padding:4px 8px;font-weight:700}.leave-note{border-radius:10px;background:#f1f8f6;border:1px solid #dcefe9;padding:14px 16px;color:#45635a;font-size:13px;line-height:1.7}.leave-note.warning{background:#fff9ed;border-color:#f4e5be;color:#806128}.leave-submit{background:#008b74;border-color:#008b74;color:white;border-radius:9px;font-weight:600;padding:11px 18px}.leave-submit:hover{background:#00735f;color:white}.leave-submit:disabled{background:#9dbbb3;color:white;border-color:transparent;cursor:not-allowed}.leave-foot{border-top:1px solid #edf1f5;padding-top:20px;margin-top:22px;display:flex;align-items:center;justify-content:space-between;gap:12px}.leave-empty{text-align:center;padding:34px 20px;color:#8493a4;font-size:13px}.leave-empty i{display:block;font-size:30px;color:#a5bbb5;margin-bottom:10px}.leave-patient{padding:14px 0;border-bottom:1px solid #edf1f5;display:flex;justify-content:space-between;gap:12px}.leave-patient:last-child{border:0}.leave-patient strong{font-size:14px}.leave-patient small{display:block;font-size:12px;color:#64748b;margin-top:4px}.leave-history{margin-top:24px}.leave-history table{font-size:13px;margin:0}.leave-history th{background:#f8fafc;color:#64748b;font-weight:600;font-size:12px;border-bottom:1px solid #e3eaf0;white-space:nowrap;padding:15px 20px}.leave-history td{padding:18px 20px;vertical-align:top;color:#334155;border-color:#f0f3f6}.leave-history td small{display:block;color:#8592a1;margin-top:5px}.leave-reason{max-width:340px;white-space:pre-wrap;overflow-wrap:anywhere}.leave-status{padding:6px 10px;display:inline-block;border-radius:7px;font-size:11px;font-weight:600;white-space:nowrap}.leave-status.Pending{background:#fff4d8;color:#956c11}.leave-status.Approved{background:#e4f5ed;color:#187b54}.leave-status.Rejected{background:#fdecef;color:#b74a5b}.leave-person{background:#f8fafc;border:1px solid #e5ebf0;border-radius:9px;padding:14px 16px;margin-bottom:14px}.leave-person strong{font-size:14px}.leave-person small{display:block;color:#64748b;margin-top:4px}.leave-section-label{font-size:12px;font-weight:600;color:#64748b;margin-bottom:12px}.leave-check{padding:12px 0;font-size:13px;line-height:1.6}.leave-check input{accent-color:#008b74;margin-right:6px}
@media(max-width:1100px){.leave-columns{grid-template-columns:1fr}.leave-hero h1{font-size:24px}}@media(max-width:650px){.leave-hero{flex-direction:column}.leave-stats{gap:8px}.leave-stat{padding:12px;display:block}.leave-stat i{display:none}.leave-stat strong{font-size:22px}.leave-stat span{font-size:11px}.leave-panel-head,.leave-panel-body{padding:18px}.leave-foot{align-items:stretch;flex-direction:column}.leave-page{padding:18px!important}}
</style></head><body>
<jsp:include page="/views/employee/layout/employee-sidebar.jsp"><jsp:param name="activeNav" value="leave-requests"/></jsp:include>
<main class="main-wrapper"><jsp:include page="/views/employee/layout/employee-header.jsp"/>
<div class="page-content leave-page">
<c:if test="${!previewOnly and not empty sessionScope.successMessage}"><div class="alert alert-success" role="status"><c:out value="${sessionScope.successMessage}"/></div><c:remove var="successMessage" scope="session"/></c:if>
<c:if test="${!previewOnly and not empty sessionScope.errorMessage}"><div class="alert alert-danger" role="alert"><c:out value="${sessionScope.errorMessage}"/></div><c:remove var="errorMessage" scope="session"/></c:if>
<c:if test="${not empty formError}"><div class="alert alert-warning" role="alert"><c:out value="${formError}"/></div></c:if>

<c:set var="pendingOwn" value="0"/><c:set var="approvedOwn" value="0"/>
<c:forEach items="${requests}" var="r"><c:if test="${r.requestStatus == 'Pending'}"><c:set var="pendingOwn" value="${pendingOwn+1}"/></c:if><c:if test="${r.requestStatus == 'Approved'}"><c:set var="approvedOwn" value="${approvedOwn+1}"/></c:if></c:forEach>
<header class="leave-hero"><div><div class="leave-kicker">Lịch làm việc / Yêu cầu nghỉ</div><h1>Xin nghỉ buổi làm việc</h1><p class="leave-subtitle">Gửi yêu cầu nghỉ theo buổi và theo dõi phản hồi của giám đốc. Lịch chỉ chuyển sang nghỉ sau khi được chấp thuận.</p></div><span class="leave-role"><i class="bi bi-person-badge me-1"></i><c:out value="${actorLabel}"/></span></header>
<div class="leave-stats"><div class="leave-stat"><i class="bi bi-inbox"></i><div><strong>${fn:length(requests)}</strong><span>Yêu cầu đã gửi</span></div></div><div class="leave-stat"><i class="bi bi-clock-history"></i><div><strong>${pendingOwn}</strong><span>Đang chờ duyệt</span></div></div><div class="leave-stat"><i class="bi bi-calendar-check"></i><div><strong>${approvedOwn}</strong><span>Đã được duyệt</span></div></div></div>
<div class="leave-columns">
<section class="leave-panel"><div class="leave-panel-head"><h2>Tạo yêu cầu nghỉ</h2><span class="leave-step">Cả buổi</span></div><div class="leave-panel-body">
<form method="post" id="leave-request-form"><input type="hidden" name="csrfToken" value="${sessionScope.scheduleCsrf}">
<div class="mb-4"><label class="form-label" for="scheduleId">Ngày và buổi muốn nghỉ <span class="text-danger">*</span></label>
<select id="scheduleId" name="scheduleId" class="form-select" required>
<option value="">Chọn một buổi đã đăng ký</option><c:forEach items="${shifts}" var="s"><option value="${s.scheduleId}" ${selectedShift == s.scheduleId ? 'selected' : ''}><c:out value="${s.workDate}"/> · Buổi <c:out value="${s.shiftName}"/> · <c:out value="${fn:substring(s.startTime,0,5)}"/>–<c:out value="${fn:substring(s.endTime,0,5)}"/><c:if test="${sessionScope.user.roleId == 3}"> · ${s.affectedCount} lịch hẹn</c:if></option></c:forEach></select>
<div id="preview-status" class="leave-hint" role="status" aria-live="polite"></div>
<div class="leave-hint">Chỉ gửi cho buổi chưa bắt đầu, chưa tiếp đón bệnh nhân và chưa có yêu cầu nghỉ đang chờ.</div>
<c:if test="${empty shifts}"><div class="leave-note warning mt-3">Bạn chưa có buổi làm việc đủ điều kiện để gửi yêu cầu nghỉ.</div></c:if></div>
<div><label class="form-label" for="reason">Lý do xin nghỉ <span class="text-danger">*</span></label><textarea id="reason" name="reason" class="form-control" maxlength="2000" rows="5" placeholder="Nêu rõ lý do để giám đốc xem xét yêu cầu…" required><c:out value="${draftReason}"/></textarea><div class="leave-hint"><span id="reason-count">${fn:length(draftReason)}</span>/2.000 ký tự. Nội dung được giữ lại khi đổi buổi.</div></div>
<div id="leave-impact-confirmation">
<input type="hidden" name="reviewedCount" value="${empty selectedShift ? -1 : fn:length(affectedAppointments)}">
<c:if test="${sessionScope.user.roleId == 3 and not empty affectedAppointments}"><div class="leave-note warning mt-3"><strong><i class="bi bi-exclamation-triangle me-1"></i>Buổi này đã có ${fn:length(affectedAppointments)} lịch hẹn</strong><div class="mt-1">Gửi yêu cầu không tự đổi bác sĩ, hủy lịch hay thông báo cho bệnh nhân. Các lịch hẹn cần có phương án xử lý khi xem xét nghỉ.</div><label class="leave-check mb-0"><input type="checkbox" name="impactConfirmed" value="yes" required>Tôi đã xem danh sách bệnh nhân bị ảnh hưởng và xác nhận gửi yêu cầu.</label></div></c:if>
</div>
<div class="leave-foot"><small class="text-muted">Đây là yêu cầu xin nghỉ, chưa phải xác nhận được nghỉ.</small><button id="send-leave" class="btn leave-submit" ${empty selectedShift ? 'disabled' : ''}><i class="bi bi-send me-2"></i>Gửi yêu cầu</button></div>
</form></div></section>
<aside class="leave-panel" id="leave-impact-panel" data-ready="${not empty selectedShift}" aria-live="polite"><div class="leave-panel-head"><h2>Thông tin buổi xin nghỉ</h2><i class="bi bi-calendar2-week text-success"></i></div><div class="leave-panel-body">
<c:choose><c:when test="${empty selectedShift}"><div class="leave-empty"><i class="bi bi-calendar2-plus"></i>Chọn một buổi để xem thông tin trước khi gửi.</div></c:when><c:otherwise>
<c:forEach items="${shifts}" var="s"><c:if test="${s.scheduleId == selectedShift}"><div class="leave-person"><strong><c:out value="${s.workDate}"/> · Buổi <c:out value="${s.shiftName}"/></strong><small><c:out value="${fn:substring(s.startTime,0,5)}"/>–<c:out value="${fn:substring(s.endTime,0,5)}"/> · Toàn bộ ${s.slotCount} khung giờ</small></div></c:if></c:forEach>
<c:choose><c:when test="${sessionScope.user.roleId == 3}"><div class="leave-section-label">LỊCH HẸN BỊ ẢNH HƯỞNG · ${fn:length(affectedAppointments)}</div>
<div class="leave-patient-list" style="max-height:440px;overflow-y:auto"><c:forEach items="${affectedAppointments}" var="a"><div class="leave-patient"><div><strong><c:out value="${a.patientName}"/></strong><small>#APT-${a.id} · <c:out value="${a.phone}"/></small><small><c:choose><c:when test="${a.status == 'Confirmed'}">Đã xác nhận</c:when><c:otherwise>Chờ xác nhận</c:otherwise></c:choose></small></div><span class="text-muted small"><c:out value="${fn:substring(a.startTime,0,5)}"/></span></div></c:forEach></div>
<c:if test="${empty affectedAppointments}"><div class="leave-empty"><i class="bi bi-people"></i>Buổi này chưa có lịch hẹn cần sắp xếp lại.</div></c:if>
<div class="leave-note mt-3">Các lịch hẹn hiện có được giữ nguyên. Danh sách này giúp bạn và giám đốc xem xét ảnh hưởng trước khi quyết định.</div></c:when>
<c:otherwise><div class="leave-note">Yêu cầu áp dụng cho cả buổi làm việc của BSPT. Các ca thủ thuật đang phụ trách cần được trao đổi bàn giao với quản lý; việc duyệt nghỉ không tự chuyển ca thủ thuật cho người khác.</div></c:otherwise></c:choose>
</c:otherwise></c:choose>
<div class="leave-hint mt-4"><i class="bi bi-info-circle me-1"></i>Yêu cầu bị từ chối sẽ giữ nguyên lịch làm việc.</div>
</div></aside></div>
<section class="leave-panel leave-history"><div class="leave-panel-head"><h2>Lịch sử yêu cầu của tôi</h2><small>${fn:length(requests)} yêu cầu</small></div>
<div class="table-responsive"><table class="table"><thead><tr><th>Ngày / buổi xin nghỉ</th><th>Lý do và phản hồi</th><th>Trạng thái</th><th>Người duyệt</th></tr></thead><tbody>
<c:forEach items="${requests}" var="r"><tr><td><strong><c:out value="${r.leaveDate}"/></strong><small><c:out value="${r.slotName}"/> · <c:out value="${r.startTime}"/>–<c:out value="${r.endTime}"/></small><small>Gửi lúc <c:out value="${r.createdAt}"/></small></td>
<td class="leave-reason"><c:out value="${r.reason}"/></td><td><span class="leave-status ${r.requestStatus}"><c:out value="${r.statusVn}"/></span><c:if test="${r.requestStatus == 'Pending'}"><small>Chờ giám đốc xem xét; lịch chưa chuyển sang nghỉ.</small></c:if></td><td><c:out value="${r.approverName}"/><c:if test="${r.requestStatus != 'Pending'}"><small><c:out value="${r.approvedAt}"/></small></c:if></td></tr></c:forEach>
<c:if test="${empty requests}"><tr><td colspan="4"><div class="leave-empty"><i class="bi bi-inbox"></i>Chưa có yêu cầu nghỉ. Các yêu cầu bạn gửi sẽ xuất hiện tại đây.</div></td></tr></c:if>
</tbody></table></div></section></div></main><script>
(() => {
  const form = document.getElementById('leave-request-form');
  const select = document.getElementById('scheduleId');
  const send = document.getElementById('send-leave');
  const reason = document.getElementById('reason');
  const status = document.getElementById('preview-status');
  let controller, sequence = 0, loading = false;
  const ready = () => !!select.value && document.getElementById('leave-impact-panel').dataset.ready === 'true';
  reason.addEventListener('input', () => {
    document.getElementById('reason-count').textContent = reason.value.length;
    reason.setCustomValidity(reason.value.trim() ? '' : 'Vui lòng nhập lý do xin nghỉ.');
  });
  select.addEventListener('change', async () => {
    if (controller) controller.abort();
    controller = new AbortController();
    const current = ++sequence;
    loading = true;
    send.disabled = true;
    status.textContent = 'Đang kiểm tra buổi làm việc và lịch hẹn…';
    document.getElementById('leave-impact-panel').setAttribute('aria-busy', 'true');
    try {
      const url = new URL(form.action || window.location.href);
      url.search = '';
      url.searchParams.set('scheduleId', select.value);
      url.searchParams.set('preview', '1');
      const response = await fetch(url, {signal: controller.signal, headers: {'X-Requested-With': 'XMLHttpRequest'}, cache: 'no-store'});
      if (!response.ok) throw new Error('Buổi làm việc đã thay đổi hoặc không còn khả dụng. Vui lòng chọn lại.');
      const page = new DOMParser().parseFromString(await response.text(), 'text/html');
      const panel = page.getElementById('leave-impact-panel');
      const confirmation = page.getElementById('leave-impact-confirmation');
      if (!panel || !confirmation) throw new Error('Không tải được thông tin. Vui lòng tải lại trang hoặc đăng nhập lại.');
      if (current !== sequence) return;
      document.getElementById('leave-impact-panel').replaceWith(document.importNode(panel, true));
      document.getElementById('leave-impact-confirmation').replaceWith(document.importNode(confirmation, true));
      status.textContent = select.value ? 'Đã cập nhật danh sách lịch hẹn.' : '';
      const address = new URL(window.location.href);
      if (select.value) address.searchParams.set('scheduleId', select.value); else address.searchParams.delete('scheduleId');
      address.searchParams.delete('preview');
      history.replaceState(null, '', address);
    } catch (error) {
      if (error.name === 'AbortError' || current !== sequence) return;
      document.getElementById('leave-impact-panel').dataset.ready = 'false';
      document.querySelector('#leave-impact-panel .leave-panel-body').replaceChildren(document.createTextNode(error.message));
      status.textContent = error.message;
    } finally {
      if (current === sequence) {
        loading = false;
        document.getElementById('leave-impact-panel').removeAttribute('aria-busy');
        send.disabled = !ready();
      }
    }
  });
  form.addEventListener('submit', event => {
    reason.setCustomValidity(reason.value.trim() ? '' : 'Vui lòng nhập lý do xin nghỉ.');
    if (loading || !ready() || !form.reportValidity()) {event.preventDefault();return;}
    send.disabled = true;
    send.textContent = 'Đang gửi yêu cầu…';
  });
  window.addEventListener('pageshow', () => {send.disabled = loading || !ready();});
})();
</script></body></html>
