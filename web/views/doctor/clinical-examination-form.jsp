<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Phiếu khám lâm sàng - VisionCare</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/vendor/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/vendor/bootstrap-icons/bootstrap-icons.css">
    <jsp:include page="/views/admin/layout/admin-css.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/doctor-forms.css">
    <script defer src="${pageContext.request.contextPath}/assets/js/doctor-forms.js"></script>
</head>
<body>
<jsp:include page="/views/employee/layout/employee-sidebar.jsp">
    <jsp:param name="activeNav" value="examination" />
</jsp:include>
<main class="main-wrapper">
    <jsp:include page="/views/employee/layout/employee-header.jsp" />
    <div class="page-content doctor-form-page" data-doctor-form="examination">
        <nav class="doctor-form-breadcrumb" aria-label="Điều hướng">
            <a href="${pageContext.request.contextPath}/doctor/waiting-list">Hàng đợi khám bệnh</a>
            <i class="bi bi-chevron-right" aria-hidden="true"></i>
            <a href="${pageContext.request.contextPath}/doctor/patient-detail?id=${appointment.id}">Chi tiết bệnh nhân</a>
            <i class="bi bi-chevron-right" aria-hidden="true"></i>
            <span aria-current="page">Phiếu khám lâm sàng</span>
        </nav>

        <header class="doctor-form-heading">
            <div>
                <span class="doctor-form-eyebrow">CA KHÁM #APPT-<c:out value="${appointment.id}" /></span>
                <h1>Phiếu khám lâm sàng</h1>
                <p>Ghi nhận thị lực, dấu hiệu nhãn khoa và kết luận của ca khám.</p>
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

        <div class="doctor-form-layout">
            <form id="examination-form" class="doctor-form-stack" autocomplete="off">
                <input type="hidden" name="appointmentId" value="<c:out value='${appointment.id}' />">
                <section class="doctor-form-card" aria-labelledby="exam-complaint-heading">
                    <div class="doctor-form-card-heading">
                        <span class="doctor-form-icon"><i class="bi bi-chat-left-text" aria-hidden="true"></i></span>
                        <div><h2 id="exam-complaint-heading">Lý do đến khám</h2><p>Triệu chứng và bệnh sử liên quan</p></div>
                    </div>
                    <div class="doctor-form-fields">
                        <label class="doctor-form-field doctor-form-span"><span>Triệu chứng chính</span>
                            <textarea name="chiefComplaint" rows="3" maxlength="1000" placeholder="Ví dụ: Nhìn mờ mắt phải trong 2 tuần, tăng khi đọc gần..."></textarea>
                        </label>
                        <label class="doctor-form-field doctor-form-span"><span>Tiền sử mắt và bệnh sử liên quan</span>
                            <textarea name="medicalHistory" rows="2" maxlength="1000" placeholder="Bệnh mắt trước đây, bệnh nền, dị ứng, thuốc đang dùng..."></textarea>
                        </label>
                    </div>
                </section>

                <section class="doctor-form-card" aria-labelledby="exam-vision-heading">
                    <div class="doctor-form-card-heading">
                        <span class="doctor-form-icon blue"><i class="bi bi-eye" aria-hidden="true"></i></span>
                        <div><h2 id="exam-vision-heading">Thị lực và nhãn áp</h2><p>Ghi riêng kết quả mắt phải (OD) và mắt trái (OS)</p></div>
                    </div>
                    <div class="doctor-form-table-wrap">
                        <table class="doctor-form-matrix">
                            <thead><tr><th scope="col">Chỉ số</th><th scope="col">Mắt phải (OD)</th><th scope="col">Mắt trái (OS)</th></tr></thead>
                            <tbody>
                                <tr><th scope="row">Thị lực không kính</th><td><input aria-label="Thị lực không kính mắt phải" name="odUncorrected" type="text" maxlength="20" placeholder="VD: 7/10"></td><td><input aria-label="Thị lực không kính mắt trái" name="osUncorrected" type="text" maxlength="20" placeholder="VD: 8/10"></td></tr>
                                <tr><th scope="row">Thị lực có kính</th><td><input aria-label="Thị lực có kính mắt phải" name="odCorrected" type="text" maxlength="20" placeholder="VD: 10/10"></td><td><input aria-label="Thị lực có kính mắt trái" name="osCorrected" type="text" maxlength="20" placeholder="VD: 10/10"></td></tr>
                                <tr><th scope="row">Nhãn áp (mmHg)</th><td><input aria-label="Nhãn áp mắt phải" name="odIop" type="number" min="0" max="80" step="0.1" placeholder="VD: 16"></td><td><input aria-label="Nhãn áp mắt trái" name="osIop" type="number" min="0" max="80" step="0.1" placeholder="VD: 17"></td></tr>
                            </tbody>
                        </table>
                    </div>
                    <p class="doctor-form-hint">Ghi thị lực theo chuẩn đang sử dụng tại phòng khám.</p>
                </section>

                <section class="doctor-form-card" aria-labelledby="exam-findings-heading">
                    <div class="doctor-form-card-heading">
                        <span class="doctor-form-icon amber"><i class="bi bi-clipboard2-pulse" aria-hidden="true"></i></span>
                        <div><h2 id="exam-findings-heading">Khám thực thể</h2><p>Ghi nhận phát hiện qua khám mắt</p></div>
                    </div>
                    <div class="doctor-form-fields">
                        <label class="doctor-form-field"><span>Bán phần trước</span><textarea name="anteriorFindings" rows="4" maxlength="2000" placeholder="Giác mạc, kết mạc, tiền phòng, thể thủy tinh..."></textarea></label>
                        <label class="doctor-form-field"><span>Đáy mắt / bán phần sau</span><textarea name="posteriorFindings" rows="4" maxlength="2000" placeholder="Võng mạc, hoàng điểm, gai thị..."></textarea></label>
                    </div>
                </section>

                <section class="doctor-form-card" aria-labelledby="exam-conclusion-heading">
                    <div class="doctor-form-card-heading">
                        <span class="doctor-form-icon violet"><i class="bi bi-journal-check" aria-hidden="true"></i></span>
                        <div><h2 id="exam-conclusion-heading">Chẩn đoán và kết luận</h2><p>Những thông tin cần thiết để tiếp tục điều trị</p></div>
                    </div>
                    <div class="doctor-form-fields">
                        <label class="doctor-form-field doctor-form-span"><span>Chẩn đoán lâm sàng <em>*</em></span><input name="clinicalDiagnosis" type="text" maxlength="255" required placeholder="Nhập chẩn đoán lâm sàng"></label>
                        <label class="doctor-form-field doctor-form-span"><span>Kết quả khám <em>*</em></span><textarea name="examinationResult" rows="4" maxlength="4000" required placeholder="Tóm tắt các kết quả khám và nhận định chính"></textarea></label>
                        <label class="doctor-form-field doctor-form-span"><span>Kết luận và hướng xử trí <em>*</em></span><textarea name="conclusion" rows="3" maxlength="4000" required placeholder="Kết luận, chỉ định bổ sung hoặc hướng điều trị"></textarea></label>
                        <label class="doctor-form-field"><span>Ngày tái khám dự kiến</span><input name="followUpDate" type="date"></label>
                    </div>
                </section>

                <div class="doctor-form-actions">
                    <a class="doctor-form-button secondary" href="${pageContext.request.contextPath}/doctor/patient-detail?id=${appointment.id}">Quay lại hồ sơ</a>
                    <button class="doctor-form-button secondary" type="button" data-preview-button><i class="bi bi-eye" aria-hidden="true"></i> Xem trước</button>
                    <button class="doctor-form-button primary" type="button" disabled title="Chưa có API lưu kết quả khám"><i class="bi bi-cloud-arrow-up" aria-hidden="true"></i> Lưu phiếu khám</button>
                </div>
                <p class="doctor-form-save-note"><i class="bi bi-info-circle" aria-hidden="true"></i> Giao diện nhập liệu đã sẵn sàng. Chức năng lưu cần kết nối servlet xử lý POST; dữ liệu đang nhập chưa được lưu.</p>
            </form>

            <aside class="doctor-form-aside" aria-label="Các bước trong ca khám">
                <div class="doctor-form-aside-card">
                    <h2>Quy trình khám</h2>
                    <ol class="doctor-form-steps">
                        <li class="current"><span>1</span><div><strong>Khám lâm sàng</strong><small>Nhập kết quả và kết luận</small></div></li>
                        <li><span>2</span><div><strong>Kê đơn</strong><small>Thuốc và kính nếu cần</small></div></li>
                        <li><span>3</span><div><strong>Hoàn tất ca khám</strong><small>Cập nhật trạng thái hàng đợi</small></div></li>
                    </ol>
                    <a class="doctor-form-aside-link" href="${pageContext.request.contextPath}/doctor/prescription?id=${appointment.id}">Sang phiếu kê đơn <i class="bi bi-arrow-right" aria-hidden="true"></i></a>
                </div>
                <div class="doctor-form-aside-tip"><i class="bi bi-shield-check" aria-hidden="true"></i><p>Kiểm tra đúng bệnh nhân và mắt phải/trái trước khi hoàn tất nội dung y khoa.</p></div>
            </aside>
        </div>
    </div>
</main>
<div class="doctor-form-modal" data-preview-modal hidden>
    <div class="doctor-form-modal-backdrop" data-close-preview></div>
    <section class="doctor-form-modal-panel" role="dialog" aria-modal="true" aria-labelledby="preview-title">
        <button type="button" class="doctor-form-modal-close" data-close-preview aria-label="Đóng xem trước"><i class="bi bi-x-lg"></i></button>
        <span class="doctor-form-eyebrow">XEM TRƯỚC · CHƯA LƯU</span>
        <h2 id="preview-title">Phiếu khám lâm sàng</h2>
        <div data-preview-content></div>
    </section>
</div>
</body>
</html>
