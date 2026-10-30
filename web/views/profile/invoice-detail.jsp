<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN" />
<jsp:include page="/views/common/header.jsp"><jsp:param name="pageTitle" value="Hóa đơn đã thanh toán" /><jsp:param name="bodyClass" value="screen-wide receipt-wide" /><jsp:param name="fullWidth" value="true" /></jsp:include>
<style>@media print{header,footer,.receipt-actions{display:none!important}.receipt{margin:0!important;width:100%!important}}</style>
<main class="container-fluid screen-fluid py-5 receipt"><div class="d-flex justify-content-between receipt-actions mb-4"><a href="${pageContext.request.contextPath}/views/profile/medical-history.jsp">Quay lại hồ sơ</a><button class="btn btn-outline-success" onclick="window.print()">In hóa đơn</button></div>
<h2>Hóa đơn #INV-<fmt:formatNumber value="${invoice.id}" pattern="00000" /></h2><p>Lịch khám #APT-${invoice.appointmentId} · <c:out value="${invoice.date}" /> · Hoàn thành</p>
<p>Bệnh nhân: <strong><c:out value="${invoice.patientName}" /></strong> · <c:out value="${invoice.phone}" /></p>
<table class="table table-bordered align-middle"><thead><tr><th>STT</th><th>Dịch vụ / Khoản thu</th><th>Số lượng</th><th>Đơn giá</th><th>Thành tiền</th></tr></thead><tbody>
<c:forEach var="item" items="${invoice.items}" varStatus="row"><c:if test="${not item.declined}"><tr><td>${row.count}</td><td><c:out value="${item.name}" /></td><td>${item.quantity}</td><td><fmt:formatNumber value="${item.unitPrice}" /> đ</td><td><fmt:formatNumber value="${item.amount}" /> đ</td></tr><c:if test="${item.refundedAmount > 0}"><tr class="text-success"><td></td><td>Hoàn khoản chưa sử dụng: <c:out value="${item.name}" /></td><td>${item.refundedQuantity}</td><td><fmt:formatNumber value="${item.unitPrice}" /> đ</td><td>-<fmt:formatNumber value="${item.refundedAmount}" /> đ</td></tr></c:if></c:if></c:forEach>
</tbody></table><div class="text-end fs-4 text-success fw-bold">Tổng tiền đã thanh toán: <fmt:formatNumber value="${invoice.netPaid}" /> đ</div></main>
<jsp:include page="/views/common/footer.jsp" />
