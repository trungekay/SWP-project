<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Include Header --%>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Hồ sơ khám bệnh" />
    <jsp:param name="pageDescription" value="Chi tiết hồ sơ bệnh án ngoại trú VisionCare Clinic" />
    <jsp:param name="bodyClass" value="starter-page-page" />
    <jsp:param name="activeNav" value="" />
</jsp:include>

<style>
    .medical-card {
        background: #ffffff;
        border-radius: 14px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.06);
        padding: 35px;
        margin-top: 15px;
        margin-bottom: 40px;
        border: 1px solid #e2e8f0;
    }
    .text-teal {
        color: #0d9488 !important;
    }
    .bg-teal {
        background-color: #0d9488 !important;
    }
    .section-title-sm {
        font-size: 13px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        color: #0d9488;
        margin-bottom: 12px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .info-box {
        background-color: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 10px;
        padding: 18px;
        height: 100%;
    }
    .custom-record-table {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        overflow: hidden;
    }
    .custom-record-table th {
        background-color: #f8fafc;
        color: #475569;
        font-size: 13px;
        font-weight: 600;
        padding: 12px 16px;
        border-bottom: 1px solid #e2e8f0;
    }
    .custom-record-table td {
        padding: 12px 16px;
        font-size: 14px;
        color: #1e293b;
        border-bottom: 1px solid #f1f5f9;
        vertical-align: middle;
    }
    .custom-record-table tr:last-child td {
        border-bottom: none;
    }
    .custom-record-table tbody tr:hover {
        background-color: #fafbfc;
    }
    .badge-soft-success {
        background-color: #dcfce7;
        color: #166534;
        font-size: 12px;
        font-weight: 500;
        padding: 4px 10px;
        border-radius: 20px;
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }
    .badge-soft-info {
        background-color: #e0f2fe;
        color: #0369a1;
        font-size: 12px;
        font-weight: 500;
        padding: 4px 10px;
        border-radius: 20px;
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }

    @media print {
        body * {
            visibility: hidden;
        }
        #printableRecord, #printableRecord * {
            visibility: visible;
        }
        #printableRecord {
            position: absolute;
            left: 0;
            top: 0;
            width: 100%;
            margin: 0;
            padding: 20px;
            background: #ffffff;
            box-shadow: none !important;
            border: none !important;
            border-radius: 0 !important;
        }
        .header, .footer, .breadcrumbs, .page-title, .btn, .action-bar-top {
            display: none !important;
        }
        .print-break-inside {
            break-inside: avoid;
        }
    }
</style>

<main class="main bg-light pb-5">

    <div class="page-title">
        <div class="heading">
            <div class="container">
                <div class="row d-flex justify-content-center text-center">
                    <div class="col-lg-8">
                        <h1>Chi tiết hồ sơ khám</h1>
                        <p class="mb-0">Hồ sơ bệnh án và kết quả khám mắt ngoại trú VisionCare Clinic</p>
                    </div>
                </div>
            </div>
        </div>
        <nav class="breadcrumbs">
            <div class="container">
                <ol>
                    <li><a href="${pageContext.request.contextPath}/home">Trang chủ</a></li>
                    <li><a href="${pageContext.request.contextPath}/views/profile/medical-history.jsp">Lịch sử khám bệnh</a></li>
                    <li class="current">Hồ sơ khám</li>
                </ol>
            </div>
        </nav>
    </div>

    <section class="section pt-4">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-9">

                    <!-- Action Bar Top -->
                    <div class="d-flex justify-content-end mb-3 gap-2 action-bar-top">
                        <button type="button" class="btn btn-outline-secondary" onclick="window.print()">
                            <i class="bi bi-printer me-2"></i>In phiếu khám & đơn thuốc
                        </button>
                        <button type="button" class="btn text-white bg-teal" onclick="if(window.history.length > 1){window.history.back();}else{location.href='${pageContext.request.contextPath}/views/profile/medical-history.jsp';}">
                            <i class="bi bi-arrow-left me-2"></i>Quay lại
                        </button>
                    </div>

                    <!-- Printable Medical Record Document -->
                    <div class="medical-card" id="printableRecord">

                        <!-- Document Header -->
                        <div class="d-flex justify-content-between align-items-center flex-wrap pb-3 mb-4 border-bottom">
                            <div>
                                <h4 class="fw-bold mb-1" style="color: #0d9488;">
                                    <i class="bi bi-eye me-2"></i>VisionCare Clinic
                                </h4>
                                <p class="text-muted small mb-0">Phòng khám chuyên khoa Mắt kỹ thuật cao</p>
                                <p class="text-muted small mb-0">Địa chỉ: 456 Lê Thị Riêng, Quận 10, TP.HCM | Hotline: 1800 599 988</p>
                            </div>
                            <div class="text-end mt-2 mt-md-0">
                                <h5 class="fw-bold mb-1 text-dark">PHIẾU KẾT QUẢ KHÁM BỆNH</h5>
                                <div class="fw-semibold text-dark fs-6">
                                    Mã hồ sơ: <span class="text-teal">${record.formattedId}</span>
                                </div>
                                <div class="small text-muted">
                                    <i class="bi bi-clock me-1"></i>Ngày khám: ${record.createdDate}
                                </div>
                                <div class="mt-2">
                                    <span class="badge-soft-success">
                                        <i class="bi bi-check-circle-fill"></i> Hoàn thành khám
                                    </span>
                                </div>
                            </div>
                        </div>

                        <!-- Info Cards (Patient & Doctor) -->
                        <div class="row g-3 mb-4">
                            <!-- Cột 1: Thông tin Bệnh nhân -->
                            <div class="col-md-6">
                                <div class="info-box">
                                    <div class="section-title-sm">
                                        <i class="bi bi-person-badge"></i> Thông tin bệnh nhân
                                    </div>
                                    <div class="mb-2">
                                        <span class="text-muted small">Họ và tên:</span>
                                        <div class="fw-bold text-dark fs-6">${record.patientName}</div>
                                    </div>
                                    <div class="row g-2 mb-2">
                                        <div class="col-6">
                                            <span class="text-muted small">Mã bệnh nhân:</span>
                                            <div class="fw-semibold text-dark">${record.formattedPatientId}</div>
                                        </div>
                                        <div class="col-6">
                                            <span class="text-muted small">Ngày sinh:</span>
                                            <div class="fw-semibold text-dark">${record.patientDob}</div>
                                        </div>
                                    </div>
                                    <div class="mb-1 small">
                                        <span class="text-muted"><i class="bi bi-telephone me-1"></i>SĐT:</span>
                                        <strong class="text-dark">${record.patientPhone}</strong>
                                    </div>
                                    <div class="small text-muted">
                                        <i class="bi bi-geo-alt me-1"></i>Địa chỉ: ${record.patientAddress}
                                    </div>
                                </div>
                            </div>

                            <!-- Cột 2: Thông tin Bác sĩ & Buổi khám -->
                            <div class="col-md-6">
                                <div class="info-box">
                                    <div class="section-title-sm">
                                        <i class="bi bi-hospital"></i> Bác sĩ & Buổi khám
                                    </div>
                                    <div class="mb-2">
                                        <span class="text-muted small">Bác sĩ phụ trách:</span>
                                        <div class="fw-bold text-dark fs-6">${record.doctorName}</div>
                                        <small class="text-teal">${record.doctorSpecialty}</small>
                                    </div>
                                    <div class="row g-2 mb-2">
                                        <div class="col-6">
                                            <span class="text-muted small">Phòng khám:</span>
                                            <div class="fw-semibold text-dark">${record.roomName}</div>
                                        </div>
                                        <div class="col-6">
                                            <span class="text-muted small">Mã lịch hẹn:</span>
                                            <div class="fw-semibold text-dark">${record.formattedApptId}</div>
                                        </div>
                                    </div>
                                    <div class="small mb-1">
                                        <span class="text-muted">Hóa đơn liên quan:</span>
                                        <c:choose>
                                            <c:when test="${not empty record.invoiceId}">
                                                <a href="${pageContext.request.contextPath}/profile/invoice-detail?id=${record.invoiceId}" class="text-teal text-decoration-none fw-semibold">
                                                    ${record.formattedInvoiceId} (${record.invoiceAmountFmt})
                                                </a>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">Chưa phát sinh hóa đơn</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Section 1: Kết quả khám lâm sàng & Chẩn đoán -->
                        <div class="mb-4">
                            <div class="section-title-sm">
                                <i class="bi bi-journal-check"></i> Kết quả khám & Chẩn đoán lâm sàng
                            </div>
                            <div class="p-3 bg-light rounded-3 border">
                                <div class="mb-3">
                                    <span class="text-muted small fw-medium">Chẩn đoán của Bác sĩ:</span>
                                    <div class="fw-bold text-dark fs-6 mt-1 p-2 rounded bg-white border border-light-subtle">
                                        <i class="bi bi-activity text-teal me-2"></i>${record.clinicalDiagnosis}
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <span class="text-muted small fw-medium">Kết quả kiểm tra mắt & thị lực:</span>
                                    <div class="text-dark small mt-1 p-2 rounded bg-white border border-light-subtle" style="line-height: 1.6;">
                                        ${record.examinationResult}
                                    </div>
                                </div>
                                <div class="mb-0">
                                    <span class="text-muted small fw-medium">Kết luận chuyên môn & Hướng xử trí:</span>
                                    <div class="text-dark small mt-1 p-2 rounded bg-white border border-light-subtle" style="line-height: 1.6;">
                                        ${record.conclusion}
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Section 2: Thủ thuật & Dịch vụ cận lâm sàng -->
                        <c:if test="${not empty record.procedures}">
                            <div class="mb-4">
                                <div class="section-title-sm">
                                    <i class="bi bi-gear-wide-connected"></i> Chỉ định dịch vụ / Cận lâm sàng
                                </div>
                                <div class="table-responsive">
                                    <table class="custom-record-table">
                                        <thead>
                                            <tr>
                                                <th class="text-center" style="width: 8%;">STT</th>
                                                <th>Tên dịch vụ cận lâm sàng</th>
                                                <th>Bác sĩ / KTV thực hiện</th>
                                                <th class="text-end" style="width: 20%;">Chi phí</th>
                                                <th class="text-center" style="width: 18%;">Trạng thái</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="proc" items="${record.procedures}">
                                                <tr>
                                                    <td class="text-center">${proc.stt}</td>
                                                    <td class="fw-semibold text-dark">${proc.serviceName}</td>
                                                    <td><i class="bi bi-person me-1 text-muted"></i>${proc.specialistName}</td>
                                                    <td class="text-end text-muted">${proc.priceFmt}</td>
                                                    <td class="text-center">
                                                        <span class="badge-soft-success">
                                                            <i class="bi bi-check2"></i> ${proc.status == 'Completed' ? 'Đã thực hiện' : proc.status}
                                                        </span>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </c:if>

                        <!-- Section 3: Đơn thuốc điều trị -->
                        <div class="mb-4 print-break-inside">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <div class="section-title-sm mb-0">
                                    <i class="bi bi-capsule"></i> Đơn thuốc điều trị
                                </div>
                                <c:if test="${record.prescriptionId != 'N/A'}">
                                    <span class="small text-muted">Mã đơn: <strong>${record.prescriptionId}</strong></span>
                                </c:if>
                            </div>

                            <c:choose>
                                <c:when test="${not empty record.medicines}">
                                    <div class="table-responsive mb-3">
                                        <table class="custom-record-table">
                                            <thead>
                                                <tr>
                                                    <th class="text-center" style="width: 8%;">STT</th>
                                                    <th style="width: 35%;">Tên thuốc / Quy cách</th>
                                                    <th class="text-center" style="width: 12%;">Số lượng</th>
                                                    <th>Liều dùng & Hướng dẫn sử dụng</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="med" items="${record.medicines}">
                                                    <tr>
                                                        <td class="text-center">${med.stt}</td>
                                                        <td>
                                                            <div class="fw-bold text-dark">${med.medicineName}</div>
                                                        </td>
                                                        <td class="text-center fw-semibold">${med.quantity}</td>
                                                        <td class="text-dark small">${med.dosageInstruction}</td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="p-3 bg-light rounded-3 text-muted text-center small mb-3 border">
                                        Bác sĩ không kê đơn thuốc uống/nhỏ trong buổi khám này.
                                    </div>
                                </c:otherwise>
                            </c:choose>

                            <!-- Lời dặn Bác sĩ -->
                            <div class="p-3 rounded-3" style="background-color: #f0fdfa; border: 1px solid #ccfbf1;">
                                <div class="d-flex align-items-center text-teal fw-bold mb-1">
                                    <i class="bi bi-chat-heart me-2"></i>Lời dặn của Bác sĩ & Hướng dẫn tái khám:
                                </div>
                                <div class="text-dark small" style="line-height: 1.6;">
                                    ${record.doctorNotes}
                                </div>
                            </div>
                        </div>

                        <!-- Chữ ký xác nhận (Bác sĩ & Bệnh nhân) -->
                        <div class="pt-4 mt-3 print-break-inside border-top">
                            <div class="text-end text-muted small fst-italic mb-3 pe-md-4">
                                TP. Hồ Chí Minh, ngày khám ${record.createdDate}
                            </div>
                            <div class="row g-4 justify-content-between">
                                <div class="col-6 text-center">
                                    <div class="fw-semibold text-dark">Bệnh nhân</div>
                                    <div class="text-muted" style="font-size: 12px;">(Ký và ghi rõ họ tên)</div>
                                    <div style="height: 75px;"></div>
                                    <div class="fw-bold text-dark">${record.patientName}</div>
                                </div>
                                <div class="col-6 text-center">
                                    <div class="fw-semibold text-dark">Bác sĩ điều trị</div>
                                    <div class="text-muted" style="font-size: 12px;">(Ký và ghi rõ họ tên)</div>
                                    <div style="height: 75px;"></div>
                                    <div class="fw-bold text-dark">${record.doctorName}</div>
                                </div>
                            </div>
                        </div>

                        <!-- Lưu ý cuối phiếu -->
                        <div class="text-center mt-4 pt-2 border-top">
                            <p class="fw-semibold mb-1 text-muted small">Cảm ơn quý khách đã tin tưởng thăm khám tại VisionCare Clinic!</p>
                            <p class="text-muted small mb-0" style="font-size: 0.8rem;">
                                Vui lòng mang theo phiếu kết quả khám này khi đến tái khám hoặc kiểm tra mắt định kỳ.
                            </p>
                        </div>

                    </div>

                </div>
            </div>
        </div>
    </section>

</main>

<%-- Include Footer --%>
<jsp:include page="/views/common/footer.jsp" />
