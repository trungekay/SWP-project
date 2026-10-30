<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN" />
<td rowspan="${empty invoice.items ? 1 : fn:length(invoice.items)}" class="invoice-payment-cell">
<c:forEach var="tx" items="${invoice.transactions}"><div class="invoice-payment-entry"><strong class="d-block"><fmt:formatDate value="${tx.date}" pattern="dd/MM/yyyy HH:mm:ss" /></strong><span class="small text-muted">#TX-${tx.id}</span></div></c:forEach>
<c:if test="${empty invoice.transactions}"><span class="text-muted">Chưa có thời gian giao dịch chi tiết.</span></c:if>
</td>
<td rowspan="${empty invoice.items ? 1 : fn:length(invoice.items)}" class="invoice-payment-cell">
<c:forEach var="tx" items="${invoice.transactions}"><div class="invoice-payment-entry"><strong class="d-block"><c:choose><c:when test="${tx.method == 'Cash'}">Tiền mặt</c:when><c:when test="${tx.method == 'QR_Banking'}">Chuyển khoản QR</c:when><c:otherwise><c:out value="${tx.method}" /></c:otherwise></c:choose></strong><span class="d-block small"><fmt:formatNumber value="${tx.amount}" /> đ · <c:choose><c:when test="${tx.status == 'Success'}">Thành công</c:when><c:otherwise><c:out value="${tx.status}" /></c:otherwise></c:choose></span><span class="small text-muted">#TX-${tx.id}</span></div></c:forEach>
<c:if test="${empty invoice.transactions}"><span class="text-muted">Chưa có phương thức giao dịch chi tiết.</span></c:if>
</td>
