<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Bệnh nhân - VisionCare</title>

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <!-- Employee / Staff Unified Layout CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/employee.css">

    <style>
        .patient-avatar {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            background: linear-gradient(135deg, #0d9488 0%, #0284c7 100%);
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 16px;
            flex-shrink: 0;
            box-shadow: 0 2px 6px rgba(13, 148, 136, 0.25);
        }

        .table-patient-card {
            background: #ffffff;
            border-radius: 14px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.03);
            overflow: hidden;
        }

        .table-patient-card thead th {
            background-color: #f8fafc;
            color: #475569;
            font-weight: 600;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 14px 16px;
            border-bottom: 1px solid #e2e8f0;
            white-space: nowrap;
        }

        .table-patient-card tbody td {
            padding: 14px 16px;
            vertical-align: middle;
            font-size: 14px;
            color: #334155;
            border-bottom: 1px solid #f1f5f9;
        }

        .table-patient-card tbody tr:hover {
            background-color: #f8fafc;
        }

        .patient-id-badge {
            font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, monospace;
            font-size: 12px;
            font-weight: 600;
            padding: 4px 8px;
            border-radius: 6px;
            background-color: #f1f5f9;
            color: #0f766e;
            border: 1px solid #cbd5e1;
        }

        .badge-portal {
            background-color: #ecfdf5;
            color: #059669;
            border: 1px solid #a7f3d0;
            font-weight: 500;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
        }

        .badge-counter {
            background-color: #f8fafc;
            color: #64748b;
            border: 1px solid #e2e8f0;
            font-weight: 500;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
        }
    </style>
</head>
<body>

    <!-- Employee Unified Sidebar -->
    <jsp:include page="/views/employee/layout/employee-sidebar.jsp">
        <jsp:param name="activeNav" value="patients" />
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

            <!-- Page Title Bar -->
            <div class="page-header d-flex align-items-center justify-content-between mb-4 flex-wrap gap-3">
                <div>
                    <h2 class="mb-1 fw-bold text-dark">Quản lý Bệnh nhân</h2>
                    <p class="text-muted mb-0 small">Tra cứu hồ sơ, danh sách khám và lịch sử điều trị tại phòng khám VisionCare</p>
                </div>
                <div>
                    <button type="button" class="btn btn-teal text-white shadow-sm px-3 py-2 fw-medium" data-bs-toggle="modal" data-bs-target="#createPatientModal" style="background-color: #0d9488; border-color: #0d9488;">
                        <i class="bi bi-person-plus-fill me-1"></i> Tiếp nhận / Thêm bệnh nhân
                    </button>
                </div>
            </div>

            <!-- KPI Metric Cards -->
            <div class="row g-3 mb-4">
                <!-- 1. Tổng bệnh nhân -->
                <div class="col-sm-6 col-xl-3">
                    <a href="${pageContext.request.contextPath}/staff/patients" class="metric-card text-decoration-none ${accountType == 'all' ? 'border border-2 border-primary shadow-sm' : ''}">
                        <div class="metric-icon-box metric-icon-teal">
                            <i class="bi bi-people-fill"></i>
                        </div>
                        <div class="metric-info">
                            <div class="metric-num"><c:out value="${stats.total}"/></div>
                            <div class="metric-title text-secondary">Tổng số bệnh nhân</div>
                        </div>
                    </a>
                </div>

                <!-- 2. Có tài khoản Portal -->
                <div class="col-sm-6 col-xl-3">
                    <a href="${pageContext.request.contextPath}/staff/patients?accountType=with_account" class="metric-card text-decoration-none ${accountType == 'with_account' ? 'border border-2 border-success shadow-sm' : ''}">
                        <div class="metric-icon-box metric-icon-green">
                            <i class="bi bi-shield-check"></i>
                        </div>
                        <div class="metric-info">
                            <div class="metric-num"><c:out value="${stats.withAccount}"/></div>
                            <div class="metric-title text-secondary">Tài khoản trực tuyến</div>
                        </div>
                    </a>
                </div>

                <!-- 3. Khách vãng lai / Tại quầy -->
                <div class="col-sm-6 col-xl-3">
                    <a href="${pageContext.request.contextPath}/staff/patients?accountType=no_account" class="metric-card text-decoration-none ${accountType == 'no_account' ? 'border border-2 border-warning shadow-sm' : ''}">
                        <div class="metric-icon-box metric-icon-amber">
                            <i class="bi bi-person-badge"></i>
                        </div>
                        <div class="metric-info">
                            <div class="metric-num"><c:out value="${stats.noAccount}"/></div>
                            <div class="metric-title text-secondary">Bệnh nhân tại quầy</div>
                        </div>
                    </a>
                </div>

                <!-- 4. Lịch hẹn hôm nay -->
                <div class="col-sm-6 col-xl-3">
                    <div class="metric-card">
                        <div class="metric-icon-box metric-icon-purple">
                            <i class="bi bi-calendar2-check-fill"></i>
                        </div>
                        <div class="metric-info">
                            <div class="metric-num"><c:out value="${stats.todayAppointments}"/></div>
                            <div class="metric-title text-secondary">Có lịch hẹn hôm nay</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Content Card: Toolbar + Tabs + Table (Đồng bộ Quản lý lịch hẹn) -->
            <div class="content-card table-patient-card">
                <!-- Toolbar: Tìm kiếm bệnh nhân -->
                <form action="${pageContext.request.contextPath}/staff/patients" method="get"
                    class="p-3 border-bottom bg-white">
                    <input type="hidden" name="accountType" value="${accountType}">
                    <div class="d-flex flex-column flex-md-row align-items-stretch align-items-md-center justify-content-between gap-3">
                        <!-- 1. Thanh tìm kiếm nhanh (Tên, SĐT, Mã BN) -->
                        <div class="search-filter-input flex-grow-1" style="max-width: 520px;">
                            <i class="bi bi-search"></i>
                            <input type="text" name="keyword" value="<c:out value='${keyword}'/>" class="w-100"
                                style="height: 40px; font-size: 14px; border-radius: 8px;"
                                placeholder="Tìm theo tên, SĐT hoặc mã BN (#PAT-0001)...">
                        </div>

                        <!-- 2. Nút Tra cứu & Nút Tải lại -->
                        <div class="d-flex align-items-center gap-2">
                            <button type="submit"
                                class="btn btn-teal px-3.5 text-nowrap d-flex align-items-center justify-content-center gap-1.5 shadow-sm"
                                style="height: 40px; font-weight: 600;">
                                <i class="bi bi-search"></i>
                                <span>Tra cứu</span>
                            </button>
                            <a href="${pageContext.request.contextPath}/staff/patients"
                                class="btn btn-outline-secondary px-3 text-nowrap d-flex align-items-center justify-content-center gap-1.5 shadow-sm"
                                style="height: 40px; font-weight: 500; border-radius: 8px;"
                                title="Tải lại danh sách (Tất cả bệnh nhân)">
                                <i class="bi bi-arrow-clockwise"></i>
                                <span>Tải lại</span>
                            </a>
                        </div>
                    </div>
                </form>

                <!-- Thanh điều hướng Tab loại bệnh nhân (Đồng bộ phong cách danh sách lịch hẹn) -->
                <div class="px-3 pt-3 pb-2 bg-light border-bottom d-flex align-items-center justify-content-between flex-wrap gap-2">
                    <div class="d-flex align-items-center gap-2 flex-wrap">
                        <a href="${pageContext.request.contextPath}/staff/patients?accountType=all&keyword=<c:out value='${keyword}'/>"
                            class="btn btn-sm ${accountType == 'all' || empty accountType ? 'btn-dark fw-bold shadow-sm' : 'btn-white border text-secondary'} rounded-pill px-3">
                            <i class="bi bi-people-fill me-1"></i> Tất cả (<c:out value="${stats.total}"/>)
                        </a>
                        <a href="${pageContext.request.contextPath}/staff/patients?accountType=with_account&keyword=<c:out value='${keyword}'/>"
                            class="btn btn-sm ${accountType == 'with_account' ? 'btn-success fw-bold shadow-sm' : 'btn-white border text-secondary'} rounded-pill px-3">
                            <i class="bi bi-shield-check me-1"></i> Trực tuyến (<c:out value="${stats.withAccount}"/>)
                        </a>
                        <a href="${pageContext.request.contextPath}/staff/patients?accountType=no_account&keyword=<c:out value='${keyword}'/>"
                            class="btn btn-sm ${accountType == 'no_account' ? 'btn-warning text-dark fw-bold shadow-sm' : 'btn-white border text-secondary'} rounded-pill px-3">
                            <i class="bi bi-person-badge me-1"></i> Tại quầy (<c:out value="${stats.noAccount}"/>)
                        </a>
                    </div>
                </div>

                <!-- Patient Table -->
                <div class="table-responsive">
                    <table class="table mb-0 align-middle">
                        <thead>
                            <tr>
                                <th style="width: 110px;">Mã BN</th>
                                <th>Bệnh nhân</th>
                                <th>Số điện thoại</th>
                                <th class="text-nowrap">Ngày sinh</th>
                                <th>Địa chỉ</th>
                                <th>Hình thức</th>
                                <th class="text-center">Số lượt khám</th>
                                <th>Khám gần nhất</th>
                                <th class="text-center text-nowrap" style="width: 120px;">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty patients}">
                                    <c:forEach var="p" items="${patients}">
                                        <tr>
                                            <td>
                                                <span class="patient-id-badge"><c:out value="${p.formattedId}"/></span>
                                            </td>
                                            <td class="text-nowrap text-truncate">
                                                <a href="javascript:void(0)" onclick="viewPatientDetail(${p.patientId})"
                                                    class="fw-semibold text-dark hover-teal text-decoration-none"
                                                    style="font-size: 14px;"
                                                    title="<c:out value='${p.fullName}'/>">
                                                    <c:out value="${p.fullName}"/>
                                                </a>
                                            </td>
                                            <td>
                                                <span class="fw-medium text-dark"><i class="bi bi-telephone text-muted me-1"></i><c:out value="${p.phone}"/></span>
                                            </td>
                                            <td class="text-nowrap">
                                                <c:choose>
                                                    <c:when test="${not empty p.dob}">
                                                        <span><fmt:formatDate value="${p.dob}" pattern="dd/MM/yyyy"/></span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted small">Chưa cập nhật</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <div class="text-truncate" style="max-width: 180px;">
                                                    <c:choose>
                                                        <c:when test="${not empty p.address}">
                                                            <c:out value="${p.address}"/>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted small">Chưa cập nhật</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${p.hasAccount}">
                                                        <span class="badge-portal"><i class="bi bi-check-circle-fill me-1"></i>Trực tuyến</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge-counter"><i class="bi bi-person me-1"></i>Tại quầy</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center">
                                                <span class="badge bg-light text-dark border px-2 py-1 rounded-pill fw-semibold">
                                                    <c:out value="${p.totalAppointments}"/> lượt
                                                </span>
                                            </td>
                                            <td>
                                                <span class="small text-muted"><c:out value="${p.latestAppointmentDate}"/></span>
                                            </td>
                                            <td class="text-center text-nowrap">
                                                <div class="action-btns justify-content-center">
                                                    <!-- Xem chi tiết & lịch sử -->
                                                    <button type="button" class="action-btn" title="Xem chi tiết & lịch sử khám" data-bs-toggle="tooltip"
                                                            onclick="viewPatientDetail(${p.patientId})">
                                                        <i class="bi bi-eye"></i>
                                                    </button>

                                                    <!-- Sửa thông tin -->
                                                    <button type="button" class="action-btn warning" title="Chỉnh sửa thông tin" data-bs-toggle="tooltip"
                                                            onclick="openEditPatient(${p.patientId})">
                                                        <i class="bi bi-pencil"></i>
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="9" class="text-center py-5 text-muted">
                                            <div class="mb-3"><i class="bi bi-search" style="font-size: 40px; color: #cbd5e1;"></i></div>
                                            <div class="fw-semibold">Không tìm thấy bệnh nhân nào phù hợp</div>
                                            <p class="small text-muted mb-3">Vui lòng thử tìm kiếm bằng từ khóa khác hoặc thêm mới hồ sơ bệnh nhân tại quầy.</p>
                                            <button type="button" class="btn btn-sm btn-teal text-white" data-bs-toggle="modal" data-bs-target="#createPatientModal" style="background-color: #0d9488;">
                                                <i class="bi bi-person-plus-fill me-1"></i> Thêm mới bệnh nhân
                                            </button>
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination Footer -->
                <c:if test="${totalRecords > 0}">
                    <div class="d-flex align-items-center justify-content-between p-3 border-top flex-wrap gap-2">
                        <div class="text-muted small">
                            Hiển thị từ <strong>${(currentPage - 1) * pageSize + 1}</strong> đến
                            <strong>${(currentPage * pageSize) > totalRecords ? totalRecords : (currentPage * pageSize)}</strong>
                            trong tổng số <strong>${totalRecords}</strong> bệnh nhân
                        </div>
                        <nav aria-label="Page navigation">
                            <ul class="pagination pagination-sm mb-0">
                                <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                                    <a class="page-link" href="${pageContext.request.contextPath}/staff/patients?keyword=${keyword}&accountType=${accountType}&page=${currentPage - 1}">
                                        <i class="bi bi-chevron-left"></i>
                                    </a>
                                </li>
                                <c:forEach begin="1" end="${totalPages}" var="pg">
                                    <c:if test="${pg >= currentPage - 2 && pg <= currentPage + 2}">
                                        <li class="page-item ${pg == currentPage ? 'active' : ''}">
                                            <a class="page-link" href="${pageContext.request.contextPath}/staff/patients?keyword=${keyword}&accountType=${accountType}&page=${pg}">${pg}</a>
                                        </li>
                                    </c:if>
                                </c:forEach>
                                <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                                    <a class="page-link" href="${pageContext.request.contextPath}/staff/patients?keyword=${keyword}&accountType=${accountType}&page=${currentPage + 1}">
                                        <i class="bi bi-chevron-right"></i>
                                    </a>
                                </li>
                            </ul>
                        </nav>
                    </div>
                </c:if>
            </div>

        </div>
    </main>

    <!-- ==================== MODAL 1: THÊM BỆNH NHÂN TẠI QUẦY ==================== -->
    <div class="modal fade" id="createPatientModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow" style="border-radius: 16px;">
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold text-dark">
                        <i class="bi bi-person-plus-fill me-2" style="color: #0d9488;"></i>Tiếp nhận hồ sơ bệnh nhân mới
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="${pageContext.request.contextPath}/staff/patients" method="POST" id="createPatientForm" onsubmit="return validateCreatePatient();">
                    <input type="hidden" name="action" value="create">
                    <div class="modal-body p-4">
                        <div class="alert alert-info py-2 small mb-3 border-0 bg-light-subtle text-muted">
                            <i class="bi bi-info-circle me-1"></i> Dành cho bệnh nhân vãng lai hoặc tiếp nhận khám trực tiếp tại quầy lễ tân.
                        </div>

                        <div class="mb-3">
                            <label class="form-label small fw-semibold">Họ và tên bệnh nhân <span class="text-danger">*</span></label>
                            <input type="text" name="fullName" class="form-control" placeholder="VD: Nguyễn Văn A" required autofocus>
                        </div>

                        <div class="mb-3">
                            <label class="form-label small fw-semibold">Số điện thoại <span class="text-danger">*</span></label>
                            <input type="tel" name="phone" id="createPhoneInput" class="form-control" placeholder="VD: 0912345678" pattern="^(0[3|5|7|8|9])[0-9]{8}$" required>
                            <div class="form-text small" id="phoneHelpText">Nhập đúng 10 số (bắt đầu bằng 03, 05, 07, 08, 09).</div>
                        </div>

                        <div class="row g-2 mb-3">
                            <div class="col-12">
                                <label class="form-label small fw-semibold">Ngày sinh</label>
                                <input type="date" name="dob" class="form-control date-past-only">
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label small fw-semibold">Địa chỉ liên hệ</label>
                            <textarea name="address" class="form-control" rows="2" placeholder="Số nhà, tên đường, phường/xã, quận/huyện..."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer border-0 pt-0 px-4 pb-4">
                        <button type="button" class="btn btn-light" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-teal text-white px-4" style="background-color: #0d9488; border-color: #0d9488;">
                            <i class="bi bi-save me-1"></i> Lưu hồ sơ
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- ==================== MODAL 2: CHỈNH SỬA BỆNH NHÂN ==================== -->
    <div class="modal fade" id="editPatientModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow" style="border-radius: 16px;">
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold text-dark">
                        <i class="bi bi-pencil-square me-2 text-warning"></i>Chỉnh sửa thông tin bệnh nhân
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="${pageContext.request.contextPath}/staff/patients" method="POST" id="editPatientForm">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="patientId" id="editPatientId">

                    <div class="modal-body p-4">
                        <div class="mb-3 d-flex align-items-center justify-content-between p-2 bg-light rounded">
                            <span class="small text-muted">Mã hồ sơ:</span>
                            <span class="fw-bold font-monospace text-teal" id="editFormattedId">#PAT-0000</span>
                        </div>

                        <div class="mb-3">
                            <label class="form-label small fw-semibold">Họ và tên bệnh nhân <span class="text-danger">*</span></label>
                            <input type="text" name="fullName" id="editFullName" class="form-control" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label small fw-semibold">Số điện thoại <span class="text-danger">*</span></label>
                            <input type="tel" name="phone" id="editPhone" class="form-control" pattern="^(0[3|5|7|8|9])[0-9]{8}$" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label small fw-semibold">Ngày sinh</label>
                            <input type="date" name="dob" id="editDob" class="form-control date-past-only">
                        </div>

                        <div class="mb-3">
                            <label class="form-label small fw-semibold">Địa chỉ liên hệ</label>
                            <textarea name="address" id="editAddress" class="form-control" rows="2"></textarea>
                        </div>
                    </div>
                    <div class="modal-footer border-0 pt-0 px-4 pb-4">
                        <button type="button" class="btn btn-light" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-teal text-white px-4" style="background-color: #0d9488; border-color: #0d9488;">
                            <i class="bi bi-check2-circle me-1"></i> Cập nhật thay đổi
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- ==================== MODAL 3: XEM CHI TIẾT & LỊCH SỬ KHÁM ==================== -->
    <div class="modal fade" id="patientDetailModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content border-0 shadow" style="border-radius: 16px;">
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold text-dark">
                        <i class="bi bi-file-earmark-medical me-2" style="color: #0d9488;"></i>Hồ sơ chi tiết & Lịch sử khám bệnh
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <!-- Patient Summary Card -->
                    <div class="card border-0 bg-light p-3 mb-4 rounded-3">
                        <div class="d-flex align-items-center justify-content-between flex-wrap gap-2">
                            <div class="d-flex align-items-center gap-3">
                                <div class="patient-avatar" id="detailAvatar" style="width: 50px; height: 50px; font-size: 20px;">
                                    A
                                </div>
                                <div>
                                    <h5 class="mb-0 fw-bold" id="detailFullName">Nguyễn Văn A</h5>
                                    <div class="text-muted small mt-1">
                                        <span class="patient-id-badge me-2" id="detailFormattedId">#PAT-0001</span>
                                        <span id="detailAccountBadge" class="badge-counter">Tại quầy</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <hr class="my-3 text-secondary-subtle">

                        <div class="row g-2 small">
                            <div class="col-sm-6 col-md-3">
                                <span class="text-muted d-block">Số điện thoại:</span>
                                <strong id="detailPhone" class="text-dark">---</strong>
                            </div>
                            <div class="col-sm-6 col-md-3">
                                <span class="text-muted d-block">Ngày sinh:</span>
                                <strong id="detailDob" class="text-dark">---</strong>
                            </div>
                            <div class="col-sm-6 col-md-3">
                                <span class="text-muted d-block">Email tài khoản:</span>
                                <strong id="detailEmail" class="text-dark">---</strong>
                            </div>
                            <div class="col-sm-6 col-md-3">
                                <span class="text-muted d-block">Tổng số lần khám:</span>
                                <strong id="detailTotalAppt" class="text-teal" style="color: #0d9488;">0 lượt</strong>
                            </div>
                            <div class="col-12 mt-2">
                                <span class="text-muted d-block">Địa chỉ:</span>
                                <span id="detailAddress" class="text-dark">---</span>
                            </div>
                        </div>
                    </div>

                    <!-- Appointment History Section -->
                    <h6 class="fw-bold mb-3 text-dark"><i class="bi bi-clock-history me-2 text-teal" style="color: #0d9488;"></i>Lịch sử các cuộc hẹn & điều trị</h6>
                    <div id="historyContainer">
                        <div class="text-center py-4 text-muted">
                            <div class="spinner-border spinner-border-sm text-teal" role="status"></div>
                            <div class="small mt-2">Đang tải lịch sử khám...</div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0 px-4 pb-4">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        const contextPath = '${pageContext.request.contextPath}';

        // Set max date for date pickers to today & init tooltips
        document.addEventListener('DOMContentLoaded', function() {
            const today = new Date().toISOString().split('T')[0];
            document.querySelectorAll('.date-past-only').forEach(function(el) {
                el.max = today;
            });

            // Initialize Bootstrap tooltips
            const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
            tooltipTriggerList.map(function (tooltipTriggerEl) {
                return new bootstrap.Tooltip(tooltipTriggerEl);
            });
        });

        // 1. View Patient Detail & History
        function viewPatientDetail(patientId) {
            const modalEl = document.getElementById('patientDetailModal');
            const modal = new bootstrap.Modal(modalEl);
            modal.show();

            // Load Basic Detail
            fetch(contextPath + '/staff/patients?ajax=detail&id=' + patientId)
                .then(res => res.json())
                .then(data => {
                    if (data.found) {
                        document.getElementById('detailAvatar').innerText = data.fullName.charAt(0);
                        document.getElementById('detailFullName').innerText = data.fullName;
                        document.getElementById('detailFormattedId').innerText = data.formattedId;
                        document.getElementById('detailPhone').innerText = data.phone;
                        document.getElementById('detailDob').innerText = data.dob ? data.dob : 'Chưa cập nhật';
                        document.getElementById('detailEmail').innerText = data.email ? data.email : 'Chưa liên kết';
                        document.getElementById('detailAddress').innerText = data.address ? data.address : 'Chưa cập nhật';
                        document.getElementById('detailTotalAppt').innerText = data.totalAppointments + ' lượt';

                        const badgeEl = document.getElementById('detailAccountBadge');
                        if (data.hasAccount) {
                            badgeEl.className = 'badge-portal';
                            badgeEl.innerHTML = '<i class="bi bi-check-circle-fill me-1"></i>Trực tuyến';
                        } else {
                            badgeEl.className = 'badge-counter';
                            badgeEl.innerHTML = '<i class="bi bi-person me-1"></i>Tại quầy';
                        }
                    }
                });

            // Load History
            const historyContainer = document.getElementById('historyContainer');
            historyContainer.innerHTML = '<div class="text-center py-4 text-muted"><div class="spinner-border spinner-border-sm text-teal" role="status"></div><div class="small mt-2">Đang tải lịch sử khám...</div></div>';

            fetch(contextPath + '/staff/patients?ajax=history&id=' + patientId)
                .then(res => res.json())
                .then(list => {
                    if (!list || list.length === 0) {
                        historyContainer.innerHTML = '<div class="text-center py-4 text-muted"><i class="bi bi-calendar-x" style="font-size: 30px; color: #cbd5e1;"></i><div class="small mt-2">Bệnh nhân chưa có lịch hẹn nào.</div></div>';
                        return;
                    }

                    let html = '<div class="list-group list-group-flush">';
                    list.forEach(item => {
                        let statusBadge = '';
                        if (item.status === 'Completed') {
                            statusBadge = '<span class="badge bg-success-subtle text-success border border-success-subtle">Hoàn thành</span>';
                        } else if (item.status === 'Confirmed') {
                            statusBadge = '<span class="badge bg-primary-subtle text-primary border border-primary-subtle">Đã xác nhận</span>';
                        } else if (item.status === 'In_Progress') {
                            statusBadge = '<span class="badge bg-warning-subtle text-warning border border-warning-subtle">Đang khám</span>';
                        } else if (item.status === 'Canceled') {
                            statusBadge = '<span class="badge bg-danger-subtle text-danger border border-danger-subtle">Đã hủy</span>';
                        } else {
                            statusBadge = '<span class="badge bg-secondary-subtle text-secondary border">Chờ xử lý</span>';
                        }

                        let diagnosisHtml = '';
                        if (item.diagnosis && item.diagnosis.trim() !== '') {
                            diagnosisHtml = '<div class="col-12 mt-1">' +
                                '<div class="p-2 bg-light rounded text-dark">' +
                                '<i class="bi bi-heart-pulse text-teal me-1"></i><strong>Chẩn đoán:</strong> ' + escapeHtml(item.diagnosis) +
                                '</div></div>';
                        }

                        html += '<div class="list-group-item px-0 py-3 border-bottom">' +
                            '<div class="d-flex align-items-center justify-content-between mb-1">' +
                                '<div class="d-flex align-items-center gap-2">' +
                                    '<span class="patient-id-badge">' + escapeHtml(item.formattedId) + '</span>' +
                                    '<strong>' + escapeHtml(item.serviceName) + '</strong>' +
                                '</div>' +
                                '<div>' + statusBadge + '</div>' +
                            '</div>' +
                            '<div class="row g-2 small text-muted mt-1">' +
                                '<div class="col-sm-6">' +
                                    '<i class="bi bi-calendar-event me-1"></i> Ngày: <strong>' + escapeHtml(item.workDate) + '</strong> (' + escapeHtml(item.time || item.slot || '') + ')' +
                                '</div>' +
                                '<div class="col-sm-6">' +
                                    '<i class="bi bi-person-badge me-1"></i> Bác sĩ: <strong>' + escapeHtml(item.doctorName) + '</strong> ' + (item.specialty ? '(' + escapeHtml(item.specialty) + ')' : '') +
                                '</div>' +
                                '<div class="col-sm-6">' +
                                    '<i class="bi bi-receipt me-1"></i> Viện phí: <strong>' + escapeHtml(item.formattedTotal) + '</strong> (' + escapeHtml(item.invoiceStatus || 'Chưa thanh toán') + ')' +
                                '</div>' +
                                '<div class="col-sm-6">' +
                                    '<i class="bi bi-clock me-1"></i> Đặt lúc: ' + escapeHtml(item.createdAt) +
                                '</div>' +
                                diagnosisHtml +
                            '</div>' +
                        '</div>';
                    });
                    html += '</div>';
                    historyContainer.innerHTML = html;
                })
                .catch(() => {
                    historyContainer.innerHTML = '<div class="alert alert-danger py-2 small">Không thể tải lịch sử khám bệnh.</div>';
                });
        }

        // 2. Open Edit Patient Modal
        function openEditPatient(patientId) {
            fetch(contextPath + '/staff/patients?ajax=detail&id=' + patientId)
                .then(res => res.json())
                .then(data => {
                    if (data.found) {
                        document.getElementById('editPatientId').value = data.id;
                        document.getElementById('editFormattedId').innerText = data.formattedId;
                        document.getElementById('editFullName').value = data.fullName;
                        document.getElementById('editPhone').value = data.phone;
                        document.getElementById('editDob').value = data.dob || '';
                        document.getElementById('editAddress').value = data.address || '';

                        const modal = new bootstrap.Modal(document.getElementById('editPatientModal'));
                        modal.show();
                    }
                });
        }

        // 3. Validate Create Form
        function validateCreatePatient() {
            const phone = document.getElementById('createPhoneInput').value.trim();
            const phoneRegex = /^(0[3|5|7|8|9])[0-9]{8}$/;
            if (!phoneRegex.test(phone)) {
                alert('Số điện thoại không hợp lệ! Vui lòng nhập đúng 10 chữ số (bắt đầu bằng 03, 05, 07, 08, 09).');
                return false;
            }
            return true;
        }

        // 4. Escape HTML Helper
        function escapeHtml(text) {
            if (!text) return '';
            return String(text)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#039;');
        }
    </script>
</body>
</html>
