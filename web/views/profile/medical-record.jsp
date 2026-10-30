<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%-- Include Common Header --%>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Hồ sơ khám bệnh" />
    <jsp:param name="pageDescription" value="Chi tiết hồ sơ bệnh án ngoại trú VisionCare Clinic" />
    <jsp:param name="bodyClass" value="starter-page-page screen-wide patient-wide" />
    <jsp:param name="fullWidth" value="true" />
        <jsp:param name="activeNav" value="" />
</jsp:include>

<!-- Link to Doctor Unified Detail & Forms Stylesheets -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/doctor-patient-detail.css?v=6">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/doctor-forms.css?v=8">

<style>
    .patient-medical-record-wrapper {
        max-width: 1320px;
        margin: 0 auto;
        padding: 10px 15px 50px;
    }
    .text-teal {
        color: #008b74 !important;
    }
    .bg-teal {
        background-color: #008b74 !important;
    }
    .border-teal-subtle {
        border-color: #cbece4 !important;
    }
    
    /* Result Display Boxes inside Clinical Detail */
    .clinical-result-box {
        background: #f8fcfa;
        border: 1px solid #e2f0eb;
        border-radius: 12px;
        padding: 16px 20px;
        margin-bottom: 16px;
        transition: border-color .2s;
    }
    .clinical-result-box:hover {
        border-color: #b9e3d7;
    }
    .clinical-result-label {
        display: flex;
        align-items: center;
        gap: 8px;
        color: #008b74;
        font-size: 11px;
        font-weight: 800;
        text-transform: uppercase;
        letter-spacing: 0.8px;
        margin-bottom: 7px;
    }
    .clinical-result-content {
        color: #172b3a;
        font-size: 14px;
        line-height: 1.6;
    }
    
    /* Matrix Display Values */
    .matrix-display-value {
        font-size: 13.5px;
        font-weight: 600;
        color: #17353a;
        padding: 6px 0;
    }

    /* Print Styles */
    @media print {
        body * {
            visibility: hidden;
        }
        #printableArea, #printableArea * {
            visibility: visible;
        }
        #printableArea {
            position: absolute;
            left: 0;
            top: 0;
            width: 100%;
            margin: 0;
            padding: 15px;
            background: #ffffff;
        }
        .header, .footer, .breadcrumbs, .page-title, .doctor-detail-breadcrumb, .doctor-detail-heading, .action-bar-top {
            display: none !important;
        }
        .doctor-detail-hero {
            box-shadow: none !important;
            border: 1px solid #ccc !important;
            break-inside: avoid;
        }
        .doctor-detail-card {
            box-shadow: none !important;
            border: 1px solid #ccc !important;
            break-inside: avoid;
            margin-bottom: 16px;
        }
        .print-signature-section {
            break-inside: avoid;
        }
    }
</style>

<main class="main bg-light pb-5">

    <!-- Page Title & Breadcrumbs -->
    <div class="page-title">
        <div class="heading">
            <div class="container-fluid screen-fluid">
                <div class="row d-flex justify-content-center text-center">
                    <div class="col-lg-8">
                        <h1>Chi tiết hồ sơ khám</h1>
                        <p class="mb-0">Hồ sơ bệnh án ngoại trú và kết quả điều trị tại VisionCare Clinic</p>
                    </div>
                </div>
            </div>
        </div>
        <nav class="breadcrumbs">
            <div class="container-fluid screen-fluid">
                <ol>
                    <li><a href="${pageContext.request.contextPath}/home">Trang chủ</a></li>
                    <li><a href="${pageContext.request.contextPath}/views/profile/medical-history.jsp">Lịch sử khám bệnh</a></li>
                    <li class="current">Hồ sơ ${record.formattedId}</li>
                </ol>
            </div>
        </nav>
    </div>

    <section class="section pt-3">
        <div class="container-fluid screen-fluid">
            <div class="patient-medical-record-wrapper">

                <!-- Breadcrumb navigation (Doctor style) -->
                <nav class="doctor-detail-breadcrumb" aria-label="Điều hướng">
                    <a href="${pageContext.request.contextPath}/views/profile/medical-history.jsp">
                        <i class="bi bi-arrow-left" aria-hidden="true"></i> Lịch sử khám bệnh
                    </a>
                    <i class="bi bi-chevron-right" aria-hidden="true"></i>
                    <span aria-current="page">Hồ sơ khám ${record.formattedId}</span>
                </nav>

                <!-- Page Header with Action Buttons -->
                <header class="doctor-detail-heading">
                    <div>
                        <span class="doctor-detail-eyebrow">HỒ SƠ KHÁM BỆNH</span>
                        <h1>Chi tiết bệnh nhân &amp; Kết quả khám</h1>
                        <p>Xem thông tin người bệnh, ca hẹn, kết quả khám lâm sàng và các chỉ định điều trị.</p>
                    </div>
                    <div class="doctor-detail-desktop-actions">
                        <button type="button" class="doctor-detail-button doctor-detail-button-secondary" onclick="window.print()">
                            <i class="bi bi-printer" aria-hidden="true"></i> In phiếu khám &amp; đơn thuốc
                        </button>
                        <a class="doctor-detail-button doctor-detail-button-primary" href="${pageContext.request.contextPath}/views/profile/medical-history.jsp">
                            <i class="bi bi-arrow-left" aria-hidden="true"></i> Về lịch sử khám
                        </a>
                    </div>
                </header>

                <!-- Printable Area -->
                <div id="printableArea">

                    <!-- ======================================================== -->
                    <!-- 1. HERO BANNER BỆNH NHÂN (100% Chuẩn Doctor Screen)      -->
                    <!-- ======================================================== -->
                    <section class="doctor-detail-hero" aria-labelledby="patient-name">
                        <div class="doctor-detail-hero-main">
                            <div class="doctor-detail-avatar" aria-hidden="true">
                                <c:choose>
                                    <c:when test="${not empty record.patientName}">
                                        <c:out value="${fn:substring(record.patientName, 0, 1)}" />
                                    </c:when>
                                    <c:otherwise>BN</c:otherwise>
                                </c:choose>
                            </div>
                            <div class="doctor-detail-hero-copy">
                                <div class="doctor-detail-hero-label">BỆNH NHÂN</div>
                                <h2 id="patient-name"><c:out value="${record.patientName}" default="Chưa có tên" /></h2>
                                <div class="doctor-detail-hero-identifiers">
                                    <span>Mã BN <strong><c:out value="${record.formattedPatientId}" /></strong></span>
                                    <span>Mã lịch hẹn <strong><c:out value="${record.formattedApptId}" /></strong></span>
                                    <span>Mã hồ sơ <strong class="text-teal"><c:out value="${record.formattedId}" /></strong></span>
                                </div>
                            </div>
                        </div>
                        <div class="doctor-detail-status-wrap">
                            <c:choose>
                                <c:when test="${record.appointmentStatus eq 'Completed'}">
                                    <span class="doctor-detail-status completed">
                                        <i class="bi bi-check-circle" aria-hidden="true"></i> Hoàn tất
                                    </span>
                                </c:when>
                                <c:when test="${record.appointmentStatus eq 'In_Progress'}">
                                    <span class="doctor-detail-status examining">
                                        <i class="bi bi-activity" aria-hidden="true"></i> Đang khám
                                    </span>
                                </c:when>
                                <c:when test="${record.appointmentStatus eq 'Confirmed'}">
                                    <span class="doctor-detail-status waiting">
                                        <i class="bi bi-hourglass-split" aria-hidden="true"></i> Chờ khám
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="doctor-detail-status neutral">
                                        <c:out value="${record.appointmentStatus}" default="Hoàn tất" />
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="doctor-detail-hero-facts">
                            <span>
                                <i class="bi bi-calendar3" aria-hidden="true"></i>
                                <strong>Ngày khám:</strong> <c:out value="${record.appointmentDateFmt}" default="${record.createdDate}" />
                            </span>
                            <span>
                                <i class="bi bi-clock" aria-hidden="true"></i>
                                <strong>Giờ hẹn:</strong> <c:out value="${record.timeSlot}" default="--:--" />
                            </span>
                            <span>
                                <i class="bi bi-geo-alt" aria-hidden="true"></i>
                                <strong>Phòng khám:</strong> <c:out value="${record.roomName}" />
                            </span>
                            <span>
                                <i class="bi bi-person-badge" aria-hidden="true"></i>
                                <strong>Bác sĩ:</strong> <c:out value="${record.doctorName}" />
                            </span>
                        </div>
                    </section>

                    <!-- ======================================================== -->
                    <!-- 2. GRID 2 CỘT: THÔNG TIN BỆNH NHÂN & CA KHÁM HIỆN TẠI   -->
                    <!-- ======================================================== -->
                    <div class="doctor-detail-grid">
                        <!-- Card Cột 1: Thông tin bệnh nhân -->
                        <section class="doctor-detail-card" aria-labelledby="patient-info-heading">
                            <div class="doctor-detail-card-heading">
                                <span class="doctor-detail-card-icon teal"><i class="bi bi-person-vcard" aria-hidden="true"></i></span>
                                <div>
                                    <h2 id="patient-info-heading">Thông tin bệnh nhân</h2>
                                    <p>Thông tin liên hệ và nhận diện</p>
                                </div>
                            </div>
                            <dl class="doctor-detail-fields">
                                <div>
                                    <dt>Họ và tên</dt>
                                    <dd><c:out value="${record.patientName}" default="Chưa cập nhật" /></dd>
                                </div>
                                <div>
                                    <dt>Ngày sinh</dt>
                                    <dd><c:out value="${record.patientDob}" default="Chưa cập nhật" /></dd>
                                </div>
                                <div>
                                    <dt>Số điện thoại</dt>
                                    <dd><c:out value="${record.patientPhone}" default="Chưa cập nhật" /></dd>
                                </div>
                                <div>
                                    <dt>Mã bệnh nhân</dt>
                                    <dd>#BN-<c:out value="${record.patientId}" /></dd>
                                </div>
                                <div class="doctor-detail-field-wide">
                                    <dt>Địa chỉ</dt>
                                    <dd><c:out value="${record.patientAddress}" default="Chưa cập nhật" /></dd>
                                </div>
                            </dl>
                        </section>

                        <!-- Card Cột 2: Ca khám tiếp nhận -->
                        <section class="doctor-detail-card" aria-labelledby="visit-info-heading">
                            <div class="doctor-detail-card-heading">
                                <span class="doctor-detail-card-icon blue"><i class="bi bi-calendar2-check" aria-hidden="true"></i></span>
                                <div>
                                    <h2 id="visit-info-heading">Ca khám tiếp nhận</h2>
                                    <p>Thông tin tiếp nhận và phân công</p>
                                </div>
                            </div>
                            <dl class="doctor-detail-fields">
                                <div>
                                    <dt>Ngày khám</dt>
                                    <dd><c:out value="${record.appointmentDateFmt}" default="${record.createdDate}" /></dd>
                                </div>
                                <div>
                                    <dt>Giờ hẹn</dt>
                                    <dd><c:out value="${record.timeSlot}" default="--:--" /></dd>
                                </div>
                                <div>
                                    <dt>Bác sĩ phụ trách</dt>
                                    <dd class="fw-bold text-dark"><c:out value="${record.doctorName}" default="Chưa phân công" /></dd>
                                </div>
                                <div>
                                    <dt>Phòng khám</dt>
                                    <dd><c:out value="${record.roomName}" default="Chưa phân phòng" /></dd>
                                </div>
                                <div class="doctor-detail-field-wide">
                                    <dt>Hóa đơn viện phí</dt>
                                    <dd>
                                        <c:choose>
                                            <c:when test="${not empty record.invoiceId}">
                                                <c:choose><c:when test="${sessionScope.user.roleId == 6 && record.invoiceVisible}"><a href="${pageContext.request.contextPath}/profile/invoice-detail?id=${record.invoiceId}" class="text-teal text-decoration-none fw-semibold">
                                                    <i class="bi bi-receipt me-1"></i><c:out value="${record.formattedInvoiceId}" /> - Tổng tiền: <strong class="text-danger"><c:out value="${record.invoiceAmountFmt}" /></strong>
                                                    <span class="badge bg-success-subtle text-success ms-2 border px-2 py-0.5" style="font-size: 11px;">${record.invoiceStatus}</span>
                                                </a></c:when><c:when test="${sessionScope.user.roleId == 1 || sessionScope.user.roleId == 2 || sessionScope.user.roleId == 5}"><a href="${pageContext.request.contextPath}/staff/invoices/detail?id=${record.invoiceId}" class="text-teal text-decoration-none fw-semibold">
                                                    <i class="bi bi-receipt me-1"></i><c:out value="${record.formattedInvoiceId}" /> - Tổng tiền: <strong class="text-danger"><c:out value="${record.invoiceAmountFmt}" /></strong>
                                                    <span class="badge bg-success-subtle text-success ms-2 border px-2 py-0.5" style="font-size: 11px;">${record.invoiceStatus}</span>
                                                </a></c:when><c:otherwise><c:out value="${record.formattedInvoiceId}" /></c:otherwise></c:choose>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">Chưa phát sinh hóa đơn</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </dd>
                                </div>
                            </dl>
                        </section>
                    </div>

                    <!-- ======================================================== -->
                    <!-- 3. PHIẾU KHÁM LÂM SÀNG (100% Cấu trúc màn hình Doctor)    -->
                    <!-- ======================================================== -->
                    <section class="doctor-detail-card mb-4" aria-labelledby="exam-heading">
                        <div class="doctor-detail-card-heading">
                            <span class="doctor-detail-card-icon violet"><i class="bi bi-clipboard2-pulse" aria-hidden="true"></i></span>
                            <div>
                                <h2 id="exam-heading">Phiếu khám lâm sàng</h2>
                                <p>Thị lực, dấu hiệu nhãn khoa, kết quả khám và kết luận của Bác sĩ</p>
                            </div>
                        </div>

                        <!-- 3.1 Lý do đến khám & Tiền sử -->
                        <c:if test="${not empty record.chiefComplaint or not empty record.medicalHistory}">
                            <div class="doctor-form-fields mb-4">
                                <c:if test="${not empty record.chiefComplaint}">
                                    <div class="doctor-detail-field-wide">
                                        <div class="clinical-result-box mb-0">
                                            <div class="clinical-result-label"><i class="bi bi-chat-left-text text-teal"></i> Lý do đến khám &amp; Triệu chứng chính</div>
                                            <div class="clinical-result-content"><c:out value="${record.chiefComplaint}" /></div>
                                        </div>
                                    </div>
                                </c:if>
                                <c:if test="${not empty record.medicalHistory}">
                                    <div class="doctor-detail-field-wide">
                                        <div class="clinical-result-box mb-0">
                                            <div class="clinical-result-label"><i class="bi bi-clock-history text-teal"></i> Tiền sử mắt &amp; Bệnh sử liên quan</div>
                                            <div class="clinical-result-content"><c:out value="${record.medicalHistory}" /></div>
                                        </div>
                                    </div>
                                </c:if>
                            </div>
                        </c:if>

                        <!-- 3.2 Bảng Ma trận Thị lực & Nhãn áp (Chuẩn Doctor Form) -->
                        <div class="mb-4">
                            <div class="d-flex align-items-center gap-2 mb-2">
                                <span class="fw-bold text-dark" style="font-size: 14px;"><i class="bi bi-eye text-teal me-1.5"></i>Thị lực và nhãn áp</span>
                                <small class="text-muted">(Mắt phải OD / Mắt trái OS)</small>
                            </div>
                            <div class="doctor-form-table-wrap">
                                <table class="doctor-form-matrix">
                                    <thead>
                                        <tr>
                                            <th scope="col" style="width: 34%;">Chỉ số</th>
                                            <th scope="col" style="width: 33%;">Mắt phải (OD)</th>
                                            <th scope="col" style="width: 33%;">Mắt trái (OS)</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <th scope="row">Thị lực không kính</th>
                                            <td><div class="matrix-display-value"><c:out value="${record.odUncorrected}" default="—" /></div></td>
                                            <td><div class="matrix-display-value"><c:out value="${record.osUncorrected}" default="—" /></div></td>
                                        </tr>
                                        <tr>
                                            <th scope="row">Thị lực có kính</th>
                                            <td><div class="matrix-display-value"><c:out value="${record.odCorrected}" default="—" /></div></td>
                                            <td><div class="matrix-display-value"><c:out value="${record.osCorrected}" default="—" /></div></td>
                                        </tr>
                                        <tr>
                                            <th scope="row">Nhãn áp (mmHg)</th>
                                            <td><div class="matrix-display-value"><c:out value="${record.odIop}" default="—" /></div></td>
                                            <td><div class="matrix-display-value"><c:out value="${record.osIop}" default="—" /></div></td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- 3.3 Khám thực thể (Bán phần trước & Đáy mắt) -->
                        <c:if test="${not empty record.anteriorFindings or not empty record.posteriorFindings}">
                            <div class="row g-3 mb-4">
                                <div class="col-md-6">
                                    <div class="clinical-result-box mb-0 h-100">
                                        <div class="clinical-result-label"><i class="bi bi-circle text-teal"></i> Bán phần trước</div>
                                        <div class="clinical-result-content"><c:out value="${record.anteriorFindings}" default="Giác mạc trong, tiền phòng sâu, đồng tử phản xạ tốt." /></div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="clinical-result-box mb-0 h-100">
                                        <div class="clinical-result-label"><i class="bi bi-circle-half text-teal"></i> Đáy mắt / Bán phần sau</div>
                                        <div class="clinical-result-content"><c:out value="${record.posteriorFindings}" default="Võng mạc bình thường, gai thị hồng rõ bờ, hoàng điểm bình thường." /></div>
                                    </div>
                                </div>
                            </div>
                        </c:if>

                        <!-- 3.4 Kết quả khám tổng thể -->
                        <div class="clinical-result-box">
                            <div class="clinical-result-label">
                                <i class="bi bi-clipboard2-data text-teal"></i> Kết quả khám &amp; Đo thị lực
                            </div>
                            <div class="clinical-result-content">
                                <c:out value="${record.examinationResult}" default="Chưa cập nhật kết quả khám" />
                            </div>
                        </div>

                        <!-- 3.5 Chẩn đoán lâm sàng -->
                        <div class="clinical-result-box" style="border-left: 4px solid #008b74; background: #f0fdfa;">
                            <div class="clinical-result-label">
                                <i class="bi bi-activity text-teal"></i> Chẩn đoán lâm sàng
                            </div>
                            <div class="clinical-result-content fw-bold text-dark fs-6">
                                <c:out value="${record.clinicalDiagnosis}" default="Khám mắt định kỳ" />
                            </div>
                        </div>

                        <!-- 3.6 Kết luận và hướng xử trí -->
                        <div class="clinical-result-box mb-0">
                            <div class="clinical-result-label">
                                <i class="bi bi-journal-check text-teal"></i> Kết luận chuyên môn &amp; Hướng xử trí
                            </div>
                            <div class="clinical-result-content">
                                <c:out value="${record.conclusion}" default="Chưa cập nhật kết luận" />
                            </div>
                            <c:if test="${not empty record.followUpDate}">
                                <div class="mt-3 pt-2 border-top d-flex align-items-center gap-2 small">
                                    <span class="text-muted"><i class="bi bi-calendar-event text-teal me-1"></i>Ngày tái khám dự kiến:</span>
                                    <strong class="text-dark"><c:out value="${record.followUpDate}" /></strong>
                                </div>
                            </c:if>
                        </div>
                    </section>

                    <!-- ======================================================== -->
                    <!-- 4. CHỈ ĐỊNH CẬN LÂM SÀNG & THỦ THUẬT                     -->
                    <!-- ======================================================== -->
                    <c:if test="${not empty record.procedures}">
                        <section class="doctor-detail-card mb-4" aria-labelledby="procedure-heading">
                            <div class="doctor-detail-card-heading">
                                <span class="doctor-detail-card-icon teal"><i class="bi bi-activity" aria-hidden="true"></i></span>
                                <div>
                                    <h2 id="procedure-heading">Chỉ định Cận lâm sàng &amp; Thủ thuật</h2>
                                    <p>Danh mục kỹ thuật đo mắt, chẩn đoán hình ảnh và thủ thuật can thiệp</p>
                                </div>
                            </div>

                            <div class="table-responsive">
                                <table class="table align-middle mb-0" style="border: 1px solid #e2ebef; border-radius: 12px; overflow: hidden;">
                                    <thead class="table-light">
                                        <tr style="font-size: 12px; text-transform: uppercase; letter-spacing: 0.5px;">
                                            <th class="text-center" style="width: 7%;">STT</th>
                                            <th style="width: 35%;">Tên kỹ thuật / Dịch vụ</th>
                                            <th>Bác sĩ / KTV thực hiện</th>
                                            <th class="text-end" style="width: 18%;">Chi phí</th>
                                            <th class="text-center" style="width: 16%;">Trạng thái</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="proc" items="${record.procedures}">
                                            <tr>
                                                <td class="text-center text-muted fw-bold">${proc.stt}</td>
                                                <td>
                                                    <div class="fw-bold text-dark"><c:out value="${proc.serviceName}" /></div>
                                                    <c:if test="${not empty proc.referralNotes}">
                                                        <div class="small text-muted mt-0.5"><i class="bi bi-info-circle me-1"></i><c:out value="${proc.referralNotes}" /></div>
                                                    </c:if>
                                                    <c:if test="${not empty proc.resultText}">
                                                        <div class="small text-dark mt-1 p-2 rounded bg-light border">
                                                            <strong>Kết quả:</strong> <c:out value="${proc.resultText}" />
                                                            <c:if test="${not empty proc.resultConclusion}">
                                                                <br><strong>Kết luận:</strong> <c:out value="${proc.resultConclusion}" />
                                                            </c:if>
                                                        </div>
                                                    </c:if>
                                                </td>
                                                <td>
                                                    <i class="bi bi-person-badge me-1 text-teal"></i>
                                                    <span class="text-dark fw-medium">${proc.specialistName}</span>
                                                    <c:if test="${not empty proc.completedAtFmt}">
                                                        <div class="small text-muted">${proc.completedAtFmt}</div>
                                                    </c:if>
                                                </td>
                                                <td class="text-end fw-bold text-teal">${proc.priceFmt}</td>
                                                <td class="text-center">
                                                    <span class="doctor-detail-status completed py-1 px-2.5" style="font-size: 11.5px;">
                                                        <i class="bi bi-check2-circle me-1"></i>${proc.status == 'Completed' ? 'Đã thực hiện' : proc.status}
                                                    </span>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </section>
                    </c:if>

                    <!-- ======================================================== -->
                    <!-- 5. ĐƠN KÍNH THUỐC (Chuẩn Doctor Glasses Table)           -->
                    <!-- ======================================================== -->
                    <c:if test="${record.hasGlasses}">
                        <section class="doctor-detail-card mb-4" aria-labelledby="glasses-heading">
                            <div class="doctor-detail-card-heading">
                                <span class="doctor-detail-card-icon violet"><i class="bi bi-eyeglasses" aria-hidden="true"></i></span>
                                <div>
                                    <h2 id="glasses-heading">Đơn kính thuốc</h2>
                                    <p>Độ cầu (SPH), độ trụ (CYL), trục (AXIS) và độ cộng (ADD)</p>
                                </div>
                            </div>

                            <div class="doctor-form-table-wrap mb-3">
                                <table class="doctor-form-matrix doctor-form-glasses-table">
                                    <thead>
                                        <tr>
                                            <th scope="col" style="width: 20%;">Mắt</th>
                                            <th scope="col" style="width: 20%;">SPH</th>
                                            <th scope="col" style="width: 20%;">CYL</th>
                                            <th scope="col" style="width: 20%;">AXIS</th>
                                            <th scope="col" style="width: 20%;">ADD</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <th scope="row">Phải (OD)</th>
                                            <td><div class="matrix-display-value"><c:out value="${record.eyeglass.odSph}" default="0.00" /></div></td>
                                            <td><div class="matrix-display-value"><c:out value="${record.eyeglass.odCyl}" default="0.00" /></div></td>
                                            <td><div class="matrix-display-value"><c:out value="${record.eyeglass.odAxis}" default="0" />°</div></td>
                                            <td><div class="matrix-display-value"><c:out value="${record.eyeglass.odAdd}" default="0.00" /></div></td>
                                        </tr>
                                        <tr>
                                            <th scope="row">Trái (OS)</th>
                                            <td><div class="matrix-display-value"><c:out value="${record.eyeglass.osSph}" default="0.00" /></div></td>
                                            <td><div class="matrix-display-value"><c:out value="${record.eyeglass.osCyl}" default="0.00" /></div></td>
                                            <td><div class="matrix-display-value"><c:out value="${record.eyeglass.osAxis}" default="0" />°</div></td>
                                            <td><div class="matrix-display-value"><c:out value="${record.eyeglass.osAdd}" default="0.00" /></div></td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>

                            <div class="row g-3">
                                <div class="col-md-4">
                                    <div class="clinical-result-box mb-0">
                                        <div class="clinical-result-label">Khoảng cách đồng tử (PD)</div>
                                        <div class="clinical-result-content fw-bold text-dark"><c:out value="${record.eyeglass.pd}" default="62" /> mm</div>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="clinical-result-box mb-0">
                                        <div class="clinical-result-label">Loại kính chỉ định</div>
                                        <div class="clinical-result-content fw-bold text-teal"><c:out value="${record.eyeglass.lensTypeName}" default="Kính nhìn xa" /></div>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="clinical-result-box mb-0">
                                        <div class="clinical-result-label">Ghi chú về kính</div>
                                        <div class="clinical-result-content"><c:out value="${record.eyeglass.glassesNotes}" default="Tròng chống lóa, bảo vệ mắt." /></div>
                                    </div>
                                </div>
                            </div>
                        </section>
                    </c:if>

                    <!-- ======================================================== -->
                    <!-- 6. ĐƠN THUỐC ĐIỀU TRỊ (Chuẩn Doctor Prescription)        -->
                    <!-- ======================================================== -->
                    <section class="doctor-detail-card mb-4" aria-labelledby="prescription-heading">
                        <div class="doctor-detail-card-heading d-flex align-items-center justify-content-between flex-wrap gap-2">
                            <div class="d-flex align-items-center gap-3">
                                <span class="doctor-detail-card-icon blue"><i class="bi bi-capsule" aria-hidden="true"></i></span>
                                <div>
                                    <h2 id="prescription-heading">Đơn thuốc điều trị</h2>
                                    <p>Toa thuốc uống và thuốc nhỏ mắt theo phác đồ của Bác sĩ</p>
                                </div>
                            </div>
                            <c:if test="${not empty record.prescriptionId && record.prescriptionId != 'N/A'}">
                                <span class="badge bg-light text-secondary border px-3 py-1.5 rounded-pill fw-semibold" style="font-size: 12px;">
                                    Mã đơn thuốc: <strong class="text-dark">${record.prescriptionId}</strong>
                                </span>
                            </c:if>
                        </div>

                        <c:choose>
                            <c:when test="${not empty record.medicines}">
                                <div class="table-responsive mb-3">
                                    <table class="table align-middle mb-0" style="border: 1px solid #e2ebef; border-radius: 12px; overflow: hidden;">
                                        <thead class="table-light">
                                            <tr style="font-size: 12px; text-transform: uppercase; letter-spacing: 0.5px;">
                                                <th class="text-center" style="width: 7%;">STT</th>
                                                <th style="width: 35%;">Tên thuốc / Quy cách</th>
                                                <th class="text-center" style="width: 13%;">Số lượng</th>
                                                <th>Liều dùng &amp; Hướng dẫn sử dụng</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="med" items="${record.medicines}">
                                                <tr>
                                                    <td class="text-center text-muted fw-bold">${med.stt}</td>
                                                    <td>
                                                        <div class="fw-bold text-dark">${med.medicineName}</div>
                                                    </td>
                                                    <td class="text-center fw-bold text-teal">${med.quantity}</td>
                                                    <td class="text-dark">${med.dosageInstruction}</td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="p-4 bg-light rounded-3 text-muted text-center small mb-3 border">
                                    <i class="bi bi-capsule text-secondary fs-4 d-block mb-1"></i>
                                    Bác sĩ không kê đơn thuốc uống hoặc thuốc nhỏ mắt trong lần khám này.
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <!-- Lời dặn Bác sĩ -->
                        <div class="clinical-result-box mb-0 mt-3" style="background-color: #f0fdfa; border: 1px solid #ccfbf1;">
                            <div class="clinical-result-label">
                                <i class="bi bi-chat-heart text-teal"></i> Lời dặn của Bác sĩ &amp; Hướng dẫn chăm sóc
                            </div>
                            <div class="clinical-result-content">
                                <c:out value="${record.doctorNotes}" default="Giữ vệ sinh mắt, tránh dụi mắt và tái khám đúng lịch hẹn nếu có bất thường." />
                            </div>
                        </div>
                    </section>

                    <!-- ======================================================== -->
                    <!-- 7. LỊCH SỬ CÁC LẦN KHÁM KHÁC (100% Doctor Timeline)      -->
                    <!-- ======================================================== -->
                    <c:if test="${not empty record.history}">
                        <section class="doctor-detail-card doctor-detail-history mb-4" aria-labelledby="history-heading">
                            <div class="doctor-detail-card-heading doctor-detail-history-heading">
                                <span class="doctor-detail-card-icon violet"><i class="bi bi-clock-history" aria-hidden="true"></i></span>
                                <div>
                                    <h2 id="history-heading">Lịch sử các lần khám khác</h2>
                                    <p>Các lần khám trước của bệnh nhân tại VisionCare, mới nhất ở trên</p>
                                </div>
                                <span class="doctor-detail-history-count"><c:out value="${fn:length(record.history)}" /> lần khám</span>
                            </div>

                            <ol class="doctor-detail-timeline">
                                <c:forEach var="item" items="${record.history}">
                                    <li class="doctor-detail-timeline-item">
                                        <span class="doctor-detail-timeline-dot" aria-hidden="true"></span>
                                        <div class="doctor-detail-history-row">
                                            <div class="doctor-detail-history-date">
                                                <i class="bi bi-calendar-event" aria-hidden="true"></i>
                                                <c:out value="${item.dateFmt}" /> <small class="text-muted">(${item.timeFmt})</small>
                                            </div>
                                            <span class="doctor-detail-record-id"><c:out value="${item.formattedId}" /></span>
                                        </div>
                                        <h3><c:out value="${item.clinicalDiagnosis}" default="Khám mắt chuyên khoa" /></h3>
                                        <p class="doctor-detail-history-doctor">
                                            <i class="bi bi-person-badge" aria-hidden="true"></i> <c:out value="${item.doctorName}" default="Chưa cập nhật" />
                                            <c:if test="${not empty item.doctorSpecialty}">
                                                <span class="text-teal ms-1">(${item.doctorSpecialty})</span>
                                            </c:if>
                                        </p>
                                        <a class="doctor-detail-history-link" href="${pageContext.request.contextPath}/profile/medical-record?id=${item.recordId}">
                                            <i class="bi bi-file-earmark-medical" aria-hidden="true"></i> Xem chi tiết lần khám này
                                        </a>
                                        <c:if test="${not empty item.examinationResult or not empty item.conclusion}">
                                            <details class="doctor-detail-history-more">
                                                <summary>Xem kết quả khám <i class="bi bi-chevron-down" aria-hidden="true"></i></summary>
                                                <div class="doctor-detail-history-result mt-2 p-3 bg-light rounded-3 border">
                                                    <c:if test="${not empty item.examinationResult}">
                                                        <div class="mb-2"><strong>Kết quả khám:</strong> <p class="mb-0 text-secondary"><c:out value="${item.examinationResult}" /></p></div>
                                                    </c:if>
                                                    <c:if test="${not empty item.conclusion}">
                                                        <div><strong>Kết luận:</strong> <p class="mb-0 text-secondary"><c:out value="${item.conclusion}" /></p></div>
                                                    </c:if>
                                                </div>
                                            </details>
                                        </c:if>
                                    </li>
                                </c:forEach>
                            </ol>
                        </section>
                    </c:if>

                    <!-- ======================================================== -->
                    <!-- 8. CHỮ KÝ XÁC NHẬN & CAM KẾT (Printable Document Footer) -->
                    <!-- ======================================================== -->
                    <div class="doctor-detail-card print-signature-section">
                        <div class="text-end text-muted small fst-italic mb-3 pe-md-4">
                            TP. Hồ Chí Minh, ngày khám <c:out value="${record.createdDate}" />
                        </div>
                        <div class="row g-4 justify-content-between mb-4">
                            <div class="col-6 text-center">
                                <div class="fw-bold text-dark">Bệnh nhân / Người nhà</div>
                                <div class="text-muted small" style="font-size: 11.5px;">(Ký và ghi rõ họ tên)</div>
                                <div style="height: 70px;"></div>
                                <div class="fw-bold text-dark fs-6"><c:out value="${record.patientName}" /></div>
                            </div>
                            <div class="col-6 text-center">
                                <div class="fw-bold text-dark">Bác sĩ khám &amp; điều trị</div>
                                <div class="text-muted small" style="font-size: 11.5px;">(Ký và ghi rõ họ tên)</div>
                                <div style="height: 70px;"></div>
                                <div class="fw-bold text-dark fs-6"><c:out value="${record.doctorName}" /></div>
                            </div>
                        </div>
                        <div class="text-center pt-3 border-top">
                            <p class="fw-semibold mb-1 text-teal small">
                                <i class="bi bi-shield-check me-1"></i>Cảm ơn quý khách đã tin tưởng và đồng hành cùng VisionCare Clinic!
                            </p>
                            <p class="text-muted small mb-0" style="font-size: 11.5px;">
                                Vui lòng bảo quản và mang theo phiếu khám này khi đến tái khám hoặc kiểm tra mắt định kỳ. Hotline hỗ trợ 24/7: 1800 599 988.
                            </p>
                        </div>
                    </div>

                </div>

            </div>
        </div>
    </section>

</main>

<%-- Include Common Footer --%>
<jsp:include page="/views/common/footer.jsp" />
