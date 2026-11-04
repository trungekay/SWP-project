<%@page contentType="text/html" pageEncoding="UTF-8"%>
<div class="modal fade" id="existingRefundModal" tabindex="-1" aria-labelledby="existingRefundTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered"><div class="modal-content">
        <div class="modal-header"><h5 class="modal-title" id="existingRefundTitle">Yêu cầu hoàn tiền hiện có</h5><button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button></div>
        <div class="modal-body">
            <dl class="row mb-0">
                <dt class="col-5">Mã yêu cầu</dt><dd class="col-7" data-refund-field="refundCode"></dd>
                <dt class="col-5">Hóa đơn</dt><dd class="col-7" data-refund-field="invoiceCode"></dd>
                <dt class="col-5">Trạng thái</dt><dd class="col-7" data-refund-field="status"></dd>
                <dt class="col-5">Số tiền hoàn</dt><dd class="col-7" data-refund-field="amount"></dd>
                <dt class="col-5">Lý do yêu cầu</dt><dd class="col-7 text-break" data-refund-field="reason"></dd>
                <dt class="col-5 d-none" id="refundDecisionLabel">Ghi chú chấp thuận</dt>
                <dd class="col-7 text-break d-none" id="refundDecisionNote" style="white-space: pre-wrap;"></dd>
            </dl>
            <p class="small text-muted mb-0" id="refundConfirmationNotice">Lịch đã có phiếu yêu cầu hoàn tiền; không thể gửi thêm yêu cầu.</p>
        </div>
        <div class="modal-footer"><form id="refundCompleteForm" action="${pageContext.request.contextPath}/staff/refunds/complete" method="post" enctype="multipart/form-data" class="m-0 d-none">
            <input type="hidden" name="csrfToken" value="${sessionScope.workflowCsrf}">
            <input type="hidden" name="refundId" id="modalCompleteRefundId">
            <input type="hidden" name="invoiceId" id="modalCompleteInvoiceId">
            <input type="hidden" name="refundSent" value="yes">
            <input type="hidden" name="returnTo" value="appointments">
            <button type="submit" class="btn btn-success" id="refundCompleteButton">Xác nhận</button>
        </form><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button></div>
    </div></div>
</div>
<script>
document.getElementById('existingRefundModal').addEventListener('show.bs.modal', function(event) {
    if (!event.relatedTarget) return;
    const data = event.relatedTarget.dataset;
    const approved = data.refundStatus === 'Approved';
    const rejected = data.refundStatus === 'Rejected';
    const decided = approved || rejected || data.refundStatus === 'Completed';
    const decisionLabel = document.getElementById('refundDecisionLabel');
    const decisionNote = document.getElementById('refundDecisionNote');
    decisionLabel.classList.toggle('d-none', !decided);
    decisionNote.classList.toggle('d-none', !decided);
    decisionLabel.textContent = rejected ? 'Lý do từ chối' : 'Ghi chú chấp thuận';
    decisionNote.textContent = (data.decisionNote || '').trim()
        || (rejected ? 'Chưa có lý do từ chối.' : 'Không có ghi chú chấp thuận.');
    const form = document.getElementById('refundCompleteForm');
    form.classList.toggle('d-none', !approved);
    document.getElementById('modalCompleteRefundId').value = data.refundId || '';
    document.getElementById('modalCompleteInvoiceId').value = data.invoiceId || '';
    document.getElementById('refundCompleteButton').disabled = !approved;
    document.getElementById('refundConfirmationNotice').textContent = approved
        ? 'Chỉ bấm Xác nhận sau khi đã chi trả tiền cho bệnh nhân. Yêu cầu sẽ chuyển sang Hoàn thành và hóa đơn chuyển sang Đã hoàn tiền.'
        : 'Lịch đã có phiếu yêu cầu hoàn tiền; không thể gửi thêm yêu cầu.';
    this.querySelectorAll('[data-refund-field]').forEach(function(field) {
        field.textContent = data[field.dataset.refundField] || '—';
    });
});
document.getElementById('refundCompleteForm').addEventListener('submit', function() {
    document.getElementById('refundCompleteButton').disabled = true;
});
</script>
