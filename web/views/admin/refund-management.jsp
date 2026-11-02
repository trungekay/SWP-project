<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Yêu cầu Hoàn tiền - VisionCare</title>
    <!-- Fonts & Icons -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Admin Base CSS -->
    <jsp:include page="/views/admin/layout/admin-css.jsp" />
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #f8fafc;
            color: #1e293b;
        }
        .main-wrapper {
            margin-left: 260px;
            transition: all 0.3s;
        }
        @media (max-width: 991px) {
            .main-wrapper {
                margin-left: 0;
            }
        }
        .stat-card {
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 20px;
            background-color: #ffffff;
            box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.05);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .stat-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }
        .stat-icon-wrapper {
            width: 48px;
            height: 48px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
        }
        .text-teal { color: #0d9488 !important; }
        .bg-teal { background-color: #0d9488 !important; }
        .btn-teal {
            background-color: #0d9488;
            color: #ffffff;
            border: none;
        }
        .btn-teal:hover {
            background-color: #0f766e;
            color: #ffffff;
        }
        .content-card {
            background: #ffffff;
            border-radius: 12px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.05);
            overflow: hidden;
        }
        .filter-tab {
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 500;
            font-size: 0.875rem;
            text-decoration: none;
            color: #64748b;
            background: #f1f5f9;
            transition: all 0.2s;
        }
        .filter-tab.active {
            background: #0d9488;
            color: #ffffff;
        }
        .filter-tab:hover:not(.active) {
            background: #e2e8f0;
            color: #334155;
        }
        .custom-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            font-family: 'Inter', sans-serif;
        }
        .custom-table th {
            background-color: #f8fafc;
            color: #64748b;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 14px 20px;
            border-bottom: 1px solid #e2e8f0;
            white-space: nowrap;
        }
        .custom-table td {
            padding: 14px 20px;
            vertical-align: middle;
            border-bottom: 1px solid #f1f5f9;
            font-size: 14px;
            color: #334155;
            font-weight: 400;
        }
        .custom-table tbody tr {
            transition: background-color 0.15s ease;
        }
        .custom-table tbody tr:hover {
            background-color: #f8fafc;
        }
        .refund-code {
            color: #0d9488;
            font-weight: 600;
            font-size: 14px;
        }
        .invoice-link {
            color: #334155;
            font-weight: 500;
            text-decoration: none;
            font-size: 14px;
            transition: color 0.2s;
        }
        .invoice-link:hover {
            color: #0d9488;
            text-decoration: underline;
        }
        .appt-subtle-badge {
            font-size: 11px;
            padding: 2px 7px;
            border-radius: 4px;
            background-color: #fef3c7;
            color: #92400e;
            border: 1px solid #fde68a;
            font-weight: 500;
            margin-left: 6px;
            display: inline-block;
        }
        .patient-name {
            color: #1e293b;
            font-weight: 500;
            font-size: 14px;
        }
        .badge-status {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            white-space: nowrap;
        }
        .badge-pending {
            background-color: #fef3c7;
            color: #92400e;
        }
        .badge-approved {
            background-color: #dcfce7;
            color: #166534;
        }
        .badge-rejected {
            background-color: #fee2e2;
            color: #991b1b;
        }
        .action-icon-btn {
            width: 32px;
            height: 32px;
            border-radius: 6px;
            border: 1px solid #e2e8f0;
            background: #ffffff;
            color: #64748b;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s ease;
            cursor: pointer;
            font-size: 15px;
        }
        .action-icon-btn:hover {
            border-color: #0d9488;
            color: #0d9488;
            background: #f0fdfa;
        }
        /* Detail Table & Card (Kiểu theo hàng) */
        .custom-detail-card {
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            overflow: hidden;
            background: #ffffff;
        }
        .custom-detail-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            margin: 0;
        }
        .custom-detail-table tr {
            border-bottom: 1px solid #f1f5f9;
            transition: background-color 0.15s ease;
        }
        .custom-detail-table tr:last-child {
            border-bottom: none;
        }
        .custom-detail-table tr:hover {
            background-color: #fafbfc;
        }
        .custom-detail-table .detail-label {
            width: 30%;
            padding: 13px 18px;
            font-size: 13px;
            font-weight: 500;
            color: #64748b;
            background-color: #f8fafc;
            border-right: 1px solid #f1f5f9;
            vertical-align: middle;
            white-space: nowrap;
        }
        .custom-detail-table .detail-value {
            padding: 13px 18px;
            font-size: 14px;
            color: #1e293b;
            font-weight: 400;
            vertical-align: middle;
        }
    </style>
</head>
<body>

    <!-- Sidebar Include -->
    <jsp:include page="/views/director/layout/director-sidebar.jsp">
        <jsp:param name="activeNav" value="refunds" />
    </jsp:include>

    <!-- Main Content -->
    <main class="main-wrapper">
        
        <!-- Header Include -->
        <jsp:include page="/views/admin/layout/admin-header.jsp" />

        <div class="page-content bg-light p-4 pb-5">
            <!-- Breadcrumbs & Header -->
            <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
                <div>
                    <h3 class="fw-bold mb-1" style="color: #0f172a;"><i class="bi bi-cash-coin me-2 text-teal"></i>Quản lý Yêu cầu Hoàn tiền</h3>
                    <p class="text-muted small mb-0">Theo dõi, duyệt yêu cầu hoàn tiền từ bệnh nhân và nhân viên</p>
                </div>

            </div>

            <!-- Flash Alerts -->
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i>${successMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>${errorMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <!-- Stats Overview Cards -->
            <div class="row g-3 mb-4">
                <div class="col-md-3 col-sm-6">
                    <div class="stat-card">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <span class="text-muted small fw-medium">Tổng yêu cầu</span>
                                <h4 class="fw-bold text-dark mt-1 mb-0">${stats.total}</h4>
                            </div>
                            <div class="stat-icon-wrapper" style="background-color: #f1f5f9; color: #475569;">
                                <i class="bi bi-collection"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6">
                    <div class="stat-card">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <span class="text-muted small fw-medium">Chờ duyệt</span>
                                <h4 class="fw-bold text-warning mt-1 mb-0">${stats.pending}</h4>
                            </div>
                            <div class="stat-icon-wrapper" style="background-color: #fef3c7; color: #d97706;">
                                <i class="bi bi-hourglass-split"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6">
                    <div class="stat-card">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <span class="text-muted small fw-medium">Đã duyệt hoàn tiền</span>
                                <h4 class="fw-bold text-success mt-1 mb-0">${stats.approved}</h4>
                            </div>
                            <div class="stat-icon-wrapper" style="background-color: #dcfce7; color: #16a34a;">
                                <i class="bi bi-check-circle"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6">
                    <div class="stat-card">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <span class="text-muted small fw-medium">Đã từ chối</span>
                                <h4 class="fw-bold text-danger mt-1 mb-0">${stats.rejected}</h4>
                            </div>
                            <div class="stat-icon-wrapper" style="background-color: #fee2e2; color: #dc2626;">
                                <i class="bi bi-x-circle"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Content Card -->
            <div class="content-card p-4">
                <!-- Filters & Search -->
                <div class="d-flex justify-content-between align-items-center flex-wrap gap-3 mb-4 pb-3 border-bottom">
                    <div class="d-flex gap-2 flex-wrap">
                        <a href="${pageContext.request.contextPath}/director/refunds?status=all" class="filter-tab ${currentStatus == 'all' ? 'active' : ''}">Tất cả</a>
                        <a href="${pageContext.request.contextPath}/director/refunds?status=Pending" class="filter-tab ${currentStatus == 'Pending' ? 'active' : ''}">Chờ duyệt (${stats.pending})</a>
                        <a href="${pageContext.request.contextPath}/director/refunds?status=Approved" class="filter-tab ${currentStatus == 'Approved' ? 'active' : ''}">Đã xác nhận (${stats.approved})</a>
                        <a href="${pageContext.request.contextPath}/director/refunds?status=Rejected" class="filter-tab ${currentStatus == 'Rejected' ? 'active' : ''}">Đã từ chối (${stats.rejected})</a>
                    </div>
                    <div class="text-muted small">
                        Hiển thị <strong>${refunds.size()}</strong> yêu cầu
                    </div>
                </div>

                <!-- Table -->
                <div class="table-responsive">
                    <table class="custom-table mb-0">
                        <thead>
                            <tr>
                                <th>Mã yêu cầu</th>
                                <th>Mã hóa đơn</th>
                                <th>Tên bệnh nhân</th>
                                <th class="text-center">Trạng thái</th>
                                <th class="text-center">Chi tiết</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty refunds}">
                                    <c:forEach var="rf" items="${refunds}">
                                        <tr>
                                            <td>
                                                <span class="refund-code">${rf.formattedId}</span>
                                            </td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/staff/invoices/detail?id=${rf.invoiceId}" class="invoice-link" title="Xem chi tiết hóa đơn">
                                                    ${rf.formattedInvoiceId}
                                                </a>
                                                <c:if test="${not empty rf.formattedApptId && rf.formattedApptId != 'N/A'}">
                                                    <span class="appt-subtle-badge" title="Lịch hẹn liên kết">
                                                        <i class="bi bi-calendar-x me-1"></i>${rf.formattedApptId}
                                                    </span>
                                                </c:if>
                                            </td>
                                            <td>
                                                <span class="patient-name">${rf.patientName}</span>
                                            </td>
                                            <td class="text-center">
                                                <span class="badge-status ${rf.status == 'Pending' ? 'badge-pending' : (rf.status == 'Approved' ? 'badge-approved' : 'badge-rejected')}">
                                                    <i class="bi bi-circle-fill" style="font-size: 6px;"></i>
                                                    ${rf.statusVn}
                                                </span>
                                            </td>
                                            <td class="text-center">
                                                <button type="button" class="action-icon-btn refund-detail-btn"
                                                        data-id="${rf.id}"
                                                        data-code="${rf.formattedId}"
                                                        data-invoice-id="${rf.invoiceId}"
                                                        data-invoice-code="${rf.formattedInvoiceId}"
                                                        data-appt-code="${rf.formattedApptId}"
                                                        data-patient-name="<c:out value="${rf.patientName}"/>"
                                                        data-patient-phone="<c:out value="${rf.patientPhone}"/>"
                                                        data-amount="${rf.amountFmt}"
                                                        data-reason="<c:out value="${rf.reason}"/>"
                                                        data-status="${rf.status}"
                                                        data-status-vn="${rf.statusVn}"
                                                        data-badge-class="${rf.badgeClass}"
                                                        data-created-at="${rf.createdAt}"
                                                        data-updated-at="${rf.updatedAt}"
                                                        data-creator="<c:out value="${rf.creatorName}"/>"
                                                        data-approver="<c:out value="${rf.approverName}"/>"
                                                        onclick="showRefundDetailModal(this)"
                                                        title="Xem chi tiết">
                                                    <i class="bi bi-eye"></i>
                                                </button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="5" class="text-center py-5 text-muted">
                                            <i class="bi bi-inbox fs-1 d-block mb-2 text-secondary"></i>
                                            Chưa có yêu cầu hoàn tiền nào trong danh mục này.
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </main>

    <!-- Modal 0: Chi tiết yêu cầu hoàn tiền (Detail Modal) -->
    <div class="modal fade" id="refundDetailModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content" style="border-radius: 14px; border: none; box-shadow: 0 10px 25px rgba(0,0,0,0.1);">
                <div class="modal-header border-bottom py-3 px-4">
                    <div class="d-flex align-items-center gap-2">
                        <div class="stat-icon-wrapper bg-teal text-white" style="width: 36px; height: 36px; font-size: 18px; border-radius: 8px;">
                            <i class="bi bi-receipt-cutoff"></i>
                        </div>
                        <div>
                            <h5 class="modal-title fw-bold mb-0 text-dark">
                                Chi tiết yêu cầu hoàn tiền <span id="detailModalRefundCode" class="text-teal ms-1">#REF-000</span>
                            </h5>
                            <small class="text-muted">Xem thông tin chi tiết và tiến trình xử lý yêu cầu hoàn tiền</small>
                        </div>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="custom-detail-card">
                        <table class="custom-detail-table mb-0">
                            <tbody>
                                <tr>
                                    <td class="detail-label"><i class="bi bi-hash me-2 text-teal"></i>Mã yêu cầu</td>
                                    <td class="detail-value">
                                        <span id="detailModalRefundCodeVal" class="refund-code">#REF-000</span>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="detail-label"><i class="bi bi-receipt me-2 text-teal"></i>Mã hóa đơn liên quan</td>
                                    <td class="detail-value">
                                        <div class="d-flex align-items-center gap-2">
                                            <a id="detailModalInvoiceLink" href="#" class="invoice-link" title="Xem hóa đơn chi tiết">#INV-00000</a>
                                            <span id="detailModalApptBadge"></span>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="detail-label"><i class="bi bi-person me-2 text-teal"></i>Bệnh nhân</td>
                                    <td class="detail-value">
                                        <div class="d-flex align-items-center gap-3">
                                            <span id="detailModalPatientName" class="patient-name">--</span>
                                            <span id="detailModalPatientPhone" class="text-muted small"><i class="bi bi-telephone me-1"></i>--</span>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="detail-label"><i class="bi bi-clock-history me-2 text-teal"></i>Thời gian gửi</td>
                                    <td class="detail-value" id="detailModalCreatedAt">--</td>
                                </tr>
                                <tr>
                                    <td class="detail-label"><i class="bi bi-cash-stack me-2 text-teal"></i>Giá tiền hoàn</td>
                                    <td class="detail-value">
                                        <span id="detailModalAmount" class="fw-semibold text-danger">0 đ</span>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="detail-label"><i class="bi bi-chat-left-text me-2 text-teal"></i>Lý do hủy</td>
                                    <td class="detail-value" id="detailModalReason" style="white-space: pre-wrap; line-height: 1.5;">--</td>
                                </tr>
                                <tr>
                                    <td class="detail-label"><i class="bi bi-shield-check me-2 text-teal"></i>Tình trạng xét duyệt</td>
                                    <td class="detail-value" id="detailModalStatusSection">
                                        <!-- Injected dynamically via JS -->
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div class="modal-footer border-top py-3 px-4 justify-content-between">
                    <button type="button" class="btn btn-light px-4" data-bs-dismiss="modal">Đóng</button>
                    <div id="detailModalActions" class="d-flex gap-2">
                        <!-- Action buttons injected via JS if status is Pending -->
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal 2: Duyệt hoàn tiền -->
    <div class="modal fade" id="approveModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content" style="border-radius: 12px; border: none;">
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold text-success"><i class="bi bi-check-circle me-2"></i>Xác nhận duyệt hoàn tiền</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form action="${pageContext.request.contextPath}/director/refunds" method="POST">
                    <input type="hidden" name="action" value="approve">
                    <input type="hidden" name="refundId" id="approveRefundId">
                    <div class="modal-body p-4">
                        <p class="mb-2">Bạn có chắc chắn muốn duyệt hoàn tiền cho yêu cầu <strong id="approveRefundCode" class="text-dark">#REF-000</strong>?</p>
                        <div class="p-3 bg-light rounded-3 mb-0 small">
                            <div class="d-flex justify-content-between mb-1">
                                <span class="text-muted">Bệnh nhân:</span>
                                <strong id="approvePatientName" class="text-dark">--</strong>
                            </div>
                            <div class="d-flex justify-content-between">
                                <span class="text-muted">Số tiền hoàn lại:</span>
                                <strong id="approveAmount" class="text-danger fs-6">-- đ</strong>
                            </div>
                        </div>
                        <div class="alert alert-info py-2 px-3 mt-3 mb-0 small border-0" style="background-color: #f0fdfa; color: #0f766e;">
                            <i class="bi bi-info-circle-fill me-1"></i>
                            <strong>Tự động đồng bộ hệ thống:</strong> Sau khi duyệt yêu cầu:
                            <ul class="mb-0 ps-3 mt-1">
                                <li>Yêu cầu hoàn tiền được chuyển sang trạng thái <strong>Đã xác nhận</strong></li>
                                <li>Hóa đơn viện phí được đánh dấu <strong>Đã hoàn tiền (Refunded)</strong></li>
                                <li>Trạng thái lịch hẹn của bệnh nhân sẽ chuyển sang <strong>Đã hủy (Canceled)</strong></li>
                                <li>Lịch làm việc của bác sĩ sẽ được giải phóng về trạng thái <strong>Trống (Available)</strong></li>
                            </ul>
                        </div>
                    </div>
                    <div class="modal-footer border-0 pt-0">
                        <button type="button" class="btn btn-light" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-success">Xác nhận duyệt hoàn tiền</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Modal 3: Từ chối hoàn tiền -->
    <div class="modal fade" id="rejectModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content" style="border-radius: 12px; border: none;">
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold text-danger"><i class="bi bi-x-circle me-2"></i>Từ chối yêu cầu hoàn tiền</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form action="${pageContext.request.contextPath}/director/refunds" method="POST">
                    <input type="hidden" name="action" value="reject">
                    <input type="hidden" name="refundId" id="rejectRefundId">
                    <div class="modal-body p-4">
                        <p class="mb-3">Từ chối yêu cầu <strong id="rejectRefundCode" class="text-dark">#REF-000</strong> của bệnh nhân <strong id="rejectPatientName" class="text-dark">--</strong>.</p>
                        <div class="mb-0">
                            <label class="form-label small fw-bold">Lý do từ chối (Ghi chú)</label>
                            <textarea class="form-control" name="rejectNote" rows="3" placeholder="Nhập lý do không chấp nhận hoàn tiền (ví dụ: đã quá thời hạn hoặc đã tham gia khám)..."></textarea>
                        </div>
                        <div class="alert alert-warning py-2 px-3 mt-3 mb-0 small border-0">
                            <i class="bi bi-exclamation-triangle-fill me-1"></i>
                            Khi từ chối yêu cầu, lịch hẹn của bệnh nhân sẽ được khôi phục về trạng thái <strong>Đã xác nhận (Confirmed)</strong> và lịch bác sĩ vẫn giữ trạng thái đã đặt (Booked).
                        </div>
                    </div>
                    <div class="modal-footer border-0 pt-0">
                        <button type="button" class="btn btn-light" data-bs-dismiss="modal">Đóng</button>
                        <button type="submit" class="btn btn-danger">Xác nhận từ chối</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Bootstrap Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let currentDetailData = null;

        function showRefundDetailModal(btn) {
            const data = {
                id: btn.getAttribute('data-id'),
                code: btn.getAttribute('data-code'),
                invoiceId: btn.getAttribute('data-invoice-id'),
                invoiceCode: btn.getAttribute('data-invoice-code'),
                apptCode: btn.getAttribute('data-appt-code'),
                patientName: btn.getAttribute('data-patient-name'),
                patientPhone: btn.getAttribute('data-patient-phone'),
                amount: btn.getAttribute('data-amount'),
                reason: btn.getAttribute('data-reason'),
                status: btn.getAttribute('data-status'),
                statusVn: btn.getAttribute('data-status-vn'),
                badgeClass: btn.getAttribute('data-badge-class'),
                createdAt: btn.getAttribute('data-created-at'),
                updatedAt: btn.getAttribute('data-updated-at'),
                creator: btn.getAttribute('data-creator'),
                approver: btn.getAttribute('data-approver')
            };
            currentDetailData = data;

            document.getElementById('detailModalRefundCode').innerText = data.code;
            const codeValEl = document.getElementById('detailModalRefundCodeVal');
            if (codeValEl) codeValEl.innerText = data.code;

            // Invoice link
            const invLink = document.getElementById('detailModalInvoiceLink');
            invLink.innerText = data.invoiceCode;
            invLink.href = '${pageContext.request.contextPath}/staff/invoices/detail?id=' + data.invoiceId;

            // Appointment badge
            const apptContainer = document.getElementById('detailModalApptBadge');
            if (data.apptCode && data.apptCode !== 'N/A') {
                apptContainer.innerHTML = '<span class="appt-subtle-badge ms-1" title="Lịch hẹn liên kết"><i class="bi bi-calendar-x me-1"></i>' + data.apptCode + '</span>';
            } else {
                apptContainer.innerHTML = '';
            }

            document.getElementById('detailModalPatientName').innerText = data.patientName;
            document.getElementById('detailModalPatientPhone').innerHTML = '<i class="bi bi-telephone me-1"></i>' + (data.patientPhone || 'Chưa cập nhật');
            document.getElementById('detailModalCreatedAt').innerText = data.createdAt || 'N/A';
            document.getElementById('detailModalAmount').innerText = data.amount;
            document.getElementById('detailModalReason').innerText = data.reason || 'Không có lý do';

            // Tình trạng xét duyệt (Duyệt hay không)
            const statusSection = document.getElementById('detailModalStatusSection');
            const actionsSection = document.getElementById('detailModalActions');

            if (data.status === 'Pending') {
                statusSection.innerHTML = 
                    '<div class="d-flex align-items-center gap-2 flex-wrap">' +
                        '<span class="badge-status badge-pending">' +
                            '<i class="bi bi-circle-fill" style="font-size: 6px;"></i> Chưa duyệt (Chờ duyệt)' +
                        '</span>' +
                        '<span class="text-muted small">Yêu cầu hoàn tiền đang chờ nhân viên kiểm tra và xử lý.</span>' +
                    '</div>';
                actionsSection.innerHTML = 
                    '<button type="button" class="btn btn-outline-danger px-3" onclick="triggerRejectFromDetail()">' +
                        '<i class="bi bi-x-lg me-1"></i>Từ chối' +
                    '</button>' +
                    '<button type="button" class="btn btn-success px-3" style="background-color: #0d9488; border-color: #0d9488;" onclick="triggerApproveFromDetail()">' +
                        '<i class="bi bi-check-lg me-1"></i>Duyệt hoàn tiền' +
                    '</button>';
            } else if (data.status === 'Approved' || data.status === 'Đã hoàn tiền' || data.status === 'Đã xác nhận') {
                statusSection.innerHTML = 
                    '<div class="d-flex align-items-center gap-2 flex-wrap">' +
                        '<span class="badge-status badge-approved">' +
                            '<i class="bi bi-circle-fill" style="font-size: 6px;"></i> Đã xác nhận' +
                        '</span>' +
                        '<span class="text-muted small">Người xác nhận: <strong class="text-dark">' + (data.approver || 'Ban quản trị') + '</strong>' +
                        (data.updatedAt ? ' | Cập nhật: ' + data.updatedAt : '') + '</span>' +
                    '</div>';
                actionsSection.innerHTML = '';
            } else if (data.status === 'Rejected') {
                statusSection.innerHTML = 
                    '<div class="d-flex align-items-center gap-2 flex-wrap">' +
                        '<span class="badge-status badge-rejected">' +
                            '<i class="bi bi-circle-fill" style="font-size: 6px;"></i> Đã từ chối' +
                        '</span>' +
                        '<span class="text-muted small">Người xử lý: <strong class="text-dark">' + (data.approver || 'Ban quản trị') + '</strong>' +
                        (data.updatedAt ? ' | Cập nhật: ' + data.updatedAt : '') + '</span>' +
                    '</div>';
                actionsSection.innerHTML = '';
            }

            const modal = new bootstrap.Modal(document.getElementById('refundDetailModal'));
            modal.show();
        }

        function triggerApproveFromDetail() {
            if (!currentDetailData) return;
            const detailModalEl = document.getElementById('refundDetailModal');
            const detailModal = bootstrap.Modal.getInstance(detailModalEl);
            if (detailModal) detailModal.hide();

            setTimeout(function() {
                openApproveModal(currentDetailData.id, currentDetailData.code, currentDetailData.patientName, currentDetailData.amount);
            }, 300);
        }

        function triggerRejectFromDetail() {
            if (!currentDetailData) return;
            const detailModalEl = document.getElementById('refundDetailModal');
            const detailModal = bootstrap.Modal.getInstance(detailModalEl);
            if (detailModal) detailModal.hide();

            setTimeout(function() {
                openRejectModal(currentDetailData.id, currentDetailData.code, currentDetailData.patientName);
            }, 300);
        }

        function openApproveModal(id, code, patientName, amount) {
            document.getElementById('approveRefundId').value = id;
            document.getElementById('approveRefundCode').innerText = code;
            document.getElementById('approvePatientName').innerText = patientName;
            document.getElementById('approveAmount').innerText = amount;
            const modal = new bootstrap.Modal(document.getElementById('approveModal'));
            modal.show();
        }

        function openRejectModal(id, code, patientName) {
            document.getElementById('rejectRefundId').value = id;
            document.getElementById('rejectRefundCode').innerText = code;
            document.getElementById('rejectPatientName').innerText = patientName;
            const modal = new bootstrap.Modal(document.getElementById('rejectModal'));
            modal.show();
        }
    </script>
</body>
</html>
