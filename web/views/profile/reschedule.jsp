<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<jsp:include page="/views/common/header.jsp"><jsp:param name="pageTitle" value="Đổi bác sĩ / ca khám" /><jsp:param name="bodyClass" value="screen-wide reschedule-wide" /><jsp:param name="fullWidth" value="true" /></jsp:include>
<main class="container-fluid screen-fluid py-5"><h2>Đổi bác sĩ / ca khám #APT-${appointment.id}</h2>
<p>Hiện tại: <c:out value="${appointment.doctorName}" /> · ${appointment.date} · ${appointment.time}</p>
<p>Giữ nguyên dịch vụ và phí khám đã thanh toán. Chỉ đổi trước giờ khám và trước khi check-in.</p>
<form class="card p-4" id="rescheduleForm" method="post" action="${pageContext.request.contextPath}/profile/reschedule" data-url="${pageContext.request.contextPath}/profile/reschedule?id=${appointment.id}&amp;action=slots">
<input type="hidden" name="appointmentId" value="${appointment.id}"><input type="hidden" name="csrfToken" value="${sessionScope.workflowCsrf}">
<div class="reschedule-field"><label for="rescheduleDoctor">Bác sĩ</label><select id="rescheduleDoctor" required class="form-select"><option value="">Chọn bác sĩ</option><c:forEach var="doctor" items="${doctors}"><option value="${doctor.id}" ${doctor.id == appointment.doctor ? 'selected' : ''}><c:out value="${doctor.name}" /> · <c:out value="${doctor.specialty}" /></option></c:forEach></select></div>
<div class="reschedule-field"><label for="rescheduleDate">Ngày khám</label><input type="date" id="rescheduleDate" value="${appointment.date}" class="form-control" required></div>
<div class="reschedule-field reschedule-full"><label for="rescheduleSlot">Ca khám còn trống</label><select id="rescheduleSlot" name="scheduleId" class="form-select" required disabled></select></div><p id="rescheduleStatus" class="reschedule-full" role="status"></p>
<div class="d-flex gap-2 reschedule-full flex-wrap"><button id="rescheduleSave" class="btn btn-success" disabled>Xác nhận đổi lịch</button><a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/views/profile/appointment-history.jsp">Quay lại</a></div></form></main>
<script src="${pageContext.request.contextPath}/assets/js/patient-reschedule.js?v=20261030-utf8" charset="UTF-8"></script><jsp:include page="/views/common/footer.jsp" />
