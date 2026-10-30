<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<style>
.sidebar-submenu li a:hover:not(.active) {
    background-color: transparent !important;
    color: var(--text-muted, #64748b) !important;
    font-weight: normal !important;
}
#request-submenu { display: none; list-style: none; margin: 0; padding: 4px 0 6px 16px; }
#request-submenu.show { display: block; }
#request-submenu a { display: flex; align-items: center; gap: 8px; padding: 10px 12px; font-size: 13px; border-radius: 8px; text-decoration: none; color: #64748b; }
#request-submenu a.active { color: #008b74; background: #f0f7f6; font-weight: 600; }
#request-submenu a:hover:not(.active) { color: #64748b !important; background: transparent !important; font-weight: normal !important; }
.sidebar-dropdown:has(#request-submenu) > a { display: flex; justify-content: space-between; align-items: center; }
</style>
<!-- Employee Work Sidebar -->
<aside class="sidebar">
    <a href="${pageContext.request.contextPath}/employee/schedule" class="sidebar-brand">
        <span class="logo-mark"><i class="bi bi-eye"></i></span>
        <span class="brand-text">VisionCare</span>
    </a>
    <ul class="sidebar-menu">
        <c:choose>
            <%-- ==================== GIAO DIỆN DÀNH CHO STAFF / LỄ TÂN ==================== --%>
            <c:when test="${empty sessionScope.user || fn:toLowerCase(sessionScope.user.role) == 'staff' || sessionScope.user.roleId == 5 || (fn:toLowerCase(sessionScope.user.role) != 'doctor' && fn:toLowerCase(sessionScope.user.role) != 'medical_specialist' && fn:toLowerCase(sessionScope.user.role) != 'specialist' && sessionScope.user.roleId != 3 && sessionScope.user.roleId != 4 && (param.activeNav == 'appointments' || param.activeNav == 'waiting-list' || param.activeNav == 'payments' || param.activeNav == 'invoices'))}">
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

                <li><a href="${pageContext.request.contextPath}/staff/invoices" class="${param.activeNav == 'invoices' || param.activeNav == 'payments' ? 'active' : ''}"><i class="bi bi-receipt"></i><span>Quản lý hóa đơn &amp; thanh toán</span></a></li>

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

        <c:if test="${sessionScope.user.roleId == 3 or sessionScope.user.roleId == 4}">
            <li><a href="${pageContext.request.contextPath}/employee/leave-requests" class="${param.activeNav == 'leave-requests' ? 'active' : ''}"><i class="bi bi-calendar2-minus"></i><span>Xin nghỉ / Lịch sử yêu cầu</span></a></li>
        </c:if>
                <c:if test="${fn:toLowerCase(sessionScope.user.role) == 'medical_specialist' || fn:toLowerCase(sessionScope.user.role) == 'specialist' || sessionScope.user.roleId == 4 || sessionScope.user.roleId == 1 || sessionScope.user.roleId == 2}">
                    <li>
                        <a href="${pageContext.request.contextPath}/specialist/waiting-list" class="${param.activeNav == 'waiting-list' || param.activeNav == 'specialist-waiting-list' ? 'active' : ''}">
                            <i class="bi bi-clipboard2-pulse"></i>
                            <span>Hàng đợi cận lâm sàng</span>
                        </a>
                    </li>
                </c:if>

                <c:if test="${fn:toLowerCase(sessionScope.user.role) == 'doctor' || sessionScope.user.roleId == 3}">
                    <li>
                        <a href="${pageContext.request.contextPath}/doctor/waiting-list" class="${param.activeNav == 'examination' || param.activeNav == 'doctor-waiting' ? 'active' : ''}">
                            <i class="bi bi-file-earmark-medical"></i>
                            <span>Hàng đợi khám bệnh</span>
                        </a>
                    </li>
                </c:if>

                <%-- Fallback cho Admin xem trang Tiếp đón / Lễ tân --%>
                <c:if test="${(fn:toLowerCase(sessionScope.user.role) == 'admin' || sessionScope.user.roleId == 1 || sessionScope.user.roleId == 2) && (param.activeNav == 'appointments' || param.activeNav == 'waiting-list' || param.activeNav == 'payments' || param.activeNav == 'invoices')}">
                    <div class="sidebar-menu-header mt-3">Tiếp đón & Lễ tân</div>
                    <li>
                        <a href="${pageContext.request.contextPath}/employee/schedule" class="${param.activeNav == 'schedule' ? 'active' : ''}">
                            <i class="bi bi-calendar3"></i>
                            <span>Đặt lịch hẹn</span>
                        </a>
                    </li>
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
                    <li>
                        <a href="${pageContext.request.contextPath}/staff/invoices" class="${param.activeNav == 'payments' ? 'active' : ''}">
                            <i class="bi bi-credit-card"></i>
                            <span>Quản lý hóa đơn &amp; thanh toán</span>
                        </a>
                    </li>
                </c:if>
            </c:otherwise>
        </c:choose>
<c:if test="${sessionScope.user.roleId == 2}">
<li class="sidebar-dropdown">
<a href="javascript:void(0);" onclick="toggleSubmenu('request-submenu', this);" class="${param.activeNav == 'refunds' ? 'active' : ''}"><div class="d-flex align-items-center gap-2"><i class="bi bi-inbox"></i><span>Quản lý yêu cầu</span></div><i class="bi bi-chevron-down"></i></a>
<ul id="request-submenu" class="sidebar-submenu ${param.activeNav == 'refunds' ? 'show' : ''}">
<li><a href="${pageContext.request.contextPath}/director/refunds" class="${param.activeNav == 'refunds' ? 'active' : ''}"><i class="bi bi-cash-coin"></i><span>Quản lý yêu cầu hoàn tiền</span></a></li>
</ul></li></c:if>
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
