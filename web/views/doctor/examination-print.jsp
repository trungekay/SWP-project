<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Phiếu khám #APPT-<c:out value="${appointment.id}" /> - VisionCare</title>
    <style>
        @page { size: A4; margin: 16mm; }
        * { box-sizing: border-box; }
        body { max-width: 210mm; margin: 0 auto; padding: 24px; color: #172b38; font: 14px/1.5 Arial, sans-serif; }
        .print-actions { display: flex; justify-content: flex-end; gap: 10px; margin-bottom: 24px; }
        .print-actions button, .print-actions a { padding: 9px 15px; border: 1px solid #0b806b; border-radius: 7px; background: #0b806b; color: #fff; font: 600 13px Arial, sans-serif; text-decoration: none; cursor: pointer; }
        .print-actions a { background: #fff; color: #0b806b; }
        .letterhead { display: flex; justify-content: space-between; gap: 16px; border-bottom: 2px solid #087e69; padding-bottom: 13px; }
        .letterhead strong { color: #087e69; font-size: 22px; letter-spacing: 1px; }
        .letterhead span { display: block; font-size: 12px; color: #52636d; }
        .letterhead .code { text-align: right; font-size: 12px; }
        h1 { margin: 20px 0 16px; text-align: center; text-transform: uppercase; font-size: 21px; letter-spacing: .5px; }
        h2 { margin: 19px 0 9px; padding-bottom: 5px; border-bottom: 1px solid #a9cfc5; color: #155c4e; font-size: 14px; text-transform: uppercase; }
        .details { display: grid; grid-template-columns: 1fr 1fr; gap: 5px 24px; }
        .details div { min-width: 0; }
        .label { color: #5c6c74; }
        .value { white-space: pre-wrap; overflow-wrap: anywhere; }
        .block { margin: 8px 0; white-space: pre-wrap; overflow-wrap: anywhere; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #bbcbc8; padding: 7px 9px; text-align: left; vertical-align: top; }
        th { background: #eef7f4; font-weight: 600; }
        .staff-notes { padding: 9px 11px; border-left: 3px solid #73ad9f; background: #f3f8f6; }
        .signature { margin: 35px 0 8px auto; width: 230px; text-align: center; break-inside: avoid; }
        .signature strong { display: block; margin-top: 50px; }
        section { break-inside: avoid; }
        @media print {
            body { max-width: none; margin: 0; padding: 0; color: #000; }
            .print-actions { display: none; }
            h2, .letterhead strong { color: #000; }
            .staff-notes, th { background: #fff; }
        }
    </style>
</head>
<body>
    <div class="print-actions">
        <a href="${pageContext.request.contextPath}/doctor/examination?id=${appointment.id}">Quay lại phiếu khám</a>
        <button type="button" onclick="window.print()">In phiếu khám</button>
    </div>
    <header class="letterhead">
        <div><strong>VISIONCARE</strong><span>Hồ sơ khám chuyên khoa mắt</span></div>
        <div class="code">Mã ca khám: #APPT-<c:out value="${appointment.id}" /><br>
            Ngày khám: <fmt:formatDate value="${appointment.appointmentDate}" pattern="dd/MM/yyyy" /></div>
    </header>
    <h1>Phiếu khám lâm sàng</h1>

    <section>
        <h2>Thông tin ca khám</h2>
        <div class="details">
            <div><span class="label">Bệnh nhân:</span> <strong><c:out value="${appointment.patientName}" /></strong></div>
            <div><span class="label">Mã bệnh nhân:</span> #PT-<c:out value="${appointment.patientId}" /></div>
            <div><span class="label">Ngày sinh:</span> <c:choose><c:when test="${not empty appointment.dob}"><fmt:formatDate value="${appointment.dob}" pattern="dd/MM/yyyy" /></c:when><c:otherwise>—</c:otherwise></c:choose></div>
            <div><span class="label">Số điện thoại:</span> <c:out value="${appointment.phone}" default="—" /></div>
            <div><span class="label">Bác sĩ:</span> <c:out value="${appointment.doctorName}" default="—" /></div>
            <div><span class="label">Giờ / phòng:</span> <c:out value="${appointment.timeSlot}" default="—" /> / <c:out value="${appointment.roomName}" default="—" /></div>
        </div>
    </section>

    <c:if test="${not empty formValues.staffNotes}">
        <section><h2>Ghi chú từ nhân viên tiếp nhận</h2><div class="block staff-notes"><c:out value="${formValues.staffNotes}" /></div></section>
    </c:if>
    <section>
        <h2>Lý do khám và bệnh sử</h2>
        <div class="block"><strong>Triệu chứng chính:</strong> <c:out value="${formValues.chiefComplaint}" default="—" /></div>
        <div class="block"><strong>Tiền sử:</strong> <c:out value="${formValues.medicalHistory}" default="—" /></div>
    </section>
    <section>
        <h2>Thị lực và nhãn áp</h2>
        <table>
            <thead><tr><th>Chỉ số</th><th>Mắt phải (OD)</th><th>Mắt trái (OS)</th></tr></thead>
            <tbody>
                <tr><td>Thị lực không kính</td><td><c:out value="${formValues.odUncorrected}" default="—" /></td><td><c:out value="${formValues.osUncorrected}" default="—" /></td></tr>
                <tr><td>Thị lực có kính</td><td><c:out value="${formValues.odCorrected}" default="—" /></td><td><c:out value="${formValues.osCorrected}" default="—" /></td></tr>
                <tr><td>Nhãn áp (mmHg)</td><td><c:out value="${formValues.odIop}" default="—" /></td><td><c:out value="${formValues.osIop}" default="—" /></td></tr>
            </tbody>
        </table>
    </section>
    <section>
        <h2>Khám thực thể</h2>
        <div class="block"><strong>Bán phần trước:</strong> <c:out value="${formValues.anteriorFindings}" default="—" /></div>
        <div class="block"><strong>Đáy mắt / bán phần sau:</strong> <c:out value="${formValues.posteriorFindings}" default="—" /></div>
    </section>
    <section>
        <h2>Kết quả và kết luận</h2>
        <div class="block"><strong>Kết quả khám:</strong> <c:out value="${formValues.examinationResult}" /></div>
        <div class="block"><strong>Chẩn đoán lâm sàng:</strong> <c:out value="${formValues.clinicalDiagnosis}" /></div>
        <div class="block"><strong>Kết luận / hướng xử trí:</strong> <c:out value="${formValues.conclusion}" /></div>
        <c:if test="${not empty formValues.followUpDate}"><div class="block"><strong>Ngày tái khám:</strong> <c:out value="${formValues.followUpDate}" /></div></c:if>
    </section>
    <c:if test="${not empty formValues.surgeryStatus}">
        <section>
            <h2>Chỉ định thủ thuật / phẫu thuật</h2>
            <div class="block"><strong>Dịch vụ:</strong> <c:out value="${formValues.surgeryServiceName}" /> — <c:out value="${formValues.surgeryStatus}" /></div>
            <div class="block"><strong>Ghi chú chỉ định:</strong> <c:out value="${formValues.surgeryNotes}" default="—" /></div>
            <c:if test="${formValues.surgeryStatus eq 'Completed'}">
                <div class="block"><strong>Kết quả thực hiện:</strong> <c:out value="${formValues.surgeryResult}" default="—" /></div>
                <div class="block"><strong>Kết luận bác sĩ thủ thuật:</strong> <c:out value="${formValues.surgeryConclusion}" default="—" /></div>
            </c:if>
        </section>
    </c:if>
    <div class="signature">Bác sĩ khám bệnh<strong><c:out value="${appointment.doctorName}" default="________________" /></strong></div>
</body>
</html>
