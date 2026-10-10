<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Thêm Người Dùng - VisionCare Admin</title>
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                rel="stylesheet">
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

            <jsp:include page="/views/admin/layout/admin-css.jsp" />
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


                .main-wrapper {
                    margin-left: var(--sidebar-width);
                    min-height: 100vh;
                }

                .page-content {
                    padding: 40px;
                    max-width: 1000px;
                    margin: 0 auto;
                }

                .page-header {
                    display: flex;
                    justify-content: space-between;
                    align-items: flex-start;
                    margin-bottom: 30px;
                }

                .page-title h2 {
                    font-size: 24px;
                    font-weight: 700;
                    color: #0f172a;
                    margin-bottom: 6px;
                }

                .page-title p {
                    color: var(--text-muted);
                    font-size: 14px;
                    margin: 0;
                }

                .btn-back {
                    background-color: white;
                    border: 1px solid #cbd5e1;
                    color: #475569;
                    padding: 8px 16px;
                    border-radius: 6px;
                    font-size: 14px;
                    font-weight: 500;
                    text-decoration: none;
                    display: inline-flex;
                    align-items: center;
                    gap: 8px;
                }

                .btn-back:hover {
                    background-color: #f8fafc;
                    color: #0f172a;
                }

                .form-card {
                    background: white;
                    border-radius: 16px;
                    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.05);
                    padding: 40px;
                    max-width: 850px;
                    margin: 0 auto;
                    border: 1px solid #f1f5f9;
                }

                .form-card h3 {
                    font-size: 20px;
                    font-weight: 700;
                    color: #1e293b;
                    margin-bottom: 28px;
                    display: flex;
                    align-items: center;
                    gap: 10px;
                }

                .form-label {
                    font-size: 14px;
                    color: #475569;
                    margin-bottom: 8px;
                }

                .form-control,
                .form-select,
                .input-group-text {
                    border: 1px solid #cbd5e1;
                    padding: 12px 16px;
                    font-size: 14px;
                    color: #0f172a;
                    transition: all 0.2s;
                }

                .input-group-text {
                    padding: 12px 16px;
                    background-color: #f8fafc;
                    color: #64748b;
                }

                .form-control:focus,
                .form-select:focus {
                    border-color: var(--primary-color);
                    box-shadow: none;
                    outline: none;
                }

                .form-control:focus+.input-group-text,
                .input-group:focus-within .input-group-text {
                    border-color: var(--primary-color);
                    color: var(--primary-color);
                }

                .form-control::placeholder {
                    color: #94a3b8;
                }

                .form-actions {
                    display: flex;
                    justify-content: flex-end;
                    gap: 16px;
                    margin-top: 32px;
                    padding-top: 24px;
                    border-top: 1px solid #f1f5f9;
                }

                .btn-cancel {
                    background: white;
                    border: 1px solid #cbd5e1;
                    color: #475569;
                    padding: 10px 24px;
                    border-radius: 8px;
                    font-weight: 500;
                    font-size: 14px;
                    text-decoration: none;
                }

                .btn-cancel:hover {
                    background-color: #f8fafc;
                    color: #0f172a;
                }

                .btn-submit {
                    background-color: #18a05e;
                    border: none;
                    color: white;
                    padding: 10px 24px;
                    border-radius: 8px;
                    font-weight: 500;
                    font-size: 14px;
                    display: inline-flex;
                    align-items: center;
                    gap: 8px;
                    cursor: pointer;
                    transition: all 0.2s;
                    box-shadow: 0 4px 12px rgba(24, 160, 94, 0.2);
                }

                .btn-submit:hover {
                    background-color: #12824b;
                    box-shadow: 0 4px 12px rgba(24, 160, 94, 0.4);
                }
            </style>
        </head>

        <body>

            <jsp:include page="/views/admin/layout/admin-sidebar.jsp">
                <jsp:param name="activeNav" value="users" />
            </jsp:include>

            <main class="main-wrapper">
                <!-- Header -->
                <jsp:include page="/views/admin/layout/admin-header.jsp" />

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
                        <div class="alert alert-danger" style="max-width: 700px; margin: 0 auto 20px;">
                            ${requestScope.error}</div>
                    </c:if>

                    <div class="form-card">
                        <h3><i class="bi bi-person-lines-fill text-primary"
                                style="color: var(--primary-color) !important;"></i> Thông tin người dùng mới</h3>
                        <form action="${pageContext.request.contextPath}/admin/users/add" method="POST">
                            <div class="row g-4">
                                <div class="col-md-6">
                                    <label class="form-label text-muted fw-semibold">Họ và Tên</label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-light border-end-0"><i
                                                class="bi bi-person text-secondary"></i></span>
                                        <input type="text" name="fullName" class="form-control border-start-0 ps-0"
                                            placeholder="Nhập họ và tên đầy đủ" required>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label text-muted fw-semibold">Email</label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-light border-end-0"><i
                                                class="bi bi-envelope text-secondary"></i></span>
                                        <input type="email" name="email" class="form-control border-start-0 ps-0"
                                            placeholder="example@system.com" required>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label text-muted fw-semibold">Số điện thoại</label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-light border-end-0"><i
                                                class="bi bi-telephone text-secondary"></i></span>
                                        <input type="text" name="phone" class="form-control border-start-0 ps-0"
                                            placeholder="09xx xxx xxx" pattern="[0-9]{10}" maxlength="10" minlength="10"
                                            title="Số điện thoại phải gồm đúng 10 chữ số" required>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label text-muted fw-semibold">Ngày sinh (DOB)</label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-light border-end-0"><i
                                                class="bi bi-calendar3 text-secondary"></i></span>
                                        <input type="text" name="dob" class="form-control border-start-0 ps-0"
                                            placeholder="dd/mm/yyyy" pattern="\d{2}/\d{2}/\d{4}"
                                            title="Nhập ngày sinh theo định dạng dd/mm/yyyy">
                                    </div>
                                </div>

                                <div class="col-md-12">
                                    <label class="form-label text-muted fw-semibold">Địa chỉ</label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-light border-end-0"><i
                                                class="bi bi-geo-alt text-secondary"></i></span>
                                        <input type="text" name="address" class="form-control border-start-0 ps-0"
                                            placeholder="Nhập địa chỉ chi tiết">
                                    </div>
                                </div>


                                <div class="col-md-6">
                                    <label class="form-label text-muted fw-semibold">Vai trò (Role)</label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-light border-end-0"><i
                                                class="bi bi-shield-lock text-secondary"></i></span>
                                        <select name="roleId" class="form-select border-start-0 ps-0"
                                            ${param.type=='patient'
                                            ? 'readonly style="pointer-events: none; background-color: #f8fafc;"' : ''
                                            }>
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
                                    </div>
                                    <c:if test="${param.type == 'patient'}">
                                        <div class="form-text text-muted mt-2"><i
                                                class="bi bi-info-circle me-1"></i>Đang tạo hồ sơ Bệnh nhân mới.</div>
                                    </c:if>
                                </div>
                            </div>

                            <div id="doctorFields" class="bg-light p-4 rounded-3 mt-4"
                                style="display: none; border: 1px dashed #cbd5e1;">
                                <h4 class="mb-4" style="font-size: 16px; color: #0f172a; font-weight: 600;"><i
                                        class="bi bi-briefcase-medical text-primary me-2"></i>Thông tin Chuyên môn (Dành
                                    cho Bác sĩ)</h4>
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label text-muted fw-semibold" style="font-size: 13px;">Mã
                                            Chứng chỉ hành nghề</label>
                                        <div class="input-group">
                                            <span class="input-group-text bg-white"><i
                                                    class="bi bi-upc-scan"></i></span>
                                            <input type="text" name="licenseNumber" class="form-control"
                                                placeholder="VD: BS-12345/EYE" value="${param.licenseNumber}">
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label text-muted fw-semibold" style="font-size: 13px;">Chuyên
                                            khoa</label>
                                        <div class="input-group">
                                            <span class="input-group-text bg-white"><i
                                                    class="bi bi-hospital"></i></span>
                                            <input type="text" name="specialty" class="form-control"
                                                placeholder="VD: Nhãn khoa tổng quát" value="${param.specialty}">
                                        </div>
                                    </div>
                                    <div class="col-md-12">
                                        <label class="form-label text-muted fw-semibold" style="font-size: 13px;">Phòng
                                            làm việc (ID)</label>
                                        <div class="input-group">
                                            <span class="input-group-text bg-white"><i
                                                    class="bi bi-door-open"></i></span>
                                            <input type="number" name="roomId" class="form-control"
                                                placeholder="Nhập ID phòng (ví dụ: 1, 2, 3...)" value="${param.roomId}">
                                        </div>
                                    </div>
                                </div>
                            </div>

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
                document.addEventListener('DOMContentLoaded', function () {
                    var roleSelect = document.querySelector('select[name="roleId"]');
                    if (roleSelect) {
                        roleSelect.addEventListener('change', checkRole);
                        checkRole();
                    }
                });
            </script>
        </body>

        </html>