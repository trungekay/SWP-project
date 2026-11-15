<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chuyển ca thủ thuật - VisionCare</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/employee.css" rel="stylesheet">
    <style>.request-grid{display:grid;grid-template-columns:minmax(0,1fr) minmax(0,1fr);gap:24px}.request-card{background:white;border:1px solid #dce5ed;border-radius:16px;padding:24px}.request-card h2{font-size:20px;margin-bottom:20px}.clinical-text{white-space:pre-wrap;overflow-wrap:anywhere}.request-list{max-height:420px;overflow:auto}@media(max-width:1000px){.request-grid{grid-template-columns:1fr}}</style>
</head>
<body>
<jsp:include page="/views/employee/layout/employee-sidebar.jsp"><jsp:param name="activeNav" value="procedure-requests"/></jsp:include>
<main class="main-wrapper">
    <jsp:include page="/views/employee/layout/employee-header.jsp"/>
    <div class="page-content">
        <h1 class="h3 mb-2">Chuyển ca sang bác sĩ phẫu thuật</h1>
        <p class="text-muted mb-4">Chọn bệnh nhân đã check-in hôm nay và dịch vụ cần thực hiện. Chỉ chuyển sang BSPT sau khi bác sĩ đã lưu đầy đủ kết quả khám của lượt này.</p>
        <c:if test="${not schemaReady}"><div class="alert alert-warning">Chức năng chưa sẵn sàng: cơ sở dữ liệu cần được cập nhật trước khi gửi ca.</div></c:if>
        <c:if test="${not empty formError}"><div class="alert alert-danger" role="alert"><c:out value="${formError}"/></div></c:if>
        <c:if test="${not empty sessionScope.procedureRequestSuccess}"><div class="alert alert-success" role="status"><c:out value="${sessionScope.procedureRequestSuccess}"/></div><c:remove var="procedureRequestSuccess" scope="session"/></c:if>
        <div class="request-grid">
            <section class="request-card">
                <h2>Thông tin chuyển ca</h2>
                <form method="get" id="patientSelection">
                    <label for="appointmentId" class="form-label">Lượt khám gốc (APT) / Bệnh nhân đã check-in</label>
                    <select id="appointmentId" name="appointmentId" class="form-select mb-3" required>
                        <option value="">Chọn bệnh nhân</option>
                        <c:forEach var="p" items="${patients}"><option value="${p.appointmentId}" ${selectedAppointment == p.appointmentId ? 'selected' : ''}>#APT-${p.appointmentId} — <c:out value="${p.name}"/> — <c:out value="${p.phone}"/></option></c:forEach>
                    </select>
                    <button type="submit" class="btn btn-outline-secondary mb-4">Xem thông tin lượt khám</button>
                </form>
                <c:if test="${empty patients}"><p class="text-muted">Chưa có bệnh nhân đủ điều kiện chuyển ca hôm nay.</p></c:if>
                <form method="post" id="procedureRequestForm">
                    <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.procedureRequestCsrf}'/>">
                    <input type="hidden" name="appointmentId" value="${selectedAppointment}">
                    <label for="serviceId" class="form-label">Dịch vụ thủ thuật <span class="text-danger">*</span></label>
                    <select id="serviceId" name="serviceId" class="form-select mb-3" required>
                        <option value="">Chọn dịch vụ</option>
                        <c:forEach var="s" items="${services}"><option value="${s.id}" ${param.serviceId == s.id ? 'selected' : ''}><c:out value="${s.name}"/> — <fmt:formatNumber value="${s.price}" pattern="#,##0"/> đ</option></c:forEach>
                    </select>
                    <label for="notes" class="form-label">Thông tin tiếp nhận / Ghi chú chuyển ca</label>
                    <textarea id="notes" name="notes" class="form-control mb-2" rows="5" maxlength="2000" placeholder="Nhu cầu thực hiện, thông tin cần lưu ý khi tiếp nhận..."><c:out value="${draftNotes}"/></textarea>
                    <p class="small text-muted">Tối đa 2.000 ký tự. Ghi chú tiếp nhận không thay thế đánh giá chuyên môn của BSPT.</p>
                    <c:if test="${not empty selectedAppointment and not patientContext.examinationReady}"><div class="alert alert-warning">Cần bác sĩ lưu đầy đủ chẩn đoán, kết quả khám và kết luận trước khi chuyển sang BSPT.</div></c:if>
                    <button type="submit" class="btn btn-success" ${not schemaReady or not selectedEligible or not patientContext.examinationReady ? 'disabled' : ''}>Gửi sang BSPT</button>
                </form>
                <c:if test="${not empty existingOrders}">
                    <h3 class="h6 mt-4">Yêu cầu thủ thuật (CD) thuộc lượt khám #APT-${selectedAppointment}</h3>
                    <div class="request-list">
                        <c:forEach var="o" items="${existingOrders}">
                            <div class="border-top py-3">
                                <strong>#CD-${o.orderId} — <c:out value="${o.serviceName}"/></strong>
                                <p class="mb-1">${o.status == 'Cancelled' ? 'Không thực hiện' : (o.status == 'Completed' ? 'Đã hoàn tất' : (empty o.specialistId ? 'Chờ BSPT nhận ca' : 'BSPT đã nhận ca'))}</p>
                                <c:if test="${not empty o.specialistName}"><p class="small mb-1">BSPT: <c:out value="${o.specialistName}"/></p></c:if>
                                <c:if test="${o.status == 'Cancelled'}"><p class="small clinical-text mb-0">Lý do: <c:out value="${o.conclusion}"/></p></c:if>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>
            </section>
            <section class="request-card">
                <h2>Thông tin khám trước đó</h2>
                <c:choose>
                    <c:when test="${empty selectedAppointment}"><p class="text-muted">Chọn lượt khám và bấm xem thông tin.</p></c:when>
                    <c:otherwise>
                        <p class="fw-bold"><c:out value="${patientContext.name}"/> <span class="fw-normal text-muted">#APT-${selectedAppointment}</span></p>
                        <p><c:out value="${patientContext.phone}"/></p>
                        <c:choose>
                            <c:when test="${not empty patientContext.diagnosis or not empty patientContext.findings or not empty patientContext.conclusion}">
                                <p>Bác sĩ khám: <c:out value="${patientContext.doctor}"/></p>
                                <div class="request-list">
                                    <h3 class="h6">Chẩn đoán</h3><p class="clinical-text"><c:out value="${patientContext.diagnosis}" default="Chưa ghi nhận"/></p>
                                    <h3 class="h6">Kết quả khám</h3><p class="clinical-text"><c:out value="${patientContext.findings}" default="Chưa ghi nhận"/></p>
                                    <h3 class="h6">Kết luận</h3><p class="clinical-text"><c:out value="${patientContext.conclusion}" default="Chưa ghi nhận"/></p>
                                </div>
                            </c:when>
                            <c:otherwise><div class="alert alert-light border">Chưa có thông tin khám của bác sĩ cho lượt này. Cần bác sĩ lưu kết quả khám trước khi chuyển sang BSPT.</div></c:otherwise>
                        </c:choose>
                    </c:otherwise>
                </c:choose>
            </section>
        </div>
    </div>
</main>
<script>
document.getElementById('procedureRequestForm').addEventListener('submit', function () {
    const button = this.querySelector('button[type="submit"]'); button.disabled = true; button.textContent = 'Đang gửi...';
});
document.getElementById('appointmentId').addEventListener('change', function () {
    document.querySelector('#procedureRequestForm button[type="submit"]').disabled = true;
});
</script>
</body></html>
