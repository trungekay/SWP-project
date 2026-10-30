<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<c:if test="${invoice.paid > 0 && (sessionScope.user.roleId == 5 || sessionScope.user.roleId == 1)}">
<section class="invoice-card p-4 mb-4" id="item-refund-create"><h5>Hoàn thuốc / thủ thuật chưa sử dụng</h5>
<p class="small text-muted">Áp dụng cả khi bệnh nhân đã check-in hoặc khám xong. Chỉ chọn khoản đã thanh toán: thuốc chưa giao, thủ thuật chưa thực hiện. Phí khám và khoản đã sử dụng không được hoàn trong phần này.</p>
<c:choose><c:when test="${not empty refundItems}"><details><summary class="btn btn-outline-teal">Tạo yêu cầu hoàn khoản phát sinh</summary>
<form method="post" action="${pageContext.request.contextPath}/staff/refunds/items" class="mt-3">
<input type="hidden" name="invoiceId" value="${invoice.id}"><input type="hidden" name="csrfToken" value="${sessionScope.workflowCsrf}">
<div class="table-responsive"><table class="table"><thead><tr><th>Chọn</th><th>Khoản đã thanh toán</th><th>Số lượng hoàn</th><th>Đơn giá đã thu</th></tr></thead><tbody>
<c:forEach var="line" items="${refundItems}" varStatus="row"><tr><td><input type="checkbox" name="itemKey" value="${line.key}" id="refund-item-${row.index}" aria-label="Chọn khoản hoàn ${row.count}"></td><td><label for="refund-item-${row.index}"><c:out value="${line.name}" /></label><div class="small text-muted">${line.type == 'Medicine' ? 'Thuốc / vật tư chưa giao' : 'Thủ thuật chưa thực hiện'}</div></td><td><input class="form-control" style="max-width:100px" type="number" name="quantity:${line.key}" value="${line.quantity}" min="1" max="${line.quantity}" step="1" aria-label="Số lượng hoàn khoản ${row.count}"><span class="small text-muted">Còn được hoàn tối đa ${line.quantity}</span></td><td><fmt:formatNumber value="${line.unitPrice}" /> đ</td></tr></c:forEach>
</tbody></table></div>
<label for="item-refund-reason" class="form-label">Lý do bệnh nhân không sử dụng</label><textarea id="item-refund-reason" name="reason" class="form-control mb-3" required maxlength="1000" rows="2"></textarea>
<label class="d-flex gap-2 mb-3"><input type="checkbox" name="unusedConfirmed" value="yes" required><span>Tôi đã đối chiếu tiền thu và xác nhận thuốc đã chọn chưa giao / thủ thuật đã chọn chưa thực hiện.</span></label>
<p class="small text-muted">Hệ thống tính tiền theo số lượng và giá đã thu. Chỉ định thủ thuật chưa thực hiện đã chọn sẽ được hủy khỏi hàng đợi; việc hủy được giữ nguyên nếu yêu cầu hoàn tiền bị từ chối. Director duyệt trước, staff xác nhận chi trả sau.</p>
<button class="btn btn-teal">Gửi director duyệt hoàn tiền</button>
</form></details></c:when><c:otherwise><c:choose><c:when test="${refund.status == 'Pending' || refund.status == 'Approved'}"><p class="small mb-0">Đang có yêu cầu #REF-${refund.id} chờ duyệt / đối chiếu chi trả ở trên. Cần giải quyết yêu cầu đó trước khi lập yêu cầu mới theo khoản.</p></c:when><c:otherwise><p class="small mb-0">Chưa có khoản đủ điều kiện: thuốc cần có dòng hóa đơn đã chốt và thanh toán đủ; thủ thuật cần có tiền thu rõ ràng và chưa có kết quả thực hiện. Khoản đã hoàn hết hoặc chưa có giá không được chọn.</p></c:otherwise></c:choose></c:otherwise></c:choose></section></c:if>
