<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Thanh toán phẫu thuật - VisionCare</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/vendor/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/vendor/bootstrap-icons/bootstrap-icons.css">
    <jsp:include page="/views/admin/layout/admin-css.jsp" />
</head>
<body style="background:#f1f5f9">
<jsp:include page="/views/employee/layout/employee-sidebar.jsp">
    <jsp:param name="activeNav" value="procedure-payments" />
</jsp:include>
<main class="main-wrapper">
    <jsp:include page="/views/employee/layout/employee-header.jsp" />
    <div class="page-content p-4">
        <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-4">
            <div>
                <h1 class="h3 fw-bold mb-1">Yêu cầu thanh toán phẫu thuật</h1>
                <p class="text-secondary mb-0">Xác nhận đã nhận tiền để chuyển chỉ định của bác sĩ đến specialist.</p>
            </div>
            <span class="badge bg-warning text-dark fs-6"><c:out value="${pendingCount}" /> chờ thanh toán</span>
        </div>
        <c:if test="${not empty sessionScope.procedurePaymentMessage}">
            <div class="alert alert-info" role="status"><c:out value="${sessionScope.procedurePaymentMessage}" /></div>
            <c:remove var="procedurePaymentMessage" scope="session" />
        </c:if>
        <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                    <tr><th>Mã chỉ định</th><th>Bệnh nhân</th><th>Dịch vụ</th><th>Giá phẫu thuật</th><th>Đã trừ tiền khám</th><th>Cần thu</th><th>Trạng thái</th><th>Thao tác</th></tr>
                    </thead>
                    <tbody>
                    <c:forEach var="item" items="${requests}">
                        <tr>
                            <td><strong>#CD-<c:out value="${item.orderId}" /></strong><div class="small text-secondary">#APPT-<c:out value="${item.appointmentId}" /></div></td>
                            <td><c:out value="${item.patientName}" /></td>
                            <td><c:out value="${item.serviceName}" /></td>
                            <td><fmt:formatNumber value="${item.price}" type="number" maxFractionDigits="0" /> đ</td>
                            <td class="text-success">−<fmt:formatNumber value="${item.creditAmount}" type="number" maxFractionDigits="0" /> đ</td>
                            <td class="fw-semibold"><fmt:formatNumber value="${item.amount}" type="number" maxFractionDigits="0" /> đ</td>
                            <td>
                                <c:choose>
                                    <c:when test="${item.status eq 'Paid'}">
                                        <span class="badge bg-success">Đã thanh toán</span>
                                        <div class="small text-secondary mt-1"><c:out value="${item.confirmedBy}" /> · <c:out value="${item.paymentMethod}" /></div>
                                    </c:when>
                                    <c:otherwise><span class="badge bg-warning text-dark">Chờ thanh toán</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:if test="${item.status eq 'Pending'}">
                                    <form action="${pageContext.request.contextPath}/staff/procedure-payments" method="post"
                                          class="d-flex flex-wrap gap-2 align-items-center"
                                          onsubmit="return confirm('Xác nhận đã nhận đủ tiền cho ca #CD-${item.orderId}?');">
                                        <input type="hidden" name="orderId" value="<c:out value='${item.orderId}' />">
                                        <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}' />">
                                        <select name="paymentMethod" class="form-select form-select-sm" style="width:auto" aria-label="Phương thức thanh toán">
                                            <option value="Cash_At_Counter">Tiền mặt</option>
                                            <option value="Bank_Transfer">Chuyển khoản</option>
                                        </select>
                                        <button type="submit" class="btn btn-success btn-sm">${item.amount == 0 ? 'Xác nhận đã khấu trừ' : 'Xác nhận đã thu'}</button>
                                    </form>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty requests}">
                        <tr><td colspan="8" class="text-center text-secondary py-5">Chưa có yêu cầu thanh toán phẫu thuật.</td></tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>
        <p class="text-secondary small mt-3">Chỉ xác nhận sau khi bệnh nhân đã thanh toán. Việc xác nhận sẽ ghi giao dịch vào hóa đơn và mở ca cho specialist.</p>
    </div>
</main>
</body>
</html>
