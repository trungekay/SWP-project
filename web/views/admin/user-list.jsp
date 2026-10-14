<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Người Dùng - VisionCare Admin</title>

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

    <!-- Admin Layout CSS -->
    <jsp:include page="/views/admin/layout/admin-css.jsp" />

    <style>
        .admin-card {
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            padding: 24px;
        }

        /* Modern Premium Table Styling with Borders - Matches Clinic Config */
        .table-custom {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            border-radius: 12px;
            overflow: hidden;
            border: 1px solid #cbd5e1;
        }

        .table-custom thead {
            background-color: #f0fdf4;
        }

        .table-custom thead th {
            color: #15803d;
            font-size: 13px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 16px 20px;
            border-bottom: 2px solid #dcfce7;
            border-right: 1px solid #dcfce7;
            border-top: none;
            white-space: nowrap;
        }

        .table-custom thead th:last-child {
            border-right: none;
        }

        .table-custom tbody td {
            padding: 16px 20px;
            vertical-align: middle;
            color: #334155;
            font-size: 14px;
            font-weight: 500;
            border-bottom: 1px solid #f1f5f9;
            border-right: 1px solid #f1f5f9;
        }

        .table-custom tbody td:last-child {
            border-right: none;
        }

        .table-custom tbody tr:last-child td {
            border-bottom: none;
        }

        .table-custom tbody tr:hover {
            background-color: #f8fafc;
        }

        /* Action buttons inside table */
        .table-custom .btn-sm {
            padding: 5px 9px;
            font-size: 13px;
            border-radius: 6px;
            transition: all 0.18s ease;
        }

        .table-custom .btn-outline-primary {
            color: #18a05e;
            border-color: #bbf7d0;
            background-color: #f0fdf4;
        }

        .table-custom .btn-outline-primary:hover {
            background-color: #18a05e !important;
            border-color: #18a05e !important;
            color: #ffffff !important;
            box-shadow: 0 2px 6px rgba(24, 160, 94, 0.25);
        }

        .table-custom .btn-outline-warning {
            color: #d97706;
            border-color: #fde68a;
            background-color: #fffbeb;
        }

        .table-custom .btn-outline-warning:hover {
            background-color: #d97706 !important;
            border-color: #d97706 !important;
            color: #ffffff !important;
            box-shadow: 0 2px 6px rgba(217, 119, 6, 0.25);
        }

        .table-custom .btn-outline-success {
            color: #16a34a;
            border-color: #bbf7d0;
            background-color: #f0fdf4;
        }

        .table-custom .btn-outline-success:hover {
            background-color: #16a34a !important;
            border-color: #16a34a !important;
            color: #ffffff !important;
            box-shadow: 0 2px 6px rgba(22, 163, 74, 0.25);
        }

        .table-custom .btn-outline-danger {
            color: #dc2626;
            border-color: #fecaca;
            background-color: #fef2f2;
        }

        .table-custom .btn-outline-danger:hover {
            background-color: #dc2626 !important;
            border-color: #dc2626 !important;
            color: #ffffff !important;
            box-shadow: 0 2px 6px rgba(220, 38, 38, 0.25);
        }

        /* Override Primary Colors to Logo Green */
        .btn-primary {
            background-color: #18a05e !important;
            border-color: #18a05e !important;
            color: #fff !important;
        }

        .btn-primary:hover,
        .btn-primary:focus,
        .btn-primary:active {
            background-color: #12824b !important;
            border-color: #12824b !important;
            color: #fff !important;
            box-shadow: 0 4px 12px rgba(24, 160, 94, 0.3) !important;
        }

        .text-primary {
            color: #18a05e !important;
        }

        .bg-primary {
            background-color: #18a05e !important;
        }

        /* Config Tab Button - Identical to Clinic Config */
        .config-tab-btn {
            border: 1px solid #e2e8f0;
            background: #fff;
            color: #475569;
            padding: 8px 18px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 14px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s;
        }

        .config-tab-btn:hover {
            background: #f1f5f9;
            color: #0f172a;
            border-color: #cbd5e1;
            transform: translateY(-1px);
        }

        .config-tab-btn.active {
            background: #18a05e;
            color: #fff;
            border-color: #18a05e;
            box-shadow: 0 3px 10px rgba(24, 160, 94, 0.25);
        }

        .config-tab-btn .badge {
            font-size: 11px;
            padding: 3px 8px;
            border-radius: 12px;
        }

        /* User Identity Cell */
        .user-cell {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .avatar-initial {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 13px;
            flex-shrink: 0;
            text-transform: uppercase;
        }

        .avatar-0 { background-color: #e0f2fe; color: #0284c7; }
        .avatar-1 { background-color: #fef3c7; color: #d97706; }
        .avatar-2 { background-color: #dcfce7; color: #15803d; }
        .avatar-3 { background-color: #f3e8ff; color: #7e22ce; }
        .avatar-4 { background-color: #fee2e2; color: #dc2626; }

        .user-details .name {
            font-weight: 600;
            color: #0f172a;
            margin: 0;
            font-size: 14px;
        }

        .user-details .email {
            font-size: 12px;
            color: #64748b;
            margin: 0;
        }

        /* Role Badges */
        .badge-role {
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
            white-space: nowrap;
        }

        .role-superadmin { background-color: #ede9fe; color: #6d28d9; border: 1px solid #ddd6fe; }
        .role-director { background-color: #ffedd5; color: #c2410c; border: 1px solid #fed7aa; }
        .role-doctor { background-color: #dbeafe; color: #1d4ed8; border: 1px solid #bfdbfe; }
        .role-specialist { background-color: #e0e7ff; color: #4338ca; border: 1px solid #c7d2fe; }
        .role-staff { background-color: #fef3c7; color: #b45309; border: 1px solid #fde68a; }
        .role-patient { background-color: #f1f5f9; color: #475569; border: 1px solid #e2e8f0; }

        /* Status Badges */
        .badge-status {
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        .status-active { background-color: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; }
        .status-inactive { background-color: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; }

        /* Filter Controls */
        .filter-search-box {
            position: relative;
            min-width: 260px;
        }

        .filter-search-box i {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
            font-size: 14px;
        }

        .filter-search-box input {
            padding-left: 38px;
            border-radius: 8px;
            border: 1px solid #cbd5e1;
            font-size: 14px;
        }

        .filter-search-box input:focus {
            border-color: #18a05e;
            box-shadow: 0 0 0 3px rgba(24, 160, 94, 0.15);
        }

        .filter-select {
            border-radius: 8px;
            border: 1px solid #cbd5e1;
            font-size: 14px;
            padding: 7px 12px;
            color: #334155;
            background-color: #fff;
        }

        .filter-select:focus {
            border-color: #18a05e;
            box-shadow: 0 0 0 3px rgba(24, 160, 94, 0.15);
            outline: none;
        }

        /* Pagination matching green theme */
        .pagination-container {
            padding: 16px 0 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-top: 1px solid #f1f5f9;
            margin-top: 16px;
        }

        .pagination-info {
            font-size: 13px;
            color: #64748b;
            font-weight: 500;
        }

        .custom-pagination {
            display: flex;
            gap: 4px;
            margin: 0;
            padding: 0;
            list-style: none;
        }

        .custom-pagination li a {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 32px;
            height: 32px;
            border-radius: 6px;
            border: 1px solid #e2e8f0;
            color: #475569;
            text-decoration: none;
            font-size: 13px;
            font-weight: 500;
            transition: all 0.2s;
        }

        .custom-pagination li a:hover {
            background-color: #f1f5f9;
            border-color: #cbd5e1;
        }

        .custom-pagination li a.active {
            background-color: #18a05e;
            color: white;
            border-color: #18a05e;
            box-shadow: 0 2px 6px rgba(24, 160, 94, 0.25);
        }

        /* Modal Dialog Styling */
        .modal-content {
            border: none;
            border-radius: 16px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
        }

        .modal-icon-circle {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            margin: 0 auto 16px;
        }

        .modal-icon-warning { background-color: #fffbeb; color: #d97706; }
        .modal-icon-success { background-color: #f0fdf4; color: #16a34a; }
        .modal-icon-danger { background-color: #fef2f2; color: #dc2626; }
    </style>
</head>

<body>
    <c:set var="currentType" value="${empty param.type ? 'staff' : param.type}" />

    <!-- Count Staff and Patients -->
    <c:set var="staffCount" value="0" />
    <c:set var="patientCount" value="0" />
    <c:forEach var="u" items="${users}">
        <c:choose>
            <c:when test="${u.role == 'Patient' || u.role == 'patient'}">
                <c:set var="patientCount" value="${patientCount + 1}" />
            </c:when>
            <c:otherwise>
                <c:set var="staffCount" value="${staffCount + 1}" />
            </c:otherwise>
        </c:choose>
    </c:forEach>

    <!-- Sidebar Include -->
    <jsp:include page="/views/admin/layout/admin-sidebar.jsp">
        <jsp:param name="activeNav" value="users" />
        <jsp:param name="activeSub" value="${currentType}" />
    </jsp:include>

    <!-- Main Content -->
    <main class="main-wrapper">
        <!-- Header Include -->
        <jsp:include page="/views/admin/layout/admin-header.jsp" />

        <div class="page-content">
            <!-- Page Header -->
            <div class="page-header d-flex flex-wrap justify-content-between align-items-center gap-3">
                <div class="page-title">
                    <c:choose>
                        <c:when test="${currentType == 'patient'}">
                            <h2>Quản lý Khách hàng &amp; Bệnh nhân</h2>
                            <p class="text-muted">Quản lý hồ sơ bệnh nhân và tài khoản khách hàng trong hệ thống</p>
                        </c:when>
                        <c:otherwise>
                            <h2>Quản lý Nhân sự &amp; Nội bộ</h2>
                            <p class="text-muted">Quản lý tài khoản cán bộ nhân viên, bác sĩ và phân quyền hệ thống</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Tab Navigation Buttons for Quick Switching (Format identical to Clinic Config) -->
            <div class="d-flex flex-wrap gap-2 mb-4">
                <a href="${pageContext.request.contextPath}/admin/users?type=staff"
                   class="config-tab-btn ${currentType != 'patient' ? 'active' : ''}">
                    <i class="bi bi-person-badge"></i> Nhân sự nội bộ
                    <span class="badge ${currentType != 'patient' ? 'bg-white text-success' : 'bg-light text-muted'}">${staffCount}</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/users?type=patient"
                   class="config-tab-btn ${currentType == 'patient' ? 'active' : ''}">
                    <i class="bi bi-people"></i> Khách hàng &amp; Bệnh nhân
                    <span class="badge ${currentType == 'patient' ? 'bg-white text-success' : 'bg-light text-muted'}">${patientCount}</span>
                </a>
            </div>

            <!-- Flash Session Alerts -->
            <c:if test="${not empty sessionScope.error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>${sessionScope.error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="error" scope="session" />
            </c:if>
            <c:if test="${not empty sessionScope.success}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i>${sessionScope.success}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="success" scope="session" />
            </c:if>

            <!-- Card Section -->
            <div class="admin-card">
                <!-- Card Header with Title and Add Button -->
                <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
                    <h5 class="mb-0 fw-bold">
                        <c:choose>
                            <c:when test="${currentType == 'patient'}">
                                <i class="bi bi-people me-2 text-primary"></i>Danh sách Tài khoản Bệnh nhân
                            </c:when>
                            <c:otherwise>
                                <i class="bi bi-person-badge me-2 text-primary"></i>Danh sách Tài khoản Nội bộ
                            </c:otherwise>
                        </c:choose>
                    </h5>
                    <a href="${pageContext.request.contextPath}/admin/users/add?type=${currentType == 'patient' ? 'patient' : 'employee'}" class="btn btn-sm btn-primary">
                        <i class="bi bi-plus-lg me-1"></i> Thêm người dùng
                    </a>
                </div>

                <!-- Filter and Search Toolbar -->
                <div class="d-flex flex-wrap gap-3 align-items-center mb-4">
                    <div class="filter-search-box flex-grow-1" style="max-width: 320px;">
                        <i class="bi bi-search"></i>
                        <input type="text" id="userSearchInput" class="form-control" placeholder="Tìm theo tên, email, SĐT..." onkeyup="filterUserTable()">
                    </div>

                    <c:if test="${currentType != 'patient'}">
                        <select class="filter-select" id="userRoleFilter" onchange="filterUserTable()">
                            <option value="">Tất cả vai trò</option>
                            <option value="System_Admin">System Admin</option>
                            <option value="Director">Director</option>
                            <option value="Doctor">Doctor</option>
                            <option value="Medical_Specialist">Medical Specialist</option>
                            <option value="Staff">Staff</option>
                        </select>
                    </c:if>

                    <select class="filter-select" id="userStatusFilter" onchange="filterUserTable()">
                        <option value="">Tất cả trạng thái</option>
                        <option value="Active">Hoạt động</option>
                        <option value="Inactive">Đã khóa</option>
                    </select>
                </div>

                <!-- Users Table -->
                <div class="table-responsive">
                    <table class="table align-middle table-custom" id="mainUserTable">
                        <thead>
                            <tr>
                                <c:choose>
                                    <c:when test="${currentType == 'patient'}">
                                        <th>Thông tin Bệnh nhân</th>
                                        <th>Số điện thoại</th>
                                        <th>Địa chỉ / Ngày sinh</th>
                                        <th>Trạng thái</th>
                                        <th class="text-end">Thao tác</th>
                                    </c:when>
                                    <c:otherwise>
                                        <th>Thông tin Người dùng</th>
                                        <th>Số điện thoại</th>
                                        <th>Vai trò (Role)</th>
                                        <th>Trạng thái</th>
                                        <th class="text-end">Thao tác</th>
                                    </c:otherwise>
                                </c:choose>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="user" items="${users}">
                                <c:set var="isThisPatient" value="${user.role == 'Patient' || user.role == 'patient'}" />
                                
                                <%-- Filter row based on active tab --%>
                                <c:if test="${(currentType == 'patient' && isThisPatient) || (currentType != 'patient' && !isThisPatient)}">
                                    <tr class="user-row"
                                        data-role="${user.role == 'admin' ? 'System_Admin' : user.role}"
                                        data-status="${user.status}">
                                        <td>
                                            <div class="user-cell">
                                                <%-- Calculate Initials --%>
                                                <c:set var="initials" value="${fn:substring(user.fullName, 0, 1)}" />
                                                <c:set var="words" value="${fn:split(user.fullName, ' ')}" />
                                                <c:if test="${fn:length(words) > 1}">
                                                    <c:set var="initials" value="${fn:substring(words[0], 0, 1)}${fn:substring(words[fn:length(words)-1], 0, 1)}" />
                                                </c:if>
                                                <c:set var="colorIdx" value="${user.id % 5}" />
                                                <div class="avatar-initial avatar-${colorIdx}">
                                                    ${fn:toUpperCase(initials)}
                                                </div>
                                                <div class="user-details">
                                                    <p class="name">${user.fullName}</p>
                                                    <p class="email">${user.email}</p>
                                                </div>
                                            </div>
                                        </td>
                                        <td>${not empty user.phone ? user.phone : '—'}</td>
                                        
                                        <c:choose>
                                            <c:when test="${currentType == 'patient'}">
                                                <td>
                                                    <div class="small text-muted">
                                                        <c:if test="${not empty user.dob}">
                                                            <div><i class="bi bi-calendar3 me-1"></i>${user.dob}</div>
                                                        </c:if>
                                                        <c:if test="${not empty user.address}">
                                                            <div class="text-truncate" style="max-width: 250px;"><i class="bi bi-geo-alt me-1"></i>${user.address}</div>
                                                        </c:if>
                                                        <c:if test="${empty user.dob && empty user.address}">
                                                            —
                                                        </c:if>
                                                    </div>
                                                </td>
                                            </c:when>
                                            <c:otherwise>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${user.role == 'admin' || user.role == 'System_Admin'}">
                                                            <span class="badge-role role-superadmin"><i class="bi bi-shield-lock me-1"></i>System Admin</span>
                                                        </c:when>
                                                        <c:when test="${user.role == 'Director' || user.role == 'director'}">
                                                            <span class="badge-role role-director"><i class="bi bi-person-gear me-1"></i>Director</span>
                                                        </c:when>
                                                        <c:when test="${user.role == 'Doctor' || user.role == 'doctor'}">
                                                            <span class="badge-role role-doctor"><i class="bi bi-heart-pulse me-1"></i>Doctor</span>
                                                        </c:when>
                                                        <c:when test="${user.role == 'Medical_Specialist' || user.role == 'medical_specialist'}">
                                                            <span class="badge-role role-specialist"><i class="bi bi-activity me-1"></i>Specialist</span>
                                                        </c:when>
                                                        <c:when test="${user.role == 'Staff' || user.role == 'staff'}">
                                                            <span class="badge-role role-staff"><i class="bi bi-person-badge me-1"></i>Staff</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge-role role-patient">Patient</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </c:otherwise>
                                        </c:choose>

                                        <td>
                                            <c:choose>
                                                <c:when test="${user.status == 'Active'}">
                                                    <span class="badge-status status-active">
                                                        <i class="bi bi-check-circle-fill"></i> Hoạt động
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-status status-inactive">
                                                        <i class="bi bi-lock-fill"></i> Đã khóa
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-end">
                                            <div class="d-inline-flex gap-1 justify-content-end">
                                                <a href="${pageContext.request.contextPath}/admin/users/detail?id=${user.id}"
                                                   class="btn btn-sm btn-outline-primary" title="Xem chi tiết & Cập nhật">
                                                    <i class="bi bi-pencil"></i>
                                                </a>
                                                <c:choose>
                                                    <c:when test="${user.status == 'Active'}">
                                                        <button type="button" class="btn btn-sm btn-outline-warning"
                                                                title="Vô hiệu hóa tài khoản"
                                                                onclick="openDeactivateModal(${user.id}, '${fn:escapeXml(user.fullName)}')">
                                                            <i class="bi bi-lock"></i>
                                                        </button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button type="button" class="btn btn-sm btn-outline-success"
                                                                title="Kích hoạt tài khoản"
                                                                onclick="openActivateModal(${user.id}, '${fn:escapeXml(user.fullName)}')">
                                                            <i class="bi bi-unlock"></i>
                                                        </button>
                                                    </c:otherwise>
                                                </c:choose>
                                                <button type="button" class="btn btn-sm btn-outline-danger"
                                                        title="Xóa tài khoản"
                                                        onclick="openDeleteModal(${user.id}, '${fn:escapeXml(user.fullName)}')">
                                                    <i class="bi bi-trash"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:if>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <!-- Empty State Message -->
                <div id="emptyNotice" class="text-center py-5 text-muted" style="display: none;">
                    <i class="bi bi-inbox fs-1 d-block mb-2 text-secondary"></i>
                    <span>Không tìm thấy người dùng phù hợp.</span>
                </div>

                <!-- Pagination Container -->
                <div class="pagination-container" id="paginationWrap">
                    <div class="pagination-info" id="paginationInfo">
                        Hiển thị 0 của 0 người dùng
                    </div>
                    <ul class="custom-pagination" id="paginationUl">
                    </ul>
                </div>
            </div>
        </div>
    </main>

    <!-- Modal Vô hiệu hóa Tài khoản -->
    <div class="modal fade" id="deactivateModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <div class="modal-header border-0 pb-0">
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4 text-center">
                    <div class="modal-icon-circle modal-icon-warning">
                        <i class="bi bi-lock"></i>
                    </div>
                    <h4 class="fw-bold mb-2 text-dark">Vô hiệu hóa tài khoản?</h4>
                    <p class="text-muted mb-4 fs-6">
                        Bạn có chắc chắn muốn khóa tài khoản của <strong id="deactivateUserName">người dùng</strong>?<br>
                        Tài khoản này sẽ không thể đăng nhập vào hệ thống sau khi khóa.
                    </p>
                    <form action="${pageContext.request.contextPath}/admin/users" method="post" id="deactivateForm">
                        <input type="hidden" name="id" id="deactivateUserId">
                        <input type="hidden" name="action" value="deactivate">
                        <input type="hidden" name="type" value="${currentType}">
                        <div class="d-flex justify-content-center gap-2">
                            <button type="button" class="btn btn-secondary px-4 rounded-pill" data-bs-dismiss="modal">Hủy</button>
                            <button type="submit" class="btn btn-warning px-4 rounded-pill text-white fw-semibold">Xác nhận khóa</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Kích hoạt Tài khoản -->
    <div class="modal fade" id="activateModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <div class="modal-header border-0 pb-0">
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4 text-center">
                    <div class="modal-icon-circle modal-icon-success">
                        <i class="bi bi-unlock"></i>
                    </div>
                    <h4 class="fw-bold mb-2 text-dark">Kích hoạt tài khoản?</h4>
                    <p class="text-muted mb-4 fs-6">
                        Mở khóa tài khoản cho <strong id="activateUserName">người dùng</strong>.<br>
                        Người dùng sẽ có thể đăng nhập và tiếp tục làm việc trên hệ thống.
                    </p>
                    <form action="${pageContext.request.contextPath}/admin/users" method="post" id="activateForm">
                        <input type="hidden" name="id" id="activateUserId">
                        <input type="hidden" name="action" value="activate">
                        <input type="hidden" name="type" value="${currentType}">
                        <div class="d-flex justify-content-center gap-2">
                            <button type="button" class="btn btn-secondary px-4 rounded-pill" data-bs-dismiss="modal">Hủy</button>
                            <button type="submit" class="btn btn-success px-4 rounded-pill fw-semibold">Kích hoạt lại</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Xóa Tài khoản -->
    <div class="modal fade" id="deleteModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <div class="modal-header border-0 pb-0">
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4 text-center">
                    <div class="modal-icon-circle modal-icon-danger">
                        <i class="bi bi-trash"></i>
                    </div>
                    <h4 class="fw-bold mb-2 text-danger">Xác nhận xóa tài khoản?</h4>
                    <p class="text-muted mb-4 fs-6">
                        Bạn có chắc chắn muốn xóa tài khoản của <strong id="deleteUserName">người dùng</strong>?<br>
                        Hành động này không thể hoàn tác nếu không có bản sao lưu cơ sở dữ liệu.
                    </p>
                    <form action="${pageContext.request.contextPath}/admin/users" method="post" id="deleteForm">
                        <input type="hidden" name="id" id="deleteUserId">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="type" value="${currentType}">
                        <div class="d-flex justify-content-center gap-2">
                            <button type="button" class="btn btn-secondary px-4 rounded-pill" data-bs-dismiss="modal">Hủy</button>
                            <button type="submit" class="btn btn-danger px-4 rounded-pill fw-semibold">Xóa tài khoản</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Client-side Filtering and Pagination Scripts -->
    <script>
        const rowsPerPage = 10;

        function renderUserPagination(currentPage) {
            const table = document.getElementById("mainUserTable");
            const tbody = table.querySelector("tbody");
            const allRows = Array.from(tbody.querySelectorAll("tr.user-row"));
            const visibleRows = allRows.filter(row => row.getAttribute("data-filtered") !== "false");

            const totalRows = visibleRows.length;
            const totalPages = Math.ceil(totalRows / rowsPerPage) || 1;
            if (currentPage > totalPages) currentPage = totalPages;
            if (currentPage < 1) currentPage = 1;

            allRows.forEach(row => {
                row.style.display = "none";
            });

            const startIdx = (currentPage - 1) * rowsPerPage;
            const endIdx = Math.min(startIdx + rowsPerPage, totalRows);
            for (let i = startIdx; i < endIdx; i++) {
                visibleRows[i].style.display = "";
            }

            const infoEl = document.getElementById("paginationInfo");
            const ulEl = document.getElementById("paginationUl");
            const emptyEl = document.getElementById("emptyNotice");
            const tableWrap = table.closest(".table-responsive");

            if (totalRows === 0) {
                if (tableWrap) tableWrap.style.display = "none";
                if (emptyEl) emptyEl.style.display = "block";
                infoEl.textContent = 'Không tìm thấy kết quả nào';
                ulEl.innerHTML = "";
                return;
            } else {
                if (tableWrap) tableWrap.style.display = "";
                if (emptyEl) emptyEl.style.display = "none";
                infoEl.textContent = 'Hiển thị ' + (startIdx + 1) + ' - ' + endIdx + ' của ' + totalRows + ' người dùng';
            }

            ulEl.innerHTML = "";

            if (totalPages > 1) {
                const liPrev = document.createElement("li");
                const aPrev = document.createElement("a");
                aPrev.href = "javascript:void(0)";
                aPrev.innerHTML = '<i class="bi bi-chevron-left"></i>';
                if (currentPage === 1) {
                    liPrev.style.opacity = "0.4";
                    liPrev.style.pointerEvents = "none";
                } else {
                    aPrev.onclick = () => renderUserPagination(currentPage - 1);
                }
                liPrev.appendChild(aPrev);
                ulEl.appendChild(liPrev);

                for (let i = 1; i <= totalPages; i++) {
                    const li = document.createElement("li");
                    const a = document.createElement("a");
                    a.href = "javascript:void(0)";
                    a.textContent = i;
                    if (i === currentPage) a.className = "active";
                    a.onclick = () => renderUserPagination(i);
                    li.appendChild(a);
                    ulEl.appendChild(li);
                }

                const liNext = document.createElement("li");
                const aNext = document.createElement("a");
                aNext.href = "javascript:void(0)";
                aNext.innerHTML = '<i class="bi bi-chevron-right"></i>';
                if (currentPage === totalPages) {
                    liNext.style.opacity = "0.4";
                    liNext.style.pointerEvents = "none";
                } else {
                    aNext.onclick = () => renderUserPagination(currentPage + 1);
                }
                liNext.appendChild(aNext);
                ulEl.appendChild(liNext);
            }
        }

        function filterUserTable() {
            const roleFilterEl = document.getElementById("userRoleFilter");
            const roleFilter = roleFilterEl ? roleFilterEl.value : "";
            const statusFilter = document.getElementById("userStatusFilter").value;
            const searchFilter = document.getElementById("userSearchInput").value.trim().toLowerCase();
            const rows = document.querySelectorAll("#mainUserTable tbody tr.user-row");

            rows.forEach(function (row) {
                const role = row.getAttribute("data-role") || "";
                const status = row.getAttribute("data-status") || "";

                const nameEl = row.querySelector(".name");
                const emailEl = row.querySelector(".email");
                const nameText = nameEl ? nameEl.textContent.toLowerCase() : "";
                const emailText = emailEl ? emailEl.textContent.toLowerCase() : "";
                const phoneText = row.children[1] ? row.children[1].textContent.toLowerCase() : "";

                const matchRole = (!roleFilter || role === roleFilter);
                const matchStatus = (!statusFilter || status === statusFilter);
                const matchSearch = (!searchFilter ||
                    nameText.includes(searchFilter) ||
                    emailText.includes(searchFilter) ||
                    phoneText.includes(searchFilter));

                if (matchRole && matchStatus && matchSearch) {
                    row.setAttribute("data-filtered", "true");
                } else {
                    row.setAttribute("data-filtered", "false");
                }
            });

            renderUserPagination(1);
        }

        function openDeactivateModal(id, name) {
            document.getElementById('deactivateUserId').value = id;
            document.getElementById('deactivateUserName').textContent = name || 'người dùng này';
            new bootstrap.Modal(document.getElementById('deactivateModal')).show();
        }

        function openActivateModal(id, name) {
            document.getElementById('activateUserId').value = id;
            document.getElementById('activateUserName').textContent = name || 'người dùng này';
            new bootstrap.Modal(document.getElementById('activateModal')).show();
        }

        function openDeleteModal(id, name) {
            document.getElementById('deleteUserId').value = id;
            document.getElementById('deleteUserName').textContent = name || 'người dùng này';
            new bootstrap.Modal(document.getElementById('deleteModal')).show();
        }

        document.addEventListener("DOMContentLoaded", function () {
            filterUserTable();
        });
    </script>
</body>
</html>
