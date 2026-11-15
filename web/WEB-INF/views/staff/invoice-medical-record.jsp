<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN" />
<c:if test="${not empty procedureError}"><div class="alert alert-danger"><c:out value="${procedureError}" /></div></c:if>
<c:if test="${not empty procedureMessage}"><div class="alert alert-success"><c:out value="${procedureMessage}" /></div></c:if>
<div class="mb-3">
    <h3 class="h5"><c:out value="${record.patientName}" /> · #APT-${record.appointmentId}</h3>
    <div class="text-muted"><c:out value="${record.formattedId}" /> · Bác sĩ khám: <c:out value="${record.doctorName}" /></div>
</div>
<dl class="mb-3">
    <c:if test="${not empty record.chiefComplaint}"><dt>Lý do khám</dt><dd><c:out value="${record.chiefComplaint}" /></dd></c:if>
    <dt>Chẩn đoán lâm sàng</dt><dd><c:out value="${record.clinicalDiagnosis}" /></dd>
    <dt>Kết quả khám</dt><dd><c:out value="${record.examinationResult}" /></dd>
    <dt>Kết luận</dt><dd><c:out value="${record.conclusion}" /></dd>
    <c:if test="${not empty record.followUpDate}"><dt>Ngày tái khám</dt><dd><c:out value="${record.followUpDate}" /></dd></c:if>
</dl>
<c:if test="${not empty record.medicalHistory || not empty record.anteriorFindings || not empty record.posteriorFindings || not empty record.odUncorrected || not empty record.osUncorrected || not empty record.odCorrected || not empty record.osCorrected || not empty record.odIop || not empty record.osIop}">
    <details class="mb-3">
        <summary class="fw-semibold">Thông số và ghi nhận khám</summary>
        <dl class="mt-2 mb-0">
            <c:if test="${not empty record.medicalHistory}"><dt>Tiền sử</dt><dd><c:out value="${record.medicalHistory}" /></dd></c:if>
            <c:if test="${not empty record.odUncorrected || not empty record.osUncorrected}"><dt>Thị lực không kính</dt><dd>OD <c:out value="${record.odUncorrected}" default="—" /> · OS <c:out value="${record.osUncorrected}" default="—" /></dd></c:if>
            <c:if test="${not empty record.odCorrected || not empty record.osCorrected}"><dt>Thị lực có kính</dt><dd>OD <c:out value="${record.odCorrected}" default="—" /> · OS <c:out value="${record.osCorrected}" default="—" /></dd></c:if>
            <c:if test="${not empty record.odIop || not empty record.osIop}"><dt>Nhãn áp</dt><dd>OD <c:out value="${record.odIop}" default="—" /> · OS <c:out value="${record.osIop}" default="—" /></dd></c:if>
            <c:if test="${not empty record.anteriorFindings}"><dt>Bán phần trước</dt><dd><c:out value="${record.anteriorFindings}" /></dd></c:if>
            <c:if test="${not empty record.posteriorFindings}"><dt>Đáy mắt / bán phần sau</dt><dd><c:out value="${record.posteriorFindings}" /></dd></c:if>
        </dl>
    </details>
</c:if>
<c:if test="${not empty record.medicines}">
    <h3 class="h6">Thuốc kê đơn</h3>
    <ul><c:forEach var="medicine" items="${record.medicines}"><li><c:out value="${medicine.medicineName}" /> · SL <c:out value="${medicine.quantity}" /> · <c:out value="${medicine.dosageInstruction}" /></li></c:forEach></ul>
</c:if>
<c:if test="${not empty record.surgeryIndication || not empty referrals}">
    <hr><h3 class="h6">Chỉ định phẫu thuật / thủ thuật</h3>
    <c:if test="${not empty record.surgeryIndication}"><p><c:out value="${record.surgeryIndication}" /></p></c:if>
    <c:if test="${empty referrals}"><p class="text-muted">Bác sĩ đã lưu ghi chú chỉ định. Cần có dịch vụ cụ thể trên phiếu khám để thu phí.</p></c:if>
</c:if>
<c:forEach var="referral" items="${referrals}">
    <section class="border rounded p-3 mb-3">
        <strong><c:out value="${referral.service}" /></strong>
        <div>Giá thủ thuật: <fmt:formatNumber value="${referral.price}" /> đ</div>
        <c:if test="${not empty referral.notes && referral.notes != record.surgeryIndication}"><div>Ghi chú: <c:out value="${referral.notes}" /></div></c:if>
        <c:if test="${not empty referral.specialist}"><div>Bác sĩ thực hiện: <c:out value="${referral.specialist}" /></div></c:if>
        <c:choose>
            <c:when test="${referral.status == 'Cancelled'}"><span class="text-muted">Chỉ định đã hủy</span></c:when>
            <c:when test="${referral.paymentStatus == 'Paid'}"><span class="text-success">Đã thanh toán chi phí thủ thuật</span></c:when>
            <c:when test="${canCollectProcedure && referral.paymentStatus == 'Pending' && referral.status == 'Pending'}">
                <c:set var="itsQr" value="${not empty activePayment && activePayment.procedureOrderId == referral.orderId}" />
                <c:choose>
                    <c:when test="${itsQr && activePayment.status == 'Pending'}">
                        <div class="mt-3" data-procedure-poll data-order="${activePayment.orderCode}"
                             data-csrf="<c:out value='${sessionScope.invoiceCsrf}' />">
                            <div data-procedure-qr data-payload="<c:out value='${activePayment.qr}' />"></div>
                            <p class="mb-0 mt-2" data-poll-message>Đang chờ xác nhận chuyển khoản <strong><fmt:formatNumber value="${activePayment.amount}" /> đ</strong>.</p>
                        </div>
                    </c:when>
                    <c:when test="${empty activePayment || itsQr}">
                        <details class="mt-3" ${itsQr || not empty procedureError ? 'open' : ''}>
                            <summary class="btn btn-sm btn-outline-teal">Thanh toán chi phí thủ thuật</summary>
                            <form class="mt-3" data-procedure-form>
                                <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.invoiceCsrf}' />">
                                <input type="hidden" name="appointmentId" value="${record.appointmentId}">
                                <input type="hidden" name="procedureOrderId" value="${referral.orderId}">
                                <input type="hidden" name="amount" value="${referral.amount}">
                                <div class="mb-3">Cần thanh toán: <strong><fmt:formatNumber value="${referral.amount}" /> đ</strong></div>
                                <c:choose>
                                    <c:when test="${itsQr}">
                                        <input type="hidden" name="specialistId" value="${activePayment.specialistId}">
                                        <input type="hidden" name="action" value="procedureQr">
                                        <button type="submit" class="btn btn-teal">Thử tạo lại QR</button>
                                        <div class="mt-2" data-procedure-poll data-order="${activePayment.orderCode}"
                                             data-csrf="<c:out value='${sessionScope.invoiceCsrf}' />">
                                            <p class="text-muted mb-0">Đang kiểm tra yêu cầu QR đã tạo.</p>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <label class="form-label d-block">Bác sĩ thực hiện
                                            <select class="form-select" name="specialistId" required>
                                                <option value="">Chọn bác sĩ phẫu thuật</option>
                                                <c:forEach var="specialist" items="${specialists}">
                                                    <c:if test="${empty referral.specialistId || specialist.id == referral.specialistId}">
                                                        <option value="${specialist.id}" ${specialist.id == referral.specialistId ? 'selected' : ''}>
                                                            <c:out value="${specialist.name}" /><c:if test="${not empty specialist.specialty}"> · <c:out value="${specialist.specialty}" /></c:if>
                                                        </option>
                                                    </c:if>
                                                </c:forEach>
                                            </select>
                                        </label>
                                        <label class="form-label d-block">Phương thức thanh toán
                                            <select class="form-select" name="action">
                                                <option value="procedureCash">${referral.amount > 0 ? 'Tiền mặt tại quầy' : 'Xác nhận khoản đã được khấu trừ'}</option>
                                                <c:if test="${referral.amount > 0}"><option value="procedureQr">Chuyển khoản QR / PayOS</option></c:if>
                                            </select>
                                        </label>
                                        <label class="form-check mb-3" data-cash-confirmation>
                                            <input type="checkbox" class="form-check-input" name="cashReceived" value="yes" required>
                                            <span class="form-check-label">${referral.amount > 0 ? 'Đã đối chiếu và nhận đủ tiền mặt.' : 'Đã đối chiếu khoản khấu trừ.'}</span>
                                        </label>
                                        <button type="submit" class="btn btn-teal">Thanh toán</button>
                                    </c:otherwise>
                                </c:choose>
                            </form>
                        </details>
                    </c:when>
                    <c:otherwise><p class="text-muted mb-0">Hóa đơn đang có giao dịch QR khác chờ xác nhận.</p></c:otherwise>
                </c:choose>
            </c:when>
        </c:choose>
    </section>
</c:forEach>
