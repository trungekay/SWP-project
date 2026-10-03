<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
            <li>
                <a href="${pageContext.request.contextPath}/admin/users" class="${param.activeNav == 'users' ? 'active' : ''}">
                    <i class="bi bi-person"></i>
                    Quản lý Người dùng
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/clinic-config" class="${param.activeNav == 'clinic-config' ? 'active' : ''}">
                    <i class="bi bi-gear"></i>
                    Cấu hình Phòng Khám
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/catalog" class="${param.activeNav == 'catalog' ? 'active' : ''}">
                    <i class="bi bi-box"></i>
                    Quản lý Danh mục (Dịch vụ/Vật tư)
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
        </ul>
    </aside>
