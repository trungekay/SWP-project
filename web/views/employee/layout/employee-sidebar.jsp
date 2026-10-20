<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<style>
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
        background-color: #fcfcfc !important;
        border-radius: 0 0 8px 8px !important;
    }
    /* Strictly forbid opening on hover under any circumstances */
    .sidebar-dropdown:hover .sidebar-submenu {
        display: none !important;
    }
    .sidebar-dropdown:hover .sidebar-submenu:not(.show) {
        display: none !important;
    }
    /* Only display when .show class is present */
    .sidebar-dropdown .sidebar-submenu.show,
    .sidebar-dropdown:hover .sidebar-submenu.show {
        display: block !important;
    }
    .sidebar-submenu li a {
        padding: 8px 16px !important;
        font-size: 13px !important;
        color: #64748b !important;
        border-radius: 6px !important;
        display: flex !important;
        align-items: center !important;
        gap: 8px !important;
        text-decoration: none !important;
        transition: all 0.2s !important;
    }
    .sidebar-submenu li a:hover,
    .sidebar-submenu li a.active {
        color: #008b74 !important;
        background-color: #f0f7f6 !important;
        font-weight: 600 !important;
    }
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
            <c:when test="${empty sessionScope.user || fn:toLowerCase(sessionScope.user.role) == 'staff' || sessionScope.user.roleId == 5 || (fn:toLowerCase(sessionScope.user.role) != 'doctor' && fn:toLowerCase(sessionScope.user.role) != 'medical_specialist' && fn:toLowerCase(sessionScope.user.role) != 'specialist' && sessionScope.user.roleId != 3 && sessionScope.user.roleId != 4 && (param.activeNav == 'appointments' || param.activeNav == 'waiting-list' || param.activeNav == 'refunds' || param.activeNav == 'procedure-payments'))}">
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
                    <a href="javascript:void(0);" onclick="toggleSubmenu('appt-sub-emp', this); return false;" class="${param.activeNav == 'appointments' || param.activeNav == 'waiting-list' ? 'active' : ''}">
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

                <!-- 4. Quản lý yêu cầu hoàn tiền -->
                <li>
                    <a href="${pageContext.request.contextPath}/staff/procedure-payments" class="${param.activeNav == 'procedure-payments' ? 'active' : ''}">
                        <i class="bi bi-credit-card"></i>
                        <span>Thanh toán phẫu thuật</span>
                    </a>
                </li>

                <!-- 4. Quản lý yêu cầu hoàn tiền -->
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
                <c:if test="${fn:toLowerCase(sessionScope.user.role) == 'admin' || sessionScope.user.roleId == 1 || sessionScope.user.roleId == 2}">
                    <div class="sidebar-menu-header mt-3">Tiếp đón & Lễ tân</div>
                    <li>
                        <a href="${pageContext.request.contextPath}/employee/schedule" class="${param.activeNav == 'schedule' ? 'active' : ''}">
                            <i class="bi bi-calendar3"></i>
                            <span>Đặt lịch hẹn</span>
                        </a>
                    </li>
                    <li class="sidebar-dropdown">
                        <a href="javascript:void(0);" onclick="toggleSubmenu('appt-sub-admin', this); return false;" class="${param.activeNav == 'appointments' || param.activeNav == 'waiting-list' ? 'active' : ''}">
                            <div class="d-flex align-items-center gap-2">
                                <i class="bi bi-calendar2-check"></i>
                                <span>Quản lý Lịch hẹn</span>
                            </div>
                            <i class="bi ${param.activeNav == 'appointments' || param.activeNav == 'waiting-list' ? 'bi-chevron-up' : 'bi-chevron-down'}" style="font-size: 11px;"></i>
                        </a>
                        <ul class="sidebar-submenu ${param.activeNav == 'appointments' || param.activeNav == 'waiting-list' ? 'show' : ''}" id="appt-sub-admin">
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
                        <a href="${pageContext.request.contextPath}/staff/procedure-payments" class="${param.activeNav == 'procedure-payments' ? 'active' : ''}">
                            <i class="bi bi-credit-card"></i>
                            <span>Thanh toán phẫu thuật</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/staff/refunds" class="${param.activeNav == 'refunds' ? 'active' : ''}">
                            <i class="bi bi-cash-coin"></i>
                            <span>Quản lý yêu cầu hoàn tiền</span>
                        </a>
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
