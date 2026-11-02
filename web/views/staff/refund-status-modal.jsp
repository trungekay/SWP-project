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
                <dt class="col-5">Lý do</dt><dd class="col-7 text-break" data-refund-field="reason"></dd>
            </dl>
            <p class="small text-muted mb-0">Lịch đã có yêu cầu hoàn tiền. Giám đốc sẽ xét duyệt yêu cầu này; không cần tạo thêm yêu cầu trùng.</p>
        </div>
        <div class="modal-footer"><a class="btn btn-success" id="refundInvoiceLink">Xem / Xác nhận chi trả</a><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button></div>
    </div></div>
</div>
<script>
document.getElementById('existingRefundModal').addEventListener('show.bs.modal', function(event) {
    if (!event.relatedTarget) return;
    const data = event.relatedTarget.dataset;
    document.getElementById("refundInvoiceLink").href="${pageContext.request.contextPath}/staff/invoices/detail?id="+encodeURIComponent(data.invoiceId);
    this.querySelectorAll('[data-refund-field]').forEach(function(field) {
        field.textContent = data[field.dataset.refundField] || '—';
    });
});
</script>
