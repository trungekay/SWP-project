<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<c:if test="${not empty refund}">
<section class="invoice-card p-4 mb-4" id="refund-settlement"><h5>Yêu cầu hoàn tiền #REF-${refund.id}</h5>
<p><strong><c:choose><c:when test="${refund.status == 'Approved'}">Đã duyệt · Chờ staff hoàn tiền</c:when><c:when test="${refund.status == 'Rejected'}">Đã từ chối</c:when><c:when test="${refund.status == 'Completed'}">Đã hoàn tiền</c:when><c:otherwise>Chờ director duyệt</c:otherwise></c:choose></strong> · <fmt:formatNumber value="${refund.amount}" /> đ</p>
<c:if test="${not empty refund.approvedBy}"><p>Người duyệt / quyết định: <strong><c:out value="${refund.approvedBy}" /></strong><c:if test="${not empty refund.decisionAt}"> · <fmt:formatDate value="${refund.decisionAt}" pattern="dd/MM/yyyy HH:mm" /></c:if></p></c:if>
<c:if test="${refund.kind == 'Items'}"><p class="small">Hoàn các khoản phát sinh chưa sử dụng, giữ nguyên trạng thái ca khám và phí khám. Không giao thuốc / thực hiện thủ thuật đang được yêu cầu hoàn.</p><ul><c:forEach var="line" items="${refund.lines}"><li><c:out value="${line.name}" /> · SL ${line.quantity} · <fmt:formatNumber value="${line.amount}" /> đ</li></c:forEach></ul></c:if>
<p>Lý do yêu cầu: <c:out value="${refund.reason}" /></p>
<c:if test="${not empty refund.decision}"><p>Ý kiến director: <c:out value="${refund.decision}" /></p></c:if>
<c:if test="${refund.status == 'Approved' && refund.canComplete && (sessionScope.user.roleId == 5 || sessionScope.user.roleId == 1)}">
<p>Thực hiện chi trả bên ngoài trong vòng 1 tuần, sau đó xác nhận tại đây. Chỉ xác nhận khi đã hoàn tiền thực tế.</p>
<form method="post" enctype="multipart/form-data" action="${pageContext.request.contextPath}/staff/refunds/complete">
<input type="hidden" name="refundId" value="${refund.id}"><input type="hidden" name="invoiceId" value="${invoice.id}"><input type="hidden" name="csrfToken" value="${sessionScope.workflowCsrf}">
<label for="refundNote" class="form-label">Mã giao dịch / ghi chú chi trả</label><textarea class="form-control mb-3" id="refundNote" name="completionNote" maxlength="1000" rows="2"></textarea>
<label for="refundEvidence" class="form-label">Ảnh giao dịch (không bắt buộc, PNG/JPEG, tối đa 5 MB)</label><input class="form-control mb-3" type="file" id="refundEvidence" name="evidence" accept="image/png,image/jpeg">
<label class="d-flex gap-2 mb-3"><input type="checkbox" name="refundSent" value="yes" required> Tôi xác nhận đã thực sự hoàn tiền bên ngoài cho bệnh nhân.</label>
<button class="btn btn-success">Xác nhận đã hoàn tiền</button></form></c:if>
<c:if test="${refund.status == 'Approved' && not refund.canComplete}"><p class="text-warning"><c:out value="${refund.payoutBlockedReason}" /> Yêu cầu đã được duyệt trước đây nhưng chưa ghi nhận chi trả; cần đối chiếu hồ sơ trước khi xác nhận đã hoàn tiền.</p></c:if>
<c:if test="${refund.status == 'Completed'}"><p>Người xác nhận: <c:out value="${refund.completedBy}" /> · <c:out value="${refund.completedAt}" /></p><p><c:out value="${refund.note}" /></p></c:if>
<c:if test="${refund.hasEvidence}"><a class="btn btn-outline-secondary" target="_blank" rel="noopener" href="${pageContext.request.contextPath}/staff/refunds/evidence?id=${refund.id}">Xem ảnh giao dịch</a></c:if>
</section></c:if>
