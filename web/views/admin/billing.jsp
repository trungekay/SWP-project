<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hóa đơn & Thanh toán - VisionCare Admin</title>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <!-- Admin Layout CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/admin-layout.css" rel="stylesheet">

    <style>
        :root {
            --primary: #0d9488;
            --primary-hover: #0f766e;
            --primary-light: #f0fdfa;
        }
        body {
            font-family: 'Inter', sans-serif;
            background-color: #f8fafc;
            color: #1e293b;
        }
        .page-content {
            padding: 30px;
        }
        .billing-stat-card {
            background: #ffffff;
            border-radius: 12px;
            padding: 20px 24px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
            display: flex;
            align-items: center;
            justify-content: space-between;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .billing-stat-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.06);
        }
        .billing-stat-card.featured-stat {
            border: 2px solid #0d9488;
            background: linear-gradient(135deg, #ffffff 0%, #f0fdfa 100%);
            box-shadow: 0 4px 15px rgba(13, 148, 136, 0.08);
        }
        .stat-icon-wrapper {
            width: 48px;
            height: 48px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
        }
        .stat-revenue { background-color: #ecfdf5; color: #059669; }
        .stat-total { background-color: #eff6ff; color: #2563eb; }
        .stat-paid { background-color: #f0fdf4; color: #16a34a; }
        .stat-unpaid { background-color: #fffbeb; color: #d97706; }
        .stat-refund { background-color: #fef2f2; color: #dc2626; }

        .content-card {
            background: #ffffff;
            border-radius: 12px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
            overflow: hidden;
        }
        .custom-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 0;
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
            padding: 16px 20px;
            vertical-align: middle;
            border-bottom: 1px solid #f1f5f9;
            font-size: 14px;
            color: #334155;
        }
        .custom-table tbody tr:hover {
            background-color: #f8fafc;
        }
        .badge-status {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        .badge-paid {
            background-color: #dcfce7;
            color: #166534;
        }
        .badge-unpaid {
            background-color: #fef3c7;
            color: #92400e;
        }
        .badge-refunded {
            background-color: #fee2e2;
            color: #991b1b;
        }
        .btn-teal {
            background-color: #0d9488;
            color: white;
            border: none;
            font-weight: 500;
        }
        .btn-teal:hover {
            background-color: #0f766e;
            color: white;
        }
        .action-icon-btn {
            width: 32px;
            height: 32px;
            border-radius: 6px;
            border: 1px solid #e2e8f0;
            background: #fff;
            color: #64748b;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
            cursor: pointer;
        }
        .action-icon-btn:hover {
            border-color: #0d9488;
            color: #0d9488;
            background: #f0fdfa;
        }
        .invoice-print-section {
            border-bottom: 2px dashed #e2e8f0;
            padding-bottom: 20px;
            margin-bottom: 24px;
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
            }
            .modal {
                position: static !important;
                display: block !important;
                padding: 0 !important;
            }
            .modal-dialog {
                max-width: 100% !important;
                margin: 0 !important;
            }
            .modal-content {
                border: none !important;
                box-shadow: none !important;
            }
            .modal-header, .modal-footer, .btn-close, .sidebar, .admin-sidebar, .header-wrapper, nav, .btn {
                display: none !important;
            }
        }
    </style>
</head>
<body>

    <!-- Sidebar Include -->
    <jsp:include page="/views/admin/layout/admin-sidebar.jsp">
        <jsp:param name="activeNav" value="billing" />
    </jsp:include>

    <!-- Main Content -->
    <main class="main-wrapper">
        
        <!-- Header Include -->
        <jsp:include page="/views/admin/layout/admin-header.jsp" />

        <div class="page-content bg-light pb-5">
            <!-- Breadcrumbs & Header -->
            <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
                <div>
                    <h3 class="fw-bold mb-1" style="color: #0f172a;">Hóa đơn & Thanh toán</h3>
                    <p class="text-muted small mb-0">Quản lý hóa đơn khám bệnh, theo dõi doanh thu và tiến trình thanh toán</p>
                </div>
            </div>

            <!-- Alerts -->
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i>${successMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>${errorMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <!-- Stats Overview Cards -->
            <div class="row g-3 mb-4">
                <!-- Card 1: Doanh thu theo mốc được chọn (Featured) -->
                <div class="col-xl-3 col-md-6">
                    <div class="billing-stat-card featured-stat">
                        <div class="w-100">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <span class="text-muted small fw-bold text-uppercase" style="font-size: 11px;">Doanh thu (Đã thu)</span>
                                <span class="badge rounded-pill" style="background-color: #ccfbf1; color: #0f766e; font-size: 11px; max-width: 150px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${periodLabel}">
                                    ${periodLabel}
                                </span>
                            </div>
                            <h4 class="fw-bold text-success my-1">${stats.periodRevenueFmt}</h4>
                            <div class="small text-muted mt-1">
                                <i class="bi bi-receipt me-1"></i><strong>${stats.periodPaidCount}</strong> hóa đơn đã thu
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Card 2: Hóa đơn đã thanh toán trong kỳ -->
                <div class="col-xl-3 col-md-6">
                    <div class="billing-stat-card">
                        <div>
                            <span class="text-muted small fw-medium">Đã thanh toán</span>
                            <h4 class="fw-bold mt-1 mb-0 text-success">${stats.periodPaidCount}</h4>
                            <small class="text-muted"><i class="bi bi-check2-circle me-1"></i>Hoàn tất trong kỳ</small>
                        </div>
                        <div class="stat-icon-wrapper stat-paid">
                            <i class="bi bi-check-circle"></i>
                        </div>
                    </div>
                </div>

                <!-- Card 3: Hóa đơn chờ xử lý trong kỳ -->
                <div class="col-xl-3 col-md-6">
                    <div class="billing-stat-card">
                        <div>
                            <span class="text-muted small fw-medium">Chờ xử lý</span>
                            <h4 class="fw-bold text-warning mt-1 mb-0">${stats.periodUnpaidCount}</h4>
                            <small class="text-muted"><i class="bi bi-hourglass-split me-1"></i>Chưa trả / Chờ cọc</small>
                        </div>
                        <div class="stat-icon-wrapper stat-unpaid">
                            <i class="bi bi-hourglass-split"></i>
                        </div>
                    </div>
                </div>

                <!-- Card 4: Hóa đơn đã hoàn tiền trong kỳ -->
                <div class="col-xl-3 col-md-6">
                    <div class="billing-stat-card">
                        <div>
                            <span class="text-muted small fw-medium">Đã hoàn tiền</span>
                            <h4 class="fw-bold text-danger mt-1 mb-0">${stats.periodRefundedCount}</h4>
                            <small class="text-muted"><i class="bi bi-arrow-counterclockwise me-1"></i>Yêu cầu hoàn trả</small>
                        </div>
                        <div class="stat-icon-wrapper stat-refund">
                            <i class="bi bi-arrow-counterclockwise"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Content Card with Filters & Table -->
            <div class="content-card">
                <!-- Filter bar -->
                <div class="p-3 border-bottom bg-white">
                    <form method="GET" action="${pageContext.request.contextPath}/admin/billing" id="billingFilterForm" onsubmit="return validateDateRange()">
                        <div class="row g-2 align-items-center">
                            <!-- Search -->
                            <div class="col-lg-4 col-md-6">
                                <div class="input-group">
                                    <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-search"></i></span>
                                    <input type="text" class="form-control border-start-0" name="search" value="${search}" 
                                           placeholder="Tìm theo Mã HĐ, Tên, SĐT (Nhấn Enter)...">
                                </div>
                            </div>

                            <!-- Status -->
                            <div class="col-lg-3 col-md-3">
                                <select class="form-select" name="status" onchange="document.getElementById('billingFilterForm').submit()">
                                    <option value="all" ${status == 'all' ? 'selected' : ''}>Tất cả trạng thái</option>
                                    <option value="Paid" ${status == 'Paid' ? 'selected' : ''}>Đã thanh toán</option>
                                    <option value="Unpaid" ${status == 'Unpaid' ? 'selected' : ''}>Chưa thanh toán</option>
                                    <option value="Pending_Deposit" ${status == 'Pending_Deposit' ? 'selected' : ''}>Chờ đặt cọc</option>
                                    <option value="Refunded" ${status == 'Refunded' ? 'selected' : ''}>Đã hoàn tiền</option>
                                </select>
                            </div>

                            <!-- Time Range Preset Selector -->
                            <div class="col-lg-3 col-md-3">
                                <select class="form-select" name="timeRange" id="timeRangeSelect" onchange="handleTimeRangeChange()">
                                    <option value="today" ${timeRange == 'today' ? 'selected' : ''}>⚡ Hôm nay</option>
                                    <option value="by_month" ${timeRange == 'by_month' ? 'selected' : ''}>🗓️ Theo tháng</option>
                                    <option value="by_quarter" ${timeRange == 'by_quarter' ? 'selected' : ''}>📊 Theo quý</option>
                                    <option value="custom" ${timeRange == 'custom' ? 'selected' : ''}>⚙️ Tự do (Khoảng ngày)</option>
                                    <option value="all" ${timeRange == 'all' ? 'selected' : ''}>📅 Toàn thời gian</option>
                                </select>
                            </div>

                            <!-- Result counter badge and Reset button -->
                            <div class="col-lg-2 col-md-12 d-flex align-items-center justify-content-end gap-2">
                                <span class="badge bg-light text-secondary border px-3 py-2 text-nowrap">
                                    <i class="bi bi-list-check me-1"></i><strong>${invoices.size()}</strong> HĐ
                                </span>
                                <a href="${pageContext.request.contextPath}/admin/billing" class="btn btn-outline-secondary" title="Đặt lại bộ lọc"><i class="bi bi-arrow-clockwise"></i></a>
                            </div>
                        </div>

                        <!-- Sub-filter row: dynamically shown for Month, Quarter, or Custom Dates -->
                        <div id="subFilterRow" class="mt-3 pt-3 border-top" style="display: none;">
                            <!-- Month Selection (1-12) -->
                            <div id="monthControls" style="display: none;">
                                <div class="d-flex align-items-center flex-wrap gap-2">
                                    <span class="small fw-semibold text-muted"><i class="bi bi-calendar-month me-1 text-teal"></i>Chọn tháng:</span>
                                    <select class="form-select form-select-sm w-auto" name="selectedMonth">
                                        <c:forEach var="m" begin="1" end="12">
                                            <option value="${m}" ${selectedMonth == m ? 'selected' : ''}>Tháng ${m}</option>
                                        </c:forEach>
                                    </select>
                                    <span class="small fw-semibold text-muted ms-2">Năm:</span>
                                    <select class="form-select form-select-sm w-auto" name="selectedYear">
                                        <c:forEach var="y" begin="${currentYear - 2}" end="${currentYear + 1}">
                                            <option value="${y}" ${selectedYear == y ? 'selected' : ''}>Năm ${y}</option>
                                        </c:forEach>
                                    </select>
                                    <button type="submit" class="btn btn-sm btn-teal ms-2 px-3"><i class="bi bi-check2 me-1"></i>Áp dụng</button>
                                </div>
                            </div>

                            <!-- Quarter Selection (1-4) -->
                            <div id="quarterControls" style="display: none;">
                                <div class="d-flex align-items-center flex-wrap gap-2">
                                    <span class="small fw-semibold text-muted"><i class="bi bi-pie-chart me-1 text-teal"></i>Chọn quý:</span>
                                    <select class="form-select form-select-sm w-auto" name="selectedQuarter">
                                        <option value="1" ${selectedQuarter == 1 ? 'selected' : ''}>Quý 1 (Tháng 1 - Tháng 3)</option>
                                        <option value="2" ${selectedQuarter == 2 ? 'selected' : ''}>Quý 2 (Tháng 4 - Tháng 6)</option>
                                        <option value="3" ${selectedQuarter == 3 ? 'selected' : ''}>Quý 3 (Tháng 7 - Tháng 9)</option>
                                        <option value="4" ${selectedQuarter == 4 ? 'selected' : ''}>Quý 4 (Tháng 10 - Tháng 12)</option>
                                    </select>
                                    <span class="small fw-semibold text-muted ms-2">Năm:</span>
                                    <select class="form-select form-select-sm w-auto" name="selectedYear">
                                        <c:forEach var="y" begin="${currentYear - 2}" end="${currentYear + 1}">
                                            <option value="${y}" ${selectedYear == y ? 'selected' : ''}>Năm ${y}</option>
                                        </c:forEach>
                                    </select>
                                    <button type="submit" class="btn btn-sm btn-teal ms-2 px-3"><i class="bi bi-check2 me-1"></i>Áp dụng</button>
                                </div>
                            </div>

                            <!-- Custom Date Range -->
                            <div id="customDateControls" style="display: none;">
                                <div class="d-flex align-items-center flex-wrap gap-2">
                                    <span class="small fw-semibold text-muted"><i class="bi bi-calendar-range me-1 text-teal"></i>Khoảng ngày tự do:</span>
                                    <div class="input-group input-group-sm w-auto">
                                        <span class="input-group-text bg-light">Từ</span>
                                        <input type="date" class="form-control" name="dateFrom" id="customDateFrom" value="${dateFrom}" onchange="updateDateToMin()">
                                    </div>
                                    <div class="input-group input-group-sm w-auto">
                                        <span class="input-group-text bg-light">Đến</span>
                                        <input type="date" class="form-control" name="dateTo" id="customDateTo" value="${dateTo}">
                                    </div>
                                    <button type="submit" class="btn btn-sm btn-teal ms-2 px-3"><i class="bi bi-check2 me-1"></i>Áp dụng</button>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- Invoices Table -->
                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Mã HĐ</th>
                                <th>Bệnh nhân</th>
                                <th>Bác sĩ</th>
                                <th>Ngày tạo</th>
                                <th class="text-end">Tổng tiền</th>
                                <th>Phương thức</th>
                                <th>Trạng thái</th>
                                <th class="text-center">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty invoices}">
                                    <c:forEach var="inv" items="${invoices}">
                                        <tr>
                                            <td>
                                                <a href="javascript:void(0);" onclick="openInvoiceDetail(${inv.id})" class="fw-bold text-decoration-none" style="color: #0d9488;">
                                                    ${inv.formattedId}
                                                </a>
                                                <div class="text-muted small">Lịch: #APT-${inv.appointmentId}</div>
                                            </td>
                                            <td>
                                                <div class="fw-semibold text-dark">${inv.patientName}</div>
                                                <div class="text-muted small"><i class="bi bi-telephone me-1"></i>${inv.patientPhone}</div>
                                            </td>
                                            <td>
                                                <div class="text-dark small">${inv.doctorName}</div>
                                            </td>
                                            <td>
                                                <span class="small text-muted">${inv.createDate}</span>
                                            </td>
                                            <td class="text-end">
                                                <div class="fw-bold text-dark">${inv.totalAmountFmt}</div>
                                                <c:if test="${inv.balanceDue > 0}">
                                                    <small class="text-danger">Còn nợ: <fmt:formatNumber value="${inv.balanceDue}" pattern="#,###"/> đ</small>
                                                </c:if>
                                            </td>
                                            <td>
                                                <span class="badge bg-light text-dark border">${inv.paymentMethod}</span>
                                            </td>
                                            <td>
                                                <span class="badge-status ${inv.badgeClass}">
                                                    <i class="bi bi-circle-fill" style="font-size: 6px;"></i>
                                                    ${inv.statusVn}
                                                </span>
                                            </td>
                                            <td class="text-center">
                                                <div class="d-inline-flex gap-1">
                                                    <button type="button" class="action-icon-btn" onclick="openInvoiceDetail(${inv.id})" title="Xem chi tiết hóa đơn">
                                                        <i class="bi bi-eye"></i>
                                                    </button>
                                                    <c:if test="${inv.status != 'Paid' && inv.status != 'Refunded'}">
                                                        <button type="button" class="action-icon-btn text-success" onclick="openPaymentModal(${inv.id}, '${inv.formattedId}', ${inv.totalAmount})" title="Xác nhận thanh toán">
                                                            <i class="bi bi-check2-circle"></i>
                                                        </button>
                                                    </c:if>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="8" class="text-center py-5 text-muted">
                                            <i class="bi bi-inbox fs-2 d-block mb-2 text-secondary"></i>
                                            Không tìm thấy hóa đơn nào phù hợp với bộ lọc.
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <!-- Footer count -->
                <div class="p-3 border-top bg-light d-flex justify-content-between align-items-center text-muted small">
                    <span>Hiển thị <strong>${invoices.size()}</strong> hóa đơn</span>
                    <span>Hệ thống quản lý phòng khám VisionCare</span>
                </div>
            </div>
        </div>
    </main>

    <!-- Modal 1: Chi tiết hóa đơn (Invoice Detail) -->
    <div class="modal fade" id="invoiceDetailModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content" style="border-radius: 12px; border: none;">
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold" style="color: #0f172a;"><i class="bi bi-receipt me-2 text-teal"></i>Chi tiết Hóa đơn</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4" id="invoiceDetailBody">
                    <div class="text-center py-4">
                        <div class="spinner-border text-teal" role="status"></div>
                        <p class="mt-2 text-muted small">Đang tải dữ liệu hóa đơn...</p>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-outline-secondary" onclick="printInvoice()"><i class="bi bi-printer me-2"></i>In hóa đơn</button>
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal 2: Xác nhận thanh toán (Confirm Payment) -->
    <div class="modal fade" id="paymentModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content" style="border-radius: 12px; border: none;">
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold" style="color: #059669;"><i class="bi bi-check-circle me-2"></i>Xác nhận thanh toán</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form method="POST" action="${pageContext.request.contextPath}/admin/billing">
                    <input type="hidden" name="action" value="update-status">
                    <input type="hidden" name="invoiceId" id="payModalInvoiceId">
                    <input type="hidden" name="newStatus" value="Paid">

                    <div class="modal-body p-4">
                        <p class="text-muted small mb-3">Xác nhận thu tiền hóa đơn <strong id="payModalInvoiceCode" class="text-dark">#INV-00000</strong></p>
                        
                        <div class="mb-3">
                            <label class="form-label small fw-bold text-dark">Số tiền thực thu (VNĐ)</label>
                            <input type="number" class="form-control" name="amount" id="payModalAmount" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label small fw-bold text-dark">Phương thức thanh toán</label>
                            <select class="form-select" name="paymentMethod" required>
                                <option value="Cash">Tiền mặt (Cash)</option>
                                <option value="VNPay">Cổng VNPay</option>
                                <option value="Bank Transfer">Chuyển khoản ngân hàng</option>
                                <option value="Credit Card">Thẻ tín dụng (POS)</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer border-0 pt-0">
                        <button type="button" class="btn btn-light" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-teal">Xác nhận đã thanh toán</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Bootstrap Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        function getDetailModal() {
            const el = document.getElementById('invoiceDetailModal');
            return el ? (bootstrap.Modal.getInstance(el) || new bootstrap.Modal(el)) : null;
        }
        function getPayModal() {
            const el = document.getElementById('paymentModal');
            return el ? (bootstrap.Modal.getInstance(el) || new bootstrap.Modal(el)) : null;
        }

        function openInvoiceDetail(id) {
            const modal = getDetailModal();
            if (modal) modal.show();
            const body = document.getElementById('invoiceDetailBody');
            if (!body) return;
            body.innerHTML = 
                '<div class="text-center py-4">' +
                    '<div class="spinner-border text-teal" style="color: #0d9488;" role="status"></div>' +
                    '<p class="mt-2 text-muted small">Đang tải chi tiết hóa đơn #' + id + '...</p>' +
                '</div>';

            fetch('${pageContext.request.contextPath}/admin/billing?action=detail&format=json&id=' + id)
                .then(res => res.json())
                .then(data => {
                    renderInvoiceDetail(data);
                })
                .catch(err => {
                    body.innerHTML = '<div class="alert alert-danger mb-0">Không thể tải thông tin hóa đơn. Lỗi: ' + err + '</div>';
                });
        }

        function renderInvoiceDetail(inv) {
            const body = document.getElementById('invoiceDetailBody');
            function esc(val) {
                if (val === null || val === undefined) return '';
                return String(val)
                    .replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;')
                    .replace(/"/g, '&quot;');
            }

            let itemsHtml = '';
            if (inv.items && inv.items.length > 0) {
                inv.items.forEach(function(it) {
                    itemsHtml += '<tr>' +
                        '<td class="text-center">' + esc(it.stt) + '</td>' +
                        '<td>' +
                            '<div class="fw-semibold">' + esc(it.name) + '</div>' +
                            '<small class="text-muted">' + esc(it.type) + '</small>' +
                        '</td>' +
                        '<td class="text-center">' + esc(it.quantity) + '</td>' +
                        '<td class="text-end">' + esc(it.unitPriceFmt) + '</td>' +
                        '<td class="text-end fw-bold">' + esc(it.totalPriceFmt) + '</td>' +
                    '</tr>';
                });
            } else {
                itemsHtml = '<tr><td colspan="5" class="text-center py-3 text-muted">Không có dịch vụ / thuốc kê đơn</td></tr>';
            }

            let badgeHtml = '';
            if (inv.status === 'Paid') {
                badgeHtml = '<span class="badge bg-success px-3 py-2">Đã thanh toán</span>';
            } else if (inv.status === 'Refunded') {
                badgeHtml = '<span class="badge bg-danger px-3 py-2">Đã hoàn tiền</span>';
            } else {
                badgeHtml = '<span class="badge bg-warning text-dark px-3 py-2">Chưa thanh toán</span>';
            }

            let docDisplayName = esc(inv.doctorName);
            if (docDisplayName && !docDisplayName.startsWith('BS.') && !docDisplayName.startsWith('BS ') && !docDisplayName.startsWith('Bác sĩ') && !docDisplayName.startsWith('ThS') && !docDisplayName.startsWith('TS')) {
                docDisplayName = 'BS. ' + docDisplayName;
            }

            let html = '<div id="printableInvoice">' +
                '<div class="d-flex justify-content-between align-items-center flex-wrap pb-3 mb-3 border-bottom">' +
                    '<div>' +
                        '<h4 class="fw-bold mb-1" style="color: #0d9488;"><i class="bi bi-eye me-2"></i>VisionCare Clinic</h4>' +
                        '<p class="text-muted small mb-0">Địa chỉ: 456 Lê Thị Riêng, Quận 10, TP.HCM</p>' +
                        '<p class="text-muted small mb-0">Hotline: 1800 599 988 | Email: hotro@visioncare.vn</p>' +
                    '</div>' +
                    '<div class="text-end mt-2 mt-md-0">' +
                        '<h5 class="fw-bold mb-1">HÓA ĐƠN THANH TOÁN</h5>' +
                        '<div class="fw-bold text-dark fs-6">Mã: ' + esc(inv.formattedId) + '</div>' +
                        '<div class="small text-muted">Ngày lập: ' + esc(inv.createDate) + '</div>' +
                        '<div class="mt-2">' + badgeHtml + '</div>' +
                    '</div>' +
                '</div>' +

                '<div class="row g-3 mb-4">' +
                    '<div class="col-md-6">' +
                        '<div class="p-3 bg-light rounded-3 h-100">' +
                            '<h6 class="fw-bold text-muted small text-uppercase mb-2">Thông tin Bệnh nhân</h6>' +
                            '<p class="mb-1 fw-bold text-dark">' + esc(inv.patientName) + '</p>' +
                            '<p class="mb-1 small text-muted"><i class="bi bi-telephone me-2"></i>' + (esc(inv.patientPhone) || 'Chưa có SĐT') + '</p>' +
                            '<p class="mb-0 small text-muted"><i class="bi bi-geo-alt me-2"></i>' + (esc(inv.patientAddress) || '456 Lê Thị Riêng, Quận 10, TP.HCM') + '</p>' +
                        '</div>' +
                    '</div>' +
                    '<div class="col-md-6">' +
                        '<div class="p-3 bg-light rounded-3 h-100">' +
                            '<h6 class="fw-bold text-muted small text-uppercase mb-2">Thông tin Khám & Điều trị</h6>' +
                            '<p class="mb-1 small"><span class="text-muted">Bác sĩ phụ trách:</span> <strong class="text-dark">' + docDisplayName + '</strong></p>' +
                            '<p class="mb-1 small"><span class="text-muted">Mã lịch hẹn:</span> <strong>#APT-' + esc(inv.appointmentId) + '</strong></p>' +
                            '<p class="mb-1 small"><span class="text-muted">Mã bệnh án:</span> <strong>' + esc(inv.recordId) + '</strong></p>' +
                            '<p class="mb-0 small"><span class="text-muted">Chẩn đoán:</span> <strong>' + esc(inv.diagnosis) + '</strong></p>' +
                        '</div>' +
                    '</div>' +
                '</div>' +

                '<div class="table-responsive mb-3">' +
                    '<table class="table table-bordered align-middle mb-0">' +
                        '<thead class="table-light">' +
                            '<tr>' +
                                '<th class="text-center" width="5%">STT</th>' +
                                '<th>Nội dung / Dịch vụ</th>' +
                                '<th class="text-center" width="10%">SL</th>' +
                                '<th class="text-end" width="20%">Đơn giá</th>' +
                                '<th class="text-end" width="20%">Thành tiền</th>' +
                            '</tr>' +
                        '</thead>' +
                        '<tbody>' +
                            itemsHtml +
                        '</tbody>' +
                    '</table>' +
                '</div>' +

                '<div class="row justify-content-end mb-3">' +
                    '<div class="col-md-6">' +
                        '<div class="d-flex justify-content-between mb-2">' +
                            '<span class="text-muted">Tạm tính:</span>' +
                            '<span class="fw-bold">' + esc(inv.totalAmountFmt) + '</span>' +
                        '</div>' +
                        '<div class="d-flex justify-content-between mb-2">' +
                            '<span class="text-muted">Đã đặt cọc:</span>' +
                            '<span class="fw-bold">' + esc(inv.depositAmountFmt) + '</span>' +
                        '</div>' +
                        '<hr class="my-2">' +
                        '<div class="d-flex justify-content-between align-items-center">' +
                            '<span class="fw-bold fs-6" style="color: #0d9488;">Tổng cộng:</span>' +
                            '<span class="fw-bold fs-5 text-success">' + esc(inv.totalAmountFmt) + '</span>' +
                        '</div>' +
                    '</div>' +
                '</div>' +

                '<div class="p-3 border rounded-3 bg-light">' +
                    '<div class="d-flex justify-content-between align-items-center flex-wrap gap-2">' +
                        '<span class="small text-muted">Phương thức thanh toán: <strong>' + (esc(inv.paymentMethod) || 'Chưa thanh toán') + '</strong></span>' +
                        '<span class="small text-muted">Ngày hoàn tất: <strong>' + (esc(inv.closeDate) || 'Đã hoàn tất') + '</strong></span>' +
                    '</div>' +
                '</div>' +
            '</div>';

            body.innerHTML = html;
        }

        function openPaymentModal(id, code, amount) {
            const idInput = document.getElementById('payModalInvoiceId');
            if (idInput) idInput.value = id;
            const codeEl = document.getElementById('payModalInvoiceCode');
            if (codeEl) codeEl.innerText = code;
            const amtInput = document.getElementById('payModalAmount');
            if (amtInput) amtInput.value = amount;
            const modal = getPayModal();
            if (modal) modal.show();
        }

        function printInvoice() {
            window.print();
        }

        function handleTimeRangeChange() {
            var sel = document.getElementById('timeRangeSelect');
            if (!sel) return;
            var val = sel.value;
            if (val === 'today' || val === 'all') {
                document.getElementById('billingFilterForm').submit();
            } else {
                toggleTimeRangeInputs();
            }
        }

        function updateDateToMin() {
            var from = document.getElementById('customDateFrom');
            var to = document.getElementById('customDateTo');
            if (from && to && from.value) {
                to.min = from.value;
                if (to.value && to.value < from.value) {
                    to.value = from.value;
                }
            }
        }

        function validateDateRange() {
            var sel = document.getElementById('timeRangeSelect');
            if (sel && sel.value === 'custom') {
                var from = document.getElementById('customDateFrom');
                var to = document.getElementById('customDateTo');
                if (from && to && from.value && to.value) {
                    if (to.value < from.value) {
                        alert('Ngày kết thúc phải lớn hơn hoặc bằng ngày bắt đầu!');
                        return false;
                    }
                }
            }
            return true;
        }

        function toggleTimeRangeInputs() {
            var sel = document.getElementById('timeRangeSelect');
            if (!sel) return;
            var timeRange = sel.value;
            var subRow = document.getElementById('subFilterRow');
            var monthBox = document.getElementById('monthControls');
            var quarterBox = document.getElementById('quarterControls');
            var customBox = document.getElementById('customDateControls');

            if (!subRow || !monthBox || !quarterBox || !customBox) return;

            monthBox.style.display = 'none';
            quarterBox.style.display = 'none';
            customBox.style.display = 'none';

            if (timeRange === 'by_month') {
                subRow.style.display = 'block';
                monthBox.style.display = 'block';
            } else if (timeRange === 'by_quarter') {
                subRow.style.display = 'block';
                quarterBox.style.display = 'block';
            } else if (timeRange === 'custom') {
                subRow.style.display = 'block';
                customBox.style.display = 'block';
                updateDateToMin();
            } else {
                subRow.style.display = 'none';
            }
        }

        document.addEventListener('DOMContentLoaded', function() {
            toggleTimeRangeInputs();
            updateDateToMin();
            <c:if test="${not empty selectedInvoice}">
            openInvoiceDetail(${selectedInvoice.id});
            </c:if>
        });
    </script>
</body>
</html>
