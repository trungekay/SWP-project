<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Include Header --%>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Chi tiết hóa đơn" />
    <jsp:param name="pageDescription" value="Chi tiết hóa đơn VisionCare Clinic" />
    <jsp:param name="bodyClass" value="starter-page-page" />
    <jsp:param name="activeNav" value="" />
</jsp:include>

<style>
    .invoice-card {
        background: #fff;
        border-radius: 12px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
        padding: 35px;
        margin-top: 15px;
        margin-bottom: 40px;
    }
    .text-teal {
        color: #0d9488;
    }
    .bg-teal {
        background-color: #0d9488;
    }
    @media print {
        body * {
            visibility: hidden;
        }
        #printableInvoice, #printableInvoice * {
            visibility: visible;
        }
        #printableInvoice {
            position: absolute;
            left: 0;
            top: 0;
            width: 100%;
            margin: 0;
            padding: 15px;
            background: #fff;
            box-shadow: none !important;
            border-radius: 0 !important;
        }
        .header, .footer, .breadcrumbs, .page-title, .btn, .action-bar-top {
            display: none !important;
        }
    }
</style>

<main class="main bg-light pb-5">

    <div class="page-title">
        <div class="heading">
            <div class="container">
                <div class="row d-flex justify-content-center text-center">
                    <div class="col-lg-8">
                        <h1>Chi tiết hóa đơn</h1>
                        <p class="mb-0">Hóa đơn điện tử phòng khám chuyên khoa mắt VisionCare Clinic</p>
                    </div>
                </div>
            </div>
        </div>
        <nav class="breadcrumbs">
            <div class="container">
                <ol>
                    <li><a href="${pageContext.request.contextPath}/home">Trang chủ</a></li>
                    <li><a href="${pageContext.request.contextPath}/views/profile/medical-history.jsp">Hồ sơ y tế</a></li>
                    <li class="current">Chi tiết hóa đơn</li>
                </ol>
            </div>
        </nav>
    </div>

    <section class="section pt-4">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-9">

                    <div class="d-flex justify-content-end mb-3 gap-2 action-bar-top">
                        <button type="button" class="btn btn-outline-secondary" onclick="window.print()"><i class="bi bi-printer me-2"></i>In hóa đơn</button>
                        <button type="button" class="btn text-white bg-teal" onclick="if(window.history.length > 1){window.history.back();}else{location.href='${pageContext.request.contextPath}/views/profile/medical-history.jsp';}"><i class="bi bi-arrow-left me-2"></i>Quay lại</button>
                    </div>

                    <div class="invoice-card" id="printableInvoice">
                        <!-- Invoice Header -->
                        <div class="d-flex justify-content-between align-items-center flex-wrap pb-3 mb-3 border-bottom">
                            <div>
                                <h4 class="fw-bold mb-1" style="color: #0d9488;"><i class="bi bi-eye me-2"></i>VisionCare Clinic</h4>
                                <p class="text-muted small mb-0">Địa chỉ: 456 Lê Thị Riêng, Quận 10, TP.HCM</p>
                                <p class="text-muted small mb-0">Hotline: 1800 599 988 | Email: hotro@visioncare.vn</p>
                            </div>
                            <div class="text-end mt-2 mt-md-0">
                                <h5 class="fw-bold mb-1">HÓA ĐƠN THANH TOÁN</h5>
                                <div class="fw-bold text-dark fs-6">Mã: ${not empty invoice.formattedId ? invoice.formattedId : '#INV-00001'}</div>
                                <div class="small text-muted">Ngày lập: ${not empty invoice.createDate ? invoice.createDate : ''}</div>
                                <div class="mt-2">
                                    <c:choose>
                                        <c:when test="${invoice.status == 'Paid'}">
                                            <span class="badge bg-success px-3 py-2">Đã thanh toán</span>
                                        </c:when>
                                        <c:when test="${invoice.status == 'Refunded'}">
                                            <span class="badge bg-danger px-3 py-2">Đã hoàn tiền</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-warning text-dark px-3 py-2">Chưa thanh toán</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                        <!-- Info Cards (Patient & Treatment) -->
                        <div class="row g-3 mb-4">
                            <div class="col-md-6">
                                <div class="p-3 bg-light rounded-3 h-100">
                                    <h6 class="fw-bold text-muted small text-uppercase mb-2">Thông tin Bệnh nhân</h6>
                                    <p class="mb-1 fw-bold text-dark">${not empty invoice.patientName ? invoice.patientName : (not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Bệnh nhân')}</p>
                                    <p class="mb-1 small text-muted"><i class="bi bi-telephone me-2"></i>${not empty invoice.patientPhone ? invoice.patientPhone : (not empty sessionScope.user.phone ? sessionScope.user.phone : 'Chưa có SĐT')}</p>
                                    <p class="mb-0 small text-muted"><i class="bi bi-geo-alt me-2"></i>${not empty invoice.patientAddress ? invoice.patientAddress : (not empty sessionScope.user.address ? sessionScope.user.address : '456 Lê Thị Riêng, Quận 10, TP.HCM')}</p>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="p-3 bg-light rounded-3 h-100">
                                    <h6 class="fw-bold text-muted small text-uppercase mb-2">Thông tin Khám & Điều trị</h6>
                                    <p class="mb-1 small"><span class="text-muted">Bác sĩ phụ trách:</span> <strong class="text-dark">${not empty invoice.doctorName ? invoice.doctorName : 'BS. Trần Văn Nam'}</strong></p>
                                    <p class="mb-1 small"><span class="text-muted">Mã lịch hẹn:</span> <strong>#APT-${not empty invoice.appointmentId ? invoice.appointmentId : '1'}</strong></p>
                                    <p class="mb-1 small"><span class="text-muted">Mã bệnh án:</span> <strong>${not empty invoice.recordId ? invoice.recordId : '#MR-0001'}</strong></p>
                                    <p class="mb-0 small"><span class="text-muted">Chẩn đoán:</span> <strong>${not empty invoice.diagnosis ? invoice.diagnosis : 'Khám mắt tổng quát'}</strong></p>
                                </div>
                            </div>
                        </div>

                        <!-- Items Table -->
                        <div class="table-responsive mb-3">
                            <table class="table table-bordered align-middle mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th class="text-center" width="5%">STT</th>
                                        <th>Nội dung / Dịch vụ</th>
                                        <th class="text-center" width="10%">SL</th>
                                        <th class="text-end" width="20%">Đơn giá</th>
                                        <th class="text-end" width="20%">Thành tiền</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty invoice.items}">
                                            <c:forEach var="it" items="${invoice.items}">
                                                <tr>
                                                    <td class="text-center">${it.stt}</td>
                                                    <td>
                                                        <div class="fw-semibold">${it.name}</div>
                                                        <small class="text-muted">${it.type}</small>
                                                    </td>
                                                    <td class="text-center">${it.quantity}</td>
                                                    <td class="text-end">${it.unitPriceFmt}</td>
                                                    <td class="text-end fw-bold">${it.totalPriceFmt}</td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="5" class="text-center py-3 text-muted">Không có dịch vụ / thuốc kê đơn</td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>

                        <!-- Financial Summary -->
                        <div class="row justify-content-end mb-3">
                            <div class="col-md-7 col-lg-6">
                                <div class="d-flex justify-content-between mb-2">
                                    <span class="text-muted">Phí đăng ký khám theo bác sĩ (Tiền cọc):</span>
                                    <span class="fw-bold">${not empty invoice.depositAmountFmt ? invoice.depositAmountFmt : '0 đ'}</span>
                                </div>
                                <c:if test="${not empty invoice.medAmount && invoice.medAmount > 0}">
                                    <div class="d-flex justify-content-between mb-2">
                                        <span class="text-muted"><i class="bi bi-capsule text-primary me-1"></i>Thuốc kê đơn (Phát sinh):</span>
                                        <span class="fw-bold text-primary">+ ${invoice.medAmountFmt}</span>
                                    </div>
                                </c:if>
                                <c:if test="${not empty invoice.procedureAmount && invoice.procedureAmount > 0}">
                                    <div class="d-flex justify-content-between mb-2">
                                        <span class="text-muted"><i class="bi bi-gear-wide text-primary me-1"></i>Cận lâm sàng / Thủ thuật phát sinh:</span>
                                        <span class="fw-bold text-primary">+ ${invoice.procedureAmountFmt}</span>
                                    </div>
                                </c:if>
                                <hr class="my-2">
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <span class="fw-bold fs-6" style="color: #0d9488;">Tổng cộng hóa đơn:</span>
                                    <span class="fw-bold fs-5 text-success">${not empty invoice.totalAmountFmt ? invoice.totalAmountFmt : '0 đ'}</span>
                                </div>
                                <div class="d-flex justify-content-between mb-2">
                                    <span class="text-muted"><i class="bi bi-check2-circle text-success me-1"></i>Tổng tiền đã ghi nhận thu:</span>
                                    <span class="fw-bold text-success">- ${not empty invoice.paidAmountFmt ? invoice.paidAmountFmt : '0 đ'}</span>
                                </div>
                                <div class="d-flex justify-content-between align-items-center pt-2 border-top">
                                    <span class="fw-bold text-dark">Còn lại cần thanh toán:</span>
                                    <c:choose>
                                        <c:when test="${invoice.settled}">
                                            <span class="badge bg-success-subtle text-success border border-success-subtle px-3 py-2 fw-semibold">0 đ (Đã tất toán đủ)</span>
                                        </c:when>
                                        <c:when test="${invoice.balanceDue == 0 && not invoice.collectionBlocked}">
                                            <span class="text-muted">0 đ (Chưa chốt hóa đơn)</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="fw-bold fs-5 text-danger">${invoice.balanceDueFmt}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                        <c:if test="${invoice.collectionBlocked}"><div class="alert alert-warning">Hóa đơn có yêu cầu hoàn tiền hoặc đã hủy/hoàn tiền. Tạm khóa thu thêm để đối chiếu; trạng thái này không có nghĩa đã thanh toán đủ.</div></c:if>
                        <!-- Payment & Close Date Box -->
                        <div class="p-3 border rounded-3 bg-light mb-4">
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                <span class="small text-muted">Phương thức thanh toán: <strong>${not empty invoice.paymentMethod ? invoice.paymentMethod : 'Chưa thanh toán'}</strong></span>
                                <span class="small text-muted">Ngày hoàn tất: <strong>${not empty invoice.closeDate ? invoice.closeDate : 'Chưa chốt hóa đơn'}</strong></span>
                            </div>
                        </div>

                        <!-- Notice Footer -->
                        <div class="text-center mt-3 pt-2">
                            <p class="fw-bold mb-1 text-muted small">Cảm ơn quý khách đã tin tưởng VisionCare Clinic!</p>
                            <p class="text-muted small mb-0" style="font-size: 0.8rem;">Lưu ý: Hóa đơn điện tử có giá trị lưu hành nội bộ và làm căn cứ đối soát, bảo hành, hoàn phí theo quy định của phòng khám.</p>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </section>

</main>

<%-- Include Footer --%>
<jsp:include page="/views/common/footer.jsp" />