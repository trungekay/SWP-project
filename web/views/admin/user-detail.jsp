<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi Tiết Người Dùng - VisionCare Admin</title>

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
            padding: 32px;
        }

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

        /* Profile Header */
        .profile-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 32px;
            padding-bottom: 24px;
            border-bottom: 1px solid #f1f5f9;
        }

        .profile-identity {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .avatar-circle-lg {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            background-color: #dcfce7;
            color: #15803d;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 22px;
            flex-shrink: 0;
            text-transform: uppercase;
        }

        .profile-name {
            font-size: 20px;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 2px;
        }

        .profile-meta {
            font-size: 13px;
            color: #64748b;
        }

        .badge-status {
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .status-active { background-color: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; }
        .status-inactive { background-color: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; }

        /* Form elements */
        .section-title {
            font-size: 15px;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .section-title i {
            color: #18a05e;
        }

        .form-label {
            font-size: 13px;
            font-weight: 600;
            color: #334155;
            margin-bottom: 6px;
        }

        .form-control, .form-select {
            border: 1px solid #cbd5e1;
            padding: 9px 14px;
            border-radius: 8px;
            font-size: 14px;
            color: #0f172a;
            transition: all 0.2s;
        }

        .form-control:focus, .form-select:focus {
            border-color: #18a05e;
            box-shadow: 0 0 0 3px rgba(24, 160, 94, 0.15);
            outline: none;
        }

        .form-control:disabled {
            background-color: #f8fafc;
            color: #64748b;
            cursor: not-allowed;
        }

        /* Role Selection Cards */
        .role-grid {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .role-card {
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            padding: 14px 16px;
            cursor: pointer;
            transition: all 0.2s;
            position: relative;
            background: #fff;
        }

        .role-card:hover {
            border-color: #cbd5e1;
            background-color: #f8fafc;
        }

        .role-card input[type="radio"] {
            position: absolute;
            opacity: 0;
        }

        .role-card.selected {
            border-color: #18a05e;
            background-color: #f0fdf4;
            box-shadow: 0 0 0 1px #18a05e;
        }

        .role-content {
            display: flex;
            align-items: flex-start;
            gap: 12px;
        }

        .radio-custom {
            width: 18px;
            height: 18px;
            border-radius: 50%;
            border: 2px solid #cbd5e1;
            margin-top: 2px;
            position: relative;
            flex-shrink: 0;
        }

        .role-card.selected .radio-custom {
            border-color: #18a05e;
        }

        .role-card.selected .radio-custom::after {
            content: '';
            position: absolute;
            width: 10px;
            height: 10px;
            background: #18a05e;
            border-radius: 50%;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
        }

        .role-info .title {
            font-weight: 600;
            font-size: 14px;
            color: #0f172a;
            margin-bottom: 2px;
            display: block;
        }

        .role-info .desc {
            font-size: 12px;
            color: #64748b;
            margin: 0;
        }
    </style>
</head>

<body>
    <!-- Sidebar Include -->
    <jsp:include page="/views/admin/layout/admin-sidebar.jsp">
        <jsp:param name="activeNav" value="users" />
        <jsp:param name="activeSub" value="${user.roleId == 6 ? 'patient' : 'staff'}" />
    </jsp:include>

    <!-- Main Content -->
    <main class="main-wrapper">
        <!-- Header Include -->
        <jsp:include page="/views/admin/layout/admin-header.jsp" />

        <div class="page-content">
            <!-- Page Header -->
            <div class="page-header d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
                <div class="page-title">
                    <h2>Chi Tiết Người Dùng</h2>
                    <p class="text-muted">Cập nhật thông tin tài khoản và điều chỉnh phân quyền hệ thống</p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/users?type=${user.roleId == 6 ? 'patient' : 'staff'}" class="btn btn-sm btn-outline-secondary">
                    <i class="bi bi-arrow-left me-1"></i> Quay lại danh sách
                </a>
            </div>

            <!-- Notifications -->
            <c:if test="${not empty sessionScope.error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert" style="max-width: 950px; margin: 0 auto 20px;">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>${sessionScope.error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="error" scope="session" />
            </c:if>
            <c:if test="${not empty requestScope.message}">
                <div class="alert alert-success alert-dismissible fade show" role="alert" style="max-width: 950px; margin: 0 auto 20px;">
                    <i class="bi bi-check-circle-fill me-2"></i>${requestScope.message}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <!-- Profile Admin Card -->
            <div class="admin-card" style="max-width: 950px; margin: 0 auto;">
                <!-- Profile Header -->
                <div class="profile-header">
                    <div class="profile-identity">
                        <c:set var="initials" value="${fn:substring(user.fullName, 0, 1)}" />
                        <c:set var="words" value="${fn:split(user.fullName, ' ')}" />
                        <c:if test="${fn:length(words) > 1}">
                            <c:set var="initials" value="${fn:substring(words[0], 0, 1)}${fn:substring(words[fn:length(words)-1], 0, 1)}" />
                        </c:if>
                        <div class="avatar-circle-lg">
                            ${fn:toUpperCase(initials)}
                        </div>
                        <div>
                            <h3 class="profile-name">${user.fullName}</h3>
                            <div class="profile-meta">
                                <span><i class="bi bi-envelope me-1"></i>${user.email}</span>
                                <c:if test="${not empty user.phone}">
                                    <span class="ms-3"><i class="bi bi-telephone me-1"></i>${user.phone}</span>
                                </c:if>
                            </div>
                        </div>
                    </div>
                    <div>
                        <c:choose>
                            <c:when test="${user.status == 'Active'}">
                                <span class="badge-status status-active"><i class="bi bi-check-circle-fill"></i> Hoạt động</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge-status status-inactive"><i class="bi bi-lock-fill"></i> Đã khóa</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- Update Form -->
                <form action="${pageContext.request.contextPath}/admin/users/detail" method="POST">
                    <input type="hidden" name="id" value="${user.id}">
                    <input type="hidden" name="action" value="update">

                    <div class="row g-4">
                        <!-- Left Column: Personal and Professional Info -->
                        <div class="col-lg-6 pe-lg-4">
                            <h5 class="section-title"><i class="bi bi-person-lines-fill"></i> Thông tin cơ bản</h5>

                            <div class="mb-3">
                                <label class="form-label">Họ và Tên <span class="text-danger">*</span></label>
                                <input type="text" name="fullName" class="form-control" value="${user.fullName}" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Địa chỉ Email</label>
                                <input type="text" class="form-control" value="${user.email}" disabled>
                                <div class="form-text small text-muted">Email định danh tài khoản và không thể sửa đổi.</div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Số điện thoại <span class="text-danger">*</span></label>
                                <input type="text" name="phone" class="form-control" value="${not empty user.phone ? user.phone : ''}" pattern="[0-9]{10}" maxlength="10" minlength="10" title="Số điện thoại phải gồm đúng 10 chữ số" required>
                            </div>

                            <!-- Patient specific fields -->
                            <div id="patient-fields" style="display: ${user.roleId == 6 ? 'block' : 'none'};">
                                <div class="mb-3">
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
                                <div class="mb-3">
                                    <label class="form-label">Địa chỉ liên hệ</label>
                                    <input type="text" name="address" class="form-control" value="${user.address}" placeholder="Nhập địa chỉ">
                                </div>
                            </div>

                            <!-- Professional fields for Doctor / Specialist -->
                            <div id="employee-fields" style="display: ${user.roleId == 3 || user.roleId == 4 ? 'block' : 'none'};">
                                <h5 class="section-title mt-4 pt-3 border-top"><i class="bi bi-briefcase-medical"></i> Chuyên môn Y khoa</h5>

                                <div class="mb-3">
                                    <label class="form-label">Mã Chứng chỉ hành nghề</label>
                                    <input type="text" name="licenseNumber" class="form-control" value="${user.licenseNumber}" placeholder="VD: BS-12345/EYE">
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Chuyên khoa</label>
                                    <input type="text" name="specialty" class="form-control" value="${user.specialty}" placeholder="VD: Nhãn khoa tổng quát">
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Phòng làm việc (ID)</label>
                                    <input type="number" name="roomId" class="form-control" value="${user.roomName}" min="1" placeholder="Nhập ID phòng (ví dụ: 1, 2, 3...)">
                                    <div class="form-text small text-muted">Nhập mã số ID phòng khám phụ trách.</div>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Tiểu sử tóm tắt (Biography)</label>
                                    <textarea name="biography" class="form-control" rows="3" placeholder="Nhập thông tin giới thiệu, kinh nghiệm...">${user.biography}</textarea>
                                </div>
                            </div>
                        </div>

                        <!-- Right Column: Role Assignment -->
                        <div class="col-lg-6 ps-lg-4 border-start">
                            <h5 class="section-title"><i class="bi bi-shield-check"></i> Phân quyền Người dùng</h5>
                            <label class="form-label mb-2">Chọn vai trò đảm nhiệm</label>

                            <div class="role-grid">
                                <label class="role-card ${user.roleId == 1 ? 'selected' : ''}" onclick="selectRole(this)">
                                    <input type="radio" name="roleId" value="1" ${user.roleId == 1 ? 'checked' : ''}>
                                    <div class="role-content">
                                        <div class="radio-custom"></div>
                                        <div class="role-info">
                                            <span class="title">System Admin</span>
                                            <span class="desc">Toàn quyền quản trị kỹ thuật và bảo mật hệ thống</span>
                                        </div>
                                    </div>
                                </label>

                                <label class="role-card ${user.roleId == 2 ? 'selected' : ''}" onclick="selectRole(this)">
                                    <input type="radio" name="roleId" value="2" ${user.roleId == 2 ? 'checked' : ''}>
                                    <div class="role-content">
                                        <div class="radio-custom"></div>
                                        <div class="role-info">
                                            <span class="title">Director</span>
                                            <span class="desc">Quản lý hoạt động chuyên môn và điều hành phòng khám</span>
                                        </div>
                                    </div>
                                </label>

                                <label class="role-card ${user.roleId == 3 ? 'selected' : ''}" onclick="selectRole(this)">
                                    <input type="radio" name="roleId" value="3" ${user.roleId == 3 ? 'checked' : ''}>
                                    <div class="role-content">
                                        <div class="radio-custom"></div>
                                        <div class="role-info">
                                            <span class="title">Doctor</span>
                                            <span class="desc">Bác sĩ khám mắt, chẩn đoán và chỉ định điều trị</span>
                                        </div>
                                    </div>
                                </label>

                                <label class="role-card ${user.roleId == 4 ? 'selected' : ''}" onclick="selectRole(this)">
                                    <input type="radio" name="roleId" value="4" ${user.roleId == 4 ? 'checked' : ''}>
                                    <div class="role-content">
                                        <div class="radio-custom"></div>
                                        <div class="role-info">
                                            <span class="title">Medical Specialist</span>
                                            <span class="desc">Kỹ thuật viên khúc xạ, thực hiện thủ thuật &amp; cận lâm sàng</span>
                                        </div>
                                    </div>
                                </label>

                                <label class="role-card ${user.roleId == 5 ? 'selected' : ''}" onclick="selectRole(this)">
                                    <input type="radio" name="roleId" value="5" ${user.roleId == 5 ? 'checked' : ''}>
                                    <div class="role-content">
                                        <div class="radio-custom"></div>
                                        <div class="role-info">
                                            <span class="title">Staff</span>
                                            <span class="desc">Nhân viên lễ tân, tiếp đón bệnh nhân và thu ngân</span>
                                        </div>
                                    </div>
                                </label>

                                <label class="role-card ${user.roleId == 6 ? 'selected' : ''}" onclick="selectRole(this)">
                                    <input type="radio" name="roleId" value="6" ${user.roleId == 6 ? 'checked' : ''}>
                                    <div class="role-content">
                                        <div class="radio-custom"></div>
                                        <div class="role-info">
                                            <span class="title">Patient</span>
                                            <span class="desc">Khách hàng / bệnh nhân đặt lịch và khám bệnh</span>
                                        </div>
                                    </div>
                                </label>
                            </div>
                        </div>
                    </div>

                    <!-- Actions -->
                    <div class="d-flex justify-content-end gap-2 mt-4 pt-3 border-top">
                        <a href="${pageContext.request.contextPath}/admin/users?type=${user.roleId == 6 ? 'patient' : 'staff'}" class="btn btn-secondary px-4 rounded-pill">
                            Hủy bỏ
                        </a>
                        <button type="submit" class="btn btn-primary px-4 rounded-pill">
                            <i class="bi bi-check-lg me-1"></i> Lưu thay đổi
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>

    <!-- Bootstrap Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        function selectRole(element) {
            if (!element) return;
            document.querySelectorAll('.role-card').forEach(card => {
                card.classList.remove('selected');
            });
            element.classList.add('selected');

            const radio = element.querySelector('input[type="radio"]');
            if (radio) {
                radio.checked = true;
                const roleId = parseInt(radio.value);
                const employeeFields = document.getElementById('employee-fields');
                const patientFields = document.getElementById('patient-fields');

                if (roleId === 3 || roleId === 4) {
                    if (employeeFields) employeeFields.style.display = 'block';
                } else {
                    if (employeeFields) employeeFields.style.display = 'none';
                }

                if (roleId === 6) {
                    if (patientFields) patientFields.style.display = 'block';
                } else {
                    if (patientFields) patientFields.style.display = 'none';
                }
            }
        }
    </script>
</body>
</html>
