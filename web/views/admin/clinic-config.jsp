<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Cấu hình Phòng Khám - VisionCare Admin</title>
        <!-- Google Fonts -->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
              rel="stylesheet">
        <!-- Bootstrap 5 CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

        <!-- Vendor CSS Files (from header.jsp) -->
        <link href="${pageContext.request.contextPath}/assets/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/vendor/bootstrap-icons/bootstrap-icons.css"
              rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/vendor/aos/aos.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">

        <!-- Main CSS File -->
        <link href="${pageContext.request.contextPath}/assets/css/main.css" rel="stylesheet">

        <jsp:include page="/views/admin/layout/admin-css.jsp" />
        <style>
            .admin-card {
                background: #fff;
                border-radius: 12px;
                box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
                padding: 24px;
            }

            /* Modern Premium Table Styling with Borders */
            .table-custom {
                width: 100%;
                border-collapse: separate;
                border-spacing: 0;
                border-radius: 12px;
                overflow: hidden;
                border: 1px solid #cbd5e1;
                /* Visible outer border */
            }

            .table-custom thead {
                background-color: #f0fdf4;
                /* Modern subtle green */
            }

            .table-custom thead th {
                color: #15803d;
                /* Crisp green text */
                font-size: 13px;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                padding: 16px 24px;
                border-bottom: 2px solid #dcfce7;
                border-right: 1px solid #dcfce7;
                /* Vertical divider */
                border-top: none;
            }

            .table-custom thead th:last-child {
                border-right: none;
            }

            .table-custom tbody td {
                padding: 18px 24px;
                vertical-align: middle;
                color: #334155;
                font-size: 15px;
                font-weight: 500;
                border-bottom: 1px solid #f1f5f9;
                border-right: 1px solid #f1f5f9;
                /* Vertical divider */
            }

            .table-custom tbody td:last-child {
                border-right: none;
            }

            .table-custom tbody tr:last-child td {
                border-bottom: none;
            }

            .table-custom tbody tr {
                background-color: transparent;
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

            .table-custom .badge {
                padding: 8px 12px;
                font-weight: 600;
                letter-spacing: 0.3px;
                border-radius: 6px;
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

            .btn-outline-primary {
                color: #18a05e !important;
                border-color: #18a05e !important;
            }

            .btn-outline-primary:hover,
            .btn-outline-primary:focus,
            .btn-outline-primary:active {
                background-color: #18a05e !important;
                border-color: #18a05e !important;
                color: #fff !important;
            }

            .text-primary {
                color: #18a05e !important;
            }

            .bg-primary {
                background-color: #18a05e !important;
            }

            .config-select-box {
                background-color: #f8fafc;
                border: 1px solid #cbd5e1;
                font-size: 15px;
                font-weight: 600;
                color: #0f172a;
                border-radius: 10px;
                padding: 9px 16px;
                min-width: 260px;
                cursor: pointer;
                box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
                transition: all 0.2s ease;
            }

            .config-select-box:focus {
                border-color: #18a05e;
                box-shadow: 0 0 0 3px rgba(24, 160, 94, 0.15);
                outline: none;
            }

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

            .gallery-card {
                transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
            }

            /* Room Cards Grid Layout */
            /* ===== ROOM CARD GRID - EXACT DESIGN MATCH ===== */
            .room-grid {
                display: grid;
                grid-template-columns: repeat(5, minmax(0, 1fr));
                gap: 14px;
            }
            @media (max-width: 1100px) { .room-grid { grid-template-columns: repeat(3, minmax(0, 1fr)); } }
            @media (max-width: 768px) { .room-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); } }
            @media (max-width: 480px) { .room-grid { grid-template-columns: 1fr; } } }
            .room-card {
                background: #ffffff;
                border: 1.5px solid #e8edf2;
                border-radius: 14px;
                padding: 0;
                box-shadow: 0 1px 6px rgba(0,0,0,0.06);
                transition: all 0.2s ease;
                display: flex;
                flex-direction: column;
                overflow: hidden;
            }
            .room-card:hover {
                box-shadow: 0 6px 20px rgba(24, 160, 94, 0.14);
                border-color: #1aaa60;
                transform: translateY(-2px);
            }
            .room-card-header {
                padding: 14px 14px 0 14px;
                display: flex;
                align-items: flex-start;
                justify-content: space-between;
                gap: 10px;
            }
            .room-card-icon {
                width: 40px;
                height: 40px;
                border-radius: 10px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 20px;
                flex-shrink: 0;
            }
            .room-card-icon.eye {
                background: #e0f2fe;
                color: #0284c7;
            }
            .room-card-icon.surgery {
                background: #fef3c7;
                color: #d97706;
            }
            .room-card-icon.default {
                background: #f0fdf4;
                color: #16a34a;
            }
            .room-card-id-badge {
                font-size: 10px;
                font-weight: 700;
                color: #94a3b8;
                letter-spacing: 0.8px;
                text-transform: uppercase;
                background: #f1f5f9;
                padding: 2px 7px;
                border-radius: 5px;
                border: 1px solid #e2e8f0;
                white-space: nowrap;
            }
            .room-card-body {
                padding: 10px 14px 14px 14px;
                flex: 1;
                display: flex;
                flex-direction: column;
                gap: 8px;
            }
            .room-card-name {
                font-size: 14px;
                font-weight: 700;
                color: #1e293b;
                line-height: 1.3;
                margin: 0;
            }
            .room-card-staff-label {
                font-size: 11px;
                color: #94a3b8;
                font-weight: 500;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }
            .room-card-staff-info {
                display: flex;
                align-items: center;
                gap: 6px;
                font-size: 12.5px;
                color: #374151;
                font-weight: 500;
            }
            .room-card-staff-avatar {
                width: 22px;
                height: 22px;
                border-radius: 6px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 11px;
                flex-shrink: 0;
            }
            .room-card-staff-avatar.doctor {
                background: #dbeafe;
                color: #1d4ed8;
            }
            .room-card-staff-avatar.specialist {
                background: #fce7f3;
                color: #be185d;
            }
            .room-card-staff-sub {
                font-size: 11px;
                color: #94a3b8;
                margin-top: 1px;
            }
            .room-card-actions {
                display: flex;
                align-items: center;
                gap: 6px;
                padding: 10px 14px;
                border-top: 1px solid #f1f5f9;
                background: #fafbfc;
            }
            .room-card-actions .btn-update {
                flex: 1;
                font-size: 12px;
                padding: 5px 10px;
                border-radius: 7px;
                border: 1.5px solid #d1d5db;
                background: #fff;
                color: #374151;
                font-weight: 500;
                transition: all 0.15s;
            }
            .room-card-actions .btn-update:hover {
                border-color: #1aaa60;
                color: #1aaa60;
                background: #f0fdf4;
            }
            .room-card-actions .btn-del {
                width: 30px;
                height: 30px;
                border-radius: 7px;
                border: 1.5px solid #fecaca;
                background: #fff;
                color: #ef4444;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 13px;
                transition: all 0.15s;
                flex-shrink: 0;
            }
            .room-card-actions .btn-del:hover {
                background: #fef2f2;
                border-color: #ef4444;
            }
            /* Add room card */
            .add-room-card {
                border: 2px dashed #d1d5db;
                border-radius: 14px;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                gap: 8px;
                min-height: 180px;
                cursor: pointer;
                color: #9ca3af;
                transition: all 0.2s ease;
                background: #fafafa;
                text-decoration: none;
                padding: 20px;
            }
            .add-room-card:hover {
                border-color: #1aaa60;
                color: #1aaa60;
                background: #f0fdf4;
                transform: translateY(-2px);
            }
            .add-room-card i {
                font-size: 28px;
            }
            .add-room-card span {
                font-size: 13px;
                font-weight: 600;
                text-align: center;
                line-height: 1.4;
            }

            /* High Contrast & Clear Slot Overview Styles */
            .slot-summary-card {
                background: #ffffff;
                border-radius: 14px;
                border: 1px solid #e2e8f0;
                box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
                padding: 22px;
                height: 100%;
                transition: all 0.2s ease;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
            }
            .slot-summary-card:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
            }
            .slot-summary-card.morning-card {
                border-left: 5px solid #d97706;
            }
            .slot-summary-card.lunch-card {
                border-left: 5px solid #0284c7;
            }
            .slot-summary-card.afternoon-card {
                border-left: 5px solid #18a05e;
            }
            .slot-summary-card.buffer-card {
                border-left: 5px solid #6366f1;
            }
            .badge-morning-tag {
                background-color: #fef3c7;
                color: #78350f;
                border: 1px solid #fde68a;
                font-weight: 700;
                font-size: 13px;
                padding: 6px 14px;
                border-radius: 20px;
                display: inline-flex;
                align-items: center;
            }
            .badge-lunch-tag {
                background-color: #e0f2fe;
                color: #0369a1;
                border: 1px solid #bae6fd;
                font-weight: 700;
                font-size: 13px;
                padding: 6px 14px;
                border-radius: 20px;
                display: inline-flex;
                align-items: center;
            }
            .badge-afternoon-tag {
                background-color: #dcfce7;
                color: #15803d;
                border: 1px solid #bbf7d0;
                font-weight: 700;
                font-size: 13px;
                padding: 6px 14px;
                border-radius: 20px;
                display: inline-flex;
                align-items: center;
            }
            .badge-buffer-tag {
                background-color: #fef3c7;
                color: #78350f;
                border: 1px solid #f59e0b;
                font-weight: 700;
                font-size: 12px;
                padding: 4px 10px;
                border-radius: 6px;
                display: inline-flex;
                align-items: center;
            }
            .slot-time-pill {
                background-color: #ffffff;
                color: #0f172a !important;
                font-family: 'SFMono-Regular', Consolas, Menlo, Monaco, monospace;
                font-size: 13.5px;
                font-weight: 700;
                padding: 6px 14px;
                border-radius: 8px;
                letter-spacing: 0.5px;
                display: inline-block;
                box-shadow: 0 1px 3px rgba(15, 23, 42, 0.15);
            }
            .slot-status-active {
                background-color: #dcfce7;
                color: #15803d;
                border: 1px solid #86efac;
                font-weight: 700;
                font-size: 12.5px;
                padding: 5px 12px;
                border-radius: 6px;
                display: inline-flex;
                align-items: center;
            }
            .slot-status-inactive {
                background-color: #fee2e2;
                color: #991b1b;
                border: 1px solid #fca5a5;
                font-weight: 700;
                font-size: 12.5px;
                padding: 5px 12px;
                border-radius: 6px;
                display: inline-flex;
                align-items: center;
            }
            .session-bar-morning {
                background: linear-gradient(to right, #fffbeb, #ffffff);
                border: 1px solid #fef08a;
                border-left: 4px solid #d97706;
                border-radius: 10px;
                padding: 14px 20px;
            }
            .session-bar-afternoon {
                background: linear-gradient(to right, #f0fdf4, #ffffff);
                border: 1px solid #bbf7d0;
                border-left: 4px solid #18a05e;
                border-radius: 10px;
                padding: 14px 20px;
            }
            .lunch-break-box {
                background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%);
                border: 1.5px dashed #0284c7;
                border-radius: 12px;
                padding: 18px 24px;
                margin: 24px 0;
            }

            .gallery-card:hover {
                transform: translateY(-3px);
                box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08) !important;
                border-color: #86efac !important;
            }
        </style>
    </head>

    <body>
        <c:set var="currentTab" value="${empty param.tab ? 'rooms' : param.tab}" />
        <jsp:include page="/views/admin/layout/admin-sidebar.jsp">
            <jsp:param name="activeNav" value="clinic-config" />
            <jsp:param name="activeSub" value="${currentTab}" />
        </jsp:include>
        <main class="main-wrapper">
            <jsp:include page="/views/admin/layout/admin-header.jsp" />
            <div class="page-content">
                <div class="page-header d-flex flex-wrap justify-content-between align-items-center gap-3">
                    <div class="page-title">
                        <c:choose>
                            <c:when test="${currentTab == 'slots'}">
                                <h2>Cấu hình Khung Giờ Khám</h2>
                                <p class="text-muted">Quản lý các ca khám bệnh và thời gian làm việc trong ngày</p>
                            </c:when>
                            <c:when test="${currentTab == 'rules'}">
                                <h2>Quy định Giờ Làm Việc Tối Thiểu</h2>
                                <p class="text-muted">Thiết lập số giờ làm việc tối thiểu hàng tuần và định mức công tác của nhân sự</p>
                            </c:when>
                            <c:when test="${currentTab == 'holdtime'}">
                                <h2>Quy định Thời Gian Giữ Chỗ Đặt Lịch</h2>
                                <p class="text-muted">Thiết lập thời gian tạm khóa khung giờ (Pending Hold Time) cho lịch hẹn trực tuyến khi chờ thanh toán</p>
                            </c:when>
                            <c:when test="${currentTab == 'buffer'}">
                                <h2>Chính sách Ca Đệm Khám Bệnh (Buffer Slot)</h2>
                                <p class="text-muted">Cấu hình thời gian đệm 30 phút cuối mỗi ca khám để bù giờ cho các ca khám phức tạp</p>
                            </c:when>
                            <c:when test="${currentTab == 'intro'}">
                                <h2>Cấu hình Hình ảnh & Giới thiệu Trang chủ</h2>
                                <p class="text-muted">Quản lý và thay đổi các hình ảnh hiển thị trên trang chủ: Dịch vụ, Banner chính và Về chúng tôi</p>
                            </c:when>
                            <c:otherwise>
                                <h2>Cấu hình Phòng Khám</h2>
                                <p class="text-muted">Quản lý danh sách phòng khám và phân công nhân sự phụ trách</p>
                            </c:otherwise>
                        </c:choose>
                    </div>

                </div>

                <!-- Tab Navigation Buttons for Quick Switching -->
                <div class="d-flex flex-wrap gap-2 mb-4">
                    <a href="${pageContext.request.contextPath}/admin/clinic-config?tab=rooms"
                       class="config-tab-btn ${currentTab == 'rooms' ? 'active' : ''}">
                        <i class="bi bi-door-open"></i> Cấu hình phòng
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/clinic-config?tab=slots"
                       class="config-tab-btn ${currentTab == 'slots' ? 'active' : ''}">
                        <i class="bi bi-clock-history"></i> Cấu hình khung giờ khám
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/clinic-config?tab=rules"
                       class="config-tab-btn ${currentTab == 'rules' ? 'active' : ''}">
                        <i class="bi bi-sliders"></i> Quy định giờ làm việc
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/clinic-config?tab=holdtime"
                       class="config-tab-btn ${currentTab == 'holdtime' ? 'active' : ''}">
                        <i class="bi bi-stopwatch"></i> Thời gian giữ chỗ
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/clinic-config?tab=buffer"
                       class="config-tab-btn ${currentTab == 'buffer' ? 'active' : ''}">
                        <i class="bi bi-shield-check"></i> Chính sách ca đệm
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/clinic-config?tab=intro"
                       class="config-tab-btn ${currentTab == 'intro' ? 'active' : ''}">
                        <i class="bi bi-images"></i> Cấu hình hình ảnh trang chủ
                    </a>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i>${error}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>
                <c:if test="${not empty sessionScope.errorMsg}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i>${sessionScope.errorMsg}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                    <c:remove var="errorMsg" scope="session" />
                </c:if>
                <c:if test="${not empty sessionScope.successMsg}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="bi bi-check-circle-fill me-2"></i>${sessionScope.successMsg}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                    <c:remove var="successMsg" scope="session" />
                </c:if>

                <div class="row g-4">
                    <c:if test="${currentTab == 'rooms'}">
                        <!-- Clinic Rooms Screen (Card Grid Layout) -->
                        <div class="col-lg-12">
                            <div class="admin-card">
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <div>
                                        <h5 class="mb-1 fw-bold"><i class="bi bi-hospital me-2" style="color:#1aaa60"></i>Danh sách Phòng Khám &amp; Điều trị</h5>
                                        <p class="text-muted small mb-0">Hệ thống đang cấu hình <strong>${fn:length(rooms)}</strong> phòng chuyên môn</p>
                                    </div>
                                    <button class="btn rounded-pill px-3 shadow-sm fw-semibold" style="background:#1aaa60;color:#fff" data-bs-toggle="modal" data-bs-target="#addRoomModal">
                                        <i class="bi bi-plus-lg me-1"></i> Thêm phòng mới
                                    </button>
                                </div>
                                <hr class="my-3">
                                <div class="room-grid">
                                    <c:forEach var="room" items="${rooms}">
                                        <c:set var="lowerRoomName" value="${fn:toLowerCase(room.name)}" />
                                        <c:set var="isEye" value="${fn:contains(lowerRoomName, 'mắt') || fn:contains(lowerRoomName, 'khúc xạ') || fn:contains(lowerRoomName, 'khám')}" />
                                        <c:set var="isSurgery" value="${fn:contains(lowerRoomName, 'tiểu phẫu') || fn:contains(lowerRoomName, 'phẫu thuật') || fn:contains(lowerRoomName, 'điều trị')}" />

                                        <c:set var="assignedDoctor" value="" />
                                        <c:set var="assignedSpecialist" value="" />
                                        <c:forEach var="doc" items="${doctors}">
                                            <c:if test="${doc.roomId == room.id}">
                                                <c:set var="assignedDoctor" value="${doc}" />
                                            </c:if>
                                        </c:forEach>
                                        <c:forEach var="spec" items="${specialists}">
                                            <c:if test="${spec.roomId == room.id}">
                                                <c:set var="assignedSpecialist" value="${spec}" />
                                            </c:if>
                                        </c:forEach>

                                        <div class="room-card">
                                            <!-- Card Header: icon + mã phòng -->
                                            <div class="room-card-header">
                                                <div class="room-card-icon ${isEye ? 'eye' : (isSurgery ? 'surgery' : 'default')}">
                                                    <i class="bi ${isEye ? 'bi-eye' : (isSurgery ? 'bi-scissors' : 'bi-hospital')}"></i>
                                                </div>
                                                <span class="room-card-id-badge">MÃ P-${room.id}</span>
                                            </div>

                                            <!-- Card Body: tên phòng + nhân sự -->
                                            <div class="room-card-body">
                                                <h6 class="room-card-name">${room.name}</h6>

                                                <div>
                                                    <div class="room-card-staff-label mb-1">Nhân sự phụ trách:</div>
                                                    <c:choose>
                                                        <c:when test="${not empty assignedDoctor}">
                                                            <div class="room-card-staff-info">
                                                                <div class="room-card-staff-avatar doctor">
                                                                    <i class="bi bi-person-fill"></i>
                                                                </div>
                                                                <div>
                                                                    <div>${assignedDoctor.name}</div>
                                                                    <div class="room-card-staff-sub">${assignedDoctor.specialty}</div>
                                                                </div>
                                                            </div>
                                                        </c:when>
                                                        <c:when test="${not empty assignedSpecialist}">
                                                            <div class="room-card-staff-info">
                                                                <div class="room-card-staff-avatar specialist">
                                                                    <i class="bi bi-person-fill"></i>
                                                                </div>
                                                                <div>
                                                                    <div>${assignedSpecialist.name}</div>
                                                                    <div class="room-card-staff-sub">${assignedSpecialist.specialty}</div>
                                                                </div>
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="room-card-staff-info text-muted">
                                                                <i class="bi bi-dash-circle me-1"></i>Chưa phân công
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>

                                            <!-- Card Footer: actions -->
                                            <div class="room-card-actions">
                                                <button class="btn-update" data-bs-toggle="modal"
                                                        data-bs-target="#editRoomModal${room.id}">
                                                    <i class="bi bi-pencil-square me-1"></i>Cập nhật
                                                </button>
                                                <button class="btn-del" data-bs-toggle="modal"
                                                        data-bs-target="#deleteRoomModal${room.id}" title="Xóa phòng">
                                                    <i class="bi bi-trash"></i>
                                                </button>
                                            </div>
                                        </div>

                                        <!-- Edit Room Modal -->
                                        <div class="modal fade" id="editRoomModal${room.id}" tabindex="-1">
                                            <div class="modal-dialog">
                                                <div class="modal-content border-0 shadow">
                                                    <form action="${pageContext.request.contextPath}/admin/room-config" method="post">
                                                        <input type="hidden" name="action" value="edit">
                                                        <input type="hidden" name="roomId" value="${room.id}">
                                                        <input type="hidden" name="tab" value="rooms">
                                                        <div class="modal-header border-0 pb-0">
                                                            <h5 class="modal-title fw-bold text-primary">Sửa Tên Phòng Khám</h5>
                                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                        </div>
                                                        <div class="modal-body p-4">
                                                            <div class="mb-3">
                                                                <label class="form-label fw-semibold">Tên phòng</label>
                                                                <input type="text" name="roomName" class="form-control" value="${room.name}"
                                                                       required oninput="checkRoomTypeForEdit(this, ${room.id})">
                                                            </div>
                                                            <div id="docDivEdit${room.id}" class="mb-3"
                                                                 style="display: ${isSurgery ? 'none' : 'block'};">
                                                                <label class="form-label fw-semibold">Người phụ trách (Bác sĩ)</label>
                                                                <select name="doctorId" class="form-select">
                                                                    <option value="">-- Không có / Bỏ trống --</option>
                                                                    <c:forEach var="doctor" items="${doctors}">
                                                                        <c:if test="${doctor.roomId == room.id || doctor.roomId == 0 || empty doctor.roomId}">
                                                                            <option value="${doctor.id}" ${doctor.roomId == room.id ? 'selected' : ''}>
                                                                                ${doctor.name} - ${doctor.specialty}
                                                                            </option>
                                                                        </c:if>
                                                                    </c:forEach>
                                                                </select>
                                                                <div class="form-text text-muted small">Chỉ phòng khám mắt mới chọn được Bác sĩ.</div>
                                                            </div>

                                                            <div id="specDivEdit${room.id}" class="mb-3"
                                                                 style="display: ${isSurgery ? 'block' : 'none'};">
                                                                <label class="form-label fw-semibold">Người phụ trách (Chuyên viên y tế)</label>
                                                                <select name="specialistId" class="form-select">
                                                                    <option value="">-- Không có / Bỏ trống --</option>
                                                                    <c:forEach var="specialist" items="${specialists}">
                                                                        <c:if test="${specialist.roomId == room.id || specialist.roomId == 0 || empty specialist.roomId}">
                                                                            <option value="${specialist.id}" ${specialist.roomId == room.id ? 'selected' : ''}>
                                                                                ${specialist.name} - ${specialist.specialty}
                                                                            </option>
                                                                        </c:if>
                                                                    </c:forEach>
                                                                </select>
                                                                <div class="form-text text-muted small">Chỉ phòng tiểu phẫu/phẫu thuật mới chọn được Chuyên viên y tế.</div>
                                                            </div>
                                                        </div>
                                                        <div class="modal-footer border-0 pt-0">
                                                            <button type="button" class="btn btn-secondary px-4 rounded-pill"
                                                                    data-bs-dismiss="modal">Hủy</button>
                                                            <button type="submit" class="btn btn-primary px-4 rounded-pill">Cập nhật</button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- End Edit Modal -->

                                        <!-- Delete Room Modal -->
                                        <div class="modal fade" id="deleteRoomModal${room.id}" tabindex="-1">
                                            <div class="modal-dialog modal-dialog-centered">
                                                <div class="modal-content border-0 shadow">
                                                    <form action="${pageContext.request.contextPath}/admin/room-config" method="post">
                                                        <input type="hidden" name="action" value="delete">
                                                        <input type="hidden" name="roomId" value="${room.id}">
                                                        <input type="hidden" name="tab" value="rooms">
                                                        <div class="modal-header border-0 pb-0">
                                                            <h5 class="modal-title fw-bold text-danger"><i class="bi bi-exclamation-triangle me-2"></i>Xác nhận Xóa Phòng Khám</h5>
                                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                        </div>
                                                        <div class="modal-body p-4 text-center">
                                                            <p class="mb-2 fs-6">Bạn có chắc chắn muốn xóa phòng <strong>${room.name}</strong> không?</p>
                                                            <p class="text-muted small mb-0">Hành động này sẽ xóa phòng khỏi hệ thống.</p>
                                                        </div>
                                                        <div class="modal-footer border-0 justify-content-center pt-0">
                                                            <button type="button" class="btn btn-secondary px-4 rounded-pill"
                                                                    data-bs-dismiss="modal">Hủy</button>
                                                            <button type="submit" class="btn btn-danger px-4 rounded-pill">Xóa phòng</button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- End Delete Room Modal -->
                                    </c:forEach>

                                    <!-- Add New Room Card -->
                                    <a href="javascript:void(0)" class="add-room-card" data-bs-toggle="modal" data-bs-target="#addRoomModal">
                                        <i class="bi bi-plus-circle"></i>
                                        <span>Thêm phòng mới<br><small class="fw-normal" style="opacity:0.7">Bấm để tạo phòng khám/điều trị</small></span>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </c:if>

                    <c:if test="${currentTab == 'rules'}">
                        <!-- Work Schedule Registration Rules Screen -->
                        <div class="col-lg-12">
                            <div class="admin-card">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <div>
                                        <h5 class="mb-1 fw-bold"><i class="bi bi-sliders me-2 text-primary"></i>Quy định Đăng ký Lịch làm việc</h5>
                                        <p class="text-muted small mb-0">Thiết lập số giờ làm việc tối thiểu mỗi tuần áp dụng cho Bác sĩ và Nhân viên khi gửi đăng ký lịch.</p>
                                    </div>
                                </div>
                                <form action="${pageContext.request.contextPath}/admin/timeslot-config" method="post" class="row g-3 align-items-end">
                                    <input type="hidden" name="action" value="update_min_hours">
                                    <input type="hidden" name="returnTab" value="rules">
                                    <div class="col-md-5 col-lg-4">
                                        <label class="form-label fw-semibold small text-secondary">
                                            Số giờ làm việc tối thiểu / tuần
                                            <span class="text-muted fw-normal">(Tối đa: ${not empty maxWeeklyHours ? maxWeeklyHours : 49.0}h)</span>
                                        </label>
                                        <div class="input-group">
                                            <span class="input-group-text bg-light"><i class="bi bi-clock"></i></span>
                                            <input type="number" step="0.5" min="0"
                                                   max="${not empty maxWeeklyHours ? maxWeeklyHours : 49.0}" name="minWorkHours"
                                                   class="form-control fw-bold text-primary"
                                                   value="${not empty minWorkHours ? minWorkHours : 30.0}" required>
                                            <span class="input-group-text bg-light text-muted">/ ${not empty maxWeeklyHours ? maxWeeklyHours : 49.0} giờ</span>
                                        </div>
                                    </div>
                                    <div class="col-md-4 col-lg-3">
                                        <button type="submit" class="btn btn-primary px-4 rounded-pill">
                                            <i class="bi bi-check-circle me-1"></i> Lưu quy định
                                        </button>
                                    </div>
                                    <div class="col-12 mt-2">
                                        <div class="small text-muted">
                                            <i class="bi bi-info-circle me-1 text-primary"></i>
                                            Tổng thời gian làm việc tối đa trong tuần hiện có: <strong>${not empty maxWeeklyHours ? maxWeeklyHours : 49.0} giờ</strong> (dựa trên các ca khám đang mở x 7 ngày/tuần). Số giờ làm tối thiểu bắt buộc phải <strong>nhỏ hơn hoặc bằng ${not empty maxWeeklyHours ? maxWeeklyHours : 49.0} giờ</strong>.
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </c:if>

                    <c:if test="${currentTab == 'holdtime'}">
                        <!-- Online Booking Hold Time Card Screen -->
                        <div class="col-lg-12">
                            <div class="admin-card">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <div>
                                        <h5 class="mb-1 fw-bold"><i class="bi bi-stopwatch me-2 text-danger"></i>Quy định Thời gian Giữ chỗ Đặt lịch (Pending Hold Time)</h5>
                                        <p class="text-muted small mb-0">Thiết lập thời gian tối đa giữ chỗ cho lịch hẹn trực tuyến khi bệnh nhân đang chờ thanh toán qua mã QR (mặc định 15 phút).</p>
                                    </div>
                                </div>
                                <form action="${pageContext.request.contextPath}/admin/timeslot-config" method="post" class="row g-3 align-items-end">
                                    <input type="hidden" name="action" value="update_pending_hold_minutes">
                                    <input type="hidden" name="returnTab" value="holdtime">
                                    <div class="col-md-5 col-lg-4">
                                        <label class="form-label fw-semibold small text-secondary">
                                            Thời gian giữ chỗ thanh toán
                                            <span class="text-muted fw-normal">(1 - 120 phút)</span>
                                        </label>
                                        <div class="input-group">
                                            <span class="input-group-text bg-light text-danger"><i class="bi bi-hourglass-split"></i></span>
                                            <input type="number" step="1" min="1" max="120" name="pendingHoldMinutes" id="pendingHoldMinutesInput"
                                                   class="form-control fw-bold text-danger"
                                                   value="${not empty pendingHoldMinutes ? pendingHoldMinutes : 15}" required>
                                            <span class="input-group-text bg-light text-muted">phút</span>
                                        </div>
                                    </div>
                                    <div class="col-md-4 col-lg-4">
                                        <label class="form-label fw-semibold small text-secondary d-block">Chọn nhanh:</label>
                                        <div class="btn-group" role="group">
                                            <button type="button" class="btn btn-outline-secondary btn-sm" onclick="document.getElementById('pendingHoldMinutesInput').value = 5;">5p</button>
                                            <button type="button" class="btn btn-outline-secondary btn-sm" onclick="document.getElementById('pendingHoldMinutesInput').value = 10;">10p</button>
                                            <button type="button" class="btn btn-outline-secondary btn-sm" onclick="document.getElementById('pendingHoldMinutesInput').value = 15;">15p</button>
                                            <button type="button" class="btn btn-outline-secondary btn-sm" onclick="document.getElementById('pendingHoldMinutesInput').value = 30;">30p</button>
                                        </div>
                                    </div>
                                    <div class="col-md-3 col-lg-4 text-md-end">
                                        <button type="submit" class="btn btn-danger px-4 rounded-pill">
                                            <i class="bi bi-check-circle me-1"></i> Lưu thời gian giữ chỗ
                                        </button>
                                    </div>
                                    <div class="col-12 mt-2">
                                        <div class="small text-muted">
                                            <i class="bi bi-info-circle me-1 text-danger"></i>
                                            Khi bệnh nhân chọn giờ và nhận mã QR, slot này sẽ bị khóa tạm thời <strong>đúng ${not empty pendingHoldMinutes ? pendingHoldMinutes : 15} phút</strong>. Quá thời gian này hoặc khi bệnh nhân bấm hủy, hệ thống sẽ tự động giải phóng slot cho người khác.
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </c:if>

                    <c:if test="${currentTab == 'buffer'}">
                        <!-- Buffer Slot Policy Card Screen -->
                        <div class="col-lg-12">
                            <div class="admin-card">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <div>
                                        <h5 class="mb-1 fw-bold"><i class="bi bi-shield-check me-2 text-success"></i>Chính sách Ca đệm cuối buổi khám (Buffer Slot)</h5>
                                        <p class="text-muted small mb-0">Cấu hình có dành riêng 30 phút cuối mỗi ca (11:00 - 11:30 và 16:30 - 17:00) để xử lý bù giờ cho các ca khám phức tạp hay không.</p>
                                    </div>
                                </div>
                                <form action="${pageContext.request.contextPath}/admin/timeslot-config" method="post" class="row g-3 align-items-center">
                                    <input type="hidden" name="action" value="update_session_buffer">
                                    <input type="hidden" name="returnTab" value="buffer">
                                    <div class="col-md-7">
                                        <div class="form-check form-switch fs-5">
                                            <input class="form-check-input" type="checkbox" name="sessionEndBufferEnabled" value="true" id="sessionBufferSwitch" ${sessionEndBufferEnabled ? 'checked' : ''}>
                                            <label class="form-check-label fs-6 fw-semibold ms-2" for="sessionBufferSwitch">
                                                Dành 30 phút cuối mỗi buổi khám làm thời gian đệm (Buffer Slot)
                                            </label>
                                        </div>
                                        <div class="small text-muted mt-2">
                                            <c:choose>
                                                <c:when test="${sessionEndBufferEnabled}">
                                                    <span class="badge bg-success-subtle text-success me-1"><i class="bi bi-shield-lock me-1"></i>Đang bật</span>
                                                    Bệnh nhân chỉ được đặt đến <strong>11:00</strong> (ca sáng) và <strong>16:30</strong> (ca chiều). Khung giờ 11:00 - 11:30 và 16:30 - 17:00 được giữ lại để phòng ngừa quá giờ.
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-primary-subtle text-primary me-1"><i class="bi bi-calendar-check me-1"></i>Đang tắt</span>
                                                    Mở toàn bộ ca bác sĩ đăng ký: Bệnh nhân được đặt đến <strong>11:30</strong> (ca sáng có slot 11:00 - 11:30) và <strong>17:00</strong> (ca chiều có slot 16:30 - 17:00).
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                    <div class="col-md-5 text-md-end">
                                        <button type="submit" class="btn btn-success px-4 rounded-pill">
                                            <i class="bi bi-check-circle me-1"></i> Lưu cấu hình Buffer Slot
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </c:if>

                    <c:if test="${currentTab == 'slots'}">
                        <!-- Appointment Time Slots Screen -->
                        <c:set var="mTotal" value="0" />
                        <c:set var="mActive" value="0" />
                        <c:set var="aTotal" value="0" />
                        <c:set var="aActive" value="0" />
                        <c:forEach var="slot" items="${timeSlots}">
                            <c:if test="${slot.session == 'Morning'}">
                                <c:set var="mTotal" value="${mTotal + 1}" />
                                <c:if test="${slot.status == 'Available'}"><c:set var="mActive" value="${mActive + 1}" /></c:if>
                            </c:if>
                            <c:if test="${slot.session == 'Afternoon'}">
                                <c:set var="aTotal" value="${aTotal + 1}" />
                                <c:if test="${slot.status == 'Available'}"><c:set var="aActive" value="${aActive + 1}" /></c:if>
                            </c:if>
                        </c:forEach>

                        <!-- Shift Overview / Balance Cards (High Contrast 4-Card Grid) -->
                        <div class="col-12 mb-4">
                            <div class="row g-3">
                                <!-- Morning Shift Card -->
                                <div class="col-md-6 col-xl-3">
                                    <div class="slot-summary-card morning-card">
                                        <div>
                                            <div class="d-flex align-items-center justify-content-between mb-3">
                                                <span class="badge-morning-tag">
                                                    <i class="bi bi-sunrise-fill me-1" style="color: #d97706;"></i> Ca Sáng
                                                </span>
                                                <span class="badge" style="background: #dcfce7; color: #15803d; border: 1px solid #86efac; font-weight: 700; font-size: 12px; padding: 5px 10px; border-radius: 6px;">
                                                    <i class="bi bi-check-circle-fill me-1"></i>${mActive} / ${mTotal} ca mở
                                                </span>
                                            </div>
                                            <h3 class="fw-bold mb-1 text-dark" style="letter-spacing: -0.5px;">08:00 — 11:30</h3>
                                            <p class="text-secondary small mb-0 fw-medium">Thời lượng <strong>3.5 giờ</strong> (7 ca chuẩn, 30p/ca)</p>
                                        </div>
                                        <div class="mt-3 pt-2 border-top">
                                            <c:choose>
                                                <c:when test="${sessionEndBufferEnabled}">
                                                    <span class="badge-buffer-tag"><i class="bi bi-shield-lock-fill me-1" style="color:#d97706;"></i>Buffer: 11:00 - 11:30</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted small"><i class="bi bi-clock-history me-1 text-success"></i>Mở nhận hẹn suốt ca</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>

                                <!-- Lunch Break Card -->
                                <div class="col-md-6 col-xl-3">
                                    <div class="slot-summary-card lunch-card">
                                        <div>
                                            <div class="d-flex align-items-center justify-content-between mb-3">
                                                <span class="badge-lunch-tag">
                                                    <i class="bi bi-cup-hot-fill me-1" style="color: #0284c7;"></i> Nghỉ Trưa
                                                </span>
                                                <span class="badge" style="background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; font-weight: 600; font-size: 12px; padding: 5px 10px; border-radius: 6px;">
                                                    Khoảng nghỉ
                                                </span>
                                            </div>
                                            <h3 class="fw-bold mb-1 text-dark" style="letter-spacing: -0.5px;">11:30 — 13:30</h3>
                                            <p class="text-secondary small mb-0 fw-medium">Thời lượng <strong>2.0 giờ</strong> (120 phút nghỉ trưa)</p>
                                        </div>
                                        <div class="mt-3 pt-2 border-top">
                                            <span class="badge" style="background: #e0f2fe; color: #0369a1; border: 1px solid #bae6fd; font-weight: 600; font-size: 12px;">
                                                <i class="bi bi-lock-fill me-1"></i>Tự động khóa đặt lịch
                                            </span>
                                        </div>
                                    </div>
                                </div>

                                <!-- Afternoon Shift Card -->
                                <div class="col-md-6 col-xl-3">
                                    <div class="slot-summary-card afternoon-card">
                                        <div>
                                            <div class="d-flex align-items-center justify-content-between mb-3">
                                                <span class="badge-afternoon-tag">
                                                    <i class="bi bi-sun-fill me-1" style="color: #15803d;"></i> Ca Chiều
                                                </span>
                                                <span class="badge" style="background: #dcfce7; color: #15803d; border: 1px solid #86efac; font-weight: 700; font-size: 12px; padding: 5px 10px; border-radius: 6px;">
                                                    <i class="bi bi-check-circle-fill me-1"></i>${aActive} / ${aTotal} ca mở
                                                </span>
                                            </div>
                                            <h3 class="fw-bold mb-1 text-dark" style="letter-spacing: -0.5px;">13:30 — 17:00</h3>
                                            <p class="text-secondary small mb-0 fw-medium">Thời lượng <strong>3.5 giờ</strong> (7 ca chuẩn, 30p/ca)</p>
                                        </div>
                                        <div class="mt-3 pt-2 border-top">
                                            <c:choose>
                                                <c:when test="${sessionEndBufferEnabled}">
                                                    <span class="badge-buffer-tag"><i class="bi bi-shield-lock-fill me-1" style="color:#d97706;"></i>Buffer: 16:30 - 17:00</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted small"><i class="bi bi-clock-history me-1 text-success"></i>Mở nhận hẹn suốt ca</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>

                                <!-- Buffer Policy Summary Card -->
                                <div class="col-md-6 col-xl-3">
                                    <div class="slot-summary-card buffer-card">
                                        <div>
                                            <div class="d-flex align-items-center justify-content-between mb-3">
                                                <span class="badge" style="background: #ede9fe; color: #5b21b6; border: 1px solid #ddd6fe; font-weight: 700; font-size: 13px; padding: 6px 14px; border-radius: 20px;">
                                                    <i class="bi bi-shield-check me-1" style="color: #7c3aed;"></i> Ca Đệm (Buffer)
                                                </span>
                                                <c:choose>
                                                    <c:when test="${sessionEndBufferEnabled}">
                                                        <span class="badge" style="background: #fef3c7; color: #78350f; border: 1px solid #f59e0b; font-weight: 800; font-size: 12px; padding: 5px 10px; border-radius: 6px;">
                                                            <i class="bi bi-check-circle-fill me-1" style="color: #d97706;"></i>ĐANG BẬT
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge" style="background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; font-weight: 700; font-size: 12px; padding: 5px 10px; border-radius: 6px;">
                                                            <i class="bi bi-x-circle me-1"></i>ĐANG TẮT
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <c:choose>
                                                <c:when test="${sessionEndBufferEnabled}">
                                                    <h4 class="fw-bold mb-1" style="color: #78350f; letter-spacing: -0.5px;">Dành 30p Cuối Ca</h4>
                                                    <p class="text-secondary small mb-0 fw-medium">Slot 11h & 16h30 giữ lại xử lý bù giờ cho ca khám dài.</p>
                                                </c:when>
                                                <c:otherwise>
                                                    <h4 class="fw-bold mb-1 text-dark" style="letter-spacing: -0.5px;">Mở Cả 14 Ca Chuẩn</h4>
                                                    <p class="text-secondary small mb-0 fw-medium">Bệnh nhân được đặt lịch đến tận 11:30 và 17:00.</p>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="mt-3 pt-2 border-top">
                                            <a href="${pageContext.request.contextPath}/admin/clinic-config?tab=rules" class="btn btn-sm btn-outline-secondary rounded-pill px-3 fw-semibold w-100 text-truncate" style="font-size: 12px;">
                                                <i class="bi bi-sliders me-1"></i>Đổi cài đặt Buffer tại Quy tắc
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-lg-12">
                            <div class="admin-card">
                                    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
                                        <div>
                                            <h5 class="mb-1 fw-bold text-dark"><i class="bi bi-clock-history me-2 text-primary"></i>Danh Sách Khung Giờ Khám Bệnh</h5>
                                            <p class="text-secondary small mb-0">Hệ thống cân bằng chuẩn: <strong>Ca Sáng (08:00 - 11:30)</strong> và <strong>Ca Chiều (13:30 - 17:00)</strong> gồm <strong>14 khung giờ</strong> (30 phút/ca), nghỉ trưa 2 tiếng.</p>
                                        </div>
                                        <div class="d-flex gap-2">
                                            <button class="btn btn-sm rounded-pill px-3 fw-bold shadow-sm" style="background: #fef3c7; color: #78350f; border: 1.5px solid #f59e0b;" data-bs-toggle="modal" data-bs-target="#resetStandardSlotsModal">
                                                <i class="bi bi-arrow-repeat me-1" style="color: #d97706;"></i> Đặt lại 14 ca chuẩn
                                            </button>
                                            <button class="btn btn-sm btn-primary rounded-pill px-3 fw-bold shadow-sm" data-bs-toggle="modal" data-bs-target="#addSlotModal">
                                                <i class="bi bi-plus-lg me-1"></i> Thêm khung giờ
                                            </button>
                                        </div>
                                    </div>

                                    <!-- BẢNG CA SÁNG -->
                                    <div class="session-bar-morning d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
                                        <div class="d-flex align-items-center">
                                            <div class="rounded-circle d-flex align-items-center justify-content-center me-3" style="width: 42px; height: 42px; background: #fef3c7; color: #b45309; font-size: 20px;">
                                                <i class="bi bi-sunrise-fill"></i>
                                            </div>
                                            <div>
                                                <div class="fw-bold fs-6 text-dark" style="letter-spacing: 0.3px;">KHUNG GIỜ CA SÁNG (08:00 — 11:30)</div>
                                                <div class="text-secondary small">7 khung giờ tiêu chuẩn • 30 phút mỗi ca</div>
                                            </div>
                                        </div>
                                        <div class="d-flex align-items-center gap-2">
                                            <span class="badge" style="background: #fef3c7; color: #78350f; border: 1px solid #fde68a; font-weight: 700; font-size: 13px; padding: 6px 14px; border-radius: 20px;">7 Ca Tiêu Chuẩn (3.5h)</span>
                                            <c:if test="${sessionEndBufferEnabled}">
                                                <span class="badge-buffer-tag"><i class="bi bi-shield-lock-fill me-1" style="color: #d97706;"></i>Ca 7: Buffer Slot</span>
                                            </c:if>
                                        </div>
                                    </div>

                                    <div class="table-responsive mb-4">
                                        <table class="table align-middle table-hover border">
                                            <thead class="table-light">
                                                <tr>
                                                    <th style="width: 22%;" class="fw-bold text-dark">Tên Ca Khám</th>
                                                    <th style="width: 25%;" class="fw-bold text-dark">Thời Gian</th>
                                                    <th style="width: 23%;" class="fw-bold text-dark">Phân Loại Khung Giờ</th>
                                                    <th style="width: 15%;" class="fw-bold text-dark">Trạng Thái</th>
                                                    <th style="width: 15%;" class="text-end fw-bold text-dark">Thao Tác</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:set var="hasMorningSlot" value="false" />
                                                <c:forEach var="slot" items="${timeSlots}">
                                                    <c:if test="${slot.session == 'Morning'}">
                                                        <c:set var="hasMorningSlot" value="true" />
                                                        <c:set var="sStart" value="${fn:length(slot.startTime) >= 5 ? fn:substring(slot.startTime, 0, 5) : slot.startTime}" />
                                                        <c:set var="sEnd" value="${fn:length(slot.endTime) >= 5 ? fn:substring(slot.endTime, 0, 5) : slot.endTime}" />
                                                        <c:set var="isMorningBuffer" value="${sessionEndBufferEnabled && sStart == '11:00' && sEnd == '11:30'}" />
                                                        <tr>
                                                            <td class="fw-bold text-dark">
                                                                <i class="bi bi-clock me-1.5 text-secondary"></i>${slot.slotName}
                                                            </td>
                                                            <td>
                                                                <span class="slot-time-pill">${sStart} — ${sEnd}</span>
                                                            </td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${isMorningBuffer}">
                                                                        <span class="badge-buffer-tag">
                                                                            <i class="bi bi-shield-lock-fill me-1" style="color: #d97706;"></i>Ca đệm (Buffer Slot)
                                                                        </span>
                                                                        <div class="text-muted small mt-1" style="font-size: 11px;">Dành riêng xử lý bù giờ kéo dài</div>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="badge" style="background: #f1f5f9; color: #334155; border: 1px solid #cbd5e1; font-weight: 600; padding: 5px 10px; border-radius: 6px;">
                                                                            <i class="bi bi-check2 me-1 text-success fw-bold"></i>Khám tiêu chuẩn (30p)
                                                                        </span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${slot.status eq 'Available'}">
                                                                        <span class="slot-status-active">
                                                                            <i class="bi bi-check-circle-fill me-1"></i>Đang mở
                                                                        </span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="slot-status-inactive">
                                                                            <i class="bi bi-x-circle-fill me-1"></i>Đang đóng
                                                                        </span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td class="text-end text-nowrap">
                                                                <button class="btn btn-sm btn-outline-primary rounded-pill px-3 me-1 fw-semibold" data-bs-toggle="modal"
                                                                        data-bs-target="#editSlotModal${slot.slotId}"><i class="bi bi-pencil-square me-1"></i>Sửa</button>
                                                                <button class="btn btn-sm btn-outline-danger rounded-pill px-2 fw-semibold" data-bs-toggle="modal"
                                                                        data-bs-target="#deleteSlotModal${slot.slotId}" title="Xóa khung giờ này"><i class="bi bi-trash"></i></button>
                                                            </td>
                                                        </tr>
                                                    </c:if>
                                                </c:forEach>
                                                <c:if test="${!hasMorningSlot}">
                                                    <tr>
                                                        <td colspan="5" class="text-center py-4 text-muted">Chưa có khung giờ nào cho ca sáng. Bấm "Đặt lại 14 ca chuẩn" để kích hoạt!</td>
                                                    </tr>
                                                </c:if>
                                            </tbody>
                                        </table>
                                    </div>

                                    <!-- NGHỈ TRƯA DIVIDER -->
                                    <div class="lunch-break-box d-flex align-items-center justify-content-between flex-wrap gap-3">
                                        <div class="d-flex align-items-center">
                                            <div class="rounded-circle d-flex align-items-center justify-content-center me-3" style="width: 48px; height: 48px; background: #0284c7; color: #ffffff; font-size: 22px;">
                                                <i class="bi bi-cup-hot-fill"></i>
                                            </div>
                                            <div>
                                                <div class="fw-bold fs-6" style="color: #0369a1; letter-spacing: 0.3px;">
                                                    KHOẢNG NGHỈ TRƯA: 11:30 — 13:30 (120 PHÚT)
                                                </div>
                                                <div class="text-secondary small mt-0.5">
                                                    Thời gian ăn trưa và nghỉ ngơi hồi phục của Bác sĩ & Kỹ thuật viên. Hệ thống tự động khóa không nhận đặt hẹn bệnh nhân.
                                                </div>
                                            </div>
                                        </div>
                                        <div>
                                            <span class="badge" style="background: #0284c7; color: #ffffff; font-size: 13px; font-weight: 600; padding: 8px 16px; border-radius: 20px;">
                                                <i class="bi bi-moon-stars-fill me-1"></i> Nghỉ trưa 2 tiếng
                                            </span>
                                        </div>
                                    </div>

                                    <!-- BẢNG CA CHIỀU -->
                                    <div class="session-bar-afternoon d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
                                        <div class="d-flex align-items-center">
                                            <div class="rounded-circle d-flex align-items-center justify-content-center me-3" style="width: 42px; height: 42px; background: #dcfce7; color: #15803d; font-size: 20px;">
                                                <i class="bi bi-sun-fill"></i>
                                            </div>
                                            <div>
                                                <div class="fw-bold fs-6 text-dark" style="letter-spacing: 0.3px;">KHUNG GIỜ CA CHIỀU (13:30 — 17:00)</div>
                                                <div class="text-secondary small">7 khung giờ tiêu chuẩn • 30 phút mỗi ca</div>
                                            </div>
                                        </div>
                                        <div class="d-flex align-items-center gap-2">
                                            <span class="badge" style="background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; font-weight: 700; font-size: 13px; padding: 6px 14px; border-radius: 20px;">7 Ca Tiêu Chuẩn (3.5h)</span>
                                            <c:if test="${sessionEndBufferEnabled}">
                                                <span class="badge-buffer-tag"><i class="bi bi-shield-lock-fill me-1" style="color: #d97706;"></i>Ca 14: Buffer Slot</span>
                                            </c:if>
                                        </div>
                                    </div>

                                    <div class="table-responsive mb-4">
                                        <table class="table align-middle table-hover border">
                                            <thead class="table-light">
                                                <tr>
                                                    <th style="width: 22%;" class="fw-bold text-dark">Tên Ca Khám</th>
                                                    <th style="width: 25%;" class="fw-bold text-dark">Thời Gian</th>
                                                    <th style="width: 23%;" class="fw-bold text-dark">Phân Loại Khung Giờ</th>
                                                    <th style="width: 15%;" class="fw-bold text-dark">Trạng Thái</th>
                                                    <th style="width: 15%;" class="text-end fw-bold text-dark">Thao Tác</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:set var="hasAfternoonSlot" value="false" />
                                                <c:forEach var="slot" items="${timeSlots}">
                                                    <c:if test="${slot.session == 'Afternoon'}">
                                                        <c:set var="hasAfternoonSlot" value="true" />
                                                        <c:set var="sStart" value="${fn:length(slot.startTime) >= 5 ? fn:substring(slot.startTime, 0, 5) : slot.startTime}" />
                                                        <c:set var="sEnd" value="${fn:length(slot.endTime) >= 5 ? fn:substring(slot.endTime, 0, 5) : slot.endTime}" />
                                                        <c:set var="isAfternoonBuffer" value="${sessionEndBufferEnabled && sStart == '16:30' && sEnd == '17:00'}" />
                                                        <tr>
                                                            <td class="fw-bold text-dark">
                                                                <i class="bi bi-clock me-1.5 text-secondary"></i>${slot.slotName}
                                                            </td>
                                                            <td>
                                                                <span class="slot-time-pill">${sStart} — ${sEnd}</span>
                                                            </td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${isAfternoonBuffer}">
                                                                        <span class="badge-buffer-tag">
                                                                            <i class="bi bi-shield-lock-fill me-1" style="color: #d97706;"></i>Ca đệm (Buffer Slot)
                                                                        </span>
                                                                        <div class="text-muted small mt-1" style="font-size: 11px;">Dành riêng xử lý bù giờ kéo dài</div>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="badge" style="background: #f1f5f9; color: #334155; border: 1px solid #cbd5e1; font-weight: 600; padding: 5px 10px; border-radius: 6px;">
                                                                            <i class="bi bi-check2 me-1 text-success fw-bold"></i>Khám tiêu chuẩn (30p)
                                                                        </span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${slot.status eq 'Available'}">
                                                                        <span class="slot-status-active">
                                                                            <i class="bi bi-check-circle-fill me-1"></i>Đang mở
                                                                        </span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="slot-status-inactive">
                                                                            <i class="bi bi-x-circle-fill me-1"></i>Đang đóng
                                                                        </span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td class="text-end text-nowrap">
                                                                <button class="btn btn-sm btn-outline-primary rounded-pill px-3 me-1 fw-semibold" data-bs-toggle="modal"
                                                                        data-bs-target="#editSlotModal${slot.slotId}"><i class="bi bi-pencil-square me-1"></i>Sửa</button>
                                                                <button class="btn btn-sm btn-outline-danger rounded-pill px-2 fw-semibold" data-bs-toggle="modal"
                                                                        data-bs-target="#deleteSlotModal${slot.slotId}" title="Xóa khung giờ này"><i class="bi bi-trash"></i></button>
                                                            </td>
                                                        </tr>
                                                    </c:if>
                                                </c:forEach>
                                                <c:if test="${!hasAfternoonSlot}">
                                                    <tr>
                                                        <td colspan="5" class="text-center py-4 text-muted">Chưa có khung giờ nào cho ca chiều. Bấm "Đặt lại 14 ca chuẩn" để kích hoạt!</td>
                                                    </tr>
                                                </c:if>
                                            </tbody>
                                        </table>
                                    </div>

                                <!-- CÁC CA KHÁC / CA TÙY CHỈNH (NẾU CÓ) -->
                                <c:set var="hasOtherSlots" value="false" />
                                <c:forEach var="slot" items="${timeSlots}">
                                    <c:if test="${slot.session != 'Morning' && slot.session != 'Afternoon'}">
                                        <c:set var="hasOtherSlots" value="true" />
                                    </c:if>
                                </c:forEach>
                                <c:if test="${hasOtherSlots}">
                                    <div class="p-3 bg-light rounded-3 mb-3 border">
                                        <div class="fw-bold text-secondary">
                                            <i class="bi bi-three-dots me-2"></i>CÁC KHUNG GIỜ KHÁC / CA TÙY CHỈNH
                                        </div>
                                    </div>
                                    <div class="table-responsive">
                                        <table class="table align-middle table-hover border">
                                            <thead class="table-light">
                                                <tr>
                                                    <th style="width: 25%;" class="fw-bold text-dark">Tên Ca Khám</th>
                                                    <th style="width: 25%;" class="fw-bold text-dark">Thời Gian</th>
                                                    <th style="width: 20%;" class="fw-bold text-dark">Thời Lượng</th>
                                                    <th style="width: 15%;" class="fw-bold text-dark">Trạng Thái</th>
                                                    <th style="width: 15%;" class="text-end fw-bold text-dark">Thao Tác</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="slot" items="${timeSlots}">
                                                    <c:if test="${slot.session != 'Morning' && slot.session != 'Afternoon'}">
                                                        <tr>
                                                            <td class="fw-bold text-dark"><i class="bi bi-clock me-1.5 text-secondary"></i>${slot.slotName}</td>
                                                            <c:set var="sOtherStart" value="${fn:length(slot.startTime) >= 5 ? fn:substring(slot.startTime, 0, 5) : slot.startTime}" />
                                                            <c:set var="sOtherEnd" value="${fn:length(slot.endTime) >= 5 ? fn:substring(slot.endTime, 0, 5) : slot.endTime}" />
                                                            <td><span class="slot-time-pill">${sOtherStart} — ${sOtherEnd}</span></td>
                                                            <td><span class="text-secondary small fw-medium">30 phút</span></td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${slot.status eq 'Available'}">
                                                                        <span class="slot-status-active"><i class="bi bi-check-circle-fill me-1"></i>Đang mở</span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="slot-status-inactive"><i class="bi bi-x-circle-fill me-1"></i>Đang đóng</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td class="text-end text-nowrap">
                                                                <button class="btn btn-sm btn-outline-primary rounded-pill px-3 me-1 fw-semibold" data-bs-toggle="modal"
                                                                        data-bs-target="#editSlotModal${slot.slotId}"><i class="bi bi-pencil-square me-1"></i>Sửa</button>
                                                                <button class="btn btn-sm btn-outline-danger rounded-pill px-2 fw-semibold" data-bs-toggle="modal"
                                                                        data-bs-target="#deleteSlotModal${slot.slotId}" title="Xóa khung giờ này"><i class="bi bi-trash"></i></button>
                                                            </td>
                                                        </tr>
                                                    </c:if>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:if>

                                <!-- Edit Slot Modals for All Slots -->
                                <c:forEach var="slot" items="${timeSlots}">
                                    <div class="modal fade" id="editSlotModal${slot.slotId}" tabindex="-1">
                                        <div class="modal-dialog modal-dialog-centered">
                                            <div class="modal-content border-0 shadow">
                                                <form action="${pageContext.request.contextPath}/admin/timeslot-config" method="post">
                                                    <input type="hidden" name="action" value="edit">
                                                    <input type="hidden" name="slotId" value="${slot.slotId}">
                                                    <div class="modal-header border-0 pb-0">
                                                        <h5 class="modal-title fw-bold text-primary"><i class="bi bi-pencil-square me-2"></i>Sửa Khung Giờ Khám #${slot.slotId}</h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <div class="modal-body p-4">
                                                        <div class="mb-3">
                                                            <label class="form-label fw-semibold">Tên ca (Slot Name)</label>
                                                            <input type="text" name="slotName" class="form-control" value="${slot.slotName}" required>
                                                        </div>
                                                        <div class="row mb-3">
                                                            <div class="col-6">
                                                                <label class="form-label fw-semibold">Giờ bắt đầu</label>
                                                                <input type="time" name="startTime" class="form-control" value="${slot.startTime}" required>
                                                            </div>
                                                            <div class="col-6">
                                                                <label class="form-label fw-semibold">Giờ kết thúc</label>
                                                                <input type="time" name="endTime" class="form-control" value="${slot.endTime}" required>
                                                            </div>
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label fw-semibold">Trạng thái</label>
                                                            <select name="status" class="form-select" required>
                                                                <option value="Available" ${slot.status=='Available' ? 'selected' : ''}>Hoạt động</option>
                                                                <option value="Canceled" ${slot.status !='Available' ? 'selected' : ''}>Ngừng hoạt động (Tắt)</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer border-0 pt-0">
                                                        <button type="button" class="btn btn-secondary px-4 rounded-pill" data-bs-dismiss="modal">Hủy</button>
                                                        <button type="submit" class="btn btn-primary px-4 rounded-pill">Cập nhật</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Delete Slot Modal -->
                                    <div class="modal fade" id="deleteSlotModal${slot.slotId}" tabindex="-1">
                                        <div class="modal-dialog modal-dialog-centered">
                                            <div class="modal-content border-0 shadow">
                                                <form action="${pageContext.request.contextPath}/admin/timeslot-config" method="post">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="slotId" value="${slot.slotId}">
                                                    <div class="modal-header border-0 pb-0">
                                                        <h5 class="modal-title fw-bold text-danger"><i class="bi bi-trash me-2"></i>Xác nhận Xóa Khung Giờ</h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <div class="modal-body p-4 text-center">
                                                        <p class="mb-2 fs-6">Bạn có chắc chắn muốn xóa khung giờ <strong>${slot.slotName}</strong> (${slot.startTime} — ${slot.endTime}) không?</p>
                                                        <p class="text-muted small mb-0">Hành động này sẽ xóa vĩnh viễn khung giờ này khỏi cấu hình phòng khám.</p>
                                                    </div>
                                                    <div class="modal-footer border-0 justify-content-center pt-0">
                                                        <button type="button" class="btn btn-secondary px-4 rounded-pill" data-bs-dismiss="modal">Hủy</button>
                                                        <button type="submit" class="btn btn-danger px-4 rounded-pill">Xóa khung giờ</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>

                            </div>
                        </div>
                    </c:if>

                    <c:if test="${currentTab == 'intro'}">
                        <c:set var="currentSubtab" value="${empty param.subtab || param.subtab == 'gallery' ? 'services' : param.subtab}" />

                        <!-- Sub-tab Navigation for Home Images -->
                        <div class="col-12 mb-3">
                            <div class="card border-0 shadow-sm rounded-4 p-2 bg-white">
                                <div class="nav nav-pills nav-fill gap-2" role="tablist">
                                    <a href="${pageContext.request.contextPath}/admin/clinic-config?tab=intro&subtab=services" 
                                       class="nav-link rounded-pill py-2 fw-semibold ${currentSubtab == 'services' ? 'active bg-primary text-white shadow-sm' : 'text-secondary'}">
                                        <i class="bi bi-heart-pulse me-2"></i>1. Hình ảnh Dịch vụ phòng khám (${fn:length(catalogServices)} dịch vụ ngoài Home)
                                    </a>
                                    <a href="${pageContext.request.contextPath}/admin/clinic-config?tab=intro&subtab=banners" 
                                       class="nav-link rounded-pill py-2 fw-semibold ${currentSubtab == 'banners' ? 'active bg-primary text-white shadow-sm' : 'text-secondary'}">
                                        <i class="bi bi-aspect-ratio me-2"></i>2. Banner Hero & Về chúng tôi (About)
                                    </a>
                                </div>
                            </div>
                        </div>

                        <!-- ================= SECTION 1: SERVICES IMAGES ================= -->
                        <c:if test="${currentSubtab == 'services'}">
                            <div class="col-12">
                                <div class="admin-card">
                                    <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                                        <div>
                                            <h5 class="mb-1 fw-bold"><i class="bi bi-heart-pulse me-2 text-primary"></i>Hình ảnh Dịch vụ Phòng Khám</h5>
                                            <p class="text-muted small mb-0">Các hình ảnh dưới đây hiển thị trực tiếp tại mục <strong>Dịch vụ phòng khám</strong> và <strong>Chuyên khoa</strong> ngoài trang chủ. Khi bạn cập nhật ảnh tại đây, ảnh ngoài trang chủ sẽ lập tức thay đổi!</p>
                                        </div>
                                    </div>

                                    <div class="row g-4">
                                        <c:forEach var="svc" items="${catalogServices}">
                                            <div class="col-sm-6 col-lg-4 col-xl-3">
                                                <div class="card h-100 border rounded-3 overflow-hidden shadow-sm d-flex flex-column gallery-card">
                                                    <div class="position-relative" style="height: 180px; background-color: #f1f5f9; overflow: hidden;">
                                                        <c:choose>
                                                            <c:when test="${svc.uploadedImage}">
                                                                <img id="svcCardImg${svc.id}"
                                                                     src="${pageContext.request.contextPath}/catalog-image?kind=service&amp;id=${svc.id}"
                                                                     alt="${fn:escapeXml(svc.name)}" class="w-100 h-100 object-fit-cover"
                                                                     onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/img/${svc.defaultImagePath}';">
                                                            </c:when>
                                                            <c:otherwise>
                                                                <img id="svcCardImg${svc.id}"
                                                                     src="${pageContext.request.contextPath}/assets/img/${svc.defaultImagePath}"
                                                                     alt="${fn:escapeXml(svc.name)}" class="w-100 h-100 object-fit-cover">
                                                            </c:otherwise>
                                                        </c:choose>

                                                        <span class="position-absolute top-0 start-0 m-2 badge ${svc.uploadedImage ? 'bg-success' : 'bg-secondary'} shadow-sm">
                                                            <i class="bi ${svc.uploadedImage ? 'bi-check-circle' : 'bi-image'} me-1"></i>
                                                            ${svc.uploadedImage ? 'Ảnh tải lên' : 'Ảnh mặc định'}
                                                        </span>
                                                        <span class="position-absolute bottom-0 end-0 m-2 badge bg-dark bg-opacity-75 shadow-sm">
                                                            ${svc.code}
                                                        </span>
                                                    </div>
                                                    <div class="card-body p-3 d-flex flex-column justify-content-between flex-grow-1">
                                                        <div>
                                                            <span class="badge bg-light text-secondary border small mb-1">${svc.category}</span>
                                                            <h6 class="fw-bold mb-1 text-truncate" title="${fn:escapeXml(svc.name)}">${svc.name}</h6>
                                                            <p class="text-muted small mb-2" style="display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; min-height: 36px;">
                                                                ${empty svc.summary ? 'Dịch vụ nhãn khoa chuyên sâu tại phòng khám VisionCare.' : svc.summary}
                                                            </p>
                                                        </div>
                                                        <div class="pt-2 border-top d-flex gap-2">
                                                            <button type="button" class="btn btn-sm btn-outline-primary flex-grow-1"
                                                                    data-bs-toggle="modal" data-bs-target="#editServiceModal${svc.id}">
                                                                <i class="bi bi-camera me-1"></i> Đổi ảnh
                                                            </button>
                                                            <c:if test="${svc.uploadedImage}">
                                                                <button type="button" class="btn btn-sm btn-outline-warning" data-bs-toggle="modal"
                                                                        data-bs-target="#resetServiceModal${svc.id}" title="Khôi phục ảnh gốc mặc định">
                                                                    <i class="bi bi-arrow-counterclockwise"></i>
                                                                </button>
                                                            </c:if>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Edit Service Image Modal -->
                                            <div class="modal fade" id="editServiceModal${svc.id}" tabindex="-1" aria-hidden="true">
                                                <div class="modal-dialog modal-dialog-centered">
                                                    <div class="modal-content border-0 shadow">
                                                        <form action="${pageContext.request.contextPath}/admin/clinic-intro-config" method="post" enctype="multipart/form-data">
                                                            <input type="hidden" name="action" value="update_service_image">
                                                            <input type="hidden" name="serviceId" value="${svc.id}">
                                                            <div class="modal-header border-0 pb-0">
                                                                <h5 class="modal-title fw-bold text-primary"><i class="bi bi-camera me-2"></i>Đổi ảnh Dịch vụ: ${svc.code}</h5>
                                                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                            </div>
                                                            <div class="modal-body p-4">
                                                                <p class="fw-semibold text-dark mb-2">${svc.name}</p>
                                                                <div class="mb-3 text-center">
                                                                    <label class="form-label d-block text-start small fw-semibold text-secondary">Ảnh hiện tại:</label>
                                                                    <c:choose>
                                                                        <c:when test="${svc.uploadedImage}">
                                                                            <img id="previewSvcImg${svc.id}"
                                                                                 src="${pageContext.request.contextPath}/catalog-image?kind=service&amp;id=${svc.id}"
                                                                                 alt="${fn:escapeXml(svc.name)}" class="img-thumbnail rounded shadow-sm w-100"
                                                                                 style="max-height: 200px; object-fit: cover;">
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <img id="previewSvcImg${svc.id}"
                                                                                 src="${pageContext.request.contextPath}/assets/img/${svc.defaultImagePath}"
                                                                                 alt="${fn:escapeXml(svc.name)}" class="img-thumbnail rounded shadow-sm w-100"
                                                                                 style="max-height: 200px; object-fit: cover;">
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </div>
                                                                <div class="mb-3">
                                                                    <label class="form-label fw-semibold">Chọn file ảnh mới <span class="text-danger">*</span></label>
                                                                    <input type="file" name="imageFile" class="form-control" accept="image/*" required
                                                                           onchange="previewGalleryImage(this, 'previewSvcImg${svc.id}')">
                                                                    <div class="form-text small text-muted">Hỗ trợ JPG, PNG, WEBP (tối đa 10MB). Ảnh sẽ lập tức thay đổi ngoài trang chủ.</div>
                                                                </div>
                                                            </div>
                                                            <div class="modal-footer border-0 pt-0">
                                                                <button type="button" class="btn btn-secondary px-4 rounded-pill" data-bs-dismiss="modal">Hủy</button>
                                                                <button type="submit" class="btn btn-primary px-4 rounded-pill"><i class="bi bi-cloud-upload me-1"></i> Lưu ảnh mới</button>
                                                            </div>
                                                        </form>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Reset Service Image Modal -->
                                            <c:if test="${svc.uploadedImage}">
                                                <div class="modal fade" id="resetServiceModal${svc.id}" tabindex="-1" aria-hidden="true">
                                                    <div class="modal-dialog modal-dialog-centered">
                                                        <div class="modal-content border-0 shadow">
                                                            <form action="${pageContext.request.contextPath}/admin/clinic-intro-config" method="post">
                                                                <input type="hidden" name="action" value="reset_service_image">
                                                                <input type="hidden" name="serviceId" value="${svc.id}">
                                                                <div class="modal-header border-0 pb-0">
                                                                    <h5 class="modal-title fw-bold text-warning"><i class="bi bi-arrow-counterclockwise me-2"></i>Khôi phục ảnh gốc</h5>
                                                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                                </div>
                                                                <div class="modal-body p-4 text-center">
                                                                    <p class="mb-2">Bạn có chắc muốn đặt lại hình ảnh cho dịch vụ <strong>${svc.name}</strong> về ảnh mặc định ban đầu?</p>
                                                                    <p class="text-muted small mb-0">Hệ thống sẽ xóa ảnh đã tải lên và khôi phục hiển thị file gốc (${svc.defaultImagePath}).</p>
                                                                </div>
                                                                <div class="modal-footer border-0 justify-content-center pt-0">
                                                                    <button type="button" class="btn btn-secondary px-4 rounded-pill" data-bs-dismiss="modal">Hủy</button>
                                                                    <button type="submit" class="btn btn-warning px-4 rounded-pill text-white">Xác nhận đặt lại</button>
                                                                </div>
                                                            </form>
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:if>
                                        </c:forEach>
                                    </div>
                                </div>
                            </div>
                        </c:if>

                        <!-- ================= SECTION 2: BANNERS & ABOUT ================= -->
                        <c:if test="${currentSubtab == 'banners'}">
                            <div class="col-12">
                                <div class="admin-card">
                                    <div class="mb-3">
                                        <h5 class="mb-1 fw-bold"><i class="bi bi-aspect-ratio me-2 text-primary"></i>Hình ảnh Banner & Về chúng tôi (About)</h5>
                                        <p class="text-muted small mb-0">Thay đổi hình ảnh nền lớn đầu trang chủ (Hero Banner) và ảnh minh họa phần "Về VisionCare" (About Us).</p>
                                    </div>

                                    <div class="row g-4">
                                        <c:forEach var="banner" items="${clinicBanners}">
                                            <div class="col-md-6">
                                                <div class="card h-100 border rounded-3 overflow-hidden shadow-sm d-flex flex-column gallery-card">
                                                    <div class="position-relative" style="height: 240px; background-color: #f1f5f9; overflow: hidden;">
                                                        <img id="bannerCardImg${banner.key}"
                                                             src="${pageContext.request.contextPath}/clinic-banner-image?key=${banner.key}&amp;t=${not empty banner.updatedAt ? banner.updatedAt : '0'}"
                                                             alt="${banner.title}" class="w-100 h-100 object-fit-cover"
                                                             onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/img/${banner.defaultFilename}';">

                                                        <span class="position-absolute top-0 start-0 m-3 badge ${banner.hasCustomImage ? 'bg-success' : 'bg-secondary'} shadow-sm">
                                                            <i class="bi ${banner.hasCustomImage ? 'bi-check-circle' : 'bi-image'} me-1"></i>
                                                            ${banner.hasCustomImage ? 'Đã tải ảnh riêng' : 'Ảnh gốc mặc định'}
                                                        </span>
                                                    </div>
                                                    <div class="card-body p-4 d-flex flex-column justify-content-between flex-grow-1">
                                                        <div>
                                                            <h5 class="fw-bold text-dark mb-1">${banner.title}</h5>
                                                            <p class="text-muted small mb-3">
                                                                <c:choose>
                                                                    <c:when test="${banner.key == 'HERO_BANNER'}">
                                                                        Hình nền lớn hiển thị toàn màn hình tại khu vực chào mừng đầu trang chủ. Tỉ lệ khuyến nghị 16:9 hoặc độ phân giải 1920x800px.
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        Hình ảnh nổi bật hiển thị tại phần giới thiệu "Về VisionCare" trên trang chủ. Tỉ lệ khuyến nghị 4:3 hoặc 600x500px.
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </p>
                                                        </div>
                                                        <div class="pt-3 border-top d-flex gap-2">
                                                            <button type="button" class="btn btn-primary rounded-pill px-4 flex-grow-1"
                                                                    data-bs-toggle="modal" data-bs-target="#editBannerModal${banner.key}">
                                                                <i class="bi bi-camera me-1"></i> Thay đổi ảnh này
                                                            </button>
                                                            <c:if test="${banner.hasCustomImage}">
                                                                <button type="button" class="btn btn-outline-warning rounded-pill px-3" data-bs-toggle="modal"
                                                                        data-bs-target="#resetBannerModal${banner.key}" title="Khôi phục ảnh gốc">
                                                                    <i class="bi bi-arrow-counterclockwise me-1"></i> Mặc định
                                                                </button>
                                                            </c:if>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Edit Banner Modal -->
                                            <div class="modal fade" id="editBannerModal${banner.key}" tabindex="-1" aria-hidden="true">
                                                <div class="modal-dialog modal-dialog-centered">
                                                    <div class="modal-content border-0 shadow">
                                                        <form action="${pageContext.request.contextPath}/admin/clinic-intro-config" method="post" enctype="multipart/form-data">
                                                            <input type="hidden" name="action" value="update_banner">
                                                            <input type="hidden" name="bannerKey" value="${banner.key}">
                                                            <div class="modal-header border-0 pb-0">
                                                                <h5 class="modal-title fw-bold text-primary"><i class="bi bi-camera me-2"></i>Thay đổi ${banner.title}</h5>
                                                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                            </div>
                                                            <div class="modal-body p-4">
                                                                <div class="mb-3 text-center">
                                                                    <label class="form-label d-block text-start small fw-semibold text-secondary">Ảnh hiện tại:</label>
                                                                    <img id="previewBannerImg${banner.key}"
                                                                         src="${pageContext.request.contextPath}/clinic-banner-image?key=${banner.key}&amp;t=${not empty banner.updatedAt ? banner.updatedAt : '0'}"
                                                                         alt="${banner.title}" class="img-thumbnail rounded shadow-sm w-100"
                                                                         style="max-height: 220px; object-fit: cover;">
                                                                </div>
                                                                <div class="mb-3">
                                                                    <label class="form-label fw-semibold">Chọn file ảnh mới <span class="text-danger">*</span></label>
                                                                    <input type="file" name="imageFile" class="form-control" accept="image/*" required
                                                                           onchange="previewGalleryImage(this, 'previewBannerImg${banner.key}')">
                                                                    <div class="form-text small text-muted">Hỗ trợ JPG, PNG, WEBP (tối đa 10MB). Ảnh mới sẽ áp dụng ngay lên trang chủ.</div>
                                                                </div>
                                                            </div>
                                                            <div class="modal-footer border-0 pt-0">
                                                                <button type="button" class="btn btn-secondary px-4 rounded-pill" data-bs-dismiss="modal">Hủy</button>
                                                                <button type="submit" class="btn btn-primary px-4 rounded-pill"><i class="bi bi-cloud-upload me-1"></i> Lưu và Áp dụng</button>
                                                            </div>
                                                        </form>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Reset Banner Modal -->
                                            <c:if test="${banner.hasCustomImage}">
                                                <div class="modal fade" id="resetBannerModal${banner.key}" tabindex="-1" aria-hidden="true">
                                                    <div class="modal-dialog modal-dialog-centered">
                                                        <div class="modal-content border-0 shadow">
                                                            <form action="${pageContext.request.contextPath}/admin/clinic-intro-config" method="post">
                                                                <input type="hidden" name="action" value="reset_banner">
                                                                <input type="hidden" name="bannerKey" value="${banner.key}">
                                                                <div class="modal-header border-0 pb-0">
                                                                    <h5 class="modal-title fw-bold text-warning"><i class="bi bi-arrow-counterclockwise me-2"></i>Khôi phục ảnh gốc</h5>
                                                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                                </div>
                                                                <div class="modal-body p-4 text-center">
                                                                    <p class="mb-2">Bạn có chắc muốn đặt lại <strong>${banner.title}</strong> về ảnh mặc định ban đầu?</p>
                                                                    <p class="text-muted small mb-0">Hệ thống sẽ xóa ảnh tùy chỉnh và khôi phục file gốc (${banner.defaultFilename}).</p>
                                                                </div>
                                                                <div class="modal-footer border-0 justify-content-center pt-0">
                                                                    <button type="button" class="btn btn-secondary px-4 rounded-pill" data-bs-dismiss="modal">Hủy</button>
                                                                    <button type="submit" class="btn btn-warning px-4 rounded-pill text-white">Xác nhận đặt lại</button>
                                                                </div>
                                                            </form>
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:if>
                                        </c:forEach>
                                    </div>
                                </div>
                            </div>
                        </c:if>

                    </c:if>
                </div>

                <!-- Add Room Modal -->
                <div class="modal fade" id="addRoomModal" tabindex="-1">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <form action="${pageContext.request.contextPath}/admin/room-config" method="post">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="tab" value="rooms">
                                <div class="modal-header border-0 pb-0">
                                    <h5 class="modal-title fw-bold text-primary">Thêm Phòng Khám Mới</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                </div>
                                <div class="modal-body p-4">
                                    <div class="mb-3">
                                        <label class="form-label fw-semibold">Tên phòng</label>
                                        <input type="text" name="roomName" class="form-control" required placeholder="VD: Phòng Khám 102"
                                               oninput="checkRoomTypeForAdd(this)">
                                    </div>
                                    <div id="docDivAdd" class="mb-3" style="display: block;">
                                        <label class="form-label fw-semibold">Người phụ trách - Bác sĩ (Tùy chọn)</label>
                                        <select name="doctorId" class="form-select">
                                            <option value="">-- Bỏ qua / Sắp xếp sau --</option>
                                            <c:forEach var="doctor" items="${doctors}">
                                                <c:if test="${doctor.roomId == 0 || empty doctor.roomId}">
                                                    <option value="${doctor.id}">${doctor.name} - ${doctor.specialty}</option>
                                                </c:if>
                                            </c:forEach>
                                        </select>
                                        <div class="form-text text-muted small">Chỉ phòng khám mắt mới chọn được Bác sĩ.</div>
                                    </div>
                                    <div id="specDivAdd" class="mb-3" style="display: none;">
                                        <label class="form-label fw-semibold">Người phụ trách - Chuyên viên y tế (Tùy chọn)</label>
                                        <select name="specialistId" class="form-select">
                                            <option value="">-- Bỏ qua / Sắp xếp sau --</option>
                                            <c:forEach var="specialist" items="${specialists}">
                                                <c:if test="${specialist.roomId == 0 || empty specialist.roomId}">
                                                    <option value="${specialist.id}">${specialist.name} - ${specialist.specialty}</option>
                                                </c:if>
                                            </c:forEach>
                                        </select>
                                        <div class="form-text text-muted small">Chỉ phòng tiểu phẫu/phẫu thuật mới chọn được Chuyên viên
                                            y tế.</div>
                                    </div>
                                </div>
                                <div class="modal-footer border-0 pt-0">
                                    <button type="button" class="btn btn-secondary px-4 rounded-pill"
                                            data-bs-dismiss="modal">Hủy</button>
                                    <button type="submit" class="btn btn-primary px-4 rounded-pill">Thêm phòng</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Add Time Slot Modal -->
                <div class="modal fade" id="addSlotModal" tabindex="-1">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <form action="${pageContext.request.contextPath}/admin/timeslot-config" method="post">
                                <input type="hidden" name="action" value="add">
                                <div class="modal-header border-0 pb-0">
                                    <h5 class="modal-title fw-bold text-primary">Thêm Khung Giờ Khám Mới</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                </div>
                                <div class="modal-body p-4">
                                    <div class="mb-3">
                                        <label class="form-label fw-semibold">Tên ca (Slot Name)</label>
                                        <input type="text" name="slotName" class="form-control" required placeholder="VD: Slot 5">
                                    </div>
                                    <div class="row mb-3">
                                        <div class="col-6">
                                            <label class="form-label fw-semibold">Giờ bắt đầu</label>
                                            <input type="time" name="startTime" class="form-control" required>
                                        </div>
                                        <div class="col-6">
                                            <label class="form-label fw-semibold">Giờ kết thúc</label>
                                            <input type="time" name="endTime" class="form-control" required>
                                        </div>
                                    </div>
                                </div>
                                <div class="modal-footer border-0 pt-0">
                                    <button type="button" class="btn btn-secondary px-4 rounded-pill"
                                            data-bs-dismiss="modal">Hủy</button>
                                    <button type="submit" class="btn btn-primary px-4 rounded-pill">Thêm khung giờ</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Reset Standard Slots Modal -->
                <div class="modal fade" id="resetStandardSlotsModal" tabindex="-1">
                    <div class="modal-dialog modal-dialog-centered">
                        <div class="modal-content border-0 shadow">
                            <form action="${pageContext.request.contextPath}/admin/timeslot-config" method="post">
                                <input type="hidden" name="action" value="reset_standard">
                                <div class="modal-header border-0 pb-0">
                                    <h5 class="modal-title fw-bold" style="color: #78350f;"><i class="bi bi-arrow-repeat me-2" style="color: #d97706;"></i>Đặt Lại Khung Giờ Chuẩn Cân Bằng</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                </div>
                                <div class="modal-body p-4">
                                    <p class="mb-3 text-dark">Hệ thống sẽ đồng bộ và cân bằng lại <strong>14 khung giờ khám tiêu chuẩn</strong>:</p>
                                    <div class="p-3 bg-light rounded-3 small mb-3 border">
                                        <div class="mb-2"><strong style="color: #92400e;"><i class="bi bi-sunrise me-1" style="color: #d97706;"></i>Ca Sáng (7 ca):</strong> 08:00 — 11:30 (Ca 1 đến Ca 7, mỗi ca 30 phút)</div>
                                        <div class="mb-2"><strong class="text-info"><i class="bi bi-cup-hot me-1"></i>Giờ Nghỉ Trưa:</strong> 11:30 — 13:30 (2.0 giờ ăn trưa & nghỉ ngơi)</div>
                                        <div><strong class="text-primary"><i class="bi bi-sun me-1"></i>Ca Chiều (7 ca):</strong> 13:30 — 17:00 (Ca 8 đến Ca 14, mỗi ca 30 phút)</div>
                                    </div>
                                    <div class="small text-muted"><i class="bi bi-info-circle me-1 text-primary"></i>Ca lệch 13:00 - 13:30 sẽ tự động tắt để đảm bảo cả hai ca sáng và chiều đều cân bằng đúng 7 ca/buổi.</div>
                                </div>
                                <div class="modal-footer border-0 justify-content-center pt-0">
                                    <button type="button" class="btn btn-secondary px-4 rounded-pill" data-bs-dismiss="modal">Hủy</button>
                                    <button type="submit" class="btn px-4 rounded-pill text-white fw-bold shadow-sm" style="background: #d97706; border-color: #d97706;">Xác nhận đặt lại</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

            </div>
        </main>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
                                          function checkRoomTypeForEdit(inputElement, roomId) {
                                              const val = inputElement.value.toLowerCase();
                                              const isSurgery = val.includes('tiểu phẫu') || val.includes('phẫu thuật') || val.includes('điều trị');
                                              if (isSurgery) {
                                                  document.getElementById('docDivEdit' + roomId).style.display = 'none';
                                                  document.getElementById('docDivEdit' + roomId).querySelector('select').value = '';
                                                  document.getElementById('specDivEdit' + roomId).style.display = 'block';
                                              } else {
                                                  document.getElementById('specDivEdit' + roomId).style.display = 'none';
                                                  document.getElementById('specDivEdit' + roomId).querySelector('select').value = '';
                                                  document.getElementById('docDivEdit' + roomId).style.display = 'block';
                                              }
                                          }

                                          function checkRoomTypeForAdd(inputElement) {
                                              const val = inputElement.value.toLowerCase();
                                              const isSurgery = val.includes('tiểu phẫu') || val.includes('phẫu thuật') || val.includes('điều trị');
                                              if (isSurgery) {
                                                  document.getElementById('docDivAdd').style.display = 'none';
                                                  document.getElementById('docDivAdd').querySelector('select').value = '';
                                                  document.getElementById('specDivAdd').style.display = 'block';
                                              } else {
                                                  document.getElementById('specDivAdd').style.display = 'none';
                                                  document.getElementById('specDivAdd').querySelector('select').value = '';
                                                  document.getElementById('docDivAdd').style.display = 'block';
                                              }
                                          }

                                          function previewGalleryImage(input, imgId) {
                                              if (input.files && input.files[0]) {
                                                  const reader = new FileReader();
                                                  reader.onload = function (e) {
                                                      const target = document.getElementById(imgId);
                                                      if (target) {
                                                          target.src = e.target.result;
                                                      }
                                                  };
                                                  reader.readAsDataURL(input.files[0]);
                                              }
                                          }
        </script>
    </body>

</html>
