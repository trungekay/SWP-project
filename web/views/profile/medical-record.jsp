<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%-- Include Common Header --%>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Hồ sơ khám bệnh" />
    <jsp:param name="pageDescription" value="Chi tiết hồ sơ bệnh án ngoại trú VisionCare Clinic" />
    <jsp:param name="bodyClass" value="starter-page-page" />
    <jsp:param name="activeNav" value="" />
</jsp:include>

<!-- Link to Doctor & Specialist Unified Detail Stylesheet -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/doctor-patient-detail.css">

<style>
    /* Patient Profile Medical Detail Scoped Adaptations */
    .patient-medical-detail-page {
        max-width: 1200px;
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
    .btn-teal {
        background: #008b74;
        color: #fff;
        border: 1px solid transparent;
        transition: all .2s ease;
    }
    .btn-teal:hover {
        background: #00705d;
        color: #fff;
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(0, 139, 116, .2);
    }
    .btn-outline-teal {
        background: #fff;
        color: #008b74;
        border: 1px solid #cbece4;
        transition: all .2s ease;
    }
    .btn-outline-teal:hover {
        background: #effbf7;
        color: #00705d;
        border-color: #008b74;
    }
    
    /* Document Container & Printable Card */
    .patient-doc-container {
        background: transparent;
    }
    
    /* Result Boxes inside Clinical Detail */
    .clinical-box {
        background: #f8fcfa;
        border: 1px solid #e2f0eb;
        border-radius: 12px;
        padding: 16px 20px;
        margin-bottom: 14px;
        transition: border-color .2s;
    }
    .clinical-box:hover {
        border-color: #b9e3d7;
    }
    .clinical-box-label {
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
    .clinical-box-content {
        color: #172b3a;
        font-size: 14px;
        line-height: 1.6;
    }
    
    /* Procedure & Prescription Tables */
    .patient-detail-table {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0;
        border: 1px solid #e2eaf0;
        border-radius: 12px;
        overflow: hidden;
        margin-bottom: 0;
    }
    .patient-detail-table th {
        background-color: #f8fafc;
        color: #475569;
        font-size: 12.5px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.4px;
        padding: 13px 18px;
        border-bottom: 1px solid #e2eaf0;
    }
    .patient-detail-table td {
        padding: 14px 18px;
        font-size: 13.5px;
        color: #1e293b;
        border-bottom: 1px solid #f1f5f9;
        vertical-align: middle;
    }
    .patient-detail-table tr:last-child td {
        border-bottom: none;
    }
    .patient-detail-table tbody tr:hover {
        background-color: #f8fcfa;
    }

    /* Print View Styles */
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
        .header, .footer, .breadcrumbs, .page-title, .action-bar-top {
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
            <div class="container">
                <div class="row d-flex justify-content-center text-center">
                    <div class="col-lg-8">
                        <h1>Chi tiết hồ sơ khám</h1>
                        <p class="mb-0">Hồ sơ bệnh án ngoại trú và kết quả điều trị tại VisionCare Clinic</p>
                    </div>
                </div>
            </div>
        </div>
        <nav class="breadcrumbs">
            <div class="container">
                <ol>
                    <li><a href="${pageContext.request.contextPath}/home">Trang chủ</a></li>
                    <li><a href="${pageContext.request.contextPath}/views/profile/medical-history.jsp">Lịch sử khám bệnh</a></li>
                    <li class="current">Hồ sơ ${record.formattedId}</li>
                </ol>
            </div>
        </nav>
    </div>

    <section class="section pt-3">
        <div class="container">
            <div class="patient-medical-detail-page">

                <!-- Top Action Bar -->
                <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-4 action-bar-top">
                    <div class="d-flex align-items-center gap-2">
                        <a href="${pageContext.request.contextPath}/views/profile/medical-history.jsp" class="btn btn-sm btn-outline-teal rounded-pill px-3 py-1.5 shadow-sm fw-semibold">
                            <i class="bi bi-arrow-left me-1"></i>Về Lịch sử khám
                        </a>
                        <span class="text-muted small">|</span>
                        <span class="badge bg-white text-secondary border px-2.5 py-1 rounded-pill" style="font-size: 12px;">
                            Mã hồ sơ: <strong class="text-teal">${record.formattedId}</strong>
                        </span>
                    </div>
                    <div class="d-flex align-items-center gap-2">
                        <button type="button" class="btn btn-sm btn-outline-teal rounded-pill px-3 py-1.5 shadow-sm fw-semibold" onclick="window.print()">
                            <i class="bi bi-printer me-1.5"></i>In phiếu khám & đơn thuốc
                        </button>
                    </div>
                </div>

                <!-- Printable Document Area -->
                <div id="printableArea" class="patient-doc-container">

                    <!-- ======================================================== -->
                    <!-- 1. HERO BANNER BỆNH NHÂN (Chuẩn Format Doctor & Specialist) -->
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
                                <div class="doctor-detail-hero-label">HỒ SƠ BỆNH ÁN NGOẠI TRÚ</div>
                                <h2 id="patient-name"><c:out value="${record.patientName}" default="Chưa có tên" /></h2>
                                <div class="doctor-detail-hero-identifiers">
                                    <span>Mã BN: <strong><c:out value="${record.formattedPatientId}" /></strong></span>
                                    <span>Mã lịch hẹn: <strong><c:out value="${record.formattedApptId}" /></strong></span>
                                    <span>Mã hồ sơ: <strong class="text-teal"><c:out value="${record.formattedId}" /></strong></span>
                                </div>
                            </div>
                        </div>
                        <div class="doctor-detail-status-wrap">
                            <c:choose>
                                <c:when test="${record.appointmentStatus eq 'Completed'}">
                                    <span class="doctor-detail-status completed">
                                        <i class="bi bi-check-circle-fill" aria-hidden="true"></i> Hoàn thành khám
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="doctor-detail-status in-progress">
                                        <i class="bi bi-clock-history" aria-hidden="true"></i> <c:out value="${record.appointmentStatus}" default="Đang khám" />
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="doctor-detail-hero-facts">
                            <span>
                                <i class="bi bi-calendar3" aria-hidden="true"></i>
                                <strong>Ngày khám:</strong> <c:out value="${record.createdDate}" default="N/A" />
                            </span>
                            <span>
                                <i class="bi bi-person-badge" aria-hidden="true"></i>
                                <strong>Bác sĩ:</strong> <c:out value="${record.doctorName}" />
                            </span>
                            <span>
                                <i class="bi bi-geo-alt" aria-hidden="true"></i>
                                <strong>Phòng khám:</strong> <c:out value="${record.roomName}" />
                            </span>
                            <span>
                                <i class="bi bi-receipt" aria-hidden="true"></i>
                                <strong>Hóa đơn:</strong>
                                <c:choose>
                                    <c:when test="${not empty record.invoiceId}">
                                        <a href="${pageContext.request.contextPath}/profile/invoice-detail?id=${record.invoiceId}" class="text-teal text-decoration-none fw-bold">
                                            <c:out value="${record.formattedInvoiceId}" /> (<c:out value="${record.invoiceAmountFmt}" />)
                                        </a>
                                    </c:when>
                                    <c:otherwise>Chưa lập hóa đơn</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </section>

                    <!-- ======================================================== -->
                    <!-- 2. GRID 2 CỘT: THÔNG TIN BỆNH NHÂN & BÁC SĨ PHỤ TRÁCH    -->
                    <!-- ======================================================== -->
                    <div class="doctor-detail-grid">
                        <!-- Card Cột 1: Thông tin bệnh nhân -->
                        <section class="doctor-detail-card" aria-labelledby="patient-info-heading">
                            <div class="doctor-detail-card-heading">
                                <span class="doctor-detail-card-icon teal"><i class="bi bi-person-vcard" aria-hidden="true"></i></span>
                                <div>
                                    <h2 id="patient-info-heading">Thông tin bệnh nhân</h2>
                                    <p>Thông tin hành chính và liên hệ</p>
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
                                    <dd><span class="badge bg-light text-dark border"><c:out value="${record.formattedPatientId}" /></span></dd>
                                </div>
                                <div class="doctor-detail-field-wide">
                                    <dt>Địa chỉ liên hệ</dt>
                                    <dd><c:out value="${record.patientAddress}" default="Chưa cập nhật" /></dd>
                                </div>
                            </dl>
                        </section>

                        <!-- Card Cột 2: Bác sĩ & Ca khám -->
                        <section class="doctor-detail-card" aria-labelledby="doctor-info-heading">
                            <div class="doctor-detail-card-heading">
                                <span class="doctor-detail-card-icon blue"><i class="bi bi-hospital" aria-hidden="true"></i></span>
                                <div>
                                    <h2 id="doctor-info-heading">Bác sĩ phụ trách & Ca khám</h2>
                                    <p>Thông tin chuyên môn và cơ sở tiếp nhận</p>
                                </div>
                            </div>
                            <dl class="doctor-detail-fields">
                                <div>
                                    <dt>Bác sĩ điều trị</dt>
                                    <dd class="text-dark fw-bold"><c:out value="${record.doctorName}" /></dd>
                                </div>
                                <div>
                                    <dt>Chuyên khoa</dt>
                                    <dd class="text-teal"><c:out value="${record.doctorSpecialty}" /></dd>
                                </div>
                                <div>
                                    <dt>Phòng khám</dt>
                                    <dd><c:out value="${record.roomName}" /></dd>
                                </div>
                                <div>
                                    <dt>Mã lịch hẹn</dt>
                                    <dd><span class="badge bg-light text-dark border"><c:out value="${record.formattedApptId}" /></span></dd>
                                </div>
                                <div class="doctor-detail-field-wide">
                                    <dt>Hóa đơn viện phí</dt>
                                    <dd>
                                        <c:choose>
                                            <c:when test="${not empty record.invoiceId}">
                                                <a href="${pageContext.request.contextPath}/profile/invoice-detail?id=${record.invoiceId}" class="text-teal text-decoration-none fw-semibold">
                                                    <i class="bi bi-receipt me-1"></i><c:out value="${record.formattedInvoiceId}" /> - Tổng tiền: <strong class="text-danger"><c:out value="${record.invoiceAmountFmt}" /></strong>
                                                </a>
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
                    <!-- 3. KẾT QUẢ KHÁM LÂM SÀNG & CHẨN ĐOÁN (Chuyên môn)        -->
                    <!-- ======================================================== -->
                    <section class="doctor-detail-card mb-4" aria-labelledby="clinical-heading">
                        <div class="doctor-detail-card-heading">
                            <span class="doctor-detail-card-icon violet"><i class="bi bi-journal-medical" aria-hidden="true"></i></span>
                            <div>
                                <h2 id="clinical-heading">Kết quả khám &amp; Chẩn đoán lâm sàng</h2>
                                <p>Ghi nhận chuyên môn từ Bác sĩ nhãn khoa</p>
                            </div>
                        </div>

                        <!-- Triệu chứng chính (nếu có) -->
                        <c:if test="${not empty record.chiefComplaint}">
                            <div class="clinical-box">
                                <div class="clinical-box-label"><i class="bi bi-chat-left-dots text-teal fs-6"></i> Triệu chứng chính</div>
                                <div class="clinical-box-content" style="white-space: pre-wrap;"><c:out value="${record.chiefComplaint}" /></div>
                            </div>
                        </c:if>

                        <!-- Tiền sử mắt và bệnh sử liên quan (nếu có) -->
                        <c:if test="${not empty record.medicalHistory}">
                            <div class="clinical-box">
                                <div class="clinical-box-label"><i class="bi bi-clock-history text-teal fs-6"></i> Tiền sử mắt &amp; Bệnh sử liên quan</div>
                                <div class="clinical-box-content" style="white-space: pre-wrap;"><c:out value="${record.medicalHistory}" /></div>
                            </div>
                        </c:if>

                        <!-- Thị lực và nhãn áp (nếu có) -->
                        <c:if test="${not empty record.odUncorrected or not empty record.osUncorrected or not empty record.odIop or not empty record.osIop}">
                            <div class="clinical-box">
                                <div class="clinical-box-label"><i class="bi bi-eye text-teal fs-6"></i> Thị lực và nhãn áp</div>
                                <div class="clinical-box-content">
                                    <div><strong>OD (Mắt phải):</strong> không kính <c:out value="${record.odUncorrected}" default="—" />, có kính <c:out value="${record.odCorrected}" default="—" />, nhãn áp <c:out value="${record.odIop}" default="—" /> mmHg</div>
                                    <div><strong>OS (Mắt trái):</strong> không kính <c:out value="${record.osUncorrected}" default="—" />, có kính <c:out value="${record.osCorrected}" default="—" />, nhãn áp <c:out value="${record.osIop}" default="—" /> mmHg</div>
                                </div>
                            </div>
                        </c:if>

                        <!-- Bán phần trước (nếu có) -->
                        <c:if test="${not empty record.anteriorFindings}">
                            <div class="clinical-box">
                                <div class="clinical-box-label"><i class="bi bi-search text-teal fs-6"></i> Bán phần trước</div>
                                <div class="clinical-box-content" style="white-space: pre-wrap;"><c:out value="${record.anteriorFindings}" /></div>
                            </div>
                        </c:if>

                        <!-- Đáy mắt / Bán phần sau (nếu có) -->
                        <c:if test="${not empty record.posteriorFindings}">
                            <div class="clinical-box">
                                <div class="clinical-box-label"><i class="bi bi-circle-half text-teal fs-6"></i> Đáy mắt / Bán phần sau</div>
                                <div class="clinical-box-content" style="white-space: pre-wrap;"><c:out value="${record.posteriorFindings}" /></div>
                            </div>
                        </c:if>

                        <!-- Chẩn đoán của Bác sĩ -->
                        <div class="clinical-box" style="border-left: 4px solid #008b74; background: #f0fdfa;">
                            <div class="clinical-box-label">
                                <i class="bi bi-activity text-teal fs-6"></i> Chẩn đoán của Bác sĩ
                            </div>
                            <div class="clinical-box-content fw-bold text-dark fs-6">
                                <c:out value="${record.clinicalDiagnosis}" default="Chưa cập nhật" />
                            </div>
                        </div>

                        <!-- Kết quả kiểm tra mắt & đo thị lực -->
                        <div class="clinical-box">
                            <div class="clinical-box-label">
                                <i class="bi bi-eye text-teal fs-6"></i> Kết quả kiểm tra mắt &amp; Đo thị lực
                            </div>
                            <div class="clinical-box-content">
                                <c:out value="${record.examinationResult}" default="Chưa cập nhật" />
                            </div>
                        </div>

                        <!-- Kết luận chuyên môn & Hướng xử trí -->
                        <div class="clinical-box mb-0">
                            <div class="clinical-box-label">
                                <i class="bi bi-clipboard-check text-teal fs-6"></i> Kết luận chuyên môn &amp; Hướng xử trí
                            </div>
                            <div class="clinical-box-content">
                                <c:out value="${record.conclusion}" default="Chưa cập nhật" />
                            </div>
                        </div>
                    </section>

                    <!-- ======================================================== -->
                    <!-- 4. CHỈ ĐỊNH CẬN LÂM SÀNG & THỦ THUẬT (Format Specialist) -->
                    <!-- ======================================================== -->
                    <c:if test="${not empty record.procedures}">
                        <section class="doctor-detail-card mb-4" aria-labelledby="procedure-heading">
                            <div class="doctor-detail-card-heading">
                                <span class="doctor-detail-card-icon teal"><i class="bi bi-clipboard2-pulse" aria-hidden="true"></i></span>
                                <div>
                                    <h2 id="procedure-heading">Chỉ định Dịch vụ / Cận lâm sàng &amp; Thủ thuật</h2>
                                    <p>Danh mục kỹ thuật đo mắt, chẩn đoán hình ảnh đã thực hiện</p>
                                </div>
                            </div>

                            <div class="table-responsive">
                                <table class="patient-detail-table">
                                    <thead>
                                        <tr>
                                            <th class="text-center" style="width: 8%;">STT</th>
                                            <th>Tên kỹ thuật / Dịch vụ</th>
                                            <th>Bác sĩ / KTV thực hiện</th>
                                            <th class="text-end" style="width: 20%;">Chi phí</th>
                                            <th class="text-center" style="width: 18%;">Trạng thái</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="proc" items="${record.procedures}">
                                            <tr>
                                                <td class="text-center text-muted fw-bold">${proc.stt}</td>
                                                <td>
                                                    <div class="fw-bold text-dark"><c:out value="${proc.serviceName}" /></div>
                                                    <c:if test="${not empty proc.referralNotes}">
                                                        <div class="small text-muted fw-normal mt-1" style="white-space:pre-wrap"><c:out value="${proc.referralNotes}" /></div>
                                                    </c:if>
                                                </td>
                                                <td>
                                                    <i class="bi bi-person me-1 text-muted"></i>
                                                    <span class="text-secondary">${proc.specialistName}</span>
                                                </td>
                                                <td class="text-end fw-semibold text-teal">${proc.priceFmt}</td>
                                                <td class="text-center">
                                                    <span class="badge bg-success-subtle text-success border border-success-subtle px-2.5 py-1 rounded-pill fw-semibold" style="font-size: 11.5px;">
                                                        <i class="bi bi-check-circle-fill me-1"></i>${proc.status == 'Completed' ? 'Đã thực hiện' : proc.status}
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
                    <!-- 5. ĐƠN THUỐC ĐIỀU TRỊ & LỜI DẶN BÁC SĨ (Prescription)    -->
                    <!-- ======================================================== -->
                    <section class="doctor-detail-card mb-4" aria-labelledby="prescription-heading">
                        <div class="doctor-detail-card-heading d-flex align-items-center justify-content-between flex-wrap gap-2">
                            <div class="d-flex align-items-center gap-3">
                                <span class="doctor-detail-card-icon blue"><i class="bi bi-capsule" aria-hidden="true"></i></span>
                                <div>
                                    <h2 id="prescription-heading">Đơn thuốc điều trị</h2>
                                    <p>Toa thuốc uống và thuốc nhỏ mắt theo phác đồ điều trị</p>
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
                                    <table class="patient-detail-table">
                                        <thead>
                                            <tr>
                                                <th class="text-center" style="width: 8%;">STT</th>
                                                <th style="width: 35%;">Tên thuốc / Quy cách</th>
                                                <th class="text-center" style="width: 12%;">Số lượng</th>
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
                                    Bác sĩ không kê đơn thuốc uống hoặc thuốc nhỏ mắt trong buổi khám này.
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <!-- Lời dặn Bác sĩ & Hướng dẫn tái khám -->
                        <div class="clinical-box mb-0 mt-3" style="background-color: #f0fdfa; border: 1px solid #ccfbf1;">
                            <div class="clinical-box-label">
                                <i class="bi bi-chat-heart text-teal fs-6"></i> Lời dặn của Bác sĩ &amp; Hướng dẫn tái khám
                            </div>
                            <div class="clinical-box-content">
                                <c:out value="${record.doctorNotes}" default="Giữ vệ sinh mắt, tránh dụi mắt và tái khám đúng lịch hẹn nếu có bất thường." />
                            </div>
                        </div>
                    </section>

                    <!-- ======================================================== -->
                    <!-- 6. CHỮ KÝ XÁC NHẬN & CAM KẾT (Printable Document Footer) -->
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
