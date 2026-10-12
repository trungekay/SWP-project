<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<style>
    .sidebar-menu .catalog-submenu { padding-left: 16px; }
    .sidebar-menu .catalog-submenu li a.catalog-subnav-link {
        padding-left: 12px;
        padding-right: 8px;
        font-size: 13px;
        white-space: nowrap;
    }
    .sidebar-menu .catalog-submenu li a.catalog-subnav-link i {
        flex-shrink: 0;
        margin-right: 8px !important;
    }
</style>
    <!-- Sidebar -->
    <aside class="sidebar">
        <a href="#" class="sidebar-brand">
            <span class="logo-mark"><i class="bi bi-eye"></i></span>
            <span class="brand-text">VisionCare</span>
        </a>
        <ul class="sidebar-menu">
            <li>
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="${param.activeNav == 'dashboard' ? 'active' : ''}">
                    <i class="bi bi-graph-up"></i>
                    Dashboard Doanh thu
                </a>
            </li>
            <li class="sidebar-dropdown">
                <a href="javascript:void(0);" onclick="document.getElementById('user-submenu').classList.toggle('show');" class="${param.activeNav == 'users' ? 'active' : ''}">
                    <i class="bi bi-person"></i>
                    Quản lý Người dùng
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
                <c:if test="${param.activeNav == 'clinic-config' || param.activeNav == 'clinic-rooms' || param.activeNav == 'clinic-slots'}">
                    <ul class="sidebar-submenu">
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/clinic-config?tab=rooms" class="${empty param.activeSub || param.activeSub == 'rooms' ? 'active-sub' : ''}">
                                <i class="bi bi-door-open me-2" style="font-size: 14px;"></i>Cấu hình phòng
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/clinic-config?tab=slots" class="${param.activeSub == 'slots' ? 'active-sub' : ''}">
                                <i class="bi bi-clock me-2" style="font-size: 14px;"></i>Cấu hình khung giờ khám
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/clinic-config?tab=rules" class="${param.activeSub == 'rules' ? 'active-sub' : ''}">
                                <i class="bi bi-sliders me-2" style="font-size: 14px;"></i>Quy định giờ làm việc
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/clinic-config?tab=intro" class="${param.activeSub == 'intro' ? 'active-sub' : ''}">
                                <i class="bi bi-images me-2" style="font-size: 14px;"></i>Cấu hình giới thiệu
                            </a>
                        </li>
                    </ul>
                </c:if>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/catalog?tab=services" class="${param.activeNav == 'catalog' ? 'active' : ''}">
                    <i class="bi bi-box"></i>
                    Quản lý Danh mục
                </a>
                <c:if test="${param.activeNav == 'catalog'}">
                    <ul class="sidebar-submenu catalog-submenu" aria-label="Danh mục">
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/catalog?tab=services" class="catalog-subnav-link ${empty param.activeSub || param.activeSub == 'services' ? 'active-sub' : ''}" data-catalog-subnav="services">
                                <i class="bi bi-clipboard2-pulse me-2" style="font-size: 14px;"></i>Dịch vụ phòng khám
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/catalog?tab=supplies" class="catalog-subnav-link ${param.activeSub == 'supplies' ? 'active-sub' : ''}" data-catalog-subnav="supplies">
                                <i class="bi bi-box-seam me-2" style="font-size: 14px;"></i>Vật tư &amp; Thiết bị
                            </a>
                        </li>
                    </ul>
                </c:if>
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
        </ul>
    </aside>
