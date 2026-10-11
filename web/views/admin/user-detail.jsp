<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi Tiết Người Dùng - VisionCare Admin</title>
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
        .avatar-circle-sm { width: 40px; height: 40px; border-radius: 50%; background-color: var(--primary-color); color: white; display: flex; align-items: center; justify-content: center; font-weight: 600; font-size: 16px; }
        .user-info .name { font-weight: 600; font-size: 14px; color: #1e293b; margin: 0; }
        .user-info .role { font-size: 12px; color: var(--text-muted); margin: 0; }

        .page-content { padding: 40px; max-width: 1100px; margin: 0 auto; }
        
        .profile-card { background: white; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); padding: 32px; }
        
        /* Profile Header */
        .profile-header { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 40px; padding-bottom: 30px; border-bottom: 1px solid #f1f5f9; }
        .profile-identity { display: flex; align-items: center; gap: 20px; }
        .avatar-circle-lg { width: 80px; height: 80px; border-radius: 50%; background-color: #fee2e2; color: #dc2626; display: flex; align-items: center; justify-content: center; font-weight: 600; font-size: 28px; }
        .profile-name { font-size: 22px; font-weight: 700; color: #0f172a; margin-bottom: 4px; }
        .profile-meta { font-size: 14px; color: #64748b; display: flex; align-items: center; gap: 16px; }
        .profile-meta i { margin-right: 6px; }
        .status-badge { background-color: #dcfce7; color: #166534; padding: 6px 16px; border-radius: 20px; font-size: 13px; font-weight: 500; }
        .status-badge.inactive { background-color: #fee2e2; color: #b91c1c; }

        /* Forms section */
        .section-title { font-size: 16px; font-weight: 600; color: #1e293b; margin-bottom: 24px; display: flex; align-items: center; gap: 8px; }
        .section-title i { color: var(--primary-color); }
        
        .form-label { font-size: 14px; font-weight: 500; color: #334155; margin-bottom: 8px; }
        .form-control { border: 1px solid #cbd5e1; padding: 10px 16px; border-radius: 8px; font-size: 14px; color: #0f172a; transition: all 0.2s; }
        .form-control:disabled { background-color: #f8fafc; color: #64748b; }
        .form-text { font-size: 12px; color: #94a3b8; margin-top: 6px; }
        
        /* Radio Cards for Role */
        .role-grid { display: flex; flex-direction: column; gap: 12px; }
        .role-card { border: 1px solid #e2e8f0; border-radius: 8px; padding: 16px; cursor: pointer; transition: all 0.2s; position: relative; display: block; }
        .role-card:hover { border-color: #cbd5e1; background-color: #f8fafc; }
        .role-card input[type="radio"] { position: absolute; opacity: 0; }
        .role-card input[type="radio"]:checked + .role-content { border-color: var(--primary-color); }
        .role-card.selected { border-color: var(--primary-color); background-color: #f0fdfa; box-shadow: 0 0 0 1px var(--primary-color); }
        
        .role-content { display: flex; align-items: flex-start; gap: 12px; }
        .radio-custom { width: 18px; height: 18px; border-radius: 50%; border: 2px solid #cbd5e1; margin-top: 2px; position: relative; }
        .role-card.selected .radio-custom { border-color: var(--primary-color); }
        .role-card.selected .radio-custom::after { content: ''; position: absolute; width: 10px; height: 10px; background: var(--primary-color); border-radius: 50%; top: 50%; left: 50%; transform: translate(-50%, -50%); }
        
        .role-info .title { font-weight: 600; font-size: 14px; color: #0f172a; margin-bottom: 4px; display: block; }
        .role-info .desc { font-size: 12px; color: #64748b; margin: 0; }

        .form-actions { display: flex; justify-content: flex-end; gap: 16px; margin-top: 40px; padding-top: 24px; border-top: 1px solid #f1f5f9; }
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
                    <div class="avatar-circle-sm">AU</div>
                    <div class="user-info">
                        <p class="name">Administrator</p>
                        <p class="role">Super Admin</p>
                    </div>
                </div>
            </div>
        </header>

        <div class="page-content">
            <div class="mb-4 text-end">
                <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-arrow-left"></i> Quay lại danh sách
                </a>
            </div>

            <c:if test="${not empty requestScope.message}">
                <div class="alert alert-success">${requestScope.message}</div>
            </c:if>

            <div class="profile-card">
                <!-- Profile Header -->
                <div class="profile-header">
                    <div class="profile-identity">
                        <c:set var="initials" value="${fn:substring(user.fullName, 0, 1)}"/>
                        <c:set var="words" value="${fn:split(user.fullName, ' ')}"/>
                        <c:if test="${fn:length(words) > 1}">
                            <c:set var="initials" value="${fn:substring(words[0], 0, 1)}${fn:substring(words[fn:length(words)-1], 0, 1)}"/>
                        </c:if>
                        <div class="avatar-circle-lg">
                            ${fn:toUpperCase(initials)}
                        </div>
                        <div>
                            <h2 class="profile-name">${user.fullName}</h2>
                            <div class="profile-meta">
                                <span><i class="bi bi-envelope"></i> ${user.email}</span>
                            </div>
                        </div>
                    </div>
                    <div>
                        <c:choose>
                            <c:when test="${user.status == 'Active'}">
                                <span class="status-badge">Đang hoạt động</span>
                            </c:when>
                            <c:otherwise>
                                <span class="status-badge inactive">Đã khóa</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- Forms -->
                <form action="${pageContext.request.contextPath}/admin/users/detail" method="POST">
                    <input type="hidden" name="id" value="${user.id}">
                    <input type="hidden" name="action" value="update">
                    
                    <div class="row">
                        <!-- Left Column: Update Info -->
                        <div class="col-md-6 pe-md-5">
                            <h3 class="section-title"><i class="bi bi-pencil-square"></i> Cập nhật thông tin</h3>
                            
                            <div class="mb-4">
                                <label class="form-label">Họ và Tên</label>
                                <input type="text" name="fullName" class="form-control" value="${user.fullName}" required>
                            </div>
                            
                            <div class="mb-4">
                                <label class="form-label">Email</label>
                                <input type="text" class="form-control" value="${user.email}" disabled>
                                <div class="form-text">Email không thể thay đổi sau khi tạo.</div>
                            </div>
                            
                            <div class="mb-4">
                                <label class="form-label">Số điện thoại</label>
                                <input type="text" name="phone" class="form-control" value="${not empty user.phone ? user.phone : ''}" pattern="[0-9]{10}" maxlength="10" minlength="10" title="Số điện thoại phải gồm đúng 10 chữ số" required>
                            </div>
                            
                            <!-- Patient fields (Patient only) -->
                            <div id="patient-fields" style="display: ${user.roleId == 6 ? 'block' : 'none'};">
                                <h4 class="section-title mt-4 pt-3 border-top"><i class="bi bi-person-lines-fill"></i> Thông tin Bệnh nhân</h4>
                                <div class="mb-4">
                                    <label class="form-label">Ngày sinh (DOB)</label>
                                    <c:set var="formattedDob" value="" />
                                    <c:if test="${not empty user.dob}">
                                        <c:set var="parts" value="${fn:split(user.dob, '-')}" />
                                        <c:if test="${fn:length(parts) == 3}">
                                            <c:set var="formattedDob" value="${parts[2]}/${parts[1]}/${parts[0]}" />
                                        </c:if>
                                    </c:if>
                                    <input type="text" name="dob" class="form-control" value="${formattedDob}" placeholder="dd/mm/yyyy" pattern="\d{2}/\d{2}/\d{4}" maxlength="10" title="Nhập ngày sinh theo định dạng dd/mm/yyyy">
                                </div>
                                <div class="mb-4">
                                    <label class="form-label">Địa chỉ</label>
                                    <input type="text" name="address" class="form-control" value="${user.address}" placeholder="Nhập địa chỉ">
                                </div>
                            </div>
                            
                            <!-- Professional fields (Doctor/Specialist only) -->
                            <div id="employee-fields" style="display: ${user.roleId == 3 || user.roleId == 4 ? 'block' : 'none'};">
                                <h4 class="section-title mt-4 pt-3 border-top"><i class="bi bi-briefcase-medical"></i> Thông tin Chuyên môn (Dành cho Bác sĩ)</h4>
                                
                                <div class="mb-4">
                                    <label class="form-label">Mã Chứng chỉ hành nghề (License)</label>
                                    <input type="text" name="licenseNumber" class="form-control" value="${user.licenseNumber}" placeholder="VD: BS-12345/EYE">
                                </div>
                                
                                <div class="mb-4">
                                    <label class="form-label">Chuyên khoa</label>
                                    <input type="text" name="specialty" class="form-control" value="${user.specialty}" placeholder="VD: Nhãn khoa tổng quát">
                                </div>
                                
                                <div class="mb-4">
                                    <label class="form-label">Phòng làm việc (ID)</label>
                                    <input type="number" name="roomId" class="form-control" value="${user.roomName}" min="1" placeholder="Nhập ID phòng (ví dụ: 1, 2, 3...)">
                                    <div class="form-text">Nhập mã ID của phòng khám.</div>
                                </div>
                                
                                <div class="mb-4">
                                    <label class="form-label">Tiểu sử (Biography)</label>
                                    <textarea name="biography" class="form-control" rows="3" placeholder="Nhập thông tin giới thiệu, tiểu sử...">${user.biography}</textarea>
                                </div>
                            </div>
                        </div>

                        <!-- Right Column: Role Assignment -->
                        <div class="col-md-6 ps-md-4 border-start">
                            <h3 class="section-title"><i class="bi bi-shield-check"></i> Phân quyền người dùng</h3>
                            <label class="form-label mb-3">Vai trò (Role)</label>
                            
                            <div class="role-grid">
                                <!-- Role 1 -->
                                <label class="role-card ${user.roleId == 1 ? 'selected' : ''}" onclick="selectRole(this)">
                                    <input type="radio" name="roleId" value="1" ${user.roleId == 1 ? 'checked' : ''}>
                                    <div class="role-content">
                                        <div class="radio-custom"></div>
                                        <div class="role-info">
                                            <span class="title">System Admin</span>
                                            <span class="desc">Toàn quyền quản trị hệ thống</span>
                                        </div>
                                    </div>
                                </label>

                                <!-- Role 2 -->
                                <label class="role-card ${user.roleId == 2 ? 'selected' : ''}" onclick="selectRole(this)">
                                    <input type="radio" name="roleId" value="2" ${user.roleId == 2 ? 'checked' : ''}>
                                    <div class="role-content">
                                        <div class="radio-custom"></div>
                                        <div class="role-info">
                                            <span class="title">Director</span>
                                            <span class="desc">Quản lý hoạt động phòng khám</span>
                                        </div>
                                    </div>
                                </label>

                                <!-- Role 3 -->
                                <label class="role-card ${user.roleId == 3 ? 'selected' : ''}" onclick="selectRole(this)">
                                    <input type="radio" name="roleId" value="3" ${user.roleId == 3 ? 'checked' : ''}>
                                    <div class="role-content">
                                        <div class="radio-custom"></div>
                                        <div class="role-info">
                                            <span class="title">Doctor</span>
                                            <span class="desc">Bác sĩ khám và điều trị</span>
                                        </div>
                                    </div>
                                </label>

                                <!-- Role 4 -->
                                <label class="role-card ${user.roleId == 4 ? 'selected' : ''}" onclick="selectRole(this)">
                                    <input type="radio" name="roleId" value="4" ${user.roleId == 4 ? 'checked' : ''}>
                                    <div class="role-content">
                                        <div class="radio-custom"></div>
                                        <div class="role-info">
                                            <span class="title">Medical Specialist</span>
                                            <span class="desc">Kỹ thuật viên, thực hiện dịch vụ y tế</span>
                                        </div>
                                    </div>
                                </label>
                                
                                <!-- Role 5 -->
                                <label class="role-card ${user.roleId == 5 ? 'selected' : ''}" onclick="selectRole(this)">
                                    <input type="radio" name="roleId" value="5" ${user.roleId == 5 ? 'checked' : ''}>
                                    <div class="role-content">
                                        <div class="radio-custom"></div>
                                        <div class="role-info">
                                            <span class="title">Staff</span>
                                            <span class="desc">Nhân viên lễ tân, hỗ trợ khách hàng</span>
                                        </div>
                                    </div>
                                </label>

                                <!-- Role 6 -->
                                <label class="role-card ${user.roleId == 6 ? 'selected' : ''}" onclick="selectRole(this)">
                                    <input type="radio" name="roleId" value="6" ${user.roleId == 6 ? 'checked' : ''}>
                                    <div class="role-content">
                                        <div class="radio-custom"></div>
                                        <div class="role-info">
                                            <span class="title">Patient</span>
                                            <span class="desc">Khách hàng, bệnh nhân cơ bản</span>
                                        </div>
                                    </div>
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

    <script>
        function selectRole(element) {
            // Xóa class 'selected' từ tất cả các role-card
            document.querySelectorAll('.role-card').forEach(card => {
                card.classList.remove('selected');
            });
            // Thêm class 'selected' cho card được click
            element.classList.add('selected');
            
            // Lấy giá trị của radio vừa được click
            const radio = element.querySelector('input[type="radio"]');
            const roleId = parseInt(radio.value);
            const employeeFields = document.getElementById('employee-fields');
            const patientFields = document.getElementById('patient-fields');
            
            // Hiển thị form chứng chỉ chuyên môn nếu là Bác sĩ (3) hoặc Chuyên viên Y tế (4)
            if (roleId === 3 || roleId === 4) {
                employeeFields.style.display = 'block';
            } else {
                employeeFields.style.display = 'none';
            }
            
            // Hiển thị form bệnh nhân nếu là Patient (6)
            if (roleId === 6) {
                patientFields.style.display = 'block';
            } else {
                patientFields.style.display = 'none';
            }
        }
    </script>
</body>
</html>
