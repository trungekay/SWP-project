<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thêm Người dùng - VisionCare Admin</title>
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
        
        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--bg-color);
            color: var(--text-main);
            overflow-x: hidden;
        }

        /* --- Sidebar & Header (Shared Styles) --- */
        .sidebar {
            width: var(--sidebar-width);
            height: 100vh;
            position: fixed;
            top: 0;
            left: 0;
            background-color: #ffffff;
            border-right: 1px solid var(--border-color);
            z-index: 1000;
        }
        .sidebar-brand { height: 70px; display: flex; align-items: center; padding: 0 24px; text-decoration: none; }
        .logo-mark {
            width: 32px; height: 32px; border-radius: 50%;
            background: linear-gradient(135deg, #14b8a6, #0d9488);
            display: inline-flex; align-items: center; justify-content: center;
            color: #fff; font-size: 16px; margin-right: 10px; flex-shrink: 0;
        }
        .brand-text { color: #1e293b; font-weight: 700; font-size: 22px; }
        .sidebar-menu { padding: 15px; list-style: none; margin: 0; }
        .sidebar-menu li a {
            display: flex; align-items: center; padding: 12px 16px; color: var(--text-muted);
            text-decoration: none; border-radius: 8px; font-weight: 500; transition: all 0.2s ease;
        }
        .sidebar-menu li a i { margin-right: 12px; font-size: 18px; }
        .sidebar-menu li a.active { background-color: #f0f7f6; color: var(--primary-color); }

        .main-wrapper { margin-left: var(--sidebar-width); min-height: 100vh; }

        .top-header {
            height: 70px; background-color: #ffffff; display: flex; align-items: center;
            justify-content: space-between; padding: 0 30px; border-bottom: 1px solid var(--border-color);
        }
        .search-bar { position: relative; width: 300px; }
        .search-bar input {
            width: 100%; padding: 8px 16px 8px 40px; border: 1px solid transparent;
            background-color: #f1f5f9; border-radius: 20px; font-size: 14px; outline: none; transition: all 0.2s;
        }
        .search-bar input:focus { background-color: #fff; border-color: var(--primary-color); box-shadow: 0 0 0 3px rgba(0, 139, 116, 0.1); }
        .search-bar i { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: #94a3b8; }
        .header-right { display: flex; align-items: center; gap: 20px; }
        .btn-icon { background: none; border: none; color: var(--text-muted); font-size: 20px; cursor: pointer; position: relative; }
        .btn-icon .badge-dot { position: absolute; top: 0; right: 0; width: 8px; height: 8px; background-color: #ef4444; border-radius: 50%; }
        .user-profile { display: flex; align-items: center; gap: 12px; cursor: pointer; }
        .avatar-circle { width: 40px; height: 40px; border-radius: 50%; background-color: var(--primary-color); color: white; display: flex; align-items: center; justify-content: center; font-weight: 600; font-size: 16px; }
        .user-info .name { font-weight: 600; font-size: 14px; color: #1e293b; margin: 0; line-height: 1.2; }
        .user-info .role { font-size: 12px; color: var(--text-muted); margin: 0; }

        /* --- Page Content Specific --- */
        .page-content { padding: 30px; }
        .page-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; }
        .page-title h2 { font-size: 24px; font-weight: 700; color: #0f172a; margin-bottom: 6px; }
        .page-title p { color: var(--text-muted); font-size: 14px; margin: 0; }
        
        .btn-outline-custom {
            background-color: white; color: #475569; border: 1px solid #cbd5e1; padding: 10px 16px;
            border-radius: 8px; font-size: 14px; font-weight: 500; display: inline-flex; align-items: center;
            gap: 8px; text-decoration: none; transition: all 0.2s;
        }
        .btn-outline-custom:hover { background-color: #f8fafc; color: #0f172a; }

        /* --- Form Card --- */
        .form-card {
            background: white; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            border: 1px solid rgba(0,0,0,0.05); padding: 32px; max-width: 600px; margin: 0 auto;
        }
        .form-title { font-size: 18px; font-weight: 600; color: #0f172a; margin-bottom: 24px; }
        
        .form-label-custom {
            font-size: 13px; font-weight: 500; color: #334155; margin-bottom: 6px; display: block;
        }
        .form-control-custom {
            width: 100%; padding: 10px 16px; border: 1px solid #cbd5e1; border-radius: 8px;
            font-size: 14px; color: #0f172a; outline: none; transition: all 0.2s;
        }
        .form-control-custom:focus {
            border-color: var(--primary-color); box-shadow: 0 0 0 3px rgba(0, 139, 116, 0.1);
        }
        .form-control-custom::placeholder { color: #94a3b8; }
        .form-group { margin-bottom: 20px; }

        .form-actions {
            display: flex; justify-content: flex-end; gap: 12px; margin-top: 32px;
        }
        .btn-cancel {
            background: white; border: 1px solid #cbd5e1; color: #475569; padding: 10px 24px;
            border-radius: 8px; font-weight: 500; font-size: 14px; transition: all 0.2s; text-decoration: none;
        }
        .btn-cancel:hover { background-color: #f1f5f9; }
        .btn-submit {
            background-color: var(--primary-color); color: white; border: none; padding: 10px 24px;
            border-radius: 8px; font-weight: 500; font-size: 14px; display: flex; align-items: center; gap: 8px;
            transition: background-color 0.2s;
        }
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
        <!-- Header -->
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
                    <div class="avatar-circle" style="width: 36px; height: 36px; font-size: 14px;">
                        AU
                    </div>
                    <div class="user-info">
                        <p class="name">Administrator</p>
                        <p class="role">Super Admin</p>
                    </div>
                    <i class="bi bi-chevron-down" style="font-size: 12px; color: #64748b; margin-left: 4px;"></i>
                </div>
            </div>
        </header>

        <!-- Page Content -->
        <div class="page-content">
            
            <c:if test="${not empty error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert" style="max-width: 600px; margin: 0 auto 20px;">
                    ${error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <div class="page-header">
                <div class="page-title">
                    <h2>Thêm Người dùng</h2>
                    <p>Thêm người dùng mới vào hệ thống</p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/users" class="btn-outline-custom">
                    <i class="bi bi-arrow-left"></i> Quay lại danh sách
                </a>
            </div>

            <div class="form-card">
                <h3 class="form-title">Thông tin người dùng mới</h3>
                
                <form action="${pageContext.request.contextPath}/admin/users/add" method="post">
                    <div class="form-group">
                        <label class="form-label-custom">Họ và Tên</label>
                        <input type="text" name="fullName" class="form-control-custom" placeholder="Nhập họ và tên đầy đủ" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label-custom">Email</label>
                        <input type="email" name="email" class="form-control-custom" placeholder="example@system.com" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label-custom">Số điện thoại</label>
                        <input type="text" name="phone" class="form-control-custom" placeholder="09xx xxx xxx">
                    </div>
                    
                    <!-- Form select role cho UI, giá trị thực tế truyền qua input hidden hoặc select. Ở đây dùng dropdown cho gọn, hoac có thẻ dùng select. Trong mockup không thấy dropdown role ở form thêm, nhưng yêu cầu cần chọn vai trò. Sẽ thêm dropdown role. -->
                    <div class="form-group">
                        <label class="form-label-custom">Vai trò hệ thống</label>
                        <select name="roleId" class="form-control-custom" style="background-color: white;">
                            <option value="1">Admin</option>
                            <option value="6">Director</option>
                            <option value="4">Staff</option>
                            <option value="2">Doctor</option>
                            <option value="3">Specialist</option>
                            <option value="5">Patient</option>
                        </select>
                    </div>

                    <div class="form-group mb-0">
                        <label class="form-label-custom">Mật khẩu khởi tạo</label>
                        <input type="password" name="password" class="form-control-custom" placeholder="••••••••" required>
                    </div>

                    <div class="form-actions">
                        <a href="${pageContext.request.contextPath}/admin/users" class="btn-cancel">Hủy bỏ</a>
                        <button type="submit" class="btn-submit">
                            <i class="bi bi-save"></i> Thêm Người dùng
                        </button>
                    </div>
                </form>
            </div>
            
        </div>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
