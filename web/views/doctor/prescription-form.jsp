<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Phiếu kê đơn - VisionCare</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/vendor/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/vendor/bootstrap-icons/bootstrap-icons.css">
    <jsp:include page="/views/admin/layout/admin-css.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/doctor-forms.css?v=8">
    <script defer charset="UTF-8" src="${pageContext.request.contextPath}/assets/js/doctor-forms.js?v=8"></script>
</head>
<body>
<jsp:include page="/views/employee/layout/employee-sidebar.jsp">
    <jsp:param name="activeNav" value="examination" />
</jsp:include>
<main class="main-wrapper">
    <jsp:include page="/views/employee/layout/employee-header.jsp" />
    <div class="page-content doctor-form-page" data-doctor-form="prescription">
        <nav class="doctor-form-breadcrumb" aria-label="Điều hướng">
            <a href="${pageContext.request.contextPath}/doctor/waiting-list">Hàng đợi khám bệnh</a>
            <i class="bi bi-chevron-right" aria-hidden="true"></i>
            <a href="${pageContext.request.contextPath}/doctor/patient-detail?id=${appointment.id}">Chi tiết bệnh nhân</a>
            <i class="bi bi-chevron-right" aria-hidden="true"></i>
            <span aria-current="page">Phiếu kê đơn</span>
        </nav>

        <header class="doctor-form-heading">
            <div>
                <span class="doctor-form-eyebrow">CA KHÁM #APPT-<c:out value="${appointment.id}" /></span>
                <h1>Phiếu kê đơn</h1>
                <p>Kê thuốc và thông số kính theo kết quả khám của bệnh nhân.</p>
            </div>
            <span class="doctor-form-state"><i class="bi bi-pencil-square" aria-hidden="true"></i> Đang nhập liệu</span>
        </header>

        <section class="doctor-form-patient" aria-label="Thông tin bệnh nhân">
            <div class="doctor-form-avatar" aria-hidden="true"><c:out value="${fn:substring(appointment.patientName, 0, 1)}" default="BN" /></div>
            <div class="doctor-form-patient-main">
                <span>BỆNH NHÂN</span>
                <h2><c:out value="${appointment.patientName}" default="Chưa cập nhật" /></h2>
                <p>Mã BN #PT-<c:out value="${appointment.patientId}" /> <span aria-hidden="true">·</span>
                    <c:choose><c:when test="${not empty appointment.dob}"><fmt:formatDate value="${appointment.dob}" pattern="dd/MM/yyyy" /></c:when><c:otherwise>Chưa có ngày sinh</c:otherwise></c:choose>
                    <span aria-hidden="true">·</span> <c:out value="${appointment.phone}" default="Chưa có SĐT" /></p>
            </div>
            <div class="doctor-form-patient-side">
                <span>CA KHÁM HIỆN TẠI</span>
                <strong><c:out value="${appointment.timeSlot}" default="--:--" /> · <c:out value="${appointment.roomName}" default="Chưa phân phòng" /></strong>
            </div>
        </section>

        <c:if test="${not empty formMessage}"><div class="doctor-form-notice success" role="status"><i class="bi bi-check-circle" aria-hidden="true"></i> <c:out value="${formMessage}" /></div></c:if>
        <c:if test="${not empty formErrors}">
            <div class="doctor-form-notice error" role="alert">
                <strong>Vui lòng kiểm tra lại đơn:</strong>
                <ul><c:forEach var="error" items="${formErrors}"><li><c:out value="${error}" /></li></c:forEach></ul>
            </div>
        </c:if>

        <div class="doctor-form-layout">
            <form id="prescription-form" class="doctor-form-stack" method="post"
                  action="${pageContext.request.contextPath}/doctor/prescription/save?id=${appointment.id}" autocomplete="off">
                <input type="hidden" name="appointmentId" value="<c:out value='${appointment.id}' />">
                <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}' />">
                <section class="doctor-form-card" aria-labelledby="prescription-type-heading">
                    <div class="doctor-form-card-heading">
                        <span class="doctor-form-icon"><i class="bi bi-sliders" aria-hidden="true"></i></span>
                        <div><h2 id="prescription-type-heading">Nội dung kê đơn</h2><p>Chọn loại chỉ định phù hợp với ca khám</p></div>
                    </div>
                    <div class="doctor-form-choice-grid">
                        <label class="doctor-form-choice"><input type="checkbox" name="includeMedication" value="true" ${includeMedication ? 'checked' : ''} data-section-toggle="medication"><span><i class="bi bi-capsule" aria-hidden="true"></i><strong>Thuốc</strong><small>Hoạt chất, liều dùng, số lượng</small></span></label>
                        <label class="doctor-form-choice"><input type="checkbox" name="includeGlasses" value="true" ${includeGlasses ? 'checked' : ''} data-section-toggle="glasses"><span><i class="bi bi-eyeglasses" aria-hidden="true"></i><strong>Kính</strong><small>Độ kính từng mắt và khoảng cách đồng tử</small></span></label>
                    </div>
                </section>

                <section class="doctor-form-card" id="medication-section" aria-labelledby="medication-heading">
                    <div class="doctor-form-card-heading">
                        <span class="doctor-form-icon blue"><i class="bi bi-capsule-pill" aria-hidden="true"></i></span>
                        <div><h2 id="medication-heading">Danh sách thuốc</h2><p>Thêm từng thuốc và hướng dẫn sử dụng</p></div>
                    </div>
                    <div class="doctor-form-medicine-list" data-medicine-list>
                        <c:forEach var="medicine" items="${medicineRows}" varStatus="row">
                            <fieldset class="doctor-form-medicine">
                                <legend>Thuốc <span data-medicine-number><c:out value="${row.count}" /></span></legend>
                                <button type="button" class="doctor-form-remove" data-remove-medicine aria-label="Xóa thuốc"><i class="bi bi-trash3" aria-hidden="true"></i> Xóa</button>
                                <div class="doctor-form-fields">
                                    <div class="doctor-form-field doctor-form-span doctor-form-medicine-name"><label for="medicine-name-${row.index}">Tên thuốc <em>*</em></label>
                                        <div class="doctor-form-combobox" data-medicine-combobox>
                                            <input id="medicine-name-${row.index}" name="medicines[${row.index}].medicineName" data-name="medicineName" type="text" maxlength="255" required autocomplete="off" role="combobox" aria-autocomplete="list" aria-expanded="false" placeholder="Chọn thuốc trong danh mục hoặc nhập tên thuốc mới" value="<c:out value='${medicine.medicineName}' />">
                                            <div class="doctor-form-suggestions" data-medicine-suggestions role="listbox" hidden></div>
                                        </div>
                                        <small class="doctor-form-hint">Có thể nhập thuốc chưa có trong danh mục.</small>
                                    </div>
                                    <label class="doctor-form-field doctor-form-span"><span>Dạng dùng</span><input name="medicines[${row.index}].strength" data-name="strength" type="text" maxlength="100" placeholder="VD: Dung dịch nhỏ mắt" value="<c:out value='${medicine.strength}' />"></label>
                                    <div class="doctor-form-dose-field doctor-form-span">
                                        <span>Liều dùng theo buổi <em>*</em></span>
                                        <div class="doctor-form-dose-grid">
                                            <div class="doctor-form-dose-row" data-dose-row><label><input name="medicines[${row.index}].morning" data-name="morning" data-dose-toggle type="checkbox" value="true" ${medicine.morning eq 'true' ? 'checked' : ''}><span>Sáng</span></label><input name="medicines[${row.index}].morningDose" data-name="morningDose" data-dose-input type="text" maxlength="100" aria-label="Liều dùng buổi sáng" placeholder="VD: 1 viên" value="<c:out value='${medicine.morningDose}' />"></div>
                                            <div class="doctor-form-dose-row" data-dose-row><label><input name="medicines[${row.index}].afternoon" data-name="afternoon" data-dose-toggle type="checkbox" value="true" ${medicine.afternoon eq 'true' ? 'checked' : ''}><span>Chiều</span></label><input name="medicines[${row.index}].afternoonDose" data-name="afternoonDose" data-dose-input type="text" maxlength="100" aria-label="Liều dùng buổi chiều" placeholder="VD: 1 viên" value="<c:out value='${medicine.afternoonDose}' />"></div>
                                            <div class="doctor-form-dose-row" data-dose-row><label><input name="medicines[${row.index}].evening" data-name="evening" data-dose-toggle type="checkbox" value="true" ${medicine.evening eq 'true' ? 'checked' : ''}><span>Tối</span></label><input name="medicines[${row.index}].eveningDose" data-name="eveningDose" data-dose-input type="text" maxlength="100" aria-label="Liều dùng buổi tối" placeholder="VD: 1 viên" value="<c:out value='${medicine.eveningDose}' />"></div>
                                        </div>
                                        <c:if test="${not empty medicine.legacySchedule}"><small class="doctor-form-legacy-dose">Hướng dẫn đơn cũ: <c:out value="${medicine.legacySchedule}" />. Hãy chọn lại buổi dùng và liều tương ứng khi lưu đơn.</small></c:if>
                                    </div>
                                    <label class="doctor-form-field doctor-form-span"><span>Thời gian dùng</span><input name="medicines[${row.index}].duration" data-name="duration" type="text" maxlength="100" value="<c:out value='${medicine.duration}' />"></label>
                                    <div class="doctor-form-quantity-unit doctor-form-span">
                                    <label class="doctor-form-field"><span>Số lượng <em>*</em></span><input name="medicines[${row.index}].quantity" data-name="quantity" type="number" min="1" max="999" step="1" required value="<c:out value='${medicine.quantity}' />"></label>
                                    <label class="doctor-form-field"><span>Đơn vị</span><select name="medicines[${row.index}].unit" data-name="unit">
                                        <option value="chai" ${medicine.unit eq 'chai' or empty medicine.unit ? 'selected' : ''}>Chai</option>
                                        <option value="hộp" ${medicine.unit eq 'hộp' ? 'selected' : ''}>Hộp</option>
                                        <option value="viên" ${medicine.unit eq 'viên' ? 'selected' : ''}>Viên</option>
                                        <option value="tuýp" ${medicine.unit eq 'tuýp' ? 'selected' : ''}>Tuýp</option>
                                        <option value="lọ" ${medicine.unit eq 'lọ' ? 'selected' : ''}>Lọ</option>
                                        <option value="khác" ${medicine.unit eq 'khác' ? 'selected' : ''}>Khác</option>
                                    </select></label>
                                    </div>
                                    <label class="doctor-form-field doctor-form-span"><span>Hướng dẫn thêm</span><input name="medicines[${row.index}].instructions" data-name="instructions" type="text" maxlength="255" value="<c:out value='${medicine.instructions}' />"></label>
                                </div>
                            </fieldset>
                        </c:forEach>
                    </div>
                    <datalist id="doctor-medicine-catalog"><c:forEach var="catalogMedicine" items="${medicineCatalog}"><option value="<c:out value='${catalogMedicine.name}' />"></option></c:forEach></datalist>
                    <button type="button" class="doctor-form-add" data-add-medicine><i class="bi bi-plus-circle" aria-hidden="true"></i> Thêm thuốc</button>
                </section>

                <section class="doctor-form-card" id="glasses-section" aria-labelledby="glasses-heading" hidden>
                    <div class="doctor-form-card-heading">
                        <span class="doctor-form-icon violet"><i class="bi bi-eyeglasses" aria-hidden="true"></i></span>
                        <div><h2 id="glasses-heading">Đơn kính</h2><p>Độ cầu (SPH), độ trụ (CYL), trục (AXIS) và độ cộng (ADD)</p></div>
                    </div>
                    <div class="doctor-form-table-wrap">
                        <table class="doctor-form-matrix doctor-form-glasses-table">
                            <thead><tr><th scope="col">Mắt</th><th scope="col">SPH</th><th scope="col">CYL</th><th scope="col">AXIS</th><th scope="col">ADD</th></tr></thead>
                            <tbody>
                                <tr><th scope="row">Phải (OD)</th><td><input name="odSph" type="number" step="0.25" min="-30" max="30" aria-label="SPH mắt phải" placeholder="0.00" value="<c:out value='${formValues.odSph}' />"></td><td><input name="odCyl" type="number" step="0.25" min="-15" max="15" aria-label="CYL mắt phải" placeholder="0.00" value="<c:out value='${formValues.odCyl}' />"></td><td><input name="odAxis" type="number" step="1" min="0" max="180" aria-label="AXIS mắt phải" placeholder="0–180" value="<c:out value='${formValues.odAxis}' />"></td><td><input name="odAdd" type="number" step="0.25" min="0" max="6" aria-label="ADD mắt phải" placeholder="0.00" value="<c:out value='${formValues.odAdd}' />"></td></tr>
                                <tr><th scope="row">Trái (OS)</th><td><input name="osSph" type="number" step="0.25" min="-30" max="30" aria-label="SPH mắt trái" placeholder="0.00" value="<c:out value='${formValues.osSph}' />"></td><td><input name="osCyl" type="number" step="0.25" min="-15" max="15" aria-label="CYL mắt trái" placeholder="0.00" value="<c:out value='${formValues.osCyl}' />"></td><td><input name="osAxis" type="number" step="1" min="0" max="180" aria-label="AXIS mắt trái" placeholder="0–180" value="<c:out value='${formValues.osAxis}' />"></td><td><input name="osAdd" type="number" step="0.25" min="0" max="6" aria-label="ADD mắt trái" placeholder="0.00" value="<c:out value='${formValues.osAdd}' />"></td></tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="doctor-form-fields doctor-form-glasses-extra">
                        <label class="doctor-form-field"><span>Khoảng cách đồng tử (PD, mm)</span><input name="pd" type="number" min="40" max="80" step="0.5" placeholder="VD: 62" value="<c:out value='${formValues.pd}' />"></label>
                        <label class="doctor-form-field"><span>Loại kính</span><select name="lensType"><option value="">Chọn loại kính</option><option value="distance" ${formValues.lensType eq 'distance' ? 'selected' : ''}>Kính nhìn xa</option><option value="near" ${formValues.lensType eq 'near' ? 'selected' : ''}>Kính đọc gần</option><option value="progressive" ${formValues.lensType eq 'progressive' ? 'selected' : ''}>Kính đa tròng</option><option value="other" ${formValues.lensType eq 'other' ? 'selected' : ''}>Khác</option></select></label>
                        <label class="doctor-form-field doctor-form-span"><span>Ghi chú về kính</span><textarea name="glassesNotes" rows="2" maxlength="1000" placeholder="Chất liệu tròng, lớp phủ, thời gian đeo..."><c:out value="${formValues.glassesNotes}" /></textarea></label>
                    </div>
                </section>

                <section class="doctor-form-card" aria-labelledby="prescription-notes-heading">
                    <div class="doctor-form-card-heading">
                        <span class="doctor-form-icon amber"><i class="bi bi-file-text" aria-hidden="true"></i></span>
                        <div><h2 id="prescription-notes-heading">Dặn dò bệnh nhân</h2><p>Hướng dẫn dùng thuốc, theo dõi và tái khám</p></div>
                    </div>
                    <div class="doctor-form-fields">
                        <label class="doctor-form-field doctor-form-span"><span>Lời dặn của bác sĩ</span><textarea name="doctorNotes" rows="4" maxlength="2000" placeholder="Ví dụ: Nhỏ thuốc đúng giờ; quay lại khi đau, đỏ hoặc nhìn mờ tăng..."><c:out value="${formValues.doctorNotes}" /></textarea></label>
                        <label class="doctor-form-field"><span>Ngày tái khám dự kiến</span><input name="followUpDate" type="date" value="<c:out value='${formValues.followUpDate}' />"></label>
                    </div>
                </section>

                <div class="doctor-form-actions">
                    <a class="doctor-form-button secondary" href="${pageContext.request.contextPath}/doctor/examination?id=${appointment.id}">Về phiếu khám</a>
                    <button class="doctor-form-button primary" type="submit"><i class="bi bi-cloud-arrow-up" aria-hidden="true"></i> Lưu đơn</button>
                </div>
            </form>

            <aside class="doctor-form-aside" aria-label="Các bước trong ca khám">
                <div class="doctor-form-aside-card">
                    <h2>Quy trình khám</h2>
                    <ol class="doctor-form-steps">
                        <li><span>1</span><div><strong>Khám lâm sàng</strong><small>Nhập kết quả và kết luận</small></div></li>
                        <li class="current"><span>2</span><div><strong>Kê đơn</strong><small>Thuốc và kính nếu cần</small></div></li>
                    </ol>
                    <a class="doctor-form-aside-link" href="${pageContext.request.contextPath}/doctor/waiting-list">Về hàng đợi <i class="bi bi-arrow-right" aria-hidden="true"></i></a>
                </div>
                <div class="doctor-form-aside-tip"><i class="bi bi-shield-check" aria-hidden="true"></i><p>Kiểm tra thuốc, liều dùng và thông số OD/OS trước khi chuyển đơn cho bệnh nhân.</p></div>
            </aside>
        </div>
    </div>
</main>
<template id="medicine-row-template">
    <fieldset class="doctor-form-medicine">
        <legend>Thuốc <span data-medicine-number></span></legend>
        <button type="button" class="doctor-form-remove" data-remove-medicine aria-label="Xóa thuốc"><i class="bi bi-trash3" aria-hidden="true"></i> Xóa</button>
        <div class="doctor-form-fields">
            <div class="doctor-form-field doctor-form-span doctor-form-medicine-name"><label>Tên thuốc <em>*</em></label><div class="doctor-form-combobox" data-medicine-combobox><input data-name="medicineName" type="text" maxlength="255" required autocomplete="off" role="combobox" aria-autocomplete="list" aria-expanded="false" placeholder="Chọn thuốc trong danh mục hoặc nhập tên thuốc mới"><div class="doctor-form-suggestions" data-medicine-suggestions role="listbox" hidden></div></div><small class="doctor-form-hint">Có thể nhập thuốc chưa có trong danh mục.</small></div>
            <label class="doctor-form-field doctor-form-span"><span>Dạng dùng</span><input data-name="strength" type="text" maxlength="100" placeholder="VD: Dung dịch nhỏ mắt"></label>
            <div class="doctor-form-dose-field doctor-form-span">
                <span>Liều dùng theo buổi <em>*</em></span>
                <div class="doctor-form-dose-grid">
                    <div class="doctor-form-dose-row" data-dose-row><label><input data-name="morning" data-dose-toggle type="checkbox" value="true"><span>Sáng</span></label><input data-name="morningDose" data-dose-input type="text" maxlength="100" aria-label="Liều dùng buổi sáng" placeholder="VD: 1 viên"></div>
                    <div class="doctor-form-dose-row" data-dose-row><label><input data-name="afternoon" data-dose-toggle type="checkbox" value="true"><span>Chiều</span></label><input data-name="afternoonDose" data-dose-input type="text" maxlength="100" aria-label="Liều dùng buổi chiều" placeholder="VD: 1 viên"></div>
                    <div class="doctor-form-dose-row" data-dose-row><label><input data-name="evening" data-dose-toggle type="checkbox" value="true"><span>Tối</span></label><input data-name="eveningDose" data-dose-input type="text" maxlength="100" aria-label="Liều dùng buổi tối" placeholder="VD: 1 viên"></div>
                </div>
            </div>
            <label class="doctor-form-field doctor-form-span"><span>Thời gian dùng</span><input data-name="duration" type="text" maxlength="100" placeholder="VD: 7 ngày"></label>
            <div class="doctor-form-quantity-unit doctor-form-span"><label class="doctor-form-field"><span>Số lượng <em>*</em></span><input data-name="quantity" type="number" min="1" max="999" step="1" placeholder="VD: 1" required></label><label class="doctor-form-field"><span>Đơn vị</span><select data-name="unit"><option value="chai">Chai</option><option value="hộp">Hộp</option><option value="viên">Viên</option><option value="tuýp">Tuýp</option><option value="lọ">Lọ</option><option value="khác">Khác</option></select></label></div>
            <label class="doctor-form-field doctor-form-span"><span>Hướng dẫn thêm</span><input data-name="instructions" type="text" maxlength="255" placeholder="VD: Nhỏ cách các thuốc khác ít nhất 5 phút"></label>
        </div>
    </fieldset>
</template>
</body>
</html>
