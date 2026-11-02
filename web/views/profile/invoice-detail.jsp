<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Hóa đơn INV-${invoice.id} - VisionCare</title>
<link href="${pageContext.request.contextPath}/assets/css/staff-invoices.css?v=20261101-receipt" rel="stylesheet"></head>
<body class="invoice-print-body">
<div class="invoice-print-toolbar"><a href="${pageContext.request.contextPath}/views/profile/medical-history.jsp">← Quay lại hồ sơ khám</a><button type="button" onclick="window.print()">In / Lưu PDF</button></div>
<jsp:include page="/views/common/invoice-receipt.jsp" />
</body></html>
