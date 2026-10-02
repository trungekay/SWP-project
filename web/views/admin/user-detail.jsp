<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết Người dùng - VisionCare Admin</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <style>
        :root {
            --primary-color: #008b74;
            --primary-hover: #00705d;
            --bg-color: #f4f7f9;
            --sidebar-width: 250px;
            --text-main: #333333;
            --text-muted: #6c757d;
            --border-color: #e5e7eb;
        }
        
        body { font-family: 'Inter', sans-serif; background-color: var(--bg-color); color: var(--text-main); overflow-x: hidden; }

        /* --- Sidebar & Header --- */
        .sidebar { width: var(--sidebar-width); height: 100vh; position: fixed; top: 0; left: 0; background-color: #ffffff; border-right: 1px solid var(--border-color); z-index: 1000; }
        .sidebar-brand { height: 70px; display: flex; align-items: center; padding: 0 24px; text-decoration: none; }
        .logo-mark {
            width: 32px; height: 32px; border-radius: 50%;
            background: linear-gradient(135deg, #14b8a6, #0d9488);
            display: inline-flex; align-items: center; justify-content: center;
            color: #fff; font-size: 16px; margin-right: 10px; flex-shrink: 0;
        }
        .brand-text { color: #1e293b; font-weight: 700; font-size: 22px; }
        .sidebar-menu { padding: 15px; list-style: none; margin: 0; }
        .sidebar-menu li a { display: flex; align-items: center; padding: 12px 16px; color: var(--text-muted); text-decoration: none; border-radius: 8px; font-weight: 500; transition: all 0.2s ease; }
        .sidebar-menu li a i { margin-right: 12px; font-size: 18px; }
        .sidebar-menu li a.active { background-color: #f0f7f6; color: var(--primary-color); }

        .main-wrapper { margin-left: var(--sidebar-width); min-height: 100vh; }

        .top-header { height: 70px; background-color: #ffffff; display: flex; align-items: center; justify-content: space-between; padding: 0 30px; border-bottom: 1px solid var(--border-color); }
        .search-bar { position: relative; width: 300px; }
        .search-bar input { width: 100%; padding: 8px 16px 8px 40px; border: 1px solid transparent; background-color: #f1f5f9; border-radius: 20px; font-size: 14px; outline: none; transition: all 0.2s; }
        .search-bar input:focus { background-color: #fff; border-color: var(--primary-color); box-shadow: 0 0 0 3px rgba(0, 139, 116, 0.1); }
        .search-bar i { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: #94a3b8; }
        .header-right { display: flex; align-items: center; gap: 20px; }
        .btn-icon { background: none; border: none; color: var(--text-muted); font-size: 20px; cursor: pointer; position: relative; }
        .btn-icon .badge-dot { position: absolute; top: 0; right: 0; width: 8px; height: 8px; background-color: #ef4444; border-radius: 50%; }
        .user-profile { display: flex; align-items: center; gap: 12px; cursor: pointer; }
        .avatar-circle-sm { width: 40px; height: 40px; border-radius: 50%; background-color: var(--primary-color); color: white; display: flex; align-items: center; justify-content: center; font-weight: 600; font-size: 16px; }
        .user-info .name { font-weight: 600; font-size: 14px; color: #1e293b; margin: 0; line-height: 1.2; }
        .user-info .role { font-size: 12px; color: var(--text-muted); margin: 0; }

        /* --- Page Content Specific --- */
        .page-content { padding: 30px; }
        .page-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; }
        .page-title h2 { font-size: 24px; font-weight: 700; color: #0f172a; margin-bottom: 6px; }
        .page-title p { color: var(--text-muted); font-size: 14px; margin: 0; }
        
        .btn-outline-custom { background-color: white; color: #475569; border: 1px solid #cbd5e1; padding: 10px 16px; border-radius: 8px; font-size: 14px; font-weight: 500; display: inline-flex; align-items: center; gap: 8px; text-decoration: none; transition: all 0.2s; }
        .btn-outline-custom:hover { background-color: #f8fafc; color: #0f172a; }

        /* --- Detail Card --- */
        .detail-card { background: white; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); border: 1px solid rgba(0,0,0,0.05); padding: 32px; max-width: 900px; margin: 0 auto; }
        
        .profile-header { display: flex; align-items: center; justify-content: space-between; padding-bottom: 24px; border-bottom: 1px solid var(--border-color); margin-bottom: 32px; }
        .profile-header-left { display: flex; align-items: center; gap: 24px; }
        
        /* Initials */
        <c:set var="initials" value="${fn:substring(user.fullName, 0, 1)}"/>
        <c:set var="words" value="${fn:split(user.fullName, ' ')}"/>
        <c:if test="${fn:length(words) > 1}">
            <c:set var="initials" value="${fn:substring(words[0], 0, 1)}${fn:substring(words[fn:length(words)-1], 0, 1)}"/>
        </c:if>
        
        .avatar-large { width: 80px; height: 80px; border-radius: 50%; background-color: #fee2e2; color: #dc2626; display: flex; align-items: center; justify-content: center; font-weight: 600; font-size: 28px; }
        .profile-name { font-size: 22px; font-weight: 700; color: #0f172a; margin: 0 0 8px 0; }
        .profile-meta { display: flex; gap: 20px; color: #64748b; font-size: 14px; }
        .profile-meta i { margin-right: 6px; }
        
        .badge-status { padding: 8px 16px; border-radius: 20px; font-size: 13px; font-weight: 500; }
        .status-active { background-color: #dcfce7; color: #166534; }
        .status-inactive { background-color: #fee2e2; color: #b91c1c; }

        /* Form sections */
        .section-title { font-size: 16px; font-weight: 600; color: #0f172a; margin-bottom: 20px; display: flex; align-items: center; gap: 8px; }
        .section-title i { color: var(--primary-color); }
        
        .form-label-custom { font-size: 13px; font-weight: 500; color: #334155; margin-bottom: 6px; display: block; }
        .form-control-custom { width: 100%; padding: 10px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; color: #0f172a; outline: none; transition: all 0.2s; }
        .form-control-custom:focus { border-color: var(--primary-color); box-shadow: 0 0 0 3px rgba(0, 139, 116, 0.1); }
        .form-control-custom:disabled { background-color: #f8fafc; color: #94a3b8; }
        .form-text-custom { font-size: 12px; color: #94a3b8; margin-top: 6px; }

        /* Role cards (Radio buttons) */
        .role-selector { display: flex; flex-direction: column; gap: 12px; }
        .role-card { border: 1px solid #cbd5e1; border-radius: 8px; padding: 16px; cursor: pointer; transition: all 0.2s; position: relative; }
        .role-card:hover { border-color: var(--primary-color); }
        .role-input { position: absolute; opacity: 0; }
        .role-card-content { display: flex; align-items: flex-start; gap: 12px; }
        .radio-custom { width: 18px; height: 18px; border-radius: 50%; border: 2px solid #cbd5e1; margin-top: 2px; position: relative; flex-shrink: 0; }
        .role-info .role-name { font-weight: 600; color: #0f172a; margin: 0 0 4px 0; font-size: 14px; }
        .role-info .role-desc { font-size: 12px; color: #64748b; margin: 0; }
        
        /* Checked state */
        .role-input:checked + .role-card { border-color: var(--primary-color); background-color: #f0f7f6; }
        .role-input:checked + .role-card .radio-custom { border-color: var(--primary-color); }
        .role-input:checked + .role-card .radio-custom::after { content: ''; position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); width: 8px; height: 8px; border-radius: 50%; background-color: var(--primary-color); }

        .form-actions { display: flex; justify-content: flex-end; gap: 12px; margin-top: 40px; border-top: 1px solid var(--border-color); padding-top: 24px; }
        .btn-cancel { background: white; border: 1px solid #cbd5e1; color: #475569; padding: 10px 24px; border-radius: 8px; font-weight: 500; font-size: 14px; transition: all 0.2s; text-decoration: none; }
        .btn-cancel:hover { background-color: #f1f5f9; }
        .btn-submit { background-color: var(--primary-color); color: white; border: none; padding: 10px 24px; border-radius: 8px; font-weight: 500; font-size: 14px; display: flex; align-items: center; gap: 8px; transition: background-color 0.2s; }
        .btn-submit:hover { background-color: var(--primary-hover); }

    </style>
</head>
<body>

    <!-- Sidebar -->
    <aside class="sidebar">
        <a href="#" class="sidebar-brand">
            <span class="logo-mark"><i class="bi bi-eye"></i></span>
            <span class="brand-text">VisionCare</span>
        </a>
        <ul class="sidebar-menu">
            <li>
                <a href="${pageContext.request.contextPath}/admin/users" class="active">
                    <i class="bi bi-person"></i>
                    Quản lý Người dùng
                </a>
            </li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="main-wrapper">
        <header class="top-header">
            <div class="search-bar">
                <i class="bi bi-search"></i>
                <input type="text" placeholder="Tìm kiếm nhanh...">
            </div>
            <div class="header-right">
                <button class="btn-icon">
                    <i class="bi bi-bell"></i>
                    <span class="badge-dot"></span>
                </button>
                <div class="user-profile">
                    <div class="avatar-circle-sm">AU</div>
                    <div class="user-info">
                        <p class="name">Administrator</p>
                        <p class="role">Super Admin</p>
                    </div>
                    <i class="bi bi-chevron-down" style="font-size: 12px; color: #64748b; margin-left: 4px;"></i>
                </div>
            </div>
        </header>

        <div class="page-content">
            <c:if test="${not empty sessionScope.success}">
                <div class="alert alert-success alert-dismissible fade show" role="alert" style="max-width: 900px; margin: 0 auto 20px;">
                    ${sessionScope.success}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="success" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert" style="max-width: 900px; margin: 0 auto 20px;">
                    ${sessionScope.error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="error" scope="session"/>
            </c:if>

            <div class="page-header" style="max-width: 900px; margin: 0 auto 24px;">
                <div class="page-title">
                    <h2>Chi tiết Người dùng</h2>
                    <p>Xem thông tin, Cập nhật hồ sơ, Phân quyền người dùng</p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/users" class="btn-outline-custom">
                    <i class="bi bi-arrow-left"></i> Quay lại danh sách
                </a>
            </div>

            <div class="detail-card">
                <div class="profile-header">
                    <div class="profile-header-left">
                        <div class="avatar-large">
                            ${fn:toUpperCase(initials)}
                        </div>
                        <div>
                            <h3 class="profile-name">${user.fullName}</h3>
                            <div class="profile-meta">
                                <span><i class="bi bi-envelope"></i> ${user.email}</span>
                                <span><i class="bi bi-calendar3"></i> Tham gia: 20/09/2026</span>
                            </div>
                        </div>
                    </div>
                    <div>
                        <c:choose>
                            <c:when test="${user.status == 'Active'}">
                                <span class="badge-status status-active">Đang hoạt động</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge-status status-inactive">Đã khóa</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <form action="${pageContext.request.contextPath}/admin/users/detail" method="post">
                    <input type="hidden" name="id" value="${user.id}">
                    <input type="hidden" name="action" value="updateRole">
                    
                    <div class="row">
                        <!-- Left Column: Update Info -->
                        <div class="col-md-6 pe-md-4">
                            <h4 class="section-title"><i class="bi bi-pencil-square"></i> Cập nhật thông tin</h4>
                            
                            <div class="mb-3">
                                <label class="form-label-custom">Họ và Tên</label>
                                <input type="text" class="form-control-custom" value="${user.fullName}" disabled>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label-custom">Email</label>
                                <input type="email" class="form-control-custom" value="${user.email}" disabled>
                                <div class="form-text-custom">Email không thể thay đổi sau khi tạo.</div>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label-custom">Số điện thoại</label>
                                <input type="text" class="form-control-custom" value="${user.phone}" disabled>
                            </div>
                        </div>
                        
                        <!-- Right Column: Assign Role -->
                        <div class="col-md-6 ps-md-4 border-start">
                            <h4 class="section-title"><i class="bi bi-shield-lock"></i> Phân quyền người dùng</h4>
                            <label class="form-label-custom mb-3">Vai trò (Role)</label>
                            
                            <div class="role-selector">
                                <label>
                                    <input type="radio" name="roleId" value="1" class="role-input" ${user.roleId == 1 ? 'checked' : ''}>
                                    <div class="role-card"><div class="role-card-content"><div class="radio-custom"></div><div class="role-info"><p class="role-name">Admin</p><p class="role-desc">Toàn quyền hệ thống</p></div></div></div>
                                </label>
                                
                                <label>
                                    <input type="radio" name="roleId" value="6" class="role-input" ${user.roleId == 6 ? 'checked' : ''}>
                                    <div class="role-card"><div class="role-card-content"><div class="radio-custom"></div><div class="role-info"><p class="role-name">Director</p><p class="role-desc">Giám đốc phòng khám</p></div></div></div>
                                </label>
                                
                                <label>
                                    <input type="radio" name="roleId" value="4" class="role-input" ${user.roleId == 4 ? 'checked' : ''}>
                                    <div class="role-card"><div class="role-card-content"><div class="radio-custom"></div><div class="role-info"><p class="role-name">Staff</p><p class="role-desc">Nhân viên y tế</p></div></div></div>
                                </label>
                                
                                <label>
                                    <input type="radio" name="roleId" value="2" class="role-input" ${user.roleId == 2 ? 'checked' : ''}>
                                    <div class="role-card"><div class="role-card-content"><div class="radio-custom"></div><div class="role-info"><p class="role-name">Doctor</p><p class="role-desc">Bác sĩ khám bệnh</p></div></div></div>
                                </label>

                                <label>
                                    <input type="radio" name="roleId" value="3" class="role-input" ${user.roleId == 3 ? 'checked' : ''}>
                                    <div class="role-card"><div class="role-card-content"><div class="radio-custom"></div><div class="role-info"><p class="role-name">Specialist</p><p class="role-desc">Chuyên gia y tế</p></div></div></div>
                                </label>

                                <label>
                                    <input type="radio" name="roleId" value="5" class="role-input" ${user.roleId == 5 ? 'checked' : ''}>
                                    <div class="role-card"><div class="role-card-content"><div class="radio-custom"></div><div class="role-info"><p class="role-name">Patient</p><p class="role-desc">Khách hàng (Bệnh nhân)</p></div></div></div>
                                </label>
                            </div>
                        </div>
                    </div>

                    <div class="form-actions">
                        <a href="${pageContext.request.contextPath}/admin/users" class="btn-cancel">Hủy bỏ</a>
                        <button type="submit" class="btn-submit">
                            <i class="bi bi-save"></i> Lưu thay đổi
                        </button>
                    </div>
                </form>
            </div>
            
        </div>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
