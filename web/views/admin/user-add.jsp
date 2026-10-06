<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thêm Người Dùng - VisionCare Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
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
        
        /* Sidebar & Header (Simplified for inclusion) */
        .sidebar { width: var(--sidebar-width); height: 100vh; position: fixed; top: 0; left: 0; background-color: #ffffff; border-right: 1px solid var(--border-color); z-index: 1000; }
        .sidebar-brand { height: 70px; display: flex; align-items: center; padding: 0 24px; text-decoration: none; }
        .logo-mark { width: 32px; height: 32px; border-radius: 50%; background: linear-gradient(135deg, #14b8a6, #0d9488); display: inline-flex; align-items: center; justify-content: center; color: #fff; font-size: 16px; margin-right: 10px; }
        .brand-text { color: #1e293b; font-weight: 700; font-size: 22px; }
        .sidebar-menu { padding: 15px; list-style: none; margin: 0; }
        .sidebar-menu li a { display: flex; align-items: center; padding: 12px 16px; color: var(--text-muted); text-decoration: none; border-radius: 8px; font-weight: 500; }
        .sidebar-menu li a.active { background-color: #f0f7f6; color: var(--primary-color); }
        .sidebar-menu li a i { margin-right: 12px; font-size: 18px; }
        
        .main-wrapper { margin-left: var(--sidebar-width); min-height: 100vh; }
        .top-header { height: 70px; background-color: #ffffff; display: flex; align-items: center; justify-content: flex-end; padding: 0 30px; border-bottom: 1px solid var(--border-color); }
        .user-profile { display: flex; align-items: center; gap: 12px; }
        .avatar-circle { width: 40px; height: 40px; border-radius: 50%; background-color: var(--primary-color); color: white; display: flex; align-items: center; justify-content: center; font-weight: 600; font-size: 16px; }
        .user-info .name { font-weight: 600; font-size: 14px; color: #1e293b; margin: 0; }
        .user-info .role { font-size: 12px; color: var(--text-muted); margin: 0; }

        .page-content { padding: 40px; max-width: 1000px; margin: 0 auto; }
        .page-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 30px; }
        .page-title h2 { font-size: 24px; font-weight: 700; color: #0f172a; margin-bottom: 6px; }
        .page-title p { color: var(--text-muted); font-size: 14px; margin: 0; }
        
        .btn-back { background-color: white; border: 1px solid #cbd5e1; color: #475569; padding: 8px 16px; border-radius: 6px; font-size: 14px; font-weight: 500; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; }
        .btn-back:hover { background-color: #f8fafc; color: #0f172a; }

        .form-card { background: white; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); padding: 40px; max-width: 700px; margin: 0 auto; }
        .form-card h3 { font-size: 18px; font-weight: 600; color: #1e293b; margin-bottom: 24px; }
        
        .form-label { font-size: 14px; font-weight: 500; color: #334155; margin-bottom: 8px; }
        .form-control, .form-select { border: 1px solid #cbd5e1; padding: 10px 16px; border-radius: 8px; font-size: 14px; color: #0f172a; transition: all 0.2s; }
        .form-control:focus, .form-select:focus { border-color: var(--primary-color); box-shadow: 0 0 0 3px rgba(0, 139, 116, 0.1); }
        .form-control::placeholder { color: #94a3b8; }
        
        .form-actions { display: flex; justify-content: flex-end; gap: 16px; margin-top: 32px; padding-top: 24px; border-top: 1px solid #f1f5f9; }
        .btn-cancel { background: white; border: 1px solid #cbd5e1; color: #475569; padding: 10px 24px; border-radius: 8px; font-weight: 500; font-size: 14px; text-decoration: none; }
        .btn-cancel:hover { background-color: #f8fafc; color: #0f172a; }
        .btn-submit { background-color: var(--primary-color); border: none; color: white; padding: 10px 24px; border-radius: 8px; font-weight: 500; font-size: 14px; display: inline-flex; align-items: center; gap: 8px; cursor: pointer; }
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
                <a href="${pageContext.request.contextPath}/admin/dashboard">
                    <i class="bi bi-graph-up"></i>
                    Dashboard Doanh thu
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/users" class="active">
                    <i class="bi bi-person"></i>
                    Quản lý Người dùng
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/clinic-config">
                    <i class="bi bi-gear"></i>
                    Cấu hình Phòng Khám
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/catalog">
                    <i class="bi bi-box"></i>
                    Quản lý Danh mục (Dịch vụ/Vật tư)
                </a>
            </li>
        </ul>
    </aside>

    <main class="main-wrapper">
        <header class="top-header">
            <div class="header-right">
                <div class="user-profile">
                    <div class="avatar-circle">AU</div>
                    <div class="user-info">
                        <p class="name">Administrator</p>
                        <p class="role">Super Admin</p>
                    </div>
                </div>
            </div>
        </header>

        <div class="page-content">
            <div class="page-header">
                <div class="page-title">
                    <h2>Thêm Người dùng</h2>
                    <p>Thêm người dùng mới vào hệ thống</p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/users" class="btn-back">
                    <i class="bi bi-arrow-left"></i> Quay lại danh sách
                </a>
            </div>

            <c:if test="${not empty requestScope.error}">
                <div class="alert alert-danger" style="max-width: 700px; margin: 0 auto 20px;">${requestScope.error}</div>
            </c:if>

            <div class="form-card">
                <h3>Thông tin người dùng mới</h3>
                <form action="${pageContext.request.contextPath}/admin/users/add" method="POST">
                    <div class="mb-4">
                        <label class="form-label">Họ và Tên</label>
                        <input type="text" name="fullName" class="form-control" placeholder="Nhập họ và tên đầy đủ" required>
                    </div>
                    
                    <div class="mb-4">
                        <label class="form-label">Email</label>
                        <input type="email" name="email" class="form-control" placeholder="example@system.com" required>
                    </div>
                    
                    <div class="mb-4">
                        <label class="form-label">Số điện thoại</label>
                        <input type="text" name="phone" class="form-control" placeholder="09xx xxx xxx" pattern="[0-9]{10}" maxlength="10" minlength="10" title="Số điện thoại phải gồm đúng 10 chữ số" required>
                    </div>

                    <div class="mb-4">
                        <label class="form-label">Ngày sinh (DOB)</label>
                        <input type="text" name="dob" class="form-control" placeholder="dd/mm/yyyy" pattern="\d{2}/\d{2}/\d{4}" title="Nhập ngày sinh theo định dạng dd/mm/yyyy">
                    </div>

                    <div class="mb-4">
                        <label class="form-label">Địa chỉ</label>
                        <input type="text" name="address" class="form-control" placeholder="Nhập địa chỉ của bạn">
                    </div>
                    
                    <div class="mb-4">
                        <label class="form-label">Mật khẩu khởi tạo</label>
                        <input type="password" name="password" class="form-control" placeholder="********" required>
                    </div>

                    <div class="mb-4">
                        <label class="form-label">Vai trò (Role)</label>
                        <select name="roleId" class="form-select" ${param.type == 'patient' ? 'readonly style="pointer-events: none; background-color: #f8fafc;"' : ''}>
                            <c:choose>
                                <c:when test="${param.type == 'patient'}">
                                    <option value="6" selected>Patient (Khách hàng cơ bản)</option>
                                </c:when>
                                <c:otherwise>
                                    <option value="5">Staff (Nhân viên)</option>
                                    <option value="3">Doctor (Bác sĩ)</option>
                                    <option value="4">Medical Specialist (Kỹ thuật viên)</option>
                                    <option value="2">Director (Quản lý)</option>
                                    <option value="1">System Admin (Toàn quyền)</option>
                                </c:otherwise>
                            </c:choose>
                        </select>
                        <c:if test="${param.type == 'patient'}">
                            <div class="form-text text-muted">Bạn đang tạo hồ sơ cho Bệnh nhân mới.</div>
                        </c:if>
                    </div>

                    <c:if test="${param.type == 'employee'}">
                        <div id="doctorFields" style="display: none; margin-top: 1.5rem; padding-top: 1.5rem; border-top: 1px solid #e2e8f0;">
                            <h4 class="mb-3" style="font-size: 16px; color: #0f172a;"><i class="bi bi-briefcase-medical"></i> Thông tin Chuyên môn (Dành cho Bác sĩ)</h4>
                            <div class="mb-3">
                                <label class="form-label">Mã Chứng chỉ hành nghề (License)</label>
                                <input type="text" name="licenseNumber" class="form-control" placeholder="VD: BS-12345/EYE">
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Chuyên khoa</label>
                                <input type="text" name="specialty" class="form-control" placeholder="VD: Nhãn khoa tổng quát">
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Phòng làm việc (ID)</label>
                                <input type="number" name="roomId" class="form-control" placeholder="Nhập ID phòng (ví dụ: 1, 2, 3...)">
                            </div>
                        </div>
                    </c:if>

                    <div class="form-actions mt-4">
                        <a href="${pageContext.request.contextPath}/admin/users" class="btn-cancel">Hủy bỏ</a>
                        <button type="submit" class="btn-submit">
                            <i class="bi bi-plus-square"></i> Thêm Người dùng
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>

    <script>
        function checkRole() {
            var roleSelect = document.querySelector('select[name="roleId"]');
            var doctorFields = document.getElementById('doctorFields');
            if (roleSelect && doctorFields) {
                var val = roleSelect.value;
                if (val == '3' || val == '4') {
                    doctorFields.style.display = 'block';
                } else {
                    doctorFields.style.display = 'none';
                }
            }
        }
        document.addEventListener('DOMContentLoaded', function() {
            var roleSelect = document.querySelector('select[name="roleId"]');
            if(roleSelect) {
                roleSelect.addEventListener('change', checkRole);
                checkRole();
            }
        });
    </script>
</body>
</html>
