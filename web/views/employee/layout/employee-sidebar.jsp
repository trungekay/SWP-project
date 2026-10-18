<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<style>
    .sidebar, .sidebar * {
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif !important;
    }
    .sidebar-menu-header {
        font-size: 11px;
        text-transform: uppercase;
        letter-spacing: 0.8px;
        color: #94a3b8;
        padding: 12px 16px 4px;
        font-weight: 700;
    }
    .sidebar-dropdown > a {
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    .sidebar-submenu {
        display: none;
        list-style: none;
        padding: 4px 0 6px 12px;
        margin: 0;
    }
    .sidebar-submenu.show {
        display: block;
    }
    .sidebar-submenu li a {
        padding: 8px 16px !important;
        font-size: 13px !important;
        color: #64748b !important;
        border-radius: 6px !important;
        display: flex;
        align-items: center;
        gap: 8px;
        text-decoration: none;
        transition: all 0.2s;
    }
    .sidebar-submenu li a:hover,
    .sidebar-submenu li a.active {
        color: #008b74 !important;
        background-color: #f0f7f6 !important;
        font-weight: 600;
    }
</style>

<!-- Unified Employee & Staff Sidebar -->
<aside class="sidebar">
    <a href="${pageContext.request.contextPath}/home" class="sidebar-brand">
        <span class="logo-mark"><i class="bi bi-eye"></i></span>
        <span class="brand-text">VisionCare</span>
    </a>

    <ul class="sidebar-menu">
        <c:choose>
            <%-- ==================== GIAO DIỆN DÀNH CHO STAFF ==================== --%>
            <c:when test="${sessionScope.user.role == 'staff' || sessionScope.user.roleId == 5}">
                <div class="sidebar-menu-header">Bàn làm việc Nhân viên</div>

                <!-- 1. Màn hình đặt lịch -->
                <li>
                    <a href="${pageContext.request.contextPath}/employee/schedule" class="${param.activeNav == 'schedule' ? 'active' : ''}">
                        <i class="bi bi-calendar3"></i>
                        <span>Đặt lịch hẹn</span>
                    </a>
                </li>

                <!-- 2. Quản lý Lịch hẹn (Sổ xuống) -->
                <li class="sidebar-dropdown">
                    <a href="javascript:void(0);" onclick="toggleSubmenu('appt-sub-emp', this);" class="${param.activeNav == 'appointments' || param.activeNav == 'waiting-list' ? 'active' : ''}">
                        <div class="d-flex align-items-center gap-2">
                            <i class="bi bi-calendar2-check"></i>
                            <span>Quản lý Lịch hẹn</span>
                        </div>
                        <i class="bi ${param.activeNav == 'appointments' || param.activeNav == 'waiting-list' ? 'bi-chevron-up' : 'bi-chevron-down'}" style="font-size: 11px;"></i>
                    </a>
                    <ul class="sidebar-submenu ${param.activeNav == 'appointments' || param.activeNav == 'waiting-list' ? 'show' : ''}" id="appt-sub-emp">
                        <li>
                            <a href="${pageContext.request.contextPath}/staff/appointments" class="${param.activeNav == 'appointments' ? 'active' : ''}">
                                <i class="bi bi-list-task"></i>
                                <span>Xem danh sách lịch hẹn</span>
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/staff/waiting-list" class="${param.activeNav == 'waiting-list' ? 'active' : ''}">
                                <i class="bi bi-people"></i>
                                <span>Hàng đợi phòng khám</span>
                            </a>
                        </li>
                    </ul>
                </li>

                <!-- 3. Quản lý yêu cầu hoàn tiền -->
                <li>
                    <a href="${pageContext.request.contextPath}/staff/refunds" class="${param.activeNav == 'refunds' ? 'active' : ''}">
                        <i class="bi bi-cash-coin"></i>
                        <span>Quản lý yêu cầu hoàn tiền</span>
                    </a>
                </li>
            </c:when>

            <%-- ==================== GIAO DIỆN DÀNH CHO BÁC SĨ & CHUYÊN VIÊN ==================== --%>
            <c:otherwise>
                <li>
                    <a href="${pageContext.request.contextPath}/employee/schedule" class="${param.activeNav == 'schedule' ? 'active' : ''}">
                        <i class="bi bi-calendar-week"></i>
                        <span>Lịch làm việc của tôi</span>
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/employee/register-schedule" class="${param.activeNav == 'register-schedule' ? 'active' : ''}">
                        <i class="bi bi-calendar-plus"></i>
                        <span>Đăng ký ca làm việc</span>
                    </a>
                </li>

                <c:if test="${sessionScope.user.role == 'medical_specialist' || sessionScope.user.role == 'specialist' || sessionScope.user.roleId == 4 || sessionScope.user.roleId == 1 || sessionScope.user.roleId == 2}">
                    <li>
                        <a href="${pageContext.request.contextPath}/specialist/waiting-list" class="${param.activeNav == 'waiting-list' ? 'active' : ''}">
                            <i class="bi bi-clipboard2-pulse"></i>
                            <span>Hàng đợi cận lâm sàng</span>
                        </a>
                    </li>
                </c:if>

                <c:if test="${sessionScope.user.role == 'doctor'}">
                    <li>
                        <a href="javascript:void(0);" class="${param.activeNav == 'examination' ? 'active' : ''}" title="Chức năng đang phát triển" style="opacity: 0.85;">
                            <i class="bi bi-file-earmark-medical"></i>
                            <span>Khám bệnh & Bệnh án</span>
                        </a>
                    </li>
                </c:if>

                <%-- Fallback cho Admin xem trang Tiếp đón / Lễ tân --%>
                <c:if test="${(sessionScope.user.role == 'admin' || sessionScope.user.roleId == 1 || sessionScope.user.roleId == 2) && (param.activeNav == 'appointments' || param.activeNav == 'waiting-list')}">
                    <div class="sidebar-menu-header mt-3">Tiếp đón & Lễ tân</div>
                    <li class="sidebar-dropdown">
                        <a href="javascript:void(0);" onclick="toggleSubmenu('appt-sub-admin', this);" class="active">
                            <div class="d-flex align-items-center gap-2">
                                <i class="bi bi-calendar2-check"></i>
                                <span>Quản lý Lịch hẹn</span>
                            </div>
                            <i class="bi bi-chevron-up" style="font-size: 11px;"></i>
                        </a>
                        <ul class="sidebar-submenu show" id="appt-sub-admin">
                            <li>
                                <a href="${pageContext.request.contextPath}/staff/appointments" class="${param.activeNav == 'appointments' ? 'active' : ''}">
                                    <i class="bi bi-list-task"></i>
                                    <span>Xem danh sách lịch hẹn</span>
                                </a>
                            </li>
                            <li>
                                <a href="${pageContext.request.contextPath}/staff/waiting-list" class="${param.activeNav == 'waiting-list' ? 'active' : ''}">
                                    <i class="bi bi-people"></i>
                                    <span>Hàng đợi phòng khám</span>
                                </a>
                            </li>
                        </ul>
                    </li>
                </c:if>
            </c:otherwise>
        </c:choose>
    </ul>
</aside>
<script>
    window.toggleSubmenu = function(menuId, el) {
        var menu = document.getElementById(menuId);
        if (!menu && el) {
            var parent = el.closest('.sidebar-dropdown') || el.parentElement;
            if (parent) {
                menu = parent.querySelector('.sidebar-submenu');
            }
        }
        if (menu) {
            var isShown = menu.classList.contains('show') || menu.style.display === 'block';
            if (isShown) {
                menu.classList.remove('show');
                menu.style.display = 'none';
            } else {
                menu.classList.add('show');
                menu.style.display = 'block';
            }
            if (el) {
                var icon = el.querySelector('.bi-chevron-down, .bi-chevron-up');
                if (icon) {
                    if (menu.classList.contains('show') || menu.style.display === 'block') {
                        icon.classList.remove('bi-chevron-down');
                        icon.classList.add('bi-chevron-up');
                    } else {
                        icon.classList.remove('bi-chevron-up');
                        icon.classList.add('bi-chevron-down');
                    }
                }
            }
        }
    };
</script>
