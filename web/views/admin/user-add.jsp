<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thêm Người Dùng - VisionCare Admin</title>

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

        .form-label {
            font-size: 13px;
            font-weight: 600;
            color: #334155;
            margin-bottom: 6px;
        }

        .form-control, .form-select {
            border: 1px solid #cbd5e1;
            padding: 10px 14px;
            font-size: 14px;
            border-radius: 8px;
            color: #0f172a;
            transition: all 0.2s;
        }

        .form-control:focus, .form-select:focus {
            border-color: #18a05e;
            box-shadow: 0 0 0 3px rgba(24, 160, 94, 0.15);
            outline: none;
        }

        .input-group-text {
            background-color: #f8fafc;
            border: 1px solid #cbd5e1;
            color: #64748b;
            border-radius: 8px 0 0 8px;
        }

        .input-group:focus-within .input-group-text {
            border-color: #18a05e;
            color: #18a05e;
        }

        .input-group .form-control, .input-group .form-select {
            border-radius: 0 8px 8px 0;
        }

        .doctor-box {
            background-color: #f8fafc;
            border: 1px dashed #cbd5e1;
            border-radius: 10px;
            padding: 20px;
            margin-top: 20px;
        }
    </style>
</head>

<body>
    <!-- Sidebar Include -->
    <jsp:include page="/views/admin/layout/admin-sidebar.jsp">
        <jsp:param name="activeNav" value="users" />
        <jsp:param name="activeSub" value="${param.type == 'patient' ? 'patient' : 'staff'}" />
    </jsp:include>

    <!-- Main Content -->
    <main class="main-wrapper">
        <!-- Header Include -->
        <jsp:include page="/views/admin/layout/admin-header.jsp" />

        <div class="page-content">
            <!-- Page Header -->
            <div class="page-header d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
                <div class="page-title">
                    <c:choose>
                        <c:when test="${param.type == 'patient'}">
                            <h2>Thêm Hồ Sơ Bệnh Nhân</h2>
                            <p class="text-muted">Đăng ký thông tin tài khoản khách hàng / bệnh nhân mới</p>
                        </c:when>
                        <c:otherwise>
                            <h2>Thêm Nhân Sự Mới</h2>
                            <p class="text-muted">Tạo mới tài khoản cán bộ nhân viên, bác sĩ vào hệ thống</p>
                        </c:otherwise>
                    </c:choose>
                </div>
                <a href="${pageContext.request.contextPath}/admin/users?type=${param.type == 'patient' ? 'patient' : 'staff'}" class="btn btn-sm btn-outline-secondary">
                    <i class="bi bi-arrow-left me-1"></i> Quay lại danh sách
                </a>
            </div>

            <!-- Error Notification -->
            <c:if test="${not empty requestScope.error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert" style="max-width: 850px; margin: 0 auto 20px;">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>${requestScope.error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <!-- Form Card -->
            <div class="admin-card" style="max-width: 850px; margin: 0 auto;">
                <div class="d-flex align-items-center mb-4 pb-2 border-bottom">
                    <h5 class="mb-0 fw-bold">
                        <i class="bi bi-person-plus me-2 text-primary"></i>Thông tin Người dùng Mới
                    </h5>
                </div>

                <form action="${pageContext.request.contextPath}/admin/users/add" method="POST">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">Họ và Tên <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-person"></i></span>
                                <input type="text" name="fullName" class="form-control" placeholder="Nhập họ và tên đầy đủ" value="${param.fullName}" required>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Địa chỉ Email <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                                <input type="email" name="email" class="form-control" placeholder="example@visioncare.vn" value="${param.email}" required>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Số điện thoại <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-telephone"></i></span>
                                <input type="text" name="phone" class="form-control" placeholder="09xxxxxxxx" pattern="[0-9]{10}" maxlength="10" minlength="10" title="Số điện thoại phải gồm đúng 10 chữ số" value="${param.phone}" required>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Ngày sinh (DOB)</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-calendar3"></i></span>
                                <input type="text" name="dob" class="form-control" placeholder="dd/mm/yyyy" pattern="\d{2}/\d{2}/\d{4}" title="Nhập ngày sinh theo định dạng dd/mm/yyyy" value="${param.dob}">
                            </div>
                        </div>

                        <div class="col-md-12">
                            <label class="form-label">Địa chỉ liên hệ</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-geo-alt"></i></span>
                                <input type="text" name="address" class="form-control" placeholder="Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành..." value="${param.address}">
                            </div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Vai trò trong hệ thống <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-shield-lock"></i></span>
                                <select name="roleId" class="form-select" ${param.type == 'patient' ? 'readonly style="pointer-events: none; background-color: #f8fafc;"' : ''}>
                                    <c:choose>
                                        <c:when test="${param.type == 'patient'}">
                                            <option value="6" selected>Patient (Khách hàng &amp; Bệnh nhân)</option>
                                        </c:when>
                                        <c:otherwise>
                                            <option value="5" ${param.roleId == '5' ? 'selected' : ''}>Staff (Nhân viên phòng khám)</option>
                                            <option value="3" ${param.roleId == '3' ? 'selected' : ''}>Doctor (Bác sĩ chuyên khoa)</option>
                                            <option value="4" ${param.roleId == '4' ? 'selected' : ''}>Medical Specialist (Kỹ thuật viên y tế)</option>
                                            <option value="2" ${param.roleId == '2' ? 'selected' : ''}>Director (Quản lý chuyên môn)</option>
                                            <option value="1" ${param.roleId == '1' ? 'selected' : ''}>System Admin (Quản trị hệ thống)</option>
                                        </c:otherwise>
                                    </c:choose>
                                </select>
                            </div>
                            <div class="form-text small text-muted mt-1">
                                <c:choose>
                                    <c:when test="${param.type == 'patient'}">
                                        <i class="bi bi-info-circle me-1"></i>Hồ sơ bệnh nhân được phân quyền mặc định là Patient.
                                    </c:when>
                                    <c:otherwise>
                                        Mật khẩu mặc định khởi tạo sẽ là <code>123</code> và được gửi qua email.
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <!-- Additional Doctor/Specialist Fields -->
                    <div id="doctorFields" class="doctor-box" style="display: none;">
                        <h6 class="fw-bold mb-3 text-dark">
                            <i class="bi bi-briefcase-medical text-primary me-2"></i>Thông tin Chuyên môn Y khoa
                        </h6>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">Mã Chứng chỉ hành nghề</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-card-text"></i></span>
                                    <input type="text" name="licenseNumber" class="form-control" placeholder="VD: CCHN-12345/BYT" value="${param.licenseNumber}">
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Chuyên khoa</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-hospital"></i></span>
                                    <input type="text" name="specialty" class="form-control" placeholder="VD: Nhãn khoa tổng quát, Khúc xạ" value="${param.specialty}">
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Phòng làm việc (ID)</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-door-open"></i></span>
                                    <input type="number" name="roomId" class="form-control" min="1" placeholder="Nhập ID phòng (ví dụ: 1, 2, 3...)" value="${param.roomId}">
                                </div>
                            </div>
                            <div class="col-md-12">
                                <label class="form-label">Tiểu sử tóm tắt (Biography)</label>
                                <textarea name="biography" class="form-control" rows="3" placeholder="Nhập tóm tắt quá trình học tập, kinh nghiệm công tác...">${param.biography}</textarea>
                            </div>
                        </div>
                    </div>

                    <!-- Actions -->
                    <div class="d-flex justify-content-end gap-2 mt-4 pt-3 border-top">
                        <a href="${pageContext.request.contextPath}/admin/users?type=${param.type == 'patient' ? 'patient' : 'staff'}" class="btn btn-secondary px-4 rounded-pill">
                            Hủy bỏ
                        </a>
                        <button type="submit" class="btn btn-primary px-4 rounded-pill">
                            <i class="bi bi-check-lg me-1"></i> Lưu thông tin
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>

    <!-- Bootstrap Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        function checkDoctorRole() {
            var roleSelect = document.querySelector('select[name="roleId"]');
            var doctorFields = document.getElementById('doctorFields');
            if (roleSelect && doctorFields) {
                var val = roleSelect.value;
                if (val === '3' || val === '4') {
                    doctorFields.style.display = 'block';
                } else {
                    doctorFields.style.display = 'none';
                }
            }
        }

        document.addEventListener('DOMContentLoaded', function () {
            var roleSelect = document.querySelector('select[name="roleId"]');
            if (roleSelect) {
                roleSelect.addEventListener('change', checkDoctorRole);
                checkDoctorRole();
            }
        });
    </script>
</body>
</html>