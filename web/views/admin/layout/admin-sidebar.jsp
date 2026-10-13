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

                <!-- 2. Quản lý Lịch hẹn (Sổ xuống gồm 2 nội dung) -->
                <li class="sidebar-dropdown">
                    <a href="javascript:void(0);" onclick="toggleSubmenu('appt-sub', this);" class="${param.activeNav == 'appointments' || param.activeNav == 'checkin' ? 'active' : ''}">
                        <div class="d-flex align-items-center gap-2">
                            <i class="bi bi-calendar2-check"></i>
                            <span>Quản lý Lịch hẹn</span>
                        </div>
                        <i class="bi ${param.activeNav == 'appointments' || param.activeNav == 'checkin' ? 'bi-chevron-up' : 'bi-chevron-down'}" style="font-size: 11px;"></i>
                    </a>
                    <ul class="sidebar-submenu ${param.activeNav == 'appointments' || param.activeNav == 'checkin' ? 'show' : ''}" id="appt-sub">
                        <li>
                            <a href="${pageContext.request.contextPath}/staff/appointments" class="${param.activeNav == 'appointments' ? 'active' : ''}">
                                <i class="bi bi-list-task"></i>
                                <span>Xem danh sách lịch hẹn</span>
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/staff/check-in" class="${param.activeNav == 'checkin' ? 'active' : ''}">
                                <i class="bi bi-person-check"></i>
                                <span>Check-in Bệnh nhân</span>
                            </a>
                        </li>
                    </ul>
                </li>

                <!-- 3. Quản lý Bệnh nhân (Không cần sổ xuống vì chỉ có 1 nội dung) -->
                <li>
                    <a href="${pageContext.request.contextPath}/staff/patients" class="${param.activeNav == 'staff-patients' || param.activeNav == 'patients' ? 'active' : ''}">
                        <i class="bi bi-people"></i>
                        <span>Danh sách bệnh nhân</span>
                    </a>
                </li>

                <!-- 4. Quản lý yêu cầu hoàn tiền (Không cần sổ xuống vì chỉ có 1 nội dung) -->
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
                <li class="sidebar-dropdown">
                    <a href="javascript:void(0);" onclick="toggleSubmenu('user-submenu', this);" class="${param.activeNav == 'users' ? 'active' : ''}">
                        <div class="d-flex align-items-center gap-2">
                            <i class="bi bi-person"></i>
                            <span>Quản lý Người dùng</span>
                        </div>
                        <i class="bi ${param.activeNav == 'users' ? 'bi-chevron-up' : 'bi-chevron-down'}" style="font-size: 11px;"></i>
                    </a>
                    <ul class="sidebar-submenu ${param.activeNav == 'users' ? 'show' : ''}" id="user-submenu">
                        <li><a href="${pageContext.request.contextPath}/admin/users?type=staff" class="${param.type == 'staff' || empty param.type ? 'active' : ''}"><i class="bi bi-person-badge"></i> Danh sách nội bộ</a></li>
                        <li><a href="${pageContext.request.contextPath}/admin/users?type=patient" class="${param.type == 'patient' ? 'active' : ''}"><i class="bi bi-people"></i> Danh sách khách hàng</a></li>
                    </ul>
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
                    <a href="${pageContext.request.contextPath}/admin/doctors" class="${param.activeNav == 'doctors' ? 'active' : ''}">
                        <i class="bi bi-person-badge"></i>
                        Quản lý Bác sĩ
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/admin/patients" class="${param.activeNav == 'patients' ? 'active' : ''}">
                        <i class="bi bi-people"></i>
                        Quản lý Bệnh nhân
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
                        Lịch làm việc (Staff)
                    </a>
                </li>
            </c:otherwise>
        </c:choose>
    </ul>
</aside>

<script>
    function toggleSubmenu(menuId, el) {
        var menu = document.getElementById(menuId);
        if (menu) {
            menu.classList.toggle('show');
            var icon = el.querySelector('.bi-chevron-down, .bi-chevron-up');
            if (icon) {
                if (menu.classList.contains('show')) {
                    icon.classList.remove('bi-chevron-down');
                    icon.classList.add('bi-chevron-up');
                } else {
                    icon.classList.remove('bi-chevron-up');
                    icon.classList.add('bi-chevron-down');
                }
            }
        }
    }
</script>
