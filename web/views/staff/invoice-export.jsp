<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN" />
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Hóa đơn INV-${invoice.id}</title><link href="${pageContext.request.contextPath}/assets/css/staff-invoices.css?v=20261030-wide" rel="stylesheet"></head><body class="invoice-print-body">
<div class="invoice-print-toolbar"><a href="${pageContext.request.contextPath}/staff/invoices/detail?id=${invoice.id}">← Quay lại hóa đơn</a><button type="button" onclick="window.print()">In / Lưu PDF</button></div>
<jsp:include page="/views/common/invoice-receipt.jsp" /></body></html>
