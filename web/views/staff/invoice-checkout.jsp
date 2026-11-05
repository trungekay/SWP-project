<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN" />
<!DOCTYPE html><html lang="vi"><head><title>Hóa đơn tổng #${invoice.id} - VisionCare</title><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<jsp:include page="/views/admin/layout/admin-css.jsp" />
<link href="${pageContext.request.contextPath}/assets/css/staff-invoices.css?v=20261105-inline" rel="stylesheet">
</head><body class="invoice-fullscreen"><jsp:include page="/views/employee/layout/employee-sidebar.jsp"><jsp:param name="activeNav" value="invoices" /></jsp:include>
<main class="main-wrapper"><jsp:include page="/views/admin/layout/admin-header.jsp" /><div class="invoice-workspace">

<a class="invoice-back" href="${pageContext.request.contextPath}/staff/invoices/detail?id=${invoice.id}"><i class="bi bi-arrow-left"></i> Quay lại đối chiếu hóa đơn</a>
<div class="invoice-heading"><div><div class="eyebrow">MASTER INVOICE · #APT-${invoice.appointmentId}</div><h2>Thanh toán hóa đơn</h2><p><c:out value="${invoice.patientName}" /> · <c:out value="${invoice.phone}" /> · <c:out value="${invoice.date}" /></p></div><span class="invoice-pill invoice-status-${invoice.progressColor}"><c:out value="${invoice.paymentLabel}" /></span></div>
<ol class="invoice-steps"><li class="active">1. Đối chiếu hóa đơn</li><li class="${checkout ? 'active' : ''}">2. Chọn phương thức &amp; thanh toán</li><li class="${invoice.finalized ? 'active' : ''}">3. Xuất hóa đơn</li></ol>
<c:if test="${invoice.finalized}"><p class="text-muted">Đã chốt: <c:out value="${invoice.finalizedAt}" /> (giờ Việt Nam) · <c:out value="${invoice.cashierName}" /></p></c:if>
<c:if test="${not empty sessionScope.invoiceSuccess}"><div class="alert alert-success"><c:out value="${sessionScope.invoiceSuccess}" /></div><c:remove var="invoiceSuccess" scope="session" /></c:if>
<c:if test="${not empty sessionScope.invoiceError}"><div class="alert alert-danger"><c:out value="${sessionScope.invoiceError}" /></div><c:remove var="invoiceError" scope="session" /></c:if>

<c:if test="${invoice.blocked}"><div class="alert alert-warning"><c:choose><c:when test="${refund.status == 'Approved'}">Yêu cầu hoàn tiền đã được director duyệt, đang chờ đối chiếu / chi trả. Tạm khóa thu thêm trên hóa đơn này.</c:when><c:when test="${refund.status == 'Pending'}">Yêu cầu hoàn tiền đang chờ director duyệt. Tạm khóa thu thêm trên hóa đơn này.</c:when><c:when test="${invoice.invoiceStatus == 'Refunded'}">Hóa đơn đã ghi nhận hoàn tiền. Không thu thêm trên hóa đơn này.</c:when><c:otherwise>Lịch hẹn hoặc hóa đơn đã hủy. Không thu thêm trên hóa đơn này.</c:otherwise></c:choose></div></c:if>
<c:if test="${not invoice.clinicalComplete && not invoice.blocked}"><div class="alert alert-info">Có thể xem trạng thái và khoản thu. Chỉ chốt hóa đơn sau khi bác sĩ kết thúc ca khám.</div></c:if>
<c:if test="${invoice.unpriced && not invoice.finalized}"><div class="alert alert-warning">Có thuốc chưa có giá trong danh mục. Tổng các khoản đã có giá hiện là <strong><fmt:formatNumber value="${invoice.total}" /> đ</strong>; chưa thể xác định tổng cuối cùng, số tiền còn thiếu hoặc thu thừa cho đến khi đối chiếu giá / khoản khách không mua.</div></c:if>
<c:if test="${invoice.unperformed && not invoice.finalized}"><div class="alert alert-warning">Có dịch vụ chưa thực hiện. Chờ hoàn tất, hoặc bỏ dịch vụ nếu bệnh nhân từ chối; không thu tiền như dịch vụ đã thực hiện.</div></c:if>
<c:if test="${invoice.overpaid > 0 && not invoice.unpriced}"><div class="alert alert-warning">Khoản đã ghi nhận thu vượt tổng hiện tại <fmt:formatNumber value="${invoice.overpaid}" /> đ. Cần đối chiếu và xử lý hoàn tiền trước khi chốt.</div></c:if>
<div class="invoice-detail-stack"><section class="invoice-card"><div class="invoice-section-title"><h5>Hóa đơn sau đối chiếu</h5><span>#INV-<fmt:formatNumber value="${invoice.id}" pattern="00000" groupingUsed="false" /></span></div>
<div class="table-responsive"><table class="table invoice-table"><thead><tr><th>Khoản thu</th><th class="text-end">SL</th><th class="text-end">Đơn giá</th><th class="text-end">Thành tiền</th></tr></thead><tbody>
<c:forEach var="item" items="${invoice.items}"><c:if test="${not item.declined}"><tr><td><strong><c:out value="${item.name}" /></strong><div class="small text-muted"><c:out value="${item.type}" /></div></td><td class="text-end">${item.quantity}</td><td class="text-end text-nowrap"><fmt:formatNumber value="${item.unitPrice}" /> đ</td><td class="text-end text-nowrap"><fmt:formatNumber value="${item.amount}" /> đ</td></tr></c:if></c:forEach>
</tbody><tfoot class="invoice-inline-totals">
<tr><th colspan="3" class="text-end">Tổng tiền sản phẩm, dịch vụ</th><td class="text-end text-nowrap"><strong><fmt:formatNumber value="${invoice.total}" /> đ</strong></td></tr>
<tr><th colspan="3" class="text-end">Đã thanh toán</th><td class="text-end text-nowrap"><fmt:formatNumber value="${invoice.paid}" /> đ</td></tr>
<c:if test="${invoice.refundedAmount > 0}"><tr><th colspan="3" class="text-end">Đã hoàn tiền</th><td class="text-end text-nowrap"><fmt:formatNumber value="${invoice.refundedAmount}" /> đ</td></tr></c:if>
<tr class="invoice-inline-due"><th colspan="3" class="text-end">Còn lại cần thanh toán</th><td class="text-end text-nowrap"><strong><fmt:formatNumber value="${invoice.outstanding}" /> đ</strong></td></tr>
</tfoot></table></div><div class="invoice-payment-actions" id="invoice-summary">
<c:choose><c:when test="${invoice.finalized && not invoice.blocked}"><div class="alert alert-success mt-3 mb-0"><i class="bi bi-check-circle-fill me-1"></i>Hoàn thành · Đã thanh toán đủ</div><a class="btn btn-teal w-100 mt-3" href="${pageContext.request.contextPath}/staff/invoices/export?id=${invoice.id}"><i class="bi bi-printer me-1"></i>Xem trước &amp; Xuất hóa đơn</a></c:when>
<c:when test="${not empty invoice.activePayment}"><div class="invoice-qr" id="invoiceQr" data-payload="${fn:escapeXml(invoice.activePayment.qr)}"></div><p class="small text-center">Đang chờ thanh toán QR: <strong><fmt:formatNumber value="${invoice.activePayment.amount}" /> đ</strong></p>
<div id="qrMonitor" data-endpoint="${pageContext.request.contextPath}/staff/invoices/checkout" data-invoice-id="${invoice.id}"
     data-order-code="${invoice.activePayment.orderCode}" data-csrf-token="${sessionScope.invoiceCsrf}">
    <div id="qrState" class="small text-muted mt-2" role="status" aria-live="polite">Đang tự động theo dõi giao dịch. Khi thanh toán thành công, hóa đơn sẽ chuyển sang Hoàn thành.</div>
</div>
<c:if test="${invoice.activePayment.status == 'Creating'}"><form method="post" action="${pageContext.request.contextPath}/staff/invoices/checkout" class="mt-2"><input type="hidden" name="csrfToken" value="${sessionScope.invoiceCsrf}"><input type="hidden" name="invoiceId" value="${invoice.id}"><input type="hidden" name="fingerprint" value="${fingerprint}"><button name="action" value="createQr" class="btn btn-outline-teal w-100">Thử tạo lại cùng mã thanh toán</button></form></c:if>
</c:when><c:when test="${invoice.canCheckout && checkout}">
<form method="post" action="${pageContext.request.contextPath}/staff/invoices/checkout" id="paymentMethodForm" class="mt-3"><input type="hidden" name="csrfToken" value="${sessionScope.invoiceCsrf}"><input type="hidden" name="invoiceId" value="${invoice.id}"><input type="hidden" name="fingerprint" value="${fingerprint}">
<c:choose><c:when test="${invoice.due > 0}"><label for="paymentChoice" class="form-label fw-semibold">Phương thức thanh toán</label><select id="paymentChoice" class="form-select" name="action"><option value="cash">Tiền mặt tại quầy</option><option value="createQr">Chuyển khoản QR / PayOS</option></select></c:when><c:otherwise><input type="hidden" name="action" value="cash"></c:otherwise></c:choose>
<label class="small my-3 d-flex gap-2" id="cashConfirm"><input type="checkbox" name="cashReceived" value="yes" required><span>${invoice.due > 0 ? 'Tôi xác nhận đã nhận đủ số tiền mặt cần thanh toán.' : 'Tôi đã đối chiếu các khoản thu; hóa đơn đã được thanh toán đủ.'}</span></label>
<button class="btn btn-teal w-100" id="payButton" type="submit">${invoice.due > 0 ? 'Xác nhận đã nhận tiền mặt' : 'Chốt hóa đơn đã thanh toán'}</button></form>
</c:when><c:when test="${invoice.canCheckout}"><a class="btn btn-teal w-100 mt-3" href="${pageContext.request.contextPath}/staff/invoices/checkout?id=${invoice.id}">Tiếp tục thanh toán <i class="bi bi-arrow-right"></i></a></c:when></c:choose>
<c:if test="${invoice.priorPaid > 0}"><div class="alert alert-info mt-4 mb-0">Có <strong><fmt:formatNumber value="${invoice.priorPaid}" /> đ</strong> đã được ghi nhận thanh toán trên hóa đơn cũ nhưng chưa có giao dịch chi tiết. Khoản này đã được trừ khỏi số tiền cần thu, không thu lại.</div></c:if>
</div></section></div>
</div></main><script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script><script src="https://cdn.jsdelivr.net/npm/qrcodejs@1.0.0/qrcode.min.js"></script><script src="${pageContext.request.contextPath}/assets/js/staff-invoices.js?v=20261025-3"></script></body></html>
