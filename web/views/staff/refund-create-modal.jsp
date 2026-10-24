<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<style>#createRefundModal .btn-teal { background-color: #0d9488; color: white; } #createRefundModal .btn-teal:hover { background-color: #0f766e; }</style>
    <!-- Modal 1: Tạo yêu cầu hoàn tiền (Staff Create Refund Request) -->
    <div class="modal fade" id="createRefundModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content" style="border-radius: 12px; border: none;">
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold" style="color: #0d9488;"><i class="bi bi-plus-circle me-2"></i>Tạo yêu cầu hoàn tiền (Nhân viên)</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form action="${pageContext.request.contextPath}/staff/refunds" method="POST">
                    <input type="hidden" name="action" value="create">
                    <input type="hidden" name="patientId" id="createRefundPatientId" value="">

                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Chọn Hóa đơn / Lịch hẹn <span class="text-danger">*</span></label>
                            <select class="form-select" name="invoiceId" id="createRefundInvoiceSelect" onchange="onInvoiceSelected()" required>
                                <option value="" data-patient-id="" data-amount="250000">-- Chọn hóa đơn cần hoàn tiền --</option>
                                <c:forEach var="inv" items="${availableInvoices}">
                                    <option value="${inv.invoiceId}" data-patient-id="${inv.patientId}" data-amount="${inv.refundableAmount}" data-appointment-id="${inv.appointmentId}">
                                        ${inv.label}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label small fw-bold">Số tiền hoàn (VNĐ) <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" name="amount" id="createRefundAmountInput" placeholder="VD: 250000" min="10000" step="10000" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label small fw-bold">Lý do hoàn tiền <span class="text-danger">*</span></label>
                            <textarea class="form-control" name="reason" rows="3" placeholder="Nhập lý do hoàn tiền cho bệnh nhân..." required></textarea>
                        </div>

                        <div class="mb-3">
                            <label class="form-label small fw-bold">Trạng thái xử lý <span class="text-danger">*</span></label>
                            <select class="form-select" name="initialStatus" required>
                                <option value="Pending" selected>Chờ duyệt (Pending)</option>

                            </select>
                        </div>
                    </div>
                    <div class="modal-footer border-0 pt-0">
                        <button type="button" class="btn btn-light" data-bs-dismiss="modal">Đóng</button>
                        <button type="submit" class="btn btn-teal">Xác nhận tạo yêu cầu</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

<script>
function onInvoiceSelected() {
 const s = document.getElementById('createRefundInvoiceSelect'), o = s.options[s.selectedIndex];
 document.getElementById('createRefundPatientId').value = o.dataset.patientId || '';
 document.getElementById('createRefundAmountInput').value = s.value ? o.dataset.amount : '';
}
document.getElementById('createRefundModal').addEventListener('show.bs.modal', function(e) {
 this.querySelector('form').reset();
 const s = document.getElementById('createRefundInvoiceSelect'); s.value = '';
 for (const o of s.options) { if (o.dataset.appointmentId === e.relatedTarget.dataset.appointmentId) { s.value = o.value; break; } }
 onInvoiceSelected();
});
</script>