<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN" />
<!DOCTYPE html><html lang="vi"><head><title>Quản lý hóa đơn &amp; thanh toán - VisionCare</title><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<jsp:include page="/views/admin/layout/admin-css.jsp" />
<link href="${pageContext.request.contextPath}/assets/css/staff-invoices.css?v=20261025-5" rel="stylesheet">
</head><body><jsp:include page="/views/employee/layout/employee-sidebar.jsp"><jsp:param name="activeNav" value="invoices" /></jsp:include>
<main class="main-wrapper"><jsp:include page="/views/admin/layout/admin-header.jsp" /><div class="invoice-workspace">

<div class="invoice-heading"><div><div class="eyebrow">THU NGÂN &amp; THANH TOÁN</div><h2>Quản lý hóa đơn &amp; thanh toán</h2><p>Tìm lịch hẹn, đối chiếu khoản thu và thanh toán cho bệnh nhân.</p></div><span class="invoice-count"><c:out value="${rows.size()}" /> lịch hẹn</span></div>
<form class="invoice-card invoice-search" method="get" action="${pageContext.request.contextPath}/staff/invoices">
<div><label for="invoiceSearch">Lịch hẹn / Hóa đơn / Bệnh nhân</label><input id="invoiceSearch" class="form-control" name="search" value="${fn:escapeXml(param.search)}" placeholder="APT-30, INV-00029, tên hoặc số điện thoại"></div>
<div><label for="invoiceDate">Ngày khám</label><input id="invoiceDate" class="form-control" type="date" name="date" value="${fn:escapeXml(param.date)}"></div>
<div><label for="invoiceStatus">Trạng thái ghi nhận</label><select id="invoiceStatus" class="form-select" name="status">
<option value="all">Tất cả</option>
<option value="Unpaid" ${param.status == 'Unpaid' ? 'selected' : ''}>Chưa thanh toán</option>
<option value="Partial_Paid" ${param.status == 'Partial_Paid' ? 'selected' : ''}>Thanh toán một phần</option>
<option value="Examined" ${param.status == 'Examined' ? 'selected' : ''}>Khám xong</option>
<option value="Completed" ${param.status == 'Completed' ? 'selected' : ''}>Hoàn thành</option>
<option value="Canceled" ${param.status == 'Canceled' ? 'selected' : ''}>Đã hủy</option>
<option value="Refunded" ${param.status == 'Refunded' ? 'selected' : ''}>Đã hoàn tiền</option>
<option value="NoInvoice" ${param.status == 'NoInvoice' ? 'selected' : ''}>Chưa có hóa đơn</option></select></div>
<button class="btn btn-teal" type="submit"><i class="bi bi-search me-1"></i>Tra cứu</button><a class="btn btn-light border" href="${pageContext.request.contextPath}/staff/invoices">Đặt lại</a>
</form>
<p class="small text-muted mb-3">Thanh toán phí khám → Thanh toán một phần. Bác sĩ kết thúc khám → Khám xong. Staff đối chiếu, chốt hóa đơn và xác nhận thanh toán đủ → Hoàn thành. Không mua thêm vẫn giữ Khám xong cho đến khi staff chốt hóa đơn.</p>
<div class="invoice-card table-responsive"><table class="table invoice-table"><thead><tr><th>Mã lịch hẹn</th><th>Bệnh nhân</th><th>Ngày khám</th><th>Hóa đơn tổng</th><th>Trạng thái ghi nhận</th><th class="text-end">Thao tác</th></tr></thead><tbody>
<c:forEach var="row" items="${rows}"><tr><td><span class="invoice-code">#APT-${row.appointmentId}</span></td><td><strong><c:out value="${row.patient}" /></strong><div class="small text-muted"><c:out value="${row.phone}" /></div></td><td><c:out value="${row.date}" /></td><td><c:choose><c:when test="${row.invoiceId > 0}">#INV-<fmt:formatNumber value="${row.invoiceId}" pattern="00000" groupingUsed="false" /></c:when><c:otherwise>Chưa có hóa đơn</c:otherwise></c:choose></td>
<td><span class="invoice-pill invoice-status-${row.progressColor}"><c:out value="${row.progressLabel}" /></span></td>
<td class="text-end"><div class="invoice-actions"><c:if test="${row.invoiceId > 0}"><a class="btn btn-sm btn-outline-teal" href="${pageContext.request.contextPath}/staff/invoices/detail?id=${row.invoiceId}"><i class="bi bi-receipt me-1"></i>Xem hóa đơn</a>
<c:if test="${row.canOpenCheckout}"><a class="btn btn-sm btn-teal" href="${pageContext.request.contextPath}/staff/invoices/checkout?id=${row.invoiceId}"><i class="bi bi-credit-card me-1"></i>Thanh toán / Chốt hóa đơn</a></c:if>
<c:if test="${row.progress == 'Completed'}"><a class="btn btn-sm btn-outline-teal" href="${pageContext.request.contextPath}/staff/invoices/export?id=${row.invoiceId}"><i class="bi bi-printer me-1"></i>Xuất hóa đơn</a></c:if>
</c:if></div></td></tr></c:forEach>
<c:if test="${empty rows}"><tr><td colspan="6" class="text-center text-muted py-5"><i class="bi bi-search fs-2 d-block mb-2"></i>Không tìm thấy lịch hẹn phù hợp.</td></tr></c:if>
</tbody></table></div></div></main><script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script></body></html>