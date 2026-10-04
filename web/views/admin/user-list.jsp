<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh sách Người dùng - VisionCare Admin</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <jsp:include page="/views/admin/layout/admin-css.jsp" />
    <style>
        .btn-primary-custom {
            background-color: var(--primary-color);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 500;
            font-size: 14px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            transition: background-color 0.2s;
        }
        .btn-primary-custom:hover {
            background-color: var(--primary-hover);
            color: white;
        }
        .btn-outline-custom {
            background-color: white;
            color: #475569;
            border: 1px solid #cbd5e1;
            padding: 8px 16px;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            transition: all 0.2s;
        }
        .btn-outline-custom:hover {
            background-color: #f8fafc;
            color: #0f172a;
        }

        /* --- Card & Table --- */
        .content-card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            border: 1px solid rgba(0,0,0,0.05);
            overflow: hidden;
        }
        .table-toolbar {
            padding: 16px 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #f1f5f9;
        }
        .filter-group {
            display: flex;
            gap: 12px;
        }
        .filter-select {
            padding: 8px 32px 8px 16px;
            border: 1px solid #e2e8f0;
            border-radius: 6px;
            font-size: 14px;
            color: #475569;
            outline: none;
            appearance: none;
            background: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/200%2Fsvg' width='16' height='16' fill='%2364748b' class='bi bi-chevron-down' viewBox='0 0 16 16'%3E%3Cpath fill-rule='evenodd' d='M1.646 4.646a.5.5 0 0 1 .708 0L8 10.293l5.646-5.647a.5.5 0 0 1 .708.708l-6 6a.5.5 0 0 1-.708 0l-6-6a.5.5 0 0 1 0-.708z'/%3E%3C/svg%3E") no-repeat right 12px center;
            background-color: white;
        }
        
        .custom-table {
            width: 100%;
            margin: 0;
            border-collapse: collapse;
        }
        .custom-table th {
            background-color: white;
            color: #64748b;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 16px 24px;
            border-bottom: 1px solid #e2e8f0;
        }
        .custom-table td {
            padding: 16px 24px;
            vertical-align: middle;
            border-bottom: 1px solid #f1f5f9;
            font-size: 14px;
            color: #334155;
        }
        .custom-table tbody tr:hover {
            background-color: #f8fafc;
        }

        /* --- User Cell Styles --- */
        .user-cell {
            display: flex;
            align-items: center;
            gap: 16px;
        }
        .avatar-initial {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 14px;
        }
        /* Random background colors for avatars based on initials could be done with JS, here we hardcode a few styles or use inline */
        .avatar-red { background-color: #fee2e2; color: #dc2626; }
        .avatar-orange { background-color: #ffedd5; color: #ea580c; }
        .avatar-green { background-color: #d1fae5; color: #059669; }
        .avatar-blue { background-color: #e0e7ff; color: #4f46e5; }
        .avatar-purple { background-color: #f3e8ff; color: #9333ea; }
        
        .user-details .name {
            font-weight: 600;
            color: #0f172a;
            margin: 0 0 4px 0;
        }
        .user-details .email {
            font-size: 13px;
            color: #64748b;
            margin: 0;
        }

        /* --- Badges --- */
        .badge-role {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
            display: inline-block;
        }
        .role-superadmin { background-color: #e0e7ff; color: #4338ca; }
        .role-manager { background-color: #ffedd5; color: #c2410c; }
        .role-doctor { background-color: #dbeafe; color: #1d4ed8; }
        .role-specialist { background-color: #fce7f3; color: #be185d; }
        .role-staff { background-color: #fef3c7; color: #b45309; }
        .role-user { background-color: #f1f5f9; color: #475569; }

        .badge-status {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
            display: inline-block;
        }
        .status-active { background-color: #dcfce7; color: #166534; }
        .status-inactive { background-color: #fee2e2; color: #b91c1c; }

        /* --- Actions --- */
        .action-btns {
            display: flex;
            gap: 12px;
            align-items: center;
        }
        .action-btn {
            color: #64748b;
            font-size: 16px;
            text-decoration: none;
            background: none;
            border: none;
            padding: 0;
            cursor: pointer;
            transition: color 0.2s;
        }
        .action-btn:hover { color: #0f172a; }
        .action-btn.delete:hover { color: #ef4444; }

        /* --- Pagination --- */
        .pagination-container {
            padding: 16px 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-top: 1px solid #f1f5f9;
        }
        .pagination-info {
            font-size: 14px;
            color: #64748b;
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
            font-size: 14px;
            transition: all 0.2s;
        }
        .custom-pagination li a:hover {
            background-color: #f1f5f9;
        }
        .custom-pagination li a.active {
            background-color: var(--primary-color);
            color: white;
            border-color: var(--primary-color);
        }

        /* --- Modals --- */
        .modal-content {
            border: none;
            border-radius: 16px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
        }
        .modal-header {
            border-bottom: none;
            padding: 24px 24px 0;
        }
        .modal-body {
            padding: 24px;
            text-align: center;
        }
        .modal-icon-warning {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            background-color: #fef3c7;
            color: #d97706;
            font-size: 28px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
        }
        .modal-icon-danger {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            background-color: #fee2e2;
            color: #dc2626;
            font-size: 28px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
        }
        .modal-icon-success {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            background-color: #dcfce7;
            color: #16a34a;
            font-size: 28px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
        }
        .modal-title-custom {
            font-size: 20px;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 12px;
        }
        .modal-text {
            color: #64748b;
            font-size: 14px;
            margin-bottom: 24px;
            line-height: 1.5;
        }
        .modal-actions {
            display: flex;
            justify-content: center;
            gap: 12px;
        }
        .btn-modal-cancel {
            background: white;
            border: 1px solid #cbd5e1;
            color: #475569;
            padding: 10px 24px;
            border-radius: 8px;
            font-weight: 500;
        }
        .btn-modal-warning {
            background-color: #f59e0b;
            border: none;
            color: white;
            padding: 10px 24px;
            border-radius: 8px;
            font-weight: 500;
        }
        .btn-modal-danger {
            background-color: #ef4444;
            border: none;
            color: white;
            padding: 10px 24px;
            border-radius: 8px;
            font-weight: 500;
        }
        .btn-modal-success {
            background-color: var(--primary-color);
            border: none;
            color: white;
            padding: 10px 24px;
            border-radius: 8px;
            font-weight: 500;
        }
        .btn-modal-success:hover {
            background-color: var(--primary-hover);
        }
        
    </style>
</head>
<body>

    <jsp:include page="/views/admin/layout/admin-sidebar.jsp">
        <jsp:param name="activeNav" value="users" />
    </jsp:include>

    <!-- Main Content -->
    <main class="main-wrapper">
        <!-- Header -->
        <jsp:include page="/views/admin/layout/admin-header.jsp" />

        <!-- Page Content -->
        <div class="page-content">
            
            <c:if test="${not empty sessionScope.success}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    ${sessionScope.success}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="success" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    ${sessionScope.error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="error" scope="session"/>
            </c:if>

            <div class="page-header">
                <div class="page-title">
                    <h2>Danh sách Người dùng</h2>
                    <p>Quản lý toàn bộ người dùng trong hệ thống (Xem, Xóa, Khóa, Mở khóa)</p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/users/add" class="btn-primary-custom">
                    <i class="bi bi-plus-lg"></i> Thêm Người dùng
                </a>
            </div>

            <div class="content-card">
                <div class="table-toolbar">
                    <div class="filter-group">
                        <select class="filter-select" id="roleFilter" onchange="filterTable()">
                            <option value="">Tất cả vai trò</option>
                            <option value="System_Admin">System Admin</option>
                            <option value="Director">Director</option>
                            <option value="Doctor">Doctor</option>
                            <option value="Medical_Specialist">Medical Specialist</option>
                            <option value="Staff">Staff</option>
                            <option value="Patient">Patient</option>
                        </select>
                        <select class="filter-select" id="statusFilter" onchange="filterTable()">
                            <option value="">Trạng thái</option>
                            <option value="Active">Hoạt động</option>
                            <option value="Inactive">Đã khóa</option>
                        </select>
                        <div class="search-bar" style="display: inline-flex; align-items: center; margin-left: 15px;">
                            <input type="text" id="searchInput" placeholder="Tìm kiếm nhanh..." onkeyup="filterTable()" style="border: 1px solid #e2e8f0; border-radius: 20px; padding: 6px 12px; outline: none;">
                        </div>
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>THÔNG TIN USER</th>
                                <th>SỐ ĐIỆN THOẠI</th>
                                <th>VAI TRÒ (ROLE)</th>
                                <th>TRẠNG THÁI</th>
                                <th class="text-end">THAO TÁC</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="user" items="${users}">
                                <tr data-role="${user.role == 'admin' ? 'System_Admin' : user.role}" data-status="${user.status}">
                                    <td>
                                        <div class="user-cell">
                                            <!-- Create Initials -->
                                            <c:set var="initials" value="${fn:substring(user.fullName, 0, 1)}"/>
                                            <c:set var="words" value="${fn:split(user.fullName, ' ')}"/>
                                            <c:if test="${fn:length(words) > 1}">
                                                <c:set var="initials" value="${fn:substring(words[0], 0, 1)}${fn:substring(words[fn:length(words)-1], 0, 1)}"/>
                                            </c:if>
                                            
                                            <!-- Random Color Class based on ID -->
                                            <c:set var="colorClass" value="avatar-blue"/>
                                            <c:if test="${user.id % 5 == 1}"><c:set var="colorClass" value="avatar-red"/></c:if>
                                            <c:if test="${user.id % 5 == 2}"><c:set var="colorClass" value="avatar-orange"/></c:if>
                                            <c:if test="${user.id % 5 == 3}"><c:set var="colorClass" value="avatar-green"/></c:if>
                                            <c:if test="${user.id % 5 == 4}"><c:set var="colorClass" value="avatar-purple"/></c:if>

                                            <div class="avatar-initial ${colorClass}">
                                                ${fn:toUpperCase(initials)}
                                            </div>
                                            <div class="user-details">
                                                <p class="name">${user.fullName}</p>
                                                <p class="email">${user.email}</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td>${not empty user.phone ? user.phone : '—'}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${user.role == 'admin' || user.role == 'System_Admin'}">
                                                <span class="badge-role role-superadmin">System Admin</span>
                                            </c:when>
                                            <c:when test="${user.role == 'Director'}">
                                                <span class="badge-role role-manager">Director</span>
                                            </c:when>
                                            <c:when test="${user.role == 'Doctor'}">
                                                <span class="badge-role role-doctor">Doctor</span>
                                            </c:when>
                                            <c:when test="${user.role == 'Medical_Specialist'}">
                                                <span class="badge-role role-specialist">Medical Specialist</span>
                                            </c:when>
                                            <c:when test="${user.role == 'Staff'}">
                                                <span class="badge-role role-staff">Staff</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge-role role-user">Patient</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${user.status == 'Active'}">
                                                <span class="badge-status status-active">Hoạt động</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge-status status-inactive">Đã khóa</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="action-btns justify-content-end">
                                            <a href="${pageContext.request.contextPath}/admin/users/detail?id=${user.id}" class="action-btn" title="Xem chi tiết">
                                                <i class="bi bi-eye"></i>
                                            </a>
                                            
                                            <c:choose>
                                                <c:when test="${user.status == 'Active'}">
                                                    <button type="button" class="action-btn" title="Vô hiệu hóa" onclick="openDeactivateModal(${user.id})">
                                                        <i class="bi bi-lock"></i>
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <button type="button" class="action-btn" title="Kích hoạt" onclick="openActivateModal(${user.id})">
                                                        <i class="bi bi-unlock"></i>
                                                    </button>
                                                </c:otherwise>
                                            </c:choose>
                                            
                                            <button type="button" class="action-btn delete" title="Xóa" onclick="openDeleteModal(${user.id})">
                                                <i class="bi bi-trash"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
                
                <div class="pagination-container">
                    <div class="pagination-info">
                        Hiển thị 1 - ${fn:length(users)} của ${fn:length(users)} người dùng
                    </div>
                    <ul class="custom-pagination">
                        <li><a href="#"><i class="bi bi-chevron-left"></i></a></li>
                        <li><a href="#" class="active">1</a></li>
                        <li><a href="#">2</a></li>
                        <li><a href="#">3</a></li>
                        <li><a href="#"><i class="bi bi-chevron-right"></i></a></li>
                    </ul>
                </div>
            </div>
        </div>
    </main>

    <!-- Modal Vô hiệu hóa -->
    <div class="modal fade" id="deactivateModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="modal-icon-warning">
                        <i class="bi bi-lock"></i>
                    </div>
                    <h3 class="modal-title-custom">Vô hiệu hóa tài khoản?</h3>
                    <p class="modal-text">Tài khoản này sẽ bị vô hiệu hóa và không thể đăng nhập vào hệ thống.</p>
                    <form action="${pageContext.request.contextPath}/admin/users" method="post" id="deactivateForm">
                        <input type="hidden" name="id" id="deactivateUserId">
                        <input type="hidden" name="action" value="deactivate">
                        <div class="modal-actions">
                            <button type="button" class="btn btn-modal-cancel" data-bs-dismiss="modal">Hủy</button>
                            <button type="submit" class="btn btn-modal-warning">Vô hiệu hóa</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Kích hoạt (Ẩn trong mockup nhưng logic cần có) -->
    <div class="modal fade" id="activateModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="modal-icon-success">
                        <i class="bi bi-unlock"></i>
                    </div>
                    <h3 class="modal-title-custom">Kích hoạt tài khoản?</h3>
                    <p class="modal-text">Tài khoản này sẽ được mở khóa và có thể đăng nhập lại vào hệ thống.</p>
                    <form action="${pageContext.request.contextPath}/admin/users" method="post" id="activateForm">
                        <input type="hidden" name="id" id="activateUserId">
                        <input type="hidden" name="action" value="activate">
                        <div class="modal-actions">
                            <button type="button" class="btn btn-modal-cancel" data-bs-dismiss="modal">Hủy</button>
                            <button type="submit" class="btn btn-modal-success">Kích hoạt</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Xóa -->
    <div class="modal fade" id="deleteModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="modal-icon-danger">
                        <i class="bi bi-trash"></i>
                    </div>
                    <h3 class="modal-title-custom">Xóa tài khoản?</h3>
                    <p class="modal-text">Bạn có chắc chắn muốn xóa vĩnh viễn tài khoản này?<br>Hành động này không thể hoàn tác.</p>
                    <form action="${pageContext.request.contextPath}/admin/users" method="post" id="deleteForm">
                        <input type="hidden" name="id" id="deleteUserId">
                        <input type="hidden" name="action" value="delete">
                        <div class="modal-actions">
                            <button type="button" class="btn btn-modal-cancel" data-bs-dismiss="modal">Hủy</button>
                            <button type="submit" class="btn btn-modal-danger">Xóa vĩnh viễn</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function filterTable() {
            var roleFilter = document.getElementById("roleFilter").value;
            var statusFilter = document.getElementById("statusFilter").value;
            var searchFilter = document.getElementById("searchInput").value.toLowerCase();
            var rows = document.querySelectorAll("tbody tr");

            rows.forEach(function(row) {
                var role = row.getAttribute("data-role");
                var status = row.getAttribute("data-status");
                
                var nameText = row.querySelector(".name").textContent.toLowerCase();
                var emailText = row.querySelector(".email").textContent.toLowerCase();
                var phoneText = row.children[1].textContent.toLowerCase();
                
                var matchRole = (roleFilter === "" || role === roleFilter);
                var matchStatus = (statusFilter === "" || status === statusFilter);
                var matchSearch = (searchFilter === "" || 
                                   nameText.includes(searchFilter) || 
                                   emailText.includes(searchFilter) || 
                                   phoneText.includes(searchFilter));

                if (matchRole && matchStatus && matchSearch) {
                    row.style.display = "";
                } else {
                    row.style.display = "none";
                }
            });
        }

        function openDeactivateModal(id) {
            document.getElementById('deactivateUserId').value = id;
            new bootstrap.Modal(document.getElementById('deactivateModal')).show();
        }
        function openActivateModal(id) {
            document.getElementById('activateUserId').value = id;
            new bootstrap.Modal(document.getElementById('activateModal')).show();
        }
        function openDeleteModal(id) {
            document.getElementById('deleteUserId').value = id;
            new bootstrap.Modal(document.getElementById('deleteModal')).show();
        }
    </script>
</body>
</html>
