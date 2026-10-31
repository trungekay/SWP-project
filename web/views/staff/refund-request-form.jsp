<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo yêu cầu hoàn tiền - VisionCare</title>

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <!-- Employee / Staff Unified Layout CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/employee.css">

    <style>
        .form-card {
            background: #ffffff;
            border-radius: 14px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.04);
            padding: 24px;
            margin-bottom: 24px;
        }

        .form-card-title {
            font-size: 16px;
            font-weight: 700;
            color: #0f172a;
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 20px;
            padding-bottom: 12px;
            border-bottom: 1px solid #f1f5f9;
        }

        .form-card-title i {
            color: #0d9488;
            font-size: 20px;
        }

        .info-summary-card {
            background: #ffffff;
            border-radius: 14px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.04);
            overflow: hidden;
            position: sticky;
            top: 20px;
        }

        .info-summary-header {
            background: linear-gradient(135deg, #0d9488 0%, #0f766e 100%);
            color: #ffffff;
            padding: 18px 20px;
        }

        .info-summary-body {
            padding: 20px;
        }

        .summary-item {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            padding: 10px 0;
            border-bottom: 1px dashed #f1f5f9;
            font-size: 14px;
        }

        .summary-item:last-child {
            border-bottom: none;
        }

        .summary-label {
            color: #64748b;
            font-weight: 500;
        }

        .summary-value {
            color: #0f172a;
            font-weight: 600;
            text-align: right;
        }

        .amount-highlight-box {
            background: #f0fdf4;
            border: 1px solid #bbf7d0;
            border-radius: 10px;
            padding: 14px;
            text-align: center;
            margin: 16px 0;
        }

        .amount-highlight-label {
            font-size: 12px;
            color: #166534;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .amount-highlight-val {
            font-size: 24px;
            font-weight: 700;
            color: #15803d;
            margin-top: 4px;
        }

        .method-selector-group {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }

        .method-card {
            border: 2px solid #e2e8f0;
            border-radius: 12px;
            padding: 14px 16px;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            gap: 12px;
            background: #ffffff;
        }

        .method-card:hover {
            border-color: #99f6e4;
            background: #f0fdfa;
        }

        .method-card.active {
            border-color: #0d9488;
            background: #f0fdfa;
            box-shadow: 0 0 0 1px #0d9488;
        }

        .method-card input[type="radio"] {
            display: none;
        }

        .method-icon {
            width: 38px;
            height: 38px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            background: #f8fafc;
            color: #0d9488;
            transition: all 0.2s;
        }

        .method-card.active .method-icon {
            background: #0d9488;
            color: #ffffff;
        }

        .quick-reason-btn {
            font-size: 12px;
            padding: 5px 10px;
            border-radius: 20px;
            border: 1px solid #e2e8f0;
            background: #f8fafc;
            color: #475569;
            cursor: pointer;
            transition: all 0.15s;
        }

        .quick-reason-btn:hover {
            background: #0d9488;
            color: #ffffff;
            border-color: #0d9488;
        }

        .empty-invoices-notice {
            background: #f8fafc;
            border: 2px dashed #cbd5e1;
            border-radius: 14px;
            padding: 40px 20px;
            text-align: center;
        }
    </style>
</head>
<body>

    <!-- Employee Unified Sidebar -->
    <jsp:include page="/views/employee/layout/employee-sidebar.jsp">
        <jsp:param name="activeNav" value="refund-request" />
    </jsp:include>

    <!-- Main Wrapper -->
    <main class="main-wrapper">
        <!-- Top Header -->
        <jsp:include page="/views/employee/layout/employee-header.jsp" />

        <!-- Page Content -->
        <div class="page-content">

            <!-- Flash Messages -->
            <c:if test="${not empty sessionScope.successMessage}">
                <div class="flash-alert flash-alert-success alert-dismissible fade show" role="alert">
                    <div class="flash-alert-icon"><i class="bi bi-check-lg"></i></div>
                    <div class="flash-alert-content">
                        <span class="alert-title">Thành công!</span> <c:out value="${sessionScope.successMessage}"/>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="successMessage" scope="session" />
            </c:if>

            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="flash-alert flash-alert-danger alert-dismissible fade show" role="alert">
                    <div class="flash-alert-icon"><i class="bi bi-exclamation-triangle-fill"></i></div>
                    <div class="flash-alert-content">
                        <span class="alert-title">Lỗi:</span> <c:out value="${sessionScope.errorMessage}"/>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="errorMessage" scope="session" />
            </c:if>

            <!-- Page Header -->
            <div class="page-header d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
                <div class="page-title">
                    <h2 class="mb-0">Tạo yêu cầu hoàn tiền</h2>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <a href="${pageContext.request.contextPath}/staff/appointments" class="btn btn-outline-secondary d-flex align-items-center gap-2">
                        <i class="bi bi-arrow-left"></i>
                        <span>Quay lại danh sách lịch hẹn</span>
                    </a>
                </div>
            </div>

            <!-- Form Body -->
            <c:choose>
                <c:when test="${empty availableInvoices}">
                    <div class="empty-invoices-notice my-4">
                        <div class="mb-3">
                            <i class="bi bi-shield-check text-muted" style="font-size: 48px;"></i>
                        </div>
                        <h5 class="fw-bold text-dark">Hiện tại không có lịch hẹn nào đủ điều kiện hoàn tiền</h5>
                        <p class="text-muted small max-w-500 mx-auto mb-4" style="max-width: 550px;">
                            Điều kiện hoàn tiền: Lịch hẹn phải ở trạng thái <strong>Đã hủy trước khi check-in tiếp đón</strong>, 
                            hóa đơn đã được thanh toán và chưa có phiếu hoàn tiền đang xử lý.
                        </p>
                        <a href="${pageContext.request.contextPath}/staff/appointments" class="btn btn-teal">
                            <i class="bi bi-calendar2-check me-2"></i>Xem Danh Sách Lịch Hẹn
                        </a>
                    </div>
                </c:when>

                <c:otherwise>
                    <form action="${pageContext.request.contextPath}/staff/refund-request" method="POST" id="refundForm" onsubmit="return validateRefundForm();">
                        <input type="hidden" name="action" value="create">
                        <input type="hidden" name="patientId" id="hiddenPatientId" value="">

                        <div class="row g-4">
                            <!-- Left Column: Form Fields -->
                            <div class="col-lg-7 col-xl-8">
                                <!-- Card 1: Chọn Hóa đơn / Lịch hẹn -->
                                <div class="form-card">
                                    <div class="form-card-title">
                                        <i class="bi bi-receipt-cutoff"></i>
                                        <span>1. Chọn Lịch Hẹn / Hóa Đơn Cần Hoàn Tiền</span>
                                    </div>

                                    <div class="mb-3">
                                        <label for="invoiceSelect" class="form-label small fw-bold text-dark">
                                            Hóa đơn đủ điều kiện hoàn trả <span class="text-danger">*</span>
                                        </label>
                                        <select class="form-select form-select-lg" name="invoiceId" id="invoiceSelect" onchange="onInvoiceChanged()" required>
                                            <option value="" 
                                                    data-patient-id="" 
                                                    data-patient-name="" 
                                                    data-patient-phone="" 
                                                    data-appt-id="" 
                                                    data-amount="0"
                                                    data-doctor=""
                                                    data-specialty=""
                                                    data-date=""
                                                    data-time="">
                                                -- Chọn hóa đơn cần lập phiếu hoàn tiền (${fn:length(availableInvoices)} hóa đơn khả dụng) --
                                            </option>
                                            <c:forEach var="inv" items="${availableInvoices}">
                                                <c:set var="isPreselected" value="${inv.appointmentId == selectedApptId || inv.invoiceId == selectedInvoiceId}" />
                                                <option value="${inv.invoiceId}" 
                                                        data-patient-id="${inv.patientId}"
                                                        data-patient-name="${inv.patientName}"
                                                        data-patient-phone="${inv.patientPhone}"
                                                        data-appt-id="${inv.appointmentId}"
                                                        data-amount="${inv.refundableAmount}"
                                                        data-doctor="${inv.doctorName}"
                                                        data-specialty="${inv.specialty}"
                                                        data-date="${inv.workDate}"
                                                        data-time="${inv.startTime}"
                                                        ${isPreselected ? 'selected' : ''}>
                                                    ${inv.label}
                                                </option>
                                            </c:forEach>
                                        </select>
                                        <div class="form-text small text-muted">
                                            Chỉ những hóa đơn đã thanh toán thuộc lịch hẹn được hủy trước tiếp đón mới xuất hiện trong danh sách này.
                                        </div>
                                    </div>
                                </div>

                                <!-- Card 2: Thông tin Hoàn tiền & Phương thức -->
                                <div class="form-card">
                                    <div class="form-card-title">
                                        <i class="bi bi-cash-stack"></i>
                                        <span>2. Thông Tin Chi Trả Hoàn Tiền</span>
                                    </div>

                                    <!-- Số tiền hoàn -->
                                    <div class="mb-4">
                                        <div class="d-flex justify-content-between align-items-center mb-1">
                                            <label for="refundAmount" class="form-label small fw-bold text-dark mb-0">
                                                Số tiền hoàn trả (VNĐ) <span class="text-danger">*</span>
                                            </label>
                                            <span class="badge bg-light text-secondary border">Cố định 100% số tiền đã nộp</span>
                                        </div>
                                        <div class="input-group">
                                            <input type="number" class="form-control form-control-lg fw-bold text-dark" 
                                                   name="amount" id="refundAmount" 
                                                   placeholder="0" 
                                                   readonly style="background-color: #f8fafc; cursor: not-allowed;" required>
                                            <span class="input-group-text fw-bold text-muted bg-light">VNĐ</span>
                                        </div>
                                        <div class="d-flex justify-content-between align-items-center mt-1">
                                            <div class="small text-muted" id="amountFormattedText">Tự động điền theo hóa đơn gốc đã chọn</div>
                                        </div>
                                    </div>

                                    <!-- Hình thức hoàn tiền -->
                                    <div class="mb-4">
                                        <label class="form-label small fw-bold text-dark mb-2">
                                            Hình thức nhận tiền của bệnh nhân <span class="text-danger">*</span>
                                        </label>
                                        <div class="method-selector-group">
                                            <label class="method-card active" id="cardCash" onclick="selectMethod('Cash')">
                                                <input type="radio" name="refundMethod" value="Cash" checked>
                                                <div class="method-icon"><i class="bi bi-wallet2"></i></div>
                                                <div>
                                                    <div class="fw-bold text-dark small">Tiền mặt tại quầy</div>
                                                    <div class="text-muted" style="font-size: 11px;">Hoàn trả trực tiếp tại quầy lễ tân</div>
                                                </div>
                                            </label>

                                            <label class="method-card" id="cardBank" onclick="selectMethod('Bank_Transfer')">
                                                <input type="radio" name="refundMethod" value="Bank_Transfer">
                                                <div class="method-icon"><i class="bi bi-bank"></i></div>
                                                <div>
                                                    <div class="fw-bold text-dark small">Chuyển khoản ngân hàng</div>
                                                    <div class="text-muted" style="font-size: 11px;">Chuyển về STK do bệnh nhân cung cấp</div>
                                                </div>
                                            </label>
                                        </div>
                                    </div>

                                    <!-- Thông tin tài khoản ngân hàng (Hiện khi chọn Bank_Transfer) -->
                                    <div id="bankDetailsSection" class="p-3 bg-light rounded-3 border mb-4" style="display: none;">
                                        <div class="fw-bold text-dark small mb-3 d-flex align-items-center gap-2">
                                            <i class="bi bi-credit-card-2-front text-teal"></i>
                                            <span>Thông tin tài khoản thụ hưởng của bệnh nhân</span>
                                        </div>
                                        <div class="row g-3">
                                            <div class="col-md-6">
                                                <label class="form-label small fw-semibold text-dark">Ngân hàng thụ hưởng</label>
                                                <select class="form-select" name="bankName" id="bankNameSelect">
                                                    <option value="Vietcombank">Vietcombank (Ngoại thương)</option>
                                                    <option value="MB Bank">MB Bank (Quân đội)</option>
                                                    <option value="Techcombank">Techcombank (Kỹ thương)</option>
                                                    <option value="BIDV">BIDV (Đầu tư &amp; Phát triển)</option>
                                                    <option value="VietinBank">VietinBank (Công thương)</option>
                                                    <option value="ACB">ACB (Á Châu)</option>
                                                    <option value="VPBank">VPBank (Việt Nam Thịnh Vượng)</option>
                                                    <option value="TPBank">TPBank (Tiên Phong)</option>
                                                    <option value="Agribank">Agribank (Nông nghiệp)</option>
                                                    <option value="Sacombank">Sacombank</option>
                                                </select>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label small fw-semibold text-dark">Số tài khoản</label>
                                                <input type="text" class="form-control" name="accountNumber" id="accountNumberInput" placeholder="Ví dụ: 0987654321">
                                            </div>
                                            <div class="col-12">
                                                <label class="form-label small fw-semibold text-dark">Tên chủ tài khoản (In hoa không dấu)</label>
                                                <input type="text" class="form-control text-uppercase" name="accountHolder" id="accountHolderInput" placeholder="NGUYEN VAN A">
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Lý do hoàn tiền -->
                                    <div class="mb-4">
                                        <label for="refundReason" class="form-label small fw-bold text-dark mb-1">
                                            Lý do hoàn tiền <span class="text-danger">*</span>
                                        </label>
                                        <div class="d-flex flex-wrap gap-1 mb-2">
                                            <span class="quick-reason-btn" onclick="setReason('Bệnh nhân báo việc đột xuất không thể đến khám')">Việc đột xuất</span>
                                            <span class="quick-reason-btn" onclick="setReason('Bác sĩ đổi lịch khám, không thể bố trí lịch thay thế')">Bác sĩ đổi lịch</span>
                                            <span class="quick-reason-btn" onclick="setReason('Bệnh nhân yêu cầu hủy trực tiếp tại quầy trước check-in')">Hủy tại quầy</span>
                                            <span class="quick-reason-btn" onclick="setReason('Bệnh nhân không còn nhu cầu khám nữa')">Không còn nhu cầu</span>
                                        </div>
                                        <textarea class="form-control" name="reason" id="refundReason" rows="3" 
                                                  placeholder="Mô tả cụ thể lý do hoàn tiền và ghi chú thêm (nếu có)..." required></textarea>
                                    </div>

                                    <!-- Trạng thái sau khi tạo -->
                                    <div class="mb-4 p-3 rounded-3" style="background-color: #fffbeb; border: 1px solid #fef3c7;">
                                        <div class="d-flex align-items-center gap-2">
                                            <i class="bi bi-clock-history text-warning fs-5"></i>
                                            <div>
                                                <div class="fw-bold text-dark small">Quy trình xét duyệt: <span class="badge bg-warning text-dark">Chờ phê duyệt (Pending)</span></div>
                                                <div class="text-muted" style="font-size: 12px;">Phiếu yêu cầu sẽ được chuyển đến Ban Giám đốc để kiểm tra và duyệt chi tiền.</div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Form Action Buttons -->
                                    <div class="d-flex align-items-center gap-3 pt-2">
                                        <button type="submit" class="btn btn-teal btn-lg px-4 shadow-sm fw-semibold">
                                            <i class="bi bi-send-check me-2"></i>Gửi Yêu Cầu Hoàn Tiền
                                        </button>
                                        <a href="${pageContext.request.contextPath}/staff/appointments" class="btn btn-light btn-lg px-4 border text-muted">
                                            Hủy bỏ
                                        </a>
                                    </div>
                                </div>
                            </div>

                            <!-- Right Column: Summary Card -->
                            <div class="col-lg-5 col-xl-4">
                                <div class="info-summary-card">
                                    <div class="info-summary-header">
                                        <div class="d-flex align-items-center gap-2 mb-1">
                                            <i class="bi bi-info-circle-fill"></i>
                                            <h6 class="fw-bold mb-0">Tóm Tắt Lịch Hẹn &amp; Hóa Đơn</h6>
                                        </div>
                                        <div class="small opacity-75" id="summarySubText">Vui lòng chọn hóa đơn để xem chi tiết</div>
                                    </div>

                                    <div class="info-summary-body">
                                        <div class="summary-item">
                                            <span class="summary-label">Mã lịch hẹn:</span>
                                            <span class="summary-value" id="dispApptId">--</span>
                                        </div>
                                        <div class="summary-item">
                                            <span class="summary-label">Mã hóa đơn:</span>
                                            <span class="summary-value text-teal" id="dispInvoiceId">--</span>
                                        </div>
                                        <div class="summary-item">
                                            <span class="summary-label">Bệnh nhân:</span>
                                            <span class="summary-value text-primary" id="dispPatientName">--</span>
                                        </div>
                                        <div class="summary-item">
                                            <span class="summary-label">Số điện thoại:</span>
                                            <span class="summary-value" id="dispPatientPhone">--</span>
                                        </div>
                                        <div class="summary-item">
                                            <span class="summary-label">Bác sĩ phụ trách:</span>
                                            <span class="summary-value" id="dispDoctorName">--</span>
                                        </div>
                                        <div class="summary-item">
                                            <span class="summary-label">Thời gian hẹn:</span>
                                            <span class="summary-value" id="dispSchedule">--</span>
                                        </div>

                                        <!-- Highlight Box -->
                                        <div class="amount-highlight-box">
                                            <div class="amount-highlight-label">Số tiền đã nộp (Tối đa hoàn)</div>
                                            <div class="amount-highlight-val" id="dispMaxRefund">0 đ</div>
                                        </div>

                                        <!-- Security & Policy Alert -->
                                        <div class="alert alert-light border small text-muted mb-0">
                                            <i class="bi bi-shield-lock-fill text-teal me-1"></i>
                                            <strong>Chính sách hoàn tiền:</strong> Chỉ áp dụng cho các ca hủy trước thời điểm tiếp đón (check-in) và đã hoàn thành nghĩa vụ thanh toán.
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </form>
                </c:otherwise>
            </c:choose>

        </div>
    </main>

    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        let currentMaxRefundable = 0;

        function selectMethod(method) {
            const cardCash = document.getElementById('cardCash');
            const cardBank = document.getElementById('cardBank');
            const bankSection = document.getElementById('bankDetailsSection');

            if (method === 'Cash') {
                cardCash.classList.add('active');
                cardBank.classList.remove('active');
                cardCash.querySelector('input[type="radio"]').checked = true;
                bankSection.style.display = 'none';
            } else {
                cardBank.classList.add('active');
                cardCash.classList.remove('active');
                cardBank.querySelector('input[type="radio"]').checked = true;
                bankSection.style.display = 'block';
            }
        }

        function setReason(text) {
            const reasonInput = document.getElementById('refundReason');
            reasonInput.value = text;
            reasonInput.focus();
        }

        function fillMaxAmount() {
            if (currentMaxRefundable > 0) {
                document.getElementById('refundAmount').value = currentMaxRefundable;
                updateAmountDisplay();
            }
        }

        function updateAmountDisplay() {
            const amtVal = parseFloat(document.getElementById('refundAmount').value) || 0;
            const textElem = document.getElementById('amountFormattedText');
            if (amtVal > 0) {
                textElem.textContent = 'Bằng số: ' + amtVal.toLocaleString('vi-VN') + ' đ (100% số tiền hóa đơn đã nộp)';
            } else {
                textElem.textContent = 'Tự động điền theo hóa đơn gốc đã chọn';
            }
        }

        function onInvoiceChanged() {
            const sel = document.getElementById('invoiceSelect');
            if (!sel) return;
            const opt = sel.options[sel.selectedIndex];

            const patientId = opt.dataset.patientId || '';
            const patientName = opt.dataset.patientName || '--';
            const patientPhone = opt.dataset.patientPhone || '--';
            const apptId = opt.dataset.apptId || '';
            const amount = parseFloat(opt.dataset.amount) || 0;
            const doctor = opt.dataset.doctor || '--';
            const specialty = opt.dataset.specialty || '';
            const date = opt.dataset.date || '';
            const time = opt.dataset.time || '';

            currentMaxRefundable = amount;

            // Hidden inputs & limits
            document.getElementById('hiddenPatientId').value = patientId;
            const amountInput = document.getElementById('refundAmount');
            amountInput.max = amount > 0 ? amount : '';
            if (sel.value) {
                amountInput.value = amount;
            } else {
                amountInput.value = '';
            }
            updateAmountDisplay();

            // Auto-fill account holder name suggestion
            if (patientName && patientName !== '--') {
                const holderInput = document.getElementById('accountHolderInput');
                if (holderInput && !holderInput.value) {
                    holderInput.value = patientName.toUpperCase();
                }
            }

            // Update Summary Card
            document.getElementById('dispApptId').textContent = apptId ? ('#APT-' + apptId) : '--';
            document.getElementById('dispInvoiceId').textContent = sel.value ? ('#INV-' + String(sel.value).padStart(5, '0')) : '--';
            document.getElementById('dispPatientName').textContent = patientName;
            document.getElementById('dispPatientPhone').textContent = patientPhone;
            document.getElementById('dispDoctorName').textContent = doctor + (specialty ? (' (' + specialty + ')') : '');
            document.getElementById('dispSchedule').textContent = (date ? date : '') + (time ? (' - ' + time) : (date ? '' : '--'));
            document.getElementById('dispMaxRefund').textContent = amount.toLocaleString('vi-VN') + ' đ';
            document.getElementById('summarySubText').textContent = sel.value ? 'Thông tin hợp lệ đủ điều kiện hoàn' : 'Vui lòng chọn hóa đơn';
        }

        function validateRefundForm() {
            const invoiceSelect = document.getElementById('invoiceSelect');
            if (!invoiceSelect.value) {
                alert('Vui lòng chọn hóa đơn cần tạo yêu cầu hoàn tiền!');
                invoiceSelect.focus();
                return false;
            }

            const amountInput = document.getElementById('refundAmount');
            const amt = parseFloat(amountInput.value) || 0;
            if (amt < 10000) {
                alert('Số tiền hoàn tiền tối thiểu là 10,000 đ!');
                amountInput.focus();
                return false;
            }
            if (currentMaxRefundable > 0 && amt > currentMaxRefundable) {
                alert('Số tiền hoàn (' + amt.toLocaleString('vi-VN') + ' đ) không được lớn hơn số tiền đã đóng (' + currentMaxRefundable.toLocaleString('vi-VN') + ' đ)!');
                amountInput.focus();
                return false;
            }

            const methodBank = document.querySelector('input[name="refundMethod"][value="Bank_Transfer"]');
            if (methodBank && methodBank.checked) {
                const accNum = document.getElementById('accountNumberInput').value.trim();
                const accHolder = document.getElementById('accountHolderInput').value.trim();
                if (!accNum) {
                    alert('Vui lòng nhập số tài khoản ngân hàng của bệnh nhân!');
                    document.getElementById('accountNumberInput').focus();
                    return false;
                }
                if (!accHolder) {
                    alert('Vui lòng nhập tên chủ tài khoản ngân hàng!');
                    document.getElementById('accountHolderInput').focus();
                    return false;
                }
            }

            const reason = document.getElementById('refundReason').value.trim();
            if (!reason) {
                alert('Vui lòng nhập lý do hoàn tiền!');
                document.getElementById('refundReason').focus();
                return false;
            }

            return true;
        }

        // Initialize state on DOM ready
        document.addEventListener('DOMContentLoaded', function() {
            onInvoiceChanged();
        });
    </script>
</body>
</html>
