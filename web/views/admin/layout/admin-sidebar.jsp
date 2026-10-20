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
    .sidebar-dropdown {
        position: relative;
    }
    .sidebar-dropdown > a {
        display: flex !important;
        align-items: center !important;
        justify-content: space-between !important;
        cursor: pointer !important;
        user-select: none !important;
    }
    .sidebar-dropdown .sidebar-submenu {
        display: none !important;
        list-style: none !important;
        padding: 4px 0 6px 12px !important;
        margin: 0 !important;
    }
    /* Strictly forbid opening on hover under any circumstances */
    .sidebar-dropdown:hover .sidebar-submenu {
        display: none !important;
    }
    .sidebar-dropdown:hover .sidebar-submenu:not(.show) {
        display: none !important;
    }
    .sidebar-dropdown .sidebar-submenu.show,
    .sidebar-dropdown:hover .sidebar-submenu.show {
        display: block !important;
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

<!-- Sidebar -->
<aside class="sidebar">
    <a href="${pageContext.request.contextPath}/home" class="sidebar-brand">
        <span class="logo-mark"><i class="bi bi-eye"></i></span>
        <span class="brand-text">VisionCare</span>
    </a>

    <ul class="sidebar-menu">
        <c:choose>
            <%-- ==================== GIAO DIỆN DÀNH CHO STAFF ==================== --%>
            <c:when test="${sessionScope.user.role == 'staff'}">
                <div class="sidebar-menu-header">Bàn làm việc Nhân viên</div>

                <!-- 1. Màn hình đặt lịch hiện đang có -->
                <li>
                    <a href="${pageContext.request.contextPath}/employee/schedule" class="${param.activeNav == 'schedule' ? 'active' : ''}">
                        <i class="bi bi-calendar3"></i>
                        <span>Đặt lịch hẹn</span>
                    </a>
                </li>

                <!-- 2. Quản lý Lịch hẹn (Sổ xuống) -->
                <li class="sidebar-dropdown">
                    <a href="javascript:void(0);" onclick="toggleSubmenu('appt-sub', this); return false;" class="${param.activeNav == 'appointments' || param.activeNav == 'waiting-list' ? 'active' : ''}">
                        <div class="d-flex align-items-center gap-2">
                            <i class="bi bi-calendar2-check"></i>
                            <span>Quản lý Lịch hẹn</span>
                        </div>
                        <i class="bi ${param.activeNav == 'appointments' || param.activeNav == 'waiting-list' ? 'bi-chevron-up' : 'bi-chevron-down'}" style="font-size: 11px;"></i>
                    </a>
                    <ul class="sidebar-submenu ${param.activeNav == 'appointments' || param.activeNav == 'waiting-list' ? 'show' : ''}" id="appt-sub">
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

                <!-- 3. Quản lý yêu cầu hoàn tiền (Không cần sổ xuống vì chỉ có 1 nội dung) -->
                <li>
                    <a href="${pageContext.request.contextPath}/staff/refunds" class="${param.activeNav == 'refunds' ? 'active' : ''}">
                        <i class="bi bi-cash-coin"></i>
                        <span>Quản lý yêu cầu hoàn tiền</span>
                    </a>
                </li>
            </c:when>

            <%-- ==================== GIAO DIỆN DÀNH CHO ADMIN ==================== --%>
            <c:otherwise>
                <div class="sidebar-menu-header">Hệ thống Quản trị</div>

                <li>
                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="${param.activeNav == 'dashboard' ? 'active' : ''}">
                        <i class="bi bi-graph-up"></i>
                        Dashboard Doanh thu
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/admin/users" class="${param.activeNav == 'users' ? 'active' : ''}">
                        <i class="bi bi-people"></i>
                        Quản lý Người dùng
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/admin/clinic-config?tab=rooms" class="${param.activeNav == 'clinic-config' || param.activeNav == 'clinic-rooms' || param.activeNav == 'clinic-slots' ? 'active' : ''}">
                        <i class="bi bi-gear"></i>
                        Cấu hình Phòng Khám
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/admin/catalog" class="${param.activeNav == 'catalog' ? 'active' : ''}">
                        <i class="bi bi-box"></i>
                        Quản lý Danh mục
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/admin/medicine" class="${param.activeNav == 'retail' ? 'active' : ''}">
                        <i class="bi bi-bag-check"></i>
                        Quản lý Vật tư bán lẻ
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/admin/billing" class="${param.activeNav == 'billing' ? 'active' : ''}">
                        <i class="bi bi-receipt"></i>
                        Hóa đơn và Thanh toán
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/staff/refunds" class="${param.activeNav == 'refunds' ? 'active' : ''}">
                        <i class="bi bi-cash-coin"></i>
                        Quản lý Hoàn tiền
                    </a>
                </li>

                <div class="sidebar-menu-header mt-3">Nghiệp vụ Nhân viên</div>
                <li>
                    <a href="${pageContext.request.contextPath}/employee/schedule" class="${param.activeNav == 'schedule' ? 'active' : ''}">
                        <i class="bi bi-calendar3"></i>
                        <span>Đặt lịch hẹn</span>
                    </a>
                </li>
                <!-- 2. Quản lý Lịch hẹn (Sổ xuống) -->
                <li class="sidebar-dropdown">
                    <a href="javascript:void(0);" onclick="toggleSubmenu('appt-sub-admin-menu', this); return false;" class="${param.activeNav == 'appointments' || param.activeNav == 'waiting-list' ? 'active' : ''}">
                        <div class="d-flex align-items-center gap-2">
                            <i class="bi bi-calendar2-check"></i>
                            <span>Quản lý Lịch hẹn</span>
                        </div>
                        <i class="bi ${param.activeNav == 'appointments' || param.activeNav == 'waiting-list' ? 'bi-chevron-up' : 'bi-chevron-down'}" style="font-size: 11px;"></i>
                    </a>
                    <ul class="sidebar-submenu ${param.activeNav == 'appointments' || param.activeNav == 'waiting-list' ? 'show' : ''}" id="appt-sub-admin-menu">
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
